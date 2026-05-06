###############################################################################
# Root Variables
###############################################################################

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# ── Networking ────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "Primary CIDR for the VPC subnet"
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR for the private subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "connector_cidr" {
  description = "CIDR for the Serverless VPC Access connector (/28 required)"
  type        = string
  default     = "10.20.2.0/28"
}

# ── Database ─────────────────────────────────────────────────────────────────

variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-g1-small"
}

variable "db_availability_type" {
  description = "Cloud SQL availability type: ZONAL or REGIONAL (HA)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.db_availability_type)
    error_message = "db_availability_type must be ZONAL or REGIONAL."
  }
}

variable "db_deletion_protection" {
  description = "Enable deletion protection on Cloud SQL instance"
  type        = bool
  default     = true
}

# ── Cloud Run ─────────────────────────────────────────────────────────────────

variable "backstage_image" {
  description = "Full Backstage container image URI (e.g. us-central1-docker.pkg.dev/project/repo/backstage:latest)"
  type        = string
}

variable "min_instances" {
  description = "Minimum Cloud Run instances (use 1+ to avoid cold starts)"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 4
}

variable "cloud_run_cpu" {
  description = "CPU allocation for each Cloud Run instance"
  type        = string
  default     = "2"
}

variable "cloud_run_memory" {
  description = "Memory allocation for each Cloud Run instance"
  type        = string
  default     = "2Gi"
}

variable "allow_public_access" {
  description = "Allow unauthenticated public access to Cloud Run service"
  type        = bool
  default     = true
}

# ── Secrets ──────────────────────────────────────────────────────────────────

variable "github_token" {
  description = "GitHub Personal Access Token for Backstage GitHub integration"
  type        = string
  sensitive   = true
}

variable "backstage_app_config" {
  description = "Backstage app-config.production.yaml contents as a string"
  type        = string
  sensitive   = true
  default     = ""
}
