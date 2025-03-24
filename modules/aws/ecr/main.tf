locals {
  service_files = fileset("${path.module}/repositories", "*.json")

  services = [for file in local.service_files : jsondecode(file("${path.module}/repositories/${file}"))]
}

resource "aws_ecr_repository" "ecr_repos" {

  for_each = { for service in local.services : service.repo_name => service }

  name                 = each.value.repo_name
  image_tag_mutability = each.value.image_tag_mutability



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
