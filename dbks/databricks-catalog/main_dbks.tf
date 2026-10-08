# Recursos do Unity Catalog, administrados pelo workspace do provider.
# A identidade que executa Terraform deve ter os privilégios de criação
# necessários no metastore e permissão para usar as managed locations.
resource "databricks_storage_credential" "catalogo" {
  name    = "credencial_${var.catalog_name}"
  comment = "Credencial de armazenamento gerenciada pelo Terraform"

  azure_managed_identity {
    access_connector_id = data.azurerm_databricks_access_connector.existente.id
  }

  # Referenciar o Connector não garante que o RBAC já tenha sido atribuído.
  # A propagação do RBAC Azure ainda pode levar tempo após sua criação.
  depends_on = [azurerm_role_assignment.acesso_storage]
}

# Uma external location por container, compartilhando a mesma credencial.
resource "databricks_external_location" "camada" {
  for_each = azurerm_storage_container.camada

  name            = "location_${var.catalog_name}_${each.key}"
  url             = "abfss://${each.value.name}@${azurerm_storage_account.dados.name}.dfs.core.windows.net/"
  credential_name = databricks_storage_credential.catalogo.name
  comment         = "External location da camada ${each.key}"
}

resource "databricks_catalog" "exemplo" {
  name    = var.catalog_name
  comment = "Catálogo gerenciado pelo Terraform"
  owner   = var.catalog_owner

  # O catálogo tem uma única raiz. Bronze fornece o fallback do catálogo.
  # Cada schema abaixo utiliza sua própria raiz, que prevalece sobre esta.
  # Subcaminhos distintos evitam sobreposição de managed locations.
  storage_root = "${databricks_external_location.camada["bronze"].url}catalog-managed"
}

# Associa explicitamente cada schema ao armazenamento da sua camada.
resource "databricks_schema" "camada" {
  for_each = databricks_external_location.camada

  catalog_name = databricks_catalog.exemplo.name
  name         = each.key
  comment      = "Schema da camada ${each.key}"
  storage_root = "${each.value.url}schema-managed"
}

# Um recurso por grupo: gerencia os privilégios desse grupo neste catálogo.
# Não misture databricks_grants com estes recursos para o mesmo catálogo.
# Os privilégios são herdados por tabelas/views atuais e futuras.
# Para arquivos em volumes, adicione READ_VOLUME conforme a necessidade.
resource "databricks_grant" "data_readers" {
  for_each = var.reader_groups

  catalog    = databricks_catalog.exemplo.name
  principal  = each.value
  privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
}
