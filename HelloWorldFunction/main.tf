terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "sa-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    iam         = "http://localhost:4566"
    dynamodb   = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "book_function" {
  function_name    = "BookFunction"
  handler          = "bookfunction.controller.BookFunction::handleRequest"
  runtime          = "java11"
  memory_size      = 512
  timeout          = 30
  filename         = "target/HelloWorld-1.0.jar" # Caminho para o JAR
  source_code_hash = filebase64sha256("target/HelloWorld-1.0.jar")
  role             = aws_iam_role.lambda_execution_role.arn
}

resource "aws_api_gateway_rest_api" "book_api" {
  name = "BookFunction"
  description = "API para gerenciar livros"
}

# Root resource for /book
resource "aws_api_gateway_resource" "book" {
  rest_api_id = aws_api_gateway_rest_api.book_api.id
  parent_id   = aws_api_gateway_rest_api.book_api.root_resource_id
  path_part   = "book"
}

# GET /book - List all books
resource "aws_api_gateway_method" "list_books" {
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  resource_id   = aws_api_gateway_resource.book.id
  http_method   = "GET"
  authorization = "NONE"
}

# Definindo a integração com o Lambda
resource "aws_api_gateway_integration" "list_books_integration" {
  rest_api_id             = aws_api_gateway_rest_api.book_api.id
  resource_id             = aws_api_gateway_resource.book.id
  http_method             = aws_api_gateway_method.list_books.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.book_function.invoke_arn
}

# Resource for /book/{id}
resource "aws_api_gateway_resource" "book_id" {
  rest_api_id = aws_api_gateway_rest_api.book_api.id
  parent_id   = aws_api_gateway_resource.book.id
  path_part   = "{id}"
}

# GET /book/{id} - Get a book by ID
resource "aws_api_gateway_method" "get_book_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  resource_id   = aws_api_gateway_resource.book_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_book_by_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.book_api.id
  resource_id             = aws_api_gateway_resource.book_id.id
  http_method             = aws_api_gateway_method.get_book_by_id.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.book_function.invoke_arn
}

# POST /book - Create a new book
resource "aws_api_gateway_method" "create_book" {
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  resource_id   = aws_api_gateway_resource.book.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_books_integration" {
  rest_api_id             = aws_api_gateway_rest_api.book_api.id
  resource_id             = aws_api_gateway_resource.book.id
  http_method             = aws_api_gateway_method.create_book.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.book_function.invoke_arn
}

# PUT /book/{id} - Update a book
resource "aws_api_gateway_method" "update_book" {
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  resource_id   = aws_api_gateway_resource.book_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_books_integration" {
  rest_api_id             = aws_api_gateway_rest_api.book_api.id
  resource_id             = aws_api_gateway_resource.book_id.id
  http_method             = aws_api_gateway_method.update_book.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.book_function.invoke_arn
}

# DELETE /book/{id} - Delete a book
resource "aws_api_gateway_method" "delete_book" {
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  resource_id   = aws_api_gateway_resource.book_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_books_integration" {
  rest_api_id             = aws_api_gateway_rest_api.book_api.id
  resource_id             = aws_api_gateway_resource.book_id.id
  http_method             = aws_api_gateway_method.delete_book.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.book_function.invoke_arn
}

# Root resource for /hello
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.book_api.id
  parent_id   = aws_api_gateway_rest_api.book_api.root_resource_id
  path_part   = "hello"
}

# GET /book - List all books
resource "aws_api_gateway_method" "hello_world" {
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# Definindo a integração com o Lambda
resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id             = aws_api_gateway_rest_api.book_api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_world.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.book_function.invoke_arn
}

# Criando o deployment
resource "aws_api_gateway_deployment" "book_api_deployment" {
  depends_on  = [
                  aws_api_gateway_integration.list_books_integration,
                  aws_api_gateway_integration.get_book_by_id_integration,
                  aws_api_gateway_integration.post_books_integration,
                  aws_api_gateway_integration.put_books_integration,
                  aws_api_gateway_integration.delete_books_integration,
                  aws_api_gateway_integration.hello_world_integration
                ]
  rest_api_id = aws_api_gateway_rest_api.book_api.id
}

# Definindo o estágio "prod" de forma explícita
resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.book_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.book_api.id
  stage_name    = "prod"

}

# Permissão para o API Gateway invocar o Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.book_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.book_api.execution_arn}/*/*"
}
