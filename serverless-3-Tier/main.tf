module "cloud_run" {
  source = "./modules"

  vpc    = "serverless_app_vpc"
  subnet = "serverless_app_vpc"
  # cloud run configuration
  cloud_run_region              = "us-central1"
  project_id                    = "project-test-490416"
  google_cloud_run_service_name = "test-service"

  backend_container_image  = "us-docker.pkg.dev/cloudrun/container/hello"
  frontend_container_image = "us-docker.pkg.dev/cloudrun/container/hello"
}