variable "project_id" {
  description = "project ID"
  type = string
}

variable "vpc" {
  description = "vpc where the vpc connector lives"
}

variable "subnet" {
  type = string
}

variable "google_cloud_run_service_name" {
  type = string
  description = "cloud run service name"
}

variable "cloud_run_region" {
  type = string
  description = "Cloud run region"
}

variable "google_cloud_run_backend_service_name" {
  description = "Cloud Run backend service name"
  default     = "backend-api"
}

variable "backend_container_image" {
  type = string
  description = "backend image"
}

variable "frontend_container_image" {
  type = string
  description = "frontend image"
}

##################### ---------------- API Route ---------------- #####################


variable "api_routes" {
  description = "A map of API paths to their respective backend services"
  type        = map(string)
  default = {
    "api"     = "backend"     # /api/* goes to the main backend
    # "v1/auth" = "auth-svc"    # /api/v1/auth/* goes to a specific auth service
    # "billing" = "billing-svc" # /api/billing/* goes to billing
  }
}

##################### ---------------- Database ---------------- #####################

variable "database_name" {
  type = string
}

variable "database_version" {
  type = string
}

variable "database_tier" {
  type = string
}

variable "backup_configuration" {
  type = bool
  default = false
  
}

variable "deletion_protection" {
  type = bool
  default = false
  
}