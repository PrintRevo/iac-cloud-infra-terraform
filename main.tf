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


module "aws_resources" {
  source       = "./aws"
  rds_password = var.rds_password
}

# module "digitalocean_resources" {
#   source = "./digitalocean"
# }
