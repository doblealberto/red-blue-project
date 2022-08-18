

terraform {
  backend "s3" {
    bucket         = "reed-blue-project"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "red-blue-project"
  }
  required_version = ">= 0.13"
}


module "iam" {
  source           = "./modules/iam"
  lambda_role_name = "hello-bye-lambda"
  api_gw_role_name = "hello-bye-gw"

}
resource "aws_api_gateway_rest_api" "apiLambda" {
  name = "hello-bye-challenge"
}

resource "aws_lambda_function" "lambda_bye" {
  filename      = "lambda-bye.zip"
  function_name = "lambda-bye"
  role          = module.iam.lambda_role_arn
  handler       = "lambda-bye.lambda_handler"

  runtime = "python3.9"
  lifecycle {
    ignore_changes = all
  }

}

resource "aws_api_gateway_resource" "Resource1" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "bye"
}

resource "aws_api_gateway_method" "Method1" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.Resource1.id
  http_method   = "GET"
  authorization = "NONE"
}

module "apigw_conf1" {
  source            = "./modules/integration"
  lambda_function_name = "lambda-bye"
  api_id            = aws_api_gateway_rest_api.apiLambda.id
  lambda_invoke_arn = aws_lambda_function.lambda_bye.invoke_arn
  resource_id       = aws_api_gateway_resource.Resource1.id
  method            = aws_api_gateway_method.Method1.http_method
  api_execution_arn = aws_api_gateway_rest_api.apiLambda.execution_arn
  depends_on = [
    aws_lambda_function.lambda_bye,
    aws_api_gateway_rest_api.apiLambda,
    aws_api_gateway_resource.Resource1,
    aws_api_gateway_method.Method1,
  ]

}


resource "aws_lambda_function" "lambda_hello" {
  filename      = "lambda-hello.zip"
  function_name = "lambda-hello"
  role          = module.iam.lambda_role_arn
  handler       = "lambda-hello.lambda_handler"

  runtime = "python3.9"
  lifecycle {
    ignore_changes = all
  }
}
resource "aws_api_gateway_resource" "Resource2" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "Method2" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.Resource2.id
  http_method   = "GET"
  authorization = "NONE"
}

module "apigw_conf2" {
  source            = "./modules/integration"
  api_id            = aws_api_gateway_rest_api.apiLambda.id
  lambda_function_name = "lambda-hello"
  lambda_invoke_arn = aws_lambda_function.lambda_hello.invoke_arn
  resource_id       = aws_api_gateway_resource.Resource2.id
  method            = aws_api_gateway_method.Method2.http_method
  api_execution_arn = aws_api_gateway_rest_api.apiLambda.execution_arn
  depends_on = [
    aws_lambda_function.lambda_bye,
    aws_api_gateway_rest_api.apiLambda,
    aws_api_gateway_resource.Resource1,
    aws_api_gateway_method.Method1,
  ]
}