# variable "do_token" {
#   description = "DigitalOcean API token"
#   type        = string
# }

variable "environment" {
  default     = "development"
  type        = string
  description = "Environment"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "rds_password" {
  type        = string
  description = "RDS Password"
}
