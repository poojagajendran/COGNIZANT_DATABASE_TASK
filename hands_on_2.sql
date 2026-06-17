USE hostel_db;


INSERT INTO hostel_blocks (block_name, total_rooms, hostel_type)
VALUES
('A Block', 50, 'Boys'),
('B Block', 40, 'Girls'),
('C Block', 30, 'Boys');

-- residents
INSERT INTO residents
(first_name, last_name, email, joining_year, block_id)
VALUES
('Arun', 'Kumar', '[arun@gmail.com](mailto:arun@gmail.com)', 2023, 1),
('Priya', 'Sharma', '[priya@gmail.com](mailto:priya@gmail.com)', 2023, 2),
('Rahul', 'Singh', '[rahul@gmail.com](mailto:rahul@gmail.com)', 2022, 1),
('Sneha', 'Reddy', '[sneha@gmail.com](mailto:sneha@gmail.com)', 2024, 2),
('Vikram', 'Das', '[vikram@gmail.com](mailto:vikram@gmail.com)', 2023, 3);

-- rooms
INSERT INTO rooms
(room_number, capacity, room_type, block_id, max_capacity)
VALUES
('A101', 2, 'AC', 1, 4),
('A102', 3, 'Non-AC', 1, 4),
('B101', 2, 'AC', 2, 4),
('C101', 4, 'Non-AC', 3, 4);

-- room_allocations
INSERT INTO room_allocations
(resident_id, room_id, allocation_date, status)
VALUES
(1, 1, '2024-06-01', 'Allocated'),
(2, 3, '2024-06-02', 'Allocated'),
(3, 2, '2024-06-03', 'Allocated'),
(4, 3, '2024-06-04', NULL),
(5, 4, '2024-06-05', 'Allocated');

-- wardens
INSERT INTO wardens
(warden_name, email, salary, block_id)
VALUES
('Mr. Rajesh', '[rajesh@hostel.com](mailto:rajesh@hostel.com)', 50000, 1),
('Mrs. Lakshmi', '[lakshmi@hostel.com](mailto:lakshmi@hostel.com)', 52000, 2),
('Mr. Karthik', '[karthik@hostel.com](mailto:karthik@hostel.com)', 51000, 3);

-- STEP 16: Insert two additional residents

INSERT INTO residents
(first_name, last_name, email, joining_year, block_id)
VALUES
('Ajay', 'Verma', '[ajay@gmail.com](mailto:ajay@gmail.com)', 2024, 1),
('Meena', 'Patel', '[meena@gmail.com](mailto:meena@gmail.com)', 2024, 2);

-- Verify resident count

SELECT COUNT(*) AS total_residents
FROM residents;

-- STEP 17: Update allocation status

UPDATE room_allocations
SET status = 'Vacated'
WHERE resident_id = 5
AND room_id = 4;

-- Verify update

SELECT *
FROM room_allocations
WHERE resident_id = 5
AND room_id = 4;

-- STEP 18: Preview rows with NULL status

SELECT *
FROM room_allocations
WHERE status IS NULL;

-- Delete rows with NULL status

DELETE FROM room_allocations
WHERE status IS NULL;

-- STEP 19: Verify row counts

SELECT COUNT(*) AS total_blocks
FROM hostel_blocks;

SELECT COUNT(*) AS total_residents
FROM residents;

SELECT COUNT(*) AS total_rooms
FROM rooms;

SELECT COUNT(*) AS total_allocations
FROM room_allocations;

SELECT COUNT(*) AS total_wardens
FROM wardens;

-- =========================================
-- Task 2: Single Table Queries and Filtering
-- Smart Hostel Management System
-- =========================================

-- 20. Retrieve all residents who joined in 2023,
-- ordered by last_name alphabetically.

SELECT *
FROM residents
WHERE joining_year = 2023
ORDER BY last_name ASC;

-- 21. Find all rooms with capacity greater than 2,
-- sorted by capacity descending.

SELECT *
FROM rooms
WHERE capacity > 2
ORDER BY capacity DESC;

-- 22. List all wardens whose salary is between
-- 50,000 and 55,000.

SELECT *
FROM wardens
WHERE salary BETWEEN 50000 AND 55000;

-- 23. Find all residents whose email ends with
-- '@gmail.com' using LIKE.

SELECT *
FROM residents
WHERE email LIKE '%@gmail.com';

-- 24. Count total residents per joining year.

SELECT joining_year,
COUNT(*) AS total_residents
FROM residents
GROUP BY joining_year
ORDER BY joining_year;

-- =========================================
-- Task 3: Multi-Table Joins
-- Smart Hostel Management System
-- =========================================

-- 25. List each resident's full name along with
-- the hostel block they belong to.

SELECT CONCAT(r.first_name, ' ', r.last_name) AS resident_name,
h.block_name
FROM residents r
INNER JOIN hostel_blocks h
ON r.block_id = h.block_id;

-- 26. Show each room allocation along with
-- resident name and room number.

SELECT ra.allocation_id,
CONCAT(r.first_name, ' ', r.last_name) AS resident_name,
rm.room_number,
ra.allocation_date,
ra.status
FROM room_allocations ra
INNER JOIN residents r
ON ra.resident_id = r.resident_id
INNER JOIN rooms rm
ON ra.room_id = rm.room_id;

-- 27. Find all residents who are NOT allocated
-- to any room.

SELECT r.resident_id,
CONCAT(r.first_name, ' ', r.last_name) AS resident_name
FROM residents r
LEFT JOIN room_allocations ra
ON r.resident_id = ra.resident_id
WHERE ra.resident_id IS NULL;

-- 28. Display every room along with the number
-- of residents allocated to it.
-- Rooms with zero allocations should also appear.

SELECT rm.room_number,
COUNT(ra.resident_id) AS resident_count
FROM rooms rm
LEFT JOIN room_allocations ra
ON rm.room_id = ra.room_id
GROUP BY rm.room_id, rm.room_number
ORDER BY rm.room_number;

-- 29. List each hostel block along with its
-- wardens and their salaries.
-- Include blocks with no wardens.

SELECT h.block_name,
w.warden_name,
w.salary
FROM hostel_blocks h
LEFT JOIN wardens w
ON h.block_id = w.block_id
ORDER BY h.block_name;

-- =========================================
-- Task 4: Aggregations and Grouping
-- Smart Hostel Management System
-- =========================================

-- 30. Calculate total room allocations per room.
-- Display room_number and allocation_count.

SELECT rm.room_number,
COUNT(ra.allocation_id) AS allocation_count
FROM rooms rm
LEFT JOIN room_allocations ra
ON rm.room_id = ra.room_id
GROUP BY rm.room_id, rm.room_number
ORDER BY allocation_count DESC;

-- 31. Find the average salary of wardens per hostel block.
-- Round to 2 decimal places.

SELECT h.block_name,
ROUND(AVG(w.salary), 2) AS avg_salary
FROM hostel_blocks h
LEFT JOIN wardens w
ON h.block_id = w.block_id
GROUP BY h.block_id, h.block_name;

-- 32. Find hostel blocks where the total room capacity
-- exceeds 50.

SELECT h.block_name,
SUM(r.capacity) AS total_capacity
FROM hostel_blocks h
JOIN rooms r
ON h.block_id = r.block_id
GROUP BY h.block_id, h.block_name
HAVING SUM(r.capacity) > 50;

-- 33. Show allocation status distribution.
-- Count of Allocated, Vacated, Pending.

SELECT status,
COUNT(*) AS status_count
FROM room_allocations
GROUP BY status
ORDER BY status_count DESC;

-- 34. Using HAVING, list hostel blocks where
-- more than 2 residents are staying.

SELECT h.block_name,
COUNT(r.resident_id) AS resident_count
FROM hostel_blocks h
JOIN residents r
ON h.block_id = r.block_id
GROUP BY h.block_id, h.block_name
HAVING COUNT(r.resident_id) > 2;
