###############################################################################
# Module: artifact_registry
# Creates: Docker repository for Backstage images
###############################################################################

resource "google_artifact_registry_repository" "backstage" {
  repository_id = "backstage-${var.environment}"
  project       = var.project_id
  location      = var.region
  format        = "DOCKER"
  description   = "Backstage Docker images — ${var.environment}"

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    service     = "backstage"
  }

  # Cleanup old images automatically
  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old-untagged"
    action = "DELETE"
    condition {
      tag_state = "UNTAGGED"
      older_than = "604800s" # 7 days
    }
  }
}

# Allow Cloud Run SA to pull images
resource "google_artifact_registry_repository_iam_member" "cloudrun_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.backstage.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.cloudrun_sa_email}"
}
