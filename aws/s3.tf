resource "aws_s3_bucket" "bucket" {
  bucket = "printrevo-${var.environment}-bucket"
  tags = {
    Environment = var.environment
  }
}
