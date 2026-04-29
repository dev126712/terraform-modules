resource "google_compute_network" "app_vpc" {
  name                    = var.vpc
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "connector_subnet" {
  name          = var.subnet
  ip_cidr_range = "10.8.0.0/28"
  region        = var.cloud_run_region
  network       = google_compute_network.app_vpc.id
}

resource "google_vpc_access_connector" "main_connector" {
  name   = "vpc-conn"
  region = var.cloud_run_region
  subnet {
    name = google_compute_subnetwork.connector_subnet.name
  }
}
##################### ---------------- Frontend ---------------- #####################
resource "google_cloud_run_v2_service" "frontend" {
  name     = var.google_cloud_run_service_name
  location = var.cloud_run_region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = var.frontend_container_image
      ports {
        container_port = 80 # Change this to the port your app actually uses
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.frontend.name
  location = google_cloud_run_v2_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.cloud_run_region
  cloud_run {
    service = google_cloud_run_v2_service.frontend.name
  }
}

resource "google_compute_backend_service" "frontend" {
  name                  = "backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  enable_cdn = true
  cdn_policy {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 3600
    client_ttl  = 3600
    max_ttl     = 86400

    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

resource "google_compute_url_map" "frontend" {
  name            = "url-map"
  default_service = google_compute_backend_service.frontend.id 

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.frontend.id

    # DYNAMIC BLOCK STARTS HERE
    dynamic "path_rule" {
      for_each = var.api_routes
      content {
        paths = ["/${path_rule.key}/*"]

        service = google_compute_backend_service.backend[path_rule.value].id
      }
    }
  }
}

resource "google_compute_target_http_proxy" "frontend" {
  name    = "http-proxy"
  url_map = google_compute_url_map.frontend.id
}

resource "google_compute_global_address" "website_ip" {
  name         = "lb-static-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "frontend" {
  name                  = "forwarding-rule"
  target                = google_compute_target_http_proxy.frontend.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.website_ip.id
}

##################### ---------------- Backend ---------------- #####################

resource "google_cloud_run_v2_service" "backend" {
  for_each = toset(values(var.api_routes))
  name     = "${each.key}-service"
  location = var.cloud_run_region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {

    service_account = google_service_account.backend_sa.email
    vpc_access {
      connector = google_vpc_access_connector.main_connector.id
      egress    = "ALL_TRAFFIC"
    }
    containers {
      image = var.backend_container_image
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.main.private_ip_address
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.users.name
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.database.name # Added this
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "backend_access" {
  for_each = toset(values(var.api_routes))
  name     = google_cloud_run_v2_service.backend[each.key].name
  location = google_cloud_run_v2_service.backend[each.key].location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "backend_neg" {
  for_each              = toset(values(var.api_routes))
  name                  = "${each.key}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.cloud_run_region
  cloud_run {
    service = google_cloud_run_v2_service.backend[each.key].name
  }
}

resource "google_compute_backend_service" "backend" {
  for_each = toset(values(var.api_routes))

  name                  = "${each.key}-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"

  backend {
    # This links each backend to its specific Cloud Run NEG
    group = google_compute_region_network_endpoint_group.backend_neg[each.key].id
  }
}

# resource "google_artifact_registry_repository" "my_repo" {
#   location      = var.cloud_run_region
#   repository_id = "app-images"
#   description   = "Docker repository for frontend and backend"
#   format        = "DOCKER"
# }

##################### ---------------- Database ---------------- #####################

resource "google_compute_global_address" "private_ip_address" {
  name          = "google-managed-services-custom-vpc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.app_vpc.id 
  project       = var.project_id
}

# Establish a private connection between Google and your VPC
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.app_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_project_service.enabled_apis]
}

resource "google_sql_database_instance" "main" {
  name             = var.database_name
  database_version = var.database_version
  region           = var.cloud_run_region
  project          = var.project_id

  # Ensure the connection is ready before creating the DB
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.database_tier

    ip_configuration {
      ipv4_enabled    = false 
      private_network = google_compute_network.app_vpc.id
    }

    # Optimization to keep costs low
    backup_configuration {
      enabled = var.backup_configuration
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "database" {
  name     = "app_db"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "users" {
  name     = "app_user"
  instance = google_sql_database_instance.main.name
  # Reference the random password directly
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled_apis]
}

resource "google_secret_manager_secret_version" "db_password_v1" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

resource "google_service_account" "backend_sa" {
  account_id   = "backend-runner"
  display_name = "Backend Cloud Run Service Account"
}

# Grant the service account permission to read the secret
resource "google_secret_manager_secret_iam_member" "accessor" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}
