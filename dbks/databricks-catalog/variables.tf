variable "subscription_id" {
  description = "ID da subscription Azure."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group existente onde será criada a storage account."
  type        = string
}

variable "storage_account_name" {
  description = "Nome globalmente único da storage account, com 3 a 24 letras minúsculas/números."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Use de 3 a 24 letras minúsculas ou números."
  }
}

variable "databricks_workspace_url" {
  description = "URL HTTPS de um workspace existente habilitado para Unity Catalog."
  type        = string
}

variable "access_connector_name" {
  description = "Nome de um Access Connector existente, com identidade SystemAssigned."
  type        = string
}

variable "access_connector_resource_group_name" {
  description = "Resource group existente do Access Connector."
  type        = string
}

variable "catalog_name" {
  description = "Nome do catálogo no metastore."
  type        = string
  default     = "catalogo_exemplo"
}

variable "catalog_owner" {
  description = "Owner existente no Databricks: usuário, grupo ou application ID do service principal. Null mantém o criador."
  type        = string
  default     = null
  nullable    = true
}

variable "reader_groups" {
  description = "Nomes exatos dos grupos de conta já disponíveis no Databricks. Recebem leitura de tabelas/views do catálogo inteiro."
  type        = set(string)

  validation {
    condition     = alltrue([for name in var.reader_groups : trimspace(name) != ""])
    error_message = "Os nomes dos grupos não podem ser vazios."
  }
}

variable "tags" {
  description = "Tags da storage account."
  type        = map(string)
  default     = {}
}
