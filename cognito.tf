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

  # Keep schema definitions for documentation, but Terraform will ignore them
  schema {
    attribute_data_type = "String"
    name                = "given_name"
    required            = false
    mutable             = true
  }

  schema {
    attribute_data_type = "String" 
    name                = "family_name"
    required            = false
    mutable             = true
  }

  schema {
    attribute_data_type = "String"
    name                = "custom:birthdate"
    required            = false
    mutable             = true
  }

  schema {
    attribute_data_type = "String"
    name                = "custom:user_address"
    required            = false
    mutable             = true
  }

  schema {
    attribute_data_type = "String"
    name                = "custom:user_phone"
    required            = false
    mutable             = true
  }

  tags = local.common_tags

  # This is the key part - add this lifecycle block
  lifecycle {
    ignore_changes = [schema]
  }
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
    "profile",
    # The ${...} syntax is called an "interpolation" in Terraform.
    # It allows you to insert the value of a variable or expression
    # into a string. In this case, we're inserting the value of the
    # "identifier" attribute of the "students_api" resource server,
    # which we created above.
    #
    # The value of "identifier" is set to "students-api" in the
    # "aws_cognito_resource_server" block above.
    #
    # So, this line is effectively setting the allowed scope to
    # "students-api/students.read". This means that the client is
    # allowed to request an access token with the "students.read"
    # scope when using the Authorization Code flow.
    #
    # The "students.read" scope is based on the "students.read" custom
    # scope defined in the "aws_cognito_resource_server" block above.
    "${aws_cognito_resource_server.students_api.identifier}/students.read",
    "${aws_cognito_resource_server.students_api.identifier}/students.write"
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
  
  # Essential for API access
  access_token_validity = 1 # Hours
  id_token_validity     = 1 # Hours
  
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

  depends_on = [aws_cognito_identity_provider.google, aws_cognito_resource_server.students_api]
}

###################################################
#  COGNITO RESOURCE SERVER FOR API ACCESS         #
###################################################
resource "aws_cognito_resource_server" "students_api" {
  identifier = "students-api"
  name       = "Students API"
  
  user_pool_id = aws_cognito_user_pool.students.id
  
  # Define the custom scopes for your API
  scope {
    scope_name        = "students.read"
    scope_description = "Read access to student data API"
  }
  
  scope {
    scope_name        = "students.write"
    scope_description = "Write access to student data API"
  }
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
