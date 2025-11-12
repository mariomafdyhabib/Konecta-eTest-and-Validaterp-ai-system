FROM n8nio/n8n:latest

# Switch to root for safe copy
USER root

# Create directory if it doesn't exist
RUN mkdir -p /home/node/.n8n

# Copy workflows file to a temporary location
COPY workflows.json /tmp/workflows.json
# COPY Attrition.json /tmp/workflows.json
COPY credentials.json /tmp/credentials.json

# Fix ownership
RUN chown -R node:node /home/node/.n8n /tmp/workflows.json /tmp/credentials.json

# Copy startup script to the correct location
COPY --chown=node:node startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Copy environment file
COPY env /tmp/.env

# Switch back to node user
USER node

# Enforce safe config permissions (recommended)
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Set n8n configuration
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV N8N_SECURE_COOKIE=false

# Expose the default n8n port
EXPOSE 5678

# Override the entrypoint to use our startup script
ENTRYPOINT ["/usr/local/bin/startup.sh"]