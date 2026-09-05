output "project_name" {
  value = databricks_postgres_project.this.name
}

output "branch_name" {
  value = databricks_postgres_branch.production.name
}

output "database_name" {
  value = databricks_postgres_database.app.name
}

output "endpoint_name" {
  value = databricks_postgres_endpoint.primary.name
}