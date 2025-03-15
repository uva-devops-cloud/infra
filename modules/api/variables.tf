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

variable "api_stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "v1"
}

variable "cors_allow_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "lambda_functions" {
  description = "Map of Lambda function details"
  type = object({
    get_all_students = object({
      name       = string
      arn        = string
      invoke_arn = string
      version    = string
    })
    get_student_by_id = object({
      name       = string
      arn        = string
      invoke_arn = string
      version    = string
    })
    create_student = object({
      name       = string
      arn        = string
      invoke_arn = string
      version    = string
    })
    update_student = object({
      name       = string
      arn        = string
      invoke_arn = string
      version    = string
    })
    delete_student = object({
      name       = string
      arn        = string
      invoke_arn = string
      version    = string
    })
  })
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "jwt_authorizer_id" {
  description = "ID of the JWT authorizer"
  type        = string
  default     = null
}

variable "migration_lambda_arn" {
  description = "ARN of the database migration Lambda function"
  type        = string
  default     = null
}
