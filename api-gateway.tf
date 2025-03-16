# API Gateway (for Lambda endpoints)
resource "aws_api_gateway_rest_api" "api" {
  name        = "students-api"
  description = "REST API for students"
  tags        = local.common_tags
}

# Required for API Gateway to function
resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.example,
    aws_api_gateway_integration.orchestrator_integration,
    aws_api_gateway_integration.db_migrate_integration,
    aws_api_gateway_integration.hello_integration,
    aws_api_gateway_integration.hello_options_integration,
    aws_api_gateway_integration_response.hello_options_integration_response,
    aws_api_gateway_integration_response.hello_get_integration_response
  ]

  # Force redeployment on changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.hello.id,
      aws_api_gateway_method.hello_get.id,
      aws_api_gateway_method.hello_options.id,
      aws_api_gateway_integration.hello_integration.id,
      aws_api_gateway_integration.hello_options_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Add a stage for the deployment
resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  depends_on = [aws_api_gateway_deployment.default]
}
