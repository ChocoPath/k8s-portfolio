#!/bin/bash

# Deploy monitoring stack to Kubernetes
echo "🚀 Deploying monitoring stack to Kubernetes..."

# Create monitoring namespace
echo "📦 Creating monitoring namespace..."
kubectl apply -f monitoring/namespace.yaml

# Deploy Prometheus
echo "📊 Deploying Prometheus..."
kubectl apply -f monitoring/prometheus-rbac.yaml
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml

# Deploy kube-state-metrics
echo "📈 Deploying kube-state-metrics..."
kubectl apply -f monitoring/kube-state-metrics.yaml

# Deploy Grafana
echo "📉 Deploying Grafana..."
kubectl apply -f monitoring/grafana-config.yaml
kubectl apply -f monitoring/grafana-deployment.yaml

# Rebuild and redeploy backend with metrics
echo "🔄 Rebuilding backend with Prometheus metrics..."
cd backend
docker build -t portfolio-backend:v2 .
kind load docker-image portfolio-backend:v2 --name k8s-portfolio
cd ..

# Update backend deployment to use new image
echo "🔄 Updating backend deployment..."
kubectl patch statefulset backend-statefulset -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","image":"portfolio-backend:v2"}]}}}}'

# Apply updated services with Prometheus annotations
echo "🔄 Updating services with Prometheus annotations..."
kubectl apply -f manifests/backend-service.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/kube-state-metrics -n monitoring

echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "🔍 Access URLs:"
echo "Prometheus: http://localhost:9090 (kubectl port-forward service/prometheus 9090:9090 -n monitoring)"
echo "Grafana: http://localhost:3000 (kubectl port-forward service/grafana 3000:3000 -n monitoring)"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "📊 Check status:"
echo "kubectl get pods -n monitoring"
echo "kubectl get services -n monitoring"
