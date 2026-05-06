###############################################################################
# Module: cloud_run
# Creates: Cloud Run v2 service for Backstage with:
#   - VPC connector (private Cloud SQL access)
#   - Secrets from Secret Manager (no env var plaintext)
#   - Min instances (no cold starts)
#   - CPU always allocated
#   - Health checks
#   - Startup probe
###############################################################################

resource "google_cloud_run_v2_service" "backstage" {
  name     = "backstage-${var.environment}"
  project  = var.project_id
  location = var.region

  # Allow only internal + load balancer traffic for production
  ingress = var.allow_public_access ? "INGRESS_TRAFFIC_ALL" : "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    service     = "backstage"
  }

  template {
    service_account = var.cloudrun_sa_email

    # ── Scaling ────────────────────────────────────────────────────────────────
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # ── VPC Access (reach Cloud SQL via private IP) ────────────────────────────
    vpc_access {
      connector = var.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY" # Only private traffic via VPC; public via internet
    }

    # ── Annotations ───────────────────────────────────────────────────────────
    annotations = {
      "run.googleapis.com/startup-cpu-boost" = "true"
    }

    containers {
      name  = "backstage"
      image = var.backstage_image

      # ── Resources ─────────────────────────────────────────────────────────────
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle          = false # CPU always allocated — avoids cold starts
        startup_cpu_boost = true  # Extra CPU during startup
      }

      # ── Ports ─────────────────────────────────────────────────────────────────
      ports {
        name           = "http1"
        container_port = 7007
      }

      # ── Environment Variables (non-sensitive) ──────────────────────────────────
      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "APP_CONFIG_app_baseUrl"
        value = "https://backstage-${var.environment}.run.app" # Update with your domain
      }

      env {
        name  = "APP_CONFIG_backend_baseUrl"
        value = "https://backstage-${var.environment}.run.app"
      }

      env {
        name  = "POSTGRES_HOST"
        value = "/cloudsql/${var.db_instance_connection}"
      }

      env {
        name  = "POSTGRES_PORT"
        value = "5432"
      }

      env {
        name  = "POSTGRES_DB"
        value = var.db_name
      }

      env {
        name  = "POSTGRES_USER"
        value = var.db_user
      }

      # ── Secrets as Environment Variables ───────────────────────────────────────
      env {
        name = "POSTGRES_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.db_password_secret_id
            version = var.db_password_secret_version
          }
        }
      }

      env {
        name = "GITHUB_TOKEN"
        value_source {
          secret_key_ref {
            secret  = var.github_token_secret_id
            version = var.github_token_secret_version
          }
        }
      }

      # ── App Config as mounted volume (optional override) ──────────────────────
      volume_mounts {
        name       = "app-config-secret"
        mount_path = "/app/app-config.production.yaml"
      }

      # ── Cloud SQL Unix socket (no Cloud SQL Auth Proxy needed with v2) ─────────
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      # ── Startup Probe ─────────────────────────────────────────────────────────
      startup_probe {
        http_get {
          path = "/healthcheck"
          port = 7007
        }
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 6 # 60s total before giving up
      }

      # ── Liveness Probe ────────────────────────────────────────────────────────
      liveness_probe {
        http_get {
          path = "/healthcheck"
          port = 7007
        }
        initial_delay_seconds = 30
        timeout_seconds       = 5
        period_seconds        = 30
        failure_threshold     = 3
      }
    }

    # ── Volumes ──────────────────────────────────────────────────────────────────

    volumes {
      name = "app-config-secret"
      secret {
        secret = var.app_config_secret_id
        items {
          version = var.app_config_secret_version
          path    = "app-config.production.yaml"
          mode    = 0444
        }
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.db_instance_connection]
      }
    }
  }

  # ── Traffic — 100% to latest revision ────────────────────────────────────────
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      # Ignore image tag changes — managed by CI/CD, not Terraform
      template[0].containers[0].image,
    ]
  }
}

###############################################################################
# IAM — Public Access (if enabled)
###############################################################################

resource "google_cloud_run_v2_service_iam_member" "public" {
  count    = var.allow_public_access ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.backstage.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
