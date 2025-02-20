output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.students.id
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.api.id
}
