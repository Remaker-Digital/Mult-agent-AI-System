# syntax=docker/dockerfile:1

# Build arguments for flexibility
ARG PYTHON_VERSION=3.11
ARG APP_USER=appuser
ARG APP_UID=1000
ARG APP_PORT=8080

# Builder stage - install dependencies
FROM python:${PYTHON_VERSION}-slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Upgrade pip and install build tools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage - minimal final image
FROM python:${PYTHON_VERSION}-slim AS runtime

# Re-declare ARGs for runtime stage
ARG APP_USER
ARG APP_UID
ARG APP_PORT

# Add OCI-compliant metadata labels
LABEL org.opencontainers.image.title="Base AI Agent" \
      org.opencontainers.image.description="Base agent implementation with Flask and gunicorn" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="AI Agent Team" \
      org.opencontainers.image.vendor="AI Agent Platform" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="python:${PYTHON_VERSION}-slim"

# Install runtime dependencies (curl for healthcheck)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Create non-root user with specific UID for security
RUN useradd -m -l -u ${APP_UID} ${APP_USER} && \
    chown -R ${APP_USER}:${APP_USER} /app

# Copy application code with proper ownership
COPY --chown=${APP_USER}:${APP_USER} app.py .

# Switch to non-root user
USER ${APP_USER}

# Expose application port
EXPOSE ${APP_PORT}

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=${APP_PORT}

# Optimized health check using curl instead of python+requests
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

# Run application with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "4", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
