# Quick Reference - Terraform Commands

A quick reference guide for common operations with the multi-agent AI infrastructure.

## Common Workflows

### Initial Deployment

```bash
# 1. Initialize
./scripts/init.sh dev

# 2. Plan
./scripts/plan.sh dev

# 3. Apply
./scripts/apply.sh dev
```

### Update Infrastructure

```bash
# After making changes to .tf files
./scripts/plan.sh dev
./scripts/apply.sh dev
```

### Destroy Infrastructure

```bash
./scripts/destroy.sh dev
```

## Terraform Commands

### Initialization

```bash
# Initialize with backend
terraform init

# Reinitialize (upgrade providers)
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure
```

### Planning

```bash
# Create execution plan
terraform plan -var-file=environments/dev/terraform.tfvars

# Save plan to file
terraform plan -var-file=environments/dev/terraform.tfvars -out=plan.tfplan

# Destroy plan
terraform plan -destroy -var-file=environments/dev/terraform.tfvars
```

### Applying

```bash
# Apply with prompt
terraform apply -var-file=environments/dev/terraform.tfvars

# Apply saved plan
terraform apply plan.tfplan

# Auto-approve (use with caution!)
terraform apply -var-file=environments/dev/terraform.tfvars -auto-approve
```

### Outputs

```bash
# Show all outputs
terraform output

# Show specific output
terraform output container_registry_login_server

# Show output in JSON
terraform output -json

# Show sensitive outputs
terraform output -raw app_insights_instrumentation_key
```

### State Management

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.main

# Remove resource from state (danger!)
terraform state rm azurerm_container_group.agents["agent1"]

# Move resource in state
terraform state mv azurerm_container_group.old azurerm_container_group.new

# Pull remote state
terraform state pull > backup.tfstate

# Refresh state
terraform refresh -var-file=environments/dev/terraform.tfvars
```

### Workspace Management

```bash
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new dev

# Switch workspace
terraform workspace select dev

# Delete workspace
terraform workspace delete dev
```

### Validation and Formatting

```bash
# Validate configuration
terraform validate

# Format all .tf files
terraform fmt -recursive

# Check formatting
terraform fmt -check
```

### Importing Resources

```bash
# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/SUB_ID/resourceGroups/RG_NAME

# Example: Import container group
terraform import 'module.agent_infrastructure.azurerm_container_group.agents["agent1"]' /subscriptions/SUB_ID/resourceGroups/RG_NAME/providers/Microsoft.ContainerInstance/containerGroups/CONTAINER_NAME
```

## Azure CLI Commands

### Authentication

```bash
# Login
az login

# Login with service principal
az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID

# Set subscription
az account set --subscription "SUBSCRIPTION_NAME"

# Show current account
az account show
```

### Resource Management

```bash
# List resource groups
az group list --output table

# Show resource group
az group show --name rg-multiagent-ai-dev-eastus

# List resources in group
az resource list --resource-group rg-multiagent-ai-dev-eastus --output table

# Delete resource group (danger!)
az group delete --name rg-multiagent-ai-dev-eastus --yes
```

### Container Registry

```bash
# Login to ACR
az acr login --name acrname

# List repositories
az acr repository list --name acrname --output table

# List tags
az acr repository show-tags --name acrname --repository agent-base --output table

# Delete image
az acr repository delete --name acrname --image agent-base:old-tag --yes
```

### Container Instances

```bash
# List container groups
az container list --resource-group rg-multiagent-ai-dev-eastus --output table

# Show container group
az container show --resource-group rg-multiagent-ai-dev-eastus --name aci-conversation-agent-dev

# Get logs
az container logs --resource-group rg-multiagent-ai-dev-eastus --name aci-conversation-agent-dev

# Stream logs
az container attach --resource-group rg-multiagent-ai-dev-eastus --name aci-conversation-agent-dev

# Restart container
az container restart --resource-group rg-multiagent-ai-dev-eastus --name aci-conversation-agent-dev

# Delete container
az container delete --resource-group rg-multiagent-ai-dev-eastus --name aci-conversation-agent-dev --yes
```

### Key Vault

```bash
# List vaults
az keyvault list --output table

# Show vault
az keyvault show --name kv-name

# List secrets
az keyvault secret list --vault-name kv-name --output table

# Get secret value
az keyvault secret show --vault-name kv-name --name secret-name --query value -o tsv

# Set secret
az keyvault secret set --vault-name kv-name --name secret-name --value "secret-value"

# Delete secret
az keyvault secret delete --vault-name kv-name --name secret-name
```

### Cosmos DB

```bash
# List accounts
az cosmosdb list --output table

# Show account
az cosmosdb show --resource-group rg-name --name cosmos-name

# List databases
az cosmosdb sql database list --account-name cosmos-name --resource-group rg-name

# Get connection string
az cosmosdb keys list --type connection-strings --resource-group rg-name --name cosmos-name
```

### Redis

```bash
# List caches
az redis list --output table

# Show cache
az redis show --resource-group rg-name --name redis-name

# Get access keys
az redis list-keys --resource-group rg-name --name redis-name

# Force reboot
az redis force-reboot --resource-group rg-name --name redis-name --reboot-type AllNodes
```

### Monitoring

```bash
# Query Application Insights
az monitor app-insights query \
  --app APP_ID \
  --analytics-query "traces | take 100"

# List Log Analytics queries
az monitor log-analytics query \
  --workspace WORKSPACE_ID \
  --analytics-query "ContainerInstanceLog_CL | take 100"

# List alerts
az monitor metrics alert list --resource-group rg-name

# Create alert
az monitor metrics alert create \
  --name alert-name \
  --resource-group rg-name \
  --scopes /subscriptions/SUB_ID/resourceGroups/RG_NAME/providers/... \
  --condition "avg Percentage CPU > 80"
```

### Costs

```bash
# Show consumption
az consumption usage list --start-date 2025-01-01 --output table

# Show budgets
az consumption budget list --output table

# Create budget
az consumption budget create \
  --budget-name monthly-budget \
  --amount 5000 \
  --time-grain Monthly \
  --start-date 2025-01-01 \
  --end-date 2025-12-31
```

## Docker Commands

### Building and Pushing

```bash
# Build image
docker build -t agent-base:latest .

# Tag for ACR
docker tag agent-base:latest acrname.azurecr.io/agent-base:latest

# Push to ACR
docker push acrname.azurecr.io/agent-base:latest

# Pull from ACR
docker pull acrname.azurecr.io/agent-base:latest
```

### Local Testing

```bash
# Run container locally
docker run -d \
  -p 8080:8080 \
  -e COSMOS_DB_ENDPOINT="https://..." \
  -e REDIS_HOSTNAME="..." \
  --name agent-test \
  agent-base:latest

# View logs
docker logs agent-test

# Stop container
docker stop agent-test

# Remove container
docker rm agent-test
```

## Troubleshooting Commands

### Check Resource Health

```bash
# Resource group
az group show --name rg-name --query properties.provisioningState

# Container instances
az container show --resource-group rg-name --name container-name --query instanceView.state

# Application Gateway
az network application-gateway show-backend-health \
  --resource-group rg-name \
  --name appgw-name
```

### Network Diagnostics

```bash
# NSG effective rules
az network nsg show --resource-group rg-name --name nsg-name

# Route table
az network route-table list --resource-group rg-name

# Private endpoint
az network private-endpoint list --resource-group rg-name

# DNS resolution (from within VNet)
nslookup cosmos-name.documents.azure.com
```

### Logs and Diagnostics

```bash
# Activity log
az monitor activity-log list --resource-group rg-name

# Diagnostic settings
az monitor diagnostic-settings list --resource RESOURCE_ID

# Container logs with filter
az container logs \
  --resource-group rg-name \
  --name container-name \
  --follow \
  | grep ERROR
```

## Environment Variables

### Required for Scripts

```bash
# Azure authentication
export ARM_SUBSCRIPTION_ID="..."
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."

# Terraform
export TF_LOG=DEBUG  # Enable debug logging
export TF_LOG_PATH=terraform.log  # Log file path
```

## Git Workflow

### Making Changes

```bash
# Create feature branch
git checkout -b feature/add-new-agent

# Make changes to .tf files
# ...

# Test changes
./scripts/plan.sh dev

# Commit changes
git add .
git commit -m "feat: add new agent configuration"

# Push branch
git push origin feature/add-new-agent

# Create pull request
# Review and merge
```

### Tagging Releases

```bash
# Create tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag
git push origin v1.0.0

# List tags
git tag -l
```

## Common Issues and Solutions

### Issue: "Error acquiring state lock"

```bash
# List locks
az lock list --resource-group rg-name

# Remove lock (if safe)
az lock delete --name lock-name --resource-group rg-name

# Force unlock in Terraform
terraform force-unlock LOCK_ID
```

### Issue: "Container failed to start"

```bash
# Check logs
az container logs --resource-group rg-name --name container-name --tail 100

# Check events
az container show --resource-group rg-name --name container-name --query instanceView.events

# Verify image
az acr repository show --name acrname --image agent-base:latest
```

### Issue: "Application Gateway 502 errors"

```bash
# Check backend health
az network application-gateway show-backend-health \
  --resource-group rg-name \
  --name appgw-name

# Check NSG rules
az network nsg rule list \
  --resource-group rg-name \
  --nsg-name nsg-agents-dev \
  --output table
```

## Performance Tips

### Terraform Performance

```bash
# Use parallelism
terraform apply -parallelism=20

# Target specific resources
terraform apply -target=module.agent_infrastructure

# Reduce output
terraform apply -compact-warnings
```

### Azure Performance

```bash
# Use batch operations
az group list --query "[].name" -o tsv | xargs -I {} az group show --name {}

# Parallel execution with GNU parallel
parallel az container restart --resource-group rg-name --name {} ::: aci-agent1 aci-agent2
```

## Best Practices

1. **Always plan before apply**
   ```bash
   ./scripts/plan.sh env && ./scripts/apply.sh env
   ```

2. **Use version control for state**
   - Remote backend configured automatically

3. **Never commit secrets**
   - Use `.gitignore`
   - Use Key Vault for secrets

4. **Test in dev first**
   ```bash
   ./scripts/apply.sh dev
   # Verify
   ./scripts/apply.sh staging
   # Verify
   ./scripts/apply.sh production
   ```

5. **Use meaningful commit messages**
   ```bash
   git commit -m "feat: add agent5 configuration"
   git commit -m "fix: correct NSG rule for agents"
   ```

---

**Quick Reference Version**: 1.0
**Last Updated**: 2025-01-15
