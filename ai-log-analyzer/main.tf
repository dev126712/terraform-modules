module "ai-log-analyxer" {
  source = "./module"

  region = "us"
  gemini_api_key = "test"
  shared_vpc_id = ""
  shared_subnetwork_id = ""

  target_project_ids = [
    # List of project(s) to enable loud Run API
    google_project.developer_project.project_id,
    google_project.internal_testing_project.project_id,
    google_project.production_project.project_id
  ]
}