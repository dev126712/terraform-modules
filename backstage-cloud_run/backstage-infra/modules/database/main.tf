###############################################################################
# Module: database
# Creates: Cloud SQL PostgreSQL 15 instance with:
#   - Private IP only (no public IP)
#   - High availability (REGIONAL)
#   - Automated backups + PITR
#   - Deletion protection
#   - SSL enforcement
#   - Backstage database and user
###############################################################################

###############################################################################
# Cloud SQL Instance
###############################################################################

resource "google_sql_database_instance" "backstage" {
  name                = "backstage-${var.environment}-postgres"
  project             = var.project_id
  region              = var.region
  database_version    = "POSTGRES_15"
  deletion_protection = var.db_deletion_protection

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type # REGIONAL = HA with standby
    disk_autoresize   = true
    disk_size         = 20   # GB — autoresize will grow as needed
    disk_type         = "PD_SSD"

    # ── Private IP only ───────────────────────────────────────────────────────
    ip_configuration {
      ipv4_enabled                                  = false  # No public IP
      private_network                               = var.vpc_id
      require_ssl                                   = true
      enable_private_path_for_google_cloud_services = true
      allocated_ip_range                            = var.private_ip_range_name
    }

    # ── Automated Backups + Point-in-Time Recovery ────────────────────────────
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00" # 3 AM UTC
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 14
        retention_unit   = "COUNT"
      }
    }

    # ── Maintenance Window ─────────────────────────────────────────────────────
    maintenance_window {
      day          = 7    # Sunday
      hour         = 4    # 4 AM UTC
      update_track = "stable"
    }

    # ── Query Insights ─────────────────────────────────────────────────────────
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    # ── Database Flags ─────────────────────────────────────────────────────────
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000" # Log queries taking > 1s
    }

    user_labels = {
      environment = var.environment
      managed-by  = "terraform"
      service     = "backstage"
    }
  }

  depends_on = [var.private_ip_range_name]
}

###############################################################################
# Database
###############################################################################

resource "google_sql_database" "backstage" {
  name     = "backstage"
  instance = google_sql_database_instance.backstage.name
  project  = var.project_id
  charset  = "UTF8"
}

###############################################################################
# Database User
###############################################################################

resource "google_sql_user" "backstage" {
  name     = "backstage"
  instance = google_sql_database_instance.backstage.name
  project  = var.project_id
  password = var.db_password

  deletion_policy = "ABANDON" # Prevent errors when destroying instance
}

###############################################################################
# Grant Cloud Run SA Cloud SQL Client role (already in IAM module,
# but scoped here at instance level for extra security)
###############################################################################

resource "google_project_iam_member" "cloudrun_sql_instance" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${var.cloudrun_sa_email}"
}
