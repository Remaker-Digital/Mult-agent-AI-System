# Docker Quick Reference

**Multi-Agent AI Platform - Common Commands & Workflows**

---

## Quick Start

```bash
# Development Environment
docker-compose up -d

# Production Environment  
docker-compose -f docker-compose.production.yml up -d

# Stop Everything
docker-compose down
```

---

## Build Commands

```bash
# Build all services
docker-compose build

# Build specific service
docker-compose build conversation-agent

# Build without cache
docker-compose build --no-cache

# Build with specific Dockerfile
docker build -f Dockerfile.production -t agent:prod .
```

---

## Start/Stop Commands

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d conversation-agent

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Restart service
docker-compose restart conversation-agent

# Pause/Unpause
docker-compose pause conversation-agent
docker-compose unpause conversation-agent
```

---

## Logs & Monitoring

```bash
# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f conversation-agent

# Last N lines
docker-compose logs --tail=100 conversation-agent

# Since timestamp
docker-compose logs --since 2h conversation-agent

# Real-time stats
docker stats

# Container details
docker inspect conversation-agent
```

---

## Scaling

```bash
# Scale specific agent
docker-compose up -d --scale conversation-agent=3

# Scale multiple agents
docker-compose up -d \
  --scale conversation-agent=3 \
  --scale analysis-agent=2
```

---

## Health Checks

```bash
# Check service status
docker-compose ps

# Test health endpoint
curl http://localhost:8081/health

# All agent health checks
curl http://localhost:8081/health  # Conversation
curl http://localhost:8082/health  # Analysis
curl http://localhost:8083/health  # Recommendation
curl http://localhost:8084/health  # Knowledge
curl http://localhost:8085/health  # Orchestration

# Gateway health
curl http://localhost/health
```

---

## Execute Commands in Container

```bash
# Open shell
docker-compose exec conversation-agent /bin/sh

# Run command
docker-compose exec conversation-agent python --version

# As different user
docker-compose exec -u root conversation-agent /bin/sh

# One-off command
docker-compose run --rm conversation-agent python -c "print('Hello')"
```

---

## Debugging

```bash
# View configuration
docker-compose config

# Validate compose file
docker-compose config --quiet

# List containers
docker ps
docker ps -a  # Include stopped

# Container logs
docker logs conversation-agent
docker logs -f --tail=100 conversation-agent

# Inspect container
docker inspect conversation-agent

# Container processes
docker top conversation-agent

# Network info
docker network ls
docker network inspect multiagent_agent-network

# Volume info
docker volume ls
docker volume inspect multiagent_redis-data
```

---

## Testing & Development

```bash
# Build and start fresh
docker-compose up -d --build

# Rebuild specific service
docker-compose up -d --build conversation-agent

# Test API endpoints
curl -X POST http://localhost/api/conversation/process \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'

# Check metrics
curl http://localhost:8081/metrics

# View service info
curl http://localhost:8081/
```

---

## Cleanup

```bash
# Stop and remove containers
docker-compose down

# Remove volumes too
docker-compose down -v

# Remove specific volume
docker volume rm multiagent_redis-data

# Remove unused images
docker image prune

# Remove all unused resources
docker system prune -a

# See disk usage
docker system df
```

---

## Production Workflows

### Deploy New Version

```bash
# 1. Build new images
docker-compose -f docker-compose.production.yml build

# 2. Tag for registry
docker tag agent:prod myregistry.azurecr.io/agent:v1.0.1

# 3. Push to registry
docker push myregistry.azurecr.io/agent:v1.0.1

# 4. Update production (rolling)
docker-compose -f docker-compose.production.yml up -d --no-deps conversation-agent
```

### Rolling Update

```bash
# Update without downtime
docker-compose -f docker-compose.production.yml up -d \
  --no-deps \
  --build \
  conversation-agent
```

### Backup & Restore

```bash
# Backup Redis volume
docker run --rm \
  -v multiagent_redis-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/redis-backup.tar.gz /data

# Restore Redis volume
docker run --rm \
  -v multiagent_redis-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/redis-backup.tar.gz -C /
```

---

## Environment Variables

```bash
# Load from .env file
docker-compose --env-file .env.production up -d

# Override specific variable
REDIS_PASSWORD=newsecret docker-compose up -d

# View environment
docker-compose exec conversation-agent env
```

---

## Network Commands

```bash
# Create network
docker network create multiagent-network

# Connect container to network
docker network connect multiagent-network conversation-agent

# Disconnect
docker network disconnect multiagent-network conversation-agent

# Inspect network
docker network inspect multiagent_agent-network

# Test connectivity
docker-compose exec conversation-agent ping redis
docker-compose exec conversation-agent nslookup redis
```

---

## Volume Commands

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect multiagent_redis-data

# Create volume
docker volume create redis-data

# Remove volume
docker volume rm multiagent_redis-data

# Browse volume data
docker run --rm -v multiagent_redis-data:/data alpine ls -la /data
```

---

## Registry Operations

```bash
# Login to Azure Container Registry
az acr login --name myregistry

# Tag image
docker tag agent:latest myregistry.azurecr.io/agent:v1.0.0

# Push to registry
docker push myregistry.azurecr.io/agent:v1.0.0

# Pull from registry
docker pull myregistry.azurecr.io/agent:v1.0.0

# List registry images
az acr repository list --name myregistry
```

---

## Performance Monitoring

```bash
# Real-time stats
docker stats

# Formatted stats
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Single snapshot
docker stats --no-stream

# Container resource usage
docker inspect conversation-agent | jq '.[0].HostConfig.Memory'
```

---

## Security

```bash
# Scan image for vulnerabilities
docker scan conversation-agent:latest

# Check running processes
docker top conversation-agent

# Verify user
docker-compose exec conversation-agent whoami

# Check capabilities
docker inspect conversation-agent | jq '.[0].HostConfig.CapAdd'
```

---

## Troubleshooting Quick Fixes

### Port Already in Use
```bash
# Find process (Windows)
netstat -ano | findstr :8080

# Find process (Linux/Mac)
lsof -i :8080

# Use different port
ports:
  - "8091:8080"
```

### Container Won't Start
```bash
# Check logs
docker-compose logs conversation-agent

# Check events
docker events --filter container=conversation-agent

# Force recreate
docker-compose up -d --force-recreate conversation-agent
```

### Out of Disk Space
```bash
# Clean everything
docker system prune -a --volumes

# Remove old images
docker image prune -a

# Remove stopped containers
docker container prune
```

### DNS Issues
```bash
# Recreate network
docker-compose down
docker network prune
docker-compose up -d

# Test DNS
docker-compose exec conversation-agent nslookup redis
```

---

## Useful Aliases

Add to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
# Docker Compose shortcuts
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dcp='docker-compose ps'
alias dcr='docker-compose restart'

# Docker shortcuts
alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dlog='docker logs -f'
alias dex='docker exec -it'

# Cleanup
alias dclean='docker system prune -a --volumes'
alias dclean-i='docker image prune -a'
alias dclean-c='docker container prune'
```

---

## Access Points Summary

| Service | Local URL | Port |
|---------|-----------|------|
| Nginx Gateway | http://localhost | 80 |
| Conversation Agent | http://localhost:8081 | 8081 |
| Analysis Agent | http://localhost:8082 | 8082 |
| Recommendation Agent | http://localhost:8083 | 8083 |
| Knowledge Agent | http://localhost:8084 | 8084 |
| Orchestration Agent | http://localhost:8085 | 8085 |
| Redis | localhost:6379 | 6379 |

---

## API Testing

```bash
# Health checks
curl http://localhost/health
curl http://localhost:8081/health

# Process request
curl -X POST http://localhost/api/conversation/process \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, agent!"}'

# Get metrics
curl http://localhost:8081/metrics

# Service info
curl http://localhost:8081/
```

---

## Getting Help

```bash
# Docker help
docker --help
docker compose --help
docker run --help

# Compose file reference
docker-compose config --help

# Image help
docker image --help

# Network help
docker network --help
```

---

**For detailed documentation, see:** `docker/DOCKER_BEST_PRACTICES.md`
