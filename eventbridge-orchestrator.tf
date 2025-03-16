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

# HTTP method for the query endpoint
resource "aws_api_gateway_method" "query_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.query_resource.id
  http_method   = "POST"
  authorization = "NONE" # Change to "COGNITO_USER_POOLS" if using auth
}

# Integration for query endpoint with Lambda
resource "aws_api_gateway_integration" "query_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.query_resource.id
  http_method             = aws_api_gateway_method.query_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.query_intake.invoke_arn
}
