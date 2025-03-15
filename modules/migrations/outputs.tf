output "migrations_bucket_name" {
  description = "Name of the S3 bucket for migration scripts"
  value       = aws_s3_bucket.migrations.bucket
}

output "migrations_bucket_arn" {
  description = "ARN of the S3 bucket for migration scripts"
  value       = aws_s3_bucket.migrations.arn
}

output "lambda_function_name" {
  description = "Name of the DB migration Lambda function"
  value       = aws_lambda_function.db_migration.function_name
}

output "lambda_function_arn" {
  description = "ARN of the DB migration Lambda function"
  value       = aws_lambda_function.db_migration.arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for the DB migration Lambda function"
  value       = aws_iam_role.migrations_lambda_role.arn
}

output "lambda_invoke_command" {
  description = "AWS CLI command to invoke the migration Lambda manually"
  value       = "aws lambda invoke --function-name ${aws_lambda_function.db_migration.function_name} --payload '{\"action\": \"migrate\"}' response.json"
}
