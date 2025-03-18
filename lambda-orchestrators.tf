# Split Orchestrator Lambda Functions
# This file contains the Lambda functions that make up the orchestrator functionality
#
# Architecture Flow:
# 1. Query Intake (API Gateway) → LLM Query Analyzer → Worker Dispatcher
# 2. Worker Dispatcher → EventBridge → Worker Lambdas
# 3. Worker Lambdas → EventBridge → Response Aggregator
# 4. Response Aggregator → Answer Generator
# 5. Query Status (API Gateway) → DynamoDB (for status checks)

#==============================================================================
# QUERY INTAKE LAMBDA
#==============================================================================
# Purpose: Entry point from API Gateway, receives student queries and forwards to LLM Analyzer
# Invoked by: API Gateway POST /query endpoint
# Invokes: LLM Query Analyzer Lambda
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
      LLM_ANALYZER_FUNCTION       = aws_lambda_function.llm_query_analyzer.function_name
      CONVERSATION_TABLE_NAME     = aws_dynamodb_table.conversation_memory.name
      USER_DATA_GENERATOR_FUNCTION = aws_lambda_function.user_data_generator.function_name
      REQUESTS_TABLE_NAME         = aws_dynamodb_table.student_query_requests.name
      RESPONSES_TABLE_NAME        = aws_dynamodb_table.student_query_responses.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

#==============================================================================
# LLM QUERY ANALYZER LAMBDA
#==============================================================================
# Purpose: Analyzes student queries using LLM to determine required data sources
# Invoked by: Query Intake Lambda
# Invokes: Worker Dispatcher Lambda
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
      LLM_API_KEY_SECRET_ARN     = aws_secretsmanager_secret.llm_api_key.arn,
      CONVERSATION_TABLE_NAME    = aws_dynamodb_table.conversation_memory.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

#==============================================================================
# WORKER DISPATCHER LAMBDA
#==============================================================================
# Purpose: Dispatches tasks to worker Lambdas via EventBridge
# Invoked by: LLM Query Analyzer Lambda
# Publishes to: EventBridge (worker events)
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
      EVENT_BUS_NAME          = aws_cloudwatch_event_bus.main.name,
      REQUESTS_TABLE_NAME     = aws_dynamodb_table.student_query_requests.name,
      CONVERSATION_TABLE_NAME = aws_dynamodb_table.conversation_memory.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

#==============================================================================
# RESPONSE AGGREGATOR LAMBDA
#==============================================================================
# Purpose: Collects and aggregates responses from worker Lambdas
# Invoked by: EventBridge (worker response events)
# Invokes: Answer Generator Lambda
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
      ANSWER_GENERATOR_FUNCTION = aws_lambda_function.answer_generator.function_name,
      CONVERSATION_TABLE_NAME   = aws_dynamodb_table.conversation_memory.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

#==============================================================================
# ANSWER GENERATOR LAMBDA
#==============================================================================
# Purpose: Generates final answers using aggregated data and LLM
# Invoked by: Response Aggregator Lambda
# Updates: DynamoDB with final responses
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
      LLM_ENDPOINT            = var.llm_endpoint,
      LLM_API_KEY_SECRET_ARN  = aws_secretsmanager_secret.llm_api_key.arn,
      REQUESTS_TABLE_NAME     = aws_dynamodb_table.student_query_requests.name,
      RESPONSES_TABLE_NAME    = aws_dynamodb_table.student_query_responses.name,
      CONVERSATION_TABLE_NAME = aws_dynamodb_table.conversation_memory.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

#==============================================================================
# QUERY STATUS LAMBDA
#==============================================================================
# Purpose: Provides status information for client polling
# Invoked by: API Gateway GET /query/{correlationId} endpoint
# Reads from: DynamoDB tables for status and response data
resource "aws_lambda_function" "query_status" {
  function_name = "student-query-status"
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
      REQUESTS_TABLE_NAME     = aws_dynamodb_table.student_query_requests.name,
      RESPONSES_TABLE_NAME    = aws_dynamodb_table.student_query_responses.name,
      CONVERSATION_TABLE_NAME = aws_dynamodb_table.conversation_memory.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

#==============================================================================
# USER DATA GENERATOR LAMBDA
#==============================================================================
# Purpose: Generates random student data for newly registered users
# Invoked by: Query Intake Lambda when a user makes their first query
# Connects to: PostgreSQL database to create student records
resource "aws_lambda_function" "user_data_generator" {
  function_name = "student-query-user-data-generator"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file - will be replaced by CI/CD
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  timeout     = 60 # Higher timeout for database operations
  memory_size = 256

  # Configure VPC access for database connectivity
  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN     = aws_secretsmanager_secret.db_secret.arn
      DB_HOST           = module.rds.db_instance_address
      DB_NAME           = "studentportal"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    module.rds
  ]

  tags = local.common_tags
}

#==============================================================================
# LAMBDA PERMISSIONS
#==============================================================================
# Permission for API Gateway to invoke Query Intake Lambda
resource "aws_lambda_permission" "api_gateway_query_intake" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_intake.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/query"
}

# Permission for API Gateway to invoke Query Status Lambda
resource "aws_lambda_permission" "api_gateway_query_status" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/query/{correlationId}"
}

# Permission for EventBridge to invoke Response Aggregator Lambda
resource "aws_lambda_permission" "eventbridge_response_aggregator" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.response_aggregator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.worker_response_rule.arn
}
