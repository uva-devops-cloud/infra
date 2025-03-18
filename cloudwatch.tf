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

# Log group for Update Profile Lambda
resource "aws_cloudwatch_log_group" "update_profile" {
  name              = "/aws/lambda/${aws_lambda_function.update_profile.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}

# Log group for Hello World Lambda
resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}

# Log group for Get Program Details Lambda
resource "aws_cloudwatch_log_group" "get_program_details" {
  name              = "/aws/lambda/${aws_lambda_function.get_program_details.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}
