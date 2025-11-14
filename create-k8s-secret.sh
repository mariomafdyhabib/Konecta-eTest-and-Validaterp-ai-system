#!/bin/bash
#
# N8N CV Screening - Kubernetes Secret Creator
# This script helps create the required Kubernetes secret
#

set -e

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # No Color

echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
echo -e "${COLOR_BLUE}N8N CV Screening - Secret Creator${COLOR_NC}"
echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${COLOR_RED}Error: .env file not found!${COLOR_NC}"
    echo ""
    echo "Please create a .env file first:"
    echo "  1. Copy the example: cp .env.example .env"
    echo "  2. Edit .env and add your API keys"
    echo "  3. Run this script again"
    echo ""
    exit 1
fi

echo -e "${COLOR_GREEN}✓${COLOR_NC} Found .env file"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${COLOR_RED}Error: kubectl is not installed or not in PATH${COLOR_NC}"
    exit 1
fi

echo -e "${COLOR_GREEN}✓${COLOR_NC} kubectl is available"
echo ""

# Check if connected to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${COLOR_RED}Error: Not connected to a Kubernetes cluster${COLOR_NC}"
    echo ""
    echo "Please connect to your cluster first:"
    echo "  - For minikube: minikube start"
    echo "  - For cloud providers: configure kubectl context"
    echo ""
    exit 1
fi

echo -e "${COLOR_GREEN}✓${COLOR_NC} Connected to Kubernetes cluster"
echo ""

# Check if secret already exists
if kubectl get secret n8n-secrets &> /dev/null; then
    echo -e "${COLOR_YELLOW}Warning: Secret 'n8n-secrets' already exists${COLOR_NC}"
    echo ""
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing secret..."
        kubectl delete secret n8n-secrets
        echo -e "${COLOR_GREEN}✓${COLOR_NC} Deleted existing secret"
        echo ""
    else
        echo "Keeping existing secret. Exiting."
        exit 0
    fi
fi

# Create secret from .env file
echo "Creating Kubernetes secret from .env file..."
echo ""

kubectl create secret generic n8n-secrets --from-env-file=.env

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${COLOR_GREEN}✓${COLOR_NC} Secret 'n8n-secrets' created successfully!"
    echo ""

    # Verify secret
    echo "Verifying secret..."
    SECRET_KEYS=$(kubectl get secret n8n-secrets -o jsonpath='{.data}' | jq -r 'keys[]' 2>/dev/null || echo "")

    if [ -n "$SECRET_KEYS" ]; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC} Secret contains the following keys:"
        echo "$SECRET_KEYS" | while read key; do
            echo "  - $key"
        done
    fi

    echo ""
    echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
    echo -e "${COLOR_BLUE}Next Steps${COLOR_NC}"
    echo -e "${COLOR_BLUE}========================================${COLOR_NC}"
    echo ""

    # Check if deployment exists
    if kubectl get deployment n8n-cv-screening &> /dev/null; then
        echo "The n8n-cv-screening deployment already exists."
        echo "Restarting it to pick up the new secret..."
        echo ""
        kubectl rollout restart deployment/n8n-cv-screening
        echo ""
        echo -e "${COLOR_GREEN}✓${COLOR_NC} Deployment restarted"
        echo ""
        echo "Monitor the deployment:"
        echo "  kubectl get pods -w"
        echo ""
        echo "Check logs:"
        echo "  kubectl logs -f deployment/n8n-cv-screening"
    else
        echo "Install the Helm chart:"
        echo "  helm install n8n-cv-screening ./helm-chart/n8n"
        echo ""
        echo "Or if using a specific namespace:"
        echo "  helm install n8n-cv-screening ./helm-chart/n8n --namespace n8n --create-namespace"
    fi

    echo ""
    echo "Access n8n:"
    echo "  kubectl port-forward svc/n8n-cv-screening 5678:5678"
    echo "  Then visit: http://localhost:5678"
    echo ""
else
    echo ""
    echo -e "${COLOR_RED}✗${COLOR_NC} Failed to create secret"
    exit 1
fi
