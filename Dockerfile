# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Install git and gh CLI
RUN apt-get update && \
    apt-get install -y git wget --no-install-recommends && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Add the repository directory to git's safe.directory list
RUN git config --global --add safe.directory /github/workspace

# Copy and install Python dependencies
COPY scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application scripts to an absolute path
COPY scripts/ /app/scripts/

# Set the entrypoint to run the orchestrator using an absolute path
ENTRYPOINT ["python", "/app/scripts/orchestrator.py"]