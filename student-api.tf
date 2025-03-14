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

resource "aws_api_gateway_integration" "orchestrator_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.query.id
  http_method             = aws_api_gateway_method.query_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.orchestrator.invoke_arn

  depends_on = [
    aws_api_gateway_method.query_post,
    aws_lambda_function.orchestrator
  ]
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_orchestrator" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orchestrator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.query_post.http_method}${aws_api_gateway_resource.query.path}"
}

# API gateway resource to handle SSO profile edits
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

// Add this to your existing profile endpoint configuration
resource "aws_api_gateway_method" "update_profile_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_profile.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_profile_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_profile.id
  http_method = aws_api_gateway_method.update_profile_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "update_profile_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_profile.id
  http_method = aws_api_gateway_method.update_profile_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "update_profile_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_profile.id
  http_method = aws_api_gateway_method.update_profile_options.http_method
  status_code = aws_api_gateway_method_response.update_profile_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

// Add method response for PUT to include CORS headers
resource "aws_api_gateway_method_response" "update_profile_put_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_profile.id
  http_method = aws_api_gateway_method.update_profile.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
  
  depends_on = [aws_api_gateway_method.update_profile]
}

// Add integration response for PUT to map CORS headers
resource "aws_api_gateway_integration_response" "update_profile_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_profile.id
  http_method = aws_api_gateway_method.update_profile.http_method
  status_code = aws_api_gateway_method_response.update_profile_put_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
  }
  
  depends_on = [
    aws_api_gateway_method_response.update_profile_put_200,
    aws_api_gateway_integration.update_profile_integration
  ]
}
