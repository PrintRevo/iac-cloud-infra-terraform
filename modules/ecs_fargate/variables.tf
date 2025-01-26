variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "printrevo-ecs-cluster"
}

variable "environment" {
  description = "Environment name"
  type        = string

}

variable "jwt_secret" {
  default = ""
}

variable "jwt_expiry" {
  default = "E3ZsRlBWs6RkmZmjKhPQPPyy8xpxD9gF2qkRnMhVxxFJuYt"
}

variable "app_env" {
  default = "staging"
}

variable "aws_region" {
  default = ""
}

variable "aws_secret_access_key" {
  default = ""
}

variable "aws_access_key_id" {
  default = ""
}

variable "aws_bucket_name" {
  description = "App File Upload Bucket Name"
  default     = "printrevo-public-assets"
}

variable "aws_message_queue_url" {
  description = "Messaging SQS Queue URL"
  default     = "https://sqs.eu-central-1.amazonaws.com/565393058854/event-messages-queue"
}

variable "access_secret" {
  default = "6vg6RMHxauuIqRkoC2fFv5w4B4pxMVxJZVBdkMhkqGQ4"
}

variable "refresh_secret" {
  default = "E3ZsRlBWs6RkmZmjKhPQPPyy8xpxD9gF2qkRnMhVxxFJuYt"
}
