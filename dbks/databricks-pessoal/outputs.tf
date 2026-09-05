output "workspace_url" {
  description = "URL do workspace Databricks"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_id" {
  description = "ID do workspace Databricks"
  value       = databricks_mws_workspaces.this.workspace_id
}
