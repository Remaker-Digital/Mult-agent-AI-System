# Dockerfile Optimizations

## Summary
The Dockerfile for the base-agent has been optimized following Docker best practices with a focus on build speed, security, maintainability, and proper structure.

## Key Optimizations Made

### 1. **Build Speed & Caching**
- ✅ Added `# syntax=docker/dockerfile:1` directive for BuildKit features
- ✅ Kept multi-stage build (builder + runtime) for optimal layer caching
- ✅ Separated dependency installation from application code copying
- ✅ Added explicit pip upgrade with `--no-cache-dir` flag
- ✅ Used python:3.11-slim (kept instead of alpine for faster builds with many compiled dependencies)

### 2. **Build Arguments (ARG) for Flexibility**
- ✅ Added `ARG PYTHON_VERSION=3.11` for easy version management
- ✅ Added `ARG APP_USER=appuser` for customizable username
- ✅ Added `ARG APP_UID=1000` for customizable user ID
- ✅ Added `ARG APP_PORT=8080` for flexible port configuration
- ✅ Re-declared ARGs in runtime stage for proper scoping

### 3. **Security Hardening**
- ✅ Maintained non-root user execution
- ✅ Used `useradd` with specific UID for better security control
- ✅ Applied proper file ownership using `--chown` flag in COPY
- ✅ Added `PYTHONDONTWRITEBYTECODE=1` to prevent .pyc file generation
- ✅ Minimized attack surface by separating build and runtime dependencies
- ✅ Removed unnecessary build tools from final image

### 4. **OCI-Compliant Metadata Labels**
Added comprehensive labels following OCI image specification:
- `org.opencontainers.image.title`
- `org.opencontainers.image.description`
- `org.opencontainers.image.version`
- `org.opencontainers.image.authors`
- `org.opencontainers.image.vendor`
- `org.opencontainers.image.licenses`
- `org.opencontainers.image.base.name`

### 5. **Health Check Optimization**
- ✅ Changed from Python + requests library to lightweight `curl`
- ✅ Uses ARG variable for port flexibility
- ✅ Increased start period from 5s to 10s for better reliability
- ✅ Proper intervals: 30s interval, 5s timeout, 3 retries

**Before:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8080/health')" || exit 1
```

**After:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1
```

### 6. **Environment Variables**
- ✅ Combined ENV declarations for better readability
- ✅ Added `PYTHONDONTWRITEBYTECODE=1` to prevent bytecode generation
- ✅ Maintained `PYTHONUNBUFFERED=1` for proper logging
- ✅ Used ARG-based PORT configuration

### 7. **Dockerfile Best Practices**
- ✅ Used uppercase for all Dockerfile commands (RUN, FROM, COPY, etc.)
- ✅ Sorted package installations alphabetically (gcc, not applicable here as single package)
- ✅ Combined RUN commands to reduce layers
- ✅ Proper use of `--no-install-recommends` for apt-get
- ✅ Cleaned up apt cache with `rm -rf /var/lib/apt/lists/*`
- ✅ Used `--no-cache-dir` for pip installations

### 8. **Layer Optimization**
The optimized structure:
1. **Builder Stage**: Install build dependencies + Python packages
2. **Runtime Stage**: Copy only necessary files, add runtime dependencies (curl)
3. **Result**: Smaller final image with better caching

## Image Size & Performance

### Original Dockerfile
- Used python:3.11-slim base
- Did not use ARG variables
- Health check used Python + requests (heavier)
- Missing OCI labels

### Optimized Dockerfile  
- Uses python:3.11-slim base with BuildKit syntax
- Parameterized with ARG variables
- Health check uses curl (lighter, faster)
- Full OCI-compliant labels
- Better layer caching strategy

## Build Instructions

### Standard Build
```bash
docker build -t base-agent:latest -f agents/base-agent/Dockerfile agents/base-agent/
```

### Custom Build with Arguments
```bash
docker build \
  --build-arg PYTHON_VERSION=3.11 \
  --build-arg APP_USER=myuser \
  --build-arg APP_UID=5000 \
  --build-arg APP_PORT=9000 \
  -t base-agent:custom \
  -f agents/base-agent/Dockerfile \
  agents/base-agent/
```

## Testing the Optimized Image

1. **Run the container:**
   ```bash
   docker run -d --name base-agent -p 8080:8080 base-agent:latest
   ```

2. **Check health:**
   ```bash
   curl http://localhost:8080/health
   ```

3. **View logs:**
   ```bash
   docker logs base-agent
   ```

4. **Inspect health status:**
   ```bash
   docker inspect base-agent --format='{{json .State.Health}}' | jq
   ```

## Security Considerations

1. **Non-root user**: Application runs as `appuser` (UID 1000 by default)
2. **Minimal base image**: Using slim variant reduces attack surface
3. **No build tools in runtime**: gcc and other build dependencies only in builder stage
4. **No bytecode files**: `PYTHONDONTWRITEBYTECODE=1` prevents .pyc files
5. **Explicit versions**: All package versions pinned in requirements.txt

## Compliance & Standards

- ✅ Follows Docker official best practices
- ✅ OCI (Open Container Initiative) compliant labels
- ✅ Proper multi-stage build pattern
- ✅ Security-first approach (non-root, minimal surface)
- ✅ Production-ready configuration

## Future Improvements (Optional)

1. **Consider distroless or alpine for even smaller images** (if dependencies allow)
2. **Add .dockerignore** to exclude unnecessary files
3. **Use specific digest for base image** for reproducible builds
4. **Add STOPSIGNAL** if application requires graceful shutdown
5. **Implement BuildKit cache mounts** for faster pip installs

## References

- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [OCI Image Spec](https://github.com/opencontainers/image-spec/blob/main/annotations.md)
- [Docker BuildKit](https://docs.docker.com/build/buildkit/)
- [Python Docker Best Practices](https://docs.docker.com/language/python/build-images/)
