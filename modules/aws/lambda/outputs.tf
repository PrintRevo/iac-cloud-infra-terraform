output "lambda_arns" {
  value = { for k, v in aws_lambda_function.lambdas : k => v.arn }
}