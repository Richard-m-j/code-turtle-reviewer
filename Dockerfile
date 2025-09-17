# ---- Builder Stage ----
# Use the specified Python 3.11 slim-bookworm image.
FROM python:3.11-slim-bookworm AS builder

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
# Updated and corrected sequence for installing GitHub CLI.
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git wget && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh --no-install-recommends && \
    apt-get clean && \
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