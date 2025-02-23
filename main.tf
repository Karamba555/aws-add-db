
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "announcements_db" {
  source         = "./modules/database"
  db_name        = var.db_name_1
  instance_class = var.db_instance_class
  username       = var.db_username
  password       = var.db_password
  region         = var.aws_region
}

module "user_data_db" {
  source         = "./modules/database"
  db_name        = var.db_name_2
  instance_class = var.db_instance_class
  username       = var.db_username
  password       = var.db_password
  region         = var.aws_region
}

resource "postgresql_database" "announcements_db_init" {
  name             = var.db_name_1
  owner            = var.db_username
  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.announcements_db.db_endpoint}/${var.db_name_1}"
  depends_on     = [module.announcements_db]
}

resource "postgresql_database" "user_data_db_init" {
  name             = var.db_name_2
  owner            = var.db_username
  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.user_data_db.db_endpoint}/${var.db_name_2}"
  depends_on     = [module.user_data_db]
}

resource "postgresql_schema" "announcements_db_schema" {
  name             = "public"  # Or another schema name if desired
  database         = postgresql_database.announcements_db_init.name
  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.announcements_db.db_endpoint}/${var.db_name_1}"
  depends_on     = [postgresql_database.announcements_db_init]
}

resource "postgresql_schema" "user_data_db_schema" {
  name             = "public"  # Or another schema name if desired
  database         = postgresql_database.user_data_db_init.name
  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.user_data_db.db_endpoint}/${var.db_name_2}"
  depends_on     = [postgresql_database.user_data_db_init]
}

resource "postgresql_table" "user_table" {
  name             = "users"
  database         = postgresql_database.user_data_db_init.name
  schema           = postgresql_schema.user_data_db_schema.name
  column {
    name     = "id"
    type     = "SERIAL"
    nullable = false
    primary_key = true
  }
  column {
    name     = "username"
    type     = "VARCHAR(255)"
    nullable = false
    unique = true
  }
  column {
    name     = "email"
    type     = "VARCHAR(255)"
    nullable = false
    unique = true
  }
  column {
    name     = "password_hash"
    type     = "VARCHAR(255)"
    nullable = false
  }
  column {
    name    = "created_at"
    type    = "TIMESTAMP"
    default = "NOW()"
  }
  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.user_data_db.db_endpoint}/${var.db_name_2}"
  depends_on     = [postgresql_schema.user_data_db_schema]
}

resource "postgresql_table" "announcement_table" {
  name             = "announcements"
  database         = postgresql_database.announcements_db_init.name
  schema           = postgresql_schema.announcements_db_schema.name
  column {
    name     = "id"
    type     = "SERIAL"
    nullable = false
    primary_key = true
  }
  column {
    name     = "user_id"
    type     = "INTEGER"
    nullable = true
  }
  column {
    name     = "title"
    type     = "VARCHAR(255)"
    nullable = false
  }
  column {
    name     = "description"
    type     = "TEXT"
    nullable = true
  }
  column {
    name     = "image_url"
    type     = "VARCHAR(255)"
    nullable = true
  }
   column {
    name    = "created_at"
    type    = "TIMESTAMP"
    default = "NOW()"
  }

  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.announcements_db.db_endpoint}/${var.db_name_1}"
  depends_on     = [postgresql_schema.announcements_db_schema]
}

resource "postgresql_foreign_key" "announcements_user_fk" {
  name             = "announcements_user_fk"
  table            = postgresql_table.announcement_table.name
  schema           = postgresql_schema.announcements_db_schema.name
  database         = postgresql_database.announcements_db_init.name
  column           = "user_id"
  foreign_table    = postgresql_table.user_table.name
  foreign_schema   = postgresql_schema.user_data_db_schema.name
  foreign_column   = "id"
  connection_url = "postgresql://${var.db_username}:${var.db_password}@${module.announcements_db.db_endpoint}/${var.db_name_1}"
  depends_on = [postgresql_table.announcement_table, postgresql_table.user_table]
