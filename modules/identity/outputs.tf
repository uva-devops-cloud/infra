output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint URL of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "app_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.web_client.id
}

output "domain" {
  description = "Cognito User Pool domain name"
  value       = aws_cognito_user_pool_domain.main.domain
}

output "hosted_ui_url" {
  description = "URL for the hosted UI login page"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool (if created)"
  value       = aws_cognito_identity_pool.main.id
}

output "authenticated_role_arn" {
  description = "ARN of the authenticated role (if identity pool created)"
  value       = aws_iam_role.authenticated.arn
}

output "jwt_authorizer_id" {
  description = "ID of the JWT authorizer for API Gateway (if created)"
  value       = aws_apigatewayv2_authorizer.cognito.id
}
