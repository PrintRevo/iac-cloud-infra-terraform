resource "aws_security_group" "redis" {
  name        = "${var.environment}-redis-sg"
  description = "Security group for Redis cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-redis-sg"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

# Create the Redis subnet group only if it does not exist
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name        = "${var.environment}-redis-subnet-group"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      tags.Name,
      description
    ]
    prevent_destroy = true
  }
}

resource "aws_elasticache_parameter_group" "redis" {
  family = "redis5.0"
  name   = "${var.environment}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  lifecycle {
    ignore_changes = [
      tags.Name,
      description
    ]
  }
}

# Elasticache Cluster for Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}-redis"
  engine              = "redis"
  node_type           = var.redis_node_type
  num_cache_nodes     = 1
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  port                = 6379
  engine_version      = "5.0.6"
  subnet_group_name   = aws_elasticache_subnet_group.redis.name
  security_group_ids  = [aws_security_group.redis.id]

  tags = {
    Name        = "${var.environment}-redis"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      engine_version,
      maintenance_window,
      snapshot_window,
      snapshot_retention_limit,
      tags.Name
    ]
    prevent_destroy = true
  }
}