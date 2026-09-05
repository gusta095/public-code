variable "databricks_host" {
  description = "Databricks workspace URL"
  type        = string
  default     = "https://dbc-xxxxxxxx-xxxx.cloud.databricks.com"
}

variable "project_id" {
  description = "Lakebase project identifier"
  type        = string
  default     = "gustalab-lakebase"
}

variable "project_name" {
  description = "Lakebase project display name"
  type        = string
  default     = "Gustalab Lakebase"
}