# Exemplo de Código Terraform para IAM Role e Bucket Policy

# Variáveis de Exemplo (Ajuste conforme sua necessidade)
variable "databricks_account_id" {
  description = "Seu Databricks Account ID (MWS)"
  type        = string
}

variable "region" {
  description = "Região AWS onde o Databricks será implantado"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefixo para nomear recursos"
  type        = string
  default     = "manus-db-demo"
}

# 1. Criação do Bucket S3 para o Root Storage
resource "aws_s3_bucket" "root_storage" {
  bucket = "${var.prefix}-root-storage"
}

resource "aws_s3_bucket_public_access_block" "root_storage" {
  bucket                  = aws_s3_bucket.root_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Criação da Cross-Account IAM Role (Credenciais)

# 2.1. Data Source para a Policy de Confiança (Assume Role Policy)
data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

# 2.2. Criação da IAM Role
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.prefix}-cross-account-role"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
}

# 2.3. Data Source para a Policy de Acesso (Access Policy)
data "databricks_aws_crossaccount_policy" "this" {
  aws_account_id = var.databricks_account_id
  region         = var.region
}

# 2.4. Anexar a Policy de Acesso à Role
resource "aws_iam_role_policy" "cross_account_policy" {
  name   = "${var.prefix}-cross-account-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

# 2.5. Registrar a Role no Databricks (databricks_mws_credentials)
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  credentials_name = "${var.prefix}-credentials"
  role_arn         = aws_iam_role.cross_account_role.arn
}

# 3. Configuração da Política do Bucket S3 (Permissão para a Role)

# 3.1. Data Source para a Bucket Policy
data "databricks_aws_bucket_policy" "this" {
  bucket           = aws_s3_bucket.root_storage.bucket
  full_access_role = aws_iam_role.cross_account_role.arn
}

# 3.2. Aplicar a Bucket Policy ao Bucket S3
resource "aws_s3_bucket_policy" "root_storage_policy" {
  bucket = aws_s3_bucket.root_storage.id
  policy = data.databricks_aws_bucket_policy.this.json
}

# 4. Registrar a Configuração de Armazenamento no Databricks
resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage.bucket
  storage_configuration_name = "${var.prefix}-storage"
}

# 5. Criação do Workspace (Requer também a Network Configuration)
# Este bloco é apenas para ilustrar o uso das IDs geradas
/*
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = "${var.prefix}-workspace"

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id # Necessita de um recurso databricks_mws_networks
  
  token {
    comment = "Terraform managed token"
  }
}
*/

# https://manus.im/share/77haNMktMrUPTxw6UCnkCJ