# Bootstrap Resource Group for remote state
resource "azurerm_resource_group" "tfstate_rg" {
  name     = "rg-tfstate-dev"
  location = "eastus"
}

# Storage Account for Terraform state
resource "azurerm_storage_account" "tfstate_sa" {
  name                     = "sttfstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate_rg.name
  location                 = azurerm_resource_group.tfstate_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false

  min_tls_version = "TLS1_2"
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }
}

# Random suffix so the storage account name is globally unique
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Container to hold terraform state blobs
resource "azurerm_storage_container" "tfstate_container" {
  name                  = "tfstate"
  storage_account_id   = azurerm_storage_account.tfstate_sa.id
  container_access_type = "private"
}

# Useful outputs for the main config
output "tfstate_resource_group_name" {
  value = azurerm_resource_group.tfstate_rg.name
}

output "tfstate_storage_account_name" {
  value = azurerm_storage_account.tfstate_sa.name
}

output "tfstate_container_name" {
  value = azurerm_storage_container.tfstate_container.name
}

output "tfstate_key_example" {
  value = "global-dev.tfstate"
}

