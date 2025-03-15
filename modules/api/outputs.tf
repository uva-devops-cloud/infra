output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.student_api.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway stage"
  value       = aws_apigatewayv2_stage.student_api.invoke_url
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_apigatewayv2_api.student_api.arn
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.student_api.execution_arn
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.student_api.execution_arn
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_apigatewayv2_stage.student_api.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for API Gateway"
  value       = aws_cloudwatch_log_group.api_logs.arn
}

output "routes" {
  description = "Map of API Gateway route details"
  value = {
    get_all_students  = aws_apigatewayv2_route.get_all_students.id
    get_student_by_id = aws_apigatewayv2_route.get_student_by_id.id
    create_student    = aws_apigatewayv2_route.create_student.id
    update_student    = aws_apigatewayv2_route.update_student.id
    delete_student    = aws_apigatewayv2_route.delete_student.id
  }
}
