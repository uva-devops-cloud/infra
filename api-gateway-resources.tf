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
    aws_api_gateway_integration.query_intake_integration,
    aws_api_gateway_integration.update_profile_integration,
    aws_api_gateway_integration.query_status_integration,
    aws_api_gateway_method.query_post,
    aws_api_gateway_method.update_profile,
    aws_api_gateway_method.query_status_get,
    aws_api_gateway_resource.query,
    aws_api_gateway_resource.user_profile,
    aws_api_gateway_resource.query_status,
    aws_api_gateway_integration.hello_integration,
    aws_api_gateway_integration.hello_options_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.query.id,
      aws_api_gateway_resource.user_profile.id,
      aws_api_gateway_resource.query_status.id,
      aws_api_gateway_method.query_post.id,
      aws_api_gateway_method.update_profile.id,
      aws_api_gateway_method.query_status_get.id,
      aws_api_gateway_integration.query_intake_integration.id,
      aws_api_gateway_integration.update_profile_integration.id,
      aws_api_gateway_integration.query_status_integration.id
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

# API Gateway resources for student query system
#
# Endpoints:
# 1. POST /query - Submit a new student query (QueryIntake Lambda)
# 2. GET /query/{correlationId} - Check status of a query (QueryStatus Lambda)
# 3. PUT /profile - Update user profile (UpdateProfile Lambda)

#==============================================================================
# QUERY ENDPOINT (POST)
#==============================================================================
# Purpose: Allows clients to submit new student queries
# Method: POST
# Authentication: Cognito User Pools
# Target: QueryIntake Lambda
resource "aws_api_gateway_resource" "query" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "query"

  depends_on = [aws_api_gateway_rest_api.api]
}

resource "aws_api_gateway_method" "query_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.query.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.students_authorizer.id

  depends_on = [
    aws_api_gateway_resource.query,
    aws_api_gateway_authorizer.students_authorizer
  ]
}

resource "aws_api_gateway_integration" "query_intake_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.query.id
  http_method             = aws_api_gateway_method.query_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.query_intake.invoke_arn

  depends_on = [
    aws_api_gateway_method.query_post,
    aws_lambda_function.query_intake
  ]
}


#==============================================================================
# USER PROFILE ENDPOINT (PUT)
#==============================================================================
# Purpose: Allows users to update their profile information
# Method: PUT
# Authentication: Cognito User Pools
# Target: UpdateProfile Lambda
resource "aws_api_gateway_resource" "user_profile" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "profile"
}

resource "aws_api_gateway_method" "update_profile" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_profile.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.students_authorizer.id
}

resource "aws_api_gateway_integration" "update_profile_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.user_profile.id
  http_method             = aws_api_gateway_method.update_profile.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_profile.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_update_profile" {
  statement_id  = "AllowAPIGatewayInvokeUpdateProfile"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_profile.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.update_profile.http_method}${aws_api_gateway_resource.user_profile.path}"
}


#==============================================================================
# QUERY STATUS ENDPOINT (GET)
#==============================================================================
# Purpose: Allows clients to check the status of submitted queries
# Method: GET
# Authentication: Cognito User Pools
# Target: QueryStatus Lambda
# Path Parameters: correlationId
resource "aws_api_gateway_resource" "query_status" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.query.id
  path_part   = "{correlationId}"

  depends_on = [aws_api_gateway_resource.query]
}

resource "aws_api_gateway_method" "query_status_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.query_status.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.students_authorizer.id
  request_parameters = {
    "method.request.path.correlationId" = true
  }

  depends_on = [
    aws_api_gateway_resource.query_status,
    aws_api_gateway_authorizer.students_authorizer
  ]
}

resource "aws_api_gateway_integration" "query_status_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.query_status.id
  http_method             = aws_api_gateway_method.query_status_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.query_status.invoke_arn

  depends_on = [
    aws_api_gateway_method.query_status_get,
    aws_lambda_function.query_status
  ]
}

