resource "aws_ecr_repository" "gobackend_api_svc" {
  name         = "printrevo-${var.environment}-repo"
  force_delete = false

  lifecycle {
    ignore_changes = [
      name,
      image_tag_mutability,
      image_scanning_configuration
    ]
    prevent_destroy = true
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE" 

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.environment}-printrevo-core-svc-repo"
    Environment = var.environment
  }
}

resource "aws_ecr_repository_policy" "ecr-repo-policy" {
  repository = aws_ecr_repository.gobackend_api_svc.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"  # Replace with specific ARNs for production use
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "repo-lifecycle" {
  repository = aws_ecr_repository.gobackend_api_svc.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}