# Frontend Module

This module creates resources for hosting the frontend web application for the StudentPortal.

## Resources Created

- S3 bucket for static website content
- CloudFront distribution for content delivery
- CloudFront Origin Access Identity for secure S3 access
- S3 bucket policy for CloudFront access
- Optional Route53 records for custom domains

## Usage

```terraform
module "frontend" {
  source = "../modules/frontend"

  prefix      = "studentportal"
  environment = "dev"

  # Optional parameters
  cloudfront_price_class = "PriceClass_100" # default, use PriceClass_All for global distribution

  # For custom domain (optional)
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef..."
  domain_names        = ["app.example.com"]
  zone_id             = "Z1234567890ABC"

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
