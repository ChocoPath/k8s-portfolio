-- PostgreSQL initialization script
-- This script will be executed when the PostgreSQL container starts

-- Create database if it doesn't exist (optional, as it's created via environment)
-- CREATE DATABASE IF NOT EXISTS portfolio_db;

-- Switch to the portfolio database
\c portfolio_db;

-- Create tables for the portfolio application
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    github_url VARCHAR(500),
    demo_url VARCHAR(500),
    technologies TEXT[], -- Array of technologies used
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS skills (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL, -- frontend, backend, devops, database, etc.
    proficiency_level INTEGER CHECK (proficiency_level >= 1 AND proficiency_level <= 10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_skills (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
    years_experience INTEGER DEFAULT 0,
    UNIQUE(user_id, skill_id)
);

CREATE TABLE IF NOT EXISTS blog_posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(300) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_featured ON projects(featured);
CREATE INDEX idx_user_skills_user_id ON user_skills(user_id);
CREATE INDEX idx_blog_posts_user_id ON blog_posts(user_id);
CREATE INDEX idx_blog_posts_published ON blog_posts(published);
CREATE INDEX idx_blog_posts_slug ON blog_posts(slug);

-- Insert sample data
INSERT INTO users (username, email, password_hash) VALUES 
('john_doe', 'john@example.com', '$2b$10$N9qo8uLOickgx2ZMRZoMye7FRNpHR/7/GX8jNq2Yz8W6Uz4RUaLni'),
('jane_smith', 'jane@example.com', '$2b$10$N9qo8uLOickgx2ZMRZoMye7FRNpHR/7/GX8jNq2Yz8W6Uz4RUaLni');

INSERT INTO skills (name, category, proficiency_level) VALUES 
('JavaScript', 'frontend', 9),
('React', 'frontend', 8),
('Node.js', 'backend', 8),
('PostgreSQL', 'database', 7),
('Docker', 'devops', 8),
('Kubernetes', 'devops', 7),
('Python', 'backend', 6),
('AWS', 'cloud', 7);

INSERT INTO projects (user_id, title, description, github_url, technologies, featured) VALUES 
(1, 'Kubernetes Portfolio', 'A portfolio application showcasing Kubernetes deployment skills', 'https://github.com/johndoe/k8s-portfolio', ARRAY['Kubernetes', 'Docker', 'Node.js', 'PostgreSQL'], true),
(1, 'Microservices E-commerce', 'Full-stack e-commerce platform using microservices architecture', 'https://github.com/johndoe/microservices-ecommerce', ARRAY['Node.js', 'React', 'MongoDB', 'Redis', 'Docker'], false);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update the updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_blog_posts_updated_at BEFORE UPDATE ON blog_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
