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
