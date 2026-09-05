variable "databricks_account_id" {
  description = "Account ID databricks"
  type        = string
  default     = "4a4cb85a-xxxx-4f16-9480-23d653bdb5fa"
}

variable "region" {
  description = "Região AWS onde o Databricks será implantado"
  type        = string
  default     = "us-east-1"
}

variable "databricks_vpc" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0f1c78c8d075xxxxx"
}

variable "databricks_subnet_ids" {
  description = "Subnet IDs para o Databricks network"
  type        = list(string)
  default     = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"]
}

variable "databricks_admin_email" {
  description = "E-mail do usuário que receberá acesso ADMIN no workspace"
  type        = string
  default     = "user@example.com"
}
