output "cognito_user_pool_id" {
  value = module.identity.user_pool_id
}

output "api_endpoint" {
  value = module.api.api_endpoint
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "db_secret_name" {
  description = "RDS password secret name"
  value       = module.database.db_secret_name
}

output "frontend_url" {
  description = "URL for the frontend application"
  value       = module.frontend.website_url
}

output "streamlit_url" {
  value       = "http://${aws_instance.streamlit.public_ip}:8501"
  description = "URL to access the Streamlit app (after manual configuration)"
}
