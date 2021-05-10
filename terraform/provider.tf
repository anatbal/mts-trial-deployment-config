terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.42"
    }
  }

  backend "azurerm" {
    # including the resource group allows us to supply just 1 secret for access.
    # however, this assumes that the terraform state storage account is on the same subscription as the resources deployed.
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "cseterraformbackend"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}