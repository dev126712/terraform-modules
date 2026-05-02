output "connection_name" {
  description = "The name of the Cloud Build v2 connection"
  value       = google_cloudbuildv2_connection.github_connection.name
}

output "repository_id" {
  description = "The ID of the linked repository"
  value       = google_cloudbuildv2_repository.repo.id
}

output "trigger_id" {
  description = "The ID of the build trigger"
  value       = google_cloudbuild_trigger.push_trigger.id
}