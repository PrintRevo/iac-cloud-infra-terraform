variable "environment" {
  type        = string
  description = "Environment"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the RDS subnet group"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}