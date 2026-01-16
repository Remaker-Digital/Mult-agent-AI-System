# Docker Best Practices Guide

## Multi-Agent AI Platform - Complete Docker Documentation

This guide covers all Docker configurations, best practices, and deployment strategies for the Multi-Agent AI Platform.

---

## Table of Contents

1. [Overview](#overview)
2. [Dockerfile Configurations](#dockerfile-configurations)
3. [Docker Compose Files](#docker-compose-files)
4. [Quick Start](#quick-start)
5. [Best Practices Applied](#best-practices-applied)
6. [Production Deployment](#production-deployment)
7. [Security Features](#security-features)
8. [Monitoring & Logging](#monitoring--logging)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The platform includes multiple Docker configurations optimized for different environments:

| File | Purpose | Use Case |
|------|---------|----------|
| `Dockerfile` | Development & Testing | Local development, CI/CD |
| `Dockerfile.production` | Production Deployment | Live environments, Azure |
| `docker-compose.yml` | Local Development | Multi-agent testing |
| `docker-compose.production.yml` | Production Stack | Full deployment |

---

## Dockerfile Configurations

### Development Dockerfile (`Dockerfile`)

**Location:** `agents/base-agent/Dockerfile`

**Features:**
- Multi-stage build for size optimization
- BuildKit syntax for enhanced caching
- Non-root user execution (UID 1000)
- Health checks with curl
- Optimized layer caching
- Development-friendly settings

**Build Command:**
```bash
docker build -t multiagent/base-agent:dev ./agents/base-agent
```

**Build Arguments:**
- `PYTHON_VERSION` (default: 3.11)
- `APP_USER` (default: appuser)
- `APP_UID` (default: 1000)
- `APP_PORT` (default: 8080)

**Example with custom args:**
```bash
docker build \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg APP_PORT=9000 \
  -t multiagent/base-agent:dev \
  ./agents/base-agent
```

### Production Dockerfile (`Dockerfile.production`)

**Location:** `agents/base-agent/Dockerfile.production`

**Additional Features:**
- Virtual environment isolation
- Pinned security updates
- Read-only filesystem support
- Enhanced health checks
- Production-optimized gunicorn settings
- OCI-compliant metadata labels

**Production Build:**
```bash
docker build \
  -f agents/base-agent/Dockerfile.production \
  -t multiagent/base-agent:prod \
  ./agents/base-agent
```

---

## Docker Compose Files

### Development Compose (`docker-compose.yml`)

**Features:**
- 5 AI agents (conversation, analysis, recommendation, knowledge, orchestration)
- Redis cache with persistence
- Nginx reverse proxy
- Health checks for all services
- Resource limits (development tier)
- YAML anchors for DRY configuration
- Network isolation
- Volume management

**Usage:**
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

**Access Points:**
- Gateway: http://localhost:80
- Conversation Agent: http://localhost:8081
- Analysis Agent: http://localhost:8082
- Recommendation Agent: http://localhost:8083
- Knowledge Agent: http://localhost:8084
- Orchestration Agent: http://localhost:8085
- Redis: localhost:6379

### Production Compose (`docker-compose.production.yml`)

**Additional Features:**
- Production resource limits (2+ replicas)
- Enhanced logging configuration
- Rolling updates support
- Restart policies
- Read-only filesystems
- Production Redis configuration
- SSL/TLS support for Nginx

**Production Usage:**
```bash
# Start production stack
docker-compose -f docker-compose.production.yml up -d

# Scale specific agent
docker-compose -f docker-compose.production.yml up -d --scale conversation-agent=3

# Rolling update
docker-compose -f docker-compose.production.yml up -d --no-deps --build conversation-agent

# View production logs
docker-compose -f docker-compose.production.yml logs -f --tail=100
```

---

## Quick Start

### 1. Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- 4GB+ RAM available
- 10GB+ disk space

**Verify installation:**
```bash
docker --version
docker-compose --version
```

### 2. Clone and Configure

```bash
# Clone repository
git clone <repository-url>
cd Multi-agent-Service-Platform

# Copy environment file
cp .env.example .env

# Edit .env with your values
# For development, defaults are fine
```

### 3. Build and Start

**Development:**
```bash
# Build all images
docker-compose build

# Start services
docker-compose up -d

# Wait for services to be healthy (30-60 seconds)
docker-compose ps
```

**Test endpoints:**
```bash
# Gateway health
curl http://localhost/health

# Agent health
curl http://localhost:8081/health  # Conversation
curl http://localhost:8082/health  # Analysis
curl http://localhost:8083/health  # Recommendation
curl http://localhost:8084/health  # Knowledge
curl http://localhost:8085/health  # Orchestration
```

### 4. Test API

```bash
# Send request to conversation agent
curl -X POST http://localhost/api/conversation/process \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, agent!"}'

# Check metrics
curl http://localhost:8081/metrics
```

---

## Best Practices Applied

### 1. Image Optimization

✅ **Multi-stage builds**
- Separates build and runtime dependencies
- Reduces final image size by 60%+
- Keeps build tools out of production

✅ **Layer caching**
- Dependencies installed before code copy
- BuildKit syntax for enhanced caching
- Optimized instruction ordering

✅ **Minimal base images**
- Uses `python:3.11-slim` (not full Python image)
- Removes unnecessary packages
- Final image: ~300-400MB

### 2. Security Hardening

✅ **Non-root user execution**
```dockerfile
RUN useradd -m -u 1000 -l appuser
USER appuser
```

✅ **Security options**
```yaml
security_opt:
  - no-new-privileges:true
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

✅ **Read-only filesystem** (production)
```yaml
read_only: true
tmpfs:
  - /tmp
  - /var/tmp
```

✅ **Secret management**
- Environment variables for sensitive data
- `.env` file excluded from git
- No hardcoded credentials

### 3. Health Checks

✅ **Container health checks**
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

✅ **Compose health checks**
```yaml
depends_on:
  redis:
    condition: service_healthy
```

### 4. Resource Management

✅ **Development limits**
```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
```

✅ **Production limits**
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
```

### 5. Logging

✅ **Structured logging**
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "50m"
    max-file: "5"
    compress: "true"
```

✅ **Application logging**
- JSON format for parsing
- Log levels configurable
- Integration with Application Insights

### 6. Networking

✅ **Network isolation**
```yaml
networks:
  agent-network:
    driver: bridge
```

✅ **Service discovery**
- Services communicate by name
- No hardcoded IPs
- DNS resolution built-in

### 7. Configuration Management

✅ **Environment variables**
- All configuration externalized
- `.env` file for local development
- Azure Key Vault for production

✅ **Build arguments**
- Customizable at build time
- Version control friendly
- No secrets in images

---

## Production Deployment

### 1. Pre-Deployment Checklist

- [ ] Update `.env` with production values
- [ ] Set strong Redis password
- [ ] Configure Application Insights
- [ ] Set up Cosmos DB connection
- [ ] SSL certificates in place
- [ ] Resource limits reviewed
- [ ] Backup strategy defined

### 2. Build Production Images

```bash
# Build all production images
docker-compose -f docker-compose.production.yml build

# Tag for registry
docker tag multiagent/conversation-agent:latest myregistry.azurecr.io/conversation-agent:v1.0.0

# Push to Azure Container Registry
az acr login --name myregistry
docker push myregistry.azurecr.io/conversation-agent:v1.0.0
```

### 3. Deploy Stack

```bash
# Deploy to production
docker-compose -f docker-compose.production.yml up -d

# Verify all services healthy
docker-compose -f docker-compose.production.yml ps

# Monitor logs
docker-compose -f docker-compose.production.yml logs -f
```

### 4. Scaling

```bash
# Scale specific agent
docker-compose -f docker-compose.production.yml up -d --scale conversation-agent=5

# Scale all agents
docker-compose -f docker-compose.production.yml up -d \
  --scale conversation-agent=3 \
  --scale analysis-agent=3 \
  --scale recommendation-agent=3
```

### 5. Updates and Rollbacks

**Rolling update:**
```bash
# Update with zero downtime
docker-compose -f docker-compose.production.yml up -d --no-deps --build conversation-agent
```

**Rollback:**
```bash
# Deploy previous version
docker-compose -f docker-compose.production.yml up -d conversation-agent:v1.0.0
```

---

## Security Features

### 1. Container Security

| Feature | Implementation | Benefit |
|---------|---------------|---------|
| Non-root user | `USER appuser` | Prevents privilege escalation |
| Read-only FS | `read_only: true` | Prevents tampering |
| No new privileges | `no-new-privileges:true` | Restricts capabilities |
| Minimal capabilities | `cap_drop: ALL` | Reduces attack surface |

### 2. Network Security

- Isolated bridge network
- No direct internet access for agents
- Nginx as security gateway
- Rate limiting enabled
- Connection limits enforced

### 3. Secrets Management

```bash
# Development: .env file
REDIS_PASSWORD=devpassword

# Production: Azure Key Vault
docker secret create redis_password - < redis_password.txt
```

### 4. Image Security

```bash
# Scan for vulnerabilities
docker scan multiagent/base-agent:prod

# Use Trivy for comprehensive scanning
trivy image multiagent/base-agent:prod
```

---

## Monitoring & Logging

### 1. Container Metrics

```bash
# Real-time stats
docker stats

# Specific container
docker stats conversation-agent

# Formatted output
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### 2. Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f conversation-agent

# Last 100 lines
docker-compose logs --tail=100 conversation-agent

# Since timestamp
docker-compose logs --since 2024-01-01T00:00:00 conversation-agent
```

### 3. Health Checks

```bash
# Check health status
docker inspect --format='{{.State.Health.Status}}' conversation-agent

# Health check logs
docker inspect --format='{{json .State.Health}}' conversation-agent | jq
```

### 4. Application Insights

Production deployments integrate with Azure Application Insights:
- Automatic telemetry collection
- Distributed tracing
- Performance monitoring
- Custom metrics and alerts

---

## Troubleshooting

### Common Issues

#### 1. Container Won't Start

```bash
# Check logs
docker-compose logs conversation-agent

# Check events
docker events --filter container=conversation-agent

# Inspect container
docker inspect conversation-agent
```

#### 2. Port Already in Use

```bash
# Find process using port
# Windows
netstat -ano | findstr :8080

# Linux/Mac
lsof -i :8080

# Change port in docker-compose.yml
ports:
  - "8091:8080"  # Use 8091 instead
```

#### 3. Health Check Failing

```bash
# Test health endpoint manually
docker exec conversation-agent curl -f http://localhost:8080/health

# Check application logs
docker-compose logs conversation-agent | grep -i error

# Increase start period
healthcheck:
  start_period: 30s  # Give more time
```

#### 4. Out of Memory

```bash
# Check current usage
docker stats conversation-agent

# Increase memory limit
deploy:
  resources:
    limits:
      memory: 1G  # Increase from 512M
```

#### 5. Network Issues

```bash
# Inspect network
docker network inspect multiagent_agent-network

# Test connectivity
docker exec conversation-agent ping redis

# Check DNS resolution
docker exec conversation-agent nslookup redis
```

#### 6. Build Failures

```bash
# Clean build (no cache)
docker-compose build --no-cache

# Prune old images
docker image prune -a

# Check disk space
docker system df
```

### Performance Optimization

#### 1. Build Performance

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Use build cache from registry
docker build --cache-from myregistry.azurecr.io/base-agent:latest .
```

#### 2. Runtime Performance

```yaml
# Optimize gunicorn workers
CMD ["gunicorn", 
     "--workers", "4",  # 2-4 × CPU cores
     "--threads", "2",  # Adjust based on workload
     "--worker-class", "gthread",
     "app:app"]
```

#### 3. Network Performance

```yaml
# Enable keep-alive in nginx
keepalive_timeout 65;
keepalive_requests 100;

# Connection pooling
keepalive 32;  # In upstream blocks
```

---

## Additional Resources

### Documentation Files

- `agents/base-agent/DOCKERFILE_OPTIMIZATIONS.md` - Detailed Dockerfile optimizations
- `agents/base-agent/OPTIMIZATION_SUMMARY.md` - Complete optimization summary
- `agents/base-agent/BEFORE_AFTER_COMPARISON.md` - Comparison of changes

### Docker Commands Reference

```bash
# Build
docker-compose build [service]
docker-compose build --no-cache [service]

# Start/Stop
docker-compose up -d
docker-compose down
docker-compose restart [service]

# Logs
docker-compose logs -f [service]
docker-compose logs --tail=100 [service]

# Scaling
docker-compose up -d --scale service=3

# Execute commands
docker-compose exec [service] /bin/sh
docker-compose exec [service] python --version

# Cleanup
docker-compose down -v
docker system prune -a
```

### External Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/)

---

## Support

For issues or questions:
1. Check this documentation
2. Review Docker logs
3. Consult troubleshooting section
4. Open GitHub issue

**Version:** 1.0.0  
**Last Updated:** 2026-01-15
