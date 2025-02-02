# Check if the IAM role already exists
data "aws_iam_role" "existing_execution_role" {
  name = "${var.environment}-ecs-task-execution-role"
}

# Create the IAM role only if it does not exist
resource "aws_iam_role" "ecs_task_execution_role" {
  count = try(data.aws_iam_role.existing_execution_role.id, null) != null ? 0 : 1

  name = "${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-ecs-task-execution-role"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}

# Attach required policies to the role (reference the correct role name)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = coalesce(try(aws_iam_role.ecs_task_execution_role[0].name, ""), data.aws_iam_role.existing_execution_role.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy" {
  role       = coalesce(try(aws_iam_role.ecs_task_execution_role[0].name, ""), data.aws_iam_role.existing_execution_role.name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
