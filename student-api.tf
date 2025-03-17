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

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_query_intake" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_intake.function_name
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

# API Gateway resource for query status endpoint
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

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_query_status" {
  statement_id  = "AllowAPIGatewayInvokeStatus"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.query_status_get.http_method}${aws_api_gateway_resource.query_status.path}"
}
