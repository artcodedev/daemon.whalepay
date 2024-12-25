-- CreateEnum
CREATE TYPE "Currency" AS ENUM ('RUB', 'USD');

-- CreateEnum
CREATE TYPE "Status" AS ENUM ('PROCESS', 'PENDING_PAY', 'PENDING_CARD', 'PENDING_TRX', 'SUCCESS', 'ERROR', 'EXITED', 'REQVER');

-- CreateEnum
CREATE TYPE "Errors" AS ENUM ('PROXY', 'LOGIN', 'NETWORK', 'NOTFOUNDELEM', 'PARSE', 'TIMEEND', 'SESSIONERROR', 'REQVER', 'OTHER', 'NONE');

-- CreateEnum
CREATE TYPE "WithdrawStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'ERROR', 'SERVERFAIL');

-- CreateTable
CREATE TABLE "Merchant" (
    "id" SERIAL NOT NULL,
    "uid" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "login" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "secret_key" TEXT NOT NULL,
    "created_at" BIGINT NOT NULL,
    "status" BOOLEAN NOT NULL,

    CONSTRAINT "Merchant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" SERIAL NOT NULL,
    "uid" TEXT NOT NULL,
    "merchant_id" INTEGER NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" "Currency" NOT NULL,
    "status" "Status" NOT NULL,
    "description" TEXT NOT NULL,
    "paid" BOOLEAN NOT NULL,
    "domain" TEXT NOT NULL,
    "callback" TEXT NOT NULL,
    "metadata" JSONB NOT NULL,
    "created_at" BIGINT NOT NULL,
    "status_error" "Errors",

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" SERIAL NOT NULL,
    "time_opened" TEXT NOT NULL,
    "timezone" INTEGER NOT NULL,
    "browser_version" TEXT NOT NULL,
    "browser_language" TEXT NOT NULL,
    "ip" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "session_uid" TEXT NOT NULL,
    "time_closed" BIGINT,
    "time_paid" INTEGER,
    "from" TEXT,
    "card_id" INTEGER,
    "created_at" BIGINT NOT NULL,
    "trx" TEXT,
    "bank_uid" TEXT NOT NULL,
    "currency_symbol" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Card" (
    "id" SERIAL NOT NULL,
    "card_number" TEXT NOT NULL,
    "card_holder" TEXT NOT NULL,
    "card_receiver" TEXT NOT NULL,
    "card_cvv" TEXT NOT NULL,
    "card_valid_thru" TEXT NOT NULL,
    "card_phone" TEXT NOT NULL,
    "card_login" TEXT NOT NULL,
    "card_password" TEXT NOT NULL,
    "card_pin" TEXT NOT NULL,
    "card_secret" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL,
    "busy" BOOLEAN NOT NULL,
    "balance" INTEGER NOT NULL,
    "withdraw_avaliable" BOOLEAN NOT NULL DEFAULT false,
    "bank_uid" TEXT NOT NULL,

    CONSTRAINT "Card_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Withdraw" (
    "id" SERIAL NOT NULL,
    "merchant_id" INTEGER NOT NULL,
    "card_id" INTEGER NOT NULL,
    "withdraw_card_number" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" "WithdrawStatus" NOT NULL,
    "message" TEXT,
    "created_at" BIGINT NOT NULL,
    "updated_at" TEXT,

    CONSTRAINT "Withdraw_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Banks" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "status" BOOLEAN NOT NULL,
    "uid" TEXT NOT NULL,
    "currency" "Currency" NOT NULL,
    "currencySymbol" TEXT NOT NULL,

    CONSTRAINT "Banks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UsersAdmin" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "login" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "merchant_uid" TEXT NOT NULL,

    CONSTRAINT "UsersAdmin_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Merchant_uid_key" ON "Merchant"("uid");

-- CreateIndex
CREATE UNIQUE INDEX "Merchant_login_key" ON "Merchant"("login");

-- CreateIndex
CREATE UNIQUE INDEX "Session_uid_key" ON "Session"("uid");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_session_uid_key" ON "Payment"("session_uid");

-- CreateIndex
CREATE UNIQUE INDEX "Card_card_number_key" ON "Card"("card_number");

-- CreateIndex
CREATE UNIQUE INDEX "Card_card_login_key" ON "Card"("card_login");

-- CreateIndex
CREATE UNIQUE INDEX "Banks_uid_key" ON "Banks"("uid");

-- CreateIndex
CREATE UNIQUE INDEX "UsersAdmin_login_key" ON "UsersAdmin"("login");

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_merchant_id_fkey" FOREIGN KEY ("merchant_id") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_session_uid_fkey" FOREIGN KEY ("session_uid") REFERENCES "Session"("uid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Withdraw" ADD CONSTRAINT "Withdraw_merchant_id_fkey" FOREIGN KEY ("merchant_id") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
