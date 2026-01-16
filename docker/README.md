# Docker Configuration

**Multi-Agent AI Platform - Complete Docker Setup**

This directory contains all Docker configurations for the Multi-Agent AI Platform, following Docker and container best practices for both development and production environments.

---

## 📁 Directory Structure

```
docker/
├── nginx/                          # Nginx reverse proxy configuration
│   ├── nginx.conf                 # Main Nginx configuration
│   ├── conf.d/
│   │   ├── default.conf          # Server blocks and routing
│   │   └── proxy_params.conf     # Proxy settings
│   └── ssl/                       # SSL certificates (production)
├── DOCKER_BEST_PRACTICES.md       # Complete Docker guide
├── QUICK_REFERENCE.md             # Common commands cheat sheet
└── README.md                      # This file

Root Level:
├── docker-compose.yml              # Development environment
├── docker-compose.production.yml   # Production environment
├── .env.example                    # Environment variables template
└── agents/base-agent/
    ├── Dockerfile                  # Development Dockerfile
    ├── Dockerfile.production       # Production Dockerfile
    └── .dockerignore              # Build exclusions
```

---

## 🚀 Quick Start

### Development Environment

```bash
# 1. Copy environment file
cp .env.example .env

# 2. Start all services
docker-compose up -d

# 3. Verify health
docker-compose ps
curl http://localhost/health

# 4. View logs
docker-compose logs -f
```

### Production Environment

```bash
# 1. Configure production environment
cp .env.example .env
# Edit .env with production values

# 2. Build production images
docker-compose -f docker-compose.production.yml build

# 3. Deploy
docker-compose -f docker-compose.production.yml up -d

# 4. Verify
docker-compose -f docker-compose.production.yml ps
```

---

## 📋 Available Services

| Service | Description | Port(s) |
|---------|-------------|---------|
| **nginx** | Reverse proxy & load balancer | 80, 443 |
| **conversation-agent** | Conversational AI agent | 8081 |
| **analysis-agent** | Data analysis agent | 8082 |
| **recommendation-agent** | Recommendation engine | 8083 |
| **knowledge-agent** | Knowledge base manager | 8084 |
| **orchestration-agent** | Multi-agent orchestrator | 8085 |
| **redis** | Cache and session storage | 6379 |

---

## 🏗️ Dockerfile Features

### Development (`Dockerfile`)

✅ Multi-stage build for optimization  
✅ BuildKit syntax for enhanced caching  
✅ Non-root user execution (UID 1000)  
✅ Health checks with curl  
✅ Optimized layer caching  
✅ Development-friendly settings  
✅ OCI-compliant labels  

**Size:** ~300-350MB

### Production (`Dockerfile.production`)

✅ All development features, plus:  
✅ Virtual environment isolation  
✅ Pinned security updates  
✅ Read-only filesystem support  
✅ Production-optimized gunicorn  
✅ Enhanced health check configuration  
✅ Stricter security policies  

**Size:** ~350-400MB

---

## 🐳 Docker Compose Features

### Development (`docker-compose.yml`)

- 5 AI agents with health checks
- Redis cache with persistence
- Nginx reverse proxy
- Resource limits (dev tier)
- YAML anchors for DRY config
- Network isolation
- Volume management
- Dependency ordering

### Production (`docker-compose.production.yml`)

- All development features, plus:
- Multi-replica support (2+ instances)
- Enhanced logging configuration
- Rolling update support
- Restart policies
- Read-only filesystems
- Production Redis settings
- SSL/TLS support
- Advanced health checks

---

## 🔧 Configuration Files

### Nginx Configuration

**`nginx/nginx.conf`** - Main configuration
- Worker process optimization
- Connection pooling
- Gzip compression
- Rate limiting zones
- Upstream definitions

**`nginx/conf.d/default.conf`** - Routing
- Agent routing (`/api/*`)
- Health check endpoints
- Security headers
- Error handling
- Rate limiting

**`nginx/conf.d/proxy_params.conf`** - Proxy settings
- Header forwarding
- WebSocket support
- Timeout configuration
- Connection reuse
- Error handling

### Environment Variables

**`.env.example`** - Template file
- Redis password
- Application Insights connection string
- Cosmos DB endpoint
- Azure Key Vault URL
- Development/Production settings

---

## 🔒 Security Features

### Container Security
- ✅ Non-root user execution
- ✅ Read-only filesystem (production)
- ✅ No new privileges flag
- ✅ Minimal capabilities (CAP_DROP ALL)
- ✅ Security scanning compatible

### Network Security
- ✅ Isolated bridge network
- ✅ No direct internet access
- ✅ Nginx security gateway
- ✅ Rate limiting enabled
- ✅ Connection limits enforced

### Secrets Management
- ✅ Environment variables
- ✅ `.env` file (gitignored)
- ✅ Azure Key Vault integration
- ✅ No hardcoded credentials

---

## 📊 Monitoring & Logging

### Health Checks

```bash
# Gateway
curl http://localhost/health

# Individual agents
curl http://localhost:8081/health  # Conversation
curl http://localhost:8082/health  # Analysis
curl http://localhost:8083/health  # Recommendation
curl http://localhost:8084/health  # Knowledge
curl http://localhost:8085/health  # Orchestration
```

### Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f conversation-agent

# Last 100 lines
docker-compose logs --tail=100 conversation-agent
```

### Metrics

```bash
# Real-time stats
docker stats

# Agent metrics endpoint
curl http://localhost:8081/metrics
```

---

## 🎯 Best Practices Applied

1. **Multi-stage builds** - Reduced image size
2. **Layer caching** - Faster builds
3. **Security hardening** - Non-root, minimal caps
4. **Health checks** - Automated monitoring
5. **Resource limits** - Prevent resource exhaustion
6. **Logging configuration** - Structured logs
7. **Network isolation** - Security boundary
8. **Volume management** - Data persistence
9. **Environment-specific configs** - Dev vs Prod
10. **Documentation** - Complete guides

---

## 📚 Documentation

| File | Description |
|------|-------------|
| [DOCKER_BEST_PRACTICES.md](DOCKER_BEST_PRACTICES.md) | Complete Docker guide with examples |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Common commands cheat sheet |
| [agents/base-agent/DOCKERFILE_OPTIMIZATIONS.md](../agents/base-agent/DOCKERFILE_OPTIMIZATIONS.md) | Dockerfile optimization details |

---

## 🧪 Testing

### Development Testing

```bash
# Start services
docker-compose up -d

# Wait for health checks
sleep 30

# Test endpoints
curl http://localhost/health
curl http://localhost:8081/health

# Test API
curl -X POST http://localhost/api/conversation/process \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'

# Stop services
docker-compose down
```

### Production Testing

```bash
# Build and start
docker-compose -f docker-compose.production.yml up -d

# Run health checks
./scripts/health-check.sh

# Load testing
ab -n 1000 -c 10 http://localhost/api/conversation/health

# Stop services
docker-compose -f docker-compose.production.yml down
```

---

## 🔄 Common Workflows

### Update a Service

```bash
# 1. Rebuild image
docker-compose build conversation-agent

# 2. Restart service
docker-compose up -d --no-deps conversation-agent

# 3. Verify
docker-compose logs conversation-agent
```

### Scale Services

```bash
# Scale conversation agent to 3 replicas
docker-compose up -d --scale conversation-agent=3

# Verify
docker-compose ps
```

### Backup Data

```bash
# Backup Redis volume
docker run --rm \
  -v multiagent_redis-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/redis-backup.tar.gz /data
```

---

## 🛠️ Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs conversation-agent

# Inspect container
docker inspect conversation-agent

# Force recreate
docker-compose up -d --force-recreate conversation-agent
```

### Port Already in Use

```bash
# Find process using port (Windows)
netstat -ano | findstr :8080

# Change port in docker-compose.yml
ports:
  - "8091:8080"
```

### Network Issues

```bash
# Recreate network
docker-compose down
docker network prune
docker-compose up -d
```

### Out of Memory

```bash
# Increase limits in docker-compose.yml
deploy:
  resources:
    limits:
      memory: 1G
```

---

## 📈 Performance Tuning

### Build Performance
- Enable BuildKit: `DOCKER_BUILDKIT=1`
- Use layer caching effectively
- Minimize build context

### Runtime Performance
- Adjust gunicorn workers/threads
- Configure nginx worker processes
- Set appropriate resource limits

### Network Performance
- Enable connection pooling
- Configure keepalive settings
- Use connection reuse

---

## 🚢 Deployment

### Azure Container Instances

```bash
# Build and push to ACR
docker-compose build
docker tag agent:latest myregistry.azurecr.io/agent:v1.0.0
docker push myregistry.azurecr.io/agent:v1.0.0

# Deploy with Terraform (see terraform/ directory)
cd terraform
./scripts/apply.sh production
```

### Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.production.yml multiagent

# Scale services
docker service scale multiagent_conversation-agent=5
```

### Kubernetes

```bash
# Generate Kubernetes manifests from Compose
kompose convert -f docker-compose.production.yml

# Apply to cluster
kubectl apply -f .
```

---

## 🤝 Contributing

When modifying Docker configurations:

1. Test locally first
2. Update documentation
3. Follow security best practices
4. Add appropriate labels
5. Test in production-like environment

---

## 📧 Support

- **Issues:** GitHub Issues
- **Documentation:** See markdown files in this directory
- **Questions:** GitHub Discussions

---

## 📝 License

MIT License - See LICENSE file in repository root

---

**Version:** 1.0.0  
**Last Updated:** 2026-01-15  
**Maintained by:** Remaker Digital
