variable "environment" {
  default     = "dev"
  type        = string
  description = "Environment"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-s3-bucket"
}


variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}

variable "redis_node_type" {
  description = "Node type for ElastiCache Redis"
  type        = string
  default     = "cache.t2.micro"
}

variable "rds_instance_class" {
  description = "Instance class for RDS Postgres"
  type        = string
  default     = "db.t2.micro"
}

variable "rds_username" {
  description = "Username for RDS Postgres"
  type        = string
  default     = "admin"
}

variable "rds_password" {
  description = "Password for RDS Postgres"
  type        = string
  sensitive   = true
}
