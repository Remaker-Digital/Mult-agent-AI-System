#!/bin/bash

# Terraform Destroy Script
# This script destroys all Terraform-managed infrastructure for the specified environment

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
    echo "Usage: ./destroy.sh <environment>"
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

# Production safety check
if [ "$ENVIRONMENT" == "production" ]; then
    print_error "CRITICAL: You are about to DESTROY the PRODUCTION environment!"
    print_warning "This action is IRREVERSIBLE and will delete all data!"
    echo ""
    echo "Type 'DELETE PRODUCTION' in ALL CAPS to confirm: "
    read -r confirmation
    if [ "$confirmation" != "DELETE PRODUCTION" ]; then
        print_info "Production destruction cancelled (wise choice!)"
        exit 1
    fi

    print_warning "Are you ABSOLUTELY SURE? Type the environment name again: "
    read -r second_confirmation
    if [ "$second_confirmation" != "production" ]; then
        print_info "Production destruction cancelled"
        exit 1
    fi
fi

# Additional confirmation for staging
if [ "$ENVIRONMENT" == "staging" ]; then
    print_warning "You are about to destroy the STAGING environment!"
    echo -n "Type 'staging' to confirm: "
    read -r confirmation
    if [ "$confirmation" != "staging" ]; then
        print_info "Staging destruction cancelled"
        exit 1
    fi
fi

# Change to terraform directory
cd "$(dirname "$0")/.." || exit 1

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_error "Terraform not initialized for $ENVIRONMENT"
    print_info "Please initialize first: ./scripts/init.sh $ENVIRONMENT"
    exit 1
fi

print_header "Destroying Infrastructure for $ENVIRONMENT"

TFVARS_FILE="environments/$ENVIRONMENT/terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Variables file not found: $TFVARS_FILE"
    exit 1
fi

print_info "Using variables from: $TFVARS_FILE"

# Show what will be destroyed
print_info "Generating destroy plan..."
terraform plan -destroy -var-file="$TFVARS_FILE"

echo ""
print_warning "The above resources will be PERMANENTLY DELETED!"
echo -n "Type 'yes' to proceed with destruction: "
read -r final_confirmation

if [ "$final_confirmation" != "yes" ]; then
    print_info "Destruction cancelled"
    exit 0
fi

# Perform destruction
print_info "Destroying infrastructure..."
terraform destroy -var-file="$TFVARS_FILE" -auto-approve

if [ $? -eq 0 ]; then
    print_header "Infrastructure Destroyed"
    print_info "All resources for $ENVIRONMENT have been deleted"

    # Log destruction
    LOG_FILE="logs/destroy-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).log"
    mkdir -p logs
    echo "Environment: $ENVIRONMENT" > "$LOG_FILE"
    echo "Destroyed at: $(date)" >> "$LOG_FILE"
    echo "Destroyed by: $(whoami)" >> "$LOG_FILE"
    print_info "Destruction logged to: $LOG_FILE"

    echo ""
    print_warning "Remember to:"
    echo "1. Verify all resources are deleted in Azure Portal"
    echo "2. Check for any orphaned resources"
    echo "3. Review cost analysis to ensure no charges"
    echo "4. Clean up any local state files if needed"
else
    print_error "Destruction failed"
    print_warning "Some resources may still exist. Check Azure Portal!"
    exit 1
fi
