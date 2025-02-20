terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
  }
}

data "aws_caller_identity" "current" {}