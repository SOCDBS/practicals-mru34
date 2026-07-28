-- AlterTable
ALTER TABLE "course"
ADD COLUMN "max_crse_size" INTEGER NOT NULL DEFAULT 100;

-- CreateTable
CREATE TABLE "payment_fee_type" (
    "fee_type" SERIAL NOT NULL,
    "fee_name" VARCHAR(20) NOT NULL,

    CONSTRAINT "payment_fee_type_pkey" PRIMARY KEY ("fee_type")
);

-- CreateTable
CREATE TABLE "payment_history" (
    "payment_id" SERIAL NOT NULL,
    "payee_no" CHAR(4) NOT NULL,
    "payment_date" DATE NOT NULL,
    "amount_paid" DECIMAL(7,2) NOT NULL,
    "fee_type" INTEGER NOT NULL,

    CONSTRAINT "payment_history_pkey" PRIMARY KEY ("payment_id")
);

-- AddForeignKey
ALTER TABLE "payment_history"
ADD CONSTRAINT "payment_history_fee_type_fk"
FOREIGN KEY ("fee_type") REFERENCES "payment_fee_type"("fee_type")
ON DELETE NO ACTION ON UPDATE NO ACTION;
