# EventBridge rules for the student query system
#
# Worker Lambda Event Flow:
# 1. WorkerDispatcher Lambda → EventBridge (worker events)
# 2. EventBridge rules → Worker Lambdas (based on detail-type)
# 3. Worker Lambdas → EventBridge (worker responses)
# 4. Worker response rule → ResponseAggregator Lambda

#==============================================================================
# EVENT BUS
#==============================================================================
resource "aws_cloudwatch_event_bus" "main" {
  name = "main-event-bus"
  tags = {
    Name        = "main-event-bus"
    Environment = "dev"
    Tier        = "free"
  }
}

#==============================================================================
# WORKER LAMBDA RULES
#==============================================================================
# Each rule below is responsible for triggering a specific worker Lambda
# based on the detail-type in the event. The WorkerDispatcher Lambda
# publishes events with the appropriate detail-type to trigger the needed workers.



#------------------------------------------------------
# GetStudentData Resources
#------------------------------------------------------
# Purpose: Triggers the Lambda that retrieves a student's personal data
# Source: WorkerDispatcher Lambda (via EventBridge)
# Target: GetStudentData Lambda
resource "aws_cloudwatch_event_rule" "get_student_data_rule" {
  name           = "get-student-data-rule"
  description    = "Rule to trigger get-student-data lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail-type = ["GetStudentData"]
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
# Purpose: Triggers the Lambda that retrieves a student's course enrollments
# Source: WorkerDispatcher Lambda (via EventBridge)
# Target: GetStudentCourses Lambda
resource "aws_cloudwatch_event_rule" "get_student_courses_rule" {
  name           = "get-student-courses-rule"
  description    = "Rule to trigger get-student-courses lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail-type = ["GetStudentCourses"]
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
# Purpose: Triggers the Lambda that retrieves details about academic programs
# Source: WorkerDispatcher Lambda (via EventBridge)
# Target: GetProgramDetails Lambda
resource "aws_cloudwatch_event_rule" "get_program_details_rule" {
  name           = "get-program-details-rule"
  description    = "Rule to trigger get-program-details lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail-type = ["GetProgramDetails"]
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

#------------------------------------------------------
# GetCourseDetails Resources
#------------------------------------------------------
# Purpose: Triggers the Lambda that retrieves details about courses
# Source: WorkerDispatcher Lambda (via EventBridge)
# Target: GetCourseDetails Lambda
resource "aws_cloudwatch_event_rule" "get_course_details_rule" {
  name           = "get-course-details-rule"
  description    = "Rule to trigger get-course-details lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail-type = ["GetCourseDetails"]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

resource "aws_cloudwatch_event_target" "get_course_details_target" {
  rule           = aws_cloudwatch_event_rule.get_course_details_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "GetCourseDetailsLambda"
  arn            = aws_lambda_function.get_course_details.arn

  depends_on = [
    aws_cloudwatch_event_rule.get_course_details_rule,
    aws_lambda_function.get_course_details
  ]
}

resource "aws_lambda_permission" "allow_eventbridge_get_course_details" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_course_details.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_course_details_rule.arn
}

#------------------------------------------------------
# GetEnrollmentStatus Resources
#------------------------------------------------------
# Purpose: Triggers the Lambda that retrieves a student's enrollment status
# Source: WorkerDispatcher Lambda (via EventBridge)
# Target: GetEnrollmentStatus Lambda
resource "aws_cloudwatch_event_rule" "get_enrollment_status_rule" {
  name           = "get-enrollment-status-rule"
  description    = "Rule to trigger get-enrollment-status lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail-type = ["GetEnrollmentStatus"]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

resource "aws_cloudwatch_event_target" "get_enrollment_status_target" {
  rule           = aws_cloudwatch_event_rule.get_enrollment_status_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "GetEnrollmentStatusLambda"
  arn            = aws_lambda_function.get_enrollment_status.arn

  depends_on = [
    aws_cloudwatch_event_rule.get_enrollment_status_rule,
    aws_lambda_function.get_enrollment_status
  ]
}

resource "aws_lambda_permission" "allow_eventbridge_get_enrollment_status" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_enrollment_status.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_enrollment_status_rule.arn
}

#------------------------------------------------------
# GetUsageInfo Resources
#------------------------------------------------------
# Purpose: Triggers the Lambda that retrieves system usage information
# Source: WorkerDispatcher Lambda (via EventBridge)
# Target: GetUsageInfo Lambda
resource "aws_cloudwatch_event_rule" "get_usage_info_rule" {
  name           = "get-usage-info-rule"
  description    = "Rule to trigger get-usage-info lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail-type = ["GetUsageInfo"]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

resource "aws_cloudwatch_event_target" "get_usage_info_target" {
  rule           = aws_cloudwatch_event_rule.get_usage_info_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "GetUsageInfoLambda"
  arn            = aws_lambda_function.get_usage_info.arn

  depends_on = [
    aws_cloudwatch_event_rule.get_usage_info_rule,
    aws_lambda_function.get_usage_info
  ]
}

resource "aws_lambda_permission" "allow_eventbridge_get_usage_info" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_usage_info.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get_usage_info_rule.arn
}


#==============================================================================
# WORKER RESPONSE RULE
#==============================================================================
# Purpose: Captures all worker Lambda responses and routes them to the Response Aggregator
# Source: Worker Lambdas (via EventBridge)
# Target: Response Aggregator Lambda
resource "aws_cloudwatch_event_rule" "worker_response_rule" {
  name           = "worker-response-rule"
  description    = "Rule to capture all worker lambda responses"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.worker"],
    detail-type = [{ suffix = "Response" }]
  })

  depends_on = [aws_cloudwatch_event_bus.main]
  tags       = local.common_tags
}

#==============================================================================
# WORKER RESPONSE TARGET
#==============================================================================
# Purpose: Invokes the Response Aggregator Lambda for worker responses
# Source: Worker Response Rule
# Target: Response Aggregator Lambda
resource "aws_cloudwatch_event_target" "worker_response_target" {
  rule           = aws_cloudwatch_event_rule.worker_response_rule.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "ResponseAggregatorLambda"
  arn            = aws_lambda_function.response_aggregator.arn

  depends_on = [
    aws_cloudwatch_event_rule.worker_response_rule,
    aws_lambda_function.response_aggregator
  ]
}

