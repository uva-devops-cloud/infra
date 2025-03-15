variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-2"
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "studentportal"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Primary availability zone"
  type        = string
  default     = "eu-west-2a"
}

variable "availability_zone_b" {
  description = "Secondary availability zone"
  type        = string
  default     = "eu-west-2b"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "google_client_id" {
  description = "Google OAuth client ID for authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "google_client_secret" {
  description = "Google OAuth client secret for authentication"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 instance access"
  type        = string
  sensitive   = true
}

variable "api_cors_allowed_origins" {
  description = "List of allowed origins for API CORS configuration"
  type        = list(string)
  default     = ["https://app.studentportal.com"]
}

variable "additional_callback_urls" {
  description = "Additional callback URLs for Cognito"
  type        = list(string)
  default     = []
}

variable "additional_logout_urls" {
  description = "Additional logout URLs for Cognito"
  type        = list(string)
  default     = []
}

variable "frontend_domain_names" {
  description = "List of custom domain names for CloudFront"
  type        = list(string)
  default     = []
}

variable "frontend_certificate_arn" {
  description = "ARN of ACM certificate for CloudFront"
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for domain"
  type        = string
  default     = null
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = ["admin@example.com"]
}

variable "environment" {
  type    = string
  default = "dev"
}
