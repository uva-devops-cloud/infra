provider "aws" {
  region = "eu-west-2"
}

resource "aws_resourceexplorer2_index" "example" {
  type = "LOCAL"
}

resource "aws_resourceexplorer2_view" "example_view" {
  index_arn = aws_resourceexplorer2_index.example.arn
  name      = "students-infra-view"
}

# API Gateway (for Lambda endpoints)
resource "aws_apigatewayv2_api" "api" {
  name          = "students-api"
  protocol_type = "HTTP"
}
