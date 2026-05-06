###############################################################################
# Module: secrets — variables.tf
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

variable "cloudrun_sa_email" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "backstage_app_config" {
  type      = string
  sensitive = true
  default   = ""
}
