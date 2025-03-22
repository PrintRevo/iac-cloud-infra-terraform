resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-cluster"
  tags = {
    Name        = "${var.environment}-cluster"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}