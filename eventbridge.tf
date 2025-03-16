# EventBridge rules for the student query system

#------------------------------------------------------
# GetStudentCurrentDegree Resources
#------------------------------------------------------
resource "aws_cloudwatch_event_rule" "get_student_degree_rule" {
  name           = "get-student-degree-rule"
  description    = "Rule to trigger get-student-degree lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail_type = ["GetStudentCurrentDegree"],
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

# Note: Target and permission for GetStudentCurrentDegree appear to be missing

#------------------------------------------------------
# GetStudentData Resources
#------------------------------------------------------
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

resource "aws_lambda_permission" "allow_eventbridge_get_student_data" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_student_data.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_student_data_rule.arn
}

#------------------------------------------------------
# GetStudentCourses Resources
#------------------------------------------------------
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

resource "aws_lambda_permission" "allow_eventbridge_get_student_courses" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_student_courses.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_student_courses_rule.arn
}

#------------------------------------------------------
# GetProgramDetails Resources
#------------------------------------------------------
resource "aws_cloudwatch_event_rule" "get_program_details_rule" {
  name           = "get-program-details-rule"
  description    = "Rule to trigger get-program-details lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail_type = ["GetProgramDetails"]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

resource "aws_cloudwatch_event_target" "get_program_details_target" {
  rule           = aws_cloudwatch_event_rule.get_program_details_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "GetProgramDetailsLambda"
  arn            = aws_lambda_function.get_program_details.arn

  depends_on = [
    aws_cloudwatch_event_rule.get_program_details_rule,
    aws_lambda_function.get_program_details
  ]
}

resource "aws_lambda_permission" "allow_eventbridge_get_program_details" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_program_details.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_program_details_rule.arn
}
