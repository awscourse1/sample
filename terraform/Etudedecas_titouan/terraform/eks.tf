module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "foodfast-cluster"
  subnets      = module.vpc.public_subnets
  vpc_id       = module.vpc.vpc_id
}
