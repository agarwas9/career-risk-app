Write-Host ""
Write-Host "===== DevOps Environment Status =====" -ForegroundColor Cyan
Write-Host ""

# Check Docker
Write-Host "Docker Status:" -ForegroundColor Yellow
$dockerRunning = docker info 2>$null

if ($dockerRunning) {
    Write-Host "Docker is running" -ForegroundColor Green
} else {
    Write-Host "Docker is NOT running" -ForegroundColor Red
}

Write-Host ""

# Check Kubernetes cluster
Write-Host "Kubernetes Cluster:" -ForegroundColor Yellow
kubectl get nodes 2>$null

Write-Host ""

# Pods
Write-Host "Application Pods:" -ForegroundColor Yellow
kubectl get pods

Write-Host ""

# Ingress Controller
Write-Host "Ingress Controller Pods:" -ForegroundColor Yellow
kubectl get pods -n ingress-nginx

Write-Host ""

# Services
Write-Host "Services:" -ForegroundColor Yellow
kubectl get svc

Write-Host ""

# Ingress
Write-Host "Ingress:" -ForegroundColor Yellow
kubectl get ingress

Write-Host ""

# Autoscaler
Write-Host "Horizontal Pod Autoscaler:" -ForegroundColor Yellow
kubectl get hpa

Write-Host ""

Write-Host "Application URL:" -ForegroundColor Green
Write-Host "http://career.local:8081"

Write-Host ""
Write-Host "====================================="