# Core Variables
variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "multiagent-ai"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Multi-Agent AI System"
    Terraform   = "true"
  }
}

# Networking Variables
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_config" {
  description = "Subnet configuration"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = list(string)
    delegation = object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })
  }))
  default = {
    gateway = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = []
      delegation        = null
    }
    agents = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault"]
      delegation = {
        name = "aci-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
    private_endpoints = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.Storage", "Microsoft.KeyVault"]
      delegation        = null
    }
  }
}

# Container Registry Variables
variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_geo_replication_locations" {
  description = "Locations for ACR geo-replication (requires Premium SKU)"
  type        = list(string)
  default     = []
}

# Cosmos DB Variables
variable "cosmos_db_consistency_level" {
  description = "Consistency level for Cosmos DB"
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.cosmos_db_consistency_level)
    error_message = "Invalid Cosmos DB consistency level."
  }
}

variable "cosmos_db_max_interval_in_seconds" {
  description = "Max staleness interval in seconds (BoundedStaleness only)"
  type        = number
  default     = 10
}

variable "cosmos_db_max_staleness_prefix" {
  description = "Max staleness prefix (BoundedStaleness only)"
  type        = number
  default     = 200
}

variable "cosmos_db_autoscale_max_throughput" {
  description = "Maximum RU/s for Cosmos DB autoscale"
  type        = number
  default     = 4000

  validation {
    condition     = var.cosmos_db_autoscale_max_throughput >= 400 && var.cosmos_db_autoscale_max_throughput <= 1000000
    error_message = "Cosmos DB autoscale max throughput must be between 400 and 1,000,000 RU/s."
  }
}

variable "cosmos_db_databases" {
  description = "Cosmos DB databases and containers configuration"
  type = map(object({
    containers = map(object({
      partition_key_path = string
      autoscale_settings = object({
        max_throughput = number
      })
    }))
  }))
  default = {
    conversations = {
      containers = {
        sessions = {
          partition_key_path = "/sessionId"
          autoscale_settings = {
            max_throughput = 4000
          }
        }
        messages = {
          partition_key_path = "/conversationId"
          autoscale_settings = {
            max_throughput = 4000
          }
        }
      }
    }
  }
}

# Redis Variables
variable "redis_capacity" {
  description = "Redis cache capacity (GB)"
  type        = number
  default     = 1

  validation {
    condition     = contains([0, 1, 2, 3, 4, 5, 6], var.redis_capacity)
    error_message = "Redis capacity must be 0, 1, 2, 3, 4, 5, or 6 GB."
  }
}

variable "redis_family" {
  description = "Redis cache family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"

  validation {
    condition     = contains(["C", "P"], var.redis_family)
    error_message = "Redis family must be C or P."
  }
}

variable "redis_sku_name" {
  description = "Redis cache SKU"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_sku_name)
    error_message = "Redis SKU must be Basic, Standard, or Premium."
  }
}

# Agent Variables
variable "agents" {
  description = "Configuration for AI agents"
  type = map(object({
    name        = string
    description = string
    port        = number
  }))
  default = {
    agent1 = {
      name        = "conversation-agent"
      description = "Handles conversational interactions"
      port        = 8080
    }
    agent2 = {
      name        = "analysis-agent"
      description = "Performs data analysis"
      port        = 8080
    }
    agent3 = {
      name        = "recommendation-agent"
      description = "Generates recommendations"
      port        = 8080
    }
    agent4 = {
      name        = "knowledge-agent"
      description = "Manages knowledge base"
      port        = 8080
    }
    agent5 = {
      name        = "orchestration-agent"
      description = "Orchestrates multi-agent workflows"
      port        = 8080
    }
  }
}

variable "agent_container_image" {
  description = "Base container image for agents"
  type        = string
  default     = "agent-base:latest"
}

variable "agent_cpu" {
  description = "CPU cores per agent container"
  type        = number
  default     = 1

  validation {
    condition     = var.agent_cpu >= 0.5 && var.agent_cpu <= 4
    error_message = "Agent CPU must be between 0.5 and 4 cores."
  }
}

variable "agent_memory" {
  description = "Memory (GB) per agent container"
  type        = number
  default     = 2

  validation {
    condition     = var.agent_memory >= 1 && var.agent_memory <= 16
    error_message = "Agent memory must be between 1 and 16 GB."
  }
}

# Autoscaling Variables
variable "enable_autoscaling" {
  description = "Enable autoscaling for agents"
  type        = bool
  default     = true
}

variable "min_instance_count" {
  description = "Minimum number of instances per agent"
  type        = number
  default     = 2

  validation {
    condition     = var.min_instance_count >= 1 && var.min_instance_count <= 100
    error_message = "Minimum instance count must be between 1 and 100."
  }
}

variable "max_instance_count" {
  description = "Maximum number of instances per agent"
  type        = number
  default     = 10

  validation {
    condition     = var.max_instance_count >= 1 && var.max_instance_count <= 100
    error_message = "Maximum instance count must be between 1 and 100."
  }
}

# Application Gateway Variables
variable "enable_waf" {
  description = "Enable Web Application Firewall on Application Gateway"
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "WAF mode (Detection or Prevention)"
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be Detection or Prevention."
  }
}

# Observability Variables
variable "alert_email_addresses" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 5000

  validation {
    condition     = var.monthly_budget_amount > 0
    error_message = "Monthly budget must be greater than 0."
  }
}

variable "budget_alert_thresholds" {
  description = "Budget alert thresholds (percentages)"
  type        = list(number)
  default     = [80, 95]

  validation {
    condition     = alltrue([for t in var.budget_alert_thresholds : t > 0 && t <= 100])
    error_message = "Budget thresholds must be between 0 and 100."
  }
}

variable "enable_custom_metrics" {
  description = "Enable custom metrics for agent performance"
  type        = bool
  default     = true
}
