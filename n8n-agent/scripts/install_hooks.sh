#!/usr/bin/env bash
set -euo pipefail

# Install Git Hooks: Pre-commit hook for automatic reporting
echo "=== Installing Git Hooks ==="

HOOKS_DIR=.git/hooks
PRE_COMMIT=$HOOKS_DIR/pre-commit

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Create pre-commit hook
cat > "$PRE_COMMIT" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "=== Pre-commit Hook: Generating Reports ==="

# Generate proof report
if [[ -f scripts/proof_report.sh ]]; then
    ./scripts/proof_report.sh
    git add ./evidence/REPORT.md
    echo "Proof report updated and staged"
fi

# Generate git report
if [[ -f scripts/git_report.sh ]]; then
    ./scripts/git_report.sh
    git add ./evidence/GIT_REPORT.md
    echo "Git report updated and staged"
fi

# Generate audit log
if [[ -f scripts/audit_aggregate.sh ]]; then
    ./scripts/audit_aggregate.sh
    git add ./evidence/AUDIT_LOG.md
    echo "Audit log updated and staged"
fi

echo "All reports generated and staged for commit"
EOF

# Make hook executable
chmod +x "$PRE_COMMIT"

echo "Pre-commit hook installed at $PRE_COMMIT"
echo "Reports will be automatically generated before each commit"
