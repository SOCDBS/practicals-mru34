-- Run in session 1. During the 10-second pause, run T2.sql in session 2.
CREATE OR REPLACE PROCEDURE T1(
    INOUT results NUMERIC[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    payment1 DECIMAL(7,2);
    payment2 DECIMAL(7,2);
BEGIN
    results := ARRAY[]::NUMERIC[];

    SELECT amount_paid
    INTO STRICT payment1
    FROM payment_history
    WHERE payee_no = 'A999';

    results := array_append(results, payment1);

    PERFORM pg_sleep(10);

    SELECT amount_paid
    INTO STRICT payment2
    FROM payment_history
    WHERE payee_no = 'A999';

    results := array_append(results, payment2);
END;
$$;

DO $$
DECLARE
    payment_results NUMERIC[];
BEGIN
    CALL T1(payment_results);
    RAISE NOTICE 'T1 results: %', payment_results;
END;
$$;
