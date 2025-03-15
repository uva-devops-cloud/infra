provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = "StudentPortal"
    Environment = "prod"
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
  prefix              = "${var.prefix}-prod"

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
  environment            = "prod"
  db_instance_class      = "db.t3.small" # Larger instance for production

  tags = local.common_tags
}

# S3 Bucket for Lambda Code
resource "aws_s3_bucket" "lambda_code" {
  bucket = "${var.prefix}-lambda-code-prod-${data.aws_caller_identity.current.account_id}"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lambda Compute Module
module "compute" {
  source = "../../modules/compute"

  prefix                   = "${var.prefix}-prod"
  private_subnet_ids       = [module.networking.private_subnet_id, module.database.private_subnet_b_id]
  lambda_security_group_id = module.networking.lambda_security_group_id
  lambda_code_bucket       = aws_s3_bucket.lambda_code.bucket
  lambda_code_key_prefix   = "lambda-code"

  # Production-specific settings
  lambda_memory_size = 512
  lambda_timeout     = 60

  # Database connection info
  db_secret_arn  = module.database.db_secret_arn
  db_secret_name = module.database.db_secret_name
  db_name        = module.database.db_name
  db_host        = module.database.db_address
  db_port        = module.database.db_port

  tags = local.common_tags
}

# API Gateway Module
module "api" {
  source = "../../modules/api"

  prefix           = "${var.prefix}-prod"
  lambda_functions = module.compute.lambda_functions
  api_stage_name   = "api"

  # Production CORS settings - restrict to your domain
  cors_allow_origins = var.api_cors_allowed_origins

  log_retention_days = 90 # Longer retention for production logs

  tags = local.common_tags
}

# Identity Module (Cognito)
module "identity" {
  source = "../../modules/identity"

  prefix      = var.prefix
  environment = "prod"

  # Production callback URLs - update with your domain
  callback_urls = concat(
    ["https://${module.frontend.cloudfront_domain_name}/login"],
    var.additional_callback_urls
  )

  logout_urls = concat(
    ["https://${module.frontend.cloudfront_domain_name}/"],
    var.additional_logout_urls
  )

  # Enable identity pool for production
  create_identity_pool = true

  tags = local.common_tags
}

# Frontend Module with Streamlit
module "frontend" {
  source = "../../modules/frontend"

  prefix      = var.prefix
  environment = "prod"

  # Production settings
  cloudfront_price_class = "PriceClass_All" # Global distribution

  # Production custom domain (if available)
  domain_names        = var.frontend_domain_names
  acm_certificate_arn = var.frontend_certificate_arn
  zone_id             = var.route53_zone_id

  # Streamlit configuration
  create_streamlit        = true
  vpc_id                  = module.networking.vpc_id
  public_subnet_id        = module.networking.public_subnet_id
  ssh_public_key          = var.ssh_public_key
  streamlit_instance_type = "t3.small" # Slightly bigger instance for production

  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  prefix      = "${var.prefix}-prod"
  environment = "prod"
  aws_region  = var.aws_region

  # API Gateway monitoring
  api_id                  = module.api.api_id
  api_5xx_error_threshold = 2 # Stricter threshold for production

  # Lambda monitoring
  lambda_function_names = [
    module.compute.lambda_functions.get_all_students.name,
    module.compute.lambda_functions.get_student_by_id.name,
    module.compute.lambda_functions.create_student.name,
    module.compute.lambda_functions.update_student.name,
    module.compute.lambda_functions.delete_student.name
  ]
  lambda_error_threshold = 1

  # RDS monitoring
  db_instance_id    = module.database.db_instance_id
  rds_cpu_threshold = 70 # Lower threshold to alert earlier

  # Production notifications
  create_sns_topic    = true
  email_notifications = var.alert_email_addresses

  # Health checks
  create_health_check_rule = true
  health_check_schedule    = "rate(1 minute)" # More frequent for production

  tags = local.common_tags
}

# Resource Explorer for production resources
resource "aws_resourceexplorer2_index" "explorer_index" {
  type = "LOCAL"
  tags = local.common_tags
}

resource "aws_resourceexplorer2_view" "explorer_view" {
  name       = "${var.prefix}-prod-view"
  depends_on = [aws_resourceexplorer2_index.explorer_index]
  tags       = local.common_tags
}
