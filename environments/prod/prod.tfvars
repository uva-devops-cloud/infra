# AWS Region
aws_region = "eu-west-2"

# Network Configuration
vpc_cidr            = "10.0.0.0/16"
availability_zone   = "eu-west-2a"
availability_zone_b = "eu-west-2b"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# API Configuration
api_cors_allowed_origins = [
  "https://app.studentportal.com",
  "https://www.studentportal.com"
]

# Optional Frontend Domain Configuration
#frontend_domain_names = ["app.studentportal.com"]
#frontend_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef..."
#route53_zone_id = "Z1234567890ABC"

# Alert Configuration
alert_email_addresses = [
  "admin@example.com",
  "devops@example.com"
]
