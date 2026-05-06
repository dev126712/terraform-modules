###############################################################################
# Module: secrets
# Creates: Secret Manager secrets for DB password, GitHub token, app-config
# Grants: Cloud Run SA access to each secret
###############################################################################

###############################################################################
# DB Password — auto-generated, stored in Secret Manager
###############################################################################

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "backstage-${var.environment}-db-password"
  project   = var.project_id

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    service     = "backstage"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

###############################################################################
# GitHub Token — passed in as a variable, never stored in state in plaintext
###############################################################################

resource "google_secret_manager_secret" "github_token" {
  secret_id = "backstage-${var.environment}-github-token"
  project   = var.project_id

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    service     = "backstage"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "github_token" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_token
}

###############################################################################
# Backstage App Config — optional override for app-config.production.yaml
###############################################################################

resource "google_secret_manager_secret" "app_config" {
  secret_id = "backstage-${var.environment}-app-config"
  project   = var.project_id

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    service     = "backstage"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "app_config" {
  secret      = google_secret_manager_secret.app_config.id
  secret_data = var.backstage_app_config != "" ? var.backstage_app_config : "placeholder"
}

###############################################################################
# Grant Cloud Run SA access to each secret
###############################################################################

resource "google_secret_manager_secret_iam_member" "cloudrun_db_password" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloudrun_sa_email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_github_token" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloudrun_sa_email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_app_config" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.app_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloudrun_sa_email}"
}
