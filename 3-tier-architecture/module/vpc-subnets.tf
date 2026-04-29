resource "aws_vpc" "vpc_project" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_tags
  }
}

resource "aws_default_security_group" "default_sg_restrict" {
  vpc_id  = aws_vpc.vpc_project.id
  ingress = []
  egress  = []

  tags = {
    Name = "Default Security Group - Restricted"
  }
}


resource "aws_subnet" "public-subnet-bastion-host" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.public-subnet-bastion-host-cidr-block
  availability_zone       = var.availability-zone[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "Public Subnet - Bastion Host"
  }
}



resource "aws_subnet" "public-subnet-nat-gateway" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.public-subnet-nat-gateway-cidr-block
  availability_zone       = var.availability-zone[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "Public Subnet - Nat Gateways"
  }
}



resource "aws_subnet" "private-web-subnet" {
  count             = length(var.private-web-subnet-cidr_block)
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = element(var.private-web-subnet-cidr_block, count.index)
  availability_zone = element(var.availability-zone, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1} - web Tier"
  }
}


resource "aws_subnet" "private-app-subnet" {
  count             = length(var.private-app-subnet-cidr_block)
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = element(var.private-app-subnet-cidr_block, count.index)
  availability_zone = element(var.availability-zone, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1} - App Tier"
  }
}


resource "aws_subnet" "private-db-subnet" {
  count             = length(var.private-db-subnet-cidr_block)
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = element(var.private-db-subnet-cidr_block, count.index)
  availability_zone = element(var.availability-zone, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1} - Database Tier"
  }
}
