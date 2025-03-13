# Lambda functions for the student query system

# Orchestrator Lambda (No VPC for direct internet access to LLM APIs)
resource "aws_lambda_function" "orchestrator" {
  function_name = "student-query-orchestrator"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  # Increased timeout for LLM API calls
  timeout     = 60
  memory_size = 256

  # Remove vpc_config completely to place outside VPC

  environment {
    variables = {
      EVENT_BUS_NAME         = aws_cloudwatch_event_bus.main.name,
      LLM_API_KEY_SECRET_ARN = aws_secretsmanager_secret.llm_api_key.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = local.common_tags
}

# Worker Lambda: Get Student Data
resource "aws_lambda_function" "get_student_data" {
  function_name = "get-student-data"
  role          = aws_iam_role.worker_lambda_role.arn
  filename      = "${path.module}/dummy_lambda.zip"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  # Put worker Lambdas in private subnet
  vpc_config {
    subnet_ids         = [aws_subnet.private.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.main.name,
      DB_SECRET_ARN  = aws_secretsmanager_secret.db_secret.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg
  ]

  tags = local.common_tags
}

# Worker Lambda: Get Student Courses
resource "aws_lambda_function" "get_student_courses" {
  function_name = "get-student-courses"
  role          = aws_iam_role.worker_lambda_role.arn
  filename      = "${path.module}/dummy_lambda.zip"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  vpc_config {
    subnet_ids         = [aws_subnet.private.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.main.name,
      DB_SECRET_ARN  = aws_secretsmanager_secret.db_secret.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg
  ]

  tags = local.common_tags
}

# Worker Lambda functions (in Private Subnet)
# resource "aws_lambda_function" "get_student_degree" {
#   function_name = "get-student-degree"
#   # Rest of configuration...
# }

# Additional worker Lambda functions here...
