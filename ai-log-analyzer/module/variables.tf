variable "region" {
  type = string
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