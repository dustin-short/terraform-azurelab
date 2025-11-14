terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.52.0" # latest major at time of writing
    }
  }
}

provider "azurerm" {
  features {}

  # For personal use, Azure CLI auth is simplest
  use_cli = true
}
