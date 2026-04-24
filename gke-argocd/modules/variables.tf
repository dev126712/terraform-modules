# --- GKE Cluster Variables ---

variable "cluster_name" {
  type        = string
  description = "The name of the GKE cluster."
}

variable "cluster_region" {
  type        = string
  description = "The region where the cluster will be hosted."
}

variable "region" {
  type        = string
  description = "The region for the subnetwork and router."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "node_count" {
  type        = number
  description = "The initial number of nodes for the cluster."
}

variable "deletion_protection" {
  type        = bool
  description = "Whether or not to allow Terraform to destroy the cluster."
}

variable "node_pool_name" {
  type        = string
  description = "The name of the node pool."
}

variable "node_pool_count" {
  type        = number
  description = "The number of nodes per zone."
}

variable "machine_type" {
  type        = string
  description = "The machine type for the nodes."
}

variable "min_node_pool_count" {
  type        = number
}

variable "max_node_pool_count" {
  type        = number
}

variable "auto_repair" {
  type        = bool
}

variable "auto_upgrade" {
  type        = bool
}

variable "static_ip_name" {
  type        = string
  description = "The name of the static global IP address for the load balancer."
}

variable "node_locations" {
  type        = list(string)
  description = "The list of zones where nodes should be created."
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "zone_count" {
  type        = number
  description = "The number of zones from the list to utilize."
  default     = 1
}


# --- ArgoCD Dynamic Variables ---

variable "argocd_app_name" {
  type        = string
  description = "The name of the root ArgoCD application." 
}

variable "repo_url" {
  type        = string
  description = "The Git repository URL for ArgoCD to track."
}

variable "target_revision" {
  type        = string
  description = "The branch, tag, or commit ArgoCD should track."
}

variable "app_path" {
  type        = string
  description = "The path within the repo to the application manifests."
}

variable "sync_prune" {
  type        = bool
  description = "Whether ArgoCD should prune resources."
}

variable "sync_self_heal" {
  type        = bool
  description = "Whether ArgoCD should automatically heal resources." 
}

variable "domain_name" {
  type        = string
  description = "The domain name for the application."
}
