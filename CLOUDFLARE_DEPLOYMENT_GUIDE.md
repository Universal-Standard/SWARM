# Cloudflare Deployment - Complete Guide

## Architecture Overview

SWARM uses a **hybrid deployment** for optimal performance:

```
┌─────────────────────────────────────────────────────────┐
│                  Cloudflare Pages                        │
│  Frontend (React SPA) - Static Assets                   │
│  Global CDN - <50ms latency worldwide                   │
└─────────────────────────────────────────────────────────┘
                         │
                         │ API Calls
                         ▼
┌─────────────────────────────────────────────────────────┐
│           Backend API (Node.js + Express)                │
│  Options: Railway / Render / Fly.io / Docker            │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Database (PostgreSQL)                       │
│  Neon / Supabase / Self-hosted                          │
└─────────────────────────────────────────────────────────┘
```

## Why Hybrid Deployment?

The SWARM backend uses Node.js-specific features not compatible with Cloudflare Workers:
- Express.js framework
- WebSocket (`ws` library)
- `http.createServer()`
- Session management
- PostgreSQL connection pooling

**Solution**: Deploy frontend to Cloudflare Pages + backend to a Node.js platform.

---

## 🚀 Quick Start (Recommended)

### Option 1: Cloudflare Pages + Railway (Easiest)

**Total Time**: ~15 minutes
**Cost**: $0-5/month

#### Step 1: Deploy Backend to Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project (choose "Empty Project")
railway init

# Link to your GitHub repo (or deploy directly)
railway link

# Add environment variables
railway variables set DATABASE_URL="your-postgres-url"
railway variables set SESSION_SECRET="$(openssl rand -hex 32)"
railway variables set ENCRYPTION_KEY="$(openssl rand -hex 32)"
railway variables set ENCRYPTION_SALT="$(openssl rand -hex 32)"
railway variables set OPENAI_API_KEY="your-key"
railway variables set ANTHROPIC_API_KEY="your-key"

# Deploy
railway up

# Get your backend URL
railway status
# Note the URL (e.g., https://swarm-api.railway.app)
```

#### Step 2: Deploy Frontend to Cloudflare Pages

```bash
# Login to Cloudflare
wrangler login

# Build frontend with backend URL
export VITE_API_URL="https://your-backend.railway.app"
npm run build

# Deploy to Pages
wrangler pages deploy dist/public --project-name=swarm

# Or connect GitHub repo in Cloudflare Dashboard
# https://dash.cloudflare.com/ → Pages → Create a project
```

**Done!** Your app is live on Cloudflare Pages.

---

## Option 2: Cloudflare Pages + Render

#### Step 1: Deploy Backend to Render

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click "New" → "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Name**: swarm-api
   - **Environment**: Node
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Environment Variables**:
     ```
     DATABASE_URL=your-postgres-url
     SESSION_SECRET=your-secret
     ENCRYPTION_KEY=your-key
     ENCRYPTION_SALT=your-salt
     OPENAI_API_KEY=your-key
     ANTHROPIC_API_KEY=your-key
     NODE_ENV=production
     PORT=5000
     ```
5. Click "Create Web Service"
6. Note your service URL (e.g., https://swarm-api.onrender.com)

#### Step 2: Deploy Frontend to Cloudflare Pages

Same as Option 1, Step 2.

---

## Option 3: Full Docker Deployment

If you prefer self-hosting with Docker:

```bash
# Use docker-compose with external database
docker-compose up -d

# Or deploy to a cloud provider with Docker support
# (DigitalOcean, AWS ECS, Google Cloud Run, etc.)
```

See [DOCKER_GUIDE.md](DOCKER_GUIDE.md) for details.

---

## 📝 Detailed Cloudflare Pages Setup

### Using Cloudflare Dashboard (Recommended)

1. **Go to Cloudflare Dashboard**
   - Visit: https://dash.cloudflare.com/
   - Navigate to: Pages → Create a project

2. **Connect GitHub Repository**
   - Select your SWARM repository
   - Configure build settings:
     ```
     Framework preset: None (or Vite)
     Build command: npm run build
     Build output directory: dist/public
     Root directory: /
     ```

3. **Set Environment Variables**
   - Click on your project → Settings → Environment variables
   - Add:
     ```
     NODE_VERSION=22
     VITE_API_URL=https://your-backend-url.com
     ```

4. **Deploy**
   - Cloudflare will automatically build and deploy
   - Your site will be live at: `https://swarm-xxx.pages.dev`

### Using Wrangler CLI

```bash
# Login
wrangler login

# Build project
npm run build

# Deploy to Pages
wrangler pages deploy dist/public --project-name=swarm

# Set environment variables
wrangler pages secret put VITE_API_URL
```

---

## 🗄️ Database Setup

### Option 1: Neon (Recommended)

1. Go to [Neon](https://neon.tech/)
2. Create new project
3. Copy connection string
4. Use in backend deployment

**Free Tier**: 0.5GB storage, always free

### Option 2: Supabase

1. Go to [Supabase](https://supabase.com/)
2. Create new project
3. Get PostgreSQL connection string from Settings → Database
4. Use in backend deployment

**Free Tier**: 500MB database, 2GB bandwidth

### Option 3: Railway PostgreSQL

```bash
# Add PostgreSQL to Railway project
railway add

# Select PostgreSQL
# Connection string automatically added to environment
```

---

## 🔐 Environment Variables Setup

### Backend Environment Variables

**Required**:
```bash
DATABASE_URL=postgresql://user:pass@host:5432/db
SESSION_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)
ENCRYPTION_SALT=$(openssl rand -hex 32)
NODE_ENV=production
PORT=5000
```

**AI Providers** (at least one required):
```bash
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GEMINI_API_KEY=...
```

**Optional**:
```bash
GITHUB_CLIENT_ID=your-client-id
GITHUB_CLIENT_SECRET=your-client-secret
GITHUB_REDIRECT_URI=https://your-backend.com/api/auth/github/callback
```

### Frontend Environment Variables

```bash
NODE_VERSION=22
VITE_API_URL=https://your-backend-url.com
```

---

## 🧪 Testing Deployment

### 1. Test Backend Health

```bash
curl https://your-backend.railway.app/api/health
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

### 2. Test Frontend

Visit your Cloudflare Pages URL:
```
https://swarm-xxx.pages.dev
```

### 3. Test Full Flow

1. Open the app in browser
2. Create a test workflow
3. Add agents
4. Execute workflow
5. Verify execution completes

---

## 🔧 Troubleshooting

### Build Fails on Cloudflare Pages

**Issue**: "npm ci can only install with an existing package-lock.json"

**Solution**:
```bash
# Ensure package-lock.json is committed
git add package-lock.json
git commit -m "Add package-lock.json"
git push
```

### Frontend Can't Connect to Backend

**Issue**: CORS errors or "Network request failed"

**Solution**:
1. Verify `VITE_API_URL` is set correctly in Cloudflare Pages
2. Rebuild frontend with correct API URL
3. Check backend CORS configuration

### Backend Won't Start

**Issue**: "Missing required environment variables"

**Solution**:
```bash
# For Railway
railway variables

# For Render
# Check Dashboard → Environment → Environment Variables

# Ensure all required vars are set
```

### Database Connection Fails

**Issue**: "Failed to connect to database"

**Solution**:
1. Verify DATABASE_URL format: `postgresql://user:pass@host:5432/db`
2. Check database is accessible from backend platform
3. Verify database credentials are correct
4. Run migrations: `npm run db:push`

---

## 💰 Cost Estimate

### Free Tier (Great for testing)
- **Cloudflare Pages**: Free (unlimited bandwidth)
- **Railway**: $5 credit (no card required)
- **Neon Database**: Free (0.5GB)
- **Total**: $0/month

### Production (Low Traffic)
- **Cloudflare Pages**: Free
- **Railway**: $5-10/month
- **Neon Database**: Free or $19/month (Pro)
- **Total**: $5-29/month

### Production (High Traffic)
- **Cloudflare Pages**: Free
- **Railway**: $10-50/month (scales with usage)
- **Neon Database**: $19-100/month
- **Total**: $29-150/month

---

## 🚀 Going Live Checklist

- [ ] Database created and accessible
- [ ] Backend deployed and healthy (`/api/health` returns 200)
- [ ] Frontend built with correct `VITE_API_URL`
- [ ] Frontend deployed to Cloudflare Pages
- [ ] All environment variables set
- [ ] Database migrations run (`npm run db:push`)
- [ ] Test workflow execution works
- [ ] Custom domain configured (optional)
- [ ] SSL/HTTPS enabled (automatic on Cloudflare)
- [ ] Monitoring set up (optional)

---

## 📚 Next Steps

After deployment:

1. **Custom Domain** (optional)
   - Cloudflare Pages: Settings → Custom domains
   - Add your domain and configure DNS

2. **Monitoring**
   - Set up uptime monitoring (UptimeRobot, Pingdom)
   - Configure error tracking (Sentry)
   - Monitor logs in Railway/Render dashboard

3. **Optimization**
   - Enable Cloudflare caching
   - Set up Cloudflare Workers for API optimization (future)
   - Configure CDN settings

4. **Security**
   - Enable Cloudflare Web Application Firewall
   - Configure rate limiting
   - Set up DDoS protection

---

## 🆘 Need Help?

- **Documentation**: [docs/deployment/](../docs/deployment/)
- **Issues**: https://github.com/Universal-Standard/SWARM/issues
- **Discussions**: https://github.com/Universal-Standard/SWARM/discussions

---

## 🎉 Success!

Once deployed, you'll have:
- ⚡ Frontend on Cloudflare's global CDN (<50ms latency)
- 🚀 Auto-scaling backend
- 💾 Managed PostgreSQL database
- 🔒 HTTPS enabled by default
- 📊 Real-time monitoring

**Your SWARM is now live!** 🎊
