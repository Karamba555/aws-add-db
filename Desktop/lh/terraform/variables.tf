variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
  default     = "us-east-1"  # Change to your desired region
}

variable "db_name_1" {
  type        = string
  description = "Name of the first database"
  default     = "announcements_db"
}

variable "db_name_2" {
  type        = string
  description = "Name of the second database"
  default     = "user_data_db"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro" # Suitable for small testing; adjust for production
}

variable "db_username" {
  type        = string
  description = "Database master username"
  default     = "admin"
  sensitive   = true  # Mark as sensitive
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true  # Mark as sensitive
}