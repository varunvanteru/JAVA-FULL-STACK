-- =========================================================
--  CodeQuest - Programming Learning Game
--  Database script (MySQL 8)
--  Run this whole file once in MySQL Workbench (lightning icon)
-- =========================================================

DROP DATABASE IF EXISTS codequest_db;
CREATE DATABASE codequest_db;
USE codequest_db;

-- ---------------------------------------------------------
-- Table 1: users  (student registration and progress)
-- ---------------------------------------------------------
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    total_xp      INT DEFAULT 0,
    player_level  INT DEFAULT 1,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- Table 2: admins  (administrator login details)
-- ---------------------------------------------------------
CREATE TABLE admins (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    username  VARCHAR(50)  NOT NULL UNIQUE,
    password  VARCHAR(255) NOT NULL
);

-- ---------------------------------------------------------
-- Table 3: missions  (programming questions created by Admin)
-- ---------------------------------------------------------
CREATE TABLE missions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(100) NOT NULL,
    description     TEXT         NOT NULL,
    category        VARCHAR(30)  NOT NULL,   -- Java, SQL, DSA
    difficulty      VARCHAR(20)  NOT NULL,   -- Easy, Medium, Hard
    option_a        VARCHAR(255) NOT NULL,
    option_b        VARCHAR(255) NOT NULL,
    option_c        VARCHAR(255) NOT NULL,
    option_d        VARCHAR(255) NOT NULL,
    correct_answer  VARCHAR(255) NOT NULL,
    xp_reward       INT DEFAULT 50,
    created_by      INT,
    CONSTRAINT fk_missions_admin
        FOREIGN KEY (created_by) REFERENCES admins(id)
        ON DELETE SET NULL
);

-- ---------------------------------------------------------
-- Table 4: mission_submissions  (student answers)
-- One attempt per mission per student -> UNIQUE(user_id, mission_id)
-- ---------------------------------------------------------
CREATE TABLE mission_submissions (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    mission_id    INT NOT NULL,
    answer        VARCHAR(255) NOT NULL,
    is_correct    BOOLEAN DEFAULT FALSE,
    completed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sub_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_sub_mission
        FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE,
    CONSTRAINT uq_one_attempt UNIQUE (user_id, mission_id)
);

-- ---------------------------------------------------------
-- Default admin account
--   username: admin
--   password: admin123   (stored as a SHA-256 hash)
-- ---------------------------------------------------------
INSERT INTO admins (username, password)
VALUES ('admin', SHA2('admin123', 256));

-- ---------------------------------------------------------
-- Sample missions (optional - you can also add them from the
-- Admin "Add Question" page)
-- ---------------------------------------------------------
INSERT INTO missions (title, description, category, difficulty,
                      option_a, option_b, option_c, option_d,
                      correct_answer, xp_reward, created_by) VALUES
('Java Entry Point',
 'Which method is the entry point of every standalone Java application?',
 'Java', 'Easy',
 'start()', 'main()', 'run()', 'init()',
 'main()', 50, 1),
('SQL Data Retrieval',
 'Which SQL keyword is used to retrieve rows from a table?',
 'SQL', 'Easy',
 'GET', 'FETCH', 'SELECT', 'OPEN',
 'SELECT', 50, 1),
('Stack Behaviour',
 'Which principle does a Stack data structure follow?',
 'DSA', 'Medium',
 'FIFO', 'LIFO', 'Random access', 'Priority based',
 'LIFO', 75, 1);

-- Quick check
SELECT * FROM admins;
SELECT id, title, category, difficulty, xp_reward FROM missions;
