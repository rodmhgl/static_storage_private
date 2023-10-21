# azurerm provider versions 3.75.0 and 3.76.0 produce errors
# when working with static_website and azurerm_storage_account
# Status=400 Code="InvalidXmlDocument" Message="XML specified is not syntactically valid.
# Pinning to ~> 3.74.0 for now. 

terraform {
  required_version = "~> 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}