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
    aws_api_gateway_integration_response.options_integration_response,
    aws_api_gateway_integration_response.existing_integration_responses
  ]
}
# Add a stage for the deployment
resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  depends_on = [aws_api_gateway_deployment.default]
}

# Enable CORS for the API Gateway
resource "aws_api_gateway_method" "options_method" {
  for_each = {
    "hello"      = aws_api_gateway_resource.hello.id
    "query"      = aws_api_gateway_resource.query.id
    "db-migrate" = aws_api_gateway_resource.db_migrate.id
    "profile"    = aws_api_gateway_resource.user_profile.id
    # Add other resources as needed
  }

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  for_each = aws_api_gateway_method.options_method

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  for_each = aws_api_gateway_method.options_method

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = aws_api_gateway_method.options_method

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = aws_api_gateway_method_response.options_200[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'" # In production, restrict to your domain
  }
}

# Add CORS headers to existing methods
resource "aws_api_gateway_method_response" "existing_method_responses" {
  for_each = {
    "hello_get"        = { resource_id = aws_api_gateway_resource.hello.id, http_method = "GET" },
    "query_post"       = { resource_id = aws_api_gateway_resource.query.id, http_method = "POST" },
    "db_migrate_post"  = { resource_id = aws_api_gateway_resource.db_migrate.id, http_method = "POST" },
    "update_profile"   = { resource_id = aws_api_gateway_resource.user_profile.id, http_method = "PUT" }
    # Add other methods as needed
  }

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "existing_integration_responses" {
  for_each = aws_api_gateway_method_response.existing_method_responses

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = each.value.status_code

  response_parameters = {
  "method.response.header.Access-Control-Allow-Origin" = "'https://${aws_cloudfront_distribution.frontend_distribution.domain_name}
  }
}
