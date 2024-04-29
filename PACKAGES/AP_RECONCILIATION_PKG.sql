--------------------------------------------------------
--  DDL for Package AP_RECONCILIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_RECONCILIATION_PKG" AUTHID CURRENT_USER as
/* $Header: aprecons.pls 120.6 2006/12/20 20:13:43 lxzhang noship $ */

--===================================================================
-- Main API for reconciliation
--===================================================================
PROCEDURE Recon_Payment_History(
                          X_CHECKRUN_ID            IN NUMBER,
                          X_CHECK_ID               IN NUMBER,
                          X_ACCOUNTING_DATE        IN DATE,
                          X_CLEARED_DATE           IN DATE,
                          X_TRANSACTION_AMOUNT     IN NUMBER,
                          X_TRANSACTION_TYPE       IN VARCHAR2,
                          X_ERROR_AMOUNT           IN NUMBER,
                          X_CHARGE_AMOUNT          IN NUMBER,
                          X_CURRENCY_CODE          IN VARCHAR2,
                          X_EXCHANGE_RATE_TYPE     IN VARCHAR2,
                          X_EXCHANGE_RATE_DATE     IN DATE,
                          X_EXCHANGE_RATE          IN NUMBER,
                          X_MATCHED_FLAG           IN VARCHAR2,
                          X_ACTUAL_VALUE_DATE      IN DATE,
                          X_LAST_UPDATE_DATE       IN DATE,
                          X_LAST_UPDATED_BY        IN NUMBER,
                          X_LAST_UPDATE_LOGIN      IN NUMBER,
                          X_CREATED_BY             IN NUMBER,
                          X_CREATION_DATE          IN DATE,
                          X_PROGRAM_UPDATE_DATE    IN DATE,
                          X_PROGRAM_APPLICATION_ID IN NUMBER,
                          X_PROGRAM_ID             IN NUMBER,
                          X_REQUEST_ID             IN NUMBER,
                          X_CALLING_SEQUENCE       IN VARCHAR2
                        )  ;

PROCEDURE Recon_Payment_Maturity(
                          X_CHECK_ID               IN NUMBER,
                          X_ACCOUNTING_DATE        IN DATE,
                          X_TRANSACTION_TYPE       IN VARCHAR2,
                          X_TRANSACTION_AMOUNT     IN NUMBER,
                          X_CURRENCY_CODE          IN VARCHAR2,
                          X_EXCHANGE_RATE_TYPE     IN VARCHAR2,
                          X_EXCHANGE_RATE_DATE     IN DATE,
                          X_EXCHANGE_RATE          IN NUMBER,
                          X_LAST_UPDATE_DATE       IN DATE,
                          X_LAST_UPDATED_BY        IN NUMBER,
                          X_LAST_UPDATE_LOGIN      IN NUMBER,
                          X_CREATED_BY             IN NUMBER,
                          X_CREATION_DATE          IN DATE,
                          X_PROGRAM_UPDATE_DATE    IN DATE,
                          X_PROGRAM_APPLICATION_ID IN NUMBER,
                          X_PROGRAM_ID             IN NUMBER,
                          X_REQUEST_ID             IN NUMBER,
                          X_CALLING_SEQUENCE       IN VARCHAR2
                        ) ;


PROCEDURE Delete_Payment_Maturity (
                          X_CHECK_ID               IN NUMBER,
                          X_CALLING_SEQUENCE       IN VARCHAR2
                        ) ;


PROCEDURE Recon_Payment_Clearing(
                          X_CHECKRUN_ID            IN NUMBER,
                          X_CHECK_ID               IN NUMBER,
                          X_ACCOUNTING_DATE        IN DATE,
                          X_CLEARED_DATE           IN DATE,
                          X_TRANSACTION_TYPE       IN VARCHAR2,
                          X_TRX_BANK_AMOUNT        IN NUMBER,
                          X_ERRORS_BANK_AMOUNT     IN NUMBER,
                          X_CHARGES_BANK_AMOUNT    IN NUMBER,
                          X_BANK_CURRENCY_CODE     IN VARCHAR2,
                          X_PMT_TO_BASE_XRATE_TYPE IN VARCHAR2,
                          X_PMT_TO_BASE_XRATE_DATE IN DATE,
                          X_PMT_TO_BASE_XRATE      IN NUMBER,
                          X_MATCHED_FLAG           IN VARCHAR2,
                          X_ACTUAL_VALUE_DATE      IN DATE,
                          X_LAST_UPDATE_DATE       IN DATE,
                          X_LAST_UPDATED_BY        IN NUMBER,
                          X_LAST_UPDATE_LOGIN      IN NUMBER,
                          X_CREATED_BY             IN NUMBER,
                          X_CREATION_DATE          IN DATE,
                          X_PROGRAM_UPDATE_DATE    IN DATE,
                          X_PROGRAM_APPLICATION_ID IN NUMBER,
                          X_PROGRAM_ID             IN NUMBER,
                          X_REQUEST_ID             IN NUMBER,
                          X_CALLING_SEQUENCE       IN VARCHAR2
                        ) ;


PROCEDURE Recon_Payment_Unclearing(
                          X_CHECKRUN_ID            IN NUMBER,
                          X_CHECK_ID               IN NUMBER,
                          X_ACCOUNTING_DATE        IN DATE,
                          X_TRANSACTION_TYPE       IN VARCHAR2,
                          X_MATCHED_FLAG           IN VARCHAR2,
                          X_LAST_UPDATE_DATE       IN DATE,
                          X_LAST_UPDATED_BY        IN NUMBER,
                          X_LAST_UPDATE_LOGIN      IN NUMBER,
                          X_CREATED_BY             IN NUMBER,
                          X_CREATION_DATE          IN DATE,
                          X_PROGRAM_UPDATE_DATE    IN DATE,
                          X_PROGRAM_APPLICATION_ID IN NUMBER,
                          X_PROGRAM_ID             IN NUMBER,
                          X_REQUEST_ID             IN NUMBER,
                          X_CALLING_SEQUENCE       IN VARCHAR2
                        ) ;

PROCEDURE Insert_Payment_History(
                        X_CHECK_ID                 IN NUMBER,
                        X_TRANSACTION_TYPE         IN VARCHAR2,
                        X_ACCOUNTING_DATE          IN DATE,
                        X_TRX_BANK_AMOUNT          IN NUMBER,
                        X_ERRORS_BANK_AMOUNT       IN NUMBER,
                        X_CHARGES_BANK_AMOUNT      IN NUMBER,
                        X_BANK_CURRENCY_CODE       IN VARCHAR2,
                        X_BANK_TO_BASE_XRATE_TYPE  IN VARCHAR2,
                        X_BANK_TO_BASE_XRATE_DATE  IN DATE,
                        X_BANK_TO_BASE_XRATE       IN NUMBER,
                        X_TRX_PMT_AMOUNT           IN NUMBER,
                        X_ERRORS_PMT_AMOUNT        IN NUMBER,
                        X_CHARGES_PMT_AMOUNT       IN NUMBER,
                        X_PMT_CURRENCY_CODE        IN VARCHAR2,
                        X_PMT_TO_BASE_XRATE_TYPE   IN VARCHAR2,
                        X_PMT_TO_BASE_XRATE_DATE   IN DATE,
                        X_PMT_TO_BASE_XRATE        IN NUMBER,
                        X_TRX_BASE_AMOUNT          IN NUMBER,
                        X_ERRORS_BASE_AMOUNT       IN NUMBER,
                        X_CHARGES_BASE_AMOUNT      IN NUMBER,
                        X_MATCHED_FLAG             IN VARCHAR2,
                        X_REV_PMT_HIST_ID          IN NUMBER,
                        X_ORG_ID                   IN NUMBER,
                        X_CREATION_DATE            IN DATE,
                        X_CREATED_BY               IN NUMBER,
                        X_LAST_UPDATE_DATE         IN DATE,
                        X_LAST_UPDATED_BY          IN NUMBER,
                        X_LAST_UPDATE_LOGIN        IN NUMBER,
                        X_PROGRAM_UPDATE_DATE      IN DATE,
                        X_PROGRAM_APPLICATION_ID   IN NUMBER,
                        X_PROGRAM_ID               IN NUMBER,
                        X_REQUEST_ID               IN NUMBER,
                        X_CALLING_SEQUENCE         IN VARCHAR2,
                        -- Bug 3343314
                        X_ACCOUNTING_EVENT_ID      IN NUMBER DEFAULT NULL,
                        -- Bug fix 5694577
                        x_invoice_adjustment_event_id  IN NUMBER DEFAULT NULL
                      );

FUNCTION UnClear_Check(
                        CC_CHECKRUN_ID             IN NUMBER,
                        CC_CHECK_ID                IN NUMBER,
                        X_LAST_UPDATE_DATE         IN DATE,
                        X_LAST_UPDATED_BY          IN NUMBER,
                        X_LAST_UPDATE_LOGIN        IN NUMBER
                      )RETURN BOOLEAN ;

FUNCTION Recon_Update_Check(
                        RU_CHECK_ID                     IN NUMBER,
                        RU_CLEARED_AMOUNT               IN NUMBER,
                        RU_CLEARED_BASE_AMOUNT          IN NUMBER,
                        RU_CLEARED_ERROR_AMOUNT         IN NUMBER,
                        RU_CLEARED_ERROR_BASE_AMOUNT    IN NUMBER,
                        RU_CLEARED_CHARGES_AMOUNT       IN NUMBER,
                        RU_CLEARED_CHARGES_BASE_AMOUNT  IN NUMBER,
                        RU_CLEARED_DATE                 IN DATE,
                        RU_CHECK_STATUS                 IN VARCHAR2,
                        RU_CLEARED_XRATE                IN NUMBER,
                        RU_CLEARED_XRATE_TYPE           IN VARCHAR2,
                        RU_CLEARED_XRATE_DATE           IN DATE,
                        RU_ACTUAL_VALUE_DATE            IN DATE,
                        RU_LAST_UPDATED_BY              IN NUMBER,
                        RU_LAST_UPDATE_LOGIN            IN NUMBER,
                        RU_REQUEST_ID                   IN NUMBER
                        ) RETURN BOOLEAN;

FUNCTION Case_Type(
                        X_BANK_CURRENCY                 IN VARCHAR2,
                        X_PAY_CURRENCY                  IN VARCHAR2,
                        X_FUNC_CURRENCY                 IN VARCHAR2
                        ) RETURN VARCHAR2;

END AP_RECONCILIATION_PKG;
 

/
