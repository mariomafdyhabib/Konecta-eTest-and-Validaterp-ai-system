# GitHub Actions CI/CD Setup for Docker Hub

This repository includes an automated GitHub Actions pipeline that builds, tests, and pushes your Docker image to Docker Hub on every push.

## Features

- **Automated Docker Build**: Builds the Docker image on every push to main/develop branches
- **Comprehensive Testing**: Validates image structure, startup, and health checks
- **Security Scanning**: Uses Trivy to scan for vulnerabilities
- **Multi-Architecture Support**: Builds for both AMD64 and ARM64 platforms
- **Smart Caching**: Implements Docker layer caching for faster builds
- **Auto-Tagging**: Generates semantic version tags and SHA-based tags
- **Pull Request Testing**: Builds and tests on PRs without pushing to Docker Hub

## Required GitHub Secrets

Before the pipeline can push to Docker Hub, you need to configure the following secrets in your GitHub repository:

### 1. DOCKERHUB_USERNAME
Your Docker Hub username

### 2. DOCKERHUB_TOKEN
Your Docker Hub access token (NOT your password)

## How to Set Up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

   **Secret 1: DOCKERHUB_USERNAME**
   - Name: `DOCKERHUB_USERNAME`
   - Value: Your Docker Hub username (e.g., `mariomafdy`)

   **Secret 2: DOCKERHUB_TOKEN**
   - Name: `DOCKERHUB_TOKEN`
   - Value: Your Docker Hub access token

### How to Generate Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Click on your username in the top right → **Account Settings**
3. Go to **Security** → **Access Tokens**
4. Click **New Access Token**
5. Give it a description (e.g., "GitHub Actions CI/CD")
6. Set permissions to **Read, Write, Delete**
7. Click **Generate**
8. **IMPORTANT**: Copy the token immediately (you won't see it again!)
9. Paste this token as the `DOCKERHUB_TOKEN` secret in GitHub

## Pipeline Workflow

### Trigger Events
The pipeline runs automatically on:
- Push to `main` branch
- Push to `develop` branch
- Push tags matching `v*.*.*` (e.g., v1.0.0)
- Pull requests to `main` or `develop`

### Pipeline Steps

1. **Checkout Code**: Clones the repository
2. **Setup Docker Buildx**: Configures advanced Docker build features
3. **Cache Docker Layers**: Speeds up builds by caching layers
4. **Create Dummy Files**: Creates placeholder files for sensitive data during build
5. **Extract Metadata**: Generates Docker tags based on branch/tag/SHA
6. **Build for Testing**: Builds the image locally for testing
7. **Test Structure**: Validates image configuration and environment
8. **Test Startup**: Runs the container and checks if n8n starts correctly
9. **Security Scan**: Scans for vulnerabilities using Trivy
10. **Login to Docker Hub**: Authenticates (only on push, not PR)
11. **Build & Push**: Builds multi-arch image and pushes to Docker Hub
12. **Generate Summary**: Creates a build report in GitHub Actions

## Docker Image Tags

The pipeline automatically generates the following tags:

- `latest` - Always points to the latest main branch build
- `main` - Latest build from main branch
- `develop` - Latest build from develop branch
- `v1.0.0` - Semantic version tag (when you push a git tag)
- `v1.0` - Major.minor version
- `v1` - Major version only
- `main-abc1234` - Branch name + short commit SHA

## Pull Your Image from Docker Hub

After a successful build, you can pull your image:

```bash
# Pull the latest version
docker pull mariomafdy/n8n-konecta-cv-screening:latest

# Pull a specific version
docker pull mariomafdy/n8n-konecta-cv-screening:main

# Pull by commit SHA
docker pull mariomafdy/n8n-konecta-cv-screening:main-abc1234
```

## Testing the Pipeline

### Test on Pull Request
1. Create a new branch: `git checkout -b test-ci`
2. Make a change to any file
3. Push: `git push origin test-ci`
4. Create a Pull Request to `main`
5. The pipeline will build and test, but won't push to Docker Hub

### Test Full Pipeline
1. Merge your PR or push directly to `main`
2. The pipeline will build, test, AND push to Docker Hub
3. Check the Actions tab in GitHub to see the progress

## Monitoring Builds

### View Build Status
- Go to your repository on GitHub
- Click the **Actions** tab
- Click on the latest workflow run
- View logs for each step

### Build Summary
Each build generates a summary with:
- Image name and tags
- Build status
- Commit information
- Pull command for easy deployment

## Security Features

### Vulnerability Scanning
- Trivy scans every build for HIGH and CRITICAL vulnerabilities
- Results are uploaded to GitHub Security tab
- Build continues even if vulnerabilities are found (informational only)

### Secrets Management
- Sensitive files (credentials.json, env) are never committed
- Dummy files are created during CI/CD build
- Real secrets should be injected at runtime via Docker secrets or environment variables

### Multi-Architecture Support
Images are built for:
- `linux/amd64` - Standard x86_64 servers
- `linux/arm64` - ARM-based servers (AWS Graviton, Apple Silicon, etc.)

## Troubleshooting

### Build Fails: "Cannot push to Docker Hub"
**Solution**: Verify GitHub secrets are configured correctly:
- Check `DOCKERHUB_USERNAME` matches your Docker Hub username
- Regenerate `DOCKERHUB_TOKEN` if needed

### Build Fails: "Timeout waiting for n8n to start"
**Solution**: The health check might need adjustment. Check:
- Container logs in the pipeline output
- Startup script logic
- Dockerfile configuration

### Build Fails: "File not found"
**Solution**: The build expects certain files to exist:
- workflows.json
- startup.sh
- Attrition.json (or workflows.json)

Ensure these files are committed to the repository.

### Security Scan Shows Vulnerabilities
**Note**: This is informational only and won't fail the build.
**Action**: Review the vulnerabilities and decide if they need addressing:
1. Check the Security tab in GitHub
2. Review the SARIF results
3. Update base image or dependencies if needed

## Customization

### Change Docker Image Name
Edit [.github/workflows/docker-build-push.yml](.github/workflows/docker-build-push.yml):
```yaml
env:
  DOCKER_IMAGE_NAME: your-custom-name  # Change this
```

### Add More Tests
Add steps after the "Test Docker image runs successfully" step:
```yaml
- name: Run custom tests
  run: |
    # Your test commands here
    docker exec test-container n8n export:workflow --all
```

### Change Trigger Branches
Edit the `on.push.branches` section:
```yaml
on:
  push:
    branches:
      - main
      - staging  # Add more branches
      - production
```

## Best Practices

1. **Version Tagging**: Use semantic versioning for releases
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Branch Strategy**:
   - `develop` - Development/testing builds
   - `main` - Production-ready builds
   - Use PRs to test before merging

3. **Security**:
   - Never commit real credentials
   - Use Docker secrets for production
   - Review security scan results regularly

4. **Monitoring**:
   - Enable GitHub Actions notifications
   - Check the Actions tab regularly
   - Review build summaries

## Next Steps

1. ✅ Set up GitHub secrets (DOCKERHUB_USERNAME and DOCKERHUB_TOKEN)
2. ✅ Push code to trigger the pipeline
3. ✅ Monitor the build in GitHub Actions
4. ✅ Pull and test your image from Docker Hub
5. ✅ Set up production deployment using the published image

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com/)
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)
