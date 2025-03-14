# resource "aws_s3_bucket" "core_bucket" {
#   bucket = "printrevo-${var.environment}-bucket"
 
#   lifecycle {
#     ignore_changes = [
#       bucket,
#       bucket_prefix
#     ]
#     prevent_destroy = false  # Set to true if you want to prevent bucket deletion
#   }

#    tags = {
#     Environment = var.environment
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
#   bucket = aws_s3_bucket.core_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # Block public access (recommended)
# resource "aws_s3_bucket_public_access_block" "public_access_block" {
#   bucket = aws_s3_bucket.core_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }