# Helm Quick Start Guide - N8N CV Screening Bot

This guide will help you deploy the N8N CV Screening Bot to Kubernetes using Helm in just a few steps.

## Prerequisites

- Kubernetes cluster (minikube, kind, GKE, EKS, AKS, etc.)
- kubectl configured and working
- Helm 3.x installed

## Quick Deploy (5 Steps)

### Step 1: Create Kubernetes Secret

Create a file called `secrets.env` with your API keys (DO NOT COMMIT THIS FILE):

```bash
cat > secrets.env << 'EOF'
OPENROUTER_API_KEY=your_openrouter_key
HUGGINGFACE_API_KEY=your_huggingface_key
PINECONE_API_KEY=your_pinecone_key
PINECONE_ENVIRONMENT=your_pinecone_env
PINECONE_INDEX_NAME=your_index_name
TELEGRAM_BOT_TOKEN=your_telegram_token
GOOGLE_DRIVE_CLIENT_ID=your_gdrive_id
GOOGLE_DRIVE_CLIENT_SECRET=your_gdrive_secret
GOOGLE_SHEETS_CLIENT_ID=your_gsheets_id
GOOGLE_SHEETS_CLIENT_SECRET=your_gsheets_secret
GMAIL_CLIENT_ID=your_gmail_id
GMAIL_CLIENT_SECRET=your_gmail_secret
JOB_DESCRIPTIONS_SHEET_ID=your_job_sheet_id
APPLICATIONS_SHEET_ID=your_app_sheet_id
HR_NOTIFICATION_EMAIL=hr@example.com
EOF
```

Edit `secrets.env` and replace all placeholder values with your actual credentials.

### Step 2: Create the Secret in Kubernetes

```bash
kubectl create secret generic n8n-secrets --from-env-file=secrets.env
```

Verify the secret was created:

```bash
kubectl get secret n8n-secrets
```

### Step 3: Install the Helm Chart

```bash
helm install n8n-cv-screening ./helm-chart/n8n
```

Or install in a specific namespace:

```bash
helm install n8n-cv-screening ./helm-chart/n8n --namespace n8n --create-namespace
```

### Step 4: Wait for Pod to be Ready

```bash
kubectl get pods -w
```

Wait until you see:
```
NAME                                  READY   STATUS    RESTARTS   AGE
n8n-cv-screening-xxxxxxxxxx-xxxxx     1/1     Running   0          30s
```

Press `Ctrl+C` to stop watching.

### Step 5: Access n8n

Port forward to access locally:

```bash
kubectl port-forward svc/n8n-cv-screening 5678:5678
```

Open your browser and visit: **http://localhost:5678**

## Common Commands

### Check Status

```bash
# Check pods
kubectl get pods

# Check service
kubectl get svc

# Check persistent volume
kubectl get pvc
```

### View Logs

```bash
kubectl logs -f deployment/n8n-cv-screening
```

### Update Deployment

```bash
helm upgrade n8n-cv-screening ./helm-chart/n8n
```

### Uninstall

```bash
helm uninstall n8n-cv-screening
```

## Production Deployment

For production, use the production values file:

### Step 1: Edit Production Values

```bash
cp helm-chart/n8n/values-production.yaml my-values.yaml
```

Edit `my-values.yaml` and update:
- `ingress.hosts[0].host` - Your domain name
- `ingress.tls[0].hosts[0]` - Your domain name
- `env.TZ` - Your timezone
- Any resource limits based on your needs

### Step 2: Create Secret (same as above)

```bash
kubectl create secret generic n8n-secrets --from-env-file=secrets.env
```

### Step 3: Install with Production Values

```bash
helm install n8n-cv-screening ./helm-chart/n8n -f my-values.yaml
```

## Deployment Options Comparison

| Feature | Default | Production |
|---------|---------|------------|
| Replicas | 1 | 2 |
| Autoscaling | Disabled | Enabled (2-5) |
| Ingress | Disabled | Enabled with TLS |
| Storage | 5Gi | 20Gi |
| Resources | 500m CPU, 512Mi RAM | 1000m CPU, 1Gi RAM |
| Basic Auth | Disabled | Enabled |
| HTTPS | No | Yes |

## Troubleshooting

### Pod is CrashLooping

Check logs:
```bash
kubectl logs deployment/n8n-cv-screening
```

Common causes:
- Secret not created or has wrong name
- Insufficient resources
- Storage provisioning issues

### Can't Access via Port Forward

Check if pod is running:
```bash
kubectl get pods
```

Check if service exists:
```bash
kubectl get svc n8n-cv-screening
```

### Secret Not Loading

Verify secret exists:
```bash
kubectl get secret n8n-secrets -o yaml
```

Check if deployment references the correct secret:
```bash
kubectl describe deployment n8n-cv-screening | grep -A 5 "Environment Variables from"
```

### Storage Issues

Check PVC status:
```bash
kubectl get pvc
```

If pending, check storage class:
```bash
kubectl get storageclass
```

## Advanced Configurations

### Use External Database (PostgreSQL)

Add to values:
```yaml
env:
  DB_TYPE: "postgresdb"
  DB_POSTGRESDB_HOST: "postgres.example.com"
  DB_POSTGRESDB_PORT: "5432"
  DB_POSTGRESDB_DATABASE: "n8n"
  DB_POSTGRESDB_USER: "n8n"
  DB_POSTGRESDB_PASSWORD: "your_password"
```

### Enable Basic Authentication

Add to values:
```yaml
env:
  N8N_BASIC_AUTH_ACTIVE: "true"
  N8N_BASIC_AUTH_USER: "admin"
  N8N_BASIC_AUTH_PASSWORD: "secure_password"
```

### Custom Domain with Let's Encrypt

Ensure cert-manager is installed in your cluster, then:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: n8n-cv.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: n8n-cv-screening-tls
      hosts:
        - n8n-cv.yourdomain.com
```

## Clean Up

To completely remove the deployment including storage:

```bash
# Uninstall Helm release
helm uninstall n8n-cv-screening

# Delete PVC
kubectl delete pvc n8n-cv-screening-data

# Delete secret
kubectl delete secret n8n-secrets

# Delete secrets.env file
rm secrets.env
```

## Next Steps

1. **Configure Credentials**: Access n8n UI and add credentials for Google, Telegram, etc.
2. **Activate Workflow**: Enable the CV-Screening-bot workflow
3. **Test**: Submit a test application to verify the workflow
4. **Monitor**: Set up monitoring and alerting
5. **Backup**: Implement regular backup strategy

## Useful Links

- [Full Helm Documentation](./n8n/README.md)
- [Docker Compose Alternative](../docker-compose.yml)
- [CI/CD Pipeline Setup](../.github/DOCKER_CI_SETUP.md)
- [N8N Documentation](https://docs.n8n.io/)

## Security Reminder

- Never commit `secrets.env` to Git
- Use Kubernetes RBAC to limit access
- Enable TLS/HTTPS in production
- Regularly update the Docker image
- Monitor for security vulnerabilities
- Use strong passwords for basic auth
- Consider using a secrets manager (Vault, AWS Secrets Manager, etc.)
