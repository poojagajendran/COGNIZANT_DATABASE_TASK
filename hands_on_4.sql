USE hostel_db;

EXPLAIN FORMAT=JSON
SELECT
    r.first_name,
    r.last_name,
    rm.room_number
FROM room_allocations ra
JOIN residents r
    ON r.resident_id = ra.resident_id
JOIN rooms rm
    ON rm.room_id = ra.room_id
WHERE r.joining_year = 2023;

EXPLAIN
SELECT
    r.first_name,
    r.last_name,
    rm.room_number
FROM room_allocations ra
JOIN residents r
    ON r.resident_id = ra.resident_id
JOIN rooms rm
    ON rm.room_id = ra.room_id
WHERE r.joining_year = 2023;

USE hostel_db;

-- =====================================================
-- HANDS-ON 4 : TASK 2
-- ADD INDEXES AND COMPARE PLANS
-- =====================================================

-- 51. Create index on residents.joining_year

CREATE INDEX idx_residents_joining_year
ON residents(joining_year);

-- -----------------------------------------------------

-- 52. Create composite UNIQUE index on
-- room_allocations(resident_id, room_id)

CREATE UNIQUE INDEX idx_unique_allocation
ON room_allocations(resident_id, room_id);

-- -----------------------------------------------------

-- 53. Create index on rooms.room_number

CREATE INDEX idx_room_number
ON rooms(room_number);

-- -----------------------------------------------------

-- 54. Re-run EXPLAIN

EXPLAIN
SELECT
    r.first_name,
    r.last_name,
    rm.room_number
FROM room_allocations ra
JOIN residents r
    ON r.resident_id = ra.resident_id
JOIN rooms rm
    ON rm.room_id = ra.room_id
WHERE r.joining_year = 2023;

-- -----------------------------------------------------

-- Analysis Comments

-- Before Index:
-- type = ALL
-- Full Table Scan on residents table.

-- After Index:
-- MySQL may use:
-- idx_residents_joining_year

-- Expected Improvement:
-- Full Table Scan -> Index Lookup / Ref Scan
-- Fewer rows examined
-- Better performance for large datasets.

-- -----------------------------------------------------

-- 55. MySQL Alternative for Partial Index

-- PostgreSQL supports:
-- CREATE INDEX ... WHERE status IS NULL

-- MySQL does not support partial indexes directly.

-- Alternative:
CREATE INDEX idx_room_status
ON room_allocations(status);

-- This helps queries such as:

SELECT *
FROM room_allocations
WHERE status IS NULL;

