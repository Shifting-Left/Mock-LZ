# Dockerfile for a custom GitHub Codespaces environment
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# --- Install System-level Tools & Dependencies ---
# Switch to the root user to perform system-level installations
USER root

# Install prerequisites for adding new repositories and tools
RUN apt-get update && apt-get install -y gnupg software-properties-common wget ca-certificates curl apt-transport-https lsb-release python3-pip

# Add the HashiCorp GPG key and repository for Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Add the Microsoft GPG key and repository for Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list

# Update package list and install Terraform and Azure CLI
RUN apt-get update && apt-get install -y terraform azure-cli

# Install gitleaks
RUN GITLEAKS_VERSION="8.18.2" && \
    wget "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -O gitleaks.tar.gz && \
    tar -xzf gitleaks.tar.gz && \
    mv gitleaks /usr/local/bin/gitleaks && \
    rm gitleaks.tar.gz

# Install Open Policy Agent (OPA)
RUN curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static && \
    chmod +x opa && \
    mv opa /usr/local/bin/opa

# Switch back to the non-root 'vscode' user for security
USER vscode