# BAckend stored within https://app.terraform.io/ aka terraform cloud
terraform { 
  cloud { 
    
    organization = "Patient-0" 

    workspaces { 
      name = "Mock-LZ" 
    } 
  }
  
}

provider "azurerm" {
    features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    }
    storage_use_azuread = true
    
    
}

