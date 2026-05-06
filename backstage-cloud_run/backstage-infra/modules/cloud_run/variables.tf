###############################################################################
# Module: cloud_run — variables.tf
###############################################################################

variable "project_id" { type = string }
variable "region" { type = string }
variable "environment" { type = string }
variable "backstage_image" { type = string }
variable "cloudrun_sa_email" { type = string }
variable "vpc_connector_id" { type = string }
variable "db_instance_connection" { type = string }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_password_secret_id" { type = string }
variable "db_password_secret_version" { type = string }
variable "github_token_secret_id" { type = string }
variable "github_token_secret_version" { type = string }
variable "app_config_secret_id" { type = string }
variable "app_config_secret_version" { type = string }

variable "min_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 4
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "2Gi"
}

variable "allow_public_access" {
  type    = bool
  default = true
}
