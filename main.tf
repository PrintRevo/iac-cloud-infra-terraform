terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
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
  source      = "./modules/aws/vpc"
  environment = var.environment
  aws_region  = var.aws_profile
}

# module "ecr_repositories" {
#   source      = "./modules/aws/ecr"
#   environment = var.environment
# }

# module "ecs_cluster_and_services" {
#   source      = "./modules/aws/ecs"
#   environment = var.environment
# }

# module "iam_role_and_permission" {
#   source      = "./modules/aws/iam"
#   environment = var.environment
# }

# module "storage_services" {
#   source     = "./modules/aws/storages"
#   depends_on = [module.main_vpc]
#   subnet_ids = [
#     module.main_vpc.public_subnet_a_id,
#     module.main_vpc.public_subnet_b_id
#   ]
#   environment                         = var.environment
#   aws_profile                         = var.aws_profile
#   rds_username                        = var.rds_username
#   rds_password                        = var.rds_password
#   aws_security_group_public_access_id = module.main_vpc.aws_security_group_public_access_id
#   redis_node_type                     = var.redis_node_type
#   rds_instance_class                  = var.rds_instance_class
#   aws_region                          = var.aws_region
# }

module "github_repositories" {
  source = "./modules/github"

  organization     = "printrevo"
  repositories_dir = "${path.module}/repository-definitions"

  aws_profile = var.aws_profile
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_access_secret_key
  auto_init      = true
}
