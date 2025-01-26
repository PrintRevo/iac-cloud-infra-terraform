variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "printrevo-ecr-repo-${var.environment}"
}
