###############################################################################
# Root Outputs
###############################################################################

output "backstage_url" {
  description = "Public URL of the Backstage Cloud Run service"
  value       = module.cloud_run.service_url
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = module.cloud_run.service_name
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL for pushing Backstage images"
  value       = module.artifact_registry.repository_url
}

output "db_instance_connection_name" {
  description = "Cloud SQL instance connection name (for Cloud SQL proxy)"
  value       = module.database.instance_connection_name
  sensitive   = false
}

output "db_name" {
  description = "Backstage database name"
  value       = module.database.db_name
}

output "vpc_id" {
  description = "VPC network ID"
  value       = module.networking.vpc_id
}

output "cloudrun_service_account" {
  description = "Cloud Run service account email"
  value       = module.iam.cloudrun_sa_email
}

output "push_image_command" {
  description = "Command to configure Docker for pushing to Artifact Registry"
  value       = "gcloud auth configure-docker ${var.region}-docker.pkg.dev"
}
