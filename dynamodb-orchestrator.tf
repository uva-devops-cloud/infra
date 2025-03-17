# DynamoDB tables for tracking student queries and responses
#
# Data Flow:
# 1. Query Intake Lambda → StudentQueryRequests (creates initial record)
# 2. Worker Dispatcher Lambda → StudentQueryRequests (updates with required workers)
# 3. Response Aggregator Lambda → StudentQueryRequests (updates completion status)
# 4. Answer Generator Lambda → StudentQueryResponses (stores final answers)
# 5. Query Status Lambda → StudentQueryRequests/StudentQueryResponses (reads status/answers)

#==============================================================================
# STUDENT QUERY REQUESTS TABLE
#==============================================================================
# Purpose: Tracks request states, correlation IDs, and processing status
# Primary Key: CorrelationId (String)
# GSI: UserIdIndex (for user-specific queries)
# Used by: QueryIntake, WorkerDispatcher, ResponseAggregator, AnswerGenerator, QueryStatus
resource "aws_dynamodb_table" "student_query_requests" {
  name           = "StudentQueryRequests"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CorrelationId"

  attribute {
    name = "CorrelationId"
    type = "S"
  }

  attribute {
    name = "UserId"
    type = "S"
  }

  global_secondary_index {
    name               = "UserIdIndex"
    hash_key           = "UserId"
    projection_type    = "ALL"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  tags = local.common_tags
}

#==============================================================================
# STUDENT QUERY RESPONSES TABLE
#==============================================================================
# Purpose: Stores query responses, history, and final answers
# Primary Key: CorrelationId (String), Timestamp (String)
# GSI: UserIdIndex (for user-specific history)
# Used by: AnswerGenerator, QueryStatus
resource "aws_dynamodb_table" "student_query_responses" {
  name           = "StudentQueryResponses"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CorrelationId"
  range_key      = "Timestamp"

  attribute {
    name = "CorrelationId"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  attribute {
    name = "UserId"
    type = "S"
  }

  global_secondary_index {
    name               = "UserIdIndex"
    hash_key           = "UserId"
    range_key          = "Timestamp"
    projection_type    = "ALL"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  tags = local.common_tags
}
