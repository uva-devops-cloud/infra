output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_role.name
}

output "lambda_functions" {
  description = "Map of Lambda function details"
  value = {
    get_all_students = {
      name       = aws_lambda_function.get_all_students.function_name
      arn        = aws_lambda_function.get_all_students.arn
      invoke_arn = aws_lambda_function.get_all_students.invoke_arn
      version    = aws_lambda_function.get_all_students.version
    }
    get_student_by_id = {
      name       = aws_lambda_function.get_student_by_id.function_name
      arn        = aws_lambda_function.get_student_by_id.arn
      invoke_arn = aws_lambda_function.get_student_by_id.invoke_arn
      version    = aws_lambda_function.get_student_by_id.version
    }
    create_student = {
      name       = aws_lambda_function.create_student.function_name
      arn        = aws_lambda_function.create_student.arn
      invoke_arn = aws_lambda_function.create_student.invoke_arn
      version    = aws_lambda_function.create_student.version
    }
    update_student = {
      name       = aws_lambda_function.update_student.function_name
      arn        = aws_lambda_function.update_student.arn
      invoke_arn = aws_lambda_function.update_student.invoke_arn
      version    = aws_lambda_function.update_student.version
    }
    delete_student = {
      name       = aws_lambda_function.delete_student.function_name
      arn        = aws_lambda_function.delete_student.arn
      invoke_arn = aws_lambda_function.delete_student.invoke_arn
      version    = aws_lambda_function.delete_student.version
    }
  }
}

output "log_groups" {
  description = "Map of CloudWatch Log Group ARNs"
  value = {
    get_all_students  = aws_cloudwatch_log_group.get_all_students.arn
    get_student_by_id = aws_cloudwatch_log_group.get_student_by_id.arn
    create_student    = aws_cloudwatch_log_group.create_student.arn
    update_student    = aws_cloudwatch_log_group.update_student.arn
    delete_student    = aws_cloudwatch_log_group.delete_student.arn
  }
}

output "orchestrator_lambda_arn" {
  description = "ARN of the orchestrator Lambda function"
  value       = aws_lambda_function.orchestrator.arn
}

output "orchestrator_lambda_name" {
  description = "Name of the orchestrator Lambda function"
  value       = aws_lambda_function.orchestrator.function_name
}

output "get_student_data_lambda_arn" {
  description = "ARN of the get_student_data Lambda function"
  value       = aws_lambda_function.get_student_data.arn
}

output "get_student_data_lambda_name" {
  description = "Name of the get_student_data Lambda function"
  value       = aws_lambda_function.get_student_data.function_name
}

output "get_student_courses_lambda_arn" {
  description = "ARN of the get_student_courses Lambda function"
  value       = aws_lambda_function.get_student_courses.arn
}

output "get_student_courses_lambda_name" {
  description = "Name of the get_student_courses Lambda function"
  value       = aws_lambda_function.get_student_courses.function_name
}

output "update_profile_lambda_arn" {
  description = "ARN of the update_profile Lambda function"
  value       = aws_lambda_function.update_profile.arn
}

output "update_profile_lambda_name" {
  description = "Name of the update_profile Lambda function"
  value       = aws_lambda_function.update_profile.function_name
}

output "llm_api_key_secret_arn" {
  description = "ARN of the LLM API key secret (if created)"
  value       = aws_secretsmanager_secret.llm_api_key.arn
}

output "student_data_lambda_arn" {
  description = "ARN of the get_student_data Lambda function"
  value       = aws_lambda_function.get_student_data.arn
}

output "student_data_lambda_name" {
  description = "Name of the get_student_data Lambda function"
  value       = aws_lambda_function.get_student_data.function_name
}

output "student_courses_lambda_arn" {
  description = "ARN of the get_student_courses Lambda function"
  value       = aws_lambda_function.get_student_courses.arn
}

output "student_courses_lambda_name" {
  description = "Name of the get_student_courses Lambda function"
  value       = aws_lambda_function.get_student_courses.function_name
}
