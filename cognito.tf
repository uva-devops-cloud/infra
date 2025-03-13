##################################
#  COGNITO USER POOL (STUDENTS)  #
##################################
resource "aws_cognito_user_pool" "students" {
  name                     = "students-user-pool"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
    require_lowercase = true
  }

  schema { // Update to FirstName, LastName depending on DB
    attribute_data_type = "String"
    name                = "name"
    required            = true
    mutable             = true
  }

  tags = local.common_tags

}

################################################
#  COGNITO USER POOL DOMAIN (HOSTED UI OPTION) #
################################################
resource "aws_cognito_user_pool_domain" "student_login_domain" {
  domain       = "studentportal-${data.aws_caller_identity.current.account_id}" // valid: using hyphens
  user_pool_id = aws_cognito_user_pool.students.id
}

#################################
#  GOOGLE IDENTITY PROVIDER     #
#################################
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.students.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "email profile openid"
  }

  attribute_mapping = {
    email = "email"
    name  = "name"
  }
}

###################################
#   COGNITO USER POOL CLIENT      #
###################################
resource "aws_cognito_user_pool_client" "students_client" {
  name         = "students-frontend-client"
  user_pool_id = aws_cognito_user_pool.students.id

  # The flows you want to allow
  allowed_oauth_flows = [
    "code", # Use Authorization Code flow for Hosted UI
    "implicit"
  ]
  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]
  supported_identity_providers = [
    "COGNITO", # Default Cognito-based (user/password) login
    "Google"   # The Identity Provider we created above
  ]

  # Allowed callback URLs after user logs in
  callback_urls = [
    "http://localhost:5173/login",
    "https://${aws_cloudfront_distribution.frontend_distribution.domain_name}/login"
  ]

  # Where to send users after they log out
  logout_urls = [
    "http://localhost:5173/login",
    "https://${aws_cloudfront_distribution.frontend_distribution.domain_name}/login"
  ]

  # If you want to enable the OAuth flows in the Hosted UI
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false # If front-end only (no server secret needed)

  depends_on = [aws_cognito_identity_provider.google]
}

###################################################
#  API GATEWAY JWT AUTHORIZER (USING COGNITO)     #
###################################################
resource "aws_api_gateway_authorizer" "students_authorizer" {
  name        = "studentsCognitoAuthorizer" # Keep the same name
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "COGNITO_USER_POOLS"

  # Use your existing Cognito pool (not students_pool)
  provider_arns = [aws_cognito_user_pool.students.arn]

  # This is how you specify where to find the token
  identity_source = "method.request.header.Authorization"
}
