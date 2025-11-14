# N8N CV Screening Workflow - Deployment Guide

This application runs n8n with the CV-Screening-bot workflow pre-installed. It provides AI-powered candidate evaluation, automated CV processing, and HR notifications.

## Deployment Options

Choose the deployment method that best fits your needs:

- **Docker Compose**: Best for local development and single-server deployments
- **Kubernetes/Helm**: Best for production, scalability, and high availability
- **Docker Run**: Simple single-container deployment

## Quick Start

### Pre-Deployment Validation

Before deploying, validate your setup:

```bash
./validate-deployment.sh
```

This script checks:
- ✅ Required tools (Docker, Helm, kubectl)
- ✅ Configuration files syntax
- ✅ Environment variables
- ✅ Kubernetes cluster connectivity

### Option 1: Using Docker Compose (Recommended for Local Development)

1. **Create your environment file**
   ```bash
   cp .env.example .env
   # Edit .env and add your API keys
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Access n8n UI**
   ```
   http://localhost:5678
   ```

4. **View logs**
   ```bash
   docker-compose logs -f
   ```

### Option 2: Using Docker Run

1. **Pull from Docker Hub**
   ```bash
   docker pull mariomafdy/n8n-lampada:latest
   ```

2. **Run the container**
   ```bash
   docker run -d -p 5678:5678 --name n8n-test --env-file .env mariomafdy/n8n-lampada
   ```

### Option 3: Using Kubernetes/Helm (Recommended for Production)

1. **Create Kubernetes secret**
   ```bash
   kubectl create secret generic n8n-secrets --from-env-file=.env
   ```

2. **Install with Helm**
   ```bash
   helm install n8n-cv-screening ./helm-chart/n8n
   ```

3. **Access n8n UI**
   ```bash
   kubectl port-forward svc/n8n-cv-screening 5678:5678
   ```
   Visit: http://localhost:5678

See the [Helm Quick Start Guide](helm-chart/HELM_QUICKSTART.md) for detailed instructions.

### Option 4: Build Locally

1. **Build the Docker Image**
   ```bash
   docker build -t n8n-custom .
   ```

2. **Run the Container**
   ```bash
   docker run -d -p 5678:5678 --name n8n-test --env-file .env n8n-custom
   ```

3. **Access n8n UI**
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

## Docker Compose Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f n8n
```

### Restart services
```bash
docker-compose restart
```

### Stop and remove volumes (WARNING: deletes all data)
```bash
docker-compose down -v
```

### Update to latest image
```bash
docker-compose pull
docker-compose up -d
```

## Docker Commands (without Compose)

### View logs
```bash
docker logs n8n-cv-screening
```

### Stop container
```bash
docker stop n8n-cv-screening
```

### Start container
```bash
docker start n8n-cv-screening
```

### Remove container
```bash
docker rm n8n-cv-screening
```

### Rebuild image after changes
```bash
docker build -t n8n-custom .
docker stop n8n-cv-screening
docker rm n8n-cv-screening
docker run -d -p 5678:5678 --name n8n-cv-screening --env-file .env n8n-custom
```

## Files Structure

```
konecta-cv-screening/
├── .github/
│   ├── workflows/
│   │   └── docker-build-push.yml  # CI/CD pipeline
│   └── DOCKER_CI_SETUP.md         # CI/CD documentation
├── Dockerfile                      # Docker image configuration
├── docker-compose.yml              # Docker Compose configuration
├── startup.sh                      # Container startup script
├── workflows.json                  # CV-Screening-bot workflow
├── credentials.json                # Empty (credentials set via UI)
├── .env.example                    # Environment variables template
├── .env                            # Your actual environment variables (not in git)
├── setup-credentials.sh            # Helper script showing credential info
├── .gitignore                      # Git ignore rules
└── README.md                       # This file
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

The container uses SQLite database stored in `/home/node/.n8n/database.sqlite` inside the container.

### Using Docker Compose (Automatic)
When using Docker Compose, data persistence is automatically configured through the `n8n-data` volume. Your workflows, credentials, and database are preserved across container restarts and updates.

### Using Docker Run (Manual)
To persist data when using `docker run`, mount a volume:

```bash
docker run -d -p 5678:5678 \
  --name n8n-cv-screening \
  --env-file .env \
  -v n8n-data:/home/node/.n8n \
  mariomafdy/n8n-lampada
```

### Backup Your Data
```bash
# Using Docker Compose
docker-compose exec n8n n8n export:workflow --all --output=/tmp/workflows-backup.json
docker cp n8n-cv-screening:/tmp/workflows-backup.json ./backup/

# Or backup the entire volume
docker run --rm -v n8n-data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n-backup.tar.gz /data
```

## Security Notes

- The `.env` file contains sensitive API keys - keep it secure
- Never commit the `.env` file to version control (it's in .gitignore)
- Use `.env.example` as a template for setting up your environment
- Basic auth is disabled for local testing - enable it for production
- For production use, consider using Docker secrets or environment variable injection
- The GitHub Actions pipeline automatically handles secrets during CI/CD

## CI/CD Pipeline

This project includes automated GitHub Actions workflow for building and deploying to Docker Hub.

### Features
- Automatic Docker image build on push to main/develop
- Comprehensive testing (health checks, startup validation)
- Security scanning with Trivy
- Multi-architecture builds (AMD64 + ARM64)
- Automatic tagging and versioning

### Setup
See [.github/DOCKER_CI_SETUP.md](.github/DOCKER_CI_SETUP.md) for detailed CI/CD setup instructions.

### Required GitHub Secrets
- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Your Docker Hub access token

## Next Steps

1. **Setup Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

2. **Start the Application**
   ```bash
   docker-compose up -d
   ```

3. **Configure Credentials**
   - Access n8n UI at http://localhost:5678
   - Add all required credentials (see "Required Credentials Setup" above)

4. **Test the Workflow**
   - Activate the CV-Screening-bot workflow
   - Submit a test application

5. **Setup CI/CD** (Optional)
   - Add GitHub secrets for Docker Hub
   - Push to main branch to trigger automatic builds

## Deployment Comparison

| Feature | Docker Compose | Kubernetes/Helm |
|---------|---------------|-----------------|
| **Best For** | Local dev, single server | Production, scalability |
| **Setup Complexity** | Low | Medium |
| **Scalability** | Manual | Automatic |
| **High Availability** | No | Yes |
| **Auto-restart** | Yes | Yes |
| **Load Balancing** | No | Yes |
| **Rolling Updates** | Manual | Automatic |
| **Secret Management** | .env file | Kubernetes Secrets |
| **Monitoring** | Manual | Integrated |
| **Backup** | Manual | Volume snapshots |

## Support & Documentation

### Docker Deployment
- **Docker Compose**: [docker-compose.yml](docker-compose.yml)
- **Environment Variables**: [.env.example](.env.example)
- **Docker Hub**: [mariomafdy/n8n-lampada](https://hub.docker.com/r/mariomafdy/n8n-lampada)

### Kubernetes Deployment
- **Helm Chart**: [helm-chart/n8n/](helm-chart/n8n/)
- **Helm Quick Start**: [helm-chart/HELM_QUICKSTART.md](helm-chart/HELM_QUICKSTART.md)
- **Helm Documentation**: [helm-chart/n8n/README.md](helm-chart/n8n/README.md)
- **Production Values**: [helm-chart/n8n/values-production.yaml](helm-chart/n8n/values-production.yaml)

### CI/CD & Automation
- **GitHub Actions Pipeline**: [.github/workflows/docker-build-push.yml](.github/workflows/docker-build-push.yml)
- **CI/CD Setup Guide**: [.github/DOCKER_CI_SETUP.md](.github/DOCKER_CI_SETUP.md)