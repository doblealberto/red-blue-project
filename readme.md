# Red-Blue App

Red-Blue app is a simple serverless app, the app's infratructure has been provisioned with terraform.

To pick the red one click on the image! <a href="https://ob1cj6ywdg.execute-api.us-east-1.amazonaws.com/prod/bye"><img width="75px" height="75px" src="https://incels.wiki/images/9/9c/Redpill2.png"/></a>
To pick the blue one click on the image! <a href="https://ob1cj6ywdg.execute-api.us-east-1.amazonaws.com/prod/hello"><img width="75px" height="75px" src="https://incels.wiki/images/b/bb/Bluepill.png"/></a>
### AND REMEMBER TO CHOOSE WISELY

![Example Image](https://drive.google.com/uc?id=1Wckeb_U5gzzyfChVe6U1EftJXxvf_XO2)

As we see the architecture design is simple there is one `prod` stage and within it two endpoints one for saying bye `/bye` a.k.a (red) and one for saying hello `/hello`
## Project Structure
```
├── main.tf
├── modules
    ├── iam  (grants permisions for cloudwatch to both api-gw and lambda resources) 
    │   ├── apigw-role.json
    │   ├── lambda-role.json
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── integration  (creates the integration between different services ie. api-gw and lambda )
        ├── inputs.tf
        ├── main.tf
        └── outputs.tf
```

## Root terraform file
## terraform block
```
terraform {
  backend "s3" {
    bucket         = "reed-blue-project"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "red-blue-project"
  }
}
```
We start adding a backend in s3 as best practices dictates for storing the state, a dynamo db table has been also added in order to prevent to collaborators to modify the state file at the same time

## IAM module instance and overview

one the modules that are available in the project is the iam module, as we can see it takes to vars those two vars are then used in the module in order to provide de policies to the respective resources, path to the module is at `./modules/iam/`
```
module "iam" {
  source           = "./modules/iam"
  lambda_role_name = "hello-bye-lambda"
  api_gw_role_name = "hello-bye-gw"
}
```
# IAM policies file
As we stated earlier Iam module contains file policies lets take for example the `apigw-role.json`
```
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "apigateway.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
```
As we see the content of the file is just an IAM policie.
The contents of the file are used to hten grant permissions to other aws services such as cloudwatch.
```
resource "aws_iam_role_policy_attachment" "Lambda-CloudWatch-Logs-ReadWrite" {
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role  = "${aws_iam_role.lambda-role.name}"
}
```
### Integration module instance and overview.
The integration module is in charge of connecting the lambda and api-gw services and also in charge of creating
the permisions for the call to the lambda function via api-gw the required the required vars to initiate it are the following
```
module "apigw_conf2" {
  source            = "./modules/integration"
  api_id: "The id of the api"
  lambda_function_name = "the name of the lambda function"
  lambda_invoke_arn = "the invoke arn of the lambda function"
  resource_id       = "the resource id"
  method            = "the http method"
  api_execution_arn = "the execution arn for the api"
  depends_on = [
    aws_lambda_function.lambda_bye,
    aws_api_gateway_rest_api.apiLambda,
    aws_api_gateway_resource.Resource1,
    aws_api_gateway_method.Method1,
  ]
}
```
inside the module there is a resource that grants the permisions to api gateway to call the lambda function
```
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/*/*"
}
```
Notice how the ```"${var.api_execution_arn}/*/*/*"``` statement allows any resource from our API to consume our lmabda functions.

