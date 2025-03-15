# S3 bucket for storing lambda scripts
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-code-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
}

# Block access to bucket
resource "aws_s3_bucket_public_access_block" "lambda_bucket_block" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
