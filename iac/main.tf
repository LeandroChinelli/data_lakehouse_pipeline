provider "azurerm" {
    features {
        key_vault {
            purge_soft_delete_on_destroy    = true
            recover_soft_deleted_key_vaults = true
        }
    }
}

resource "azurerm_resource_group" "resource_group" {
    name     = var.rgname
    location = var.location
}

resource "azurerm_data_factory" "data_factory" {
  name                = var.adfname
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
    identity {
      type = var.assign_identity_type
    }
}

resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                = var.dbksname
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = var.dbks_sku_type
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = var.keyvaultname
  location                    = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = var.kv_sku_type

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.adlsname
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind
  is_hns_enabled           = var.storage_account_is_hns_enabled
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_gen2_filesystem" {
  name               = var.adlsname
  storage_account_id = azurerm_storage_account.storage_account.id

  properties = {
    hello = "aGVsbG8="
  }
}

resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = var.synapse_name
  resource_group_name                  = azurerm_resource_group.resource_group.name
  location                             = azurerm_resource_group.resource_group.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.data_lake_gen2_filesystem.id

  aad_admin {
    login     = var.synapse_aad_name
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
  }

  identity {
    type = var.assign_identity_type
  }

}