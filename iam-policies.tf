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

# Role for the profile update Lambda
resource "aws_iam_role" "update_profile_role" {
  name = "lambda-update-profile-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  tags = local.common_tags
}

# Policy allowing the Lambda to update user attributes in Cognito
resource "aws_iam_policy" "update_profile_policy" {
  name        = "lambda-update-profile-policy"
  description = "Allow Lambda to update user attributes in Cognito"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect = "Allow"
      },
      {
        Action = [
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminGetUser"
        ],
        Resource = aws_cognito_user_pool.students.arn,
        Effect = "Allow"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "update_profile_policy_attachment" {
  role       = aws_iam_role.update_profile_role.name
  policy_arn = aws_iam_policy.update_profile_policy.arn
}
