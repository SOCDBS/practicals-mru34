/* eslint-disable no-console */
const { PrismaClient } = require('@prisma/client');
const util = require('util');

const prisma = new PrismaClient();

function getMeanCourseFee() {
    return prisma.course.aggregate({
        _avg: {
            crseFee: true,
        },
    });
}

/** Section A: Aggregation */

function getNumberOfFullTimeStaff() {
    return prisma.staff.aggregate({
        _count: {
            staffNo: true,
        },
        where: {
            typeOfEmployment: 'FT',
        },
    });
}

/** Section B: groupBy */

function getTotalAllowanceOfStaffByGrade() {
    return prisma.staff.groupBy({
        by: ['grade'],
        where: {
            grade: {
                not: {
                    startsWith: 'S',
                },
            },
            allowance: {
                not: null,
            },
        },
        _sum: {
            allowance: true,
        },
        orderBy: {
            grade: 'desc',
        },
    });
}

function getTotalPayAndNoOfStaffByDeptWithHighTotal() {
    return prisma.staff.groupBy({
        by: ['deptCode'],
        where: {
            deptCode: {
                not: 'DPO',
            },
        },
        _sum: {
            pay: true,
        },
        _count: {
            staffNo: true,
        },
        having: {
            pay: {
                _sum: {
                    gt: 20000,
                },
            },
        },
        orderBy: {
            _sum: {
                pay: 'desc',
            },
        },
    });
}

/** Using Raw Query */

function getAvgLabFeeWithRawQuery() {
    return prisma.$queryRaw`SELECT AVG(COALESCE(lab_fee, 0)) AS "Mean Lab Fee" FROM course;`;
}

async function main(argument) {
    let results;
    switch (argument) {
        case 'getMeanCourseFee':
            results = await getMeanCourseFee();
            break;
        case 'getNumberOfFullTimeStaff':
            results = await getNumberOfFullTimeStaff();
            break;
        case 'getTotalAllowanceOfStaffByGrade':
            results = await getTotalAllowanceOfStaffByGrade();
            break;
        case 'getTotalPayAndNoOfStaffByDeptWithHighTotal':
            results = await getTotalPayAndNoOfStaffByDeptWithHighTotal();
            break;
        case 'getAvgLabFeeWithRawQuery':
            results = await getAvgLabFeeWithRawQuery();
            break;
        default:
            console.log('Invalid argument');
    }
    if (results) {
        console.log(util.inspect(results, { showHidden: false, depth: null, colors: true }));
    }
}

main(process.argv[2])
    .catch(function (error) {
        console.error(error);
        process.exitCode = 1;
    })
    .finally(function () {
        return prisma.$disconnect();
    });
