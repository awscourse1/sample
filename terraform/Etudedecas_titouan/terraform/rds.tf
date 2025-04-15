resource "aws_db_instance" "postgres" {
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  name                 = "foodfastdb"
  username             = "admin"
  password             = "admin123"
  skip_final_snapshot  = true
}
