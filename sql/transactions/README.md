# Transactions practical

This folder contains the completed transaction exercises from **Practical
Transactions v3**.

## Main practical

Run the work in this order:

1. Apply the Prisma migration:
   `npx prisma migrate deploy`
2. Run `01_commit_rollback_savepoints.sql`.
3. Run `02_transfer_staff.sql` to create `transfer_staff`.
4. Run `03_enrol_new_student.sql` once to seed the two fee types and create
   `enrol_new_student`.
5. Start the Express application normally. `models/staff.js` and
   `models/students.js` call the two procedures.

For the course-capacity test, set a course's `max_crse_size` to `2`, then try
to enrol three students into it. The third student's payment remains recorded,
but the student insert is rolled back and the application receives:

`Maximum course size exceeded. Please Handle Manually.`

## Optional isolation-level exercise

1. Run `04_isolation_setup.sql`.
2. Open two database sessions.
3. In session 1, choose the isolation level and run `T1.sql`.
4. While T1 is sleeping, run `T2.sql` in session 2.

For **read committed**, use:

```sql
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

The two values printed by T1 can differ because its second query sees T2's
committed update.

Reset with `04_isolation_setup.sql`, then use:

```sql
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

The two values printed by T1 remain the same because both reads use one
transaction snapshot.
