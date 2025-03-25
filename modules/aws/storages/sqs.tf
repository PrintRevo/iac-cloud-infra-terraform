resource "aws_sqs_queue" "sqs_queus" {
  name = "printrevo-event-messages-queue"

  tags = {
    Environment = var.environment
  }
}
