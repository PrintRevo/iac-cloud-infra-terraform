resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
  tags = {
    Name        = "${var.environment}-ecs-task-execution-role"
    Environment = var.environment
  }
}
# End of IAM Role for ECS Task Execution

# Create an ECS Task Definitions
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.environment}-printrevo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MiB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name        = "${var.environment}-printrevo-container"
      image       = "${length(data.aws_ecr_repository.existing_repo.id) > 0 ? data.aws_ecr_repository.existing_repo.repository_url : aws_ecr_repository.private_repo[0].repository_url}:latest"
      cpu         = 256
      memory      = 512
      environment = [
        {
          name  = "APP_SECRETS",
          value = "{\"DB_HOST\":\"${aws_db_instance.postgresql.address}\",\"DB_NAME\":\"${aws_db_instance.postgresql.db_name}\",\"DB_USER\":\"${aws_db_instance.postgresql.username}\",\"DB_PASS\":\"${aws_db_instance.postgresql.password}\",\"REDIS_HOST\":\"${aws_elasticache_cluster.redis_cluster.cache_nodes[0].address}\",\"REDIS_PORT\":\"${aws_elasticache_cluster.redis_cluster.port}\",PORT\":\"80\",DB_PORT\":\"5432\",AWS_ACCESS_KEY_ID\":\"${var.aws_access_key_id}\",AWS_SECRET_ACCESS_KEY\":\"${var.aws_secret_access_key}\",AWS_REGION\":\"${var.aws_region}\",AWS_S3_MEDIA_UPLOAD\":\"${var.aws_bucket_name}\",AWS_MESSAGES_QUEUE_URL\":\"${var.aws_message_queue_url}\",ACCESS_SECRET\":\"${var.access_secret}\",REFRESH_SECRET\":\"${var.refresh_secret}\",SSL_MODE\":\"disable\",APP_ENV\":\"${var.app_env}\"}"
        },
        {
          name  = "GOOSE_MIGRATION_DIR"
          value = "./internal/db/migrations"
        },
      ]
      healthcheck = {
        command      = ["CMD-SHELL", "curl -f http://localhost:80/ || exit 1"]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 60
      }
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
  tags = {
    Name        = "${var.environment}-printrevo-task"
    Environment = var.environment
  }
}
# End of ECS Task Definitions

# Create an ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "printrevo-core-svc" # Your service name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.public_subnet[*].id
    security_groups = [aws_security_group.ecs_sg.id]
  }
  tags = {
    Name        = "${var.environment}-printrevo-core-svc"
    Environment = var.environment
  }
}
# End of ECS Service