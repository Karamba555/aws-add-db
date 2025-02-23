resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-group-${random_id.db_id.hex}"
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres-${random_id.db_id.hex}"
  description = "Allow postgres traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Postgres traffic"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this for production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow Postgres Traffic"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20  # Minimum value, increase as needed
  db_name                = var.db_name
  engine                 = "postgres"
  engine_version         = "15.latest" # Use a specific version for stability
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true  # Remove this for production
  vpc_security_group_ids = [aws_security_group.allow_postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  multi_az               = false  # Consider true for production
  publicly_accessible  = true # Set to false for a production environment
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "*private*"  # Adjust to match your subnet naming
  }
}

resource "random_id" "db_id" {
  byte_length = 4
}