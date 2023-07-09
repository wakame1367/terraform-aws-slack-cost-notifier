locals {
  env     = "production"
  project = "slack-cost-notifier"

  chatbot_logging_level      = "INFO"
  chatbot_slack_workspace_id = "T024F6QTP"

  chatbot_tags = {
    Automation     = "Terraform + Cloudformation"
    Terraform      = true
    Cloudformation = true
  }
}

data "aws_iam_role" "chatbot" {
  name = "Wave__AwsChatBot"
}

data "aws_sns_topic" "serverless_sumologic_convox_scylla_pipeline_notifications" {
  name = "serverless-sumologic-convox-scylla-pipeline-notifications"
}

module "chatbot_slack_configuration" {
  source  = "waveaccounting/chatbot-slack-configuration/aws"
  version = "1.1.0"

  configuration_name = "config-name"
  iam_role_arn       = data.aws_iam_role.chatbot.arn
  slack_channel_id   = "ABCDEADF"
  slack_workspace_id = local.chatbot_slack_workspace_id

  sns_topic_arns = [
    data.aws_sns_topic.serverless_sumologic_convox_scylla_pipeline_notifications.arn,
  ]

  tags = local.chatbot_tags
}

module "trust" {
  source  = "../../modules/trust"
  project = local.project
  env     = local.env

  github_username = "wakame1367"
  github_repository_name = ""
  github_repository_branch_name = "main"
}
