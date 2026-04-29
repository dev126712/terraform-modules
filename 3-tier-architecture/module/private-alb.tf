resource "aws_lb" "private-internal-application-load-balancer" {
  name                       = "load-balancer-1-internal"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.internal-1-alb-security-group.id]
  subnets                    = [for subnet in aws_subnet.private-web-subnet : subnet.id]
  enable_deletion_protection = true

  access_logs {
    enabled = true
    # IMPORTANT: Replace 'your-alb-logs-bucket-name' with the actual S3 bucket name
    bucket = var.private-s3-bucket-name-lb
    # Optional: Add a prefix to organize logs within the bucket
    prefix = var.private-s3-bucket-name-lb-prefix
  }

  drop_invalid_header_fields = true

  tags = {
    Name = "Entry App Load Balancer"
  }
}

