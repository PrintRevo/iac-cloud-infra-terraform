data "aws_ecr_repository" "existing_repo" {
  name = var.repository_name
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_ecr_repository" "private_repo" {
  count = length(data.aws_ecr_repository.existing_repo.id) > 0 ? 0 : 1

  name = "printrevo-ecr-repo-${var.environment}"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256" # Default encryption
  }

  tags = {
    Name = "${var.environment}-printrevo-core-svc-repo"
    Environment = var.environment
  }
}
