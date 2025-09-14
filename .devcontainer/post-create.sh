#!/usr/bin/env bash
set -euo pipefail

# Dev-time tools
npm install -g pnpm azure-functions-core-tools@4

# Terraform Cloud credentials file from secret
mkdir -p ~/.terraform.d
cat > ~/.terraform.d/credentials.tfrc.json <<JSON
{
  "credentials": {
    "app.terraform.io": {
      "token": "${TF_API_TOKEN:-}"
    }
  }
}
JSON
# Git inside container may consider the workspace unsafe without this
git config --global --add safe.directory ${containerWorkspaceFolder}

# Ensure your custom .gitignore blocker script is executable (if present)
if [ -f scripts/block-ignored-files.sh ]; then chmod +x scripts/block-ignored-files.sh; fi

# Install and activate pre-commit hooks (pre-commit + pre-push)
pre-commit install --hook-type pre-commit --hook-type pre-push

# One-time sweep of the whole repo (won't fail the container build)
pre-commit run --all-files || true

# Quick sanity checks (optional)
terraform -version
gitleaks version || true
detect-secrets --version || true
