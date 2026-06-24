# Create the API
resource "aws_api_gateway_rest_api" "tasks_api" {
  name = "tasks-api"
}

# /tasks resource
resource "aws_api_gateway_resource" "tasks" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id   = aws_api_gateway_rest_api.tasks_api.root_resource_id
  path_part   = "tasks"
}

# /tasks/{task_id} resource
resource "aws_api_gateway_resource" "task" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id   = aws_api_gateway_resource.tasks.id
  path_part   = "{task_id}"
}

# POST /tasks
resource "aws_api_gateway_method" "post_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.tasks.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_tasks" {
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.tasks.id
  http_method             = aws_api_gateway_method.post_tasks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_task.invoke_arn
}

resource "aws_lambda_permission" "post_tasks" {
  statement_id  = "AllowAPIGatewayPOST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/POST/tasks"
}

# GET /tasks
resource "aws_api_gateway_method" "get_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.tasks.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_tasks" {
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.tasks.id
  http_method             = aws_api_gateway_method.get_tasks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_tasks.invoke_arn
}

resource "aws_lambda_permission" "get_tasks" {
  statement_id  = "AllowAPIGatewayGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_tasks.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/GET/tasks"
}

# GET /tasks/{task_id}
resource "aws_api_gateway_method" "get_task" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.task.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_task" {
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.task.id
  http_method             = aws_api_gateway_method.get_task.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_task.invoke_arn
}

resource "aws_lambda_permission" "get_task" {
  statement_id  = "AllowAPIGatewayGETTask"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/GET/tasks/*"
}

# PUT /tasks/{task_id}
resource "aws_api_gateway_method" "put_task" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.task.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_task" {
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.task.id
  http_method             = aws_api_gateway_method.put_task.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_task.invoke_arn
}

resource "aws_lambda_permission" "put_task" {
  statement_id  = "AllowAPIGatewayPUT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/PUT/tasks/*"
}

# DELETE /tasks/{task_id}
resource "aws_api_gateway_method" "delete_task" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.task.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_task" {
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.task.id
  http_method             = aws_api_gateway_method.delete_task.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_task.invoke_arn
}

resource "aws_lambda_permission" "delete_task" {
  statement_id  = "AllowAPIGatewayDELETE"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/DELETE/tasks/*"
}

# Deploy the API
resource "aws_api_gateway_deployment" "tasks_api" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id

  depends_on = [
    aws_api_gateway_integration.post_tasks,
    aws_api_gateway_integration.get_tasks,
    aws_api_gateway_integration.get_task,
    aws_api_gateway_integration.put_task,
    aws_api_gateway_integration.delete_task
  ]
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.tasks_api.id
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  stage_name    = "dev"
}

# Output the API URL
output "api_url" {
  value = "https://${aws_api_gateway_rest_api.tasks_api.id}.execute-api.us-east-1.amazonaws.com/dev"
}