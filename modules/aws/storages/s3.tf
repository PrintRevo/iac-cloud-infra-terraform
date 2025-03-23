resource "aws_s3_bucket" "printrevo_bucket" {
  bucket = "printrevo-bucket-${var.environment}"

  lifecycle {
    ignore_changes = [
      bucket,
      bucket_prefix
    ]
    prevent_destroy = false 
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.printrevo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access (recommended)
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.printrevo_bucket.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}