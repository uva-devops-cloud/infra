#USES THE API DEFINED IN API_GATEWAY


# API Gateway resource for the hello endpoint
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
}

# HTTP GET method for the hello endpoint
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.students_authorizer.id
}

# Integration between API Gateway and Lambda
resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn
}

# Permission for API Gateway to invoke the Lambda
resource "aws_lambda_permission" "api_gateway_hello" {
  statement_id  = "AllowAPIGatewayInvokeHello"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.hello_get.http_method}${aws_api_gateway_resource.hello.path}"
}


# OPTIONS method for CORS preflight requests
resource "aws_api_gateway_method" "hello_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Mock integration for OPTIONS method
resource "aws_api_gateway_integration" "hello_options_integration" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.hello.id
  http_method      = aws_api_gateway_method.hello_options.http_method
  type             = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# Response for OPTIONS method
resource "aws_api_gateway_method_response" "hello_options_200" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_options.http_method
  status_code   = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration response for OPTIONS method
resource "aws_api_gateway_integration_response" "hello_options_integration_response" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_options.http_method
  status_code   = aws_api_gateway_method_response.hello_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Add CORS headers to GET method response
resource "aws_api_gateway_method_response" "hello_get_200" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_get.http_method
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Configure GET method integration response
resource "aws_api_gateway_integration_response" "hello_get_integration_response" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = aws_api_gateway_method.hello_get.http_method
  status_code   = aws_api_gateway_method_response.hello_get_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.hello_integration
  ]
}
