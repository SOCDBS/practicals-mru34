-- Practical Transactions, Section C
-- Run this once after applying the create-payment-models migration.
INSERT INTO payment_fee_type (fee_name)
VALUES ('crse_fee'), ('lab_fee');

CREATE OR REPLACE PROCEDURE enrol_new_student(
    IN p_adm_no CHAR(4),
    IN p_stud_name VARCHAR(30),
    IN p_gender CHAR(1),
    IN p_address VARCHAR(100),
    IN p_dob DATE,
    IN p_nationality VARCHAR(30),
    IN p_crse_code VARCHAR(5),
    OUT err_msg VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_crse_fee DECIMAL(7,2);
    v_lab_fee DECIMAL(7,2);
    v_max_crse_size INTEGER;
    v_student_count INTEGER;
BEGIN
    err_msg := NULL;

    -- T1: payment work. Its exception block rolls back only this block.
    BEGIN
        SELECT crse_fee, lab_fee
        INTO STRICT v_crse_fee, v_lab_fee
        FROM course
        WHERE crse_code = p_crse_code;

        IF v_crse_fee IS NOT NULL THEN
            INSERT INTO payment_history (
                payee_no,
                payment_date,
                amount_paid,
                fee_type
            )
            VALUES (p_adm_no, CURRENT_DATE, v_crse_fee, 1);
        END IF;

        IF v_lab_fee IS NOT NULL THEN
            INSERT INTO payment_history (
                payee_no,
                payment_date,
                amount_paid,
                fee_type
            )
            VALUES (p_adm_no, CURRENT_DATE, v_lab_fee, 2);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            err_msg := 'Issues with payments.';
    END;

    -- T2: enrolment work runs only when payment processing succeeded.
    IF err_msg IS NULL THEN
        BEGIN
            INSERT INTO student (
                adm_no,
                stud_name,
                gender,
                address,
                dob,
                nationality,
                crse_code
            )
            VALUES (
                p_adm_no,
                p_stud_name,
                p_gender,
                p_address,
                p_dob,
                p_nationality,
                p_crse_code
            );

            SELECT max_crse_size
            INTO STRICT v_max_crse_size
            FROM course
            WHERE crse_code = p_crse_code;

            SELECT COUNT(*)
            INTO v_student_count
            FROM student
            WHERE crse_code = p_crse_code;

            IF v_student_count > v_max_crse_size THEN
                RAISE EXCEPTION 'Maximum course size exceeded.';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                err_msg :=
                    'Maximum course size exceeded. Please Handle Manually.';
        END;
    END IF;

    COMMIT;
END;
$$;
