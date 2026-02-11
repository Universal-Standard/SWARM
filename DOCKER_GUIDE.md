# Docker Deployment Guide

SWARM supports Docker containerization for easy deployment and local development.

## Quick Start with Docker Compose

### Production Deployment

1. **Set environment variables**
   ```bash
   # Copy example environment file
   cp .env.example .env

   # Edit .env and set your values
   nano .env
   ```

2. **Start services**
   ```bash
   docker-compose up -d
   ```

3. **Check status**
   ```bash
   docker-compose ps
   docker-compose logs -f app
   ```

4. **Access application**
   - Application: http://localhost:5000
   - Health check: http://localhost:5000/api/health

### Development with Hot Reload

1. **Start development environment**
   ```bash
   docker-compose -f docker-compose.dev.yml up
   ```

2. **Features**
   - Hot reload for code changes
   - Source code mounted as volumes
   - Separate development database
   - Full development dependencies

## Manual Docker Build

### Build Production Image

```bash
# Build image
docker build -t swarm:latest .

# Run container
docker run -d \
  --name swarm-app \
  -p 5000:5000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  -e SESSION_SECRET="your-secret" \
  -e ENCRYPTION_KEY="your-key" \
  -e ENCRYPTION_SALT="your-salt" \
  swarm:latest
```

### Build Development Image

```bash
# Build development image
docker build -f Dockerfile.dev -t swarm:dev .

# Run with volume mounts for hot reload
docker run -d \
  --name swarm-dev \
  -p 5000:5000 \
  -v $(pwd)/client:/app/client \
  -v $(pwd)/server:/app/server \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  swarm:dev
```

## Docker Compose Commands

### Basic Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f app

# Restart services
docker-compose restart

# Rebuild containers
docker-compose up -d --build
```

### Database Management

```bash
# Access PostgreSQL
docker-compose exec postgres psql -U swarm -d swarm

# Backup database
docker-compose exec postgres pg_dump -U swarm swarm > backup.sql

# Restore database
cat backup.sql | docker-compose exec -T postgres psql -U swarm -d swarm

# View database logs
docker-compose logs -f postgres
```

### Application Management

```bash
# Execute command in app container
docker-compose exec app sh

# View application logs
docker-compose logs -f app

# Restart application
docker-compose restart app

# Run database migrations
docker-compose exec app npm run db:push
```

## Environment Variables

### Required Variables

```env
# Database
DATABASE_URL=postgresql://swarm:password@postgres:5432/swarm

# Security
SESSION_SECRET=your-random-secret-key
ENCRYPTION_KEY=your-32-character-encryption-key
ENCRYPTION_SALT=your-32-character-salt

# AI Providers (at least one required)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GEMINI_API_KEY=...
```

### Optional Variables

```env
# GitHub OAuth
GITHUB_CLIENT_ID=your-client-id
GITHUB_CLIENT_SECRET=your-client-secret
GITHUB_REDIRECT_URI=http://localhost:5000/api/auth/github/callback

# Application
NODE_ENV=production
PORT=5000
```

## Production Deployment

### Using Docker Compose

1. **Prepare environment**
   ```bash
   cp .env.example .env
   # Edit .env with production values
   ```

2. **Generate secure secrets**
   ```bash
   # Generate encryption keys
   openssl rand -hex 32  # ENCRYPTION_KEY
   openssl rand -hex 32  # ENCRYPTION_SALT
   openssl rand -hex 32  # SESSION_SECRET
   ```

3. **Start services**
   ```bash
   docker-compose up -d
   ```

4. **Verify deployment**
   ```bash
   # Check health
   curl http://localhost:5000/api/health

   # Check logs
   docker-compose logs -f
   ```

### Using Docker Swarm (Orchestration)

```yaml
# docker-stack.yml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    deploy:
      replicas: 1
      placement:
        constraints: [node.role == manager]
    environment:
      POSTGRES_DB: swarm
      POSTGRES_USER: swarm
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
    secrets:
      - postgres_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app:
    image: swarm:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    ports:
      - "5000:5000"
    environment:
      DATABASE_URL: postgresql://swarm:password@postgres:5432/swarm
      SESSION_SECRET_FILE: /run/secrets/session_secret
    secrets:
      - session_secret
      - encryption_key
      - encryption_salt

volumes:
  postgres_data:

secrets:
  postgres_password:
    external: true
  session_secret:
    external: true
  encryption_key:
    external: true
  encryption_salt:
    external: true
```

Deploy stack:
```bash
docker stack deploy -c docker-stack.yml swarm
```

## Health Checks

Both Docker images include health checks:

### Application Health Check
```bash
curl http://localhost:5000/api/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-11T00:00:00.000Z",
  "uptime": 3600,
  "environment": "production"
}
```

### Database Health Check
```bash
docker-compose exec postgres pg_isready -U swarm
```

## Troubleshooting

### Common Issues

1. **Container won't start**
   ```bash
   # Check logs
   docker-compose logs app

   # Check environment variables
   docker-compose exec app env | grep DATABASE_URL
   ```

2. **Database connection errors**
   ```bash
   # Verify database is running
   docker-compose ps postgres

   # Check database logs
   docker-compose logs postgres

   # Test connection
   docker-compose exec postgres psql -U swarm -d swarm -c "SELECT 1"
   ```

3. **Port already in use**
   ```bash
   # Change port in docker-compose.yml
   ports:
     - "8080:5000"  # Use 8080 instead of 5000
   ```

4. **Permission issues**
   ```bash
   # Reset permissions
   sudo chown -R $USER:$USER .
   ```

### Debugging

```bash
# Enter container shell
docker-compose exec app sh

# View all environment variables
docker-compose exec app env

# Check Node.js version
docker-compose exec app node --version

# Check application process
docker-compose exec app ps aux

# View real-time logs
docker-compose logs -f --tail=100
```

## Performance Tuning

### Resource Limits

Add to `docker-compose.yml`:
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### PostgreSQL Optimization

```yaml
services:
  postgres:
    command:
      - "postgres"
      - "-c"
      - "max_connections=200"
      - "-c"
      - "shared_buffers=256MB"
      - "-c"
      - "effective_cache_size=1GB"
```

## Security Best Practices

1. **Use secrets for sensitive data**
   ```bash
   echo "my-secret" | docker secret create session_secret -
   ```

2. **Don't commit .env files**
   ```bash
   # Already in .gitignore
   .env
   .env.*
   ```

3. **Use non-root user**
   - Both Dockerfiles already use non-root user `nodejs`

4. **Keep images updated**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

5. **Scan for vulnerabilities**
   ```bash
   docker scan swarm:latest
   ```

## CI/CD Integration

### Build in CI

```yaml
# .github/workflows/docker.yml
- name: Build Docker image
  run: docker build -t swarm:${{ github.sha }} .

- name: Run tests in container
  run: |
    docker run --rm \
      -e DATABASE_URL="postgresql://..." \
      swarm:${{ github.sha }} \
      npm test
```

### Push to Registry

```bash
# Tag and push
docker tag swarm:latest your-registry.com/swarm:latest
docker push your-registry.com/swarm:latest
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)

---

**Ready to deploy?** Choose your platform:
- **Local Development**: `docker-compose -f docker-compose.dev.yml up`
- **Production**: `docker-compose up -d`
- **Cloud**: See platform-specific guides in `docs/deployment/`
