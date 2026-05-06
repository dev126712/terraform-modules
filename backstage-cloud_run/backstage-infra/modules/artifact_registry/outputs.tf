###############################################################################
# Module: artifact_registry — outputs.tf
###############################################################################

output "repository_url" {
  description = "Full Artifact Registry URL for Docker push/pull"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.backstage.repository_id}"
}

output "repository_id" {
  value = google_artifact_registry_repository.backstage.repository_id
}
