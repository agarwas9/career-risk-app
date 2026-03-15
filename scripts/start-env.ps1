# -----------------------------------------------------------
# Start Script for Local DevOps Platform Environment
# -----------------------------------------------------------
# This script starts the complete Kubernetes development
# platform including:
#
# Docker
# Kind Kubernetes cluster
# Metrics Server
# NGINX Ingress Controller
# Prometheus Monitoring Stack
# Grafana Dashboards
# Jenkins CI/CD Server
#
# IMPORTANT (Day 5 Change):
# Application deployment is now handled by Jenkins CI/CD.
#
# Developers deploy new versions using:
# git push → Jenkins pipeline → Kubernetes deployment
#
# Therefore manual image builds and Helm deployments
# are no longer executed in this script.
# -----------------------------------------------------------

Write-Host ""
Write-Host "Starting DevOps Kubernetes Environment..." -ForegroundColor Green


# -----------------------------------------------------------
# Ensure Script Runs From Project Root
# -----------------------------------------------------------

Set-Location "C:\Users\Administrator\Desktop\DevOps\Git\career-risk-app"

$CLUSTER_NAME="career-cluster"


# -----------------------------------------------------------
# Start Docker Desktop
# -----------------------------------------------------------

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
# Start Jenkins CI/CD Server
# -----------------------------------------------------------
# Jenkins runs inside Docker and performs:
#
# - Docker image builds
# - Kubernetes deployments
# - Helm upgrades
#
# The container is recreated every time to guarantee the
# correct DevOps tooling environment.
# -----------------------------------------------------------

Write-Host ""
Write-Host "Starting Jenkins CI/CD server..."

docker rm -f jenkins 2>$null

docker run -d `
 --name jenkins `
 -p 8085:8080 `
 -p 50000:50000 `
 -v jenkins_home:/var/jenkins_home `
 -v /var/run/docker.sock:/var/run/docker.sock `
 -u root `
 jenkins-devops

Write-Host "Jenkins running at http://localhost:8085" -ForegroundColor Green

# -----------------------------------------------------------
# Copy Kubernetes kubeconfig into Jenkins container
# -----------------------------------------------------------
# Jenkins pipelines use this kubeconfig to access the
# local Kind cluster for Helm deployments.

Write-Host ""
Write-Host "Copying kubeconfig into Jenkins container..."

docker cp `
C:\Users\Administrator\Desktop\DevOps\Git\career-risk-app\Jenkins\career-kubeconfig.yaml `
jenkins:/career-kubeconfig.yaml

Write-Host "Kubeconfig copied to Jenkins." -ForegroundColor Green

# -----------------------------------------------------------
# Verify Jenkins DevOps Tools
# -----------------------------------------------------------

Write-Host ""
Write-Host "Verifying Jenkins DevOps tools..."

docker exec jenkins docker --version
docker exec jenkins kubectl version --client
docker exec jenkins helm version
docker exec jenkins kind version


# -----------------------------------------------------------
# Create Kubernetes Cluster (Kind)
# -----------------------------------------------------------

Write-Host ""
Write-Host "Creating Kind Kubernetes cluster..."

C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe create cluster --name $CLUSTER_NAME


# -----------------------------------------------------------
# Install Metrics Server
# -----------------------------------------------------------

Write-Host ""
Write-Host "Installing Kubernetes Metrics Server..."

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Start-Sleep -Seconds 5


# -----------------------------------------------------------
# Patch Metrics Server (Kind TLS workaround)
# -----------------------------------------------------------

Write-Host "Patching Metrics Server TLS settings..."

kubectl patch deployment metrics-server -n kube-system --patch-file patches/metrics-server-patch.yaml


# -----------------------------------------------------------
# Install NGINX Ingress Controller
# -----------------------------------------------------------

Write-Host ""
Write-Host "Installing NGINX Ingress Controller..."

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml


# -----------------------------------------------------------
# OLD DEPLOYMENT METHOD (Deprecated After Day 5)
# -----------------------------------------------------------
# Previously this script performed manual deployments:
#
# 1. Build Docker images
# 2. Load images into Kind cluster
# 3. Deploy application using Helm
#
# This approach was replaced with Jenkins CI/CD automation.
#
# Keeping the code commented provides documentation of
# the project's evolution from manual DevOps to CI/CD.
# -----------------------------------------------------------

# Write-Host ""
# Write-Host "Building Docker Images..."
#
# docker build -t career-backend ./backend
# docker build -t career-frontend ./frontend
#
#
# Write-Host ""
# Write-Host "Loading images into Kind cluster..."
#
# C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe load docker-image career-backend --name $CLUSTER_NAME
# C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe load docker-image career-frontend --name $CLUSTER_NAME
#
#
# Write-Host ""
# Write-Host "Deploying Application using Helm..."
#
# helm install career-app ./helm/career-app


# -----------------------------------------------------------
# Install Monitoring Stack
# -----------------------------------------------------------

Write-Host ""
Write-Host "Installing Prometheus + Grafana monitoring stack..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack


# -----------------------------------------------------------
# Wait for Kubernetes Pods
# -----------------------------------------------------------

Write-Host ""
Write-Host "Waiting for Kubernetes components to start..."

Start-Sleep -Seconds 30


# -----------------------------------------------------------
# Start Port Forwarding for Ingress
# -----------------------------------------------------------

Write-Host ""
Write-Host "Starting Ingress port forwarding..."

Start-Job { kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80 }


# -----------------------------------------------------------
# Start Grafana Port Forward
# -----------------------------------------------------------

Write-Host "Starting Grafana port forwarding..."

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

Write-Host "Grafana Dashboard:"
Write-Host "http://localhost:3000"
Write-Host ""

Write-Host "Jenkins CI/CD:"
Write-Host "http://localhost:8085"
Write-Host ""


# -----------------------------------------------------------
# Open Application Automatically
# -----------------------------------------------------------

Write-Host "Opening application in Chrome..."

Start-Process "chrome.exe" "http://career.local:8081"

Write-Host "Opening Grafana in Chrome..."

Start-Process "chrome.exe" "http://localhost:3000"

Write-Host "Opening Jenkins in Chrome, build the docker-test to run app"

Start-Process "chrome.exe" "http://localhost:8085/job/docker-test/"


# -----------------------------------------------------------
# Cluster Status Checks
# -----------------------------------------------------------

Write-Host ""
Write-Host "Kubernetes Pod Status:" -ForegroundColor Cyan
kubectl get pods

Write-Host ""
Write-Host "Ingress Controller Status:" -ForegroundColor Cyan
kubectl get pods -n ingress-nginx

Write-Host ""
Write-Host "Horizontal Pod Autoscaler:" -ForegroundColor Cyan
kubectl get hpa


# -----------------------------------------------------------
# Deployment Instructions
# -----------------------------------------------------------

Write-Host ""
Write-Host "Application deployments are handled by Jenkins CI/CD." -ForegroundColor Yellow
Write-Host ""

Write-Host "To deploy a new vaersion:"
Write-Host "1) Make code changes"
Write-Host "2) git add ."
Write-Host "3) git commit -m 'update'"
Write-Host "4) git push"
Write-Host ""
Write-Host "Jenkins will automatically build and deploy the new version." -ForegroundColor Green