resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [var.subnet_ids[0], var.subnet_ids[1]]

  tags = {
    Name        = "printrevo-${var.environment}-db"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "postgres" {
  identifier = "printrevo-${var.environment}-db"

  # Engine configuration
  engine         = "postgres"
  engine_version = "15.7"
  instance_class = "db.t3.micro"

  # Storage configuration
  allocated_storage   = 20
  storage_type        = "gp2"
  storage_encrypted   = true
  skip_final_snapshot = true

  # Database configuration
  username = var.rds_username
  password = var.rds_password

  # Network configuration
  vpc_security_group_ids = [var.aws_security_group_public_access_id]
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name

  publicly_accessible = true

  # Maintenance configuration
  auto_minor_version_upgrade = true
  maintenance_window         = "Mon:03:00-Mon:04:00"
  backup_window              = "02:00-03:00"
  backup_retention_period    = 7

  # Parameter group
  parameter_group_name = "default.postgres15"


  tags = {
    Name        = "printrevo-${var.environment}-db"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password,
      tags.Name,
      maintenance_window,
      backup_window
    ]
  }
}


# Security Group for RDS
# resource "aws_security_group" "rds" {
#   name        = "printrevo-${var.environment}-rds-sg"
#   description = "Security group for RDS instance"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "printrevo-${var.environment}-rds-sg"
#     Environment = var.environment
#   }

#   lifecycle {
#     ignore_changes = [tags.Name]
#   }
# }

# # DB Subnet Group with better error handling
# resource "aws_db_subnet_group" "postgres" {
#   name_prefix = "printrevo-${var.environment}-"
#   subnet_ids  = [aws_subnet.public_1.id, aws_subnet.public_2.id]

#   tags = {
#     Name        = "printrevo-${var.environment}-db-subnet-group"
#     Environment = var.environment
#   }

#   lifecycle {
#     create_before_destroy = true
#     ignore_changes       = [tags.Name]
#   }
# }
