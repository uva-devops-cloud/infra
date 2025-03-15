variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "studentportal"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions in MB"
  type        = number
  default     = 256
}

variable "lambda_code_bucket" {
  description = "S3 bucket containing Lambda function code"
  type        = string
}

variable "lambda_code_key_prefix" {
  description = "S3 key prefix for Lambda function code"
  type        = string
  default     = "lambda"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  type        = string
}

variable "db_secret_name" {
  description = "Name of the database secret in Secrets Manager"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
  default     = "5432"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

# Event Bridge configuration
variable "event_bus_name" {
  description = "Name of the EventBridge event bus"
  type        = string
  default     = null
}

variable "event_bus_arn" {
  description = "ARN of the EventBridge event bus"
  type        = string
  default     = null
}

# LLM API configuration
variable "llm_api_key_secret_arn" {
  description = "ARN of the secret containing LLM API key"
  type        = string
  default     = null
}

variable "llm_api_key" {
  description = "LLM API key (if creating a secret)"
  type        = string
  default     = null
  sensitive   = true
}

# Orchestrator specific settings
variable "orchestrator_timeout" {
  description = "Timeout for orchestrator Lambda function in seconds"
  type        = number
  default     = 60
}

variable "orchestrator_memory_size" {
  description = "Memory size for orchestrator Lambda function in MB"
  type        = number
  default     = 256
}
