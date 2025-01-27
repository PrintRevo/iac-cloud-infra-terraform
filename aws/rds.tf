resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.5"
  instance_class       = var.rds_instance_class
  username             = var.rds_username
  password             = var.rds_password
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
  publicly_accessible  = true

}

resource "aws_db_subnet_group" "postgres" {
  name       = "my-postgres-subnet-group"
  subnet_ids = [aws_subnet.public.id]
}

resource "aws_db_instance" "postgresql" {
  allocated_storage = 20
  #  identifier             = "ellobae-core"
  identifier_prefix      = var.environment
  engine                 = "postgres"
  engine_version         = "15.7"
  instance_class         = "db.t3.micro"
  db_name                = "ellobae_scv"
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.postgres15"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.ecs.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
}
