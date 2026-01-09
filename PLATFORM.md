# GITHUB Platform - DEVELOPMENT Environment

## Quick Start
Development testing environment for GitHub Pages deployment.

**Platform:** GitHub Pages  
**Environment:** Development/Testing  
**URL:** Separate testing repository or dev subdomain  
**Purpose:** Integration testing before staging

## Deployment

Auto-deploys on push to `github-development`:
```bash
git checkout github-development
git merge feature-branch
git push origin github-development
```

## Environment Configuration

**Branch Protection:**
- Requires 1 approving review
- Must pass all tests
- Development features merged here first

**Testing Focus:**
- Integration testing
- Feature validation
- Bug reproduction
- Performance testing

## Key Differences from Production
- Verbose logging enabled
- Debug mode active
- Test data prefilled
- Relaxed rate limits

**Branch:** `github-development` | **Platform:** `GITHUB` | **Environment:** `DEVELOPMENT`