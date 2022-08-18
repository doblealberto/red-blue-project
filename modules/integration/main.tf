resource "aws_api_gateway_integration" "lambdaInt" {
  rest_api_id = var.api_id
  resource_id = var.resource_id
  http_method = var.method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "apideploy" {
  depends_on  = [aws_api_gateway_integration.lambdaInt]
  rest_api_id = var.api_id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${api_execution_arn}/*/*/*"
}
