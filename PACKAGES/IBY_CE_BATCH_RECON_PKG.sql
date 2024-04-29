--------------------------------------------------------
--  DDL for Package IBY_CE_BATCH_RECON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_CE_BATCH_RECON_PKG" AUTHID CURRENT_USER as
/* $Header: ibycepis.pls 120.2.12010000.1 2008/07/28 05:39:56 appldev ship $ */


--==========================================================================
-- This API will be called by CE for reconciliation at the batch level with
-- R12 IBY payment instructions.
-- This API models the AP_RECONCILIATION_PKG.Recon_Payment_History() API for
-- batch clearing. The API will do proration as AP, then call product APIs
-- at transaction (payment) level so they can execute their business logic
-- and update their tables.
--==========================================================================
PROCEDURE Payment_Instruction_Clearing(
                          P_PAYMENT_INSTRUCTION_ID IN NUMBER,
                          P_ACCOUNTING_DATE        IN DATE,
                          P_CLEARED_DATE           IN DATE,
                          P_TRANSACTION_AMOUNT     IN NUMBER,      -- in bank curr.
                          P_ERROR_AMOUNT           IN NUMBER,      -- in bank curr.
                          P_CHARGE_AMOUNT          IN NUMBER,      -- in bank curr.
                          P_CURRENCY_CODE          IN VARCHAR2,    -- bank curr. code
                          P_EXCHANGE_RATE_TYPE     IN VARCHAR2,    -- between payment and functional
                          P_EXCHANGE_RATE_DATE     IN DATE,        -- between payment and functional
                          P_EXCHANGE_RATE          IN NUMBER,      -- between payment and functional
                          P_MATCHED_FLAG           IN VARCHAR2,
                          P_ACTUAL_VALUE_DATE      IN DATE,
                          P_PASSIN_MODE            IN VARCHAR2,    -- passed back to CE
                          P_STATEMENT_LINE_ID      IN NUMBER,      -- passed back to CE
                          P_STATEMENT_LINE_TYPE    IN VARCHAR2,    -- passed back to CE
                          P_LAST_UPDATE_DATE       IN DATE,
                          P_LAST_UPDATED_BY        IN NUMBER,
                          P_LAST_UPDATE_LOGIN      IN NUMBER,
                          P_CREATED_BY             IN NUMBER,
                          P_CREATION_DATE          IN DATE,
                          P_PROGRAM_UPDATE_DATE    IN DATE,
                          P_PROGRAM_APPLICATION_ID IN NUMBER,
                          P_PROGRAM_ID             IN NUMBER,
                          P_REQUEST_ID             IN NUMBER,
                          P_CALLING_SEQUENCE       IN VARCHAR2,
                          P_LOGICAL_GROUP_REFERENCE IN VARCHAR2
                          )  ;

PROCEDURE Payment_Instruction_Unclearing(
                          P_PAYMENT_INSTRUCTION_ID IN NUMBER,
                          P_ACCOUNTING_DATE        IN DATE,
                          P_MATCHED_FLAG           IN VARCHAR2,
                          P_LAST_UPDATE_DATE       IN DATE,
                          P_LAST_UPDATED_BY        IN NUMBER,
                          P_LAST_UPDATE_LOGIN      IN NUMBER,
                          P_CREATED_BY             IN NUMBER,
                          P_CREATION_DATE          IN DATE,
                          P_PROGRAM_UPDATE_DATE    IN DATE,
                          P_PROGRAM_APPLICATION_ID IN NUMBER,
                          P_PROGRAM_ID             IN NUMBER,
                          P_REQUEST_ID             IN NUMBER,
                          P_CALLING_SEQUENCE       IN VARCHAR2
                        ) ;

END IBY_CE_BATCH_RECON_PKG;

/
