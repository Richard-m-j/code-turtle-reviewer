# ---- Builder Stage ----
# This stage installs Python dependencies to keep the final image lean.
FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

COPY scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ---- Final Stage ----
# This stage creates the lean, final image for the application.
FROM python:3.11-slim-bookworm

WORKDIR /app

# Install runtime system dependencies.
RUN apt-get update && \
    apt-get install -y git wget --no-install-recommends && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from the builder stage.
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Create a non-root user and its home directory.
RUN addgroup --system app && \
    adduser --system --ingroup app --home /home/app --shell /bin/sh app

# Set the HOME environment variable. This tells the huggingface library where to cache the model.
ENV HOME=/home/app

# Pre-download and cache the model. This will now be stored in /home/app/.cache
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

# Copy the application scripts.
COPY scripts/ /app/scripts/

# Change ownership of the app directory and the user's home directory to the app user.
RUN chown -R app:app /app /home/app

# Switch to the non-root user.
USER app

# Set the entrypoint for the container.
ENTRYPOINT ["python", "/app/scripts/orchestrator.py"]