# This goes in your ROOT serverless-3-Tier/outputs.tf
output "load_balancer_ip" {
  value       = module.cloud_run.load_balancer_ip
  description = "The external IP address of the Load Balancer"
}
