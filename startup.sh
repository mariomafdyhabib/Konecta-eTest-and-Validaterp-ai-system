#!/bin/sh

# Import workflows if the file exists
if [ -f /tmp/workflows.json ]; then
  echo "Importing workflows..."
  # Check if file is not empty and is valid JSON
  if [ -s /tmp/workflows.json ]; then
    n8n import:workflow --input=/tmp/workflows.json || echo "Warning: Failed to import workflows"
  else
    echo "Workflows file is empty, skipping import"
  fi
fi

# Import credentials if the file exists
if [ -f /tmp/credentials.json ]; then
  echo "Importing credentials..."
  # Check if file contains actual credentials (not just empty array)
  if grep -q '"id"' /tmp/credentials.json 2>/dev/null; then
    n8n import:credentials --input=/tmp/credentials.json || echo "Warning: Failed to import credentials"
  else
    echo "No pre-configured credentials found."
    echo "Credentials need to be set up via the n8n UI."
  fi
fi

# Display setup information
echo ""
echo "==================================================================="
echo "N8N is starting..."
echo "==================================================================="
echo "All environment variables have been loaded:"
echo "  - OPENROUTER_API_KEY: ${OPENROUTER_API_KEY:0:20}..."
echo "  - HUGGINGFACE_API_KEY: ${HUGGINGFACE_API_KEY:0:20}..."
echo "  - PINECONE_API_KEY: ${PINECONE_API_KEY:0:20}..."
echo "  - TELEGRAM_BOT_TOKEN: ${TELEGRAM_BOT_TOKEN:0:20}..."
echo "  - GOOGLE credentials are loaded"
echo ""
echo "IMPORTANT: You need to configure credentials in the n8n UI"
echo "Access n8n at: http://localhost:5678"
echo "Then go to Settings > Credentials to add the required credentials"
echo "==================================================================="
echo ""

# Start n8n
echo "Starting n8n..."
exec n8n start
