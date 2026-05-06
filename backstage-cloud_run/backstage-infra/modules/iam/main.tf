###############################################################################
# Module: iam
# Creates: Cloud Run Service Account with least-privilege IAM bindings
###############################################################################

###############################################################################
# Cloud Run Service Account
###############################################################################

resource "google_service_account" "cloudrun" {
  account_id   = "backstage-${var.environment}-cloudrun"
  display_name = "Backstage Cloud Run SA (${var.environment})"
  description  = "Least-privilege SA for Backstage Cloud Run service"
  project      = var.project_id
}

###############################################################################
# IAM Bindings — Project Level
###############################################################################

# Allow Cloud Run SA to connect to Cloud SQL as a client
resource "google_project_iam_member" "cloudrun_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow Cloud Run SA to access Secret Manager secrets
resource "google_project_iam_member" "cloudrun_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow Cloud Run SA to write logs
resource "google_project_iam_member" "cloudrun_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow Cloud Run SA to write metrics
resource "google_project_iam_member" "cloudrun_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow Cloud Run SA to write traces (Cloud Trace)
resource "google_project_iam_member" "cloudrun_trace_agent" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow Cloud Run SA to pull images from Artifact Registry
resource "google_project_iam_member" "cloudrun_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}
