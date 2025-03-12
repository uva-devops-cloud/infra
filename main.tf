provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = "StudentPortal"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  tags = local.common_tags
}

resource "aws_resourceexplorer2_index" "explorer_index" {
  type = "LOCAL"

  tags = local.common_tags

}

resource "aws_resourceexplorer2_view" "explorer_view" {
  name       = "students-infra-view"
  depends_on = [aws_resourceexplorer2_index.explorer_index]

  tags = local.common_tags

}

# API Gateway (for Lambda endpoints)
resource "aws_api_gateway_rest_api" "api" {
  name        = "students-api"
  description = "REST API for students"

  tags = local.common_tags
}

# Required for API Gateway to function
resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [aws_api_gateway_rest_api.api]
}

resource "aws_apigatewayv2_integration" "orchestrator_integration" {
  api_id             = aws_api_gateway_rest_api.api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.orchestrator.invoke_arn

  depends_on = [aws_api_gateway_rest_api.api, aws_lambda_function.orchestrator]
}

resource "aws_apigatewayv2_route" "orchestrator_route" {
  api_id    = aws_api_gateway_rest_api.api.id
  route_key = "POST /api/student/query"
  target    = "integrations/${aws_apigatewayv2_integration.orchestrator_integration.id}"

  authorizer_id      = aws_apigatewayv2_authorizer.students_authorizer.id
  authorization_type = "JWT"

  depends_on = [
    aws_apigatewayv2_integration.orchestrator_integration,
    aws_apigatewayv2_authorizer.students_authorizer
  ]
}
