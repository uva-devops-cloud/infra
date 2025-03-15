output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "api_id" {
  description = "ID of the API Gateway"
  value       = module.api.api_id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = module.api.api_endpoint
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.identity.user_pool_id
}

output "cognito_app_client_id" {
  description = "ID of the Cognito App Client"
  value       = module.identity.app_client_id
}

output "cognito_hosted_ui_url" {
  description = "URL for the hosted UI login page"
  value       = module.identity.hosted_ui_url
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "db_name" {
  description = "Name of the database"
  value       = module.database.db_name
}

output "db_secret_name" {
  description = "Name of the database password secret"
  value       = module.database.db_secret_name
}

output "frontend_url" {
  description = "URL for the frontend application"
  value       = module.frontend.website_url
}

output "custom_domain_urls" {
  description = "URLs for custom domains (if configured)"
  value       = module.frontend.custom_domain_urls
}

output "streamlit_url" {
  description = "URL to access the Streamlit app (after manual configuration)"
  value       = module.frontend.streamlit_url
}

output "streamlit_public_ip" {
  description = "Public IP of the Streamlit instance"
  value       = module.frontend.streamlit_public_ip
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}
