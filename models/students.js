const { query } = require('../database');
const { SQL_ERROR_CODE, UNIQUE_VIOLATION_ERROR, RAISE_EXCEPTION } = require('../errors');

module.exports.retrieveAll = function retrieveAll() {
    const sql = 'SELECT adm_no, stud_name, gender, crse_code, gpa, gpa_last_updated FROM student';
    return query(sql).then(function ({ rows }) {
        return rows;
    });
};

module.exports.enrolNewStudent = function enrolNewStudent(adminNumber, studentName, gender, address, dob, nationality, courseCode) {
    const sql = 'CALL enrol_new_student($1, $2, $3, $4, $5, $6, $7, $8)';
    const parameters = [adminNumber, studentName, gender, address, dob, nationality, courseCode, ''];

    return query(sql, parameters)
        .then(function ({ rows }) {
            const errorMessage = rows[0] && rows[0].errMsg;
            if (errorMessage) {
                throw new RAISE_EXCEPTION(errorMessage);
            }
        })
        .catch(function (error) {
            if (error instanceof RAISE_EXCEPTION) {
                throw error;
            }
            if (error.code === SQL_ERROR_CODE.UNIQUE_VIOLATION) {
                throw new UNIQUE_VIOLATION_ERROR(`Student with adm no ${adminNumber} already exists! Cannot create duplicate.`);
            }
            if (error.code === SQL_ERROR_CODE.RAISE_EXCEPTION) {
                throw new RAISE_EXCEPTION(error.message);
            }
            throw error;
        });
};
