resource "aws_sqs_queue" "main" {
  name = "printrevo-event-messages-queue"

  tags = {
    Environment = var.environment
  }
}
