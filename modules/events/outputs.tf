output "event_bus_name" {
  description = "Name of the EventBridge event bus"
  value       = aws_cloudwatch_event_bus.main.name
}

output "event_bus_arn" {
  description = "ARN of the EventBridge event bus"
  value       = aws_cloudwatch_event_bus.main.arn
}

output "student_query_rule_arn" {
  description = "ARN of the student query event rule"
  value       = aws_cloudwatch_event_rule.student_query.arn
}

output "fetch_student_data_rule_arn" {
  description = "ARN of the fetch student data event rule"
  value       = aws_cloudwatch_event_rule.fetch_student_data.arn
}

output "fetch_student_courses_rule_arn" {
  description = "ARN of the fetch student courses event rule"
  value       = aws_cloudwatch_event_rule.fetch_student_courses.arn
}

output "update_profile_rule_arn" {
  description = "ARN of the update profile event rule"
  value       = aws_cloudwatch_event_rule.update_profile.arn
}

output "vpc_endpoint_id" {
  description = "ID of the EventBridge VPC endpoint (if created)"
  value       = var.create_vpc_endpoint ? aws_vpc_endpoint.eventbridge[0].id : null
}

output "vpc_endpoint_dns" {
  description = "DNS entries of the EventBridge VPC endpoint (if created)"
  value       = var.create_vpc_endpoint ? aws_vpc_endpoint.eventbridge[0].dns_entry : null
}

output "eventbridge_security_group_id" {
  description = "ID of the EventBridge VPC endpoint security group (if created)"
  value       = var.create_vpc_endpoint ? aws_security_group.eventbridge_endpoint[0].id : null
}
