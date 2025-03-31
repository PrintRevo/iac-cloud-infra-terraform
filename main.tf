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
    bucket = "printrevo-terraform-state"
    key    = "iac-terraform-repos.tfstate"
    region = "eu-central-1"
  }
}

module "main_vpc" {
  source      = "./modules/aws/vpc"
  environment = var.environment
  aws_region  = var.aws_region
}

module "ecr_repositories" {
  source      = "./modules/aws/ecr"
  environment = var.environment
}

module "ecs_cluster_and_services" {
  source      = "./modules/aws/ecs"
  environment = var.environment

  depends_on = [module.main_vpc, module.ecr_repositories]
  vpc_id     = module.main_vpc.vpc_id
  subnet_ids = [
    module.main_vpc.public_subnet_a_id,
    module.main_vpc.public_subnet_b_id
  ]

  ecr_repositories = module.ecr_repositories.ecr_repositories

}

module "storage_services" {
  source     = "./modules/aws/storages"
  depends_on = [module.main_vpc]
  subnet_ids = [
    module.main_vpc.public_subnet_a_id,
    module.main_vpc.public_subnet_b_id
  ]
  environment                         = var.environment
  aws_profile                         = var.aws_profile
  rds_password                        = var.rds_password
  aws_security_group_public_access_id = module.main_vpc.aws_security_group_public_access_id
  redis_node_type                     = var.redis_node_type
  rds_instance_class                  = var.rds_instance_class
  aws_region                          = var.aws_region
}


module "eks_cluster" {
  source       = "./modules/aws/eks"
  depends_on   = [module.main_vpc, module.ecr_repositories]
  subnet_ids   = [module.main_vpc.public_subnet_a_id, module.main_vpc.public_subnet_b_id]
  vpc_id       = module.main_vpc.vpc_id
  environment  = var.environment
  aws_region   = var.aws_region
  cluster_name = "printrevo-${var.environment}-eks"
}

module "lambda_functions" {
  source       = "./modules/aws/lambda"
  environment  = var.environment
  aws_region   = var.aws_region
  depends_on   = [module.eks_cluster]
  instance_ids = module.eks_cluster.eks_node_instance_ids
}

module "github_repositories" {
  source = "./modules/github"

  organization     = "PrintRevo"

  aws_profile           = var.aws_profile
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_access_secret_key
  auto_init             = true
}
