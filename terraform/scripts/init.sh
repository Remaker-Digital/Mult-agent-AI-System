#!/bin/bash

# Terraform Initialization Script
# This script initializes Terraform with remote state backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment argument is provided
if [ -z "$1" ]; then
    print_error "Environment argument is required"
    echo "Usage: ./init.sh <environment>"
    echo "Environments: dev, staging, production"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Valid environments: dev, staging, production"
    exit 1
fi

print_info "Initializing Terraform for environment: $ENVIRONMENT"

# Change to terraform directory
cd "$(dirname "$0")/.." || exit 1

# Backend configuration
BACKEND_RESOURCE_GROUP="rg-terraform-state"
BACKEND_STORAGE_ACCOUNT="sttfstate${ENVIRONMENT}"
BACKEND_CONTAINER="tfstate"
BACKEND_KEY="multiagent-ai-${ENVIRONMENT}.tfstate"

print_info "Backend configuration:"
echo "  Resource Group: $BACKEND_RESOURCE_GROUP"
echo "  Storage Account: $BACKEND_STORAGE_ACCOUNT"
echo "  Container: $BACKEND_CONTAINER"
echo "  State File: $BACKEND_KEY"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
print_info "Checking Azure login status..."
if ! az account show &> /dev/null; then
    print_warning "Not logged in to Azure"
    print_info "Logging in to Azure..."
    az login
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
print_info "Using subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"

# Create backend storage account if it doesn't exist
print_info "Checking if backend storage account exists..."
if ! az storage account show --name "$BACKEND_STORAGE_ACCOUNT" --resource-group "$BACKEND_RESOURCE_GROUP" &> /dev/null; then
    print_warning "Backend storage account does not exist"
    print_info "Creating resource group: $BACKEND_RESOURCE_GROUP"
    az group create --name "$BACKEND_RESOURCE_GROUP" --location eastus

    print_info "Creating storage account: $BACKEND_STORAGE_ACCOUNT"
    az storage account create \
        --name "$BACKEND_STORAGE_ACCOUNT" \
        --resource-group "$BACKEND_RESOURCE_GROUP" \
        --location eastus \
        --sku Standard_LRS \
        --encryption-services blob \
        --https-only true \
        --min-tls-version TLS1_2

    # Get storage account key
    STORAGE_KEY=$(az storage account keys list \
        --account-name "$BACKEND_STORAGE_ACCOUNT" \
        --resource-group "$BACKEND_RESOURCE_GROUP" \
        --query '[0].value' -o tsv)

    print_info "Creating container: $BACKEND_CONTAINER"
    az storage container create \
        --name "$BACKEND_CONTAINER" \
        --account-name "$BACKEND_STORAGE_ACCOUNT" \
        --account-key "$STORAGE_KEY"
else
    print_info "Backend storage account already exists"
fi

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init \
    -backend-config="resource_group_name=$BACKEND_RESOURCE_GROUP" \
    -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" \
    -backend-config="container_name=$BACKEND_CONTAINER" \
    -backend-config="key=$BACKEND_KEY" \
    -reconfigure

if [ $? -eq 0 ]; then
    print_info "Terraform initialized successfully for $ENVIRONMENT environment"
else
    print_error "Terraform initialization failed"
    exit 1
fi

# Validate Terraform configuration
print_info "Validating Terraform configuration..."
terraform validate

if [ $? -eq 0 ]; then
    print_info "Terraform configuration is valid"
else
    print_error "Terraform configuration is invalid"
    exit 1
fi

print_info "Initialization complete!"
echo ""
echo "Next steps:"
echo "  1. Review the configuration in environments/$ENVIRONMENT/terraform.tfvars"
echo "  2. Run: ./scripts/plan.sh $ENVIRONMENT"
echo "  3. Run: ./scripts/apply.sh $ENVIRONMENT"
