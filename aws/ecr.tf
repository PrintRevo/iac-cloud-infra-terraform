data "aws_ecr_repository" "existing_private" {
  name  = "printrevo-${var.environment}-repo"
  count = can(data.aws_ecr_repository.existing_private[0].id) ? 1 : 0
}

resource "aws_ecr_repository" "private_repo" {
  count = length(data.aws_ecr_repository.existing_private) > 0 ? 0 : 1

  name         = "printrevo-${var.environment}-repo"
  force_delete = true # Optional: allows deletion of the repository even if it contains images

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.environment}-printrevo-core-svc-repo"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name]
  }
}
