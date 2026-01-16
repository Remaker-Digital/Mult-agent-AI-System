#!/bin/bash

# Terraform Apply Script
# This script applies Terraform changes for the specified environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if environment argument is provided
if [ -z "$1" ]; then
    print_error "Environment argument is required"
    echo "Usage: ./apply.sh <environment> [plan-file]"
    echo "Environments: dev, staging, production"
    exit 1
fi

ENVIRONMENT=$1
PLAN_FILE=$2

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Valid environments: dev, staging, production"
    exit 1
fi

# Production safety check
if [ "$ENVIRONMENT" == "production" ]; then
    print_warning "You are about to apply changes to PRODUCTION!"
    echo -n "Type 'production' to confirm: "
    read -r confirmation
    if [ "$confirmation" != "production" ]; then
        print_error "Production deployment cancelled"
        exit 1
    fi
fi

# Change to terraform directory
cd "$(dirname "$0")/.." || exit 1

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_warning "Terraform not initialized"
    print_info "Running initialization..."
    ./scripts/init.sh "$ENVIRONMENT"
fi

print_header "Applying Infrastructure Changes for $ENVIRONMENT"

# If plan file is provided, use it
if [ -n "$PLAN_FILE" ] && [ -f "$PLAN_FILE" ]; then
    print_info "Applying plan from: $PLAN_FILE"

    print_warning "About to apply the following plan:"
    terraform show "$PLAN_FILE"

    echo ""
    echo -n "Do you want to apply this plan? (yes/no): "
    read -r apply_confirmation

    if [ "$apply_confirmation" != "yes" ]; then
        print_error "Apply cancelled"
        exit 1
    fi

    terraform apply "$PLAN_FILE"
else
    # No plan file provided, apply with auto-approve prompt
    print_info "No plan file provided, generating and applying changes"

    TFVARS_FILE="environments/$ENVIRONMENT/terraform.tfvars"

    if [ ! -f "$TFVARS_FILE" ]; then
        print_error "Variables file not found: $TFVARS_FILE"
        exit 1
    fi

    print_info "Using variables from: $TFVARS_FILE"

    terraform apply -var-file="$TFVARS_FILE"
fi

if [ $? -eq 0 ]; then
    print_header "Deployment Successful!"

    # Show outputs
    print_info "Infrastructure Outputs:"
    terraform output

    # Save outputs to file
    OUTPUT_FILE="outputs/${ENVIRONMENT}-outputs-$(date +%Y%m%d-%H%M%S).json"
    mkdir -p outputs
    terraform output -json > "$OUTPUT_FILE"
    print_info "Outputs saved to: $OUTPUT_FILE"

    echo ""
    print_info "Deployment Summary:"
    echo "  Environment: $ENVIRONMENT"
    echo "  Timestamp: $(date)"
    echo "  Outputs file: $OUTPUT_FILE"

    # Show next steps
    echo ""
    print_header "Next Steps"
    echo "1. Verify resources in Azure Portal"
    echo "2. Push container images to ACR:"
    echo "   az acr login --name \$(terraform output -raw container_registry_name)"
    echo "   docker push \$(terraform output -raw container_registry_login_server)/agent-base:latest"
    echo "3. Monitor Application Insights:"
    echo "   https://portal.azure.com/#resource/\$(terraform output -raw app_insights_id)"
    echo "4. Access Application Gateway:"
    echo "   http://\$(terraform output -raw application_gateway_public_ip)"
else
    print_error "Deployment failed"
    exit 1
fi
