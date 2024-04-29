--------------------------------------------------------
--  DDL for Package GL_DAILY_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DAILY_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: glidbals.pls 120.3 2005/05/05 01:06:38 kvora ship $ */
--
-- Package
--   GL_DAILY_BALANCES_PKG
-- Purpose
--   To create GL_DAILY_BALANCES_PKG package.
--


  --
  -- Procedure
  --   set_translated_flag
  -- Purpose
  -- History
  --   03-NOV-1994  E. Rumanang    Created.
  -- Arguments
  --   x_ledger_id  		Ledger ID.
  --   x_ccid  			Code combination ID.
  --   x_currency  		Currency Code.
  --   x_period_year  		Period Year.
  --   x_period_num  		Period Number.
  --   x_last_updated_by	User id who last update the row.
  --   x_chart_of_accounts_id   Structure Number.
  --   x_period_name   		Period Name.
  --
  PROCEDURE set_translated_flag( x_ledger_id  		NUMBER,
                                 x_ccid   		NUMBER,
                                 x_currency		VARCHAR2,
                                 x_period_year		NUMBER,
                                 x_period_num 		NUMBER,
                                 x_last_updated_by	NUMBER,
				 x_chart_of_accounts_id NUMBER,
				 x_period_name		VARCHAR2,
				 x_usage_code           VARCHAR2);





END GL_DAILY_BALANCES_PKG;

 

/
