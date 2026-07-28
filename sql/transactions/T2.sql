-- Run in session 2 while T1.sql is paused.
BEGIN;

UPDATE payment_history
SET amount_paid = amount_paid + 100
WHERE payee_no = 'A999';

COMMIT;
