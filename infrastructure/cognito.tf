resource "aws_cognito_user_pool" "tasks_pool" {
  name = "tasks-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }
}

resource "aws_cognito_user_pool_client" "tasks_client" {
  name            = "tasks-app-client"
  user_pool_id    = aws_cognito_user_pool.tasks_pool.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.tasks_pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.tasks_client.id
}