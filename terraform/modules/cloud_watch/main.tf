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