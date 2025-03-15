variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "studentportal"
}

variable "environment" {
  description = "Environment name (dev, prod, etc)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# API Gateway
variable "api_id" {
  description = "ID of the API Gateway"
  type        = string
}

variable "api_5xx_error_threshold" {
  description = "Threshold for API Gateway 5XX error alarm"
  type        = number
  default     = 5
}

# Lambda Functions
variable "lambda_function_names" {
  description = "List of Lambda function names to monitor"
  type        = list(string)
  default     = []
}

variable "lambda_error_threshold" {
  description = "Threshold for Lambda error alarm"
  type        = number
  default     = 1
}

# RDS
variable "db_instance_id" {
  description = "ID of the RDS instance to monitor"
  type        = string
  default     = ""
}

variable "rds_cpu_threshold" {
  description = "Threshold for RDS CPU utilization alarm"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm transitions to ALARM state"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm transitions to OK state"
  type        = list(string)
  default     = []
}

variable "email_notifications" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  default     = ["merlijn.van.uden@student.uva.nl"]
}
