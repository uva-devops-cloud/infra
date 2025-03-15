# ------------------------------------------------------------------------------
# Cognito User Pool
# ------------------------------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = "${var.prefix}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Schema attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }

  # Account recovery setting
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Google Identity Provider
# ------------------------------------------------------------------------------

resource "aws_cognito_identity_provider" "google" {

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "email profile openid"
  }

  attribute_mapping = {
    email       = "email"
    name        = "name"
    given_name  = "given_name"
    family_name = "family_name"
  }
}

# ------------------------------------------------------------------------------
# Cognito App Client
# ------------------------------------------------------------------------------

resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.prefix}-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret        = false
  refresh_token_validity = 30
  access_token_validity  = 1
  id_token_validity      = 1
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Include Google in identity providers if enabled
  supported_identity_providers = var.enable_google_auth ? ["COGNITO", "Google"] : ["COGNITO"]

  depends_on = [aws_cognito_identity_provider.google]
}

# ------------------------------------------------------------------------------
# Cognito Domain
# ------------------------------------------------------------------------------

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.prefix}-${var.environment}-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ------------------------------------------------------------------------------
# HTTP API JWT Authorizer (if API ID provided)
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_authorizer" "cognito" {

  api_id           = var.api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.prefix}-cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.web_client.id]
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

# ------------------------------------------------------------------------------
# Cognito Identity Pool (optional)
# ------------------------------------------------------------------------------

resource "aws_cognito_identity_pool" "main" {

  identity_pool_name               = "${var.prefix}-identity-pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web_client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# IAM Roles for Identity Pool (if created)
# ------------------------------------------------------------------------------

resource "aws_iam_role" "authenticated" {

  name = "${var.prefix}-cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "authenticated_policy" {

  name        = "${var.prefix}-cognito-authenticated-policy"
  description = "Policy for Cognito authenticated users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cognito-sync:*",
          "cognito-identity:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "authenticated_attach" {

  role       = aws_iam_role.authenticated.name
  policy_arn = aws_iam_policy.authenticated_policy.arn
}

# ------------------------------------------------------------------------------
# Identity Pool Role Attachment (if identity pool created)
# ------------------------------------------------------------------------------

resource "aws_cognito_identity_pool_roles_attachment" "main" {

  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}
