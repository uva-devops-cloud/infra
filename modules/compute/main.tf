# ------------------------------------------------------------------------------
# Lambda Execution Role and Policies
# ------------------------------------------------------------------------------

resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_secrets_policy" {
  name        = "${var.prefix}-lambda-secrets-policy"
  description = "Allow Lambda functions to access specific secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = var.db_secret_arn
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}

# ------------------------------------------------------------------------------
# Orchestrator Lambda Role and Policies
# ------------------------------------------------------------------------------

resource "aws_iam_role" "orchestrator_lambda_role" {
  name = "${var.prefix}-orchestrator-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "orchestrator_lambda_basic" {
  role       = aws_iam_role.orchestrator_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "orchestrator_eventbridge_policy" {
  name        = "${var.prefix}-orchestrator-eventbridge-policy"
  description = "Allow Lambda to publish events to EventBridge"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "events:PutEvents"
        ],
        Effect   = "Allow",
        Resource = var.event_bus_arn != null ? var.event_bus_arn : "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "orchestrator_eventbridge" {
  role       = aws_iam_role.orchestrator_lambda_role.name
  policy_arn = aws_iam_policy.orchestrator_eventbridge_policy.arn
}

resource "aws_iam_policy" "orchestrator_secrets_policy" {
  name        = "${var.prefix}-orchestrator-secrets-policy"
  description = "Allow orchestrator to access LLM API key"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = var.llm_api_key_secret_arn != null ? var.llm_api_key_secret_arn : "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "orchestrator_secrets" {
  role       = aws_iam_role.orchestrator_lambda_role.name
  policy_arn = aws_iam_policy.orchestrator_secrets_policy.arn
}

# ------------------------------------------------------------------------------
# Lambda Functions
# ------------------------------------------------------------------------------

# Get All Students Lambda
resource "aws_lambda_function" "get_all_students" {
  function_name = "${var.prefix}-get-all-students"
  role          = aws_iam_role.lambda_role.arn
  handler       = "get_all_students.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  # Assuming the code is in an S3 bucket
  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/get_all_students.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port
    }
  }

  tags = var.tags
}

# Get Student By ID Lambda
resource "aws_lambda_function" "get_student_by_id" {
  function_name = "${var.prefix}-get-student-by-id"
  role          = aws_iam_role.lambda_role.arn
  handler       = "get_student_by_id.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/get_student_by_id.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port
    }
  }

  tags = var.tags
}

# Create Student Lambda
resource "aws_lambda_function" "create_student" {
  function_name = "${var.prefix}-create-student"
  role          = aws_iam_role.lambda_role.arn
  handler       = "create_student.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/create_student.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port
    }
  }

  tags = var.tags
}

# Update Student Lambda
resource "aws_lambda_function" "update_student" {
  function_name = "${var.prefix}-update-student"
  role          = aws_iam_role.lambda_role.arn
  handler       = "update_student.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/update_student.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port
    }
  }

  tags = var.tags
}

# Delete Student Lambda
resource "aws_lambda_function" "delete_student" {
  function_name = "${var.prefix}-delete-student"
  role          = aws_iam_role.lambda_role.arn
  handler       = "delete_student.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/delete_student.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port
    }
  }

  tags = var.tags
}

# Orchestrator Lambda (No VPC for direct internet access to LLM APIs)
resource "aws_lambda_function" "orchestrator" {
  function_name = "${var.prefix}-orchestrator"
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
      EVENT_BUS_NAME         = var.event_bus_name,
      LLM_API_KEY_SECRET_ARN = var.create_llm_api_key_secret ? aws_secretsmanager_secret.llm_api_key[0].arn : var.llm_api_key_secret_arn
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment
  ]

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Additional Lambda Functions (Student Data & Courses)
# ------------------------------------------------------------------------------

resource "aws_lambda_function" "get_student_data" {
  function_name = "${var.prefix}-get-student-data"
  role          = aws_iam_role.lambda_role.arn
  handler       = "get_student_data.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/get_student_data.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port,
      EVENT_BUS_NAME = var.event_bus_name
    }
  }

  tags = var.tags
}

resource "aws_lambda_function" "get_student_courses" {
  function_name = "${var.prefix}-get-student-courses"
  role          = aws_iam_role.lambda_role.arn
  handler       = "get_student_courses.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/get_student_courses.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port,
      EVENT_BUS_NAME = var.event_bus_name
    }
  }

  tags = var.tags
}

resource "aws_lambda_function" "update_profile" {
  function_name = "${var.prefix}-update-profile"
  role          = aws_iam_role.lambda_role.arn
  handler       = "update_profile.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key_prefix}/update_profile.zip"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_name,
      DB_NAME        = var.db_name,
      DB_HOST        = var.db_host,
      DB_PORT        = var.db_port,
      EVENT_BUS_NAME = var.event_bus_name
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# CloudWatch Log Groups
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "get_all_students" {
  name              = "/aws/lambda/${aws_lambda_function.get_all_students.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "get_student_by_id" {
  name              = "/aws/lambda/${aws_lambda_function.get_student_by_id.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "create_student" {
  name              = "/aws/lambda/${aws_lambda_function.create_student.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "update_student" {
  name              = "/aws/lambda/${aws_lambda_function.update_student.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "delete_student" {
  name              = "/aws/lambda/${aws_lambda_function.delete_student.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "orchestrator" {
  name              = "/aws/lambda/${aws_lambda_function.orchestrator.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "get_student_data" {
  name              = "/aws/lambda/${aws_lambda_function.get_student_data.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "get_student_courses" {
  name              = "/aws/lambda/${aws_lambda_function.get_student_courses.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

