terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

# Configure autenticação Azure via Azure CLI, identidade ou ARM_*.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Este host seleciona o workspace e, consequentemente, seu metastore.
# O workspace e a associação ao Unity Catalog já devem existir.
# Configure autenticação com DATABRICKS_* ou perfil externo; não grave segredos.
provider "databricks" {
  host = var.databricks_workspace_url
}
