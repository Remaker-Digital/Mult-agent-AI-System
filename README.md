# Multi-Agent AI Service Platform on Azure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)

A **production-ready, enterprise-grade multi-agent AI system** deployed on Microsoft Azure using Infrastructure as Code (Terraform). This platform provides a secure, scalable, and cost-optimized environment for running containerized AI agents with comprehensive networking, data storage, monitoring, and security features.

![Architecture Diagram](docs/images/architecture-placeholder.png)
*Architecture diagram showing the complete Azure infrastructure*

## 🌟 Features

### Core Infrastructure
- ✅ **5 Containerized AI Agents** on Azure Container Instances with auto-scaling
- ✅ **Azure Cosmos DB** for conversation state storage (400-4000 RU/s autoscale)
- ✅ **Azure Cache for Redis** for session management (250MB - 4GB configurable)
- ✅ **Application Gateway** with Web Application Firewall (WAF)
- ✅ **Container Registry** with geo-replication support
- ✅ **Key Vault** for secrets management
- ✅ **Application Insights + Log Analytics** for observability

### Security
- 🔒 Private Virtual Network with isolated subnets
- 🔒 Network Security Groups with least-privilege rules
- 🔒 Private endpoints for all backend services
- 🔒 Managed Identities (zero credential management)
- 🔒 TLS 1.3 enforcement
- 🔒 WAF with OWASP 3.2 ruleset
- 🔒 Customer-managed encryption keys

### Scalability
- 📈 Independent agent scaling (2-10 instances per agent)
- 📈 Cosmos DB autoscaling (400-4000 RU/s)
- 📈 Redis capacity scaling (Basic to Premium tiers)
- 📈 Application Gateway autoscaling

### Observability
- 📊 Application Insights for APM
- 📊 Centralized logging with Log Analytics
- 📊 Custom metrics and dashboards
- 📊 Pre-configured alerts (CPU, memory, errors, latency)
- 📊 Budget alerts at 80%, 95%, and 100% thresholds

## 🚀 Quick Start

### Prerequisites

- **Azure Subscription** with appropriate permissions
- **Terraform** 1.5.0 or later ([Install](https://www.terraform.io/downloads.html))
- **Azure CLI** 2.40 or later ([Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Docker Desktop** (for building agent images) ([Install](https://www.docker.com/products/docker-desktop))
- **Git** for version control

### One-Command Deployment

```bash
# Clone the repository
git clone https://github.com/Remaker-Digital/multi-agent-service-platform.git
cd multi-agent-service-platform/terraform

# Authenticate with Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Make scripts executable (Unix/Mac/Git Bash)
chmod +x scripts/*.sh

# Deploy to development environment
./scripts/init.sh dev
./scripts/plan.sh dev
./scripts/apply.sh dev
```

For detailed deployment instructions, see the [Deployment Guide](terraform/DEPLOYMENT_GUIDE.md).

## 📁 Project Structure

```
multi-agent-service-platform/
├── README.md                       # This file
├── LICENSE                         # MIT License
├── CONTRIBUTING.md                 # Contribution guidelines
├── claude.md                       # Project context for AI assistants
│
├── terraform/                      # Infrastructure as Code
│   ├── main.tf                    # Root module
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Output values
│   ├── modules/                   # 7 Terraform modules
│   ├── environments/              # Environment configs (dev/staging/prod)
│   ├── scripts/                   # Deployment automation
│   └── docs/                      # Detailed documentation
│
├── agents/                         # Agent applications
│   ├── conversation-agent/        # Conversational AI agent
│   ├── analysis-agent/            # Data analysis agent
│   ├── recommendation-agent/      # Recommendation engine
│   ├── knowledge-agent/           # Knowledge base manager
│   └── orchestration-agent/       # Multi-agent orchestrator
│
├── docker/                         # Docker configurations
│   ├── docker-compose.yml         # Local development setup
│   └── base/                      # Base Docker images
│
├── .github/                        # GitHub configurations
│   └── workflows/                 # CI/CD pipelines
│
└── docs/                          # Additional documentation
    ├── architecture.md            # Architecture details
    ├── setup/                     # Setup guides
    └── images/                    # Diagrams and screenshots
```

## 💰 Cost Estimates

| Environment | Monthly Cost | Use Case |
|-------------|--------------|----------|
| Development | ~$500 | Development and testing |
| Staging | ~$2,000 | Pre-production validation |
| Production | ~$5,000 | Live production workloads |

Cost optimization features:
- Environment-specific SKUs (Basic for dev, Premium for prod)
- Autoscaling to match demand
- Budget alerts and monitoring
- Optional geo-replication (production only)

## 🏗️ Architecture

The platform consists of 7 modular Terraform components:

1. **Networking** - VNet, subnets, NSGs, private DNS zones
2. **Security** - Key Vault, managed identities, RBAC
3. **Container Registry** - ACR with geo-replication
4. **Data Layer** - Cosmos DB and Redis
5. **Observability** - Application Insights and Log Analytics
6. **Agent Infrastructure** - Container instances with autoscaling
7. **Gateway** - Application Gateway with WAF

For detailed architecture documentation, see [Architecture Guide](docs/architecture.md).

## 🔧 Configuration

### Environment Variables

Create a `terraform/environments/<env>/terraform.tfvars` file:

```hcl
# Core Configuration
project_name = "multiagent-ai"
environment  = "dev"
location     = "eastus"

# Alert Configuration
alert_email_addresses = ["info@remakerdigital.com"]

# Budget
monthly_budget_amount = 500

# Agent Configuration
agents = {
  agent1 = {
    name        = "conversation-agent"
    description = "Handles conversational interactions"
    port        = 8080
  }
  # Add more agents...
}
```

See [terraform.tfvars.example](terraform/terraform.tfvars.example) for all available options.

## 🐳 Docker Setup

Build and push agent images:

```bash
# Build agent image
cd agents/conversation-agent
docker build -t conversation-agent:latest .

# Login to Azure Container Registry
az acr login --name <your-registry-name>

# Tag and push
docker tag conversation-agent:latest <registry>.azurecr.io/conversation-agent:latest
docker push <registry>.azurecr.io/conversation-agent:latest
```

For local development:
```bash
cd docker
docker-compose up
```

## 📊 Monitoring

### Application Insights
Access Application Insights for real-time monitoring:
```bash
APP_INSIGHTS_URL=$(terraform output -raw app_insights_id)
echo "https://portal.azure.com/#resource/$APP_INSIGHTS_URL"
```

### Log Analytics
Query logs using KQL:
```bash
az monitor log-analytics query \
  --workspace $(terraform output -raw log_analytics_workspace_id) \
  --analytics-query "ContainerInstanceLog_CL | take 100"
```

## 🛡️ Security

- **Zero Trust Architecture** - No public access to backend services
- **Managed Identities** - Eliminates credential management
- **Private Endpoints** - All data services isolated from internet
- **WAF Protection** - OWASP 3.2 + Bot detection + Rate limiting
- **Encryption** - TLS 1.3 in transit, customer-managed keys at rest

For security best practices, see [Security Guide](docs/security.md).

## 🔄 CI/CD

GitHub Actions workflows are included for:
- Terraform validation and formatting
- Infrastructure deployment (with approvals)
- Container image building and pushing
- Security scanning

See [.github/workflows/](.github/workflows/) for workflow definitions.

## 📚 Documentation

- [Deployment Guide](terraform/DEPLOYMENT_GUIDE.md) - Step-by-step deployment instructions
- [Quick Reference](terraform/QUICK_REFERENCE.md) - Common commands
- [Files Summary](terraform/FILES_SUMMARY.md) - Complete file inventory
- [Architecture Guide](docs/architecture.md) - Detailed architecture documentation
- [Security Guide](docs/security.md) - Security best practices

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on:
- Code of conduct
- Development setup
- Pull request process
- Coding standards

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Terraform](https://www.terraform.io/)
- Deployed on [Microsoft Azure](https://azure.microsoft.com/)
- Documentation generated with assistance from Claude AI

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/Remaker-Digital/multi-agent-service-platform/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Remaker-Digital/multi-agent-service-platform/discussions)
- **Email**: info@remakerdigital.com

## 🗺️ Roadmap

- [x] Terraform infrastructure modules
- [x] Environment configurations (dev/staging/production)
- [x] Security hardening with private endpoints
- [x] Comprehensive monitoring and alerting
- [ ] Sample AI agent implementations
- [ ] Kubernetes alternative (AKS)
- [ ] Multi-region deployment support
- [ ] Advanced autoscaling policies
- [ ] Terraform Cloud integration

## ⭐ Show Your Support

If you find this project helpful, please consider giving it a star on GitHub!

---

**Built with ❤️ for the AI community**
