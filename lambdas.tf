# Lambda functions for the student query system

# Orchestrator Lambda (Public Subnet)
resource "aws_lambda_function" "orchestrator" {
  function_name = "student-query-orchestrator"
  role          = aws_iam_role.orchestrator_lambda_role.arn

  # Use a minimal dummy file
  filename = "${path.module}/dummy_lambda.zip"
  handler  = "index.handler"
  runtime  = "nodejs18.x"

  # Other configuration...
  timeout     = 60
  memory_size = 256

  vpc_config {
    subnet_ids         = [aws_subnet.public.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.orchestrator_policy_attachment,
    aws_security_group.lambda_sg,
    aws_subnet.public
  ]

  tags = local.common_tags
}

resource "aws_lambda_permission" "api_gateway_orchestrator" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orchestrator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  depends_on = [
    aws_lambda_function.orchestrator,
    aws_api_gateway_rest_api.api
  ]
}

# Worker Lambda functions (in Private Subnet)
# resource "aws_lambda_function" "get_student_degree" {
#   function_name = "get-student-degree"
#   # Rest of configuration...
# }

# Additional worker Lambda functions here...
