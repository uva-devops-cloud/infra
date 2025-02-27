variable "aws_region" {
  default = "eu-west-2"
}
variable "google_client_id" {
  default = "869761900348-727b907c90lujsv684jocjprtkjj8vr2.apps.googleusercontent.com "
}
variable "google_client_secret" {
  default = "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"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = "euw2-az1"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}
