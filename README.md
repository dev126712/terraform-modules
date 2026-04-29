# Terraform Modules Library

Welcome to my personal collection of reusable Terraform modules. This repository is designed to house various infrastructure patterns for Cloud and DevOps automation.


## 📂 Available Modules

| Module Name | Cloud | Description |
| :--- | :--- | :--- |
| [**serverless-3-tier**](./serverless-3-Tier) | GCP | Production-ready Cloud Run stack with Global Load Balancing, CDN, Secret Manager, and Private Cloud SQL. |
| [**gke-argocd**](./gke-argocd) | GCP | GKE cluster with integrated ArgoCD, Monitoring, and Security. |
| [**3-tier-architecture**](./3-tier-architecture) | AWS | Enterprise-grade stack featuring WAFv2 protection, Public/Internal ALBs, Auto Scaling, and Multi-AZ RDS isolation. |

## 🚀 How to use this Repository
Each folder in this repository is a standalone module. You can reference them directly in your Terraform code:

Example: Deploying the GKE-ArgoCD
```hcl
module "my_infrastructure" {
  source = "[github.com/dev126712/terraform-modules//gke-argocd](https://github.com/dev126712/terraform-modules//gke-argocd)"
  
  # Module specific variables
  project_id = "your-gcp-project"
}
```

Example: Deploying the Serverless 3-Tier Stack
```hcl
module "app_infrastructure" {
  source = "github.com/dev126712/terraform-modules//serverless-3-tier"

  project_id               = "your-gcp-project-id"
  cloud_run_region         = "us-central1"
  frontend_container_image = "gcr.io/your-project/frontend:latest"
  backend_container_image  = "gcr.io/your-project/backend:latest"
  
  api_routes = {
    "api" = "backend"
  }
}
```

### Example: Deploying the AWS 3-Tier Stack
```hcl
module "aws_app_infra" {
  source = "[github.com/dev126712/terraform-modules//3-tier-architecture-aws](https://github.com/dev126712/terraform-modules//3-tier-architecture)"

  aws_region               = "us-east-1"
  vpc_cidr                 = "10.0.0.0/16"
  web_tier_certificate_arn = "arn:aws:acm:..."
  db_password              = var.db_password # Marked as sensitive
}
