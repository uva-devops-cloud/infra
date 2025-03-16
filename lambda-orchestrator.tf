# Split Orchestrator Lambda Functions
# This file contains the Lambda functions that make up the orchestrator functionality

# Query Intake Lambda (No VPC - entry point from API Gateway)
resource "aws_lambda_function" "query_intake" {
  function_name = "student-query-intake"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file - will be replaced by CI/CD
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  timeout     = 30
  memory_size = 256

  # Remove vpc_config to place outside VPC for direct API Gateway access

  environment {
    variables = {
      LLM_ANALYZER_FUNCTION = aws_lambda_function.llm_query_analyzer.function_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_lambda_function.llm_query_analyzer
  ]

  tags = local.common_tags
}

# LLM Query Analyzer Lambda (No VPC - needs internet access for LLM API)
resource "aws_lambda_function" "llm_query_analyzer" {
  function_name = "student-query-llm-analyzer"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file - will be replaced by CI/CD
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  timeout     = 60 # Increased for LLM API calls
  memory_size = 256

  # Remove vpc_config to place outside VPC for LLM API access

  environment {
    variables = {
      WORKER_DISPATCHER_FUNCTION = aws_lambda_function.worker_dispatcher.function_name,
      LLM_ENDPOINT               = var.llm_endpoint,
      LLM_API_KEY_SECRET_ARN     = aws_secretsmanager_secret.llm_api_key.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_lambda_function.worker_dispatcher,
    aws_secretsmanager_secret.llm_api_key
  ]

  tags = local.common_tags
}

# Worker Dispatcher Lambda (No VPC - needs to publish to EventBridge)
resource "aws_lambda_function" "worker_dispatcher" {
  function_name = "student-query-worker-dispatcher"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file - will be replaced by CI/CD
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  timeout     = 30
  memory_size = 256

  # Remove vpc_config to place outside VPC

  environment {
    variables = {
      EVENT_BUS_NAME      = aws_cloudwatch_event_bus.main.name,
      REQUESTS_TABLE_NAME = aws_dynamodb_table.student_query_requests.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_cloudwatch_event_bus.main,
    aws_dynamodb_table.student_query_requests
  ]

  tags = local.common_tags
}

# Response Aggregator Lambda (No VPC - triggered by EventBridge)
resource "aws_lambda_function" "response_aggregator" {
  function_name = "student-query-response-aggregator"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file - will be replaced by CI/CD
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  timeout     = 30
  memory_size = 256

  # Remove vpc_config to place outside VPC

  environment {
    variables = {
      REQUESTS_TABLE_NAME       = aws_dynamodb_table.student_query_requests.name,
      ANSWER_GENERATOR_FUNCTION = aws_lambda_function.answer_generator.function_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_dynamodb_table.student_query_requests,
    aws_lambda_function.answer_generator
  ]

  tags = local.common_tags
}

# Answer Generator Lambda (No VPC - needs internet access for LLM API)
resource "aws_lambda_function" "answer_generator" {
  function_name = "student-query-answer-generator"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file - will be replaced by CI/CD
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  timeout     = 60 # Increased for LLM API calls
  memory_size = 256

  # Remove vpc_config to place outside VPC for LLM API access

  environment {
    variables = {
      LLM_ENDPOINT           = var.llm_endpoint,
      LLM_API_KEY_SECRET_ARN = aws_secretsmanager_secret.llm_api_key.arn,
      REQUESTS_TABLE_NAME    = aws_dynamodb_table.student_query_requests.name,
      RESPONSES_TABLE_NAME   = aws_dynamodb_table.student_query_responses.name,
      WEBSOCKET_API_ENDPOINT = aws_apigatewayv2_stage.websocket_stage.invoke_url
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_secretsmanager_secret.llm_api_key,
    aws_dynamodb_table.student_query_requests,
    aws_dynamodb_table.student_query_responses,
    aws_apigatewayv2_stage.websocket_stage
  ]

  tags = local.common_tags
}

# WebSocket Connect Lambda (No VPC - triggered by API Gateway)
resource "aws_lambda_function" "websocket_connect" {
  function_name = "websocket-connect-handler"
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

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_dynamodb_table.websocket_connections
  ]

  tags = local.common_tags
}

# Lambda permission for API Gateway to invoke Query Intake Lambda
resource "aws_lambda_permission" "api_gateway_query_intake" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_intake.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*/query"
}

# Lambda permission for EventBridge to invoke Response Aggregator Lambda
resource "aws_lambda_permission" "eventbridge_response_aggregator" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.response_aggregator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.worker_response_rule.arn
}

# Lambda permission for API Gateway to invoke WebSocket Connect Lambda
resource "aws_lambda_permission" "websocket_connect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/$connect"
}
