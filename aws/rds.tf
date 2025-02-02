# Check if the DB subnet group already exists
data "aws_db_subnet_group" "existing_postgres" {
  name = "printrevo_core_${var.environment}-svc-subnet-group"
}

# Create the DB subnet group only if it does not exist
resource "aws_db_subnet_group" "postgres" {
  count = try(data.aws_db_subnet_group.existing_postgres.id, null) != null ? 0 : 1

  name       = "printrevo_core_${var.environment}-svc-subnet-group"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  lifecycle {
    prevent_destroy = true
  }
}

# Declare list of database stacks for each microservice
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

  # Use existing or newly created DB subnet group
  db_subnet_group_name = coalesce(
    try(aws_db_subnet_group.postgres[0].name, ""),
    data.aws_db_subnet_group.existing_postgres.name
  )

  tags = {
    Name        = "${var.environment}-ecs-task-execution-role"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}
