# -----------------------------------------------------------
# Stop Script for Local DevOps Platform Environment
# -----------------------------------------------------------
# This script shuts down the complete Kubernetes environment
# including:
# Helm deployments
# Monitoring stack
# Port-forward jobs
# Kind Kubernetes cluster
# Docker containers
# Docker Desktop
# -----------------------------------------------------------

Write-Host "Stopping DevOps Kubernetes Environment..." -ForegroundColor Yellow

$CLUSTER_NAME="career-cluster"


# -----------------------------------------------------------
# Stop Background Port Forward Jobs
# -----------------------------------------------------------
# These jobs were started in the start script for:
# Ingress access
# Grafana dashboard access

Write-Host ""
Write-Host "Stopping background port-forward jobs..."

Stop-Job * -ErrorAction SilentlyContinue
Remove-Job * -ErrorAction SilentlyContinue


# -----------------------------------------------------------
# OLD METHOD (Raw Kubernetes Manifests)
# -----------------------------------------------------------
# Previously resources were removed using:
#
# kubectl delete -f k8s/
#
# This is no longer used because the application
# is now managed using Helm.


# -----------------------------------------------------------
# Remove Helm Application Release
# -----------------------------------------------------------
# Removes frontend, backend, postgres, ingress,
# autoscaler and related Kubernetes resources.

Write-Host ""
Write-Host "Removing Helm application release..."

helm uninstall career-app 2>$null


# -----------------------------------------------------------
# Remove Monitoring Stack
# -----------------------------------------------------------
# This removes Prometheus, Grafana, Alertmanager,
# Node Exporter and Kubernetes monitoring resources.

Write-Host ""
Write-Host "Removing Monitoring Stack (Prometheus + Grafana)..."

helm uninstall prometheus 2>$null


# -----------------------------------------------------------
# Delete Kind Kubernetes Cluster
# -----------------------------------------------------------
# This removes the local Kubernetes control plane
# and all cluster nodes.

Write-Host ""
Write-Host "Deleting Kind cluster..."

C:\Users\Administrator\Desktop\DevOps\Kubernetes\kind.exe delete cluster --name $CLUSTER_NAME


# -----------------------------------------------------------
# Remove Leftover Kind Containers
# -----------------------------------------------------------
# Occasionally Docker containers remain after cluster deletion.

Write-Host ""
Write-Host "Removing leftover Kind containers (if any)..."

docker rm -f $(docker ps -aq --filter "name=career-cluster") 2>$null


# -----------------------------------------------------------
# Clean Unused Docker Containers
# -----------------------------------------------------------
# Removes stopped containers created during builds
# or testing.

Write-Host ""
Write-Host "Cleaning unused Docker containers..."

docker container prune -f


# -----------------------------------------------------------
# Stop Docker Desktop
# -----------------------------------------------------------
# Optional step to fully shut down local container runtime.

Write-Host ""
Write-Host "Stopping Docker Desktop..."

$dockerProcesses = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
if ($dockerProcesses) {
    Stop-Process -Name "Docker Desktop" -Force
}


# -----------------------------------------------------------
# Environment Shutdown Complete
# -----------------------------------------------------------

Write-Host ""
Write-Host "Environment Stopped Successfully." -ForegroundColor Red