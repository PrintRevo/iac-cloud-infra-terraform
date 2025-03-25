variable "aws_region" {
  description = "The AWS region to create for the Lambda function"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "instance_ids" {
  description = "The IDs of the EKS node instances"
  type        = list(string)
}
