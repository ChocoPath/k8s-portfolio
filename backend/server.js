const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
const client = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// Create a Registry to register the metrics
const register = new client.Registry();

// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: 'portfolio-backend',
  version: '1.0.0'
});

// Enable the collection of default metrics
client.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

const activeConnections = new client.Gauge({
  name: 'http_active_connections',
  help: 'Number of active HTTP connections'
});

// Register custom metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(activeConnections);

// Middleware to track active connections
app.use((req, res, next) => {
  activeConnections.inc();
  res.on('finish', () => {
    activeConnections.dec();
  });
  next();
});

// Middleware to track request metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, route, res.statusCode)
      .inc();
  });
  
  next();
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Environment variables
const NODE_ENV = process.env.NODE_ENV || 'development';
const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_USER = process.env.DB_USER || 'admin';
const DB_PASSWORD = process.env.DB_PASSWORD || 'secretpassword';
const DB_NAME = process.env.DB_NAME || 'portfolio_db';

// Data directory for StatefulSet persistence
const DATA_DIR = '/app/data';

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

// In-memory storage for demo (in real app, this would be in database)
let portfolioData = {
  projects: [
    {
      id: 1,
      title: 'Kubernetes Portfolio',
      description: 'A comprehensive Kubernetes portfolio demonstrating stateless and stateful applications',
      technologies: ['Kubernetes', 'Docker', 'Node.js', 'PostgreSQL'],
      featured: true,
      github_url: 'https://github.com/portfolio/k8s-portfolio'
    },
    {
      id: 2,
      title: 'Microservices E-commerce',
      description: 'Full-stack e-commerce platform using microservices architecture',
      technologies: ['Node.js', 'React', 'MongoDB', 'Redis', 'Docker'],
      featured: false,
      github_url: 'https://github.com/portfolio/microservices-ecommerce'
    }
  ],
  skills: [
    { id: 1, name: 'Kubernetes', category: 'devops', proficiency: 8 },
    { id: 2, name: 'Docker', category: 'devops', proficiency: 9 },
    { id: 3, name: 'Node.js', category: 'backend', proficiency: 8 },
    { id: 4, name: 'React', category: 'frontend', proficiency: 7 },
    { id: 5, name: 'PostgreSQL', category: 'database', proficiency: 7 }
  ]
};

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: NODE_ENV,
    pod: process.env.HOSTNAME || 'unknown'
  });
});

app.get('/ready', (req, res) => {
  // In a real app, check database connectivity, etc.
  res.status(200).json({ 
    status: 'ready',
    timestamp: new Date().toISOString(),
    database: {
      host: DB_HOST,
      database: DB_NAME,
      status: 'simulated_connected'
    }
  });
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    const metrics = await register.metrics();
    res.end(metrics);
  } catch (error) {
    res.status(500).end(error);
  }
});

// API endpoints
app.get('/api/projects', (req, res) => {
  try {
    res.json({
      success: true,
      data: portfolioData.projects,
      count: portfolioData.projects.length
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/projects/:id', (req, res) => {
  try {
    const project = portfolioData.projects.find(p => p.id === parseInt(req.params.id));
    if (!project) {
      return res.status(404).json({ success: false, error: 'Project not found' });
    }
    res.json({ success: true, data: project });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/skills', (req, res) => {
  try {
    res.json({
      success: true,
      data: portfolioData.skills,
      count: portfolioData.skills.length
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Statistics endpoint
app.get('/api/stats', (req, res) => {
  try {
    const stats = {
      totalProjects: portfolioData.projects.length,
      featuredProjects: portfolioData.projects.filter(p => p.featured).length,
      totalSkills: portfolioData.skills.length,
      categories: [...new Set(portfolioData.skills.map(s => s.category))],
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      environment: {
        nodeEnv: NODE_ENV,
        nodeVersion: process.version,
        platform: process.platform,
        hostname: process.env.HOSTNAME || 'unknown'
      }
    };
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Persistence endpoint (demonstrates StatefulSet data persistence)
app.post('/api/data/save', (req, res) => {
  try {
    const { key, value } = req.body;
    const filePath = path.join(DATA_DIR, `${key}.json`);
    fs.writeFileSync(filePath, JSON.stringify(value, null, 2));
    res.json({ 
      success: true, 
      message: `Data saved to ${filePath}`,
      pod: process.env.HOSTNAME || 'unknown'
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/data/:key', (req, res) => {
  try {
    const filePath = path.join(DATA_DIR, `${req.params.key}.json`);
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ success: false, error: 'Data not found' });
    }
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    res.json({ 
      success: true, 
      data,
      pod: process.env.HOSTNAME || 'unknown'
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'K8s Portfolio Backend',
    version: '1.0.0',
    environment: NODE_ENV,
    pod: process.env.HOSTNAME || 'unknown',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      ready: '/ready',
      projects: '/api/projects',
      skills: '/api/skills',
      stats: '/api/stats'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    success: false, 
    error: 'Internal server error',
    pod: process.env.HOSTNAME || 'unknown'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    error: 'Endpoint not found',
    pod: process.env.HOSTNAME || 'unknown'
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 K8s Portfolio Backend running on port ${PORT}`);
  console.log(`📊 Environment: ${NODE_ENV}`);
  console.log(`🗄️  Database: ${DB_HOST}/${DB_NAME}`);
  console.log(`📂 Data directory: ${DATA_DIR}`);
  console.log(`🏠 Pod: ${process.env.HOSTNAME || 'unknown'}`);
});
