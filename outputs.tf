output "db_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "db_user" {
  value = aws_db_instance.rds.username
}

output "db_arn" {
  value = aws_db_instance.rds.arn
}

