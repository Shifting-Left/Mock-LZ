# Dockerfile for a custom GitHub Codespaces environment
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# --- Install System-level Tools & Dependencies ---
# Switch to the root user to perform system-level installations
USER root

# Install prerequisites for adding new repositories and tools
RUN apt-get update && apt-get install -y \
    gnupg software-properties-common wget ca-certificates curl apt-transport-https lsb-release python3-pip \
    jq \
 && rm -rf /var/lib/apt/lists/*

# Add the HashiCorp GPG key and repository for Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list

# Add the Microsoft GPG key and repository for Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list

# Update package list and install Terraform and Azure CLI
RUN apt-get update && apt-get install -y terraform azure-cli && rm -rf /var/lib/apt/lists/*

# Install gitleaks
ENV GITLEAKS_VERSION="8.18.2"
RUN wget -O /tmp/gitleaks.tar.gz "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
 && tar -xzf /tmp/gitleaks.tar.gz -C /tmp \
 && mv /tmp/gitleaks /usr/local/bin/gitleaks \
 && rm /tmp/gitleaks.tar.gz

# Install Open Policy Agent (OPA)
RUN curl -L -o /usr/local/bin/opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static && \
    chmod +x /usr/local/bin/opa

# --- Add Checkov ---
# Pin to a known-good version; latest on PyPI as of now is 3.2.469
ARG CHECKOV_VERSION=3.2.469
RUN pip3 install --no-cache-dir "checkov==${CHECKOV_VERSION}"

# --- Optional: Helm v3 for Helm chart scanning with Checkov ---
# Enable at build time: docker build --build-arg INSTALL_HELM=true ...
ARG INSTALL_HELM=false
RUN if [ "$INSTALL_HELM" = "true" ]; then \
      curl https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg && \
      echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm-stable-debian.list && \
      apt-get update && apt-get install -y helm && \
      rm -rf /var/lib/apt/lists/* ; \
    fi

# Switch back to the non-root 'vscode' user for security
USER vscode
