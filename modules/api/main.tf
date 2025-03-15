# ------------------------------------------------------------------------------
# API Gateway Resources
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "student_api" {
  name          = "${var.prefix}-api"
  protocol_type = "HTTP"
  description   = "API Gateway for Student Portal"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    max_age       = 300
  }

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "student_api" {
  api_id      = aws_apigatewayv2_api.student_api.id
  name        = var.api_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
      responseLatency    = "$context.responseLatency"
    })
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.prefix}-api-gateway-logs"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# ------------------------------------------------------------------------------
# API Routes and Lambda Integrations
# ------------------------------------------------------------------------------

# GET /students - Get all students
resource "aws_apigatewayv2_integration" "get_all_students" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.get_all_students.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_all_students" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "GET /students"
  target    = "integrations/${aws_apigatewayv2_integration.get_all_students.id}"
}

# GET /students/{id} - Get student by ID
resource "aws_apigatewayv2_integration" "get_student_by_id" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.get_student_by_id.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_student_by_id" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "GET /students/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_student_by_id.id}"
}

# POST /students - Create student
resource "aws_apigatewayv2_integration" "create_student" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.create_student.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_student" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "POST /students"
  target    = "integrations/${aws_apigatewayv2_integration.create_student.id}"
}

# PUT /students/{id} - Update student
resource "aws_apigatewayv2_integration" "update_student" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.update_student.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_student" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "PUT /students/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_student.id}"
}

# DELETE /students/{id} - Delete student
resource "aws_apigatewayv2_integration" "delete_student" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.delete_student.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_student" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "DELETE /students/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_student.id}"
}

# ------------------------------------------------------------------------------
# Query and Profile Endpoints
# ------------------------------------------------------------------------------

# Query endpoint integration
resource "aws_apigatewayv2_integration" "query_integration" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.orchestrator.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Query endpoint route
resource "aws_apigatewayv2_route" "query_route" {
  api_id             = aws_apigatewayv2_api.student_api.id
  route_key          = "POST /query"
  target             = "integrations/${aws_apigatewayv2_integration.query_integration.id}"
  authorization_type = var.jwt_authorizer_id != null ? "JWT" : null
  authorizer_id      = var.jwt_authorizer_id
}

# Profile endpoint integration
resource "aws_apigatewayv2_integration" "profile_integration" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_functions.update_profile.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Profile endpoint routes
resource "aws_apigatewayv2_route" "get_profile_route" {
  api_id             = aws_apigatewayv2_api.student_api.id
  route_key          = "GET /profile/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.profile_integration.id}"
  authorization_type = var.jwt_authorizer_id != null ? "JWT" : null
  authorizer_id      = var.jwt_authorizer_id
}

resource "aws_apigatewayv2_route" "update_profile_route" {
  api_id             = aws_apigatewayv2_api.student_api.id
  route_key          = "PUT /profile/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.profile_integration.id}"
  authorization_type = var.jwt_authorizer_id != null ? "JWT" : null
  authorizer_id      = var.jwt_authorizer_id
}

# ------------------------------------------------------------------------------
# Database Migration Endpoint
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "migration_integration" {
  api_id                 = aws_apigatewayv2_api.student_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.migration_lambda_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "migration_route" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "POST /migrations"
  target    = "integrations/${aws_apigatewayv2_integration.migration_integration.id}"

  # Only allow authenticated admin users
  authorization_type = var.jwt_authorizer_id != null ? "JWT" : null
  authorizer_id      = var.jwt_authorizer_id
}

# ------------------------------------------------------------------------------
# Lambda Permissions for API Gateway
# ------------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway_get_all_students" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.get_all_students.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/students"
}

resource "aws_lambda_permission" "api_gateway_get_student_by_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.get_student_by_id.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/students/*"
}

resource "aws_lambda_permission" "api_gateway_create_student" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.create_student.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/students"
}

resource "aws_lambda_permission" "api_gateway_update_student" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.update_student.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/students/*"
}

resource "aws_lambda_permission" "api_gateway_delete_student" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.delete_student.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/students/*"
}

resource "aws_lambda_permission" "orchestrator_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.orchestrator.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/query"
}

resource "aws_lambda_permission" "update_profile_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions.update_profile.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/profile/*"
}
