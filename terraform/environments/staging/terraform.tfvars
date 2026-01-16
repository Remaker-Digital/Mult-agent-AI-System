# Staging Environment Configuration

# Core Configuration
project_name = "multiagent-ai"
environment  = "staging"
location     = "eastus"

tags = {
  Project     = "Multi-Agent AI System"
  Environment = "Staging"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  Owner       = "AI-Team"
}

# Networking Configuration
vnet_address_space = ["10.1.0.0/16"]

# Container Registry Configuration
acr_sku                       = "Standard"
acr_geo_replication_locations = []  # No replication for staging

# Cosmos DB Configuration
cosmos_db_consistency_level        = "Session"
cosmos_db_max_interval_in_seconds  = 10
cosmos_db_max_staleness_prefix     = 200
cosmos_db_autoscale_max_throughput = 2000

cosmos_db_databases = {
  conversations = {
    containers = {
      sessions = {
        partition_key_path = "/sessionId"
        autoscale_settings = {
          max_throughput = 2000
        }
      }
      messages = {
        partition_key_path = "/conversationId"
        autoscale_settings = {
          max_throughput = 2000
        }
      }
    }
  }
}

# Redis Configuration
redis_capacity = 1
redis_family   = "C"
redis_sku_name = "Standard"

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
agent_cpu             = 1
agent_memory          = 2

# Autoscaling Configuration
enable_autoscaling  = true
min_instance_count  = 1
max_instance_count  = 5

# Application Gateway Configuration
enable_waf = true
waf_mode   = "Detection"  # Detection mode for staging

# Observability Configuration
alert_email_addresses = ["staging-team@example.com", "devops@example.com"]
monthly_budget_amount = 2000
budget_alert_thresholds = [80, 95]
enable_custom_metrics = true
