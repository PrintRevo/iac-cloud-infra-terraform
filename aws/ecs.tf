resource "aws_ecs_cluster" "cluster" {
  name = "printrevo-${var.environment}-cluster"
  tags = {
    Name        = "printrevo-${var.environment}-cluster"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}