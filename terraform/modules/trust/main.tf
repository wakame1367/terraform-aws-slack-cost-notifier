# data "tls_certificate" "gh_actions_certificate" {
#   url = "https://${var.tfc_hostname}"
# }

# OIDC Providr is unique in ID Provider IAM
# Create once then, remove from terraform state
# terraform state rm module.trust.aws_iam_openid_connect_provider.tfc_provider
# if you create Id Provider using Terraform, apply below code.
/*
resource "aws_iam_openid_connect_provider" "tfc_provider" {
  url             = data.tls_certificate.tfc_certificate.url
  client_id_list  = [var.tfc_aws_audience]
  thumbprint_list = [data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint]
}
*/

data "aws_iam_openid_connect_provider" "gh_actions_provider_data" {
  arn = "arn:aws:iam::086854724267:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_role" "gh_actions_role" {
  name = "${var.project}-gh-actions-role-${var.env}"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Principal": {
			"Federated": "${data.aws_iam_openid_connect_provider.gh_actions_provider_data.arn}"
		},
		"Action": "sts:AssumeRoleWithWebIdentity",
		"Condition": {
			"StringEquals": {
				"token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
				"token.actions.githubusercontent.com:sub": "repo:<GitHubユーザー名>/<GitHubリポジトリ名>:ref:refs/heads/<ブランチ名>"
			},
		}
	}]
}
EOF
}

resource "aws_iam_policy" "gh_actions_policy" {
  name        = "${var.project}-gh-actions-policy-${var.env}"
  description = "GitHubActions run policy"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"iam:*",
			"ecr:*",
			"s3:*",
			"lambda:*",
		],
		"Resource": "*"
	}]
}
EOF
}

resource "aws_iam_role_policy_attachment" "gh_actions_policy_attachment" {
  role       = aws_iam_role.gh_actions_role.name
  policy_arn = aws_iam_policy.gh_actions_policy.arn
}
