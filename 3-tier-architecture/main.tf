module "three-tier" {
  source = "./module"

  aws_region = "ca-central1"
  ###### ----- VPC ----- ########
  vpc_cidr = "10.0.0.0/16"
  vpc_tags = "vpc-project"

  ###### ----- SUBNETS ----- ########
  availability-zone = ["ca-central-1a", "ca-central-1b"]

  private-web-subnet-cidr_block = ["10.0.3.0/24", "10.0.4.0/24"]
  private-app-subnet-cidr_block = ["10.0.5.0/24", "10.0.6.0/24"]
  private-db-subnet-cidr_block  = ["10.0.7.0/24", "10.0.8.0/24"]

  public-subnet-nat-gateway-cidr-block  = "10.0.2.0/24"
  public-subnet-bastion-host-cidr-block = "10.0.1.0/24"


  ###### ----- WEB TIER ----- ########
  web_tier_amis            = "ami-0f39ffd6e446bf727"
  web_instance_type        = "t2.micro"
  web_tier_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

  ###### ----- APP TIER ----- ########
  app_tier_amis     = "ami-0f39ffd6e446bf727"
  app_instance_type = "t2.micro"

  ###### ----- Database  ----- ########
  db_password       = "db_password"
  db_username       = "dbadmin"
  db_name           = "myappdb"
  db_instance_class = "db.t3.micro"

  ###### ----- Baston Host  ----- ########
  instance_type_bastion_host = "t2.micro"
  baston-host-keypair-key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
  baston-host-keypair-name   = "deployer-key"
  amis_bastion_host          = "ami-0f39ffd6e446bf727"
  bastion-host-ssh-cidr      = ["78.67.5.54/32"]

  ###### ----- Private Internal Load Balancer  ----- ########
  private-s3-bucket-name-lb        = "your-alb-logs-bucket-name"
  private-s3-bucket-name-lb-prefix = "internal-alb-access"

  ###### ----- Public External Load Balancer  ----- ########
  public-load-balancer-http-allow-cidr = ["28.8.7.6/32"]
  public-s3-bucket-name-lb             = "your-alb-logs-bucket-name"
  public-s3-bucket-name-lb-prefix      = "internal-alb-access"


}