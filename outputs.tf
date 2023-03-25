output "airflow_s3_dags_arn" {
  description = "S3 for Airflow DAGs"
  value       = aws_s3_bucket.airflow_dags.arn
}
