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
}

module "aws_resources" {
  source       = "./aws"
  rds_password = var.rds_password
}

# module "digitalocean_resources" {
#   source = "./digitalocean"
# }
