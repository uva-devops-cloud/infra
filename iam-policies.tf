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
