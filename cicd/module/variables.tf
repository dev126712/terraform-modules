variable "project_id" {
  description = "The Google Cloud Project ID where Cloud Build will run"
  type        = string
}

variable "region" {
  description = "The region for Cloud Build and Secret Manager"
  type        = string
}

variable "github_pat" {
  description = "Your GitHub Personal Access Token (Keep this secure in your root variables)"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "The installation ID of the Google Cloud Build GitHub App"
  type        = number
}

variable "repository_name" {
  description = "The name you want to give the repository connection in GCP"
  type        = string
}

variable "repository_uri" {
  description = "The HTTPS URI of your GitHub repository (e.g., https://github.com/user/repo.git)"
  type        = string
}

variable "trigger_branch" {
  description = "The branch regex to trigger the build on (e.g., ^main$)"
  type        = string
  default     = "^main$"
}