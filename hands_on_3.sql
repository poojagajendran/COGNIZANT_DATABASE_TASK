-- =========================================
-- HANDS-ON 3
-- Task 1: Subqueries
-- Smart Hostel Management System
-- =========================================

-- 35. Find residents who have more room allocations
-- than the average allocations per resident.

SELECT r.resident_id,
CONCAT(r.first_name,' ',r.last_name) AS resident_name
FROM residents r
JOIN room_allocations ra
ON r.resident_id = ra.resident_id
GROUP BY r.resident_id, resident_name
HAVING COUNT(*) >
(
SELECT AVG(allocation_count)
FROM
(
SELECT COUNT(*) AS allocation_count
FROM room_allocations
GROUP BY resident_id
) avg_table
);

-- 36. List rooms where all allocations have status 'Allocated'

SELECT rm.room_number
FROM rooms rm
WHERE NOT EXISTS
(
SELECT *
FROM room_allocations ra
WHERE ra.room_id = rm.room_id
AND ra.status <> 'Allocated'
);

-- 37. Find the highest-paid warden in each hostel block

SELECT w1.*
FROM wardens w1
WHERE salary =
(
SELECT MAX(w2.salary)
FROM wardens w2
WHERE w2.block_id = w1.block_id
);

-- 38. Find blocks whose average warden salary
-- exceeds 50000 using a derived table

SELECT *
FROM
(
SELECT h.block_name,
ROUND(AVG(w.salary),2) AS avg_salary
FROM hostel_blocks h
JOIN wardens w
ON h.block_id = w.block_id
GROUP BY h.block_id, h.block_name
) block_avg
WHERE avg_salary > 50000;
DESCRIBE residents;
DESCRIBE hostel_blocks;
DESCRIBE room_allocations;

DROP VIEW IF EXISTS vw_resident_allocation_summary;

CREATE VIEW vw_resident_allocation_summary AS
SELECT
    r.resident_id,
    CONCAT(r.first_name, ' ', r.last_name) AS resident_name,
    h.block_name,
    COUNT(ra.allocation_id) AS total_allocations
FROM residents r
LEFT JOIN hostel_blocks h
    ON r.block_id = h.block_id
LEFT JOIN room_allocations ra
    ON r.resident_id = ra.resident_id
GROUP BY
    r.resident_id,
    r.first_name,
    r.last_name,
    h.block_name;
    
    CREATE TABLE IF NOT EXISTS department_transfer_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    resident_id INT,
    old_block_id INT,
    new_block_id INT,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS sp_allocate_resident;

DELIMITER $$

CREATE PROCEDURE sp_allocate_resident(
    IN p_resident_id INT,
    IN p_room_id INT,
    IN p_allocation_date DATE
)
BEGIN

    IF EXISTS (
        SELECT 1
        FROM room_allocations
        WHERE resident_id = p_resident_id
          AND room_id = p_room_id
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Resident already allocated to this room';
    ELSE
        INSERT INTO room_allocations
        (
            resident_id,
            room_id,
            allocation_date,
            status
        )
        VALUES
        (
            p_resident_id,
            p_room_id,
            p_allocation_date,
            'Allocated'
        );
    END IF;

END$$

DELIMITER ;
SELECT * FROM department_transfer_log;

START TRANSACTION;

UPDATE residents
SET block_id = 999
WHERE resident_id = 1;

ROLLBACK;

SELECT *
FROM residents
WHERE resident_id = 1;

START TRANSACTION;

INSERT INTO room_allocations
(
    resident_id,
    room_id,
    allocation_date,
    status
)
VALUES
(
    1,
    1,
    CURDATE(),
    'Allocated'
);

SAVEPOINT first_insert;

-- Deliberate error (invalid foreign keys)
INSERT INTO room_allocations
(
    resident_id,
    room_id,
    allocation_date,
    status
)
VALUES
(
    999,
    999,
    CURDATE(),
    'Allocated'
);

ROLLBACK TO first_insert;

COMMIT;

SELECT * FROM room_allocations;