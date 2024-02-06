terraform {
  required_version = "1.7.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"      
      version = "3.90.0"
    }
    databricks = {
      source = "databricks/databricks"
      version = "1.34.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.databricks_workspace.id
}

#________________________PARAMETERS________________________#
data azurerm_client_config current {}

