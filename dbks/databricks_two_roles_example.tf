# Exemplo de Código Terraform: As Duas Roles no Databricks AWS

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

# ====================================================================
# ROLE 1: CROSS-ACCOUNT ROLE (PLANO DE CONTROLE / MWS CREDENTIALS)
# Finalidade: Permite que o Databricks gerencie a infraestrutura (EC2, VPC)
# ====================================================================

# 1. Policy de Confiança para a Cross-Account Role
data "databricks_aws_assume_role_policy" "cross_account" {
  external_id = var.databricks_account_id
}

# 2. Criação da Cross-Account Role
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.prefix}-cross-account-role"
  assume_role_policy = data.databricks_aws_assume_role_policy.cross_account.json
}

# 3. Policy de Acesso para a Cross-Account Role
data "databricks_aws_crossaccount_policy" "cross_account" {
  aws_account_id = var.databricks_account_id
  region         = var.region
}

# 4. Anexar a Policy de Acesso à Role
resource "aws_iam_role_policy" "cross_account_policy" {
  name   = "${var.prefix}-cross-account-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.cross_account.json
}

# 5. Registrar a Role no Databricks (MWS Credentials)
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  credentials_name = "${var.prefix}-credentials"
  role_arn         = aws_iam_role.cross_account_role.arn
}

# ====================================================================
# ROLE 2: STORAGE CREDENTIAL ROLE (PLANO DE DADOS / UNITY CATALOG)
# Finalidade: Permite que o Unity Catalog acesse os dados no S3
# ====================================================================

# 6. Policy de Confiança para a Storage Credential Role (Assume Role Policy)
# Esta role confia no Unity Catalog (Databricks) para assumir a role
data "databricks_aws_unity_catalog_assume_role_policy" "storage_credential" {
  external_id = var.databricks_account_id
}

# 7. Criação da Storage Credential Role
resource "aws_iam_role" "storage_credential_role" {
  name               = "${var.prefix}-storage-credential-role"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.storage_credential.json
}

# 8. Policy de Acesso para a Storage Credential Role (Permissões S3)
# Esta policy concede as permissões de leitura/escrita no S3
data "databricks_aws_unity_catalog_policy" "storage_credential" {
  bucket_name = "seu-bucket-de-dados-aqui" # Substitua pelo nome do seu bucket de dados
}

# 9. Anexar a Policy de Acesso à Role
resource "aws_iam_role_policy" "storage_credential_policy" {
  name   = "${var.prefix}-storage-credential-policy"
  role   = aws_iam_role.storage_credential_role.id
  policy = data.databricks_aws_unity_catalog_policy.storage_credential.json
}

# 10. Registrar a Role no Databricks (Storage Credential - Unity Catalog)
resource "databricks_storage_credential" "this" {
  name = "${var.prefix}-storage-credential"
  aws_iam_role {
    role_arn = aws_iam_role.storage_credential_role.arn
  }
  comment = "Credencial de armazenamento para o Unity Catalog"
}

# ====================================================================
# Uso no Workspace (Apenas para referência)
# O Workspace usa a MWS Credential (Role 1)
# O Unity Catalog usa a Storage Credential (Role 2)
# ====================================================================
/*
resource "databricks_mws_workspaces" "this" {
  # ...
  credentials_id           = databricks_mws_credentials.this.credentials_id # Role 1
  # ...
}

resource "databricks_metastore" "this" {
  # ...
  storage_root = "s3://seu-bucket-de-dados-aqui"
  owner        = "databricks_account_id"
  force_destroy = true
}

resource "databricks_catalog" "this" {
  # ...
  storage_credential_id = databricks_storage_credential.this.id # Role 2
  # ...
}
*/
