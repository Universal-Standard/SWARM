# Production Deployment Checklist

## Pre-Deployment Requirements

### 1. Environment Variables
All required environment variables must be set before deployment:

```bash
# REQUIRED - Database
DATABASE_URL=postgresql://user:password@host:5432/database

# REQUIRED - Security
SESSION_SECRET=<generate-random-string-32-chars>
ENCRYPTION_KEY=<openssl rand -hex 32>
ENCRYPTION_SALT=<openssl rand -hex 32>

# REQUIRED - At least one AI provider
OPENAI_API_KEY=sk-...
# OR
ANTHROPIC_API_KEY=sk-ant-...
# OR  
GEMINI_API_KEY=...

# OPTIONAL - GitHub OAuth
GITHUB_CLIENT_ID=...
GITHUB_CLIENT_SECRET=...
GITHUB_REDIRECT_URI=https://your-domain.com/api/auth/github/callback

# Server Configuration
PORT=5000
NODE_ENV=production
```

### 2. Generate Secure Secrets

```bash
# Generate encryption key and salt
openssl rand -hex 32  # For ENCRYPTION_KEY
openssl rand -hex 32  # For ENCRYPTION_SALT

# Generate session secret
openssl rand -base64 32  # For SESSION_SECRET
```

### 3. Database Setup

```bash
# Run database migrations
npm run db:push

# Verify connection
# The server will validate connection on startup
```

## Build Process

### 1. Install Dependencies
```bash
npm install --legacy-peer-deps --production=false
```

### 2. Run Type Check
```bash
npm run check
```
Should output: **0 errors**

### 3. Build Application
```bash
npm run build
```

This creates:
- `dist/public/` - Frontend static files
- `dist/index.js` - Backend server bundle

## Deployment Options

### Option 1: Cloudflare Pages + Workers (Recommended)

**Benefits:**
- Global CDN with <50ms latency
- Auto-scaling
- $0-20/month
- Zero maintenance

**Frontend (Cloudflare Pages):**
```bash
# In Cloudflare dashboard:
Build command: npm run build
Build output directory: dist/public
Root directory: (leave empty)
```

**Backend (Cloudflare Workers):**
```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Deploy Worker
wrangler deploy
```

See: [CLOUDFLARE_DEPLOYMENT.md](./CLOUDFLARE_DEPLOYMENT.md)

### Option 2: Self-Hosted (Docker)

```dockerfile
FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps --production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Expose port
EXPOSE 5000

# Start server
CMD ["npm", "start"]
```

Build and run:
```bash
docker build -t swarm .
docker run -p 5000:5000 --env-file .env swarm
```

### Option 3: Traditional Server (Ubuntu/Amazon Linux)

```bash
# Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone and build
git clone https://github.com/Universal-Standard/SWARM.git
cd SWARM
npm install --legacy-peer-deps
npm run build

# Create systemd service
sudo nano /etc/systemd/system/swarm.service
```

Service file:
```ini
[Unit]
Description=SWARM AI Workflow Platform
After=network.target

[Service]
Type=simple
User=swarm
WorkingDirectory=/opt/swarm
EnvironmentFile=/opt/swarm/.env
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
```

Start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable swarm
sudo systemctl start swarm
```

## Post-Deployment Verification

### 1. Check Server Health
```bash
curl https://your-domain.com/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-05T09:30:00.000Z"
}
```

### 2. Verify Environment Variables
Check server logs on startup:
```
✓ Environment validation passed
✓ Database connection verified
✓ Basic workflow scheduler started
✓ Advanced features initialized
✓ Server running on port 5000
✓ Environment: production
```

### 3. Test Key Features
- [ ] User authentication works
- [ ] Can create workflows
- [ ] Can save workflows
- [ ] AI providers respond (if configured)
- [ ] Workflow execution works

## Monitoring

### Application Logs
Logs are output in JSON format for production:
```json
{
  "timestamp": "2026-02-05T09:30:00.000Z",
  "level": "info",
  "message": "Workflow execution started",
  "workflowId": "abc123"
}
```

Recommended log aggregation tools:
- Datadog
- New Relic
- CloudWatch (AWS)
- Grafana Loki

### Health Checks
Monitor these endpoints:
- `GET /api/health` - Application health
- Database connection status (checked on startup)

### Metrics to Monitor
- Response time (should be <200ms for API calls)
- Error rate (should be <1%)
- Database connection pool usage
- Memory usage (Node.js should stay under 512MB)
- CPU usage

## Security Checklist

- [ ] All environment variables set (no defaults used)
- [ ] HTTPS enabled (Let's Encrypt or CloudFlare)
- [ ] Database uses SSL connection
- [ ] API keys encrypted at rest
- [ ] Rate limiting enabled (TODO: implement)
- [ ] CORS configured for your domain only
- [ ] Content Security Policy headers set (TODO: implement)
- [ ] Dependency vulnerabilities resolved (run `npm audit`)

## Troubleshooting

### Server Won't Start

**Check 1: Environment Variables**
```
Error: Missing required environment variables: DATABASE_URL, SESSION_SECRET
```
Solution: Set all required environment variables

**Check 2: Database Connection**
```
Error: Failed to connect to database
```
Solution: Verify DATABASE_URL is correct and database is accessible

**Check 3: Port Already in Use**
```
Error: EADDRINUSE: address already in use :::5000
```
Solution: Change PORT environment variable or kill process using port 5000

### Build Failures

**Issue: Peer dependency conflicts**
```
npm error Conflicting peer dependency
```
Solution: Use `--legacy-peer-deps` flag

**Issue: Out of memory**
```
JavaScript heap out of memory
```
Solution: Increase Node.js memory: `NODE_OPTIONS=--max_old_space_size=4096 npm run build`

### Runtime Errors

**Check server logs** - All errors are logged with stack traces in development:
```bash
# View logs (systemd)
sudo journalctl -u swarm -f

# View logs (Docker)
docker logs -f <container-id>
```

## Performance Optimization

### 1. Enable Compression
```typescript
// server/index.ts
import compression from 'compression';
app.use(compression());
```

### 2. Set Up CDN
Serve static assets from CDN:
- Cloudflare (recommended)
- AWS CloudFront
- Azure CDN

### 3. Database Optimization
- Enable connection pooling (already configured in Drizzle)
- Add indexes on frequently queried columns
- Use read replicas for heavy workloads

### 4. Caching
Consider adding Redis for:
- Session storage
- AI response caching
- Rate limiting

## Scaling Recommendations

### <1000 users
- Single server deployment
- PostgreSQL on same server or managed service
- 2 CPU cores, 4GB RAM sufficient

### 1000-10,000 users
- Load balancer (nginx, CloudFlare)
- 2-4 application servers
- Managed PostgreSQL with read replicas
- Redis for session storage
- 4 CPU cores, 8GB RAM per server

### >10,000 users
- Kubernetes cluster
- Horizontal pod autoscaling
- Managed PostgreSQL cluster
- Redis cluster
- CDN for static assets
- Consider microservices architecture

## Backup Strategy

### Database Backups
```bash
# Daily automated backups
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql

# Retention: Keep 7 daily, 4 weekly, 3 monthly
```

### Disaster Recovery
- Test restore process monthly
- Document RTO (Recovery Time Objective): <4 hours
- Document RPO (Recovery Point Objective): <24 hours
- Keep backups in different region/availability zone

## Support & Maintenance

### Regular Maintenance Tasks
- [ ] Weekly: Review error logs
- [ ] Weekly: Check disk space
- [ ] Monthly: Update dependencies (`npm update`)
- [ ] Monthly: Review and rotate API keys
- [ ] Quarterly: Security audit (`npm audit`)
- [ ] Quarterly: Load testing

### Updates
```bash
# Pull latest code
git pull origin main

# Install dependencies
npm install --legacy-peer-deps

# Run type check
npm run check

# Build
npm run build

# Restart server
sudo systemctl restart swarm
```

## Getting Help

- **Documentation**: See `docs/` directory
- **Issues**: https://github.com/Universal-Standard/SWARM/issues
- **Discussions**: https://github.com/Universal-Standard/SWARM/discussions
- **Security**: See SECURITY.md for reporting vulnerabilities
