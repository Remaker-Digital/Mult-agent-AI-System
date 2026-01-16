# Local variables for standardized tagging and cost allocation

locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Environment       = var.environment
    Project           = var.project_name
    ManagedBy         = "Terraform"
    CreatedDate       = timestamp()
    TerraformWorkspace = terraform.workspace
  })

  # Cost allocation tags for chargeback reporting
  cost_allocation_tags = {
    CostCenter        = var.cost_center
    BusinessUnit      = var.business_unit
    Department        = var.department
    BillingContact    = var.billing_contact
    Environment       = var.environment
    Application       = "Multi-Agent-AI-Platform"
  }

  # Agent-specific tag templates (used by agent infrastructure module)
  agent_cost_tags = {
    for agent_key, agent in var.agents : agent_key => merge(
      local.common_tags,
      local.cost_allocation_tags,
      {
        Component     = "AI-Agent"
        AgentName     = agent.name
        AgentType     = agent.name
        Service       = "Container-Instance"
        Workload      = "AI-Processing"
      }
    )
  }

  # Data layer cost tags
  data_layer_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Data-Layer"
      Service   = "Storage-Database"
      Workload  = "Data-Persistence"
    }
  )

  # Networking cost tags
  networking_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Networking"
      Service   = "Network-Infrastructure"
      Workload  = "Connectivity"
    }
  )

  # Security cost tags
  security_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Security"
      Service   = "Security-Services"
      Workload  = "Security-Compliance"
    }
  )

  # Observability cost tags
  observability_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Observability"
      Service   = "Monitoring-Logging"
      Workload  = "Operations"
    }
  )

  # Gateway cost tags
  gateway_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Gateway"
      Service   = "Application-Gateway"
      Workload  = "Traffic-Management"
    }
  )

  # Front Door cost tags
  front_door_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Global-Load-Balancer"
      Service   = "Front-Door"
      Workload  = "Global-Distribution"
      Regions   = "APAC-EMEA-Americas"
    }
  )

  # Cognitive Search cost tags
  cognitive_search_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Cognitive-Search"
      Service   = "AI-Search"
      Workload  = "Knowledge-Retrieval"
      AgentName = "knowledge-agent"
    }
  )

  # Container Registry cost tags
  container_registry_tags = merge(
    local.common_tags,
    local.cost_allocation_tags,
    {
      Component = "Container-Registry"
      Service   = "ACR"
      Workload  = "Container-Storage"
    }
  )
}
