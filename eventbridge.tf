# EventBridge rules for the student query system

# EventBridge rule for student degree queries
resource "aws_cloudwatch_event_rule" "get_student_degree_rule" {
  name           = "get-student-degree-rule"
  description    = "Rule to trigger get-student-degree lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail_type = ["GetStudentCurrentDegree"],
  })

  depends_on = [aws_cloudwatch_event_bus.main]

  tags = local.common_tags
}

# EventBridge rule for student data queries
resource "aws_cloudwatch_event_rule" "get_student_data_rule" {
  name           = "get-student-data-rule"
  description    = "Rule to trigger get-student-data lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail_type = ["GetStudentData"]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

# Target for the GetStudentData rule
resource "aws_cloudwatch_event_target" "get_student_data_target" {
  rule           = aws_cloudwatch_event_rule.get_student_data_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "GetStudentDataLambda"
  arn            = aws_lambda_function.get_student_data.arn

  depends_on = [
    aws_cloudwatch_event_rule.get_student_data_rule,
    aws_lambda_function.get_student_data
  ]
}

# EventBridge rule for student courses queries
resource "aws_cloudwatch_event_rule" "get_student_courses_rule" {
  name           = "get-student-courses-rule"
  description    = "Rule to trigger get-student-courses lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail_type = ["GetStudentCourses"]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

# Target for the GetStudentCourses rule
resource "aws_cloudwatch_event_target" "get_student_courses_target" {
  rule           = aws_cloudwatch_event_rule.get_student_courses_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "GetStudentCoursesLambda"
  arn            = aws_lambda_function.get_student_courses.arn

  depends_on = [
    aws_cloudwatch_event_rule.get_student_courses_rule,
    aws_lambda_function.get_student_courses
  ]
}

# Permission for EventBridge to invoke Lambdas
resource "aws_lambda_permission" "allow_eventbridge_get_student_data" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_student_data.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_student_data_rule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_get_student_courses" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_student_courses.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_student_courses_rule.arn
}
