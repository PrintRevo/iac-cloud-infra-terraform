variable "project_name" {
  description = "Project name"
  type        = string
  default     = "printrevo App IaC"
}
variable "environment" {
  description = "Environment name"
  type        = string
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
