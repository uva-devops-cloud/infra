# EventBridge rules for the split orchestrator architecture

# Rule to capture all worker lambda responses
resource "aws_cloudwatch_event_rule" "worker_response_rule" {
  name           = "worker-response-rule"
  description    = "Rule to capture all worker lambda responses"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.worker"],
    detail_type = [{ suffix = "Response" }]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

# Target for worker response rule - invokes Response Aggregator Lambda
resource "aws_cloudwatch_event_target" "worker_response_target" {
  rule           = aws_cloudwatch_event_rule.worker_response_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "ResponseAggregatorLambda"
  arn            = aws_lambda_function.response_aggregator.arn

  depends_on = [
    aws_cloudwatch_event_rule.worker_response_rule,
    aws_lambda_function.response_aggregator
  ]
}

# WebSocket API for real-time updates
resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "student-query-websocket-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  tags = local.common_tags
}

# Production stage for WebSocket API
resource "aws_apigatewayv2_stage" "websocket_stage" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  name        = "prod"
  auto_deploy = true

  tags = local.common_tags
}

# Connect route for WebSocket API
resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}

# Integration for WebSocket connect route
resource "aws_apigatewayv2_integration" "connect_integration" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  
  integration_uri = aws_lambda_function.websocket_connect.arn
}

# Disconnect route for WebSocket API
resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.disconnect_integration.id}"
}

# Integration for WebSocket disconnect route
resource "aws_apigatewayv2_integration" "disconnect_integration" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  
  integration_uri = aws_lambda_function.websocket_disconnect.arn
}

# Lambda function for handling WebSocket disconnects
resource "aws_lambda_function" "websocket_disconnect" {
  function_name = "websocket-disconnect-handler"
  role          = aws_iam_role.orchestrator_lambda_role.arn
  filename      = "${path.module}/dummy_lambda.zip"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      CONNECTIONS_TABLE_NAME = aws_dynamodb_table.websocket_connections.name
    }
  }

  tags = local.common_tags
}

# Lambda permission for API Gateway to invoke WebSocket Disconnect Lambda
resource "aws_lambda_permission" "websocket_disconnect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/$disconnect"
}

# Add the query API route to the existing API Gateway
resource "aws_apigatewayv2_route" "query_route" {
  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "POST /query"
  target    = "integrations/${aws_apigatewayv2_integration.query_integration.id}"
}

# Integration for query route
resource "aws_apigatewayv2_integration" "query_integration" {
  api_id             = aws_apigatewayv2_api.student_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.query_intake.arn
  integration_method = "POST"
  
  payload_format_version = "2.0"
}
