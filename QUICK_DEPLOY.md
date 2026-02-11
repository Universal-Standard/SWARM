# 🚀 SWARM Quick Deploy Guide

## ✅ Prerequisites Ready
- ✅ Neon DATABASE_URL
- ✅ OpenAI API Key
- ✅ Anthropic API Key
- ✅ Gemini API Key
- ✅ Secure keys generated (see above)

---

## 📝 Deployment Steps

### STEP 1: Railway Login & Setup (5 min)

```bash
# 1.1 Login to Railway (opens browser)
railway login

# 1.2 Navigate to project directory
cd /home/user/SWARM-1

# 1.3 Initialize Railway project
railway init
# → Choose: "Empty Project"
# → Name: "swarm-api"
```

### STEP 2: Configure Environment Variables (2 min)

```bash
# Database (paste your Neon connection string)
railway variables set DATABASE_URL="postgresql://user:pass@ep-xxx.neon.tech/neondb?sslmode=require"

# Security keys (use the generated keys from above)
railway variables set SESSION_SECRET="paste-generated-session-secret-here"
railway variables set ENCRYPTION_KEY="paste-generated-encryption-key-here"
railway variables set ENCRYPTION_SALT="paste-generated-encryption-salt-here"

# Node environment
railway variables set NODE_ENV="production"
railway variables set PORT="5000"

# AI API Keys (paste your actual keys)
railway variables set OPENAI_API_KEY="sk-proj-your-key-here"
railway variables set ANTHROPIC_API_KEY="sk-ant-your-key-here"
railway variables set GEMINI_API_KEY="your-gemini-key-here"
```

### STEP 3: Deploy Backend (3-4 min)

```bash
# Deploy to Railway (takes 2-3 minutes)
railway up

# Generate public domain
railway domain

# Check deployment status
railway status
```

### STEP 4: Setup Database (1 min)

```bash
# Run database migrations
railway run npm run db:push

# Verify it worked - you should see "✓" for all tables
```

### STEP 5: Get Backend URL (30 sec)

```bash
# Get your backend URL
railway status

# Copy the URL shown (e.g., https://swarm-api-production-xxx.up.railway.app)
# SAVE THIS - you need it for the frontend!
```

### STEP 6: Deploy Frontend to Cloudflare (3 min)

```bash
# 6.1 Login to Cloudflare (opens browser)
wrangler login

# 6.2 Build frontend with your Railway backend URL
# ⚠️ REPLACE with your actual Railway URL from step 5!
export VITE_API_URL="https://your-backend-url.up.railway.app"
npm run build

# 6.3 Deploy to Cloudflare Pages
wrangler pages deploy dist/public --project-name=swarm
```

---

## ✅ Verify Deployment (2 min)

### Test Backend
```bash
# Replace with your Railway URL
curl https://your-backend.up.railway.app/api/health

# Expected response:
# {"status":"ok","timestamp":"...","uptime":123,"environment":"production"}
```

### Test Frontend
1. Copy the Cloudflare Pages URL from the deployment output
2. Open it in your browser
3. You should see the SWARM landing page

### Test Full Workflow
1. Click "Get Started" or visit `/app/workflows`
2. Create a new workflow
3. Add an agent node
4. Configure it with one of your AI providers
5. Execute the workflow
6. Verify it completes successfully

---

## 🎉 Success!

Your SWARM is now live at:
- **Frontend**: https://xxx.pages.dev (Cloudflare)
- **Backend**: https://xxx.up.railway.app (Railway)
- **Database**: Neon PostgreSQL

### Next Steps:
1. **Add custom domain** (optional): Cloudflare Dashboard → Custom domains
2. **Monitor usage**: Railway Dashboard → Metrics
3. **View logs**: `railway logs` or Railway Dashboard
4. **Invite users**: Share your Cloudflare Pages URL

---

## 🆘 Troubleshooting

### Railway deployment fails
```bash
# Check logs
railway logs

# Verify environment variables
railway variables

# Redeploy
railway up
```

### Frontend can't connect to backend
```bash
# Rebuild with correct URL
export VITE_API_URL="https://your-correct-backend-url.up.railway.app"
npm run build
wrangler pages deploy dist/public --project-name=swarm
```

### Database connection fails
- Verify your DATABASE_URL is correct
- Check Neon dashboard - database should be "Active"
- Try running migrations again: `railway run npm run db:push`

---

## 💰 Cost Tracking

- **Cloudflare Pages**: $0 (free forever)
- **Railway**: Using $5 credit (lasts 2-4 weeks)
- **Neon**: $0 (free tier)

After credit runs out:
- Railway: ~$5/month for this size app
- Total: $5/month

---

## 📚 Useful Commands

```bash
# View logs
railway logs
railway logs --tail  # Follow logs live

# Check status
railway status

# Add more environment variables
railway variables set KEY="value"

# Redeploy
railway up

# Cloudflare logs
wrangler pages deployment tail

# Update frontend
npm run build
wrangler pages deploy dist/public --project-name=swarm
```

---

**🎊 Congratulations! SWARM is deployed and ready to use!**
