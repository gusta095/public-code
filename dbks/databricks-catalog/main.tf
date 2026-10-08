# Exemplo didático para Azure Databricks.
# Pré-requisitos existentes:
# - Workspace associado a um metastore do Unity Catalog.
# - Storage account ADLS Gen2 (hierarchical namespace habilitado) e container.
# - Access Connector com identidade gerenciada atribuída pelo sistema.
# - Identidade do Access Connector com acesso de leitura/escrita ao container
#   (por exemplo, Storage Blob Data Contributor no escopo adequado).
# - Identidade que executa Terraform com permissões para criar os três objetos
#   e CREATE MANAGED STORAGE na external location utilizada.
# Substitua os valores de exemplo antes de executar.

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

# É aqui que você direciona as chamadas para o workspace.
# O metastore utilizado é aquele associado a esse workspace.
# Configure autenticação fora do arquivo, por exemplo com DATABRICKS_TOKEN
# ou credenciais OAuth via variáveis de ambiente do Databricks.
provider "databricks" {
  host = "https://adb-1234567890123456.7.azuredatabricks.net"
}

# 1. Registra a identidade que acessa o armazenamento.
# Não cria o Access Connector nem a identidade no Azure.
resource "databricks_storage_credential" "catalogo" {
  name    = "credencial_catalogo_exemplo"
  comment = "Credencial de armazenamento gerenciada pelo Terraform"

  azure_managed_identity {
    access_connector_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dados/providers/Microsoft.Databricks/accessConnectors/ac-databricks"
  }
}

# 2. Associa um caminho ADLS à credencial acima.
# O container dados e a storage account stdadosexemplo já devem existir.
# A referência credential_name cria a dependência no Terraform.
resource "databricks_external_location" "catalogo" {
  name            = "location_catalogo_exemplo"
  url             = "abfss://dados@stdadosexemplo.dfs.core.windows.net/catalogo-exemplo"
  credential_name = databricks_storage_credential.catalogo.name
  comment         = "Localização de armazenamento gerenciada pelo Terraform"
}

# 3. Cria o catálogo com armazenamento gerenciado dentro da external location.
# A referência à URL cria a dependência na external location.
# managed é um subcaminho dedicado aos dados gerenciados pelo Unity Catalog.
resource "databricks_catalog" "exemplo" {
  name         = "catalogo_exemplo"
  comment      = "Catálogo gerenciado pelo Terraform"
  storage_root = "${databricks_external_location.catalogo.url}/managed"

  # Opcional: application ID de um service principal existente no Databricks.
  # owner = "00000000-0000-0000-0000-000000000000"
}
