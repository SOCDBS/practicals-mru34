-- Practical Transactions, Section A
-- Run each numbered transaction in order.

-- 1. Increase every backup staff member's hourly rate and keep the change.
BEGIN;

UPDATE staff_backup
SET hourly_rate = hourly_rate + 20;

COMMIT;

-- 2. Change staff numbers beginning with S to A, inspect them, then undo.
BEGIN;

UPDATE staff_backup
SET staff_no = OVERLAY(staff_no PLACING 'A' FROM 1 FOR 1)
WHERE staff_no LIKE 'S%';

SELECT staff_no, staff_name
FROM staff_backup
ORDER BY staff_no;

ROLLBACK;

SELECT staff_no, staff_name
FROM staff_backup
ORDER BY staff_no;

-- 3. Keep the S-to-B change, but undo the additional $30 hourly-rate change.
BEGIN;

SAVEPOINT before_staff_number_change;

UPDATE staff_backup
SET staff_no = OVERLAY(staff_no PLACING 'B' FROM 1 FOR 1)
WHERE staff_no LIKE 'S%';

SAVEPOINT before_hourly_rate_change;

UPDATE staff_backup
SET hourly_rate = hourly_rate + 30;

ROLLBACK TO SAVEPOINT before_hourly_rate_change;

SELECT staff_no, staff_name, hourly_rate
FROM staff_backup
ORDER BY staff_no;

COMMIT;
