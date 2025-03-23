variable "environment" {
  type        = string
  description = "Environment"
}
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "redis_node_type" {
  description = "Node type for ElastiCache Redis"
  type        = string
}

variable "rds_instance_class" {
  description = "Instance class for RDS Postgres"
  type        = string
}

variable "rds_password" {
  description = "Password for RDS Postgres"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "aws_security_group_public_access_id" {
  description = "AWS Group Public IP"
  type        = string
}