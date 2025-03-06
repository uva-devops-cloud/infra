provider "aws" {
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {}

resource "aws_resourceexplorer2_index" "explorer_index" {
  type = "LOCAL"
}

resource "aws_resourceexplorer2_view" "explorer_view" {
  name       = "students-infra-view"
  depends_on = [aws_resourceexplorer2_index.explorer_index]
}

# API Gateway (for Lambda endpoints)
resource "aws_apigatewayv2_api" "api" {
  name          = "students-api"
  protocol_type = "HTTP"
}