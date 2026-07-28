-- Practical Transactions, Section B
CREATE OR REPLACE PROCEDURE transfer_staff(
    IN p_staff_no CHAR(4),
    IN p_new_dept_code VARCHAR(5)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_dept_code VARCHAR(5);
BEGIN
    SELECT dept_code
    INTO v_old_dept_code
    FROM staff
    WHERE staff_no = p_staff_no;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Staff % was not found.', p_staff_no;
    END IF;

    IF v_old_dept_code = p_new_dept_code THEN
        RAISE EXCEPTION 'Staff % is already assigned to department %.',
            p_staff_no, p_new_dept_code;
    END IF;

    UPDATE department
    SET no_of_staff = COALESCE(no_of_staff, 0) + 1
    WHERE dept_code = p_new_dept_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Department % was not found.', p_new_dept_code;
    END IF;

    UPDATE department
    SET no_of_staff = COALESCE(no_of_staff, 0) - 1
    WHERE dept_code = v_old_dept_code;

    -- This exception proves the preceding updates are rolled back atomically.
    IF EXISTS (
        SELECT 1
        FROM department
        WHERE hod = p_staff_no
    ) THEN
        RAISE EXCEPTION 'Please manually update for HOD appointment holders.';
    END IF;

    UPDATE module
    SET mod_coord = NULL
    WHERE mod_coord = p_staff_no;

    UPDATE staff
    SET supervisor_staff_no = NULL
    WHERE supervisor_staff_no = p_staff_no;

    UPDATE staff
    SET dept_code = p_new_dept_code
    WHERE staff_no = p_staff_no;
END;
$$;
