# Contributing to Multi-Agent AI Service Platform

First off, thank you for considering contributing to the Multi-Agent AI Service Platform! It's people like you that make this project such a great tool for the community.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Pledge

We are committed to making participation in this project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Bug Report Template:**

```markdown
**Description**
A clear and concise description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Run command '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: [e.g., Windows 11, Ubuntu 22.04]
- Terraform Version: [e.g., 1.5.0]
- Azure CLI Version: [e.g., 2.50.0]
- Environment: [dev/staging/production]

**Logs**
```
Paste relevant logs here
```

**Screenshots**
If applicable, add screenshots.

**Additional Context**
Any other context about the problem.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Clear title and description**
- **Rationale** - Why is this enhancement needed?
- **Use cases** - How would this be used?
- **Alternatives considered** - What other approaches did you consider?
- **Implementation ideas** - Optional: How might this be implemented?

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** as needed
5. **Commit your changes** with clear messages
6. **Push to your fork** and submit a pull request

**Pull Request Template:**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Tested in dev environment
- [ ] Tested in staging environment
- [ ] Added unit tests
- [ ] All existing tests pass

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass locally with my changes
```

## Development Setup

### Prerequisites

1. **Install Required Tools:**
   - Terraform 1.5.0+
   - Azure CLI 2.40+
   - Docker Desktop
   - Git
   - VS Code (recommended)

2. **Clone the Repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/multi-agent-service-platform.git
   cd multi-agent-service-platform
   ```

3. **Set Up Development Environment:**
   ```bash
   # Authenticate with Azure
   az login
   az account set --subscription "YOUR_DEV_SUBSCRIPTION"

   # Initialize Terraform
   cd terraform
   ./scripts/init.sh dev
   ```

### Development Workflow

1. **Create a Feature Branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes:**
   - Edit Terraform files
   - Update documentation
   - Add tests if applicable

3. **Test Your Changes:**
   ```bash
   # Format code
   terraform fmt -recursive

   # Validate configuration
   terraform validate

   # Generate plan
   ./scripts/plan.sh dev
   ```

4. **Commit Your Changes:**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

5. **Push and Create PR:**
   ```bash
   git push origin feature/your-feature-name
   # Then create a pull request on GitHub
   ```

## Coding Standards

### Terraform

1. **Formatting:**
   - Use `terraform fmt` to format all `.tf` files
   - 2 spaces for indentation
   - No trailing whitespace

2. **Naming Conventions:**
   - Use lowercase with hyphens for resource names: `azurerm_resource_group.main`
   - Use descriptive variable names: `cosmos_db_autoscale_max_throughput`
   - Prefix resources with type: `rg-`, `vnet-`, `aci-`, etc.

3. **Documentation:**
   - Add descriptions to all variables
   - Document complex logic with inline comments
   - Update module README files

4. **Variables:**
   ```hcl
   variable "example_variable" {
     description = "Clear description of what this variable does"
     type        = string
     default     = "default-value"

     validation {
       condition     = can(regex("^[a-z0-9-]+$", var.example_variable))
       error_message = "Must contain only lowercase letters, numbers, and hyphens."
     }
   }
   ```

5. **Resources:**
   ```hcl
   resource "azurerm_resource_group" "main" {
     name     = "rg-${var.project_name}-${var.environment}"
     location = var.location

     tags = merge(var.tags, {
       Environment = var.environment
       ManagedBy   = "Terraform"
     })
   }
   ```

### Docker

1. **Dockerfile Best Practices:**
   - Use specific base image tags (not `latest`)
   - Minimize layers
   - Use multi-stage builds
   - Run as non-root user
   - Use `.dockerignore`

2. **Example Dockerfile:**
   ```dockerfile
   FROM python:3.11-slim AS base
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt

   FROM base AS runtime
   COPY . .
   RUN useradd -m appuser && chown -R appuser:appuser /app
   USER appuser
   EXPOSE 8080
   CMD ["python", "app.py"]
   ```

### Documentation

1. **Markdown Files:**
   - Use clear headings (H1 for title, H2 for sections)
   - Include code examples with syntax highlighting
   - Add links to related documentation
   - Keep line length under 120 characters

2. **Code Comments:**
   - Explain "why" not "what"
   - Keep comments up-to-date
   - Use inline comments sparingly

## Testing

### Infrastructure Testing

1. **Local Validation:**
   ```bash
   terraform fmt -check
   terraform validate
   terraform plan
   ```

2. **Dev Environment:**
   - Always test in dev environment first
   - Verify resources are created correctly
   - Check monitoring and alerts

3. **Integration Testing:**
   - Deploy to staging environment
   - Run end-to-end tests
   - Verify autoscaling behavior
   - Test failover scenarios

### Checklist Before PR

- [ ] Code formatted with `terraform fmt`
- [ ] Configuration validated with `terraform validate`
- [ ] Successfully deployed to dev environment
- [ ] Documentation updated
- [ ] No sensitive data in commits
- [ ] All tests pass
- [ ] CHANGELOG updated (for significant changes)

## Git Commit Messages

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(networking): add support for IPv6

- Added IPv6 address space configuration
- Updated NSG rules to support IPv6
- Updated documentation

Closes #123
```

```
fix(agents): resolve container startup issue

Fixed environment variable injection that was causing
agents to fail health checks.

Fixes #456
```

## Project Structure

### Adding New Modules

1. Create module directory: `terraform/modules/new-module/`
2. Include: `main.tf`, `variables.tf`, `outputs.tf`
3. Add README.md with usage examples
4. Update root `main.tf` to reference module
5. Update documentation

### Adding New Agents

1. Create agent directory: `agents/new-agent/`
2. Include Dockerfile, source code, requirements
3. Add health check endpoints (`/health`, `/ready`)
4. Update `terraform/variables.tf` to include new agent
5. Document agent purpose and API

## Documentation

### Required Documentation Updates

When making changes, update:

- [ ] Module README (if module changed)
- [ ] Main README.md (if major feature)
- [ ] DEPLOYMENT_GUIDE.md (if deployment process changed)
- [ ] QUICK_REFERENCE.md (if new commands added)
- [ ] claude.md (project context)

### Documentation Style

- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Keep it up-to-date

## Review Process

### What Reviewers Look For

1. **Code Quality:**
   - Follows coding standards
   - Well-documented
   - No unnecessary complexity

2. **Functionality:**
   - Works as intended
   - Handles edge cases
   - No breaking changes (or clearly documented)

3. **Testing:**
   - Adequate test coverage
   - Tests pass

4. **Documentation:**
   - Clear and complete
   - Examples provided
   - Updated for changes

### Response Time

- We aim to review PRs within 3-5 business days
- Complex PRs may take longer
- Feel free to ping reviewers after 5 days

## Community

### Getting Help

- **GitHub Discussions:** Ask questions and share ideas
- **GitHub Issues:** Report bugs and request features
- **Documentation:** Check existing docs first

### Stay Updated

- Watch the repository for updates
- Join discussions
- Follow the roadmap

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes (for significant contributions)
- Project documentation (where relevant)

## Questions?

Don't hesitate to ask! We're here to help:
- Open an issue with the `question` label
- Start a discussion on GitHub Discussions
- Contact maintainers directly

---

Thank you for contributing to the Multi-Agent AI Service Platform! 🎉
