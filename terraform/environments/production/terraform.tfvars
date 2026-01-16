# Production Environment Configuration

# Core Configuration
project_name = "multiagent-ai"
environment  = "production"
location     = "eastus"

tags = {
  Project     = "Multi-Agent AI System"
  Environment = "Production"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  Owner       = "AI-Team"
  Compliance  = "SOC2"
}

# Networking Configuration
vnet_address_space = ["10.2.0.0/16"]

# Container Registry Configuration
acr_sku                       = "Premium"
acr_geo_replication_locations = ["westus2", "westeurope"]  # Geo-replication for production

# Cosmos DB Configuration
cosmos_db_consistency_level        = "Session"
cosmos_db_max_interval_in_seconds  = 10
cosmos_db_max_staleness_prefix     = 200
cosmos_db_autoscale_max_throughput = 4000

cosmos_db_databases = {
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

# Redis Configuration
redis_capacity = 4           # 4GB for production (requires Premium SKU)
redis_family   = "P"         # Premium family
redis_sku_name = "Premium"   # Premium tier with persistence

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
agent_cpu             = 2    # Increased for production
agent_memory          = 4    # Increased for production

# Autoscaling Configuration
enable_autoscaling  = true
min_instance_count  = 2
max_instance_count  = 10

# Application Gateway Configuration
enable_waf = true
waf_mode   = "Prevention"  # Prevention mode for production

# Observability Configuration
alert_email_addresses = ["sre@example.com", "devops@example.com", "oncall@example.com"]
monthly_budget_amount = 5000
budget_alert_thresholds = [80, 95]
enable_custom_metrics = true
