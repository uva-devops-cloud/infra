variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "studentportal"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zone" {
  description = "Primary availability zone"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
