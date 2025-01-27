data "aws_ecr_repository" "existing_repo" {
  name = "printrevo-${var.environment}-repo"
}

resource "aws_ecr_repository" "private_repo" {
  count = length(data.aws_ecr_repository.existing_repo.id) > 0 ? 0 : 1

  name = "printrevo-${var.environment}-repo"
  # allows deletion of the repository even if it contains images
  force_delete = false

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
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
