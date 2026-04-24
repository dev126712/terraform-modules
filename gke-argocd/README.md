## Module: GKE + ArgoCD

The gke-argocd module is a comprehensive "Infrastructure-as-Code" (IaC) solution that builds a production-ready environment on Google Cloud Platform (GCP) & GKE cluster and automatically installs ArgoCD for GitOps, VictoriaMetrics for monitoring, Trivy for scan security, Vault for secrets management.

#### Core Infrastructure & Networking
Custom VPC & Subnets: Instead of using default settings, it creates a dedicated custom-vpc and specific subnets to isolate your traffic.

GKE Cluster: A Google Kubernetes Engine cluster named my-gke-cluster is deployed in us-central1. It includes advanced features like Workload Identity for secure access to GCP services and the stable Gateway API for modern traffic management.

Secure External Access: It uses a Cloud NAT and Router setup so that nodes can access the internet for updates without being directly exposed to the public web

Firewalls: Specific rules allow internal communication while restricting external access to only necessary management ports.

#### GitOps with ArgoCD

Continuous Delivery is handled through ArgoCD, which is automatically installed via Helm.
  - Automated Deployment: It connects to your GitHub repository (microservice-charts-deployment.git) to automatically sync and deploy your applications.
  - Self-Healing: The configuration is set to "Self-Heal," meaning if someone manually changes a setting in the cluster, ArgoCD will automatically revert it to match your code in Git.

#### Security & Compliance

Security is integrated at multiple layers of the stack.HashiCorp Vault: 

  - Deployed for secret management, ensuring that sensitive credentials are never stored in plain text. It uses a dedicated Google Service Account for added security.
  - Trivy Operator: This tool constantly scans your running container images for "Critical" vulnerabilities, helping you stay ahead of security threats.
  - Least Privilege: GKE nodes are configured with specific OAuth scopes limited to logging, monitoring, and read-only storage access.
![GKE_ARGOCD]()
