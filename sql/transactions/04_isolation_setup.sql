-- Optional isolation-level exercise setup.
-- Re-running this file leaves exactly one A999 test payment.
DELETE FROM payment_history
WHERE payee_no = 'A999';

INSERT INTO payment_history (
    payee_no,
    payment_date,
    amount_paid,
    fee_type
)
VALUES ('A999', CURRENT_DATE, 100, 1);
