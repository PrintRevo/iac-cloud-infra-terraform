output "ecs_cluster_ids" {
  description = "ECS Cluster IDs"
  value       = { for cluster in aws_ecs_cluster.ecs_cluster : cluster.name => cluster.id }
}

output "ecs_services" {
  description = "ECS Services"
  value       = { for service in aws_ecs_service.ecs_service : service.name => service.id }
}