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
