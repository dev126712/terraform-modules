#### Serverless 3-Tier Architecture on Google Cloud (GCP)
A production-ready, highly scalable 3-tier web architecture deployed using Terraform. This project demonstrates advanced infrastructure-as-code (IaC) patterns, including global load balancing, private networking, and automated secret management.


### 🏗️ Architecture Overview
The architecture is divided into three distinct layers:

- Presentation Tier: A Cloud Run V2 frontend service protected by a Global External HTTP(S) Load Balancer with Cloud CDN enabled for edge caching.

- Application Tier: One or more Cloud Run V2 backend services handling business logic, accessible only via internal load balancer traffic.- - 

- Data Tier: A Cloud SQL (PostgreSQL 15) instance configured with Private IP only, ensuring the database is never exposed to the public internet.

### 🚀 Key Features

1. Dynamic Routing & Microservices

    - Dynamic Path Matching: Uses Terraform dynamic blocks to map multiple API routes (e.g., /api, /v1/auth, /billing) to backend services automatically.

    - Scalable Backends: Implements for_each logic to create unique Network Endpoint 

    - Groups (NEGs) and Backend Services for every route defined in the configuration.

2. Enterprise-Grade Security

    - Zero-Trust Ingress: Services are configured with INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER, preventing users from bypassing the Load Balancer.

    - Secret Orchestration: Database credentials are automatically generated via random_password, stored in Secret Manager, and injected into the backend container at runtime.

    - Least Privilege IAM: A dedicated Service Account is used for the backend with specific secretAccessor permissions.


3. Advanced Networking

    - Global Load Balancing: A single global entry point using a Static IP and Forwarding Rules.

    - Serverless VPC Access: Uses a VPC Access Connector to allow the Serverless application tier to communicate privately with the Data tier.

    - Private Service Access: Uses VPC Peering to connect the custom VPC to Google-managed services.

    ### 🛠️ Tech Stack

    - Infrastructure: Terraform
    - Compute: Cloud Run V2 
    - Database: Cloud SQL (PostgreSQL) 
    - Networking: Global Load Balancer, Cloud CDN, VPC, VPC Access Connector 
    - Security: Secret Manager, IAM, Random Provider 

### 📖 Deployment

Initialize Terraform: 
```sh
terraform init
```

Configure Variables: Update ``` project_id ``` and ``` cloud_run_region ``` in ``` variables ```.tf or a ``` terraform.tfvars ``` file.

Deploy: 
```sh 
terraform apply
```
`
Access: The output will provide the ``` load_balancer_ip ```. Point your domain or test via this IP.
