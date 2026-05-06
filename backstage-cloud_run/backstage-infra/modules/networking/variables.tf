###############################################################################
# Module: networking — variables.tf
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

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "connector_cidr" {
  description = "CIDR for Serverless VPC Access Connector — must be /28"
  type        = string
}
