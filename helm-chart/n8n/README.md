# N8N CV Screening Bot - Helm Chart

A comprehensive Helm chart for deploying the N8N CV Screening Bot on Kubernetes. This application automates recruitment workflows with AI-powered candidate evaluation, CV processing, and HR notifications.

## Features

- **Automated Deployment**: One-command deployment to Kubernetes
- **Persistent Storage**: Workflow and database persistence with PVCs
- **Secret Management**: Secure handling of API keys and credentials
- **High Availability**: Configurable replicas and autoscaling
- **Ingress Support**: Optional NGINX ingress with TLS
- **Health Checks**: Liveness and readiness probes
- **Resource Management**: CPU and memory limits/requests

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support (if persistence is enabled)
- kubectl configured to access your cluster

## Quick Start

### 1. Create Kubernetes Secrets

Before installing, create a secret with your API keys:

```bash
kubectl create secret generic n8n-secrets \
  --from-literal=OPENROUTER_API_KEY=your_openrouter_key \
  --from-literal=HUGGINGFACE_API_KEY=your_huggingface_key \
  --from-literal=PINECONE_API_KEY=your_pinecone_key \
  --from-literal=PINECONE_ENVIRONMENT=your_pinecone_env \
  --from-literal=PINECONE_INDEX_NAME=your_index_name \
  --from-literal=TELEGRAM_BOT_TOKEN=your_telegram_token \
  --from-literal=GOOGLE_DRIVE_CLIENT_ID=your_gdrive_id \
  --from-literal=GOOGLE_DRIVE_CLIENT_SECRET=your_gdrive_secret \
  --from-literal=GOOGLE_SHEETS_CLIENT_ID=your_gsheets_id \
  --from-literal=GOOGLE_SHEETS_CLIENT_SECRET=your_gsheets_secret \
  --from-literal=GMAIL_CLIENT_ID=your_gmail_id \
  --from-literal=GMAIL_CLIENT_SECRET=your_gmail_secret \
  --from-literal=JOB_DESCRIPTIONS_SHEET_ID=your_job_sheet_id \
  --from-literal=APPLICATIONS_SHEET_ID=your_app_sheet_id \
  --from-literal=HR_NOTIFICATION_EMAIL=hr@example.com
```

### 2. Install the Chart

```bash
helm install n8n-cv-screening ./helm-chart/n8n
```

Or with a specific namespace:

```bash
helm install n8n-cv-screening ./helm-chart/n8n --namespace n8n --create-namespace
```

### 3. Access n8n

If using the default ClusterIP service, port-forward to access locally:

```bash
kubectl port-forward svc/n8n-cv-screening 5678:5678
```

Then visit: http://localhost:5678

## Configuration

### Image Configuration

The chart uses the pre-built Docker image from Docker Hub by default:

```yaml
image:
  repository: mariomafdy/n8n-lampada
  pullPolicy: IfNotPresent
  tag: "latest"
```

### Service Configuration

Control how n8n is exposed:

```yaml
service:
  type: ClusterIP  # Options: ClusterIP, NodePort, LoadBalancer
  port: 5678
  targetPort: 5678
```

### Persistence

Data persistence is enabled by default:

```yaml
persistence:
  enabled: true
  storageClass: ""  # Use default storage class
  accessMode: ReadWriteOnce
  size: 5Gi
```

### Secrets Management

Configure API keys via Kubernetes secrets:

```yaml
secrets:
  enabled: true
  name: n8n-secrets
  create: false  # Set to true to create via Helm (not recommended for production)
```

### Resource Limits

Configure CPU and memory:

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

## Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of n8n replicas | `1` |
| `image.repository` | Docker image repository | `mariomafdy/n8n-lampada` |
| `image.tag` | Docker image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `5678` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.hosts[0].host` | Ingress hostname | `n8n-cv-screening.example.com` |
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.size` | PVC size | `5Gi` |
| `secrets.enabled` | Enable secret loading | `true` |
| `secrets.name` | Secret name | `n8n-secrets` |
| `secrets.create` | Create secret via Helm | `false` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |

## Advanced Usage Examples

### Enable Ingress with TLS

Create a values file `values-production.yaml`:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
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

Install with custom values:

```bash
helm install n8n-cv-screening ./helm-chart/n8n -f values-production.yaml
```

### Enable Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

### Use NodePort for Local Development

```yaml
service:
  type: NodePort
  port: 5678
```

### Disable Persistence (Testing Only)

```yaml
persistence:
  enabled: false
```

## Upgrading

Update the deployment:

```bash
helm upgrade n8n-cv-screening ./helm-chart/n8n
```

Update with new values:

```bash
helm upgrade n8n-cv-screening ./helm-chart/n8n -f values-production.yaml
```

## Rollback

Rollback to a previous release:

```bash
helm rollback n8n-cv-screening
```

## Uninstalling

Remove the deployment:

```bash
helm uninstall n8n-cv-screening
```

**Note**: This will not delete the PersistentVolumeClaim. Delete it manually if needed:

```bash
kubectl delete pvc n8n-cv-screening-data
```

## Monitoring and Troubleshooting

### View Logs

```bash
kubectl logs -f deployment/n8n-cv-screening
```

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/instance=n8n-cv-screening
```

### Describe Pod

```bash
kubectl describe pod -l app.kubernetes.io/instance=n8n-cv-screening
```

### Check Events

```bash
kubectl get events --sort-by='.lastTimestamp'
```

### Access Pod Shell

```bash
kubectl exec -it deployment/n8n-cv-screening -- /bin/sh
```

### Verify Secrets

```bash
kubectl get secret n8n-secrets -o yaml
```

## Security Best Practices

1. **Never commit secrets to Git**: Always use Kubernetes secrets or external secret managers
2. **Use RBAC**: Limit service account permissions
3. **Enable TLS**: Use cert-manager for automatic certificate management
4. **Network Policies**: Restrict pod-to-pod communication
5. **Resource Limits**: Always set CPU and memory limits
6. **Image Security**: Use specific image tags instead of `latest` in production
7. **Secret Management**: Consider using solutions like:
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager

## Production Checklist

- [ ] Secrets created and verified
- [ ] Persistent volume configured
- [ ] Resource limits set appropriately
- [ ] Ingress configured with TLS
- [ ] Monitoring and logging enabled
- [ ] Backup strategy in place
- [ ] High availability configured (replicas > 1)
- [ ] Autoscaling configured based on load
- [ ] Network policies defined
- [ ] RBAC roles configured

## Backup and Restore

### Backup Workflows

```bash
kubectl exec deployment/n8n-cv-screening -- n8n export:workflow --all --output=/tmp/workflows.json
kubectl cp n8n-cv-screening:/tmp/workflows.json ./workflows-backup.json
```

### Backup Persistent Volume

```bash
kubectl get pvc n8n-cv-screening-data -o yaml > pvc-backup.yaml
```

### Restore from Backup

1. Create a new deployment with the backed-up PVC
2. Import workflows through the n8n UI or CLI

## CI/CD Integration

This chart works seamlessly with the GitHub Actions pipeline. After the CI/CD pipeline builds and pushes the image to Docker Hub, deploy using:

```bash
# Pull latest image
helm upgrade n8n-cv-screening ./helm-chart/n8n --set image.tag=latest

# Or use a specific tag
helm upgrade n8n-cv-screening ./helm-chart/n8n --set image.tag=v1.0.0
```

## Support and Documentation

- **Project Repository**: https://github.com/mariomafdy/konecta-cv-screening
- **N8N Documentation**: https://docs.n8n.io/
- **Docker Hub**: https://hub.docker.com/r/mariomafdy/n8n-lampada
- **Issues**: https://github.com/mariomafdy/konecta-cv-screening/issues

## License

This Helm chart is provided as-is for the N8N CV Screening Bot application.
