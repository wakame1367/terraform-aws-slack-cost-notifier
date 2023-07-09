resource "aws_lambda_function" "cost_report" {
  function_name = "${var.project}-cost-reporte-${var.env}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler" # Lambda functionのハンドラー

  filename = "lambda_function_payload.zip" # AWSサービスごとのコスト情報を取得しSNSに送信するLambda関数のZIPパッケージへのパス

  runtime = "python3.8" # ランタイムのバージョン
}
