# GCP Landing Zone - Enterprise Foundation

This project implements a production-ready Google Cloud Platform (GCP) Landing Zone using Terraform. It establishes a secure, scalable, and hierarchical resource structure based on the Google Cloud Adoption Framework.

## 🏗️ Architecture Overview

The Landing Zone is designed to centralize networking and security while allowing decentralized development across different environments (Development, Testing, and Production).

![GCP Architecture Diagram](./Screenshot%202026-04-30%208.30.26%20PM.png)

### Key Components

*   **Resource Hierarchy**: Organized using Folders for logical separation of environments and to enable hierarchical IAM policy inheritance.
*   **Shared VPC (Hub-and-Spoke)**: Implements a centralized networking model where a single Host Project (`platform-net-host`) manages the VPC and subnets, which are then shared with Service Projects (`Production`, `Development`).
*   **Bootstrap Project**: Contains a "Seed" project and CI/CD project to isolate the management of the infrastructure itself from the workloads.
*   **Security & Governance**: 
    *   Subnets are configured with `private_ip_google_access` to ensure internal-only communication for sensitive workloads.
    *   Projects are created with `auto_create_network = false` to prevent default network clutter and enforce the use of the Shared VPC.

## 📂 Directory Structure
```text
.
├── main.tf                     Root module
├── providers.tf                Provider configuration (Google & Google-Beta)
├── variables.tf                Global input variables
├── terraform.tfvars            Environment-specific values (Sensitive)
└── module/                     Internal Logic
    ├── hierarchy.tf            Folders and Project resources
    ├── networking.tf           Shared VPC Host/Service attachments
    └── network_resources.tf    VPC, Subnets, and Cloud NAT
```

🛠️ Design Decisions 
- Why Shared VPC ?: By centralizing the network in the Shared infrastructure folder, we reduce operational overhead, maintain a single source of truth for firewall rules, and lower costs by sharing Cloud NAT and Interconnect resources across projects.
- Modular Design: The project uses a standalone internal module to ensure that the Landing Zone logic can be versioned and reused for multiple departments or business units.
