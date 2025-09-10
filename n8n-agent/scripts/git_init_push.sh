#!/usr/bin/env bash
set -euo pipefail

# GitHub Sync: Initialize repository and push to remote
echo "=== GitHub Sync: Init & Push ==="

# Check if git is initialized
if [[ ! -d .git ]]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "feat: initial n8n-agent scaffold with proof collection"
fi

# Check if remote is set
if ! git remote get-url origin &>/dev/null; then
    read -p "Enter GitHub repository URL (https://github.com/username/repo.git): " repo_url
    if [[ -n "$repo_url" ]]; then
        git remote add origin "$repo_url"
        echo "$repo_url" > ./evidence/GIT_REMOTE.txt
    else
        echo "No repository URL provided. Skipping remote setup."
        exit 0
    fi
fi

# Push to remote
echo "Pushing to remote repository..."
git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || {
    echo "Push failed. You may need to set up authentication or create the repository first."
    echo "Repository URL saved to ./evidence/GIT_REMOTE.txt"
}

echo "GitHub sync completed!"
echo "Repository: $(cat ./evidence/GIT_REMOTE.txt 2>/dev/null || echo 'Not set')"
