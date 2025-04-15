# terraform/modules/ecr/main.tf
provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "main" {
  name                 = "${var.project}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Variables
variable "region" {
  description = "AWS Region"
  default     = "eu-west-3"
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
output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.main.name
}