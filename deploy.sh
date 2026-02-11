#!/bin/bash

# SWARM Deployment Script for Railway + Cloudflare
# This script helps automate the deployment process

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          SWARM Deployment to Railway + Cloudflare           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo -e "${BLUE}[1/7] Checking prerequisites...${NC}"
if ! command -v railway &> /dev/null; then
    echo -e "${RED}✗ Railway CLI not found${NC}"
    exit 1
fi
if ! command -v wrangler &> /dev/null; then
    echo -e "${RED}✗ Wrangler CLI not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Railway CLI installed${NC}"
echo -e "${GREEN}✓ Wrangler CLI installed${NC}"
echo ""

# Step 2: Generate secure keys
echo -e "${BLUE}[2/7] Generating secure keys...${NC}"
SESSION_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)
ENCRYPTION_SALT=$(openssl rand -hex 32)
echo -e "${GREEN}✓ Keys generated${NC}"
echo ""
echo "Save these values:"
echo -e "${YELLOW}SESSION_SECRET=${SESSION_SECRET}${NC}"
echo -e "${YELLOW}ENCRYPTION_KEY=${ENCRYPTION_KEY}${NC}"
echo -e "${YELLOW}ENCRYPTION_SALT=${ENCRYPTION_SALT}${NC}"
echo ""

# Step 3: Database setup instructions
echo -e "${BLUE}[3/7] Database Setup${NC}"
echo ""
echo "Please create a Neon database:"
echo "1. Go to: ${BLUE}https://neon.tech/${NC}"
echo "2. Sign up / Log in"
echo "3. Create new project: 'swarm-production'"
echo "4. Copy the connection string"
echo ""
read -p "Press Enter when you have your DATABASE_URL ready..."
echo ""
read -p "Paste your DATABASE_URL: " DATABASE_URL
echo ""

# Step 4: API Keys
echo -e "${BLUE}[4/7] AI Provider API Keys${NC}"
echo ""
echo "Enter at least ONE AI provider API key:"
echo ""
read -p "OpenAI API Key (or press Enter to skip): " OPENAI_API_KEY
read -p "Anthropic API Key (or press Enter to skip): " ANTHROPIC_API_KEY
read -p "Gemini API Key (or press Enter to skip): " GEMINI_API_KEY
echo ""

if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${RED}✗ At least one AI provider API key is required${NC}"
    exit 1
fi

# Step 5: Railway login and setup
echo -e "${BLUE}[5/7] Setting up Railway...${NC}"
echo "Opening browser for Railway authentication..."
railway login

echo ""
echo "Initializing Railway project..."
railway init

echo ""
echo "Setting environment variables..."
railway variables set DATABASE_URL="$DATABASE_URL"
railway variables set SESSION_SECRET="$SESSION_SECRET"
railway variables set ENCRYPTION_KEY="$ENCRYPTION_KEY"
railway variables set ENCRYPTION_SALT="$ENCRYPTION_SALT"
railway variables set NODE_ENV="production"
railway variables set PORT="5000"

if [ ! -z "$OPENAI_API_KEY" ]; then
    railway variables set OPENAI_API_KEY="$OPENAI_API_KEY"
fi
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    railway variables set ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
fi
if [ ! -z "$GEMINI_API_KEY" ]; then
    railway variables set GEMINI_API_KEY="$GEMINI_API_KEY"
fi

echo -e "${GREEN}✓ Environment variables set${NC}"
echo ""

# Step 6: Deploy backend to Railway
echo -e "${BLUE}[6/7] Deploying backend to Railway...${NC}"
echo "This may take 2-3 minutes..."
railway up

echo ""
echo "Generating public domain..."
railway domain

echo ""
echo "Running database migrations..."
railway run npm run db:push

echo ""
echo -e "${GREEN}✓ Backend deployed!${NC}"
echo ""

# Get Railway URL
echo "Getting your backend URL..."
RAILWAY_URL=$(railway status --json 2>/dev/null | grep -o '"url":"[^"]*"' | cut -d'"' -f4 || echo "")

if [ -z "$RAILWAY_URL" ]; then
    echo -e "${YELLOW}⚠ Could not automatically detect Railway URL${NC}"
    echo "Please get it from: railway status"
    read -p "Paste your Railway backend URL: " RAILWAY_URL
fi

echo ""
echo -e "${GREEN}Backend URL: ${RAILWAY_URL}${NC}"
echo ""

# Step 7: Deploy frontend to Cloudflare
echo -e "${BLUE}[7/7] Deploying frontend to Cloudflare...${NC}"
echo ""
echo "Logging into Cloudflare..."
wrangler login

echo ""
echo "Building frontend with backend URL..."
export VITE_API_URL="$RAILWAY_URL"
npm run build

echo ""
echo "Deploying to Cloudflare Pages..."
wrangler pages deploy dist/public --project-name=swarm

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  🎉 DEPLOYMENT COMPLETE! 🎉                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Your SWARM is now live!${NC}"
echo ""
echo -e "${BLUE}Backend:${NC} $RAILWAY_URL"
echo -e "${BLUE}Frontend:${NC} Check the Cloudflare output above"
echo ""
echo "Next steps:"
echo "1. Test backend health: curl $RAILWAY_URL/api/health"
echo "2. Visit your frontend URL"
echo "3. Create a test workflow"
echo ""
echo "View logs:"
echo "  Railway: railway logs"
echo "  Cloudflare: wrangler pages deployment tail"
echo ""
echo "Documentation: ./DEPLOYMENT_STEPS.md"
echo ""
