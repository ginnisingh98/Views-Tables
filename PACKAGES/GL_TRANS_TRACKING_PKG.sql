--------------------------------------------------------
--  DDL for Package GL_TRANS_TRACKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TRANS_TRACKING_PKG" AUTHID CURRENT_USER AS
/* $Header: glitrtks.pls 120.3 2005/05/05 00:53:42 kvora ship $ */
--
-- Package
--   GL_TRANS_TRACKING_PKG
-- Purpose
--   To create GL_TRANS_TRACKING_PKG package.
--


  --
  -- Procedure
  --   set_outdated_period
  -- Purpose
  -- History
  -- Arguments
  --   x_chart_of_accounts_id	Structure Number.
  --   x_ccid			Code Combination ID.
  --   x_ledger_id  		Ledger ID.
  --   x_currency  		Currency Code.
  --   x_period_year  		Period Year.
  --   x_period_num  		Period Number.
  --   x_period_name  		Period Name.
  --   x_last_updated_by	User id who last update the row.
  --
  PROCEDURE set_outdated_period( x_chart_of_accounts_id NUMBER,
				 x_ccid			NUMBER,
				 x_ledger_id  		NUMBER,
                                 x_currency		VARCHAR2,
                                 x_period_year		NUMBER,
                                 x_period_num 		NUMBER,
                                 x_period_name 		VARCHAR2,
                                 x_last_updated_by	NUMBER,
				 x_usage_code           VARCHAR2);





END GL_TRANS_TRACKING_PKG;

 

/
