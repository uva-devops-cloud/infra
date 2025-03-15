# Identity Module

This module creates authentication and authorization resources for the StudentPortal application using AWS Cognito.

## Resources Created

- Cognito User Pool with email authentication
- Cognito User Pool Client for web applications
- Cognito domain for hosted UI
- Optional Cognito Identity Pool with authenticated role
- IAM roles and policies for authenticated users (when identity pool is created)

## Usage

```terraform
module "identity" {
  source = "../modules/identity"

  prefix      = "studentportal"
  environment = "dev"

  # Optional parameters
  callback_urls = ["http://localhost:3000", "https://myapp.example.com"]
  logout_urls   = ["http://localhost:3000", "https://myapp.example.com"]
  create_identity_pool = false # default

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
