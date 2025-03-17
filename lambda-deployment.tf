# S3 bucket for Lambda function deployments
resource "aws_s3_bucket" "lambda_deployments" {
  bucket = "lambda-deployments-${data.aws_caller_identity.current.account_id}"

  tags = local.common_tags
}

# Enable versioning for Lambda deployment bucket
resource "aws_s3_bucket_versioning" "lambda_deployments_versioning" {
  bucket = aws_s3_bucket.lambda_deployments.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Secure the Lambda deployment bucket
resource "aws_s3_bucket_public_access_block" "lambda_deployments_public_access" {
  bucket = aws_s3_bucket.lambda_deployments.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
