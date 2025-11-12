# n8n Helm Chart

A Helm chart for deploying n8n workflow automation tool on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installation

### 1. Build and Push Your Docker Image

First, build your Docker image and push it to your container registry:

```bash
cd /home/mario/Desktop/terra/docker-n8n
docker build -t your-registry/n8n:latest .
docker push your-registry/n8n:latest
```

### 2. Update values.yaml

Edit `values.yaml` and update the image repository:

```yaml
image:
  repository: your-registry/n8n  # Update this
  tag: "latest"
```

### 3. Install the Chart

```bash
helm install n8n ./helm-chart/n8n
```

Or with custom values:

```bash
helm install n8n ./helm-chart/n8n -f custom-values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of n8n replicas | `1` |
| `image.repository` | Image repository | `your-registry/n8n` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `5678` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.hosts` | Ingress hosts | `[]` |
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.size` | PVC size | `5Gi` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |

## Examples

### Enable Ingress

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: n8n.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: n8n-tls
      hosts:
        - n8n.yourdomain.com
```

### Disable Persistence (for testing)

```yaml
persistence:
  enabled: false
```

### Add Environment Variables from Secrets

```yaml
envFrom:
  - secretRef:
      name: n8n-secrets
```

## Upgrading

```bash
helm upgrade n8n ./helm-chart/n8n
```

## Uninstalling

```bash
helm uninstall n8n
```

Note: This will not delete the PersistentVolumeClaim. Delete it manually if needed:

```bash
kubectl delete pvc n8n-n8n-data
```

## Support

For issues and questions, please refer to the n8n documentation at https://docs.n8n.io/
