# IAM Policies and Roles for the student query system
#
# Policy Structure:
# 1. Orchestrator Lambda Role - Used by all orchestrator Lambdas (outside VPC)
# 2. Worker Lambda Role - Used by all worker Lambdas (inside VPC)
# 3. Update Profile Role - Used by the profile update Lambda

#==============================================================================
# ORCHESTRATOR LAMBDA POLICIES
#==============================================================================
# Purpose: Provides permissions for orchestrator Lambdas to:
# - Publish to EventBridge
# - Access DynamoDB tables
# - Invoke other Lambdas
# - Access Secrets Manager for LLM API keys
# - Write to CloudWatch Logs
# Used by: QueryIntake, LLMQueryAnalyzer, WorkerDispatcher, ResponseAggregator, AnswerGenerator, QueryStatus
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
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [
          aws_dynamodb_table.student_query_requests.arn,
          aws_dynamodb_table.student_query_responses.arn,
          aws_dynamodb_table.conversation_memory.arn,
          "${aws_dynamodb_table.conversation_memory.arn}/index/*",
          "${aws_dynamodb_table.student_query_requests.arn}/index/*",
          "${aws_dynamodb_table.student_query_responses.arn}/index/*"
        ],
        Effect = "Allow"
      },
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resources = [
          aws_secretsmanager_secret.db_secret.arn,
          aws_secretsmanager_secret.llm_api_key.arn
        ]
        Effect = "Allow"
      }
    ]
  })
}

#==============================================================================
# WORKER LAMBDA POLICIES
#==============================================================================
# Purpose: Provides permissions for worker Lambdas to:
# - Publish responses to EventBridge
# - Access RDS database via Secrets Manager
# - Create VPC network interfaces
# - Write to CloudWatch Logs
# Used by: GetStudentData, GetStudentCourses, GetProgramDetails, etc.
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

#==============================================================================
# PROFILE UPDATE LAMBDA ROLE AND POLICY
#==============================================================================
# Purpose: Provides permissions for the profile update Lambda to:
# - Update user attributes in Cognito
# - Write to CloudWatch Logs
# Used by: UpdateProfile Lambda
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
        Effect   = "Allow"
      },
      {
        Action = [
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminGetUser"
        ],
        Resource = aws_cognito_user_pool.students.arn,
        Effect   = "Allow"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "update_profile_policy_attachment" {
  role       = aws_iam_role.update_profile_role.name
  policy_arn = aws_iam_policy.update_profile_policy.arn
}

#==============================================================================
# LAMBDA ROLES
#==============================================================================
# Purpose: Base roles for Lambda functions to assume
# Used by: All Lambda functions in the system

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

#==============================================================================
# POLICY ATTACHMENTS
#==============================================================================
# Purpose: Attaches policies to roles
# Used by: All Lambda functions in the system

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
