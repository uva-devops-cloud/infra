# ------------------------------------------------------------------------------
# S3 Bucket for Migration Scripts
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "migrations" {
  bucket = "${var.prefix}-${var.environment}-db-migrations"

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "migrations" {
  bucket = aws_s3_bucket.migrations.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "migrations" {
  bucket = aws_s3_bucket.migrations.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "migrations" {
  bucket = aws_s3_bucket.migrations.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Folder structure for migration scripts
resource "aws_s3_object" "migrations_folder" {
  bucket       = aws_s3_bucket.migrations.id
  key          = "scripts/"
  content_type = "application/x-directory"

  # Empty content for folder object
  content = ""
}

# ------------------------------------------------------------------------------
# IAM Role for Migration Lambda
# ------------------------------------------------------------------------------

resource "aws_iam_role" "migrations_lambda_role" {
  name = "${var.prefix}-${var.environment}-migrations-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.migrations_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy (if Lambda needs VPC access)
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.migrations_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Policy for S3 access
resource "aws_iam_policy" "migrations_s3_access" {
  name        = "${var.prefix}-${var.environment}-migrations-s3-policy"
  description = "Allow Lambda to access migration scripts in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.migrations.arn,
          "${aws_s3_bucket.migrations.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "migrations_s3_access" {
  role       = aws_iam_role.migrations_lambda_role.name
  policy_arn = aws_iam_policy.migrations_s3_access.arn
}

# Policy for Secrets Manager access (to get DB credentials)
resource "aws_iam_policy" "migrations_secrets_access" {
  name        = "${var.prefix}-${var.environment}-migrations-secrets-policy"
  description = "Allow Lambda to access DB secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arn != null ? [var.db_secret_arn] : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "migrations_secrets_access" {
  role       = aws_iam_role.migrations_lambda_role.name
  policy_arn = aws_iam_policy.migrations_secrets_access.arn
}

# ------------------------------------------------------------------------------
# Lambda Function for DB Migrations
# ------------------------------------------------------------------------------

resource "aws_lambda_function" "db_migration" {
  function_name = "${var.prefix}-${var.environment}-db-migration"
  description   = "Executes database migration scripts"

  # Code package
  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/db-migration.zip"

  # Runtime configuration
  handler     = "index.handler"
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  # IAM role
  role = aws_iam_role.migrations_lambda_role.arn

  # Environment variables
  environment {
    variables = {
      DB_SECRET_ARN     = var.db_secret_arn != null ? var.db_secret_arn : ""
      MIGRATIONS_BUCKET = aws_s3_bucket.migrations.id
      DB_NAME           = var.db_name
    }
  }

  # VPC configuration (if required)
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "db_migration" {
  name              = "/aws/lambda/${aws_lambda_function.db_migration.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# ------------------------------------------------------------------------------
# S3 Bucket Notification to Trigger Lambda (Optional)
# ------------------------------------------------------------------------------

resource "aws_lambda_permission" "allow_bucket" {
  count         = var.enable_s3_trigger ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_migration.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.migrations.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.enable_s3_trigger ? 1 : 0
  bucket = aws_s3_bucket.migrations.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.db_migration.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "scripts/"
    filter_suffix       = ".sql"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# ------------------------------------------------------------------------------
# Lambda Permission for API Gateway
# ------------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway_invoke_migration" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_migration.function_name
  principal     = "apigateway.amazonaws.com"

  # API Gateway can invoke the function
  source_arn = "${var.api_execution_arn}/*/POST/migrations"
}
