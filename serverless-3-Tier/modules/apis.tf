resource "google_project_service" "enabled_apis" {
  project = var.project_id
  for_each = toset([
    "run.googleapis.com",             # Cloud Run
    "sqladmin.googleapis.com",        # Cloud SQL
    "secretmanager.googleapis.com",   # Secret Manager
    "compute.googleapis.com",         # Added for LB and CDN   
    "vpcaccess.googleapis.com",       # Serverless VPC Access
    "servicenetworking.googleapis.com" # Private Service Connect (for DB)
  ])

  service = each.key


  disable_on_destroy = false 
}
