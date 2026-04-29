# AWS Production-Grade 3-Tier Architecture

This project deploys a highly secure and scalable 3-tier architecture on AWS using Terraform. It is designed to simulate a real-world enterprise environment where security and auditing are paramount.
![alt text](https://github.com/dev126712/terraform-modules/blob/4e862058e978cf449a7c5457932dc60d21792dbe/3-tier-architecture/Untitled%20Diagram.drawio.png)

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
