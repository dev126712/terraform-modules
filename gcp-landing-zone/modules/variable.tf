variable "org_id" {}
variable "prefix" {}
variable "billing_account" {}
#varible "" {}
variable "seed_project_id" {
  type        = string
  description = "The ID of the management project"
}

variable "region" {
  type    = string
  default = "northamerica-northeast1"
}

variable "zone" {
  type    = string
  default = "northamerica-northeast1-a"
}

variable "auto_create_network" {

  type    = bool
  default = false
}
