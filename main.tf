# variable "environment" {
#   default     = "development"
#   type        = string
#   description = "Environment"
# }

# variable "aws_region" {
#   description = "AWS region"
#   type        = string
#   default     = "eu-central-1"
# }

# variable "aws_profile" {
#   description = "AWS Profile"
#   type        = string
# }

# variable "rds_password" {
#   type        = string
#   description = "RDS Password"
# }


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    # digitalocean = {
    #   source  = "digitalocean/digitalocean"
    #   version = "~> 2.0"
    # }
  }
  backend "s3" {
    bucket         = "printrevo-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "printrevo-terraform-lock-table"
  }
}

module "main_vpc" {
  source = "./aws/vpc"
}

module "ecr_repositories" {
  source = "./aws/ecr"
}

module "ecs_cluster_and_services" {
  source = "./aws/ecs"
}

module "iam_role_and_permission" {
  source = "./aws/iam"
}

module "storage_services" {
  source       = "./aws/storages"
  rds_password = var.rds_password
}


# module "aws_resources" {
#   source       = "./aws"
#   rds_password = var.rds_password
# }

# module "digitalocean_resources" {
#   source = "./digitalocean"
# }
