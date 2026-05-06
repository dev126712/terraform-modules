###############################################################################
# Module: secrets — outputs.tf
###############################################################################

output "db_password_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}

output "db_password_secret_version" {
  value = google_secret_manager_secret_version.db_password.version
}

output "db_password_value" {
  description = "Raw DB password — used by database module to create Cloud SQL user"
  value       = random_password.db_password.result
  sensitive   = true
}

output "github_token_secret_id" {
  value = google_secret_manager_secret.github_token.secret_id
}

output "github_token_secret_version" {
  value = google_secret_manager_secret_version.github_token.version
}

output "app_config_secret_id" {
  value = google_secret_manager_secret.app_config.secret_id
}

output "app_config_secret_version" {
  value = google_secret_manager_secret_version.app_config.version
}
