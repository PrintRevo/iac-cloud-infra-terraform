locals {
  service_files = fileset("${path.module}/../../services", "*.json")

  services = [for file in local.service_files : jsondecode(file("${path.module}/../../services/${file}"))]
}

resource "aws_ecr_repository" "ecr_repos" {

  for_each = { for service in local.services : service.ecr_repository => service }

  name                 = each.value.ecr_repository
  image_tag_mutability = "MUTABLE"

  lifecycle {
    prevent_destroy = false
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
  }
}