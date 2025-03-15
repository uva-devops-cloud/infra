# ------------------------------------------------------------------------------
# EventBridge Event Bus
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.prefix}-${var.environment}-event-bus"
  tags = var.tags
}

# ------------------------------------------------------------------------------
# VPC Endpoints for EventBridge (if requested)
# ------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "eventbridge" {
  count = var.create_vpc_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.events"
  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    aws_security_group.eventbridge_endpoint[0].id
  ]

  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${var.environment}-eventbridge-endpoint"
    }
  )
}

resource "aws_security_group" "eventbridge_endpoint" {
  count = var.create_vpc_endpoint ? 1 : 0

  name        = "${var.prefix}-${var.environment}-eventbridge-endpoint-sg"
  description = "Security group for EventBridge VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${var.environment}-eventbridge-endpoint-sg"
    }
  )
}

# ------------------------------------------------------------------------------
# Student Query Event Rules
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "student_query" {
  name           = "${var.prefix}-${var.environment}-student-query-rule"
  description    = "Rule to process student queries"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  # Update to match original pattern
  event_pattern = jsonencode({
    source      = ["student.query.api"], # Original source
    detail-type = ["StudentQuery"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "orchestrator" {
  count          = var.orchestrator_lambda_arn != null ? 1 : 0
  rule           = aws_cloudwatch_event_rule.student_query.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "OrchestratorTarget"
  arn            = var.orchestrator_lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge_orchestrator" {
  count         = var.orchestrator_lambda_arn != null && var.orchestrator_lambda_name != null ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.orchestrator_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.student_query.arn
}

# ------------------------------------------------------------------------------
# Student Data Event Rules
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "fetch_student_data" {
  name           = "${var.prefix}-${var.environment}-fetch-student-data-rule"
  description    = "Rule to fetch student data"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  # Update to match original pattern
  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"], # Original source
    detail-type = ["FetchStudentData"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "fetch_student_data" {
  count          = var.student_data_lambda_arn != null ? 1 : 0
  rule           = aws_cloudwatch_event_rule.fetch_student_data.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "FetchStudentDataTarget"
  arn            = var.student_data_lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge_student_data" {
  count         = var.student_data_lambda_arn != null && var.student_data_lambda_name != null ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.student_data_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fetch_student_data.arn
}

# ------------------------------------------------------------------------------
# Student Courses Event Rules
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "fetch_student_courses" {
  name           = "${var.prefix}-${var.environment}-fetch-student-courses-rule"
  description    = "Rule to fetch student courses"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  # Update to match original pattern
  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"], # Original source
    detail-type = ["FetchStudentCourses"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "fetch_student_courses" {
  count          = var.student_courses_lambda_arn != null ? 1 : 0
  rule           = aws_cloudwatch_event_rule.fetch_student_courses.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "FetchStudentCoursesTarget"
  arn            = var.student_courses_lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge_student_courses" {
  count         = var.student_courses_lambda_arn != null && var.student_courses_lambda_name != null ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.student_courses_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fetch_student_courses.arn
}

# ------------------------------------------------------------------------------
# Profile Update Event Rules
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "update_profile" {
  name           = "${var.prefix}-${var.environment}-update-profile-rule"
  description    = "Rule to update student profile"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["studentportal.profile"],
    detail-type = ["UpdateProfile"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "update_profile" {
  count          = var.update_profile_lambda_arn != null ? 1 : 0
  rule           = aws_cloudwatch_event_rule.update_profile.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "UpdateProfileTarget"
  arn            = var.update_profile_lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge_update_profile" {
  count         = var.update_profile_lambda_arn != null && var.update_profile_lambda_name != null ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.update_profile_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.update_profile.arn
}
