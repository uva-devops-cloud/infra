output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.students.id
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.api.id
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_secret_name" {
  description = "RDS password secret name"
  value       = aws_secretsmanager_secret.db_secret.name
}