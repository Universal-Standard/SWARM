#!/bin/bash

# Script to push all platform-specific branches to remote repository
# This script should be run by a user with push access to the repository

echo "Pushing all 16 platform-specific branches to remote..."
echo ""

# GitHub branches
echo "📍 Pushing GitHub branches..."
git push origin github-main github-development github-features github-staging

# Cloudflare branches
echo "📍 Pushing Cloudflare branches..."
git push origin cloudflare-main cloudflare-development cloudflare-features cloudflare-staging

# Azure branches
echo "📍 Pushing Azure branches..."
git push origin azure-main azure-development azure-features azure-staging

# AWS branches
echo "📍 Pushing AWS branches..."
git push origin aws-main aws-development aws-features aws-staging

echo ""
echo "✅ All 16 branches have been pushed to remote repository"
echo ""
echo "Verify with: git branch -r | grep -E '(github|cloudflare|azure|aws)'"
