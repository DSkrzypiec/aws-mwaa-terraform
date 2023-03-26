resource "aws_s3_bucket" "airflow_dags" {
  bucket = "airflow-ds-dags"
}

resource "aws_s3_bucket_acl" "airflow_dags_acl" {
  bucket = aws_s3_bucket.airflow_dags.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "airflow_dags_ver" {
  bucket = aws_s3_bucket.airflow_dags.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "airflow_dags_access" {
  bucket = aws_s3_bucket.airflow_dags.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_mwaa_environment" "this" {
  name                 = "airflow-ds-test"
  dag_s3_path          = "dags/"
    #plugins_s3_path      = "plugins.zip"
    #requirements_s3_path = "requirements.txt"
  execution_role_arn   = "arn:aws:iam::605411976919:role/airflow-exec-ds-test"
  airflow_version      = "2.4.3"
  environment_class    = "mw1.small"

  network_configuration {
    security_group_ids = [aws_security_group.airflow_sg.id]
    subnet_ids         = [aws_subnet.airflow_priv_subnet1.id, aws_subnet.airflow_priv_subnet2.id]
  }

  source_bucket_arn = aws_s3_bucket.airflow_dags.arn

  tags = {
    Name = "mwaa-${var.environment_name}-instance"
  }
}
