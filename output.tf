# output "ecr_repository_url" {
#   depends_on = [module.aws_resources]
#   value      = data.aws_ecr_repository.existing_repo.repository_url
# }

# output "s3_bucket_name" {
#   depends_on = [module.aws_resources]
#   value      = aws_s3_bucket.bucket.bucket
# }

# output "redis_endpoint" {
#   depends_on = [module.aws_resources]
#   value      = aws_elasticache_cluster.redis.cache_nodes[0].address
# }

# output "rds_endpoint" {
#   depends_on = [module.aws_resources]
#   value      = aws_db_instance.postgres.endpoint
# }

# output "ecs_service_url" {
#   depends_on = [module.aws_resources]
#   value      = "http://${aws_ecs_service.service.name}.${aws_ecs_cluster.cluster.name}.ecs.amazonaws.com"
# }

# output "sqs_queue_url" {
#   depends_on = [module.aws_resources]
#   value      = aws_sqs_queue.event_queue.id != "" ? aws_sqs_queue.event_queue.id : data.aws_sqs_queue.existing_queue.id
# }
