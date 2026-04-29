output "load_balancer_ip" {
  value       = module.cloud_run.load_balancer_ip
  description = "The external IP address of the Load Balancer"
}
