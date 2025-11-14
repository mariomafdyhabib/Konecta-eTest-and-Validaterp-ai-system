# N8N CV Screening Bot - Complete Deployment Guide

This guide provides a comprehensive overview of all deployment options for the N8N CV Screening Bot.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Deployment Options](#deployment-options)
3. [Environment Setup](#environment-setup)
4. [Docker Compose Deployment](#docker-compose-deployment)
5. [Kubernetes/Helm Deployment](#kuberneteshelm-deployment)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Post-Deployment Configuration](#post-deployment-configuration)
8. [Troubleshooting](#troubleshooting)

## Quick Start

### 30-Second Docker Compose Deploy

```bash
# Clone and navigate to project
cd Konecta-eTest-and-Validaterp-ai-system

# Setup environment
cp .env.example .env
# Edit .env with your API keys

# Start
docker-compose up -d

# Access at http://localhost:5678
```

### 5-Minute Kubernetes Deploy

```bash
# Create secret
kubectl create secret generic n8n-secrets --from-env-file=.env

# Install
helm install n8n-cv-screening ./helm-chart/n8n

# Access
kubectl port-forward svc/n8n-cv-screening 5678:5678
```

## Deployment Options

### Comparison Matrix

| Criteria | Docker Compose | Kubernetes/Helm | Docker Run |
|----------|---------------|-----------------|------------|
| **Setup Time** | 5 minutes | 10 minutes | 2 minutes |
| **Best For** | Development, Testing | Production | Quick testing |
| **Scalability** | ❌ No | ✅ Yes | ❌ No |
| **High Availability** | ❌ No | ✅ Yes | ❌ No |
| **Auto-healing** | ⚠️ Limited | ✅ Yes | ❌ No |
| **Load Balancing** | ❌ No | ✅ Yes | ❌ No |
| **Storage** | Docker volumes | PersistentVolumes | Docker volumes |
| **Secrets** | .env file | K8s Secrets | .env file |
| **Monitoring** | Manual | Integrated | Manual |
| **Updates** | Manual | Rolling | Manual |
| **Cost** | Low | Medium-High | Low |

### When to Use What?

**Use Docker Compose if:**
- Local development or testing
- Single server deployment
- Small team or personal use
- Budget constraints
- Quick proof of concept

**Use Kubernetes/Helm if:**
- Production environment
- Need scalability (multiple replicas)
- High availability requirements
- Enterprise deployment
- CI/CD integration
- Multi-region deployment

**Use Docker Run if:**
- Quick testing
- Temporary deployment
- Minimal setup needed
- Learning/exploration

## Environment Setup

### Required API Keys and Credentials

Create a `.env` file with the following:

```bash
# AI Services
OPENROUTER_API_KEY=sk-or-v1-xxxxx          # Get from: https://openrouter.ai/keys
HUGGINGFACE_API_KEY=hf_xxxxx               # Get from: https://huggingface.co/settings/tokens

# Vector Database
PINECONE_API_KEY=xxxxx                     # Get from: https://app.pinecone.io/
PINECONE_ENVIRONMENT=us-east-1-aws         # Your Pinecone environment
PINECONE_INDEX_NAME=cv-screening           # Your Pinecone index name

# Communication
TELEGRAM_BOT_TOKEN=123456:ABC-DEF          # Get from: @BotFather on Telegram

# Google Services OAuth
GOOGLE_DRIVE_CLIENT_ID=xxxxx.apps.googleusercontent.com
GOOGLE_DRIVE_CLIENT_SECRET=xxxxx
GOOGLE_SHEETS_CLIENT_ID=xxxxx.apps.googleusercontent.com
GOOGLE_SHEETS_CLIENT_SECRET=xxxxx
GMAIL_CLIENT_ID=xxxxx.apps.googleusercontent.com
GMAIL_CLIENT_SECRET=xxxxx

# Application Configuration
JOB_DESCRIPTIONS_SHEET_ID=xxxxx            # Google Sheets ID for job descriptions
APPLICATIONS_SHEET_ID=xxxxx                # Google Sheets ID for applications
HR_NOTIFICATION_EMAIL=hr@example.com       # Email for notifications

# Optional
TZ=UTC                                     # Timezone (e.g., America/New_York)
```

### Getting API Keys

1. **OpenRouter**: https://openrouter.ai/keys
2. **HuggingFace**: https://huggingface.co/settings/tokens
3. **Pinecone**: https://app.pinecone.io/
4. **Telegram**: Message @BotFather on Telegram
5. **Google OAuth**: https://console.cloud.google.com/

## Docker Compose Deployment

### Prerequisites

- Docker 20.10+
- Docker Compose 1.29+

### Step-by-Step

1. **Clone Repository**
   ```bash
   git clone <your-repo-url>
   cd Konecta-eTest-and-Validaterp-ai-system
   ```

2. **Create Environment File**
   ```bash
   cp .env.example .env
   nano .env  # or use your preferred editor
   ```

3. **Start Services**
   ```bash
   docker-compose up -d
   ```

4. **Verify Deployment**
   ```bash
   docker-compose ps
   docker-compose logs -f n8n
   ```

5. **Access Application**
   Open browser: http://localhost:5678

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Update to latest image
docker-compose pull
docker-compose up -d

# Backup data
docker run --rm -v n8n-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/n8n-backup.tar.gz /data
```

## Kubernetes/Helm Deployment

### Prerequisites

- Kubernetes 1.19+
- Helm 3.2+
- kubectl configured

### Step-by-Step

1. **Create Kubernetes Secret**
   ```bash
   # From .env file
   kubectl create secret generic n8n-secrets --from-env-file=.env

   # Or manually
   kubectl create secret generic n8n-secrets \
     --from-literal=OPENROUTER_API_KEY=your_key \
     --from-literal=HUGGINGFACE_API_KEY=your_key \
     # ... add all other keys
   ```

2. **Install Helm Chart**

   **Development:**
   ```bash
   helm install n8n-cv-screening ./helm-chart/n8n
   ```

   **Production:**
   ```bash
   helm install n8n-cv-screening ./helm-chart/n8n \
     -f helm-chart/n8n/values-production.yaml
   ```

3. **Verify Deployment**
   ```bash
   kubectl get pods
   kubectl get svc
   kubectl logs -f deployment/n8n-cv-screening
   ```

4. **Access Application**

   **Port Forward (Development):**
   ```bash
   kubectl port-forward svc/n8n-cv-screening 5678:5678
   ```

   **Ingress (Production):**
   Setup ingress in values-production.yaml

### Helm Commands

```bash
# List releases
helm list

# Upgrade
helm upgrade n8n-cv-screening ./helm-chart/n8n

# Rollback
helm rollback n8n-cv-screening

# Uninstall
helm uninstall n8n-cv-screening

# Get values
helm get values n8n-cv-screening
```

### Production Configuration

Edit `values-production.yaml`:

```yaml
replicaCount: 2  # High availability

ingress:
  enabled: true
  hosts:
    - host: n8n-cv.yourdomain.com  # YOUR DOMAIN
  tls:
    - secretName: n8n-cv-screening-tls
      hosts:
        - n8n-cv.yourdomain.com  # YOUR DOMAIN

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5

persistence:
  size: 20Gi  # Increased storage
```

## CI/CD Pipeline

### GitHub Actions Setup

The project includes automated CI/CD for building and pushing to Docker Hub.

### Setup Steps

1. **Add GitHub Secrets**

   Go to: Repository → Settings → Secrets → Actions

   Add:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token

2. **Trigger Pipeline**
   ```bash
   git add .
   git commit -m "Deploy to production"
   git push origin main
   ```

3. **Monitor Build**
   Go to: Repository → Actions tab

### Pipeline Features

- ✅ Automated build on push to main/develop
- ✅ Multi-architecture support (AMD64 + ARM64)
- ✅ Automated testing (health checks)
- ✅ Security scanning (Trivy)
- ✅ Automatic tagging
- ✅ Push to Docker Hub

### Manual Deploy After CI/CD

```bash
# Pull latest image
docker-compose pull
docker-compose up -d

# Or for Kubernetes
helm upgrade n8n-cv-screening ./helm-chart/n8n \
  --set image.tag=latest
```

## Post-Deployment Configuration

### Initial Setup in n8n UI

1. **Access n8n**
   - Docker Compose: http://localhost:5678
   - Kubernetes: After port-forward to http://localhost:5678

2. **Configure Credentials**

   Navigate to: Settings → Credentials

   Add each credential:
   - OpenRouter API
   - HuggingFace API
   - Pinecone API
   - Telegram API
   - Google Drive OAuth2
   - Google Sheets OAuth2
   - Gmail OAuth2

3. **Verify Workflow**
   - The CV-Screening-bot workflow should be pre-loaded
   - Review workflow nodes
   - Test connections

4. **Activate Workflow**
   - Toggle the workflow to "Active"
   - Monitor for any errors

### Test Deployment

1. **Submit Test Application**
   - Create a test CV
   - Upload to Google Drive
   - Add entry to Applications spreadsheet

2. **Monitor Execution**
   - Check workflow executions in n8n
   - Verify Pinecone storage
   - Check email notifications

3. **Test Telegram Bot**
   - Message your bot on Telegram
   - Ask about candidates
   - Verify responses

## Troubleshooting

### Docker Compose Issues

**Container keeps restarting:**
```bash
# Check logs
docker-compose logs n8n

# Common issues:
# - Missing .env file
# - Invalid API keys
# - Port 5678 already in use
```

**Can't access UI:**
```bash
# Check if container is running
docker-compose ps

# Check port binding
netstat -an | grep 5678

# Try different port
# Edit docker-compose.yml: "8080:5678"
```

### Kubernetes Issues

**Pod stuck in Pending:**
```bash
kubectl describe pod <pod-name>

# Common issues:
# - No storage class available
# - Insufficient resources
# - Image pull issues
```

**Secret not loading:**
```bash
# Verify secret exists
kubectl get secret n8n-secrets

# Check secret content (base64 encoded)
kubectl get secret n8n-secrets -o yaml

# Restart deployment
kubectl rollout restart deployment/n8n-cv-screening
```

**Ingress not working:**
```bash
# Check ingress
kubectl get ingress

# Verify ingress controller
kubectl get pods -n ingress-nginx

# Check cert-manager (if using TLS)
kubectl get certificate
```

### Application Issues

**Workflow not executing:**
- Check credentials are configured
- Verify API keys are valid
- Check execution logs in n8n UI

**OAuth not working:**
- Ensure redirect URIs are configured in Google Console
- Check OAuth scopes
- Try re-authorizing

**Pinecone errors:**
- Verify index exists
- Check index dimensions match
- Ensure API key has correct permissions

## Monitoring and Maintenance

### Health Checks

**Docker Compose:**
```bash
curl http://localhost:5678/healthz
```

**Kubernetes:**
```bash
kubectl get pods  # Should show Running
kubectl exec deployment/n8n-cv-screening -- wget -q -O- http://localhost:5678/healthz
```

### Backup Strategy

**Docker Compose:**
```bash
# Backup volume
docker run --rm -v n8n-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz /data
```

**Kubernetes:**
```bash
# Export workflows
kubectl exec deployment/n8n-cv-screening -- \
  n8n export:workflow --all --output=/tmp/workflows.json

# Copy to local
kubectl cp n8n-cv-screening:/tmp/workflows.json ./workflows-backup.json

# Backup PVC (requires velero or similar)
```

### Updates

**Docker Compose:**
```bash
docker-compose pull
docker-compose up -d
```

**Kubernetes:**
```bash
helm upgrade n8n-cv-screening ./helm-chart/n8n
```

## Additional Resources

- **Helm Documentation**: [helm-chart/n8n/README.md](helm-chart/n8n/README.md)
- **Helm Quick Start**: [helm-chart/HELM_QUICKSTART.md](helm-chart/HELM_QUICKSTART.md)
- **CI/CD Setup**: [.github/DOCKER_CI_SETUP.md](.github/DOCKER_CI_SETUP.md)
- **Main README**: [README.md](README.md)
- **N8N Docs**: https://docs.n8n.io/

## Support

For issues and questions:
- GitHub Issues: https://github.com/mariomafdy/konecta-cv-screening/issues
- N8N Community: https://community.n8n.io/
