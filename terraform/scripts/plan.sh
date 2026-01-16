#!/bin/bash

# Terraform Plan Script
# This script generates an execution plan for the specified environment

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
    echo "Usage: ./plan.sh <environment> [options]"
    echo "Environments: dev, staging, production"
    echo "Options:"
    echo "  -out=<file>    Save plan to file"
    echo "  -destroy       Create a destroy plan"
    exit 1
fi

ENVIRONMENT=$1
shift  # Remove environment from arguments

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Valid environments: dev, staging, production"
    exit 1
fi

# Change to terraform directory
cd "$(dirname "$0")/.." || exit 1

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_warning "Terraform not initialized"
    print_info "Running initialization..."
    ./scripts/init.sh "$ENVIRONMENT"
fi

print_header "Planning Infrastructure for $ENVIRONMENT"

# Set variables file
TFVARS_FILE="environments/$ENVIRONMENT/terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Variables file not found: $TFVARS_FILE"
    exit 1
fi

print_info "Using variables from: $TFVARS_FILE"

# Default plan output file
PLAN_FILE="plans/${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).tfplan"
mkdir -p plans

print_info "Plan will be saved to: $PLAN_FILE"

# Run terraform plan
print_info "Generating execution plan..."
terraform plan \
    -var-file="$TFVARS_FILE" \
    -out="$PLAN_FILE" \
    "$@"

if [ $? -eq 0 ]; then
    print_info "Plan generated successfully"
    echo ""
    print_header "Plan Summary"
    echo "Environment: $ENVIRONMENT"
    echo "Plan file: $PLAN_FILE"
    echo ""
    print_info "To apply this plan, run:"
    echo "  ./scripts/apply.sh $ENVIRONMENT $PLAN_FILE"
    echo ""
    print_warning "Review the plan carefully before applying!"
else
    print_error "Plan generation failed"
    exit 1
fi
