locals {
  service_files = fileset("${path.module}/services", "*.json")

  services = [for file in local.service_files : jsondecode(file("${path.module}/services/${file}"))]
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "printrevo-pod-cluster"
  tags = {
    Name        = "${var.environment}-cluster"
    Environment = var.environment
  }
  for_each = { for service in local.services : service.cluster_name => service }


  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  for_each = { for service in local.services : service.service_name => service }

  name = "${each.value.service_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  for_each = aws_iam_role.ecs_task_execution_role

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_task" {
  for_each = { for service in local.services : service.service_name => service }

  family                   = each.value.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = [each.value.launch_type]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[each.value.service_name].arn

  container_definitions = jsonencode([
    {
      name      = each.value.service_name
      image     = "${var.ecr_repositories[each.value.service_name]}:latest"
      cpu       = each.value.cpu
      memory    = each.value.memory
      essential = true
      portMappings = [{
        containerPort = each.value.container_port
        hostPort      = each.value.container_port
      }]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  for_each = { for service in local.services : service.service_name => service }

  name            = each.value.service_name
  cluster         = aws_ecs_cluster.ecs_cluster[each.value.cluster_name].id
  task_definition = aws_ecs_task_definition.ecs_task[each.value.service_name].arn
  desired_count   = each.value.desired_count
  launch_type     = each.value.launch_type

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
