# ---- Builder Stage ----
# This stage installs Python dependencies.
FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

COPY scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ---- Final Stage ----
# This stage creates the lean, final image for the application.
FROM python:3.11-slim-bookworm

WORKDIR /app

# Install runtime system dependencies (git, gh) and create a non-root user.
RUN apt-get update && \
    apt-get install -y git wget --no-install-recommends && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup --system app && \
    adduser --system --ingroup app app

# Copy installed Python packages from the builder stage.
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Configure git's safe directory.
RUN git config --global --add safe.directory /github/workspace

# Copy the application scripts and set ownership.
COPY --chown=app:app scripts/ /app/scripts/

# Switch to the non-root user.
USER app

# Set the entrypoint for the container.
ENTRYPOINT ["python", "/app/scripts/orchestrator.py"]