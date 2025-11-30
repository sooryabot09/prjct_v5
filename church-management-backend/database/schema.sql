-- Church Management System Database Schema
-- MySQL 8.0+

-- Create database
CREATE DATABASE IF NOT EXISTS church_management_system;
USE church_management_system;

-- User Roles Table
CREATE TABLE IF NOT EXISTS user_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default roles
INSERT INTO user_roles (name, description) VALUES
    ('PARISHIONER', 'Regular church member'),
    ('PRIEST', 'Church priest'),
    ('CHURCH_ADMIN', 'Church administrator'),
    ('DIOCESE_ADMIN', 'Diocese administrator'),
    ('SUPER_ADMIN', 'System super administrator')
ON DUPLICATE KEY UPDATE name=name;

-- Diocese Table
CREATE TABLE IF NOT EXISTS dioceses (
    diocese_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(10) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Forane Table
CREATE TABLE IF NOT EXISTS foranes (
    forane_id INT AUTO_INCREMENT PRIMARY KEY,
    diocese_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (diocese_id) REFERENCES dioceses(diocese_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Churches Table
CREATE TABLE IF NOT EXISTS churches (
    church_id INT AUTO_INCREMENT PRIMARY KEY,
    forane_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    bank_account VARCHAR(100),
    qr_code_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (forane_id) REFERENCES foranes(forane_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role_id INT NOT NULL DEFAULT 1,
    church_id INT,
    birthday DATE,
    ordination_date DATE,
    feast_date DATE,
    motto TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(role_id) ON DELETE RESTRICT,
    FOREIGN KEY (church_id) REFERENCES churches(church_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Beneficiary Types Table
CREATE TABLE IF NOT EXISTS beneficiary_types (
    beneficiary_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default beneficiary types
INSERT INTO beneficiary_types (name, description) VALUES
    ('PRIEST', 'Priest benefit'),
    ('CHURCH', 'Church benefit'),
    ('DIOCESE', 'Diocese benefit'),
    ('CHARITY', 'Charity benefit')
ON DUPLICATE KEY UPDATE name=name;

-- Services Table
CREATE TABLE IF NOT EXISTS services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    church_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    amount_paise INT NOT NULL DEFAULT 0, -- Store in paise (smallest currency unit)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (church_id) REFERENCES churches(church_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Split Config Table
CREATE TABLE IF NOT EXISTS split_config (
    split_config_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    beneficiary_type_id INT NOT NULL,
    percentage INT NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (beneficiary_type_id) REFERENCES beneficiary_types(beneficiary_type_id) ON DELETE CASCADE,
    UNIQUE KEY unique_service_beneficiary (service_id, beneficiary_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Booking Statuses Table
CREATE TABLE IF NOT EXISTS booking_statuses (
    booking_status_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default booking statuses
INSERT INTO booking_statuses (name, description) VALUES
    ('PENDING', 'Booking is pending'),
    ('CONFIRMED', 'Booking is confirmed'),
    ('CANCELLED', 'Booking is cancelled'),
    ('COMPLETED', 'Booking is completed')
ON DUPLICATE KEY UPDATE name=name;

-- Bookings Table
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    parishioner_id INT NOT NULL,
    church_id INT NOT NULL,
    priest_id INT,
    amount_paise INT NOT NULL,
    status_id INT NOT NULL DEFAULT 1,
    payment_method VARCHAR(50),
    payment_id VARCHAR(255),
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
    FOREIGN KEY (parishioner_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (church_id) REFERENCES churches(church_id) ON DELETE RESTRICT,
    FOREIGN KEY (priest_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (status_id) REFERENCES booking_statuses(booking_status_id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Entity Types Table (for events)
CREATE TABLE IF NOT EXISTS entity_types (
    entity_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default entity types
INSERT INTO entity_types (name, description) VALUES
    ('PRIEST', 'Priest entity'),
    ('CHURCH', 'Church entity'),
    ('DIOCESE', 'Diocese entity')
ON DUPLICATE KEY UPDATE name=name;

-- Event Visibility Table
CREATE TABLE IF NOT EXISTS event_visibility (
    event_visibility_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default visibility types
INSERT INTO event_visibility (name, description) VALUES
    ('PUBLIC', 'Public event visible to all'),
    ('PRIVATE', 'Private event visible only to creator'),
    ('CHURCH', 'Visible only to church members')
ON DUPLICATE KEY UPDATE name=name;

-- Events Table
CREATE TABLE IF NOT EXISTS events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type_id INT NOT NULL,
    entity_id INT NOT NULL,
    title VARCHAR(255),
    description TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    visibility_id INT NOT NULL DEFAULT 1,
    is_busy BOOLEAN DEFAULT FALSE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (entity_type_id) REFERENCES entity_types(entity_type_id) ON DELETE RESTRICT,
    FOREIGN KEY (visibility_id) REFERENCES event_visibility(event_visibility_id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Complaint Statuses Table
CREATE TABLE IF NOT EXISTS complaint_statuses (
    complaint_status_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default complaint statuses
INSERT INTO complaint_statuses (name, description) VALUES
    ('OPEN', 'Complaint is open'),
    ('IN_PROGRESS', 'Complaint is being processed'),
    ('RESOLVED', 'Complaint is resolved'),
    ('CLOSED', 'Complaint is closed')
ON DUPLICATE KEY UPDATE name=name;

-- Complaints Table
CREATE TABLE IF NOT EXISTS complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    booking_id INT,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    status_id INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL,
    FOREIGN KEY (status_id) REFERENCES complaint_statuses(complaint_status_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    amount_paise INT NOT NULL,
    method VARCHAR(50) NOT NULL DEFAULT 'CASH',
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    payment_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    details JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_church ON users(church_id);
CREATE INDEX idx_bookings_status ON bookings(status_id);
CREATE INDEX idx_bookings_parishioner ON bookings(parishioner_id);
CREATE INDEX idx_bookings_church ON bookings(church_id);
CREATE INDEX idx_events_entity ON events(entity_type_id, entity_id);
CREATE INDEX idx_events_time ON events(start_time, end_time);
CREATE INDEX idx_complaints_user ON complaints(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

