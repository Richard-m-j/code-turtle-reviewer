# ---- Builder Stage ----
# Use the specified Python 3.11 slim-bookworm image.
FROM python:3.11-slim-bookworm as builder

# Set the working directory.
WORKDIR /app

# Copy and install Python dependencies.
COPY scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Final Stage ----
FROM python:3.11-slim-bookworm

# Set the working directory.
WORKDIR /app

# Install system dependencies, create a non-root user, and set permissions.
RUN apt-get update && \
    apt-get install -y git wget --no-install-recommends && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup --system app && adduser --system --ingroup app && \
    chown -R app:app /app

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