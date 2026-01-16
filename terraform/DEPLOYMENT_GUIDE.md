# Multi-Agent AI System - Deployment Guide

This guide walks you through deploying the multi-agent AI infrastructure on Azure from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deployment Steps](#deployment-steps)
4. [Post-Deployment Configuration](#post-deployment-configuration)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

1. **Azure CLI** (version 2.40+)
   ```bash
   az --version
   ```
   Install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

2. **Terraform** (version 1.5.0+)
   ```bash
   terraform --version
   ```
   Install: https://www.terraform.io/downloads.html

3. **Git Bash** (Windows) or Bash shell (Linux/Mac)

### Azure Requirements

1. **Active Azure Subscription** with sufficient quota:
   - At least 20 vCPUs for Container Instances
   - Premium SKU access for Container Registry
   - Cosmos DB and Redis quota

2. **Permissions**: Owner or Contributor role on the subscription

3. **Service Principals** (optional, for CI/CD):
   ```bash
   az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
   ```

## Initial Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd terraform
```

### 2. Authenticate with Azure

```bash
# Login to Azure
az login

# Set the subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify
az account show
```

### 3. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### 4. Choose Environment

Decide which environment to deploy first:
- **dev**: For development and testing (~$500/month)
- **staging**: For pre-production validation (~$2,000/month)
- **production**: For live workloads (~$5,000/month)

## Deployment Steps

### Step 1: Initialize Terraform

This creates the remote state storage and initializes Terraform:

```bash
./scripts/init.sh dev
```

**What it does:**
- Creates Azure Storage Account for Terraform state
- Initializes Terraform backend
- Downloads required providers
- Validates configuration

**Expected output:**
```
[INFO] Initializing Terraform for environment: dev
[INFO] Backend configuration:
  Resource Group: rg-terraform-state
  Storage Account: sttfstatedev
  Container: tfstate
  State File: multiagent-ai-dev.tfstate
[INFO] Terraform initialized successfully for dev environment
[INFO] Terraform configuration is valid
```

### Step 2: Review Configuration

Edit the environment-specific variables:

```bash
# For development
nano environments/dev/terraform.tfvars
```

**Key settings to review:**

1. **Email Alerts**: Update `alert_email_addresses`
   ```hcl
   alert_email_addresses = ["your-email@example.com"]
   ```

2. **Budget**: Adjust `monthly_budget_amount` if needed
   ```hcl
   monthly_budget_amount = 500  # for dev
   ```

3. **Agents**: Customize agent configuration
   ```hcl
   agents = {
     agent1 = {
       name        = "conversation-agent"
       description = "Handles conversational interactions"
       port        = 8080
     }
     # ... add or modify agents
   }
   ```

4. **Resources**: Review CPU/memory allocation
   ```hcl
   agent_cpu    = 0.5  # CPU cores per container
   agent_memory = 1.5  # GB per container
   ```

### Step 3: Generate Execution Plan

Create a plan to review changes before applying:

```bash
./scripts/plan.sh dev
```

**What to look for:**
- Number of resources to create (should be ~50+ for initial deployment)
- No unexpected deletions or modifications
- Resource naming conventions are correct
- Costs estimates (if available)

**Expected output:**
```
Plan: 54 to add, 0 to change, 0 to destroy.
```

**Review the plan carefully!** Look for:
- ✅ All expected resources are being created
- ✅ Network security groups have correct rules
- ✅ Private endpoints are configured
- ✅ Managed identities are created
- ⚠️ No accidental public exposure

### Step 4: Apply Infrastructure

Deploy the infrastructure:

```bash
./scripts/apply.sh dev
```

**Duration**: 15-25 minutes for initial deployment

**What happens:**
1. Creates resource group
2. Deploys virtual network and subnets
3. Creates Log Analytics workspace
4. Deploys Key Vault with managed identities
5. Creates Container Registry
6. Deploys Cosmos DB with private endpoint
7. Creates Redis cache with private endpoint
8. Sets up Application Insights
9. Deploys container groups (agents)
10. Configures Application Gateway

**Expected output:**
```
Apply complete! Resources: 54 added, 0 changed, 0 destroyed.

Outputs:

application_gateway_public_ip = "20.121.45.67"
container_registry_login_server = "acrmultiagentaidevabcdef.azurecr.io"
cosmos_db_endpoint = "https://cosmos-multiagent-ai-dev-abcdef.documents.azure.com:443/"
key_vault_uri = "https://kv-multiagent-ai-dev-abcdef.vault.azure.net/"
redis_hostname = "redis-multiagent-ai-dev-abcdef.redis.cache.windows.net"
```

### Step 5: Save Outputs

Outputs are automatically saved to `outputs/` directory:

```bash
cat outputs/dev-outputs-*.json
```

Store these safely - you'll need them for:
- CI/CD pipelines
- Application configuration
- Troubleshooting

## Post-Deployment Configuration

### 1. Build and Push Container Images

Your agents need container images in ACR:

```bash
# Get ACR login server from outputs
ACR_SERVER=$(terraform output -raw container_registry_login_server)

# Login to ACR
az acr login --name $(terraform output -raw container_registry_name)

# Build your agent image (example)
cd ../agent-code  # Navigate to your agent code
docker build -t agent-base:latest .

# Tag for ACR
docker tag agent-base:latest $ACR_SERVER/agent-base:latest

# Push to ACR
docker push $ACR_SERVER/agent-base:latest
```

### 2. Configure Agent Environment Variables

If you need additional environment variables, update the agent infrastructure module or use Key Vault secrets.

### 3. Set Up Monitoring Alerts

Access Application Insights:

```bash
APP_INSIGHTS_ID=$(terraform output -raw app_insights_id)
echo "https://portal.azure.com/#resource/$APP_INSIGHTS_ID"
```

Configure additional alerts in Azure Portal:
1. Navigate to Application Insights
2. Go to "Alerts" > "New alert rule"
3. Add custom metrics for your agents

### 4. Configure WAF Rules (Production)

For production, review and customize WAF rules:

```bash
# Navigate to Application Gateway in Azure Portal
GATEWAY_ID=$(terraform output -raw application_gateway_id)
echo "https://portal.azure.com/#resource/$GATEWAY_ID"
```

### 5. Set Up DNS (Optional)

Point your domain to the Application Gateway:

```bash
# Get the public IP
APP_GATEWAY_IP=$(terraform output -raw application_gateway_public_ip)

# Create DNS A record
# example.com -> $APP_GATEWAY_IP
```

## Verification

### 1. Check Resource Health

```bash
# List all resources in the resource group
RG_NAME=$(terraform output -raw resource_group_name)
az resource list --resource-group $RG_NAME --output table
```

### 2. Verify Container Instances

```bash
# List container groups
az container list --resource-group $RG_NAME --output table

# Check logs for one agent
az container logs --resource-group $RG_NAME --name aci-conversation-agent-dev
```

### 3. Test Application Gateway

```bash
# Get public IP
APP_GATEWAY_IP=$(terraform output -raw application_gateway_public_ip)

# Test HTTP endpoint
curl http://$APP_GATEWAY_IP/health
```

### 4. Verify Private Endpoints

```bash
# Check Cosmos DB connectivity (from within VNet)
# This requires a VM or Azure Bastion in the VNet

# Verify Redis connectivity
az redis show --resource-group $RG_NAME --name $(terraform output -raw redis_name) --query "provisioningState"
```

### 5. Check Monitoring

```bash
# View recent logs in Application Insights
az monitor app-insights query \
  --app $(terraform output -raw app_insights_app_id) \
  --analytics-query "traces | take 100"
```

### 6. Verify Costs

```bash
# Check current costs
az consumption usage list --start-date $(date -d '7 days ago' '+%Y-%m-%d') --output table
```

## Troubleshooting

### Common Issues

#### 1. Terraform Init Fails

**Error**: "Failed to get existing workspaces"

**Solution**:
```bash
# Check Azure login
az account show

# Re-authenticate
az login

# Clear Terraform cache
rm -rf .terraform
./scripts/init.sh dev
```

#### 2. Container Registry Access Denied

**Error**: "Failed to pull image from ACR"

**Solution**:
```bash
# Verify managed identity has AcrPull role
IDENTITY_ID=$(terraform output -raw user_assigned_identity_principal_id)
ACR_ID=$(terraform output -raw container_registry_id)

az role assignment create \
  --assignee $IDENTITY_ID \
  --role AcrPull \
  --scope $ACR_ID
```

#### 3. Container Instances Not Starting

**Check logs**:
```bash
az container logs --resource-group $RG_NAME --name aci-conversation-agent-dev --tail 100
```

**Common causes**:
- Image not found in ACR
- Environment variables misconfigured
- Health check failing
- Insufficient CPU/memory

#### 4. Application Gateway 502 Errors

**Check backend health**:
```bash
az network application-gateway show-backend-health \
  --resource-group $RG_NAME \
  --name $(terraform output -raw application_gateway_name)
```

**Common causes**:
- Backend agents not responding to health probes
- NSG blocking traffic
- Agents not listening on configured port

#### 5. Cosmos DB Connection Timeout

**Verify private endpoint**:
```bash
# Check private endpoint connection
az network private-endpoint list --resource-group $RG_NAME --output table
```

**Common causes**:
- DNS resolution failing (check private DNS zones)
- Network security group blocking traffic
- Firewall rules on Cosmos DB

#### 6. High Costs

**Check cost breakdown**:
```bash
az consumption usage list \
  --start-date $(date -d '1 month ago' '+%Y-%m-%d') \
  --query "[?contains(instanceName, 'multiagent')]" \
  --output table
```

**Cost optimization**:
- Scale down dev/staging environments when not in use
- Review autoscaling settings
- Check Cosmos DB RU/s consumption
- Verify Application Gateway is not over-provisioned

### Getting Help

1. **Review Terraform logs**: Check plan output for warnings
2. **Check Azure Activity Log**: Portal > Resource Group > Activity Log
3. **Application Insights**: Review exceptions and traces
4. **Azure Support**: Create a support ticket for Azure-specific issues

## Rolling Back

If you need to rollback:

### Option 1: Destroy and Redeploy

```bash
# Destroy infrastructure
./scripts/destroy.sh dev

# Redeploy from last known good configuration
git checkout <good-commit>
./scripts/init.sh dev
./scripts/apply.sh dev
```

### Option 2: Terraform State Rollback

```bash
# List state versions
az storage blob list \
  --account-name sttfstatedev \
  --container-name tfstate \
  --prefix multiagent-ai-dev.tfstate \
  --output table

# Download previous version
az storage blob download \
  --account-name sttfstatedev \
  --container-name tfstate \
  --name multiagent-ai-dev.tfstate.<version> \
  --file terraform.tfstate.backup

# Restore (use with caution!)
mv terraform.tfstate.backup .terraform/terraform.tfstate
```

## Scaling to Other Environments

### Deploy Staging

After successful dev deployment:

```bash
# Initialize staging
./scripts/init.sh staging

# Review staging configuration
nano environments/staging/terraform.tfvars

# Plan staging
./scripts/plan.sh staging

# Apply staging
./scripts/apply.sh staging
```

### Deploy Production

**Important**: Production requires additional approvals and safeguards.

```bash
# Initialize production
./scripts/init.sh production

# Review production configuration carefully
nano environments/production/terraform.tfvars

# Generate plan and save
./scripts/plan.sh production -out=production.tfplan

# Review plan with team
terraform show production.tfplan

# Get approval from stakeholders

# Apply production (requires double confirmation)
./scripts/apply.sh production production.tfplan
```

## Next Steps

After successful deployment:

1. ✅ Set up CI/CD pipelines (GitHub Actions, Azure DevOps)
2. ✅ Configure monitoring dashboards
3. ✅ Implement backup and disaster recovery procedures
4. ✅ Document runbooks for common operations
5. ✅ Schedule regular security reviews
6. ✅ Set up log retention policies
7. ✅ Configure cost alerts
8. ✅ Plan capacity scaling strategy

## Maintenance Schedule

- **Daily**: Review monitoring alerts
- **Weekly**: Check cost trends, review logs
- **Monthly**: Update Terraform providers, review security
- **Quarterly**: Disaster recovery testing, capacity planning

## Support Contacts

- **DevOps Team**: devops@example.com
- **Security Team**: security@example.com
- **Azure Support**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade

---

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Maintained By**: DevOps Team
