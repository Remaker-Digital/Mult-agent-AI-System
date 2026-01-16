# Development Environment Configuration

# Core Configuration
project_name = "multiagent-ai"
environment  = "dev"
location     = "eastus"

tags = {
  Project     = "Multi-Agent AI System"
  Environment = "Development"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  Owner       = "AI-Team"
}

# Networking Configuration
vnet_address_space = ["10.0.0.0/16"]

# Container Registry Configuration
acr_sku                       = "Basic"  # Reduced for dev
acr_geo_replication_locations = []       # No replication for dev

# Cosmos DB Configuration
cosmos_db_consistency_level        = "Session"
cosmos_db_max_interval_in_seconds  = 10
cosmos_db_max_staleness_prefix     = 200
cosmos_db_autoscale_max_throughput = 1000  # Reduced for dev

cosmos_db_databases = {
  conversations = {
    containers = {
      sessions = {
        partition_key_path = "/sessionId"
        autoscale_settings = {
          max_throughput = 1000
        }
      }
      messages = {
        partition_key_path = "/conversationId"
        autoscale_settings = {
          max_throughput = 1000
        }
      }
    }
  }
}

# Redis Configuration
redis_capacity = 0           # 250MB for dev
redis_family   = "C"
redis_sku_name = "Basic"     # Basic tier for dev

# Agent Configuration
agents = {
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

agent_container_image = "agent-base:latest"
agent_cpu             = 0.5  # Reduced for dev
agent_memory          = 1.5  # Reduced for dev

# Autoscaling Configuration
enable_autoscaling  = false  # Disabled for dev
min_instance_count  = 1
max_instance_count  = 3

# Application Gateway Configuration
enable_waf = false  # Disabled for dev to save costs
waf_mode   = "Detection"

# Observability Configuration
alert_email_addresses = ["dev-team@example.com"]
monthly_budget_amount = 500  # Reduced budget for dev
budget_alert_thresholds = [80, 95]
enable_custom_metrics = false  # Disabled for dev
