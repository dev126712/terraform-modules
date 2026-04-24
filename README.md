# Terraform Modules Library

Welcome to my personal collection of reusable Terraform modules. This repository is designed to house various infrastructure patterns for Cloud and DevOps automation.

## 📂 Available Modules

| Module Name | Cloud | Description |
| :--- | :--- | :--- |
| [**gke-argocd**](./gke-argocd) | GCP | GKE cluster with integrated ArgoCD, Monitoring, and Security. |

## 🚀 How to use this Repository
Each folder in this repository is a standalone module. You can reference them directly in your Terraform code:

```hcl
module "my_infrastructure" {
  source = "[github.com/dev126712/terraform-modules//gke-argocd](https://github.com/dev126712/terraform-modules//gke-argocd)"
  
  # Module specific variables
  project_id = "your-gcp-project"
}
