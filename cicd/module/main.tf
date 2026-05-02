# 1. Store the GitHub Token Securely
resource "google_secret_manager_secret" "github_token" {
  secret_id = "${var.repository_name}-github-token"
  project   = var.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_pat
}

# 2. Grant Cloud Build permission to read the secret (Required for the connection to work)
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_secret_access" {
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

# 3. Create the Cloud Build v2 Connection
resource "google_cloudbuildv2_connection" "github_connection" {
  project  = var.project_id
  location = var.region
  name     = "${var.repository_name}-connection"

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_version.id
    }
  }

  depends_on = [google_secret_manager_secret_iam_member.cloudbuild_secret_access]
}

# 4. Link the specific Repository
resource "google_cloudbuildv2_repository" "repo" {
  project           = var.project_id
  location          = var.region
  name              = var.repository_name
  parent_connection = google_cloudbuildv2_connection.github_connection.name
  remote_uri        = var.repository_uri
}

# 5. Create the Push Trigger
resource "google_cloudbuild_trigger" "push_trigger" {
  project  = var.project_id
  location = var.region
  name     = "${var.repository_name}-push-trigger"

  repository_event_config {
    repository = google_cloudbuildv2_repository.repo.id
    push {
      branch = var.trigger_branch
    }
  }

  filename = "cloudbuild.yaml" 
}