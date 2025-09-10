#!/usr/bin/env bash
set -euo pipefail

# CI Safety Check: Verify required secrets are set
echo "=== CI Safety Check ==="

REQUIRED_SECRETS=("SSH_HOST" "SSH_USER" "SSH_KEY" "N8N_BASE_URL" "N8N_API_KEY" "SLACK_WEBHOOK_URL")

echo "Checking required secrets..."
for secret in "${REQUIRED_SECRETS[@]}"; do
    # In GitHub Actions, secrets would be available as environment variables
    # For local testing, we'll check if they're defined
    if [[ -z "${!secret:-}" ]]; then
        echo "❌ Missing secret: $secret"
        MISSING_SECRETS+=("$secret")
    else
        echo "✅ Found secret: $secret"
    fi
done

if [[ ${#MISSING_SECRETS[@]} -gt 0 ]]; then
    echo ""
    echo "🚨 MISSING SECRETS DETECTED:"
    printf '  - %s\n' "${MISSING_SECRETS[@]}"
    echo ""
    echo "📝 ACTION REQUIRED:"
    echo "   1. Go to GitHub Repository → Settings → Secrets and variables → Actions"
    echo "   2. Add the missing secrets listed above"
    echo "   3. Re-run the workflow"
    exit 1
else
    echo ""
    echo "🎉 All required secrets are present!"
    echo "   CI/CD pipeline should run successfully."
fi
