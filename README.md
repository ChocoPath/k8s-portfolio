# Kubernetes Portfolio Project

A comprehensive Kubernetes portfolio project demonstrating expertise in container orchestration, stateless and stateful applications, and external dependency management.

## 🎯 Project Overview

This project showcases understanding of:
- **Stateless Applications**: Frontend deployment with horizontal scaling
- **Stateful Applications**: Backend StatefulSet with persistent storage
- **External Dependencies**: Database integration and configuration management
- **Kubernetes Best Practices**: Resource management, health checks, secrets, and ConfigMaps

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Database      │
│  (Deployment)   │────│ (StatefulSet)   │────│   (External)    │
│                 │    │                 │    │                 │
│ • Nginx         │    │ • Node.js API   │    │ • PostgreSQL    │
│ • 3 replicas    │    │ • 2 replicas    │    │ • MySQL         │
│ • Stateless     │    │ • Persistent    │    │ • Redis         │
│ • Load Balanced │    │ • Health Checks │    │ • Docker Local  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
k8s-portfolio/
├── manifests/                 # Kubernetes manifests
│   ├── frontend-deployment.yaml    # Stateless frontend deployment
│   ├── backend-statefulset.yaml    # Stateful backend application
│   ├── backend-service.yaml        # Backend services (headless + LoadBalancer)
│   ├── frontend-service.yaml       # Frontend services (LoadBalancer + NodePort)
│   ├── configmap.yaml              # Application configuration
│   └── secret.yaml                 # Sensitive data (passwords, keys)
├── backend/                   # Backend Node.js application
│   ├── src/
│   │   └── server.js              # Express.js API server
│   ├── package.json               # Node.js dependencies
│   └── Dockerfile                 # Container image definition
├── db/                        # Database setup for local development
│   ├── docker-compose.yaml         # Local database services
│   ├── init-scripts/               # Database initialization
│   │   ├── 01-init-postgres.sql    # PostgreSQL schema and data
│   │   └── 02-init-mysql.sql       # MySQL schema and data
│   └── README.md                   # Database setup instructions
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- Docker (for local database development)

### 1. Deploy to Kubernetes

```bash
# Clone the repository
git clone <repository-url>
cd k8s-portfolio

# Apply all manifests
kubectl apply -f manifests/

# Build and load backend image
cd backend
docker build -t portfolio-backend:latest .
kind load docker-image portfolio-backend:latest --name k8s-portfolio

# Check deployment status
kubectl get pods
kubectl get services
```

### 2. Local Database Development

```bash
# Start local databases
cd db
docker-compose up -d

# Verify databases are running
docker-compose ps
```

### 3. Access Applications

```bash
# Get service URLs
kubectl get services

# Frontend access (if using LoadBalancer)
kubectl get service frontend-service

# Backend access
kubectl get service backend-service-lb

# Port forward for local testing
kubectl port-forward service/frontend-service 8080:80
kubectl port-forward service/backend-service-lb 3001:3000
```

## 🎯 Application Details

### Backend API (Node.js)
The backend is a fully functional Express.js API with the following endpoints:

- `GET /` - Welcome message and server info
- `GET /health` - Health check endpoint (used by Kubernetes liveness probe)
- `GET /ready` - Readiness check endpoint (used by Kubernetes readiness probe)
- `GET /api/users` - Returns sample user data
- `GET /api/projects` - Returns sample project data

### Access URLs
- **Frontend**: http://localhost:8080 (Nginx)
- **Backend API**: http://localhost:3001 (Node.js API)
- **Database Admin**: http://localhost:8080 (Adminer - different port)

### Testing the Backend
```bash
# Test the API endpoints
curl http://localhost:3001/
curl http://localhost:3001/health
curl http://localhost:3001/api/users
curl http://localhost:3001/api/projects
```

## 🔧 Configuration

### ConfigMap (`configmap.yaml`)
- Database connection details
- Application settings
- Feature flags
- Environment-specific configurations

### Secrets (`secret.yaml`)
- Database credentials
- JWT secrets
- API keys
- Connection strings

**Note**: The secrets in this repository contain base64-encoded demo values. In production, use proper secret management tools like:
- Kubernetes Secrets with encryption at rest
- External secret management (AWS Secrets Manager, HashiCorp Vault)
- Sealed Secrets or External Secrets Operator

## 📊 Key Features Demonstrated

### 1. Stateless Applications (Frontend)
- **Deployment**: Manages replica sets for scaling
- **Horizontal Scaling**: Multiple replicas for high availability
- **Rolling Updates**: Zero-downtime deployments
- **Resource Limits**: Memory and CPU constraints
- **Health Checks**: Liveness and readiness probes

### 2. Stateful Applications (Backend)
- **StatefulSet**: Ordered deployment and scaling
- **Persistent Storage**: Volume claim templates
- **Stable Network Identity**: Predictable pod names
- **Ordered Scaling**: Sequential pod creation/deletion

### 3. Service Management
- **ClusterIP**: Internal service communication
- **LoadBalancer**: External access to applications
- **NodePort**: Alternative external access method
- **Headless Service**: Direct pod access for StatefulSets

### 4. Configuration Management
- **ConfigMaps**: Non-sensitive configuration data
- **Secrets**: Sensitive information with base64 encoding
- **Environment Variables**: Configuration injection
- **Volume Mounts**: File-based configuration

### 5. Resource Management
- **Resource Requests**: Guaranteed resource allocation
- **Resource Limits**: Maximum resource usage
- **Quality of Service**: Guaranteed QoS class

### 6. Health and Monitoring
- **Liveness Probes**: Container health detection
- **Readiness Probes**: Traffic routing decisions
- **Startup Probes**: Slow-starting container support

## 🛠️ Best Practices Implemented

1. **Security**
   - Non-root containers where possible
   - Resource limits to prevent resource exhaustion
   - Secrets for sensitive data
   - Network policies (can be added)

2. **Reliability**
   - Health checks for all containers
   - Multiple replicas for high availability
   - Graceful shutdown handling
   - Resource requests for guaranteed allocation

3. **Scalability**
   - Horizontal Pod Autoscaler ready
   - Stateless frontend design
   - Proper service abstractions
   - External database for state persistence

4. **Maintainability**
   - Clear resource organization
   - Comprehensive documentation
   - Environment-specific configurations
   - Infrastructure as Code approach

## 🔄 Deployment Scenarios

### Development
```bash
# Use local databases
cd db && docker-compose up -d

# Deploy with development configs
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/secret.yaml
kubectl apply -f manifests/
```

### Production
```bash
# Update ConfigMap for production database endpoints
# Update Secrets with production credentials
# Apply with production-ready configurations
kubectl apply -f manifests/
```

## 📈 Scaling

```bash
# Scale frontend replicas
kubectl scale deployment frontend-deployment --replicas=5

# Scale backend StatefulSet
kubectl scale statefulset backend-statefulset --replicas=3

# Enable HPA (requires metrics server)
kubectl autoscale deployment frontend-deployment --cpu-percent=70 --min=3 --max=10
```

## 🧪 Testing

```bash
# Check pod status
kubectl get pods -o wide

# View logs
kubectl logs -f deployment/frontend-deployment
kubectl logs -f statefulset/backend-statefulset

# Test connectivity
kubectl exec -it <frontend-pod> -- curl backend-service:3000/health
```

## 🚨 Troubleshooting

```bash
# Describe resources for detailed status
kubectl describe deployment frontend-deployment
kubectl describe statefulset backend-statefulset

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug networking
kubectl exec -it <pod-name> -- nslookup backend-service
```

## 🎓 Learning Outcomes

This project demonstrates proficiency in:
- Kubernetes core concepts and resources
- Container orchestration patterns
- Stateful vs stateless application design
- Service discovery and networking
- Configuration and secret management
- Health monitoring and observability
- DevOps best practices
- Infrastructure as Code

## 📚 Technologies Used

- **Container Orchestration**: Kubernetes, kind
- **Containerization**: Docker
- **Frontend**: Nginx (Alpine Linux)
- **Backend**: Node.js, Express.js
- **Databases**: PostgreSQL, MySQL, Redis
- **Configuration**: YAML manifests, ConfigMaps, Secrets
- **Local Development**: Docker Compose
- **Health Monitoring**: Kubernetes probes (liveness, readiness)
- **Storage**: Persistent Volumes, StatefulSets

## 🤝 Contributing

This is a portfolio project, but suggestions for improvements are welcome! Please feel free to:
- Open issues for discussions
- Submit pull requests for enhancements
- Share feedback on architecture decisions

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Note**: This project now includes a fully functional Node.js backend API that demonstrates real application deployment in Kubernetes. The backend includes health checks, API endpoints, and proper resource management. For production use, additional considerations such as monitoring, logging, backup strategies, and security hardening should be implemented.

## 🔄 Current Status

✅ **All services running successfully**:
- Frontend: 3 Nginx replicas serving static content
- Backend: 2 Node.js API replicas with health checks
- Database: PostgreSQL, MySQL, and Redis available locally
- Services: LoadBalancer and NodePort configurations tested

The project demonstrates a complete microservices architecture with stateful and stateless components working together.
