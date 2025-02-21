variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "username" {
  type        = string
  description = "Database master username"
}

variable "password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "AWS region"
}