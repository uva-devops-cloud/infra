terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-686255942173"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
  }
}