# Monitoring and Observability

This directory contains a complete monitoring and observability stack for the Kubernetes portfolio project using Prometheus and Grafana.

## 🎯 What This Demonstrates

- **Metrics Collection**: Prometheus scraping Kubernetes and application metrics
- **Service Discovery**: Automatic discovery of targets using Kubernetes SD
- **Application Metrics**: Custom Node.js metrics using prom-client
- **Infrastructure Metrics**: kube-state-metrics for Kubernetes resource monitoring
- **Visualization**: Grafana dashboards for metrics visualization
- **Alerting**: Prometheus alerting rules for common issues
- **RBAC**: Proper service accounts and cluster roles for security

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Prometheus    │────│   Application   │    │    Grafana      │
│                 │    │    Metrics      │    │                 │
│ • Metrics Store │    │ • /metrics      │────│ • Dashboards    │
│ • Alerting      │    │ • HTTP stats    │    │ • Visualization │
│ • Service Disc. │    │ • Custom        │    │ • Alerts        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ kube-state      │
                    │ metrics         │
                    │                 │
                    │ • Pod Status    │
                    │ • Deployments   │
                    │ • Services      │
                    └─────────────────┘
```

## 📦 Components

### Prometheus
- **Image**: `prom/prometheus:v2.47.0`
- **Purpose**: Metrics collection, storage, and alerting
- **Config**: Custom configuration with Kubernetes service discovery
- **Storage**: EmptyDir (ephemeral) - suitable for demo
- **Port**: 9090

### Grafana
- **Image**: `grafana/grafana:10.1.0`
- **Purpose**: Metrics visualization and dashboards
- **Auth**: admin/admin (default)
- **Datasource**: Automatically configured to use Prometheus
- **Port**: 3000

### kube-state-metrics
- **Image**: `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.10.0`
- **Purpose**: Expose Kubernetes object metrics
- **Metrics**: Pods, Deployments, Services, Nodes, etc.
- **Port**: 8080 (metrics), 8081 (telemetry)

## 🚀 Quick Start

### Deploy Monitoring Stack

```bash
# Run the deployment script
./deploy-monitoring.sh
```

### Manual Deployment

```bash
# Create namespace
kubectl apply -f monitoring/namespace.yaml

# Deploy Prometheus
kubectl apply -f monitoring/prometheus-rbac.yaml
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml

# Deploy kube-state-metrics
kubectl apply -f monitoring/kube-state-metrics.yaml

# Deploy Grafana
kubectl apply -f monitoring/grafana-config.yaml
kubectl apply -f monitoring/grafana-deployment.yaml

# Rebuild backend with metrics
cd backend
docker build -t portfolio-backend:v2 .
kind load docker-image portfolio-backend:v2 --name k8s-portfolio
kubectl patch statefulset backend-statefulset -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","image":"portfolio-backend:v2"}]}}}}'
```

## 🔍 Access Monitoring

### Port Forward Services

```bash
# Prometheus
kubectl port-forward service/prometheus 9090:9090 -n monitoring

# Grafana
kubectl port-forward service/grafana 3000:3000 -n monitoring
```

### Access URLs

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

## 📊 Available Metrics

### Application Metrics (Backend)

- `http_requests_total` - Total HTTP requests by method, route, status
- `http_request_duration_seconds` - HTTP request duration histogram
- `http_active_connections` - Current active HTTP connections
- `nodejs_*` - Node.js runtime metrics (heap, event loop, etc.)
- `process_*` - Process-level metrics (CPU, memory, file descriptors)

### Kubernetes Metrics

- `kube_pod_status_phase` - Pod status by phase
- `kube_deployment_status_replicas` - Deployment replica status
- `kube_service_info` - Service information
- `kube_node_status_condition` - Node health status
- `container_memory_usage_bytes` - Container memory usage
- `container_cpu_usage_seconds_total` - Container CPU usage

### System Metrics

- `up` - Target availability
- `prometheus_build_info` - Prometheus build information
- `prometheus_config_last_reload_successful` - Config reload status

## 📈 Sample Queries

### Application Performance

```promql
# Request rate per minute
rate(http_requests_total[1m])

# Average request duration
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Infrastructure Health

```promql
# Pod restart rate
rate(kube_pod_container_status_restarts_total[5m])

# Memory usage percentage
(container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100

# CPU usage percentage
rate(container_cpu_usage_seconds_total[5m]) * 100

# Available pods vs desired
kube_deployment_status_replicas_available / kube_deployment_spec_replicas
```

## 🚨 Alerting Rules

The monitoring stack includes predefined alerting rules:

- **HighErrorRate**: Triggers when error rate > 10% for 2 minutes
- **HighMemoryUsage**: Triggers when memory usage > 80% for 2 minutes
- **PodCrashLooping**: Triggers when pod restart rate > 0 for 2 minutes
- **NodeDown**: Triggers when node is unreachable for 2 minutes

## 📊 Grafana Dashboards

### Portfolio Application Dashboard

The included dashboard provides:

- **Pod Status**: Current status of all pods
- **Memory Usage**: Memory consumption over time
- **CPU Usage**: CPU utilization trends
- **HTTP Request Rate**: Application request metrics
- **Error Rates**: HTTP error tracking
- **Response Times**: Latency monitoring

### Adding Custom Dashboards

1. Access Grafana UI
2. Go to "+" → Import
3. Use dashboard ID or JSON definition
4. Configure data source (Prometheus)

## 🔧 Configuration

### Prometheus Configuration

The Prometheus configuration includes:

- **Global settings**: 15s scrape interval
- **Kubernetes service discovery**: Automatic target discovery
- **Relabeling rules**: Proper metric labeling
- **Alerting rules**: Custom alert definitions
- **Storage**: Local storage with 200h retention

### Grafana Configuration

- **Admin credentials**: admin/admin
- **Data source**: Auto-configured Prometheus
- **Dashboards**: Auto-provisioned portfolio dashboard
- **Plugins**: Default Grafana plugins

## 🔒 Security Considerations

### RBAC Configuration

- **Service accounts**: Dedicated accounts for each component
- **Cluster roles**: Minimal required permissions
- **Role bindings**: Proper scope limitation

### Network Security

- **Service types**: ClusterIP for internal communication
- **LoadBalancer**: Only for external access points
- **Port exposure**: Only necessary ports exposed

## 🐛 Troubleshooting

### Common Issues

```bash
# Check pod status
kubectl get pods -n monitoring

# View logs
kubectl logs -f deployment/prometheus -n monitoring
kubectl logs -f deployment/grafana -n monitoring

# Check service discovery
curl http://localhost:9090/api/v1/targets

# Test metrics endpoint
kubectl port-forward service/backend-service-lb 3001:3000
curl http://localhost:3001/metrics
```

### Prometheus Not Scraping Targets

1. Check service annotations:
   ```yaml
   annotations:
     prometheus.io/scrape: 'true'
     prometheus.io/port: '3000'
     prometheus.io/path: '/metrics'
   ```

2. Verify RBAC permissions
3. Check network connectivity

### Grafana Dashboard Not Loading

1. Verify Prometheus data source
2. Check dashboard configuration
3. Confirm metrics are available

## 📈 Production Considerations

For production deployment, consider:

- **Persistent storage**: Use PVCs for data retention
- **High availability**: Multiple Prometheus/Grafana replicas
- **External storage**: Remote storage for metrics
- **Security**: TLS, authentication, network policies
- **Backup**: Regular configuration and data backups
- **Alertmanager**: External alerting system
- **Resource limits**: Appropriate CPU/memory limits

## 🔄 Monitoring the Monitors

Monitor the monitoring stack itself:

```promql
# Prometheus health
up{job="prometheus"}

# Grafana availability
up{job="grafana"}

# Metrics ingestion rate
prometheus_tsdb_symbol_table_size_bytes
```

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [Prometheus Node Exporter](https://github.com/prometheus/node_exporter)
- [Kubernetes Monitoring Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
