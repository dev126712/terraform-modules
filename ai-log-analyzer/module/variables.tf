variable "region" {
  type = string
}

variable "zone" {
  
}

variable "target_project_ids" {
  type        = set(string)
  description = "The list of project IDs where the AIOps service should be enabled and deployed."
}

variable "gemini_api_key" {
  type = string
}

variable "shared_vpc_id" {
  type = string
}

variable "shared_subnetwork_id" {
  type = string
}

variable "atlas_public_key" {
  type = string
}

variable "atlas_private_key" {
  type = string
}

variable "atlas_org_id" {
  type = string
}

variable "atlas_user_password" {
  type = string
}

variable "provider_instance_size_name" {
  type = string
  default = "M0"
}

variable "provider_region_name" {
  type = string
  default = "CENTRAL_US"
}