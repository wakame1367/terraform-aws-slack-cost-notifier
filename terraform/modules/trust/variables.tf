variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "github_username" {
  type = string
  description = "GitHub Username"
}

variable "github_repository_name" {
  type = string
  description = "GitHub repository name"
}

variable "github_repository_branch_name" {
  type = string
  default     = "main"
  description = "GitHub repository branch name"
}

variable "aws_region" {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS region for all resources"
}
