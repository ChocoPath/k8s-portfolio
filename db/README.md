# Database Setup Scripts

This directory contains database initialization scripts and Docker Compose configuration for local development.

## Quick Start

### Using Docker Compose (Recommended for local development)

1. **Start all services:**
   ```bash
   docker-compose up -d
   ```

2. **Start specific database:**
   ```bash
   # PostgreSQL only
   docker-compose up -d postgres
   
   # MySQL only
   docker-compose up -d mysql
   
   # Redis only
   docker-compose up -d redis
   ```

3. **Access databases:**
   - **PostgreSQL**: `localhost:5432`
     - Database: `portfolio_db`
     - Username: `admin`
     - Password: `secretpassword`
   
   - **MySQL**: `localhost:3306`
     - Database: `portfolio_db`
     - Username: `admin`
     - Password: `secretpassword`
   
   - **Redis**: `localhost:6379`
   
   - **Adminer** (Web DB client): `http://localhost:8080`

4. **Stop services:**
   ```bash
   docker-compose down
   ```

5. **Clean up (remove volumes):**
   ```bash
   docker-compose down -v
   ```

## Database Schema

The initialization scripts create the following tables:
- `users` - User accounts
- `projects` - Portfolio projects
- `skills` - Available skills/technologies
- `user_skills` - Many-to-many relationship between users and skills
- `blog_posts` - Blog posts/articles

## Environment Variables

You can customize the database configuration by creating a `.env` file:

```env
# PostgreSQL
POSTGRES_DB=portfolio_db
POSTGRES_USER=admin
POSTGRES_PASSWORD=secretpassword

# MySQL
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=portfolio_db
MYSQL_USER=admin
MYSQL_PASSWORD=secretpassword
```

## Connecting from Kubernetes

When deploying to Kubernetes, the applications will connect to external databases or database services within the cluster. Update the ConfigMap and Secret values accordingly.

## Health Checks

All database services include health checks:
- PostgreSQL: `pg_isready`
- MySQL: `mysqladmin ping`
- Redis: `redis-cli ping`
