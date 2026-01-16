# Multi-Agent AI System - Terraform Infrastructure

This directory contains Terraform configuration for deploying a production-ready multi-agent AI system on Azure.

## Architecture Overview

The infrastructure includes:

- **5 Containerized AI Agents** running on Azure Container Instances
- **Azure Cosmos DB** for conversation state storage with autoscaling (400-4000 RU/s)
- **Azure Cache for Redis** for session management (4GB memory, configurable)
- **Azure Application Gateway** with WAF for load balancing
- **Azure Container Registry** with geo-replication for image storage
- **Azure Key Vault** for secrets management with RBAC
- **Azure Monitor** (Application Insights + Log Analytics) for observability
- **Virtual Network** with private endpoints and NSGs for security
- **Managed Identities** for secure, credential-free authentication

## Prerequisites

1. **Azure CLI** - [Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform** >= 1.5.0 - [Install](https://www.terraform.io/downloads.html)
3. **Azure Subscription** with appropriate permissions
4. **Bash shell** (Git Bash on Windows, or WSL)

## Quick Start

### 1. Clone and Navigate

```bash
cd terraform
```

### 2. Authenticate with Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Initialize Terraform

```bash
chmod +x scripts/*.sh  # Make scripts executable
./scripts/init.sh dev  # For development environment
```

### 4. Review Configuration

Edit the environment-specific variables:

```bash
# For development
nano environments/dev/terraform.tfvars

# For staging
nano environments/staging/terraform.tfvars

# For production
nano environments/production/terraform.tfvars
```

### 5. Generate Execution Plan

```bash
./scripts/plan.sh dev
```

### 6. Apply Infrastructure

```bash
./scripts/apply.sh dev
```

## Project Structure

```
terraform/
├── main.tf                    # Root module and provider configuration
├── variables.tf               # Input variables with validation
├── outputs.tf                 # Output values for CI/CD integration
├── terraform.tfvars.example   # Example variable values
├── modules/
│   ├── networking/            # VNet, subnets, NSGs, private endpoints
│   ├── container-registry/    # Azure Container Registry
│   ├── agent-infrastructure/  # Container instances with scaling
│   ├── data-layer/            # Cosmos DB and Redis
│   ├── security/              # Key Vault, managed identities, RBAC
│   ├── observability/         # Application Insights, Log Analytics
│   └── gateway/               # Application Gateway with WAF
├── environments/
│   ├── dev/                   # Development environment config
│   ├── staging/               # Staging environment config
│   └── production/            # Production environment config
└── scripts/
    ├── init.sh                # Initialize Terraform with remote state
    ├── plan.sh                # Generate execution plan
    ├── apply.sh               # Apply infrastructure changes
    └── destroy.sh             # Teardown infrastructure
```

## Environments

### Development (dev)

- **Purpose**: Local development and testing
- **Cost**: ~$500/month
- **Features**:
  - Basic SKU for most services
  - No geo-replication
  - Reduced autoscaling limits (1-3 instances)
  - WAF disabled
  - Smaller resource sizes

### Staging (staging)

- **Purpose**: Pre-production testing
- **Cost**: ~$2,000/month
- **Features**:
  - Standard SKUs
  - Limited autoscaling (1-5 instances)
  - WAF in Detection mode
  - Moderate resource sizes

### Production (production)

- **Purpose**: Live production workloads
- **Cost**: ~$5,000/month
- **Features**:
  - Premium SKUs with geo-replication
  - Full autoscaling (2-10 instances)
  - WAF in Prevention mode
  - Zone redundancy
  - Enhanced monitoring and alerting

## Security Features

### Network Security

- **Private Virtual Network** with isolated subnets
- **Network Security Groups** with least-privilege rules
- **Private Endpoints** for Cosmos DB, Redis, Key Vault, and ACR
- **No public internet access** to backend services
- **Application Gateway** as the only public endpoint

### Identity and Access

- **Managed Identities** for all services (no credential management)
- **Azure RBAC** for fine-grained access control
- **Key Vault** integration for secrets
- **Customer-managed encryption keys**

### Data Protection

- **Encryption at rest** for all storage
- **TLS 1.3** for all connections
- **Private DNS zones** for internal name resolution
- **Soft delete** enabled on Key Vault

### Web Application Firewall

- **OWASP 3.2 rule set** for common vulnerabilities
- **Bot detection** to block automated attacks
- **Rate limiting** to prevent abuse (100 req/min per IP)
- **Detection vs Prevention** mode configurable per environment

## Observability

### Application Insights

- Request/response tracking
- Exception monitoring
- Performance metrics
- Custom telemetry

### Log Analytics

- Centralized logging
- Kusto Query Language (KQL) for analysis
- 30-day retention (configurable)
- Integration with all Azure services

### Alerts

- **High CPU/Memory** usage
- **High error rate** (>10 errors in 5 minutes)
- **High response time** (>1 second average)
- **Low availability** (<99%)
- **Budget alerts** at 80% and 95%

### Dashboards

- Custom workbooks for agent performance
- Real-time metrics visualization
- Cost analysis and forecasting

## Cost Optimization

### Strategies Implemented

1. **Autoscaling**: Scale based on demand (2-10 instances)
2. **Serverless Cosmos DB**: Pay only for consumed RU/s
3. **Reserved Instances**: Use for baseline load (production)
4. **Budget Alerts**: Notify at 80%, 95%, and 100% forecast
5. **Environment Sizing**: Smaller resources for dev/staging

### Cost Breakdown (Production)

| Service | Monthly Cost | Notes |
|---------|-------------|-------|
| Container Instances (5 agents × 2-10 instances) | $1,500 | Autoscaling enabled |
| Application Gateway (WAF v2) | $600 | Zone redundant |
| Cosmos DB (4000 RU/s max) | $1,200 | Autoscale 400-4000 |
| Redis Premium (4GB) | $500 | Persistence enabled |
| Container Registry (Premium) | $400 | Geo-replicated |
| Application Insights | $300 | 10GB daily cap |
| Key Vault | $50 | Premium tier |
| Networking | $250 | Bandwidth charges |
| **Total** | **~$4,800** | Subject to usage |

## Scaling Configuration

### Agent Autoscaling

Azure Container Instances don't have native autoscaling, so we implement it via Azure Automation:

- **Min instances**: 2 (production), 1 (staging/dev)
- **Max instances**: 10 (production), 5 (staging), 3 (dev)
- **Scale triggers**: CPU >80%, Memory >80%, Queue depth
- **Cooldown**: 5 minutes between scale operations

### Database Autoscaling

- **Cosmos DB**: 400-4000 RU/s (auto-scales based on usage)
- **Redis**: Fixed capacity with Premium tier for production

## Disaster Recovery

### Backup Strategy

- **Cosmos DB**: Automatic backups every 4 hours, 8-hour retention
- **Redis**: RDB snapshots every 60 minutes (Premium tier)
- **Terraform State**: Stored in Azure Blob Storage with versioning

### High Availability

- **Zone redundancy** for Application Gateway and Redis (production)
- **Geo-replication** for Container Registry (production)
- **Automatic failover** for Cosmos DB (production)

## Maintenance

### Updating Infrastructure

```bash
# 1. Review changes
./scripts/plan.sh production

# 2. Apply updates
./scripts/apply.sh production

# 3. Verify deployment
terraform output
```

### Rotating Secrets

```bash
# Secrets are automatically rotated via Key Vault policies
# Manual rotation:
az keyvault secret set \
  --vault-name $(terraform output -raw key_vault_name) \
  --name "secret-name" \
  --value "new-value"
```

### Upgrading Terraform

```bash
# Update provider versions in main.tf
terraform init -upgrade
```

## Troubleshooting

### Common Issues

1. **Terraform Init Fails**
   - Check Azure CLI authentication: `az account show`
   - Verify subscription permissions
   - Ensure storage account exists for backend

2. **Plan Shows Unexpected Changes**
   - Check for manual changes in Azure Portal
   - Review state file: `terraform state list`
   - Refresh state: `terraform refresh`

3. **Apply Fails**
   - Review error messages in output
   - Check Azure service quotas
   - Verify network connectivity

4. **Agents Not Starting**
   - Check container logs in Azure Portal
   - Verify Key Vault access for managed identity
   - Review Application Insights for errors

### Logs and Diagnostics

```bash
# View Terraform state
terraform state show <resource>

# Show outputs
terraform output

# Container logs
az container logs --resource-group <rg> --name <container-name>

# Application Insights query
az monitor app-insights query \
  --app <app-id> \
  --analytics-query "traces | take 100"
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Terraform Init
        run: ./scripts/init.sh production

      - name: Terraform Plan
        run: ./scripts/plan.sh production

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: ./scripts/apply.sh production
```

## Security Best Practices

1. **Never commit secrets** to version control
2. **Use managed identities** instead of service principals where possible
3. **Enable soft delete** on Key Vault (production)
4. **Review NSG rules** regularly
5. **Monitor failed authentication** attempts
6. **Rotate keys** every 90 days
7. **Enable diagnostic logs** on all resources
8. **Review WAF logs** for attacks

## Contributing

1. Create a feature branch
2. Test changes in dev environment
3. Generate and review plan
4. Submit pull request with plan output
5. Apply to staging for validation
6. Deploy to production after approval

## Support

For issues or questions:
- Review logs in Application Insights
- Check Azure Service Health
- Contact DevOps team
- File an issue in the repository

## License

Copyright © 2025 - All Rights Reserved
