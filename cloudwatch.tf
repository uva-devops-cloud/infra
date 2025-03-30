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

# CloudWatch Alarms for Lambda Functions

# Error Rate Alarms for Worker Lambdas
resource "aws_cloudwatch_metric_alarm" "get_student_data_errors" {
  alarm_name          = "get-student-data-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300" # 5 minutes
  statistic           = "Sum"
  threshold           = "5" # Alert if more than 5 errors in 5 minutes
  alarm_description   = "This metric monitors error rate for Get Student Data Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_student_data.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "get_student_courses_errors" {
  alarm_name          = "get-student-courses-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Get Student Courses Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_student_courses.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Get Program Details Lambda
resource "aws_cloudwatch_metric_alarm" "get_program_details_errors" {
  alarm_name          = "get-program-details-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Get Program Details Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_program_details.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Get Course Details Lambda
resource "aws_cloudwatch_metric_alarm" "get_course_details_errors" {
  alarm_name          = "get-course-details-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Get Course Details Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_course_details.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Get Enrollment Status Lambda
resource "aws_cloudwatch_metric_alarm" "get_enrollment_status_errors" {
  alarm_name          = "get-enrollment-status-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Get Enrollment Status Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_enrollment_status.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Get Usage Info Lambda
resource "aws_cloudwatch_metric_alarm" "get_usage_info_errors" {
  alarm_name          = "get-usage-info-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Get Usage Info Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_usage_info.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Update Profile Lambda
resource "aws_cloudwatch_metric_alarm" "update_profile_errors" {
  alarm_name          = "update-profile-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Update Profile Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.update_profile.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Hello World Lambda
resource "aws_cloudwatch_metric_alarm" "hello_world_errors" {
  alarm_name          = "hello-world-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Hello World Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.hello_world.function_name
  }

  tags = local.common_tags
}

# Duration Alarms for Worker Lambdas
resource "aws_cloudwatch_metric_alarm" "get_student_data_duration" {
  alarm_name          = "get-student-data-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (Lambda timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Get Student Data Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_student_data.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "get_student_courses_duration" {
  alarm_name          = "get-student-courses-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000"
  alarm_description   = "This metric monitors execution duration for Get Student Courses Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_student_courses.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Get Program Details Lambda
resource "aws_cloudwatch_metric_alarm" "get_program_details_duration" {
  alarm_name          = "get-program-details-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Get Program Details Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_program_details.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Get Course Details Lambda
resource "aws_cloudwatch_metric_alarm" "get_course_details_duration" {
  alarm_name          = "get-course-details-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Get Course Details Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_course_details.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Get Enrollment Status Lambda
resource "aws_cloudwatch_metric_alarm" "get_enrollment_status_duration" {
  alarm_name          = "get-enrollment-status-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Get Enrollment Status Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_enrollment_status.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Get Usage Info Lambda
resource "aws_cloudwatch_metric_alarm" "get_usage_info_duration" {
  alarm_name          = "get-usage-info-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Get Usage Info Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.get_usage_info.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Update Profile Lambda
resource "aws_cloudwatch_metric_alarm" "update_profile_duration" {
  alarm_name          = "update-profile-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Update Profile Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.update_profile.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Hello World Lambda
resource "aws_cloudwatch_metric_alarm" "hello_world_duration" {
  alarm_name          = "hello-world-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "8000" # 8 seconds (timeout is 10s)
  alarm_description   = "This metric monitors execution duration for Hello World Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.hello_world.function_name
  }

  tags = local.common_tags
}

# Error Rate Alarms for Orchestrator Lambdas
resource "aws_cloudwatch_metric_alarm" "query_intake_errors" {
  alarm_name          = "query-intake-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Query Intake Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.query_intake.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "llm_query_analyzer_errors" {
  alarm_name          = "llm-query-analyzer-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for LLM Query Analyzer Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.llm_query_analyzer.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "answer_generator_errors" {
  alarm_name          = "answer-generator-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Answer Generator Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.answer_generator.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Worker Dispatcher Lambda
resource "aws_cloudwatch_metric_alarm" "worker_dispatcher_errors" {
  alarm_name          = "worker-dispatcher-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Worker Dispatcher Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.worker_dispatcher.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Response Aggregator Lambda
resource "aws_cloudwatch_metric_alarm" "response_aggregator_errors" {
  alarm_name          = "response-aggregator-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Response Aggregator Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.response_aggregator.function_name
  }

  tags = local.common_tags
}

# Error Alarm for Query Status Lambda
resource "aws_cloudwatch_metric_alarm" "query_status_errors" {
  alarm_name          = "query-status-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for Query Status Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.query_status.function_name
  }

  tags = local.common_tags
}

# Error Alarm for User Data Generator Lambda
resource "aws_cloudwatch_metric_alarm" "user_data_generator_errors" {
  alarm_name          = "user-data-generator-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate for User Data Generator Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.user_data_generator.function_name
  }

  tags = local.common_tags
}

# Duration Alarms for Orchestrator Lambdas
resource "aws_cloudwatch_metric_alarm" "query_intake_duration" {
  alarm_name          = "query-intake-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "55000" # 55 seconds (Lambda timeout is 60s)
  alarm_description   = "This metric monitors execution duration for Query Intake Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.query_intake.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "llm_query_analyzer_duration" {
  alarm_name          = "llm-query-analyzer-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "110000" # 110 seconds (Lambda timeout is 120s)
  alarm_description   = "This metric monitors execution duration for LLM Query Analyzer Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.llm_query_analyzer.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "answer_generator_duration" {
  alarm_name          = "answer-generator-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "110000" # 110 seconds (Lambda timeout is 120s)
  alarm_description   = "This metric monitors execution duration for Answer Generator Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.answer_generator.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Worker Dispatcher Lambda
resource "aws_cloudwatch_metric_alarm" "worker_dispatcher_duration" {
  alarm_name          = "worker-dispatcher-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "110000" # 110 seconds (timeout is 120s)
  alarm_description   = "This metric monitors execution duration for Worker Dispatcher Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.worker_dispatcher.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Response Aggregator Lambda
resource "aws_cloudwatch_metric_alarm" "response_aggregator_duration" {
  alarm_name          = "response-aggregator-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "110000" # 110 seconds (timeout is 120s)
  alarm_description   = "This metric monitors execution duration for Response Aggregator Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.response_aggregator.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for Query Status Lambda
resource "aws_cloudwatch_metric_alarm" "query_status_duration" {
  alarm_name          = "query-status-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000" # 25 seconds (timeout is 30s)
  alarm_description   = "This metric monitors execution duration for Query Status Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.query_status.function_name
  }

  tags = local.common_tags
}

# Duration Alarm for User Data Generator Lambda
resource "aws_cloudwatch_metric_alarm" "user_data_generator_duration" {
  alarm_name          = "user-data-generator-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "55000" # 55 seconds (timeout is 60s)
  alarm_description   = "This metric monitors execution duration for User Data Generator Lambda"
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.user_data_generator.function_name
  }

  tags = local.common_tags
}

# SNS Topic for Lambda Alerts
resource "aws_sns_topic" "lambda_alerts" {
  name = "lambda-alerts"

  tags = local.common_tags
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "lambda_alerts_policy" {
  arn = aws_sns_topic.lambda_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.lambda_alerts.arn
      }
    ]
  })
}
