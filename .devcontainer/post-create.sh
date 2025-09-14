#!/usr/bin/env bash
set -euo pipefail

echo "==> Post-create starting..."

# If you want to debug, uncomment:
# set -x

# (A) Optional dev-time tools
# NOTE: Global npm installs may fail due to permissions in some environments.
# If you actually need these, keep them; otherwise you can remove or make them non-blocking.
echo "==> Installing optional Node dev tools (non-blocking)..."
npm install -g pnpm azure-functions-core-tools@4 || echo "WARN: Skipping npm global install (pnpm/azure-functions-core-tools)."

# (B) Terraform Cloud token
echo "==> Writing Terraform Cloud credentials..."
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
# If TF_API_TOKEN was not set, we'll continue—but terraform may need it later.
if [ -z "${TF_API_TOKEN:-}" ]; then
  echo "WARN: TF_API_TOKEN is empty. Set a Codespaces secret named TF_API_TOKEN for Terraform Cloud."
fi
# (C) Git safe.directory (use the *actual* current dir; avoids variable expansion issues)
echo "==> Marking workspace as safe for Git..."
git config --global --add safe.directory "$(pwd)" || true

# (D) Ensure your custom .gitignore blocker script is executable (if present)
if [ -f scripts/block-ignored-files.sh ]; then
  echo "==> Ensuring scripts/block-ignored-files.sh is executable..."
  chmod +x scripts/block-ignored-files.sh || true
fi

# (E) Install and activate pre-commit hooks
echo "==> Installing pre-commit hooks..."
pre-commit install --hook-type pre-commit --hook-type pre-push

# (F) One-time sweep of the whole repo (non-blocking for container creation)
echo "==> Running pre-commit across all files (non-blocking)..."
pre-commit run --all-files || echo "WARN: pre-commit reported issues on initial scan."

# (G) Quick sanity checks (non-blocking)
echo "==> Tool versions:"
terraform -version || echo "WARN: terraform not found"
gitleaks version || echo "WARN: gitleaks not found"
detect-secrets --version || echo "WARN: detect-secrets not found"

echo "==> Post-create finished."
