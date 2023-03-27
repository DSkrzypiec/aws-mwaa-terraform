resource "aws_iam_role" "this" {
  name               = "airflow-mwaa-${var.environment_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags = {
    Name = "mwaa-${var.environment_name}-iam-role"
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "mwaa-${var.environment_name}-execution-policy"
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}

data "aws_iam_policy_document" "assume" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "airflow-env.amazonaws.com",
        "airflow.amazonaws.com",
        "batch.amazonaws.com",
        "ssm.amazonaws.com",
        "lambda.amazonaws.com",
        "s3.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "base" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics"
    ]
    resources = [
      "arn:aws:airflow:${var.region}:${var.account_id}:environment/${var.environment_name}"
    ]
  }
  statement {
    effect  = "Deny"
    actions = ["s3:ListAllMyBuckets"]
    resources = [
      aws_s3_bucket.airflow_dags.arn,
      "${aws_s3_bucket.airflow_dags.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    resources = [
      aws_s3_bucket.airflow_dags.arn,
      "${aws_s3_bucket.airflow_dags.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetAccountPublicAccessBlock"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:*:airflow-celery-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    not_resources = ["arn:aws:kms:*:${var.account_id}:key/*"]
    condition {
      test = "StringLike"
      values = [
        "sqs.${var.region}.amazonaws.com"
      ]
      variable = "kms:ViaService"
    }
  }
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    data.aws_iam_policy_document.base.json
  ]
}
