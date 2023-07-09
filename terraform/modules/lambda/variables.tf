variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "lambda_function_name" {
  description = "The arn of the aws_iam_role"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket to be accessed by the lambda function"
  type        = string
}

variable "repository_url" {
  description = "The url of the ecr"
  type        = string
}

variable "iam_for_lambda_arn" {
  description = "The arn of the aws_iam_role"
  type        = string
}
