###############################################################################
# Module: database — variables.tf
###############################################################################

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_ip_range_name" {
  type = string
}

variable "db_tier" {
  type    = string
  default = "db-g1-small"
}

variable "db_availability_type" {
  type    = string
  default = "REGIONAL"
}

variable "db_deletion_protection" {
  type    = bool
  default = true
}

variable "cloudrun_sa_email" {
  type = string
}

variable "db_password_secret_id" {
  description = "Secret Manager secret ID for DB password (used for dependency only)"
  type        = string
}

variable "db_password" {
  description = "Raw DB password from secrets module"
  type        = string
  sensitive   = true
  default     = ""
}
