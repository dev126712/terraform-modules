module "cloud_run" {
  source = "./modules"

  vpc    = "serverless-app-vpc"
  subnet = "serverless-app-subnet"
  # cloud run configuration
  cloud_run_region              = "us-central1"
  project_id                    = "project-test-490416"
  google_cloud_run_service_name = "test-service"

  backend_container_image  = "us-central1-docker.pkg.dev/project-test-490416/app-images/backend:latest3"
  frontend_container_image = "us-central1-docker.pkg.dev/project-test-490416/app-images/frontend:latest3"
}
