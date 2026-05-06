###############################################################################
# Module: database — outputs.tf
###############################################################################

output "instance_connection_name" {
  description = "Cloud SQL connection name (project:region:instance)"
  value       = google_sql_database_instance.backstage.connection_name
}

output "instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.backstage.name
}

output "private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.backstage.private_ip_address
}

output "db_name" {
  description = "Backstage database name"
  value       = google_sql_database.backstage.name
}

output "db_user" {
  description = "Backstage database user"
  value       = google_sql_user.backstage.name
}
