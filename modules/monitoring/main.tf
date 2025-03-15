# ------------------------------------------------------------------------------
# CloudWatch Dashboard
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.prefix}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", var.api_id, { "stat" : "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "API Requests"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiId", var.api_id, { "stat" : "Sum" }],
            ["AWS/ApiGateway", "5XXError", "ApiId", var.api_id, { "stat" : "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "API Errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names[0], { "stat" : "Sum" }],
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names[1], { "stat" : "Sum" }],
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names[2], { "stat" : "Sum" }],
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names[3], { "stat" : "Sum" }],
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names[4], { "stat" : "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Invocations"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names[0], { "stat" : "Sum" }],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names[1], { "stat" : "Sum" }],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names[2], { "stat" : "Sum" }],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names[3], { "stat" : "Sum" }],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names[4], { "stat" : "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_id, { "stat" : "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "RDS CPU Utilization"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_instance_id, { "stat" : "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "RDS Free Storage Space"
          period  = 300
        }
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# CloudWatch Alarms
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "api_error_rate" {
  alarm_name          = "${var.prefix}-${var.environment}-api-error-rate-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.api_5xx_error_threshold
  alarm_description   = "This metric monitors API Gateway 5XX errors"

  dimensions = {
    ApiId = var.api_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {

  alarm_name          = "${var.prefix}-${var.environment}-lambda-error-rate-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  alarm_description   = "This metric monitors Lambda function errors"

  dimensions = {
    FunctionName = var.lambda_function_names[0] # Just monitor the first function as an example
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {

  alarm_name          = "${var.prefix}-${var.environment}-rds-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

# ------------------------------------------------------------------------------
# SNS Topic for Alarms (Optional)
# ------------------------------------------------------------------------------

resource "aws_sns_topic" "alerts" {

  name = "${var.prefix}-${var.environment}-alerts-topic"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_notifications[0]
}

# ------------------------------------------------------------------------------
# EventBridge Rule for Scheduled Health Checks (Optional)
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "health_check" {

  name                = "${var.prefix}-${var.environment}-health-check"
  description         = "Scheduled health check for the application"
  schedule_expression = var.health_check_schedule

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "health_check_lambda" {

  rule = aws_cloudwatch_event_rule.health_check.name
  arn  = var.health_check_lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.health_check_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.health_check.arn
}
