


#________________________RESOURCE GROUP________________________#
resource azurerm_resource_group resource_group {
    name     = var.rgname
    location = var.location
}




#________________________DATA FACTORY________________________#
# resource azurerm_data_factory data_factory {
#   name                = var.adfname
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
#     identity {
#       type = var.assign_identity_type
#     }
# }




#________________________AZURE DATABRICKS SETUP________________________#
resource azurerm_databricks_workspace databricks_workspace {
  name                = var.dbksname
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = var.dbks_sku_type
}

resource azurerm_databricks_access_connector databricks_access_connector {
  name                = var.databricks_access_connector_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  identity {
    type = var.databricks_access_conector_assign_identity_type
  }
}



#________________________STORAGE________________________#
resource azurerm_storage_account storage_account {
  name                     = var.adlsname
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind
  is_hns_enabled           = var.storage_account_is_hns_enabled
}

resource azurerm_storage_data_lake_gen2_filesystem data_lake_gen2_filesystem {
  name               = var.adlsname
  storage_account_id = azurerm_storage_account.storage_account.id
}

resource "azurerm_storage_account" "metastore_storage_account" {
  name                     = var.metastore_storage_account_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "container" {
  name                  = var.metastore_container_name
  storage_account_name  = azurerm_storage_account.metastore_storage_account.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "role_assignment_access_conector_databricks" {
  scope                = azurerm_storage_account.metastore_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.databricks_access_connector.identity[0].principal_id
}



#________________________KEY VAULT SETUP________________________#
# resource azurerm_key_vault key_vault {
#   name                        = var.keyvaultname
#   location                    = azurerm_resource_group.resource_group.location
#   resource_group_name         = azurerm_resource_group.resource_group.name
#   enabled_for_disk_encryption = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false

#   sku_name = var.kv_sku_type
#   }

# resource azurerm_key_vault_access_policy access_policy0 {
#     key_vault_id = azurerm_key_vault.key_vault.id
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = azurerm_data_factory.data_factory.identity[0].principal_id

#     key_permissions = [ 
#       "Get",  
#       "List", 
#     ]

#     secret_permissions = [
#       "Get",
#       "List", 
#     ]

#     storage_permissions = [
#       "Get", 
#       "GetSAS", 
#       "List", 
#       "ListSAS", 
#     ]
# }



#________________________DATABRICKS WORKSPACE SETUP________________________#
data databricks_node_type smallest {
  local_disk = true
}

data databricks_spark_version standard {
  spark_version = "3.4.1"
  gpu = false
  ml  = false
  long_term_support = false
}

resource databricks_cluster cluster{
  cluster_name = "cluster_do_flavin"
  spark_version = data.databricks_spark_version.standard.id
  node_type_id = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  autoscale {
    min_workers = 1
    max_workers = 2
  }
}

resource "databricks_cluster" "single_node" {
  cluster_name = "single_node cluster"
  num_workers = 0
  spark_version = "13.3.x-scala2.12"
  node_type_id = "Standard_DS3_v2"
  driver_node_type_id = "Standard_DS3_v2"
  single_user_name = "leandrochinellipereira@gmail.com"
  
  spark_conf = {
    "spark.master" = "local[*, 4]"
    "spark.databricks.cluster.profile" = "singleNode"
  }

  azure_attributes {
    first_on_demand = 1
    availability = "ON_DEMAND_AZURE"
    spot_bid_max_price = -1
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }

  spark_env_vars = {
    "PYSPARK_PYTHON" = "/databricks/python3/bin/python3"
  }

  autotermination_minutes = 10
  enable_elastic_disk = true
  enable_local_disk_encryption = false
  data_security_mode = "LEGACY_SINGLE_USER_STANDARD"
  runtime_engine = "PHOTON"
}