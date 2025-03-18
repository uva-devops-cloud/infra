# CloudWatch Log Groups for Worker Lambdas

# Log group for Get Student Data Lambda
resource "aws_cloudwatch_log_group" "get_student_data" {
  name              = "/aws/lambda/${aws_lambda_function.get_student_data.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}

# Log group for Get Student Courses Lambda
resource "aws_cloudwatch_log_group" "get_student_courses" {
  name              = "/aws/lambda/${aws_lambda_function.get_student_courses.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}
