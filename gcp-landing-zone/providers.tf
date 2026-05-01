variable "org_id" {
  description = "The numeric ID of your Google Cloud Organization"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with"
  type        = string
}

variable "prefix" {
  description = "A short prefix to ensure project IDs are globally unique (e.g., 'acme')"
  type        = string
  default     = "mycorp"
}

variable "region" {
  description = "Default region for networking and resources"
  type        = string
  default     = "northamerica-northeast1"
}

variable "zone" {
  description = "Default zone for resources"
  type        = string
  default     = "northamerica-northeast1-a"
}

variable "seed_project_id" {
  description = "The ID of the project where Terraform is running"
  type        = string
}
