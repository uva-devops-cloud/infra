# DynamoDB tables for tracking student queries and responses

# Table for tracking request states and correlation
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

# Table for storing query responses and history
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
