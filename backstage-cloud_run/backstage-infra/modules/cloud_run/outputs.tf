###############################################################################
# Module: cloud_run — outputs.tf
###############################################################################

output "service_url" {
  description = "Public URL of the Backstage Cloud Run service"
  value       = google_cloud_run_v2_service.backstage.uri
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.backstage.name
}

output "service_id" {
  description = "Cloud Run service ID"
  value       = google_cloud_run_v2_service.backstage.id
}

output "latest_revision" {
  description = "Latest deployed revision name"
  value       = google_cloud_run_v2_service.backstage.latest_ready_revision
}
