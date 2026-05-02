# 1. Enable Cloud Run API in ALL targeted projects
resource "google_project_service" "run_api" {
  for_each = var.target_project_ids
  
  project            = each.value
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# 2. Deploy the Cloud Run Service to ALL targeted projects
resource "google_cloud_run_v2_service" "ai_log_analyzer_svc" {
  for_each = var.target_project_ids
  
  name     = "ai-log-analyzer"
  location = var.region
  project  = each.value # Deploys into the specific project from the loop
  
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      # You can still use a central image or one per project
      image = "us-east1-docker.pkg.dev/${each.value}/mlops-repo/ai-log-analyzer:1.0.0"
      
      env {
        name  = "GEMINI_API_KEY"
        value = var.gemini_api_key
      }
    }

    vpc_access {
      network_interfaces {
        # This assumes all projects are spokes of the same Shared VPC
        network    = var.shared_vpc_id
        subnetwork = var.shared_subnetwork_id
      }
      egress = "ALL_TRAFFIC" 
    }
  }

  depends_on = [google_project_service.run_api]
}