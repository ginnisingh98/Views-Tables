--------------------------------------------------------
--  DDL for Package CE_CASHFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_CASHFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: cecashps.pls 120.1.12010000.2 2009/11/24 11:26:52 bkkashya ship $ */

--l_DEBUG varchar2(1);
PROCEDURE update_ce_cashflows(
    	X_CASHFLOW_ID   		number,
	X_TRX_STATUS			varchar2,
        X_actual_value_date  		date,
        X_CLEARED_DATE          	date,
        X_CLEARED_AMOUNT    		number,
        X_CLEARED_ERROR_AMOUNT          number,
        X_CLEARED_CHARGE_AMOUNT         number,
        X_CLEARED_EXCHANGE_RATE_TYPE    varchar2,
        X_CLEARED_EXCHANGE_RATE_DATE    date,
        X_CLEARED_EXCHANGE_RATE         number,
	X_NEW_TRX_STATUS		varchar2,
	X_CLEARED_BY_FLAG		VARCHAR2,
        X_LAST_UPDATE_DATE      	date,
        X_LAST_UPDATED_BY       	number,
        X_LAST_UPDATE_LOGIN     	number,
	X_STATEMENT_LINE_ID    		number,
	X_PASSIN_MODE			varchar2
	);

PROCEDURE RAISE_ACCT_EVENT(
	 X_CASHFLOW_ID 			number,
	 X_ACCTG_EVENT 			varchar2,
         X_ACCOUNTING_DATE 		date,
 	 X_EVENT_STATUS_CODE		VARCHAR2,
 	 X_EVENT_ID			IN OUT NOCOPY NUMBER);


PROCEDURE clear_cashflow (
    	X_CASHFLOW_ID   		number,
	X_TRX_STATUS			varchar2,
        X_actual_value_date  		date,
        X_ACCOUNTING_DATE       	date,
        X_CLEARED_DATE          	date,
        X_CLEARED_AMOUNT    		number,
        X_CLEARED_ERROR_AMOUNT          number,
        X_CLEARED_CHARGE_AMOUNT         number,
        X_CLEARED_EXCHANGE_RATE_TYPE    varchar2,
        X_CLEARED_EXCHANGE_RATE_DATE    date,
        X_CLEARED_EXCHANGE_RATE         number,
	X_PASSIN_MODE			varchar2,
	X_STATEMENT_LINE_ID		NUMBER,
	X_STATEMENT_LINE_TYPE		VARCHAR2
        );

PROCEDURE update_user_lines
(
 X_WORKSHEET_HEADER_ID  IN NUMBER,
 X_WORKSHEET_LINE_ID    IN NUMBER,
 X_LINE_DESCRIPTION     IN VARCHAR2,
 X_SOURCE_TYPE          IN VARCHAR2,
 X_BANK_ACCOUNT_ID      IN NUMBER,
 X_AS_OF_DATE           IN DATE,
 X_AMOUNT               IN NUMBER
);

END CE_CASHFLOW_PKG;

/
