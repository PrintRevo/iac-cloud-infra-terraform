resource "aws_ecs_cluster" "cluster" {
  name = "printrevo-${var.environment}-cluster"
  tags = {
    Name        = "printrevo-${var.environment}-cluster"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}


resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.environment}-printrevo-coresvc-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  depends_on               = [aws_elasticache_cluster.redis]
  execution_role_arn       = data.aws_iam_role.existing_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "${var.environment}-coresvc-container"
      image     = "${aws_ecr_repository.private_repo[0].repository_url}:latest"
      essential = true
      # environment = [
      #   {
      #     name  = "APP_SECRETS",
      #     value = "{\"DB_HOST\":\"${aws_db_instance.postgres.address}\",\"DB_NAME\":\"${aws_db_instance.postgres.db_name}\",\"DB_USER\":\"${aws_db_instance.postgres.username}\",\"DB_PASS\":\"${aws_db_instance.postgres.password}\",\"REDIS_HOST\":\"${aws_elasticache_cluster.redis.cache_nodes[0].address}\",\"REDIS_PORT\":\"${aws_elasticache_cluster.redis.port}\",PORT\":\"80\",DB_PORT\":\"5432\",AWS_ACCESS_KEY_ID\":\"not-ideal\",AWS_SECRET_ACCESS_KEY\":\"not-ideal\",AWS_REGION\":\"${var.aws_region}\",AWS_S3_MEDIA_UPLOAD\":\"${aws_s3_bucket.bucket.bucket}\",AWS_MESSAGES_QUEUE_URL\":\"${aws_sqs_queue.main.url}\",ACCESS_SECRET\":\"6vg6RMHxauuIqRkoC2fFv5w4B4pxMVxJZVBdkMhkqGQ4\",REFRESH_SECRET\":\"E3ZsRlBWs6RkmZmjKhPQPPyy8xpxD9gF2qkRnMhVxxFJuYt\",SSL_MODE\":\"disable\",APP_ENV\":\"${var.environment}\"}"
      #   },
      #   {
      #     name  = "GOOSE_MIGRATION_DIR"
      #     value = "./internal/db/migrations"
      #   },
      # ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        },
        {
          containerPort = 443
          hostPort      = 443
        }
      ],
      healthcheck = {
        command      = ["CMD-SHELL", "curl -f http://localhost:80/ || exit 1"]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 60
      },
      tags = {
        Name        = "${var.environment}-printrevo-task"
        Environment = var.environment
      }
    }
  ])

  lifecycle {
    ignore_changes = [family]
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "printrevo-${var.environment}-core-backend-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  tags = {
    Name        = "${var.environment}-printrevo-core-svc"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}
