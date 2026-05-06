# Backstage Infrastructure — Google Cloud Run (Terraform)

Production-grade Terraform infrastructure for running [Backstage](https://backstage.io) on Google Cloud Run, with a private Cloud SQL PostgreSQL database, Secret Manager, VPC networking, and Artifact Registry.

## Architecture

```
Internet
   │
   ▼
Cloud Run (Backstage)
   │  ◄── VPC Connector ──► Private Subnet ──► Cloud NAT ──► Internet
   │  ◄── Secret Manager (DB password, GitHub token, app-config)
   │  ◄── Artifact Registry (Docker image)
   │
   ▼
Cloud SQL PostgreSQL 15 (Private IP, HA, automated backups)
```

## Module Structure

```
backstage-infra/
├── main.tf                        # Root orchestration
├── variables.tf                   # Root variables
├── outputs.tf                     # Root outputs
├── terraform.tfvars.example       # Example config (copy → terraform.tfvars)
├── .gitignore
└── modules/
    ├── networking/                # VPC, subnet, NAT, Cloud Router, VPC Connector
    ├── iam/                       # Service accounts + least-privilege IAM
    ├── secrets/                   # Secret Manager (DB password, GitHub token)
    ├── database/                  # Cloud SQL PostgreSQL 15 (private IP, HA)
    ├── artifact_registry/         # Docker image repository
    └── cloud_run/                 # Backstage Cloud Run v2 service
```

## What Gets Created

| Resource | Details |
|---|---|
| VPC | Custom, no auto-subnets, regional routing |
| Private Subnet | `10.20.1.0/24`, private Google access enabled |
| Cloud Router + NAT | Outbound internet for private nodes |
| Private Service Access | Cloud SQL private IP peering |
| VPC Serverless Connector | Cloud Run → Cloud SQL (private) |
| Firewall Rules | Default-deny + allow internal/health-checks/IAP |
| Cloud SQL PostgreSQL 15 | Private IP, REGIONAL HA, SSL enforced, PITR backups |
| Secret Manager | DB password (auto-generated), GitHub token, app-config |
| Artifact Registry | Docker repo with auto-cleanup of old images |
| Cloud Run v2 | Backstage with min instances, health probes, secret mounts |
| Service Account | Least-privilege SA (SQL client, Secret Accessor, Log Writer) |

## Prerequisites

- Terraform >= 1.5
- GCP project with billing enabled
- `gcloud` CLI authenticated
- A built Backstage Docker image

## Usage

### 1. Clone and configure

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Build and push your Backstage image

```bash
# Authenticate Docker to Artifact Registry (after first apply creates the repo)
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build
docker build -t us-central1-docker.pkg.dev/YOUR_PROJECT/backstage-prod/backstage:latest .

# Push
docker push us-central1-docker.pkg.dev/YOUR_PROJECT/backstage-prod/backstage:latest
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access Backstage

```bash
terraform output backstage_url
```

## Security Notes

- Cloud SQL has **no public IP** — only reachable via VPC connector from Cloud Run
- All secrets are stored in **Secret Manager**, never in environment variable plaintext
- DB password is **auto-generated** by Terraform (32 chars, special chars)
- Cloud Run SA follows **least-privilege** — only the roles it needs
- Firewall default-deny with explicit allow rules
- SSL enforced on Cloud SQL

## Production Checklist

- [ ] Set `db_deletion_protection = true`
- [ ] Set `db_availability_type = "REGIONAL"` for HA
- [ ] Set `min_instances = 1` to avoid cold starts
- [ ] Configure a custom domain (update `APP_CONFIG_app_baseUrl`)
- [ ] Set up GCS backend for remote Terraform state
- [ ] Add Cloud Armor for WAF / DDoS protection
- [ ] Configure alerting policies in Cloud Monitoring
