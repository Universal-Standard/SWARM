# Multi-stage Dockerfile for SWARM Production Deployment

# Stage 1: Build the frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY package-lock.json ./
COPY client/package*.json ./client/

# Install dependencies
RUN npm ci --production=false

# Copy client source
COPY client ./client
COPY shared ./shared
COPY vite.config.ts ./
COPY tsconfig.json ./
COPY tailwind.config.ts ./
COPY postcss.config.js ./
COPY components.json ./

# Build frontend
RUN npm run build

# Stage 2: Build the backend
FROM node:22-alpine AS backend-builder
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY package-lock.json ./

# Install dependencies
RUN npm ci --production=false

# Copy server source
COPY server ./server
COPY shared ./shared
COPY tsconfig.json ./
COPY drizzle.config.ts ./

# Build backend
RUN npx esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist

# Stage 3: Production image
FROM node:22-alpine
WORKDIR /app

# Install production dependencies only
COPY package*.json ./
COPY package-lock.json ./
RUN npm ci --production && npm cache clean --force

# Copy built artifacts
COPY --from=frontend-builder /app/dist/public ./dist/public
COPY --from=backend-builder /app/dist ./dist
COPY --from=backend-builder /app/shared ./shared

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Set environment
ENV NODE_ENV=production
ENV PORT=5000

# Start application
CMD ["node", "dist/index.js"]
