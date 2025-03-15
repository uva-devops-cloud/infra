variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_a_id" {
  description = "ID of the first private subnet"
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Primary availability zone"
  type        = string
}

variable "availability_zone_b" {
  description = "Secondary availability zone"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of the private route table"
  type        = string
}

variable "rds_security_group_id" {
  description = "ID of the security group for RDS"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
