provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = "StudentPortal"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  tags = local.common_tags
}

resource "aws_resourceexplorer2_index" "explorer_index" {
  type = "LOCAL"

  tags = local.common_tags

}

resource "aws_resourceexplorer2_view" "explorer_view" {
  name       = "students-infra-view"
  depends_on = [aws_resourceexplorer2_index.explorer_index]

  tags = local.common_tags

}

# API Gateway (for Lambda endpoints)
resource "aws_apigatewayv2_api" "api" {
  name          = "students-api"
  protocol_type = "HTTP"

  tags = local.common_tags
}

