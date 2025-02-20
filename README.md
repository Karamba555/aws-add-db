# aws-add-db
Board app &lt;add postgres db + role + *.sql
-
AWS PostgreSQL databases with the specified schemas using Terraform. This involves several steps:
-
1. Project Structure and Prerequisites:
-
Terraform Installation: Make sure you have Terraform installed and configured.
AWS Credentials: You'll need AWS credentials configured so Terraform can provision resources in your AWS account (e.g., using AWS CLI, environment variables, or an IAM role).
Project Directory: Create a project directory to hold your Terraform files. A good practice is to organize your code into modules. Here's a possible structure:
 ```
 terraform-db-setup/
 ├── modules/
 │   ├── database/
 │   │   ├── main.tf
 │   │   ├── variables.tf
 │   │   ├── outputs.tf
 │   │   └── scripts/  # For database initialization
 │   │       └── create_schema.sql
 ├── main.tf        # Main Terraform file
 ├── variables.tf   # Global variables (region, etc.)
 └── outputs.tf     # Outputs (DB endpoints, etc.)
 ```
Explanation and Important Considerations:

Modules: The database module encapsulates the creation of an RDS PostgreSQL instance. This promotes reusability and organization.
Variables: Using variables makes the code more configurable (e.g., region, DB instance class).
Security Groups: The security group in the module allows_postgres will allow incoming traffic to the DB on port 5432 from 0.0.0.0/0. This is highly insecure for a production environment. You should restrict this to only the IP addresses that need to access the database (e.g., your application servers). Consider using a bastion host.
Subnet Groups: The subnet group tells RDS in which subnets it can create the DB instance. The configuration assumes that the subnet naming include the word 'private'.
RDS Configuration: The aws_db_instance resource creates the PostgreSQL instance. Important attributes include:
allocated_storage: Start small and increase as needed.
instance_class: Choose an appropriate instance type based on your workload.
engine: "postgres"
username, password: The master credentials. Store these securely! Consider using AWS Secrets Manager or SSM Parameter Store.
skip_final_snapshot: Remove this for production! It creates a snapshot when you destroy the instance, allowing you to restore it later.
multi_az: Consider true for production to improve availability (automatic failover to a standby replica).
publicly_accessible: true for development/testing, but set to false for production! Use other mechanisms to access the DB (e.g., VPN, bastion host).
PostgreSQL Provider: The cyrilgdn/postgresql provider is used to interact with the PostgreSQL database after it's created. It allows you to create databases, schemas, tables, and other database objects.
Database and Schema Creation: The code creates the databases and schemas using the postgresql_database and postgresql_schema resources.
Table Creation: The postgresql_table resource creates the users and announcements tables with the specified columns and constraints.
Foreign Key: The postgresql_foreign_key resource creates the foreign key constraint between the announcements table and the users table.
Database Initialization Script (Optional but Recommended):
The create_schema.sql file contains the SQL statements to create the tables.
You'll need to execute this script after the database instance is created. One way to do this is using the postgresql_query resource (not shown in detail here for brevity, but look it up in the provider documentation).
9. Running the Terraform Code:

Initialize: terraform init (This downloads the necessary providers and modules.)
Plan: terraform plan (This shows you the changes Terraform will make.)
Apply: terraform apply (This creates the resources in AWS.) You'll be prompted to confirm.
Security Best Practices (Very Important!):

Secrets Management: Do not hardcode passwords in your Terraform code. Use AWS Secrets Manager or SSM Parameter Store to store sensitive data and retrieve it in your Terraform configuration. This is the most important security consideration.
Networking:
Never make your database publicly accessible in a production environment.
Use a VPC and private subnets.
Restrict access to the security group to only the necessary IP addresses or security groups.
IAM Roles: Use IAM roles with minimal privileges for Terraform to manage your AWS resources. Avoid using your root account credentials.
Encryption: Enable encryption at rest and in transit for your RDS instances.
Regular Backups: Configure automated backups for your RDS instances.
Example using AWS Secrets Manager:

Create a Secret in Secrets Manager: Store the database password as a secret in AWS Secrets Manager.
Data Source for Secret:
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "arn:aws:secretsmanager:<region>:<account_id>:secret:<secret_name>"  # Replace with your Secret ARN
}
Use the Secret:
variable "db_password" {
  type = string
  description = "Database master password"
  sensitive   = true
  default = data.aws_secretsmanager_secret_version.db_password.secret_string
}
Remember to replace placeholders like <region>, <account_id>, and <secret_name> with your actual values. This makes your code much more secure!
