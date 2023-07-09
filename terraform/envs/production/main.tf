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

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "cost_report" {
  function_name = "cost_report"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler" # Lambda functionのハンドラー

  filename = "lambda_function_payload.zip" # AWSサービスごとのコスト情報を取得しSNSに送信するLambda関数のZIPパッケージへのパス

  runtime = "python3.8" # ランタイムのバージョン
}

resource "aws_cloudwatch_event_rule" "every_sunday" {
  name                = "every_sunday"
  schedule_expression = "cron(0 12 ? * SUN *)" # 毎週日曜日の午後12時（UTC）にトリガー
}

resource "aws_cloudwatch_event_target" "send_report" {
  rule      = aws_cloudwatch_event_rule.every_sunday.name
  target_id = "SendCostReport"
  arn       = aws_lambda_function.cost_report.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_report.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_sunday.arn
}

resource "aws_sns_topic" "slack_notifications" {
  name = "slack-notifications"
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_report.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.slack_notifications.arn
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.slack_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"
    Statement = [
      {
        Sid       = "__default_statement_ID"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["SNS:Publish"]
        Resource  = aws_sns_topic.slack_notifications.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_lambda_function.cost_report.arn
          }
        }
      }
    ]
  })
}

module "trust" {
  source  = "../../modules/trust"
  project = local.project
  env     = local.env

  github_username = "wakame1367"
  github_repository_name = ""
  github_repository_branch_name = "main"
}
