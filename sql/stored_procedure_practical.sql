ALTER TABLE student
ADD COLUMN IF NOT EXISTS gpa NUMERIC(4, 2),
ADD COLUMN IF NOT EXISTS gpa_last_updated DATE;

CREATE OR REPLACE PROCEDURE create_module(
    IN p_code VARCHAR(10),
    IN p_name VARCHAR(100),
    IN p_credit INT
)
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM module WHERE mod_code = p_code) THEN
        RAISE EXCEPTION 'Module % already exists', p_code;
    END IF;

    INSERT INTO module (mod_code, mod_name, credit_unit)
    VALUES (p_code, p_name, p_credit);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE update_module(
    IN p_code VARCHAR(10),
    IN p_credit INT
)
AS $$
BEGIN
    UPDATE module
    SET credit_unit = p_credit
    WHERE mod_code = p_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Module % not found', p_code;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delete_module(
    IN p_code VARCHAR(10)
)
AS $$
BEGIN
    DELETE FROM module
    WHERE mod_code = p_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Module % not found', p_code;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_modules_performance()
RETURNS TABLE (
    mod_registered VARCHAR(10),
    grade CHAR(2),
    grade_count BIGINT
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        smp.mod_registered,
        smp.grade,
        COUNT(*) AS grade_count
    FROM stud_mod_performance smp
    GROUP BY smp.mod_registered, smp.grade
    ORDER BY smp.grade, COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_grade_point(grade_input CHAR(2))
RETURNS NUMERIC
AS $$
DECLARE
    grade_point NUMERIC;
BEGIN
    grade_point := CASE TRIM(grade_input)
        WHEN 'AD' THEN 4.0
        WHEN 'A' THEN 4.0
        WHEN 'B+' THEN 3.5
        WHEN 'B' THEN 3.0
        WHEN 'C+' THEN 2.5
        WHEN 'C' THEN 2.0
        WHEN 'D+' THEN 1.5
        WHEN 'D' THEN 1.0
        WHEN 'F' THEN 0.0
        ELSE NULL
    END;

    IF grade_point IS NULL THEN
        RAISE EXCEPTION 'Invalid Grade: %', grade_input;
    END IF;

    RETURN grade_point;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE calculate_students_gpa()
AS $$
DECLARE
    v_adm_no CHAR(4);
    v_mod_performance RECORD;
    total_credit_units INT;
    total_weighted_grade_points NUMERIC;
    computed_gpa NUMERIC;
BEGIN
    FOR v_adm_no IN (
        SELECT DISTINCT adm_no
        FROM stud_mod_performance
    )
    LOOP
        total_credit_units := 0;
        total_weighted_grade_points := 0;

        FOR v_mod_performance IN
            SELECT
                smp.grade,
                m.credit_unit
            FROM stud_mod_performance smp
            INNER JOIN module m
                ON m.mod_code = smp.mod_registered
            WHERE smp.adm_no = v_adm_no
        LOOP
            total_credit_units := total_credit_units + v_mod_performance.credit_unit;
            total_weighted_grade_points :=
                total_weighted_grade_points +
                (get_grade_point(v_mod_performance.grade) * v_mod_performance.credit_unit);
        END LOOP;

        IF total_credit_units > 0 THEN
            computed_gpa := total_weighted_grade_points / total_credit_units;

            UPDATE student
            SET
                gpa = ROUND(computed_gpa, 2),
                gpa_last_updated = CURRENT_DATE
            WHERE adm_no = v_adm_no;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
