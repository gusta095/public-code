terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

# Usa a autenticação do ambiente e o endpoint do workspace.
provider "databricks" {}
