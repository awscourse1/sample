provider "aws" {
  region = "eu-west-3"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "foodfast-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["eu-west-3a", "eu-west-3b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  tags = {
    Name = "foodfast-vpc"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "foodfast-eks"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Name = "foodfast-eks"
  }
}

resource "aws_ecr_repository" "foodfast" {
  name = "foodfast-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "foodfast-ecr"
  }
}
