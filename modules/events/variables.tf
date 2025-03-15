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

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPC endpoints"
  type        = list(string)
  default     = []
}

# Lambda Function ARNs
variable "orchestrator_lambda_arn" {
  description = "ARN of the orchestrator Lambda function"
  type        = string
  default     = null
}

variable "orchestrator_lambda_name" {
  description = "Name of the orchestrator Lambda function"
  type        = string
  default     = null
}

variable "student_data_lambda_arn" {
  description = "ARN of the student data Lambda function"
  type        = string
  default     = null
}

variable "student_data_lambda_name" {
  description = "Name of the student data Lambda function"
  type        = string
  default     = null
}

variable "student_courses_lambda_arn" {
  description = "ARN of the student courses Lambda function"
  type        = string
  default     = null
}

variable "student_courses_lambda_name" {
  description = "Name of the student courses Lambda function"
  type        = string
  default     = null
}

variable "update_profile_lambda_arn" {
  description = "ARN of the update profile Lambda function"
  type        = string
  default     = null
}

variable "update_profile_lambda_name" {
  description = "Name of the update profile Lambda function"
  type        = string
  default     = null
}
