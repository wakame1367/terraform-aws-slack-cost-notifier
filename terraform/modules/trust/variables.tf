variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_region" {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS region for all resources"
}
