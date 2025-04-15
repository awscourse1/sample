# terraform/modules/rds/main.tf
provider "aws" {
  region = var.region
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg-${var.environment}"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-rds-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project}-db-subnet-group-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project}-db-${var.environment}"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  allocated_storage      = var.allocated_storage
  storage_type           = "gp2"
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  multi_az               = var.environment == "prod" ? true : false
  
  backup_retention_period = var.environment == "prod" ? 7 : 1
  deletion_protection    = var.environment == "prod" ? true : false
  storage_encrypted      = true

  tags = {
    Name        = "${var.project}-db-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

# Variables
variable "region" {
  description = "AWS Region"
  default     = "eu-west-3"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID for EKS"
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  default     = "14.6"
}

variable "instance_class" {
  description = "DB instance class"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  default     = "foodfast"
}

variable "username" {
  description = "Database username"
}

variable "password" {
  description = "Database password"
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  default     = 20
}

variable "environment" {
  description = "Environment tag"
  default     = "dev"
}

variable "project" {
  description = "Project name"
  default     = "foodfast"
}

# Outputs
output "db_instance_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.main.id
}