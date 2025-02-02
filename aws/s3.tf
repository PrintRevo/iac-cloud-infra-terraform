data "aws_s3_bucket" "existing_bucket" {
  count  = can(data.aws_s3_bucket.existing_bucket[0].id) ? 1 : 0
  bucket = "printrevo-${var.environment}-bucket"
}

resource "aws_s3_bucket" "bucket" {
  count  = length(data.aws_s3_bucket.existing_bucket) > 0 ? 0 : 1
  bucket = "printrevo-${var.environment}-bucket"
  tags = {
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [bucket]
  }
}