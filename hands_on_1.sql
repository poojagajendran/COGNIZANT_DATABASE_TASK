CREATE DATABASE hostel_db;
USE hostel_db;

CREATE TABLE hostel_blocks (
    block_id INT AUTO_INCREMENT PRIMARY KEY,
    block_name VARCHAR(50) NOT NULL,
    total_rooms INT NOT NULL,
    block_type VARCHAR(20)
);

CREATE TABLE residents (
    resident_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    joining_year INT,
    block_id INT,

    FOREIGN KEY (block_id)
    REFERENCES hostel_blocks(block_id)
);

CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    capacity INT NOT NULL,
    room_type VARCHAR(20),
    block_id INT,

    FOREIGN KEY (block_id)
    REFERENCES hostel_blocks(block_id)
);

CREATE TABLE room_allocations (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    resident_id INT,
    room_id INT,
    allocation_date DATE,
    status VARCHAR(20),

    FOREIGN KEY (resident_id)
    REFERENCES residents(resident_id),

    FOREIGN KEY (room_id)
    REFERENCES rooms(room_id)
);

CREATE TABLE wardens (
    warden_id INT AUTO_INCREMENT PRIMARY KEY,
    warden_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    block_id INT,

    FOREIGN KEY (block_id)
    REFERENCES hostel_blocks(block_id)
);

SHOW TABLES;

DESCRIBE hostel_blocks;
DESCRIBE residents;
DESCRIBE rooms;
DESCRIBE room_allocations;
DESCRIBE wardens;

-- 1NF:
-- All columns contain atomic values.
-- phone_number stores only one phone number.

-- 2NF:
-- All non-key attributes depend fully on the primary key.
-- No partial dependencies exist.

-- 3NF:
-- No transitive dependencies exist.
-- block_name is stored only in hostel_blocks table.

-- room_allocations 3NF Analysis:
-- allocation_date and status depend directly on allocation_id.
-- No non-key attribute depends on another non-key attribute.

ALTER TABLE residents
ADD phone_number VARCHAR(15);

ALTER TABLE rooms
ADD max_capacity INT DEFAULT 4;

ALTER TABLE room_allocations
ADD CONSTRAINT chk_status
CHECK (status IN ('Allocated','Vacated','Pending'));

ALTER TABLE hostel_blocks
RENAME COLUMN block_type TO hostel_type;

ALTER TABLE hostel_blocks
CHANGE block_type hostel_type VARCHAR(20);

ALTER TABLE residents
DROP COLUMN phone_number;


-- Task 3: Alter and Extend Schema

-- Added phone_number column to residents table.
-- Added max_capacity column to rooms table with DEFAULT value.
-- Added CHECK constraint on room allocation status.
-- Renamed block_type column to hostel_type.
-- Dropped phone_number column to simulate schema rollback.
-- Verified all changes using DESCRIBE and INFORMATION_SCHEMA.

show tables
