variable "project_id" {
    description = "project ID"
}

variable "vpc" {
  description = "vpc where the vpc connector lives"
}

variable "subnet" {
  
}

variable "google_cloud_run_service_name" {
    description = "cloud run service name"
}

variable "cloud_run_region" {
    description = "Cloud run region"
}

variable "google_cloud_run_backend_service_name" {
    description = "Cloud Run backend service name"
    default     = "backend-api"
}

variable "backend_container_image" {
    description = "backend image"
}

variable "frontend_container_image" {
    description = "frontend image"
}
