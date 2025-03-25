locals {
  lambda_configs = fileset("${path.module}/lambdas", "*.json")
  lambdas        = { for file in local.lambda_configs : trimsuffix(file, ".json") => jsondecode(file("${path.module}/lambdas/${file}")) }
}

resource "aws_iam_role" "lambda_role" {
  name = "ec2_scheduler_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ec2_control" {
  name        = "ec2_control_policy"
  description = "Policy for Lambda to control EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  policy_arn = aws_iam_policy.ec2_control.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "lambdas" {
  for_each = local.lambdas

  filename         = "${path.module}/lambda_functions/${each.key}.zip"
  function_name    = each.value.name
  role             = aws_iam_role.lambda_role.arn
  handler          = each.value.handler
  runtime          = each.value.runtime
  source_code_hash = filebase64sha256("${path.module}/lambda_functions/${each.key}.zip")

  environment {
    variables = {
      INSTANCE_IDS = join(",", var.instance_ids)
    }
  }
}

# Create Multiple EventBridge Rules for Each Schedule
resource "aws_cloudwatch_event_rule" "schedule" {
  for_each = { for k, v in local.lambdas : k => v if lookup(v, "schedule_expressions", null) != null }

  name                = "${each.value.name}-schedule"
  description         = "Trigger ${each.value.name} on schedule"
  schedule_expression = each.value.schedule_expressions[0]  # Assuming the first element for simplicity
}

# Grant EventBridge Permission to Invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = aws_cloudwatch_event_rule.schedule

  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdas[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}

# Attach EventBridge Rules to Lambda Targets
resource "aws_cloudwatch_event_target" "lambda_target" {
  for_each = aws_cloudwatch_event_rule.schedule

  rule      = each.value.name
  target_id = "InvokeLambdaFunction"
  arn       = aws_lambda_function.lambdas[each.key].arn
}
