variable "api_id" {
  description = "id of the api"
}
variable lambda_function_name {
  description = "name of the lambda function"
}
variable "lambda_invoke_arn"{
  description = "Lambda invoke_arn"
}

variable "resource_id" {
    description = "id or the resource"
}
variable "method"  {
    description = "http method"
}

variable "api_execution_arn" {
    description = "Execution arn of the api"
}