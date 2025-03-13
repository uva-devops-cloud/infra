# LLM API Secret for orchestrator Lambda
resource "aws_secretsmanager_secret" "llm_api_key" {
  name        = "llm-api-key-${var.environment}"
  description = "API key for LLM service"
  tags        = local.common_tags
}

resource "aws_secretsmanager_secret_version" "llm_api_key_initial" {
  secret_id     = aws_secretsmanager_secret.llm_api_key.id
  secret_string = "dummy-replace-in-console" # Replace with actual key in AWS Console
}

# RDS Database password and secrets are already defined in database.tf
