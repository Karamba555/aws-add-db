output "db_endpoint" {
  value       = aws_db_instance.default.endpoint
  description = "The endpoint of the database"
}

output "db_name" {
  value       = aws_db_instance.default.db_name
  description = "The name of the database"
}

output "db_username" {
  value       = aws_db_instance.default.username
  description = "The username of the database"
}