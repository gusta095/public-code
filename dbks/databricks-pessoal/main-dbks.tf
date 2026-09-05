resource "time_sleep" "wait_for_iam_propagation" {
  depends_on = [aws_iam_role_policy.databricks_cross_account_policy]

  create_duration = "15s"
}

resource "databricks_mws_credentials" "this" {
  credentials_name = "gustalab-dbks-credentials"
  role_arn         = aws_iam_role.databricks_cross_account.arn

  depends_on = [time_sleep.wait_for_iam_propagation]
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
  subnet_ids         = var.databricks_subnet_ids
  vpc_id             = var.databricks_vpc
}

resource "databricks_mws_workspaces" "this" {
  account_id      = var.databricks_account_id
  aws_region      = var.region
  workspace_name  = "gustalab-dbks-sandbox"

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform managed token"
  }
}

data "databricks_user" "admin" {
  user_name = var.databricks_admin_email
}

resource "databricks_mws_permission_assignment" "admin" {
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_user.admin.id
  permissions  = ["ADMIN"]
}