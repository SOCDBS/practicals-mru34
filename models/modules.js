const { PrismaClient, Prisma } = require('@prisma/client');
const { EMPTY_RESULT_ERROR, UNIQUE_VIOLATION_ERROR } = require('../errors');

const prisma = new PrismaClient();

module.exports.create = function create(code, name, credit) {
    return prisma.module
        .create({
            data: {
                modCode: code,
                modName: name,
                creditUnit: Number(credit),
            },
        })
        .catch(function (error) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
                throw new UNIQUE_VIOLATION_ERROR(
                    `Module ${code} already exists! Cannot create duplicate.`,
                );
            }
            throw error;
        });
};

module.exports.retrieveByCode = function retrieveByCode(code) {
    return prisma.module
        .findUnique({
            where: {
                modCode: code,
            },
        })
        .then(function (module) {
            if (module === null) {
                throw new EMPTY_RESULT_ERROR(`Module ${code} not found!`);
            }
            return module;
        });
};

module.exports.deleteByCode = function deleteByCode(code) {
    return prisma.module
        .delete({
            where: {
                modCode: code,
            },
        })
        .catch(function (error) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2025') {
                throw new EMPTY_RESULT_ERROR(`Module ${code} not found!`);
            }
            throw error;
        });
};

module.exports.updateByCode = function updateByCode(code, credit) {
    return prisma.module
        .update({
            where: {
                modCode: code,
            },
            data: {
                creditUnit: Number(credit),
            },
        })
        .catch(function (error) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2025') {
                throw new EMPTY_RESULT_ERROR(`Module ${code} not found!`);
            }
            throw error;
        });
};

module.exports.retrieveAll = function retrieveAll() {
    return prisma.module.findMany();
};

module.exports.retrieveBulk = function retrieveBulk(codes) {
    return prisma.module
        .findMany({
            where: {
                modCode: {
                    in: codes,
                },
            },
        })
        .then(function (modules) {
            return modules.reduce(function (result, module) {
                result[module.modCode] = module;
                return result;
            }, {});
        });
};
