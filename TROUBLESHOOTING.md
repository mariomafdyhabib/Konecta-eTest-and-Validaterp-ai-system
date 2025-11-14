# Troubleshooting Guide - N8N CV Screening Bot

## Common Issues and Solutions

### 1. Pod in CreateContainerConfigError

**Symptoms:**
```bash
kubectl get pods
NAME                                READY   STATUS                       RESTARTS   AGE
n8n-cv-screening-74ff884f48-qqp5x   0/1     CreateContainerConfigError   0          7m42s
```

**Cause:** The Kubernetes secret `n8n-secrets` is missing or misconfigured.

**Solution:**

**Option 1: Use the helper script (Recommended)**
```bash
# Make sure you have .env file with your API keys
cp .env.example .env
# Edit .env and add your actual API keys

# Run the secret creator script
./create-k8s-secret.sh
```

**Option 2: Manual creation**
```bash
# Create secret from .env file
kubectl create secret generic n8n-secrets --from-env-file=.env

# Verify secret was created
kubectl get secret n8n-secrets

# Restart the deployment
kubectl rollout restart deployment/n8n-cv-screening
```

**Option 3: Manual creation without .env file**
```bash
kubectl create secret generic n8n-secrets \
  --from-literal=OPENROUTER_API_KEY=your_key \
  --from-literal=HUGGINGFACE_API_KEY=your_key \
  --from-literal=PINECONE_API_KEY=your_key \
  --from-literal=PINECONE_ENVIRONMENT=your_env \
  --from-literal=PINECONE_INDEX_NAME=your_index \
  --from-literal=TELEGRAM_BOT_TOKEN=your_token \
  --from-literal=GOOGLE_DRIVE_CLIENT_ID=your_id \
  --from-literal=GOOGLE_DRIVE_CLIENT_SECRET=your_secret \
  --from-literal=GOOGLE_SHEETS_CLIENT_ID=your_id \
  --from-literal=GOOGLE_SHEETS_CLIENT_SECRET=your_secret \
  --from-literal=GMAIL_CLIENT_ID=your_id \
  --from-literal=GMAIL_CLIENT_SECRET=your_secret \
  --from-literal=JOB_DESCRIPTIONS_SHEET_ID=your_sheet_id \
  --from-literal=APPLICATIONS_SHEET_ID=your_sheet_id \
  --from-literal=HR_NOTIFICATION_EMAIL=hr@example.com
```

**Verify and Restart:**
```bash
# Check pod status
kubectl get pods

# Watch pod come up
kubectl get pods -w

# If still failing, check logs
kubectl logs -f deployment/n8n-cv-screening
```

---

### 2. Pod in CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods
NAME                                READY   STATUS             RESTARTS   AGE
n8n-cv-screening-74ff884f48-qqp5x   0/1     CrashLoopBackOff   5          10m
```

**Diagnosis:**
```bash
# Check pod logs
kubectl logs n8n-cv-screening-74ff884f48-qqp5x

# Check previous container logs
kubectl logs n8n-cv-screening-74ff884f48-qqp5x --previous
```

**Common Causes:**

1. **Invalid API Keys**
   - Check your secret values
   ```bash
   kubectl get secret n8n-secrets -o yaml
   ```
   - Recreate secret with correct values

2. **Insufficient Resources**
   - Check pod events
   ```bash
   kubectl describe pod n8n-cv-screening-74ff884f48-qqp5x
   ```
   - Increase resources in values.yaml

3. **Storage Issues**
   - Check PVC status
   ```bash
   kubectl get pvc
   ```

---

### 3. Pod in Pending State

**Symptoms:**
```bash
kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
n8n-cv-screening-74ff884f48-qqp5x   0/1     Pending   0          5m
```

**Diagnosis:**
```bash
kubectl describe pod n8n-cv-screening-74ff884f48-qqp5x
```

**Common Causes:**

1. **PVC Not Bound**
   ```bash
   kubectl get pvc
   ```
   **Solution:** Check storage class availability
   ```bash
   kubectl get storageclass
   ```

2. **Insufficient Resources**
   - Node doesn't have enough CPU/memory
   ```bash
   kubectl describe node
   ```

3. **Image Pull Issues**
   - Check image pull errors in events
   ```bash
   kubectl describe pod <pod-name>
   ```

---

### 4. ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods
NAME                                READY   STATUS             RESTARTS   AGE
n8n-cv-screening-74ff884f48-qqp5x   0/1     ImagePullBackOff   0          2m
```

**Diagnosis:**
```bash
kubectl describe pod <pod-name> | grep -A 10 Events
```

**Common Causes:**

1. **Image doesn't exist**
   - Verify image exists on Docker Hub
   - Check image name and tag in values.yaml

2. **Rate limiting**
   - Docker Hub has rate limits
   - Wait a few minutes and try again
   - Or use authenticated pull

**Solution:**
```yaml
# In values.yaml, use authenticated pull
imagePullSecrets:
  - name: dockerhub-secret

# Create the secret
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=docker.io \
  --docker-username=your-username \
  --docker-password=your-password
```

---

### 5. Can't Access via Port Forward

**Symptoms:**
```bash
kubectl port-forward svc/n8n-cv-screening 5678:5678
# Hangs or shows error
```

**Solutions:**

1. **Check if service exists**
   ```bash
   kubectl get svc n8n-cv-screening
   ```

2. **Check if pod is running**
   ```bash
   kubectl get pods
   ```

3. **Try different port**
   ```bash
   kubectl port-forward svc/n8n-cv-screening 8080:5678
   # Access at http://localhost:8080
   ```

4. **Port forward to pod directly**
   ```bash
   kubectl port-forward pod/<pod-name> 5678:5678
   ```

---

### 6. Helm Install Fails

**Symptoms:**
```bash
helm install n8n-cv-screening ./helm-chart/n8n
Error: INSTALLATION FAILED: ...
```

**Diagnosis:**
```bash
# Dry run to see what would be created
helm install n8n-cv-screening ./helm-chart/n8n --dry-run --debug

# Check Helm chart validity
helm lint ./helm-chart/n8n
```

**Common Causes:**

1. **Values file syntax error**
   ```bash
   # Validate YAML
   python3 -c "import yaml; yaml.safe_load(open('./helm-chart/n8n/values.yaml'))"
   ```

2. **Release already exists**
   ```bash
   # List existing releases
   helm list

   # Uninstall existing
   helm uninstall n8n-cv-screening
   ```

3. **Namespace doesn't exist**
   ```bash
   # Create namespace
   kubectl create namespace n8n

   # Install in namespace
   helm install n8n-cv-screening ./helm-chart/n8n --namespace n8n
   ```

---

### 7. Secret Values Not Loading

**Symptoms:**
- Pod starts but environment variables are empty
- API calls fail with authentication errors

**Diagnosis:**
```bash
# Check if secret exists
kubectl get secret n8n-secrets

# View secret keys (values are base64 encoded)
kubectl get secret n8n-secrets -o yaml

# Decode a specific value
kubectl get secret n8n-secrets -o jsonpath='{.data.OPENROUTER_API_KEY}' | base64 -d
echo ""
```

**Solution:**
```bash
# Delete and recreate secret
kubectl delete secret n8n-secrets
./create-k8s-secret.sh

# Restart deployment
kubectl rollout restart deployment/n8n-cv-screening
```

---

### 8. Ingress Not Working

**Symptoms:**
- Can't access via domain name
- 404 errors

**Diagnosis:**
```bash
# Check ingress
kubectl get ingress

# Describe ingress
kubectl describe ingress n8n-cv-screening

# Check ingress controller
kubectl get pods -n ingress-nginx
```

**Solutions:**

1. **Ingress controller not installed**
   ```bash
   # For minikube
   minikube addons enable ingress

   # For production clusters
   # Install NGINX ingress controller
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
   ```

2. **DNS not configured**
   - Add entry to /etc/hosts for testing
   ```bash
   echo "127.0.0.1 n8n-cv.yourdomain.com" | sudo tee -a /etc/hosts
   ```

3. **TLS certificate issues**
   ```bash
   # Check cert-manager
   kubectl get certificate

   # Install cert-manager if needed
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
   ```

---

### 9. Docker Compose Issues

**Symptoms:**
```bash
docker-compose up -d
ERROR: ...
```

**Common Causes:**

1. **Port already in use**
   ```bash
   # Check what's using port 5678
   lsof -i :5678

   # Stop the conflicting service or use different port
   # Edit docker-compose.yml: "8080:5678"
   ```

2. **.env file missing**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

3. **Docker not running**
   ```bash
   # Start Docker
   sudo systemctl start docker

   # Check status
   docker ps
   ```

---

### 10. Application-Specific Issues

**n8n won't start:**
```bash
# Check logs
docker-compose logs -f n8n
# Or
kubectl logs -f deployment/n8n-cv-screening
```

**Workflows not loading:**
- Check if workflows.json is mounted correctly
- Verify startup.sh is executing

**API calls failing:**
- Verify API keys are correct
- Check if external services are accessible
- Test API keys manually

---

## Diagnostic Commands

### Quick Health Check
```bash
# Kubernetes
kubectl get pods
kubectl get svc
kubectl get pvc
kubectl logs -f deployment/n8n-cv-screening
kubectl describe pod <pod-name>

# Docker Compose
docker-compose ps
docker-compose logs -f
curl http://localhost:5678/healthz
```

### Complete Status Check
```bash
# Run validation script
./validate-deployment.sh

# Kubernetes detailed check
kubectl get all
kubectl get events --sort-by='.lastTimestamp'
kubectl get secret n8n-secrets
helm status n8n-cv-screening
```

---

## Getting Help

If you're still experiencing issues:

1. **Run diagnostics:**
   ```bash
   ./validate-deployment.sh > diagnostics.txt
   kubectl describe pod <pod-name> >> diagnostics.txt
   kubectl logs <pod-name> >> diagnostics.txt
   ```

2. **Check documentation:**
   - [README.md](README.md)
   - [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
   - [Helm Quick Start](helm-chart/HELM_QUICKSTART.md)

3. **Common resources:**
   - Kubernetes docs: https://kubernetes.io/docs/
   - Helm docs: https://helm.sh/docs/
   - n8n docs: https://docs.n8n.io/

4. **Report issues:**
   - GitHub Issues: https://github.com/mariomafdy/konecta-cv-screening/issues
   - Include diagnostics output
   - Describe steps to reproduce

---

## Prevention Tips

1. **Always run validation before deploying:**
   ```bash
   ./validate-deployment.sh
   ```

2. **Create secrets BEFORE installing Helm chart**

3. **Check resource requirements match your cluster capacity**

4. **Use specific image tags in production (not `latest`)**

5. **Test with dry-run first:**
   ```bash
   helm install n8n-cv-screening ./helm-chart/n8n --dry-run --debug
   ```

6. **Monitor logs during initial deployment:**
   ```bash
   kubectl logs -f deployment/n8n-cv-screening
   ```
