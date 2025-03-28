variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "google_client_id" {
  type      = string
  sensitive = true
  default   = "790428310125-ecad52ggpandpmk422ihp7gqsrruh27u.apps.googleusercontent.com"
}
variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-2a"
}

variable "availability_zone_b" {
  type    = string
  default = "eu-west-2b"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "environment" {
  type = string
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 instance access"
  type        = string
  sensitive   = true  # Mark as sensitive
}

variable "llm_endpoint" {
  type    = string
  default = "https://api.openai.com/v1/chat/completions"
}
