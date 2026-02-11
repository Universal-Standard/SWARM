# SWARM Deployment Steps - Railway + Cloudflare + Neon

## 🎯 Deployment Architecture

```
Frontend (Cloudflare Pages) → Backend (Railway) → Database (Neon PostgreSQL)
```

---

## Step 1: Set Up Neon Database (5 minutes)

### 1.1 Create Neon Account
1. Go to https://neon.tech/
2. Click "Sign Up" (use GitHub for quick signup)
3. Create a new project:
   - **Project Name**: swarm-production
   - **Region**: Choose closest to you
   - **PostgreSQL Version**: 16 (recommended)

### 1.2 Get Connection String
1. After project creation, you'll see the connection details
2. Copy the **Connection String** (looks like):
   ```
   postgresql://username:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```
3. **SAVE THIS** - you'll need it for Railway

**Free Tier**: 0.5GB storage, 3GB data transfer/month (plenty for starting)

---

## Step 2: Generate Secure Keys (1 minute)

Run these commands to generate secure encryption keys:

```bash
# Generate SESSION_SECRET
echo "SESSION_SECRET=$(openssl rand -hex 32)"

# Generate ENCRYPTION_KEY
echo "ENCRYPTION_KEY=$(openssl rand -hex 32)"

# Generate ENCRYPTION_SALT
echo "ENCRYPTION_SALT=$(openssl rand -hex 32)"
```

**SAVE THESE VALUES** - you'll add them to Railway.

---

## Step 3: Deploy Backend to Railway (10 minutes)

### 3.1 Install Railway CLI (if not installed)
```bash
npm install -g @railway/cli
```

### 3.2 Login to Railway
```bash
railway login
```
This will open your browser - authorize the CLI.

### 3.3 Initialize Railway Project
```bash
cd /home/user/SWARM-1

# Create new Railway project
railway init

# When prompted:
# - Choose "Empty Project"
# - Name it: swarm-api
```

### 3.4 Add Environment Variables
```bash
# Database URL (use your Neon connection string)
railway variables set DATABASE_URL="postgresql://username:password@ep-xxx.neon.tech/neondb?sslmode=require"

# Security keys (use generated values from Step 2)
railway variables set SESSION_SECRET="your-generated-secret"
railway variables set ENCRYPTION_KEY="your-generated-key"
railway variables set ENCRYPTION_SALT="your-generated-salt"

# Node environment
railway variables set NODE_ENV="production"
railway variables set PORT="5000"

# AI API Keys (add at least one)
railway variables set OPENAI_API_KEY="sk-your-openai-key"
# Or/And
railway variables set ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"
# Or/And
railway variables set GEMINI_API_KEY="your-gemini-key"
```

### 3.5 Deploy to Railway
```bash
# Deploy your app
railway up

# Wait for deployment (2-3 minutes)
# You'll see build logs
```

### 3.6 Get Your Backend URL
```bash
# Generate a public domain
railway domain

# Get the status and URL
railway status
```

Your backend will be available at something like:
```
https://swarm-api-production-xxxx.up.railway.app
```

**SAVE THIS URL** - you'll need it for the frontend.

### 3.7 Run Database Migrations
```bash
# Connect to Railway and run migrations
railway run npm run db:push
```

---

## Step 4: Deploy Frontend to Cloudflare Pages (5 minutes)

### 4.1 Login to Wrangler (if not done)
```bash
wrangler login
```

### 4.2 Build Frontend with Backend URL
```bash
cd /home/user/SWARM-1

# Set your Railway backend URL
export VITE_API_URL="https://your-backend.up.railway.app"

# Build the frontend
npm install
npm run build
```

### 4.3 Deploy to Cloudflare Pages
```bash
# Deploy using Wrangler
wrangler pages deploy dist/public --project-name=swarm

# Or if you want to use a different name
wrangler pages deploy dist/public --project-name=swarm-app
```

### 4.4 Get Your Frontend URL
After deployment, you'll see:
```
✅ Success! Uploaded X files (Y.yy sec)
✨ Deployment complete! Take a peek over at
   https://xxxxxxxx.swarm.pages.dev
```

---

## Step 5: Verify Deployment (2 minutes)

### 5.1 Test Backend Health
```bash
curl https://your-backend.up.railway.app/api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-11T...",
  "uptime": 123,
  "environment": "production"
}
```

### 5.2 Test Frontend
1. Open your Cloudflare Pages URL in a browser
2. You should see the SWARM landing page
3. Try navigating to `/app/workflows`

### 5.3 Test Full Workflow
1. Create a test workflow
2. Add an agent node
3. Configure the agent
4. Execute the workflow
5. Verify execution completes

---

## 🎉 Deployment Complete!

Your SWARM is now live:
- **Frontend**: https://xxx.pages.dev (Cloudflare)
- **Backend**: https://xxx.up.railway.app (Railway)
- **Database**: Neon PostgreSQL

---

## 📝 Post-Deployment Tasks

### Optional: Add Custom Domain

**For Cloudflare Pages**:
1. Go to Cloudflare Dashboard
2. Pages → Your Project → Custom domains
3. Add your domain
4. Update DNS records

**For Railway Backend**:
1. Railway Dashboard → Your Service → Settings
2. Add custom domain
3. Update DNS records

### Optional: Enable Monitoring

**Railway**:
- View logs: `railway logs`
- View metrics: Railway Dashboard → Metrics

**Cloudflare**:
- Analytics: Cloudflare Dashboard → Analytics

### Optional: Set Up Alerts

**Railway**:
- Dashboard → Settings → Notifications
- Set up email/Slack alerts for downtime

---

## 🆘 Troubleshooting

### Backend won't start on Railway
```bash
# Check logs
railway logs

# Common issues:
# 1. Missing environment variables
railway variables

# 2. Database connection failed
# - Verify DATABASE_URL is correct
# - Check Neon database is active

# 3. Build failed
# - Check package.json scripts
# - Verify all dependencies are in package.json
```

### Frontend can't connect to backend
```bash
# 1. Verify VITE_API_URL was set during build
# 2. Rebuild with correct URL:
export VITE_API_URL="https://your-backend.up.railway.app"
npm run build
wrangler pages deploy dist/public --project-name=swarm
```

### Database migrations failed
```bash
# Run migrations manually
railway run npm run db:push

# Or generate and push
railway run npm run db:generate
railway run npm run db:push
```

---

## 💰 Current Costs

- **Cloudflare Pages**: $0 (free forever)
- **Railway**: $5 credit (lasts 2-4 weeks)
- **Neon Database**: $0 (free tier)
- **Total**: $0 for first 2-4 weeks, then $5/month

---

## 🚀 Next Steps

1. **Add AI API Keys** if you haven't:
   ```bash
   railway variables set OPENAI_API_KEY="your-key"
   ```

2. **Test Workflow Execution**:
   - Create a workflow
   - Add agents with AI providers
   - Execute and verify

3. **Monitor Usage**:
   - Railway Dashboard: Check resource usage
   - Neon Dashboard: Check database size
   - Cloudflare Analytics: Check traffic

4. **Scale as Needed**:
   - When Railway credit runs out, add payment method
   - If database > 0.5GB, upgrade Neon
   - If traffic is high, optimize or scale Railway

---

**Deployment Guide Complete!** 🎊

Questions? Check:
- Railway docs: https://docs.railway.app/
- Neon docs: https://neon.tech/docs/
- Cloudflare docs: https://developers.cloudflare.com/pages/
