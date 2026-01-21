resource "databricks_mws_credentials" "this" {
  credentials_name = "gustalab-dbks-credentials"
  role_arn         = aws_iam_role.databricks_cross_account.arn
}

resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage.bucket
  storage_configuration_name = "gustalab-dbks-storage"
}

resource "databricks_mws_networks" "this" {
  account_id         = var.databricks_account_id
  network_name       = "gustalab-dbks-network"
  security_group_ids = [aws_security_group.databricks_sg.id]
  subnet_ids         = ["subnet-0fe686cf6fc66e96f", "subnet-010c553ad47b195cb"]
  vpc_id             = var.databricks_vpc
}

resource "databricks_mws_workspaces" "this" {
  account_id      = var.databricks_account_id
  aws_region      = "us-east-1" 
  workspace_name  = "gustalab-dbks-sandbox"

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform managed token"
  }
}