output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "alarms" {
  description = "Map of CloudWatch alarm details"
  value = {
    api_error_rate = {
      name = aws_cloudwatch_metric_alarm.api_error_rate.alarm_name
      arn  = aws_cloudwatch_metric_alarm.api_error_rate.arn
    }
    lambda_error_rate = length(var.lambda_function_names) > 0 ? {
      name = aws_cloudwatch_metric_alarm.lambda_error_rate[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.lambda_error_rate[0].arn
    } : null
    rds_cpu_utilization = var.db_instance_id != "" ? {
      name = aws_cloudwatch_metric_alarm.rds_cpu_utilization[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.rds_cpu_utilization[0].arn
    } : null
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms (if created)"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].arn : null
}

output "health_check_rule" {
  description = "Details of the health check EventBridge rule (if created)"
  value = var.create_health_check_rule ? {
    name = aws_cloudwatch_event_rule.health_check[0].name
    arn  = aws_cloudwatch_event_rule.health_check[0].arn
  } : null
}
