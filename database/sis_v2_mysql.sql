-- MySQL/MariaDB import for phpMyAdmin.
-- Creates the schema used by the Flutter SIS V2 SQLite application.
CREATE DATABASE IF NOT EXISTS sis_v2
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sis_v2;

CREATE TABLE IF NOT EXISTS courses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_code VARCHAR(50) NOT NULL UNIQUE,
  course_name VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  section_name VARCHAR(100) NOT NULL,
  year_level INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id VARCHAR(100) NOT NULL UNIQUE,
  first_name VARCHAR(100) NOT NULL,
  middle_name VARCHAR(100) NOT NULL DEFAULT '',
  last_name VARCHAR(100) NOT NULL,
  gender VARCHAR(50) NOT NULL,
  birth_date DATE NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  address TEXT NOT NULL,
  course_id INT NOT NULL,
  year_level INT NOT NULL,
  section_id INT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'Active',
  date_enrolled DATE NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_students_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_students_section FOREIGN KEY (section_id) REFERENCES sections(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(100) NOT NULL,
  entity VARCHAR(100) NOT NULL,
  entity_id VARCHAR(100) NULL,
  details TEXT NULL,
  created_at DATETIME NOT NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO courses (course_code, course_name) VALUES
  ('BSIT', 'Bachelor of Science in Information Technology'),
  ('BSCS', 'Bachelor of Science in Computer Science'),
  ('BSEMC', 'Bachelor of Science in Entertainment and Multimedia Computing');

INSERT IGNORE INTO sections (section_name, year_level) VALUES
  ('A', 1), ('B', 2), ('C', 3), ('D', 4);

INSERT IGNORE INTO users (username, password_hash, role, created_at) VALUES
  ('admin', 'admin123', 'admin', NOW()),
  ('faculty', 'faculty123', 'faculty', NOW()),
  ('student', 'student123', 'student', NOW());