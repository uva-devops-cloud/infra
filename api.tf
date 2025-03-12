# REST API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "student_portal_API"
  description = "Student Portal REST API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Enable CORS for the entire API
resource "aws_api_gateway_gateway_response" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  depends_on = [aws_api_gateway_rest_api.api]
}

# Define endpoints to create with original names
locals {
  endpoints = {
    "student"           = { mock_response = { name = "John Doe", email = "john.doe@student.uva.nl", start_year = 2022, graduation_year = 2026, address = "123 Amsterdam Street" } }
    "programs"          = { mock_response = [] }
    "courses"           = { mock_response = [] }
    "usage_information" = { mock_response = {} }
  }
}

# Create API resources
resource "aws_api_gateway_resource" "resources" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.key

  depends_on = [aws_api_gateway_rest_api.api]
}

# Create ANY methods with JWT auth for all resources
resource "aws_api_gateway_method" "any_methods" {
  for_each = local.endpoints

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resources[each.key].id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.students_authorizer.id

  depends_on = [aws_api_gateway_resource.resources]
}

# Mock integration for resources
resource "aws_api_gateway_integration" "any_integrations" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resources[each.key].id
  http_method = aws_api_gateway_method.any_methods[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  depends_on = [aws_api_gateway_method.any_methods]
}

# Integration responses for mock
resource "aws_api_gateway_integration_response" "any_integration_responses" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resources[each.key].id
  http_method = aws_api_gateway_method.any_methods[each.key].http_method
  status_code = "200"

  # Return appropriate mock response
  response_templates = {
    "application/json" = jsonencode(each.value.mock_response)
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH'"
  }

  depends_on = [
    aws_api_gateway_method_response.any_method_responses,
    aws_api_gateway_integration.any_integrations
  ]
}

# Method response for ANY methods
resource "aws_api_gateway_method_response" "any_method_responses" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resources[each.key].id
  http_method = aws_api_gateway_method.any_methods[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  depends_on = [aws_api_gateway_method.any_methods]
}

# OPTIONS methods (for CORS)
resource "aws_api_gateway_method" "options_methods" {
  for_each = local.endpoints

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resources[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.resources]
}

# OPTIONS integrations
resource "aws_api_gateway_integration" "options_integrations" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resources[each.key].id
  http_method = aws_api_gateway_method.options_methods[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  depends_on = [aws_api_gateway_method.options_methods]
}

# OPTIONS integration responses
resource "aws_api_gateway_integration_response" "options_integration_responses" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resources[each.key].id
  http_method = aws_api_gateway_method.options_methods[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH'"
  }

  depends_on = [
    aws_api_gateway_method_response.options_method_responses,
    aws_api_gateway_integration.options_integrations
  ]
}

# Method responses for OPTIONS
resource "aws_api_gateway_method_response" "options_method_responses" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resources[each.key].id
  http_method = aws_api_gateway_method.options_methods[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.options_methods]
}

# Add root resource method and integration
resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "root_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "root_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  status_code = aws_api_gateway_method_response.root_method_response.status_code

  response_templates = {
    "application/json" = jsonencode({
      message = "Welcome to Student Portal API"
    })
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

resource "time_sleep" "wait_for_api_resources" {
  depends_on = [
    aws_api_gateway_integration_response.any_integration_responses,
    aws_api_gateway_integration_response.options_integration_responses,
    aws_api_gateway_integration_response.root_integration_response
  ]
  create_duration = "10s"
}

# Deploy the API to a stage
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Add this stage description to force redeployment
  stage_description = "Deployed at ${timestamp()}"

  # Force redeployment when any of the integrations change
  triggers = {
    # Include all resources in the hash
    resources = sha1(join(",", [
      # Join all resource ids to create a dependency chain
      jsonencode(values(aws_api_gateway_resource.resources)[*].id),
      jsonencode(values(aws_api_gateway_method.any_methods)[*].id),
      jsonencode(values(aws_api_gateway_method.options_methods)[*].id),
      jsonencode(values(aws_api_gateway_integration.any_integrations)[*].id),
      jsonencode(values(aws_api_gateway_integration.options_integrations)[*].id)
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  # Explicit dependencies - list every resource type
  depends_on = [
    aws_api_gateway_method.any_methods,
    aws_api_gateway_method.options_methods,
    aws_api_gateway_integration.any_integrations,
    aws_api_gateway_integration.options_integrations,
    aws_api_gateway_method_response.any_method_responses,
    aws_api_gateway_method_response.options_method_responses,
    aws_api_gateway_integration_response.any_integration_responses,
    aws_api_gateway_integration_response.options_integration_responses,
    aws_api_gateway_authorizer.students_authorizer,
    # Add root resources
    aws_api_gateway_method.root_method,
    aws_api_gateway_integration.root_integration,
    aws_api_gateway_method_response.root_method_response,
    aws_api_gateway_integration_response.root_integration_response,
    time_sleep.wait_for_api_resources
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}

