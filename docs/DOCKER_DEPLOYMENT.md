# Docker Deployment Guide

This guide covers Docker deployment strategies for the Capital Marketplace Frontend, including development, staging, and production environments.

## 🐳 Overview

The application uses a multi-stage Docker build process optimized for production deployment with Nginx as a reverse proxy for better performance and static file serving.

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Basic understanding of Docker concepts
- Access to the application source code

## 🏗️ Architecture

### Production Stack
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     Client      │───▶│      Nginx       │───▶│   Next.js App   │
│   (Browser)     │    │  (Port 80/443)   │    │   (Port 3000)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Development Stack
```
┌─────────────────┐    ┌──────────────────┐
│     Client      │───▶│   Next.js Dev    │
│   (Browser)     │    │   (Port 3000)     │
└─────────────────┘    └──────────────────┘
```

## 🚀 Quick Start

### Development Environment

1. **Clone and navigate to the project**:
   ```bash
   git clone <repository-url>
   cd capital-marketplace-frontend
   ```

2. **Create environment file**:
   ```bash
   cp .env.example .env.local
   ```

3. **Start development environment**:
   ```bash
   docker-compose -f docker-compose.dev.yml up
   ```

4. **Access the application**:
   - Frontend: http://localhost:3000
   - Hot reload enabled for development

### Production Environment

1. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with production values
   ```

2. **Build and start production stack**:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Access the application**:
   - Frontend: http://localhost (port 80)
   - Nginx reverse proxy handles routing

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
# API Configuration
NEXT_PUBLIC_API_ENDPOINT=http://localhost:3001

# Cal.com Integration (Optional)
NEXT_PUBLIC_CAL_COM_BOOKING_URL=https://cal.com/your-username

# Production Settings
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# Docker-specific
HOSTNAME=capital-marketplace-frontend
```

### Docker Compose Files

#### Development (`docker-compose.dev.yml`)
```yaml
version: '3.7'

services:
  capital-marketplace-frontend:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    env_file:
      - .env.local
```

#### Production (`docker-compose.prod.yml`)
```yaml
version: '3.7'

services:
  capital-marketplace-frontend:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
      - HOSTNAME=capital-marketplace-frontend
    env_file:
      - .env
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://capital-marketplace-frontend:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - default

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro  # For SSL certificates
    depends_on:
      - capital-marketplace-frontend
    networks:
      - default
```

## 🏗️ Dockerfile Analysis

### Multi-Stage Build Process

The production Dockerfile uses a multi-stage build for optimization:

#### Stage 1: Dependencies (`deps`)
```dockerfile
FROM node:18-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production
```

#### Stage 2: Builder (`builder`)
```dockerfile
FROM base AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build
```

#### Stage 3: Runner (`runner`)
```dockerfile
FROM base AS runner
WORKDIR /app
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"
CMD ["node", "server.js"]
```

### Key Optimizations

- **Alpine Linux**: Smaller base image
- **Standalone Output**: Self-contained Next.js build
- **Non-root User**: Security best practice
- **Layer Caching**: Optimized layer ordering
- **Production Dependencies**: Separate dependency installation

## 🌐 Nginx Configuration

### Basic Configuration (`nginx/nginx.conf`)

```nginx
events {
    worker_connections 1024;
}

http {
    upstream nextjs_upstream {
        server capital-marketplace-frontend:3000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://nextjs_upstream;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # Static files caching
        location /_next/static/ {
            proxy_pass http://nextjs_upstream;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

### SSL Configuration (Optional)

For production with SSL:

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # Rest of configuration same as above
}
```

## 🔍 Health Checks

### Application Health Check

The production setup includes health checks:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://capital-marketplace-frontend:3000/api/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Manual Health Check

```bash
# Check container status
docker ps

# Check application logs
docker-compose logs capital-marketplace-frontend

# Test application endpoint
curl http://localhost/api/health
```

## 📊 Monitoring & Logging

### Log Management

```bash
# View real-time logs
docker-compose logs -f

# View specific service logs
docker-compose logs capital-marketplace-frontend

# View Nginx logs
docker-compose logs nginx
```

### Performance Monitoring

```bash
# Container resource usage
docker stats

# Container details
docker inspect capital-marketplace-frontend
```

## 🔒 Security Considerations

### Container Security

1. **Non-root User**: Application runs as `nextjs` user
2. **Minimal Base Image**: Alpine Linux reduces attack surface
3. **No Development Dependencies**: Production image excludes dev tools
4. **Read-only Filesystem**: Consider using read-only root filesystem

### Network Security

1. **Internal Communication**: Services communicate via Docker network
2. **Port Exposure**: Only necessary ports exposed
3. **Reverse Proxy**: Nginx handles external traffic

### Environment Variables

1. **No Secrets in Images**: Use environment variables for sensitive data
2. **Separate Configs**: Different configs for different environments
3. **Secret Management**: Consider Docker secrets for production

## 🚀 Deployment Strategies

### Blue-Green Deployment

1. **Build new image**:
   ```bash
   docker build -t capital-marketplace-frontend:v2 .
   ```

2. **Update docker-compose**:
   ```yaml
   image: capital-marketplace-frontend:v2
   ```

3. **Deploy new version**:
   ```bash
   docker-compose up -d
   ```

### Rolling Updates

```bash
# Update with zero downtime
docker-compose up -d --no-deps capital-marketplace-frontend
```

### Rollback Strategy

```bash
# Rollback to previous version
docker-compose down
docker-compose up -d
```

## 🔧 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker-compose logs capital-marketplace-frontend

# Check container status
docker ps -a

# Restart container
docker-compose restart capital-marketplace-frontend
```

#### Build Failures
```bash
# Clean build
docker-compose build --no-cache

# Check Dockerfile syntax
docker build -t test .
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :3000

# Change port in docker-compose
ports:
  - "3001:3000"  # Use port 3001 instead
```

#### Environment Variables
```bash
# Check environment variables
docker-compose config

# Verify .env file
cat .env
```

### Performance Issues

#### Memory Usage
```bash
# Monitor memory usage
docker stats

# Increase memory limits
deploy:
  resources:
    limits:
      memory: 1G
```

#### Slow Builds
```bash
# Use build cache
docker-compose build

# Parallel builds
docker-compose build --parallel
```

## 📈 Scaling Considerations

### Horizontal Scaling

```yaml
services:
  capital-marketplace-frontend:
    deploy:
      replicas: 3
    # Load balancer configuration needed
```

### Vertical Scaling

```yaml
services:
  capital-marketplace-frontend:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build Docker image
        run: docker build -t capital-marketplace-frontend .
      
      - name: Deploy to server
        run: |
          docker-compose -f docker-compose.prod.yml up -d
```

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Next.js Docker Documentation](https://nextjs.org/docs/deployment#docker-image)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

---

*This guide should be updated as deployment requirements evolve and new best practices emerge.*
