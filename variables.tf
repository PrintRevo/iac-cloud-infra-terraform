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

variable "organization" {
  description = "Organisation Name"
  type        = string
  default     = "PrintRevo"
}

variable "github_token" {
  description = "Github Token"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = "default"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}
variable "aws_access_secret_key" {
  description = "AWS Access Secret Key"
  type        = string
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

variable "rds_password" {
  description = "Password for RDS Postgres"
  type        = string
  sensitive   = true
}


variable "module_dir" {
  description = "Module Conf Files Directory"
  type        = string
}
