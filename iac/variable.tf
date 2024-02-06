variable rgname {
  type = string
  description = "Name of resource group"
}

variable location {
  type = string
  description = "Location of resource group"
}

variable adfname {
  type = string
  description = "Azure Datafactory name"
}

variable assign_identity_type {
  type = string
  description = "Assign identity type"
}

variable dbksname {
  type = string
  description = "Databricks name"
}

variable dbks_sku_type {
  type = string
  description = "Databricks sku"
}

variable keyvaultname {
  type = string
  description = "Key vault name"
}

variable kv_sku_type {
  type = string
  description = "Key vault sku"
}

variable tenant_id {
  type = string
  description = "Key vault sku"
}

variable adlsname {
  type = string
  description = "ADLS Gen2 name"
}

variable storage_account_tier {
  type = string
  description = "Storage account tier"
}

variable storage_account_replication_type {
  type = string
  description = "Storage account replication type"
}

variable storage_account_kind {
  type = string
  description = "Storage account kind"
}

variable storage_account_is_hns_enabled {
  type = string
  description = "Storage account is_hns_enabled"
}

variable synapse_name {
  type = string
  description = "Synapse_name"
}

variable synapse_aad_name {
  type = string
  description = "Synapse aad name"
}

variable databricks_access_connector_name {
  type = string
  description = "Databricks access connector name"
}

variable databricks_access_conector_assign_identity_type {
  type = string
  description = "Assign identity type"
}

variable metastore_storage_account_name{
  type = string
  description = "Storage made for metastore storage account name"
}

variable metastore_container_name{
  type = string
  description = "Storage made for metastore storage account name"
}