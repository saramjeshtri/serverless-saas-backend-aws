resource "aws_dynamodb_table" "tasks" {
  name         = "tasks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "task_id"

  attribute {
    name = "task_id"
    type = "S"
  }

  tags = {
    Project     = "serverless-saas-aws"
    Environment = "dev"
  }
}