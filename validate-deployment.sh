#!/bin/bash
#
# N8N CV Screening Bot - Deployment Validation Script
# This script validates your deployment configuration before deploying
#

set -e

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # No Color

echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
echo -e "${COLOR_BLUE}N8N CV Screening - Deployment Validator${COLOR_NC}"
echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
echo ""

# Function to print success message
success() {
    echo -e "${COLOR_GREEN}✓${COLOR_NC} $1"
}

# Function to print error message
error() {
    echo -e "${COLOR_RED}✗${COLOR_NC} $1"
}

# Function to print warning message
warning() {
    echo -e "${COLOR_YELLOW}⚠${COLOR_NC} $1"
}

# Function to print info message
info() {
    echo -e "${COLOR_BLUE}ℹ${COLOR_NC} $1"
}

# Check if required tools are installed
echo "Checking prerequisites..."

# Check Docker
if command -v docker &> /dev/null; then
    success "Docker is installed ($(docker --version | cut -d' ' -f3 | tr -d ','))"
else
    error "Docker is not installed"
    exit 1
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    success "Docker Compose is installed ($(docker-compose --version | cut -d' ' -f3 | tr -d ','))"
    DOCKER_COMPOSE_AVAILABLE=true
else
    warning "Docker Compose is not installed (optional for Docker Compose deployment)"
    DOCKER_COMPOSE_AVAILABLE=false
fi

# Check Helm
if command -v helm &> /dev/null; then
    success "Helm is installed ($(helm version --short 2>/dev/null || echo 'version unknown'))"
    HELM_AVAILABLE=true
else
    warning "Helm is not installed (optional for Kubernetes deployment)"
    HELM_AVAILABLE=false
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    success "kubectl is installed ($(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 || echo 'version unknown'))"
    KUBECTL_AVAILABLE=true
else
    warning "kubectl is not installed (optional for Kubernetes deployment)"
    KUBECTL_AVAILABLE=false
fi

echo ""

# Validate configuration files
echo "Validating configuration files..."

# Check .env file
if [ -f ".env" ]; then
    success ".env file exists"

    # Check for required environment variables
    REQUIRED_VARS=(
        "OPENROUTER_API_KEY"
        "HUGGINGFACE_API_KEY"
        "PINECONE_API_KEY"
        "TELEGRAM_BOT_TOKEN"
    )

    MISSING_VARS=()
    for var in "${REQUIRED_VARS[@]}"; do
        if ! grep -q "^${var}=" .env 2>/dev/null || grep -q "^${var}=$\|^${var}=your_\|^${var}=dummy" .env 2>/dev/null; then
            MISSING_VARS+=("$var")
        fi
    done

    if [ ${#MISSING_VARS[@]} -eq 0 ]; then
        success "All required environment variables are set"
    else
        warning "The following environment variables need to be configured:"
        for var in "${MISSING_VARS[@]}"; do
            echo "  - $var"
        done
    fi
else
    warning ".env file not found. Copy .env.example to .env and configure it"
fi

# Validate Docker Compose
if [ "$DOCKER_COMPOSE_AVAILABLE" = true ]; then
    echo ""
    echo "Validating Docker Compose configuration..."

    if [ -f "docker-compose.yml" ]; then
        if docker-compose config > /dev/null 2>&1; then
            success "docker-compose.yml is valid"
        else
            error "docker-compose.yml has syntax errors"
            docker-compose config
        fi
    else
        error "docker-compose.yml not found"
    fi
fi

# Validate Helm Chart
if [ "$HELM_AVAILABLE" = true ]; then
    echo ""
    echo "Validating Helm chart..."

    if [ -d "helm-chart/n8n" ]; then
        # Lint Helm chart
        if helm lint ./helm-chart/n8n > /dev/null 2>&1; then
            success "Helm chart passes lint validation"
        else
            error "Helm chart has errors"
            helm lint ./helm-chart/n8n
        fi

        # Test template rendering
        if helm template test ./helm-chart/n8n > /dev/null 2>&1; then
            success "Helm chart templates render correctly (default values)"
        else
            error "Helm chart template rendering failed (default values)"
        fi

        # Test production values
        if [ -f "helm-chart/n8n/values-production.yaml" ]; then
            if helm template test ./helm-chart/n8n -f helm-chart/n8n/values-production.yaml > /dev/null 2>&1; then
                success "Helm chart templates render correctly (production values)"
            else
                error "Helm chart template rendering failed (production values)"
            fi
        fi
    else
        error "Helm chart directory not found"
    fi
fi

# Check Kubernetes connectivity
if [ "$KUBECTL_AVAILABLE" = true ]; then
    echo ""
    echo "Checking Kubernetes cluster connectivity..."

    if kubectl cluster-info > /dev/null 2>&1; then
        success "Connected to Kubernetes cluster"

        # Check for existing deployment
        if kubectl get deployment n8n-cv-screening > /dev/null 2>&1; then
            warning "n8n-cv-screening deployment already exists in the cluster"
        fi

        # Check for secret
        if kubectl get secret n8n-secrets > /dev/null 2>&1; then
            success "n8n-secrets already exists in the cluster"
        else
            info "n8n-secrets does not exist. You'll need to create it before deploying"
        fi

    else
        warning "Not connected to a Kubernetes cluster (this is OK if you're not deploying to K8s)"
    fi
fi

# Validate Dockerfile
echo ""
echo "Validating Dockerfile..."

if [ -f "Dockerfile" ]; then
    success "Dockerfile exists"

    # Check if required files exist
    REQUIRED_FILES=("workflows.json" "startup.sh")
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            success "$file exists"
        else
            error "$file is missing (required by Dockerfile)"
        fi
    done
else
    error "Dockerfile not found"
fi

# Summary
echo ""
echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
echo -e "${COLOR_BLUE}Validation Summary${COLOR_NC}"
echo -e "${COLOR_BLUE}========================================${COLOR_NC}"

echo ""
echo "Deployment options available:"

if [ "$DOCKER_COMPOSE_AVAILABLE" = true ] && [ -f "docker-compose.yml" ] && [ -f ".env" ]; then
    success "Docker Compose deployment is ready"
    echo "  → Run: docker-compose up -d"
else
    warning "Docker Compose deployment is not ready"
fi

if [ "$HELM_AVAILABLE" = true ] && [ -d "helm-chart/n8n" ]; then
    success "Helm deployment is ready"
    echo "  → Run: kubectl create secret generic n8n-secrets --from-env-file=.env"
    echo "  → Run: helm install n8n-cv-screening ./helm-chart/n8n"
else
    warning "Helm deployment is not ready"
fi

if command -v docker &> /dev/null && [ -f ".env" ]; then
    success "Docker run deployment is ready"
    echo "  → Run: docker run -d -p 5678:5678 --env-file .env mariomafdy/n8n-lampada"
else
    warning "Docker run deployment is not ready"
fi

echo ""
echo -e "${COLOR_GREEN}Validation complete!${COLOR_NC}"
echo ""
