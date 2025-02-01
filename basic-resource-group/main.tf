# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # version = "~> 3.0.2"
    }
  }

  # required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  # subscription_id = "xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-demo"
  location = "uksouth"
}
