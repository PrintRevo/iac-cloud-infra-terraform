# Check if the Redis subnet group already exists
data "aws_elasticache_subnet_group" "existing_redis" {
  name = "${var.environment}-redis-subnet-group"
}

# Create the Redis subnet group only if it does not exist
resource "aws_elasticache_subnet_group" "redis" {
  count = try(data.aws_elasticache_subnet_group.existing_redis.id, null) != null ? 0 : 1

  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  lifecycle {
    prevent_destroy = true
  }
}

# Elasticache Cluster for Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}-redis-cluster"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379

  # Use the existing or newly created Redis subnet group
  subnet_group_name = coalesce(
    try(aws_elasticache_subnet_group.redis[0].name, ""),
    data.aws_elasticache_subnet_group.existing_redis.name
  )

  security_group_ids = [aws_security_group.ecs.id]

  lifecycle {
    prevent_destroy = true
  }
}
