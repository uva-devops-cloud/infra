provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = "StudentPortal"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  prefix              = "${var.prefix}-${var.environment}"

  tags = local.common_tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  vpc_id                 = module.networking.vpc_id
  private_subnet_a_id    = module.networking.private_subnet_id
  private_route_table_id = module.networking.private_route_table_id
  availability_zone      = var.availability_zone
  availability_zone_b    = var.availability_zone_b
  rds_security_group_id  = module.networking.rds_security_group_id
  account_id             = data.aws_caller_identity.current.account_id
  environment            = var.environment

  tags = local.common_tags
}

# S3 Bucket for Lambda Code
resource "aws_s3_bucket" "lambda_code" {
  bucket = "${var.prefix}-lambda-code-${data.aws_caller_identity.current.account_id}"

  tags = local.common_tags
}

# Lambda Compute Module
module "compute" {
  source = "../../modules/compute"

  prefix                   = var.prefix
  private_subnet_ids       = [module.networking.private_subnet_id, module.database.private_subnet_b_id]
  lambda_security_group_id = module.networking.lambda_security_group_id
  lambda_code_bucket       = aws_s3_bucket.lambda_code.bucket
  lambda_code_key_prefix   = "lambda-code/${var.environment}"

  # Database connection info
  db_secret_arn  = module.database.db_secret_arn
  db_secret_name = module.database.db_secret_name
  db_name        = module.database.db_name
  db_host        = module.database.db_address
  db_port        = module.database.db_port

  event_bus_name = module.events.event_bus_name
  event_bus_arn  = module.events.event_bus_arn

  tags = local.common_tags
}

# API Gateway Module
module "api" {
  source = "../../modules/api"

  prefix             = var.prefix
  lambda_functions   = module.compute.lambda_functions
  cors_allow_origins = ["*"] # For development, allow all origins

  tags = local.common_tags
}

# Identity Module (Cognito)
module "identity" {
  source = "../../modules/identity"

  prefix      = var.prefix
  environment = var.environment

  enable_google_auth   = true
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  // Link to API for JWT authorizer
  api_id = module.api.api_id

  callback_urls = [
    "http://localhost:3000/login",
    "https://${module.frontend.cloudfront_domain_name}/login"
  ]
  logout_urls = [
    "http://localhost:3000/",
    "https://${module.frontend.cloudfront_domain_name}/"
  ]

  tags = local.common_tags
}

# Frontend Module
module "frontend" {
  source = "../../modules/frontend"

  prefix      = var.prefix
  environment = var.environment

  create_streamlit = true
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_id
  ssh_public_key   = var.ssh_public_key

  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  prefix      = var.prefix
  environment = var.environment
  aws_region  = var.aws_region

  api_id = module.api.api_id

  lambda_function_names = [
    module.compute.lambda_functions.get_all_students.name,
    module.compute.lambda_functions.get_student_by_id.name,
    module.compute.lambda_functions.create_student.name,
    module.compute.lambda_functions.update_student.name,
    module.compute.lambda_functions.delete_student.name
  ]

  db_instance_id = module.database.db_instance_id

  create_sns_topic    = true
  email_notifications = ["admin@example.com"] // Replace with your email

  tags = local.common_tags
}

# Resource Explorer
resource "aws_resourceexplorer2_index" "explorer_index" {
  type = "LOCAL"
  tags = local.common_tags
}

resource "aws_resourceexplorer2_view" "explorer_view" {
  name       = "students-infra-view"
  depends_on = [aws_resourceexplorer2_index.explorer_index]
  tags       = local.common_tags
}

# Events Module
module "events" {
  source = "../../modules/events"

  prefix      = var.prefix
  environment = var.environment
  aws_region  = var.aws_region

  # Lambda function ARNs (you'll need to add these to your compute module)
  orchestrator_lambda_arn  = module.compute.orchestrator_lambda_arn
  orchestrator_lambda_name = module.compute.orchestrator_lambda_name

  student_data_lambda_arn  = module.compute.student_data_lambda_arn
  student_data_lambda_name = module.compute.student_data_lambda_name

  student_courses_lambda_arn  = module.compute.student_courses_lambda_arn
  student_courses_lambda_name = module.compute.student_courses_lambda_name

  update_profile_lambda_arn  = module.compute.update_profile_lambda_arn
  update_profile_lambda_name = module.compute.update_profile_lambda_name

  # VPC configuration
  create_vpc_endpoint = true
  vpc_id              = module.networking.vpc_id
  vpc_cidr            = var.vpc_cidr
  private_subnet_ids  = [module.networking.private_subnet_id]

  tags = local.common_tags
}

# Migrations Module
module "migrations" {
  source = "../../modules/migrations"

  prefix      = var.prefix
  environment = var.environment

  lambda_code_bucket     = aws_s3_bucket.lambda_code.bucket
  lambda_code_key_prefix = "lambda-code/${var.environment}"

  db_secret_arn = module.database.db_secret_arn
  db_name       = module.database.db_name

  vpc_config = {
    subnet_ids         = [module.networking.private_subnet_id]
    security_group_ids = [module.networking.lambda_security_group_id]
  }

  api_execution_arn = module.api.api_execution_arn

  tags = local.common_tags
}
