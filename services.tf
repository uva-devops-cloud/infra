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

# Policies for orchestrator lambda
resource "aws_iam_policy" "orchestrator_policy" {
  name        = "orchestrator-lambda-policy"
  description = "Policy for orchestrator lambda to communicate with EventBridge and LLM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "events:PutEvents",
          "events:CreateEventBus",
          "events:ListEventBuses"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow"
      },
      {
        Action = [
          "bedrock:InvokeModel"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

# Policies for worker lambdas
resource "aws_iam_policy" "worker_policy" {
  name        = "worker-lambda-policy"
  description = "Policy for worker lambdas to communicate with EventBridge and RDS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "events:PutEvents"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow"
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.db_secret.arn,
        Effect   = "Allow"
      }
    ]
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "orchestrator_policy_attachment" {
  role       = aws_iam_role.orchestrator_lambda_role.name
  policy_arn = aws_iam_policy.orchestrator_policy.arn
}

resource "aws_iam_role_policy_attachment" "worker_policy_attachment" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = aws_iam_policy.worker_policy.arn
}
