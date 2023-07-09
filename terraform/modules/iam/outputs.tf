output "lambda_arn" {
  description = "The arn of the aws_lambda_function"
  value       = aws_lambda_function.main.arn
}
