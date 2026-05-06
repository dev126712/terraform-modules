###############################################################################
# Module: iam — outputs.tf
###############################################################################

output "cloudrun_sa_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.cloudrun.email
}

output "cloudrun_sa_id" {
  description = "Cloud Run service account ID"
  value       = google_service_account.cloudrun.id
}
