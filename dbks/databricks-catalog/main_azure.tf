# Recursos e consultas do lado Azure.
# O Resource Group e o Access Connector são reutilizados, não criados.
data "azurerm_resource_group" "dados" {
  name = var.resource_group_name
}

data "azurerm_databricks_access_connector" "existente" {
  name                = var.access_connector_name
  resource_group_name = var.access_connector_resource_group_name
}

locals {
  camadas = toset(["bronze", "prata", "gold"])
}

resource "azurerm_storage_account" "dados" {
  name                            = var.storage_account_name
  resource_group_name             = data.azurerm_resource_group.dados.name
  location                        = data.azurerm_resource_group.dados.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public  = false
  tags                            = var.tags
}

# Containers privados; os blobs serão os arquivos gravados dentro deles.
resource "azurerm_storage_container" "camada" {
  for_each = local.camadas

  name                  = each.key
  storage_account_id    = azurerm_storage_account.dados.id
  container_access_type = "private"
}

# A identidade do Access Connector precisa escrever os dados gerenciados.
# Leitura apenas (Storage Blob Data Reader) não atende a esse caso.
# O escopo cobre os três containers desta storage account dedicada.
resource "azurerm_role_assignment" "acesso_storage" {
  scope                = azurerm_storage_account.dados.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_databricks_access_connector.existente.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
