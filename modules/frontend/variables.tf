variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "studentportal"
}

variable "environment" {
  description = "Environment name (dev, prod, etc)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100" # Use PriceClass_All for global distribution
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (optional)"
  type        = string
  default     = null
}

variable "domain_names" {
  description = "List of custom domain names (optional)"
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Route53 hosted zone ID for domain (optional)"
  type        = string
  default     = null
}

variable "create_streamlit" {
  description = "Whether to create a Streamlit instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC for Streamlit resources"
  type        = string
  default     = null
}

variable "public_subnet_id" {
  description = "ID of the public subnet for the Streamlit instance"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 instance access"
  type        = string
  default     = ""
}

variable "streamlit_instance_type" {
  description = "Instance type for Streamlit EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "streamlit_ami_id" {
  description = "AMI ID for Streamlit EC2 instance"
  type        = string
  default     = "ami-0eb260c4d5475b901" # Amazon Linux 2023 AMI
}
