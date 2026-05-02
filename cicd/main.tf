module "aiops_pipeline" {
  source = "./modules/cicd"

  project_id                 = var.project_id
  region                     = var.cloud_run_region
  
  # GitHub Details
  github_pat                 = var.github_pat # Pass this in securely via terraform.tfvars
  github_app_installation_id = 12345678       # Your numeric GitHub App ID
  repository_name            = "aiops-log-analyzer"
  repository_uri             = "https://github.com/your-username/aiops-log-converter.git"
  trigger_branch             = "^main$"
}