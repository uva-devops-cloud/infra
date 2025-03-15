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

variable "callback_urls" {
  description = "List of allowed callback URLs for the identity provider"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the identity provider"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "enable_google_auth" {
  description = "Whether to enable Google as an identity provider"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Client ID for Google identity provider"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Client secret for Google identity provider"
  type        = string
  default     = ""
  sensitive   = true
}

variable "api_id" {
  description = "ID of the API Gateway to create JWT authorizer for"
  type        = string
  default     = null
}
