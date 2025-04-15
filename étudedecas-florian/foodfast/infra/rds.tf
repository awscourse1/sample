resource "aws_db_subnet_group" "rds_subnet" {
  name       = "foodfast-rds-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "foodfast-db-subnet"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "foodfast-db"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  name              = "foodfastdb"
  username          = "admin"
  password          = "SuperSecret123"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  skip_final_snapshot = true

  tags = {
    Name = "foodfast-db"
  }
}
