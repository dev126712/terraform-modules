variable "project_id" {
  description = "The GCP Project ID where resources will be deployed"
  type        = string
  default     = "project-test-490416"
}

variable "region" {
  description = "The default GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  default     = "express-api-cluster1"
  description = "Cluster name"
}

variable "zone" {
  description = "The default GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "node_machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Cluster Node Type"
}

variable "node_pool_name" {
  type    = string
  default = "main-pool"
}
variable "node_pool_location" {
  type    = string
  default = "us-central1"
}
