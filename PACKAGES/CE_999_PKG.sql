--------------------------------------------------------
--  DDL for Package CE_999_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_999_PKG" AUTHID CURRENT_USER AS
/* $Header: ceab999s.pls 115.8 2002/01/25 16:51:45 pkm ship   $	*/
  PROCEDURE lock_row(
    X_call_mode		VARCHAR2, -- 'U' from reconcile, 'M' from unreconcile
    X_trx_type 		VARCHAR2, -- trx_type of the transaction
    X_trx_rowid		VARCHAR2  -- rowid of the transaction
  );

  PROCEDURE clear(
    X_trx_id		NUMBER,	  -- transaction id
    X_trx_type		VARCHAR2, -- transaction type
    X_status            VARCHAR2, -- status
    X_trx_number        VARCHAR2, -- transaction number
    X_trx_date		DATE,	  -- transaction date
    X_trx_currency	VARCHAR2, -- transaction currency code
    X_gl_date		DATE,	  -- gl date
    X_bank_currency	VARCHAR2, -- bank currency code
    X_cleared_amount	NUMBER,	  -- amount to be cleared
    X_cleared_date      DATE,     -- cleared date
    X_charges_amount	NUMBER,	  -- charges amount
    X_errors_amount	NUMBER,	  -- errors amount
    X_exchange_date	DATE,	  -- exchange rate date
    X_exchange_type	VARCHAR2, -- exchange rate type
    X_exchange_rate	NUMBER 	  -- exchange rate
  );

  PROCEDURE unclear(
    X_trx_id		NUMBER,	  -- transaction id
    X_trx_type		VARCHAR2, -- transaction type
    X_status            VARCHAR2, -- status
    X_trx_date		DATE,	  -- transaction date
    X_gl_date		DATE	  -- gl date
  );

END CE_999_PKG;

 

/
