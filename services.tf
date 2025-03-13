# Define a simple AWS EventBridge event bus suitable for free tier usage
resource "aws_cloudwatch_event_bus" "main" {
  name = "main-event-bus"

  tags = {
    Name        = "main-event-bus"
    Environment = "dev"
    Tier        = "free"
  }
}

# Orchestrator Lambda Role (public-facing)
resource "aws_iam_role" "orchestrator_lambda_role" {
  name = "orchestrator-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })

  tags = local.common_tags
}

# Worker Lambda Role (for task-specific lambdas)
resource "aws_iam_role" "worker_lambda_role" {
  name = "worker-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })

  tags = local.common_tags
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "orchestrator_policy_attachment" {
  role       = aws_iam_role.orchestrator_lambda_role.name
  policy_arn = aws_iam_policy.orchestrator_policy.arn

  depends_on = [aws_iam_role.orchestrator_lambda_role, aws_iam_policy.orchestrator_policy]
}

resource "aws_iam_role_policy_attachment" "worker_policy_attachment" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = aws_iam_policy.worker_policy.arn

  depends_on = [aws_iam_role.worker_lambda_role, aws_iam_policy.worker_policy]
}
