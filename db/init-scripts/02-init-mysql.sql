-- MySQL initialization script
-- This script will be executed when the MySQL container starts

USE portfolio_db;

-- Create tables for the portfolio application
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    github_url VARCHAR(500),
    demo_url VARCHAR(500),
    technologies JSON, -- Store technologies as JSON array
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    proficiency_level INT CHECK (proficiency_level >= 1 AND proficiency_level <= 10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    skill_id INT,
    years_experience INT DEFAULT 0,
    UNIQUE(user_id, skill_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS blog_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(300) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
('MySQL', 'database', 7),
('Docker', 'devops', 8),
('Kubernetes', 'devops', 7),
('Python', 'backend', 6),
('AWS', 'cloud', 7);

INSERT INTO projects (user_id, title, description, github_url, technologies, featured) VALUES 
(1, 'Kubernetes Portfolio', 'A portfolio application showcasing Kubernetes deployment skills', 'https://github.com/johndoe/k8s-portfolio', JSON_ARRAY('Kubernetes', 'Docker', 'Node.js', 'MySQL'), true),
(1, 'Microservices E-commerce', 'Full-stack e-commerce platform using microservices architecture', 'https://github.com/johndoe/microservices-ecommerce', JSON_ARRAY('Node.js', 'React', 'MongoDB', 'Redis', 'Docker'), false);
