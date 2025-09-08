# Secure Azure Storage and Key Vault with Terraform

This Terraform project deploys a highly secure Azure Storage Account and Key Vault. The infrastructure is designed with a security-first approach, disabling public network access and leveraging **private endpoints** to ensure all traffic remains on the Azure private network. 🔐

The Storage Account is configured to use a **customer-managed key (CMK)**, which is securely stored and managed within the deployed Azure Key Vault.



***

## Architecture Overview

This configuration provisions the following core components:

* **A Resource Group** to contain all the created resources.
* **A Virtual Network (VNet)** and a dedicated **Subnet**.
* An **Azure Storage Account** with:
    * Public access disabled.
    * A private endpoint for secure access from the VNet.
    * Encryption configured using a customer-managed key from the Key Vault.
    * A system-assigned managed identity.
* An **Azure Key Vault** with:
    * RBAC for authorization.
    * Public access restricted to one IP.
    * A private endpoint for secure access from the VNet.
* An **RSA Key** within the Key Vault for the storage account's encryption.
* **Role Assignments** to grant necessary permissions:
    * The Storage Account's identity gets the "Key Vault Crypto Officer" role to access the encryption key.
    * The identity running Terraform gets the "Key Vault Administrator" role for setup.
    * A specified user gets the "Storage Blob Data Contributor" role for data access.

***

## Prerequisites

Before you begin, ensure you have the following:

* An active **Azure Subscription**.
* **Terraform CLI** (v1.0.0 or later) installed.
* **Azure CLI** installed and authenticated (`az login`).
* A **Terraform Cloud** account.

***

## Configuration & Deployment 🚀

This project is configured to use Terraform Cloud as the backend for state management.

### 1. Configure Terraform Cloud

The `terraform` block in the configuration file is already set up to connect to Terraform Cloud. Make sure your organization and workspace names match your setup.

```hcl
terraform {
  cloud {
    organization = "Patient-0"
    workspaces {
      name = "Mock-LZ"
    }
  }
}
