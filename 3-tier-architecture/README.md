![alt text](https://github.com/dev126712/three-tier-architecture/blob/6235857785ad7c407f1f26ef24c3ce65f9fb1e3f/Untitled%20Diagram.drawio.png)


# AWS Production-Grade 3-Tier Architecture

This project deploys a highly secure and scalable 3-tier architecture on AWS using Terraform. It is designed to simulate a real-world enterprise environment where security and auditing are paramount.

## 🏗️ Architecture Design

The infrastructure is distributed across multiple Availability Zones to ensure high availability:

1.  **Public Layer**: Internet Gateway, NAT Gateways, and a Bastion Host for secure administrative access.
2.  **Web Tier (Private)**: Frontend application in an Auto Scaling Group, fronted by a Public ALB protected by AWS WAF.
3.  **Application Tier (Private)**: Logic layer behind an Internal ALB, isolated from the public internet.
4.  **Database Tier (Private)**: Dedicated private subnets for persistent storage.


## ✨ Highlighted Features

* **Enterprise Security**: WAF Managed Rule Sets protect against common exploits (SQLi, Log4j).
* **Audit-Ready**: VPC Flow Logs are automatically captured and replicated to a secure log-archive bucket.
* **Hardened Instances**: All EC2 instances use IMDSv2 and are shielded in private subnets.
* **Lifecycle Management**: Automated S3 storage class transitions (Standard to Glacier) to optimize costs.

## 📊 Key Components

| Component | Purpose |
| :--- | :--- |
| **VPC** | Custom network with strict segmentation and DNS hostnames. |
| **ASG** | Auto-scaling compute for both Web and App tiers. |
| **WAFv2** | Managed firewall rules attached to the external entry point. |
| **Bastion Host** | Secure jump server for internal network management. |
| **Flow Logs** | Full traffic logging and replication for security forensics. |

## 🔧 Setup & Customization

Update your `terraform.tfvars` with your specific requirements:

* `aws_region`: Target deployment region.
* `vpc_cidr`: Main VPC IP range.
* `bastion-host-ssh-cidr`: Your specific IP for secure access.
* `web_tier_amis` / `app_tier_amis`: Region-specific AMI IDs.


# 1 Infrastructure ci ( ci-terraform.yml )
````
name: Deploy Terraform
on: 
  push:
    paths: 
      - '**.tf'
      - '.github/workflows/ci-terraform.yml'
permissions:
  contents: read
  packages: read
  pull-requests: write

jobs:
````
### -1 Terraform check 
````
verify:
    env:
        AWS_ACCESS_KEY_ID: "${{ secrets.AWS_ACCESS_KEY_ID }}"
        AWS_SECRET_ACCESS_KEY: "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
    runs-on: ubuntu-latest
    steps:
      - name: Code Checkout
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform init
        run: terraform init

      - name: Terraform fmt
        run: terraform fmt
        
      - name: Terraform validate
        run: terraform validate 

      - name: Terraform fmt check
        run: terraform fmt -check -recursive  

      - name: Terraform Plan
        run: terraform plan  

````
# 2 Security scan ( security.yml )
````
name: security check

on:
  push:
    branches:
      - main
    paths: '**'

permissions:
  contents: read

````

### -1 Security check on workflows yml files
````
 secirity-scan-on-workflows:
    runs-on: ubuntu-latest
    permissions:
      contents: write 
    steps:
    - name: checkout repo
      uses: actions/checkout@v4

    - name: Run Checkov Security Scan on yml files
      uses: bridgecrewio/checkov-action@master
      with:
        directory:  .github/workflows
        output_format: cli
        soft_fail: true
        quiet: true  
````
#### -2 Security check on Terraform files
````
secirity-scan-on-terraform-files:
    runs-on: ubuntu-latest
    permissions:
      contents: write 
    steps:
    - name: checkout repo
      uses: actions/checkout@v4

    - name: Run Checkov Security Scan on yml files
      uses: bridgecrewio/checkov-action@master
      with:
        directory:  .
        output_format: cli
        soft_fail: true
        quiet: true
````

