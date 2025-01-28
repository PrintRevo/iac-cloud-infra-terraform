resource "aws_db_subnet_group" "postgres" {
  name       = "printrevo_core_${var.environment}-svc-subnet-group"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# Declare list of database stacks for each mircoservices
resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  identifier_prefix      = var.environment
  engine                 = "postgres"
  engine_version         = "15.7"
  instance_class         = "db.t3.micro"
  db_name                = "printrevo-core-${var.environment}-svc"
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.postgres15"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.ecs.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name

  tags = {
    Name        = "${var.environment}-ecs-task-execution-role"
    Environment = var.environment
  }
}
