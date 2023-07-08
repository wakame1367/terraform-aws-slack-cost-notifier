terraform {
  backend "s3" {
    bucket         = "slack-cost-notifier-086854724267-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "slack-cost-notifier-terraform-lock"
  }
}
