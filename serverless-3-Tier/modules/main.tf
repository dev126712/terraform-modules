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

# 3. Create the Serverless VPC Connector
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
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = var.frontend_container_image
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
    cache_mode = "CACHE_ALL_STATIC"
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
  default_service = google_compute_backend_service.frontend.id # Default goes to Frontend

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.frontend.id

    path_rule {
      paths   = ["/api", "/api/*"]
      service = google_compute_backend_service.backend.id
    }
  }
}

resource "google_compute_target_http_proxy" "frontend" {
  name    = "http-proxy"
  url_map = google_compute_url_map.frontend.id
}

resource "google_compute_global_forwarding_rule" "frontend" {
  name                  = "forwarding-rule"
  target                = google_compute_target_http_proxy.frontend.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}


##################### ---------------- Backend ---------------- #####################

resource "google_cloud_run_v2_service" "backend" {
  name     = var.google_cloud_run_backend_service_name
  location = var.cloud_run_region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    vpc_access {
      connector = google_vpc_access_connector.main_connector.id
      egress    = "ALL_TRAFFIC"
    }
    containers {
      image = var.backend_container_image
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "backend_access" {
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.cloud_run_region
  cloud_run {
    service = google_cloud_run_v2_service.backend.name
  }
}

resource "google_compute_backend_service" "backend" {
  name                  = "api-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  enable_cdn            = false # Typically false for dynamic APIs

  backend {
    group = google_compute_region_network_endpoint_group.backend_neg.id
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
  network       = google_compute_network.app_vpc.id # Reuses your custom-vpc 
  project       = var.project_id
}

# 2. Establish a private connection between Google and your VPC
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.app_vpc.id 
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# 3. The Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "app-db-instance"
  database_version = "POSTGRES_15"
  region           = var.cloud_run_region
  project          = var.project_id
  
  # Ensure the connection is ready before creating the DB
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro" # Smallest tier, perfect for testing/free tier
    
    ip_configuration {
      ipv4_enabled    = false # Disables Public IP for security
      private_network = google_compute_network.app_vpc.id 
    }

    # Optimization to keep costs low
    backup_configuration {
      enabled = false 
    }
  }

  deletion_protection = false # Allows you to destroy it easily during development [cite: 8]
}

# 4. The actual Database inside the instance
resource "google_sql_database" "database" {
  name     = "app_db"
  instance = google_sql_database_instance.main.name
}

# 5. The Database User
resource "google_sql_user" "users" {
  name     = "app_user"
  instance = google_sql_database_instance.main.name
  password = "your-secure-password" # In the next step, we'll move this to Secret Manager
}