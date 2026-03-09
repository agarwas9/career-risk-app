# -----------------------------------------------------------
# Start Script for Local DevOps Platform Environment
# -----------------------------------------------------------
# This script starts the complete Kubernetes development
# platform including:
# Docker
# Kind Kubernetes cluster
# Metrics Server
# NGINX Ingress Controller
# Application (Frontend, Backend, Postgres)
# Prometheus Monitoring Stack
# Grafana Dashboards
# -----------------------------------------------------------

Write-Host "Starting DevOps Kubernetes Environment..." -ForegroundColor Green

# Ensure script runs from project root
Set-Location "C:\Users\Administrator\Desktop\DevOps\Git\career-risk-app"

# Cluster name used by Kind
$CLUSTER_NAME="career-cluster"


# -----------------------------------------------------------
# Start Docker Desktop
# -----------------------------------------------------------
# Kubernetes (Kind) requires Docker to run container nodes.
# This step launches Docker Desktop and waits until it is ready.

Write-Host ""
Write-Host "Starting Docker Desktop..."

Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

Write-Host "Waiting for Docker to be ready..."

do {
    Start-Sleep -Seconds 5
    $dockerReady = docker info 2>$null
} until ($dockerReady)

Write-Host "Docker is ready." -ForegroundColor Green


# -----------------------------------------------------------
# Create Kubernetes Cluster using Kind
# -----------------------------------------------------------
# Kind creates a local Kubernetes cluster inside Docker.

Write-Host ""
Write-Host "Creating Kind cluster..."

C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe create cluster --name $CLUSTER_NAME


# -----------------------------------------------------------
# Install Kubernetes Metrics Server
# -----------------------------------------------------------
# Metrics Server collects CPU and memory metrics from pods.
# Required for Horizontal Pod Autoscaler (HPA).

Write-Host ""
Write-Host "Installing Metrics Server..."

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Start-Sleep -Seconds 5


# -----------------------------------------------------------
# Patch Metrics Server (Kind TLS workaround)
# -----------------------------------------------------------
# Kind uses self-signed certificates, so the metrics server
# must be patched to allow insecure TLS communication.

Write-Host "Patching Metrics Server..."

kubectl patch deployment metrics-server -n kube-system --patch-file patches/metrics-server-patch.yaml


# -----------------------------------------------------------
# Install NGINX Ingress Controller
# -----------------------------------------------------------
# The ingress controller acts as the entry point for HTTP
# traffic into the cluster.

Write-Host ""
Write-Host "Installing NGINX Ingress Controller..."

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml


# -----------------------------------------------------------
# Build Docker Images for Application
# -----------------------------------------------------------
# Build local images for backend API and frontend UI.

Write-Host ""
Write-Host "Building Docker Images..."

docker build -t career-backend ./backend
docker build -t career-frontend ./frontend


# -----------------------------------------------------------
# Load Images into Kind Cluster
# -----------------------------------------------------------
# Since Kind runs inside Docker, images must be explicitly
# loaded into the cluster.

Write-Host ""
Write-Host "Loading images into Kind cluster..."

C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe load docker-image career-backend --name $CLUSTER_NAME
C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe load docker-image career-frontend --name $CLUSTER_NAME


# -----------------------------------------------------------
# OLD DEPLOYMENT METHOD (Deprecated)
# -----------------------------------------------------------
# Previously the application was deployed using raw Kubernetes
# manifests.

# kubectl apply -f k8s/


# -----------------------------------------------------------
# NEW DEPLOYMENT METHOD (Helm)
# -----------------------------------------------------------
# Helm packages the application into a reusable chart.

Write-Host ""
Write-Host "Deploying Application using Helm..."

helm install career-app ./helm/career-app


# -----------------------------------------------------------
# Install Observability Stack
# -----------------------------------------------------------
# Deploy Prometheus, Grafana, Alertmanager, Node Exporter,
# and Kubernetes monitoring components.

Write-Host ""
Write-Host "Installing Monitoring Stack (Prometheus + Grafana)..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack


# -----------------------------------------------------------
# Wait for Pods to Start
# -----------------------------------------------------------
# Allow time for all Kubernetes components to initialize.

Write-Host ""
Write-Host "Waiting for pods to start..."

Start-Sleep -Seconds 30


# -----------------------------------------------------------
# Start Port Forwarding for Ingress
# -----------------------------------------------------------
# Enables access to the application via local browser.

Write-Host ""
Write-Host "Starting Ingress Port Forward..."

Start-Job { kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80 }


# -----------------------------------------------------------
# Start Grafana Port Forward
# -----------------------------------------------------------
# Enables access to Grafana dashboards.

Write-Host "Starting Grafana Port Forward..."

Start-Job { kubectl port-forward service/prometheus-grafana 3000:80 }


# -----------------------------------------------------------
# Environment Status
# -----------------------------------------------------------

Write-Host ""
Write-Host "Environment Started Successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "Application URL:"
Write-Host "http://career.local:8081"
Write-Host ""

Write-Host "Grafana URL:"
Write-Host "http://localhost:3000"
Write-Host ""


# -----------------------------------------------------------
# Open Application Automatically
# -----------------------------------------------------------

Write-Host "Opening application in Chrome..."

Start-Process "chrome.exe" "http://career.local:8081"


# -----------------------------------------------------------
# Cluster Status Checks
# -----------------------------------------------------------

Write-Host ""
Write-Host "Pod Status (Verify all are Running):" -ForegroundColor Cyan
kubectl get pods

Write-Host ""
Write-Host "Ingress Controller Status:" -ForegroundColor Cyan
kubectl get pods -n ingress-nginx

Write-Host ""
Write-Host "Autoscaler Status:" -ForegroundColor Cyan
kubectl get hpa


Write-Host ""
Write-Host "If all pods show 'Running', the environment is ready." -ForegroundColor Green