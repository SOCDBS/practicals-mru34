CREATE TABLE "country" (
    "country_name" VARCHAR(30) NOT NULL,
    "language" VARCHAR(30) NOT NULL,
    "region" VARCHAR(30) NOT NULL,
    CONSTRAINT "country_pkey" PRIMARY KEY ("country_name")
);

CREATE TABLE "course" (
    "crse_code" VARCHAR(5) NOT NULL,
    "crse_name" VARCHAR(100) NOT NULL,
    "offered_by" VARCHAR(5) NOT NULL,
    "crse_fee" DECIMAL(7,2) NOT NULL,
    "lab_fee" DECIMAL(7,2),
    CONSTRAINT "course_pkey" PRIMARY KEY ("crse_code")
);

CREATE TABLE "department" (
    "dept_code" VARCHAR(5) NOT NULL,
    "dept_name" VARCHAR(100) NOT NULL,
    "hod" CHAR(4) NOT NULL,
    "no_of_staff" INTEGER,
    "max_staff_strength" INTEGER,
    "budget" DECIMAL(9,2),
    "expenditure" DECIMAL(9,2),
    "hod_appt_date" DATE,
    CONSTRAINT "department_pkey" PRIMARY KEY ("dept_code")
);

CREATE TABLE "module" (
    "mod_code" VARCHAR(10) NOT NULL,
    "mod_name" VARCHAR(100) NOT NULL,
    "credit_unit" INTEGER NOT NULL,
    "mod_coord" CHAR(4),
    CONSTRAINT "module_pkey" PRIMARY KEY ("mod_code")
);

CREATE TABLE "pre_requisite" (
    "mod_code" VARCHAR(10) NOT NULL,
    "requisite" VARCHAR(10) NOT NULL,
    CONSTRAINT "pre_requisite_pkey" PRIMARY KEY ("mod_code", "requisite")
);

CREATE TABLE "staff" (
    "staff_no" CHAR(4) NOT NULL,
    "staff_name" VARCHAR(100) NOT NULL,
    "supervisor_staff_no" CHAR(4),
    "dob" DATE NOT NULL,
    "grade" VARCHAR(5) NOT NULL,
    "marital_status" VARCHAR(1) NOT NULL,
    "pay" DECIMAL(7,2),
    "allowance" DECIMAL(7,2),
    "hourly_rate" DECIMAL(7,2),
    "gender" CHAR(1) NOT NULL,
    "citizenship" VARCHAR(10) NOT NULL,
    "join_yr" INTEGER NOT NULL,
    "dept_code" VARCHAR(5) NOT NULL,
    "type_of_employment" VARCHAR(2) NOT NULL,
    "highest_qln" VARCHAR(10) NOT NULL,
    "designation" VARCHAR(20) NOT NULL,
    CONSTRAINT "staff_pkey" PRIMARY KEY ("staff_no")
);

CREATE TABLE "staff_backup" (
    "staff_no" CHAR(4) NOT NULL,
    "staff_name" VARCHAR(100) NOT NULL,
    "supervisor" CHAR(4),
    "dob" DATE NOT NULL,
    "grade" VARCHAR(5) NOT NULL,
    "marital_status" VARCHAR(1) NOT NULL,
    "pay" DECIMAL(7,2),
    "allowance" DECIMAL(7,2),
    "hourly_rate" DECIMAL(7,2),
    "gender" CHAR(1) NOT NULL,
    "citizenship" VARCHAR(10) NOT NULL,
    "join_yr" INTEGER NOT NULL,
    "dept_code" VARCHAR(5) NOT NULL,
    "type_of_employment" VARCHAR(2) NOT NULL,
    "highest_qln" VARCHAR(10) NOT NULL,
    "designation" VARCHAR(20) NOT NULL,
    CONSTRAINT "staff_backup_pkey" PRIMARY KEY ("staff_no")
);

CREATE TABLE "staff_dependent" (
    "staff_no" CHAR(4) NOT NULL,
    "dependent_name" VARCHAR(30) NOT NULL,
    "relationship" VARCHAR(20) NOT NULL,
    CONSTRAINT "staff_dependent_pkey" PRIMARY KEY ("staff_no", "dependent_name")
);

CREATE TABLE "student" (
    "adm_no" CHAR(4) NOT NULL,
    "stud_name" VARCHAR(30) NOT NULL,
    "gender" CHAR(1) NOT NULL,
    "address" VARCHAR(100) NOT NULL,
    "mobile_phone" CHAR(8),
    "home_phone" CHAR(8),
    "dob" DATE NOT NULL,
    "nationality" VARCHAR(30) NOT NULL,
    "crse_code" VARCHAR(5) NOT NULL,
    "gpa" DECIMAL(4,2),
    "gpa_last_updated" DATE,
    CONSTRAINT "student_pkey" PRIMARY KEY ("adm_no")
);

CREATE TABLE "stud_mod_performance" (
    "adm_no" CHAR(4) NOT NULL,
    "mod_registered" VARCHAR(10) NOT NULL,
    "mark" INTEGER,
    "grade" CHAR(2),
    CONSTRAINT "stud_mod_performance_pkey" PRIMARY KEY ("adm_no", "mod_registered")
);

CREATE TABLE "user_role" (
    "id" INTEGER NOT NULL,
    "name" VARCHAR(25) NOT NULL,
    CONSTRAINT "user_role_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "user_account" (
    "id" INTEGER NOT NULL,
    "account_no" VARCHAR(6) NOT NULL,
    "role" INTEGER NOT NULL,
    "password" VARCHAR(255),
    CONSTRAINT "user_account_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "course" ADD CONSTRAINT "course_offered_by_fk" FOREIGN KEY ("offered_by") REFERENCES "department"("dept_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "department" ADD CONSTRAINT "dept_hod_fk" FOREIGN KEY ("hod") REFERENCES "staff"("staff_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "module" ADD CONSTRAINT "mod_mod_coord_fk" FOREIGN KEY ("mod_coord") REFERENCES "staff"("staff_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "pre_requisite" ADD CONSTRAINT "pre_requisite_mod_code_fk" FOREIGN KEY ("mod_code") REFERENCES "module"("mod_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "pre_requisite" ADD CONSTRAINT "pre_requisite_requisite_fk" FOREIGN KEY ("requisite") REFERENCES "module"("mod_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "staff" ADD CONSTRAINT "staff_dept_code_fk" FOREIGN KEY ("dept_code") REFERENCES "department"("dept_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "staff_dependent" ADD CONSTRAINT "staff_dependent_staff_no_fk" FOREIGN KEY ("staff_no") REFERENCES "staff"("staff_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "student" ADD CONSTRAINT "student_crse_code_fk" FOREIGN KEY ("crse_code") REFERENCES "course"("crse_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "student" ADD CONSTRAINT "student_nationality_fk" FOREIGN KEY ("nationality") REFERENCES "country"("country_name") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "stud_mod_performance" ADD CONSTRAINT "stud_mod_performance_adm_no_fkey" FOREIGN KEY ("adm_no") REFERENCES "student"("adm_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "stud_mod_performance" ADD CONSTRAINT "stud_mod_performance_mod_registered_fkey" FOREIGN KEY ("mod_registered") REFERENCES "module"("mod_code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "user_account" ADD CONSTRAINT "fk_account_no" FOREIGN KEY ("account_no") REFERENCES "staff"("staff_no") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "user_account" ADD CONSTRAINT "fk_role" FOREIGN KEY ("role") REFERENCES "user_role"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
