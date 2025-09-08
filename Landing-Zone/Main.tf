data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = false
  numeric = true
  special = false
}

# Assign Key Vault Crypto Officer role to the Storage Account's managed identity
resource "azurerm_role_assignment" "storage_keyvault_role" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_storage_account.strg.identity[0].principal_id
}

# Assign Key Vault Administrator role to the Terraform principal for unrestricted access to AKV
resource "azurerm_role_assignment" "terraform_keyvault_role" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "specific_user_blob_reader" {
  scope                = azurerm_storage_account.strg.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.user1_object_id
  principal_type       = "User"
}

resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${azurerm_resource_group.rg.name}"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
    name                 = var.subnet_name
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
    service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_storage_account" "strg" {
  name                = "storage-${azurerm_resource_group.rg.name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  https_traffic_only_enabled = true
  min_tls_version         = "TLS1_2"
  public_network_access_enabled = false # Public networking is disabled. As such the browser hits the public endpoint and is blocked (data plane access). Access is only possible via the private endpoint.
  allow_nested_items_to_be_public = false
  shared_access_key_enabled = false
  sftp_enabled = false
  network_rules {
    default_action             = "Deny"
    ip_rules                   = [var.Home_PIP]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_key_vault" "keyvault" {

    name                        = "vault-${azurerm_resource_group.rg.name}-${random_string.suffix.result}"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name                    = "standard"
    purge_protection_enabled    = true
    rbac_authorization_enabled = true
    public_network_access_enabled = false # Public networking is disabled. As such the browser hits the public endpoint and is blocked (data plane access). Access is only possible via the private endpoint.

    network_acls {
        default_action = "Deny"
        bypass         = "AzureServices"

        ip_rules = [var.Home_PIP]
    }
    
}

resource "azurerm_key_vault_key" "key" {
    name         = "key1-${azurerm_resource_group.rg.name}"
    key_vault_id = azurerm_key_vault.keyvault.id
    key_type     = "RSA"
    key_size     = 2048
    key_opts     = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]
}

resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.strg.id
  key_vault_id       = azurerm_key_vault.keyvault.id
  key_name           = azurerm_key_vault_key.key.name
}

resource "azurerm_private_endpoint" "storage_pe" {
    name                = "${var.private_endpoint_name}-storage"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id           = azurerm_subnet.subnet.id

    private_service_connection {
        name                           = "storageConnection"
        private_connection_resource_id = azurerm_storage_account.strg.id
        subresource_names              = ["blob"]
        is_manual_connection           = false
    }
}

resource "azurerm_private_endpoint" "keyvault_pe" {
    name                = "${var.private_endpoint_name}-keyvault"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id           = azurerm_subnet.subnet.id

    private_service_connection {
        name                           = "keyVaultConnection"
        private_connection_resource_id = azurerm_key_vault.keyvault.id
        subresource_names              = ["vault"]
        is_manual_connection           = false
    }
}

resource "azurerm_storage_container" "container" {
  name                  = "content"
  storage_account_id    = azurerm_storage_account.strg.id
  container_access_type = "private"
}

