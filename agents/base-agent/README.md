# Base AI Agent

A sample AI agent implementation demonstrating the structure and endpoints required for the Multi-Agent Service Platform.

## Features

- ✅ Health check endpoints (`/health`, `/ready`)
- ✅ Metrics endpoint (`/metrics`)
- ✅ Azure Application Insights integration
- ✅ Structured logging
- ✅ Error handling
- ✅ Non-root container user
- ✅ Production-ready with Gunicorn

## Endpoints

### GET /
Returns agent information and available endpoints.

### GET /health
Liveness probe - returns 200 if agent is alive.

### GET /ready
Readiness probe - returns 200 if agent is ready to accept traffic.

### GET /metrics
Returns agent performance metrics.

### POST /process
Main processing endpoint for agent logic.

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `AGENT_NAME` | Name of the agent | No (default: base-agent) |
| `AGENT_DESCRIPTION` | Agent description | No |
| `ENVIRONMENT` | Environment (dev/staging/production) | No (default: development) |
| `PORT` | HTTP port | No (default: 8080) |
| `COSMOS_DB_ENDPOINT` | Cosmos DB endpoint URL | No |
| `COSMOS_DB_KEY` | Cosmos DB access key | No |
| `REDIS_HOSTNAME` | Redis cache hostname | No |
| `REDIS_KEY` | Redis access key | No |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | App Insights connection string | No |

## Local Development

### Run with Python

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export AGENT_NAME=conversation-agent
export AGENT_DESCRIPTION="Handles conversational interactions"
export ENVIRONMENT=development

# Run the app
python app.py
```

### Run with Docker

```bash
# Build the image
docker build -t base-agent:latest .

# Run the container
docker run -d \
  -p 8080:8080 \
  -e AGENT_NAME=conversation-agent \
  -e ENVIRONMENT=development \
  --name base-agent \
  base-agent:latest

# View logs
docker logs base-agent

# Test health endpoint
curl http://localhost:8080/health

# Stop and remove
docker stop base-agent
docker rm base-agent
```

## Testing

### Health Check

```bash
curl http://localhost:8080/health
```

Expected response:
```json
{
  "status": "healthy",
  "agent": "base-agent",
  "timestamp": "2025-01-15T10:30:00.000000"
}
```

### Process Request

```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, agent!"}'
```

Expected response:
```json
{
  "agent": "base-agent",
  "status": "success",
  "message": "Request processed by base-agent",
  "input": {"message": "Hello, agent!"},
  "timestamp": "2025-01-15T10:30:00.000000"
}
```

## Deployment

### Build and Push to Azure Container Registry

```bash
# Login to ACR
az acr login --name <your-registry-name>

# Build and tag
docker build -t <your-registry>.azurecr.io/base-agent:latest .

# Push to ACR
docker push <your-registry>.azurecr.io/base-agent:latest
```

### Deploy to Azure Container Instances

The Terraform infrastructure automatically deploys agents to ACI. Update the agent configuration in `terraform/variables.tf`:

```hcl
agents = {
  agent1 = {
    name        = "conversation-agent"
    description = "Handles conversational interactions"
    port        = 8080
  }
}
```

## Customization

To create a custom agent:

1. Copy the `base-agent` directory
2. Rename to your agent name
3. Modify `app.py` to implement your agent logic
4. Update `requirements.txt` with any additional dependencies
5. Update the Dockerfile if needed
6. Build and deploy

## Production Considerations

- **Logging**: All logs are written to stdout/stderr for container orchestration
- **Health Checks**: Kubernetes/ACI use `/health` and `/ready` endpoints
- **Monitoring**: Application Insights integration for telemetry
- **Security**: Runs as non-root user, minimal base image
- **Performance**: Gunicorn with 2 workers and 4 threads per worker

## License

MIT License - See LICENSE file in the project root
