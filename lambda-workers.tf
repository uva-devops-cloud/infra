# Lambda functions for the student query system

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
      DB_HOST        = module.rds.db_instance_address
      DB_NAME        = "studentportal"
      DB_PORT        = "5432"
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
      DB_HOST        = module.rds.db_instance_address
      DB_NAME        = "studentportal"
      DB_PORT        = "5432"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg
  ]

  tags = local.common_tags
}

# Lambda function for updating user profiles
resource "aws_lambda_function" "update_profile" {
  function_name = "update-user-profile"
  role          = aws_iam_role.update_profile_role.arn
  filename      = "${path.module}/dummy_lambda.zip" # This will be replaced by actual deployment
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256


  environment {
    variables = {
      USER_POOL_ID = aws_cognito_user_pool.students.id
    }
  }


  tags = local.common_tags
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"
  role          = aws_iam_role.worker_lambda_role.arn
  filename      = "${path.module}/dummy_lambda.zip" # This will be replaced by your actual deployment
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

  tags = local.common_tags
}

# Lambda function for getting program_details
resource "aws_lambda_function" "get_program_details" {
  function_name = "get-program-details"
  role          = aws_iam_role.worker_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  # This will be updated by the services CI/CD pipeline
  filename = "${path.module}/dummy_lambda.zip"

  environment {
    variables = {
      DB_SECRET_ARN  = aws_secretsmanager_secret.db_secret.arn
      DB_HOST        = module.rds.db_instance_address
      DB_NAME        = "studentportal"
      DB_PORT        = "5432"
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.main.name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg,
    module.rds
  ]
}

# Lambda function for getting course details
resource "aws_lambda_function" "get_course_details" {
  function_name = "get-course-details"
  role          = aws_iam_role.worker_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  # This will be updated by the services CI/CD pipeline
  filename = "${path.module}/dummy_lambda.zip"

  environment {
    variables = {
      DB_SECRET_ARN  = aws_secretsmanager_secret.db_secret.arn
      DB_HOST        = module.rds.db_instance_address
      DB_NAME        = "studentportal"
      DB_PORT        = "5432"
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.main.name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg,
    module.rds
  ]
}

# Lambda function for getting enrollment status
resource "aws_lambda_function" "get_enrollment_status" {
  function_name = "get-enrollment-status"
  role          = aws_iam_role.worker_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  # This will be updated by the services CI/CD pipeline
  filename = "${path.module}/dummy_lambda.zip"

  environment {
    variables = {
      DB_SECRET_ARN  = aws_secretsmanager_secret.db_secret.arn
      DB_HOST        = module.rds.db_instance_address
      DB_NAME        = "studentportal"
      DB_PORT        = "5432"
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.main.name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg,
    module.rds
  ]
}

# Lambda function for getting usage info
resource "aws_lambda_function" "get_usage_info" {
  function_name = "get-usage-info"
  role          = aws_iam_role.worker_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  # This will be updated by the services CI/CD pipeline
  filename = "${path.module}/dummy_lambda.zip"

  environment {
    variables = {
      DB_SECRET_ARN  = aws_secretsmanager_secret.db_secret.arn
      DB_HOST        = module.rds.db_instance_address
      DB_NAME        = "studentportal"
      DB_PORT        = "5432"
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.main.name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_policy_attachment,
    aws_security_group.lambda_sg,
    module.rds
  ]
}
