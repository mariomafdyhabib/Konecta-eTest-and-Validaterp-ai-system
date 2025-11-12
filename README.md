# N8N CV Screening Workflow - Docker Setup

This Docker container runs n8n with the CV-Screening-bot workflow pre-installed.

## Quick Start

### 1. Build the Docker Image

```bash
cd /home/mario/Desktop/terra/docker-n8n
docker build -t n8n-custom .
```

### 2. Run the Container

```bash
docker run -d -p 5678:5678 --name n8n-test --env-file env n8n-custom
```

### 3. Access n8n UI

Open your browser and navigate to:
```
http://localhost:5678
```

## What's Included

- **Pre-installed Workflow**: CV-Screening-bot
- **Environment Variables**: All API keys and configuration loaded from `env` file
- **Auto-import**: Workflow is automatically imported on container start

## Environment Variables Loaded

The following environment variables are automatically loaded:

- `OPENROUTER_API_KEY` - For LLM chat models
- `HUGGINGFACE_API_KEY` - For embeddings
- `PINECONE_API_KEY` - For vector store
- `PINECONE_ENVIRONMENT` - Pinecone environment
- `PINECONE_INDEX_NAME` - Pinecone index name
- `TELEGRAM_BOT_TOKEN` - For Telegram bot integration
- `GOOGLE_DRIVE_CLIENT_ID` - Google Drive OAuth
- `GOOGLE_DRIVE_CLIENT_SECRET` - Google Drive OAuth
- `GOOGLE_SHEETS_CLIENT_ID` - Google Sheets OAuth
- `GOOGLE_SHEETS_CLIENT_SECRET` - Google Sheets OAuth
- `GMAIL_CLIENT_ID` - Gmail OAuth
- `GMAIL_CLIENT_SECRET` - Gmail OAuth
- `JOB_DESCRIPTIONS_SHEET_ID` - Job descriptions spreadsheet ID
- `APPLICATIONS_SHEET_ID` - Applications spreadsheet ID
- `HR_NOTIFICATION_EMAIL` - Email for HR notifications

## Required Credentials Setup

⚠️ **IMPORTANT**: After the container starts, you MUST configure the following credentials through the n8n UI:

### 1. OpenRouter API
- **Type**: OpenRouter API
- **Name**: OpenRouter account
- **API Key**: Use `$OPENROUTER_API_KEY` from env file

### 2. HuggingFace API
- **Type**: HuggingFace API
- **Name**: HuggingFaceApi account
- **API Key**: Use `$HUGGINGFACE_API_KEY` from env file

### 3. Pinecone API
- **Type**: Pinecone API
- **Name**: PineconeApi account
- **API Key**: Use `$PINECONE_API_KEY` from env file
- **Environment**: Use `$PINECONE_ENVIRONMENT` from env file

### 4. Telegram API
- **Type**: Telegram API
- **Name**: Telegram account
- **Access Token**: Use `$TELEGRAM_BOT_TOKEN` from env file

### 5. Google Drive OAuth2
- **Type**: Google Drive OAuth2 API
- **Name**: Google Drive account
- **Client ID**: Use `$GOOGLE_DRIVE_CLIENT_ID` from env file
- **Client Secret**: Use `$GOOGLE_DRIVE_CLIENT_SECRET` from env file
- **OAuth Flow**: Complete the OAuth authorization in browser

### 6. Google Sheets OAuth2
- **Type**: Google Sheets OAuth2 API
- **Name**: Google Sheets account
- **Client ID**: Use `$GOOGLE_SHEETS_CLIENT_ID` from env file
- **Client Secret**: Use `$GOOGLE_SHEETS_CLIENT_SECRET` from env file
- **OAuth Flow**: Complete the OAuth authorization in browser

### 7. Gmail OAuth2
- **Type**: Gmail OAuth2
- **Name**: Gmail account
- **Client ID**: Use `$GMAIL_CLIENT_ID` from env file
- **Client Secret**: Use `$GMAIL_CLIENT_SECRET` from env file
- **OAuth Flow**: Complete the OAuth authorization in browser

## How to Add Credentials in n8n UI

1. Access n8n at http://localhost:5678
2. Click on your user profile (bottom left)
3. Go to **Settings** → **Credentials**
4. Click **Add Credential** for each required credential type
5. Fill in the details from the env file
6. For OAuth credentials, complete the authorization flow

## Workflow Description

The **CV-Screening-bot** workflow:

1. **Triggers**:
   - Schedule trigger (every 3 minutes) to check for new applications
   - Telegram trigger for HR assistant chat

2. **CV Processing**:
   - Downloads CVs from Google Drive
   - Extracts text from PDF files
   - Stores CV content in Pinecone vector database
   - Compares CV to job descriptions using AI

3. **Evaluation**:
   - Uses OpenRouter LLM to analyze candidate fit
   - Generates match score (0-100)
   - Identifies strengths and weaknesses
   - Updates Google Sheets with results

4. **Notifications**:
   - Sends confirmation email to applicants
   - Alerts HR team for high-scoring candidates (score ≥ 85)

5. **HR Assistant**:
   - Telegram bot for HR queries
   - Can search CV database
   - Access application scores and job descriptions
   - Provides candidate insights

## Docker Commands

### View logs
```bash
docker logs n8n-test
```

### Stop container
```bash
docker stop n8n-test
```

### Start container
```bash
docker start n8n-test
```

### Remove container
```bash
docker rm n8n-test
```

### Rebuild image after changes
```bash
docker build -t n8n-custom .
docker stop n8n-test
docker rm n8n-test
docker run -d -p 5678:5678 --name n8n-test --env-file env n8n-custom
```

## Files Structure

```
docker-n8n/
├── Dockerfile              # Docker image configuration
├── startup.sh              # Container startup script
├── workflows.json          # CV-Screening-bot workflow
├── credentials.json        # Empty (credentials set via UI)
├── env                     # Environment variables
├── env.json               # Environment variables in JSON format
├── setup-credentials.sh   # Helper script showing credential info
└── README.md              # This file
```

## Troubleshooting

### Container exits immediately
Check logs: `docker logs n8n-test`

### Workflow shows errors
Make sure all credentials are configured in the n8n UI

### Can't access n8n UI
- Check container is running: `docker ps | grep n8n-test`
- Check port is not in use: `lsof -i :5678`
- Check health: `curl http://localhost:5678/healthz`

### Credentials not working
- Verify environment variables are loaded: `docker exec n8n-test env | grep API`
- Re-configure credentials through n8n UI
- For OAuth: Complete the authorization flow in browser

## Data Persistence

The container uses SQLite database stored in `/home/node/.n8n/database.sqlite` inside the container. To persist data across container restarts, consider using a Docker volume:

```bash
docker run -d -p 5678:5678 \
  --name n8n-test \
  --env-file env \
  -v n8n-data:/home/node/.n8n \
  n8n-custom
```

## Security Notes

- The `env` file contains sensitive API keys - keep it secure
- Never commit the `env` file to version control
- Basic auth is disabled for local testing - enable it for production
- For production use, consider using Docker secrets or environment variable injection

## Next Steps

1. ✅ Container is running
2. ✅ Workflow is imported
3. ✅ Environment variables are loaded
4. ⏳ Configure credentials in n8n UI (http://localhost:5678)
5. ⏳ Test the workflow by activating it
6. ⏳ Submit a test application to verify end-to-end flow


docker run -p 5678:5678 mariomafdy/n8n-lampada