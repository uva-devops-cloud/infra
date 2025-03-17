#==============================================================================
# DynamoDB Table for Conversation Memory
#
# Purpose: Stores conversation history for LLM interactions to maintain context
# across multiple queries from the same user.
#
# Flow: 
# - LLMQueryAnalyzer and AnswerGenerator Lambdas read/write conversation history
# - TTL automatically removes old conversations after 15+ minutes
#==============================================================================

resource "aws_dynamodb_table" "conversation_memory" {
  name           = "ConversationMemory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserId"
  range_key      = "CorrelationId"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "CorrelationId"
    type = "S"
  }

  ttl {
    attribute_name = "ExpirationTime"
    enabled        = true
  }

  tags = {
    Name        = "conversation-memory-table"
    Environment = var.environment
    Project     = "StudentPortal"
  }
}

# Global Secondary Index for retrieving recent conversations by user
resource "aws_dynamodb_table_global_secondary_index" "user_conversations_index" {
  name               = "UserConversationsIndex"
  hash_key           = "UserId"
  range_key          = "ExpirationTime"
  table_name         = aws_dynamodb_table.conversation_memory.name
  projection_type    = "ALL"
}
