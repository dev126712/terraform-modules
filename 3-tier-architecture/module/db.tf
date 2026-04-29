# 1. Database Security Group
# Only allows traffic from the Application Tier on port 5432
resource "aws_security_group" "db_sg" {
  name        = "Database-SG"
  description = "Allow inbound traffic from App Tier"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    description     = "PostgreSQL from App Tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.apptier-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Database-SG" }
}

# 2. RDS Subnet Group
# This tells AWS which private subnets the database can live in
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.private-db-subnet[*].id

  tags = { Name = "Main DB Subnet Group" }
}

# 3. RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres15"
  
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  # High Availability: Creates a standby in a different AZ
  multi_az               = true
  
  # Security: Encrypt the storage and disable public access
  storage_encrypted      = true
  publicly_accessible    = false
  skip_final_snapshot    = true # Set to false for real production!

  tags = { Name = "Main-PostgreSQL-Instance" }
}
