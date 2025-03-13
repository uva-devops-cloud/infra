# S3 bucket for storing migration scripts
resource "aws_s3_bucket" "migrations_bucket" {
  bucket = "db-migrations-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
}

# Block public access to migration scripts
resource "aws_s3_bucket_public_access_block" "migrations_bucket_block" {
  bucket = aws_s3_bucket.migrations_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lambda function to run migrations
resource "aws_lambda_function" "db_migration" {
  function_name = "db-migration-runner"
  role          = aws_iam_role.worker_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 300 # Increased from 60 to 300 seconds (5 minutes)
  memory_size   = 256 # Also increase memory for better performance


  filename = "${path.module}/dummy_lambda.zip" # Placeholder

  environment {
    variables = {
      DB_SECRET_ARN     = aws_secretsmanager_secret.db_secret.arn
      DB_HOST           = module.rds.db_instance_address
      DB_NAME           = "studentportal"
      MIGRATIONS_BUCKET = aws_s3_bucket.migrations_bucket.bucket
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg,
    module.rds
  ]
}

# Simple API endpoint to trigger migrations manually
resource "aws_api_gateway_resource" "db_migrate" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "db-migrate"
}

resource "aws_api_gateway_method" "db_migrate_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.db_migrate.id
  http_method   = "POST"
  authorization = "NONE" # No auth for simplicity in this temporary project
}

resource "aws_api_gateway_integration" "db_migrate_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.db_migrate.id
  http_method             = aws_api_gateway_method.db_migrate_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.db_migration.invoke_arn
}

# Lambda permission
resource "aws_lambda_permission" "api_gateway_db_migrate" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_migration.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.db_migrate_post.http_method}${aws_api_gateway_resource.db_migrate.path}"
}

# Modify the DB migration Lambda IAM policy to access S3
resource "aws_iam_role_policy_attachment" "s3_policy_for_migration" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
