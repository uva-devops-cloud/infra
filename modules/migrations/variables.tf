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

# S3 configuration
variable "create_bucket" {
  description = "Whether to create a new S3 bucket for migrations"
  type        = bool
  default     = true
}

variable "existing_bucket_name" {
  description = "Name of an existing S3 bucket for migrations (if create_bucket is false)"
  type        = string
  default     = null
}

# Lambda configuration
variable "lambda_code_bucket" {
  description = "S3 bucket containing Lambda code package"
  type        = string
}

variable "lambda_code_key_prefix" {
  description = "S3 key prefix for Lambda code package"
  type        = string
  default     = "lambda"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 60
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch Logs"
  type        = number
  default     = 14
}

# VPC configuration
variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# Database configuration
variable "db_secret_arn" {
  description = "ARN of the secret containing database credentials"
  type        = string
  default     = null
}

variable "db_name" {
  description = "Name of the database to run migrations on"
  type        = string
}

# Trigger configuration
variable "enable_s3_trigger" {
  description = "Whether to enable automatic triggering of the Lambda when files are uploaded to S3"
  type        = bool
  default     = true
}

variable "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
  default     = null
}
