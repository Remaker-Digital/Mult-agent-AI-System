# Docker Desktop Setup Guide for Beginners

This guide will walk you through setting up Docker Desktop and using it to build and run your AI agents locally.

## What is Docker?

Docker allows you to package your applications into "containers" - isolated environments that include everything needed to run your code. Think of it like a lightweight virtual machine.

## Prerequisites

- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher) **OR** Windows 11
- At least 4GB RAM (8GB+ recommended)
- Virtualization enabled in BIOS (usually enabled by default)

## Step 1: Download Docker Desktop

1. Go to https://www.docker.com/products/docker-desktop
2. Click **Download for Windows**
3. The installer will download (about 500MB)

## Step 2: Install Docker Desktop

1. **Run the Installer**:
   - Double-click the downloaded `Docker Desktop Installer.exe`
   - If prompted by Windows, click **Yes** to allow

2. **Installation Options**:
   - ✅ **Use WSL 2 instead of Hyper-V** (RECOMMENDED)
   - ✅ **Add shortcut to desktop**
   - Click **OK**

3. **Wait for Installation**:
   - This takes 3-5 minutes
   - Don't close the installer

4. **Restart Computer**:
   - Click **Close and restart** when prompted
   - Your computer will restart to apply changes

## Step 3: Start Docker Desktop

1. After restart, Docker Desktop should start automatically
2. If not, search for "Docker Desktop" in the Start menu and open it
3. You'll see the Docker icon in your system tray (bottom-right corner)

### First Launch

1. **Accept Terms**: Read and accept the Docker Subscription Service Agreement
2. **Sign In** (Optional): You can skip this by clicking "Continue without signing in"
3. **Tutorial**: You can skip the tutorial for now

### Verify Docker is Running

Look for the Docker whale icon 🐳 in your system tray:
- **Green**: Docker is running ✅
- **Yellow/Orange**: Docker is starting ⏳
- **Red**: Docker has an error ❌

## Step 4: Verify Installation

Let's make sure Docker is working correctly.

1. **Open PowerShell or Command Prompt**:
   - Press `Win + X`
   - Click "Windows PowerShell" or "Terminal"

2. **Check Docker Version**:
   ```powershell
   docker --version
   ```
   You should see something like: `Docker version 24.0.6, build...`

3. **Run Test Container**:
   ```powershell
   docker run hello-world
   ```

   You should see:
   ```
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   ```

🎉 Docker is now installed and working!

## Step 5: Configure Docker Settings

Let's optimize Docker for your project.

1. **Open Docker Desktop Dashboard**:
   - Click the Docker whale icon in the system tray
   - Click **Dashboard**

2. **Go to Settings** (gear icon in top-right)

3. **Resources** → **Advanced**:
   - **CPUs**: 4 (or half of your total CPUs)
   - **Memory**: 6 GB (minimum 4 GB)
   - **Swap**: 1 GB
   - **Disk image size**: 60 GB (default is usually fine)
   - Click **Apply & Restart**

4. **General Settings**:
   - ✅ **Start Docker Desktop when you log in** (recommended)
   - ✅ **Use the WSL 2 based engine**
   - Click **Apply & Restart**

## Step 6: Build Your First Agent

Now let's build one of your AI agents!

1. **Open PowerShell or Terminal**

2. **Navigate to Your Project**:
   ```powershell
   cd "C:\Users\micha\OneDrive\Desktop\Multi-agent Service Platform\agents\base-agent"
   ```

3. **Build the Docker Image**:
   ```powershell
   docker build -t base-agent:latest .
   ```

   **What's happening?**
   - Docker reads the `Dockerfile`
   - Downloads Python base image
   - Installs dependencies from `requirements.txt`
   - Copies your code into the container
   - Creates an image named `base-agent:latest`

   **This takes 2-5 minutes the first time** (faster afterwards)

4. **Verify the Image Was Built**:
   ```powershell
   docker images
   ```

   You should see:
   ```
   REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
   base-agent    latest    abc123def456   2 minutes ago   200MB
   ```

## Step 7: Run Your Agent Locally

Now let's run the agent in a container.

1. **Run the Container**:
   ```powershell
   docker run -d -p 8080:8080 --name my-agent base-agent:latest
   ```

   **Breaking down this command**:
   - `docker run`: Run a container
   - `-d`: Run in background (detached)
   - `-p 8080:8080`: Map port 8080 (host) to 8080 (container)
   - `--name my-agent`: Give it a friendly name
   - `base-agent:latest`: Use the image we just built

2. **Verify Container is Running**:
   ```powershell
   docker ps
   ```

   You should see:
   ```
   CONTAINER ID   IMAGE               STATUS          PORTS                    NAMES
   abc123def456   base-agent:latest   Up 10 seconds   0.0.0.0:8080->8080/tcp   my-agent
   ```

3. **Test the Agent**:
   Open your browser and go to: http://localhost:8080

   You should see JSON output:
   ```json
   {
     "agent": "base-agent",
     "description": "Base AI Agent",
     "version": "1.0.0",
     ...
   }
   ```

4. **Test Health Endpoint**:
   Go to: http://localhost:8080/health

   You should see:
   ```json
   {
     "status": "healthy",
     "agent": "base-agent",
     "timestamp": "2025-01-15T..."
   }
   ```

🎊 **Your agent is running!**

## Step 8: View Logs

Want to see what's happening inside the container?

```powershell
docker logs my-agent
```

You'll see the Flask application logs, including startup messages and any requests.

**Follow logs in real-time**:
```powershell
docker logs -f my-agent
```
(Press `Ctrl+C` to stop following)

## Step 9: Stop and Remove Container

When you're done testing:

1. **Stop the Container**:
   ```powershell
   docker stop my-agent
   ```

2. **Remove the Container**:
   ```powershell
   docker rm my-agent
   ```

3. **Verify It's Gone**:
   ```powershell
   docker ps -a
   ```

## Step 10: Use Docker Compose (Run All Agents)

Docker Compose lets you run multiple containers at once. Your project includes a `docker-compose.yml` file that runs all 5 agents plus Redis!

1. **Navigate to Project Root**:
   ```powershell
   cd "C:\Users\micha\OneDrive\Desktop\Multi-agent Service Platform"
   ```

2. **Start All Services**:
   ```powershell
   docker-compose up -d
   ```

   **What's happening?**
   - Builds all agent images (if needed)
   - Starts Redis container
   - Starts all 5 agent containers
   - Starts Nginx reverse proxy
   - Sets up networking between containers

   **First run takes 5-10 minutes** (building all images)

3. **Check Status**:
   ```powershell
   docker-compose ps
   ```

   You should see all services running:
   ```
   NAME                   STATUS        PORTS
   conversation-agent     Up            0.0.0.0:8081->8080/tcp
   analysis-agent         Up            0.0.0.0:8082->8080/tcp
   recommendation-agent   Up            0.0.0.0:8083->8080/tcp
   knowledge-agent        Up            0.0.0.0:8084->8080/tcp
   orchestration-agent    Up            0.0.0.0:8085->8080/tcp
   redis-cache            Up            0.0.0.0:6379->6379/tcp
   nginx-gateway          Up            0.0.0.0:80->80/tcp
   ```

4. **Test the Agents**:
   - Conversation Agent: http://localhost:8081/health
   - Analysis Agent: http://localhost:8082/health
   - Recommendation Agent: http://localhost:8083/health
   - Knowledge Agent: http://localhost:8084/health
   - Orchestration Agent: http://localhost:8085/health
   - Gateway: http://localhost/health

5. **View Logs for All Services**:
   ```powershell
   docker-compose logs -f
   ```

6. **Stop All Services**:
   ```powershell
   docker-compose down
   ```

## Common Docker Commands

### Working with Images

```powershell
# List all images
docker images

# Remove an image
docker rmi base-agent:latest

# Remove all unused images
docker image prune -a
```

### Working with Containers

```powershell
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start a container
docker start my-agent

# Stop a container
docker stop my-agent

# Restart a container
docker restart my-agent

# Remove a container
docker rm my-agent

# Remove all stopped containers
docker container prune
```

### Debugging

```powershell
# View container logs
docker logs my-agent

# Follow logs (real-time)
docker logs -f my-agent

# Execute command inside container
docker exec -it my-agent /bin/bash

# Inspect container details
docker inspect my-agent

# View resource usage
docker stats
```

### Docker Compose Commands

```powershell
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild images
docker-compose build

# Restart a specific service
docker-compose restart conversation-agent

# Scale a service
docker-compose up -d --scale conversation-agent=3
```

## Using Docker Desktop Dashboard

The Docker Desktop Dashboard provides a GUI alternative to command-line operations.

1. **Open Dashboard**:
   - Click the Docker whale icon
   - Click **Dashboard**

2. **What You Can Do**:
   - **Containers**: View, start, stop, delete containers
   - **Images**: View, delete images
   - **Volumes**: Manage persistent data
   - **Logs**: View container logs
   - **CLI**: Quick access to terminal

3. **Inspecting Containers**:
   - Click on a container name
   - See live logs, stats, terminal access
   - View environment variables, port mappings

## Troubleshooting

### "Docker daemon is not running"

**Solution**:
1. Start Docker Desktop
2. Wait for the whale icon to turn green
3. Try your command again

### "Cannot connect to the Docker daemon"

**Solution**:
1. Restart Docker Desktop
2. If still not working, restart your computer
3. Check if Docker is set to start on login

### "Port is already allocated"

**Solution**:
1. Another service is using that port
2. Stop the other service, OR
3. Use a different port: `docker run -p 9090:8080 ...`

### "No space left on device"

**Solution**:
1. Clean up unused images: `docker image prune -a`
2. Clean up unused containers: `docker container prune`
3. Clean up unused volumes: `docker volume prune`
4. Increase disk image size in Docker Desktop settings

### Build Fails with "Network Error"

**Solution**:
1. Check your internet connection
2. Docker might be downloading images
3. Try again - it might be temporary

### Container Exits Immediately

**Solution**:
1. Check logs: `docker logs my-agent`
2. Look for error messages
3. Common issues:
   - Port already in use
   - Missing environment variables
   - Code errors in application

## Best Practices

### Image Building

- **Use specific tags** instead of `latest` for reproducibility
- **Minimize layers** by combining RUN commands
- **Use .dockerignore** to exclude unnecessary files
- **Multi-stage builds** reduce final image size

### Container Management

- **Name your containers** for easy reference
- **Use docker-compose** for multi-container apps
- **Remove stopped containers** regularly
- **Monitor resource usage** with `docker stats`

### Development Workflow

1. Make code changes in VS Code
2. Rebuild image: `docker build -t base-agent:latest .`
3. Stop old container: `docker stop my-agent`
4. Remove old container: `docker rm my-agent`
5. Run new container: `docker run -d -p 8080:8080 --name my-agent base-agent:latest`
6. Test changes: http://localhost:8080

**Or use Docker Compose**:
1. Make code changes
2. Run: `docker-compose up -d --build`

## Next Steps

Now that Docker is set up:

1. ✅ Build all your agent images
2. ✅ Test them locally with docker-compose
3. ✅ Customize the agents for your needs
4. ✅ Push images to Azure Container Registry (covered in main README)

## Additional Resources

- **Docker Documentation**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **Docker Best Practices**: https://docs.docker.com/develop/dev-best-practices/
- **Python Docker Guide**: https://docs.docker.com/language/python/

## Getting Help

If you encounter issues:

1. Check Docker Desktop logs (Settings → Troubleshooting)
2. Visit Docker Community Forums: https://forums.docker.com/
3. Check the Docker Desktop documentation
4. Open an issue in this repository

---

**You've successfully set up Docker Desktop! 🐳**
