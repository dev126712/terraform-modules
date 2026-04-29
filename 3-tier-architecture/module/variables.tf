################# ------------------ REGION  ------------------ #################
variable "aws_region" {
  type = string
}
################# ------------------ VPC & SUBNETS  ------------------ #################
###### ----- VPC  ----- ########
variable "vpc_cidr" {
  type = string
}

variable "vpc_tags" {
  type = string
}
###### ----- SUBNETS ----- ########
variable "availability-zone" {
  type        = list(string)
  description = "Availability Zones"
}

variable "private-web-subnet-cidr_block" {
  type        = list(string)
  description = "ptivate web subnet cidr block values"
}

variable "private-app-subnet-cidr_block" {
  type        = list(string)
  description = "ptivate app subnet cidr block values"
}

variable "private-db-subnet-cidr_block" {
  type        = list(string)
  description = "ptivate db subnet cidr block values"
}

variable "public-subnet-bastion-host-cidr-block" {
  type = string
}

variable "public-subnet-nat-gateway-cidr-block" {
  type = string
}
################# ------------------ NAT GATEWAY  ------------------ #################


################# ------------------ APP TIER  ------------------ #################
variable "app_tier_amis" {
  type    = string
  default = "ami-0f39ffd6e446bf727"
}

variable "app_instance_type" {
  type    = string
  default = "t2.micro"
}

################# ------------------ WEB TIER  ------------------ #################
variable "web_tier_amis" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "web_tier_certificate_arn" {
  type = string
}

################# ------------------ DATABASE  ------------------ #################
variable "db_instance_class" {
}

variable "db_name" {
}

variable "db_username" {
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

################# ------------------ Load Balancer  ------------------ #################
###### ----- Public Load Balancer  ----- ########
variable "public-load-balancer-http-allow-cidr" {
  type    = list(any)
  default = ["28.8.7.6/32"]
}

variable "public-s3-bucket-name-lb" {
  description = "bucket name for the logs from public external load balancer"
  type        = string
  default     = "your-alb-logs-bucket-name"
}

variable "public-s3-bucket-name-lb-prefix" {
  description = "bucket prefix for the logs from public external load balancer"
  type        = string
  default     = "internal-alb-access"
}
###### ----- Private Internal Load Balancer  ----- ########
variable "private-s3-bucket-name-lb" {
  description = "bucket name for the logs from private internal load balancer"
  type        = string
  default     = "your-alb-logs-bucket-name"
}

variable "private-s3-bucket-name-lb-prefix" {
  description = "bucket prefix for the logs from private internal load balancer"
  type        = string
  default     = "internal-alb-access"
}
################# ------------------ Baston Host  ------------------ #################
variable "bastion-host-ssh-cidr" {
  description = "cidr block to allows ssh to bastion host"
  type        = list(any)
}

variable "amis_bastion_host" {
  description = "bastion host machine amis"
  type        = string
}

variable "baston-host-keypair-name" {
  type = string
}

variable "baston-host-keypair-key" {
  type = string
}

variable "instance_type_bastion_host" {
  type = string
}






# variable "amis" {
#   type = string
# }

# variable "instance_type" {
#   type = string
# }
