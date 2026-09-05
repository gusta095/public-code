terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.128"
    }
  }
}

provider "databricks" {
  host = var.databricks_host

  # Recomendo OAuth/M2M em ambiente real.
  # Para laboratório, você pode configurar
  # DATABRICKS_HOST / DATABRICKS_TOKEN.
}
