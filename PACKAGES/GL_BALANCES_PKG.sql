--------------------------------------------------------
--  DDL for Package GL_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: gliblncs.pls 120.4 2005/05/05 01:03:02 kvora ship $ */
--
-- Package
--   GL_BALANCES_PKG
-- Purpose
--   To create GL_BALANCES_PKG package.
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
  --
  PROCEDURE set_translated_flag( x_ledger_id  		NUMBER,
                                 x_ccid   		NUMBER,
                                 x_currency		VARCHAR2,
                                 x_period_year		NUMBER,
                                 x_period_num 		NUMBER,
                                 x_last_updated_by	NUMBER,
				 x_chart_of_accounts_id NUMBER,
				 x_period_name          VARCHAR2,
				 x_usage_code           VARCHAR2);




  -- Procedure
  --     gl_activity
  -- Purpose
  -- Given the parameter listed above and the procedure will return
  -- the Period Net Cr and the Period Net Dr
  -- or raise exception NO_DATA_FOUND
  -- History
  -- 3/16/95        Schirin Farzaneh  Created
  -- Arguments
  --  PARAMETERS
  --      PERIOD_FROM          VARCHAR2
  --      PERIOD_TO            VARCHAR2
  --      CODE_COMBINATION_ID  NUMBER
  --      LEDGER_ID            NUMBER
  -- RETURNS
  --    PERIOD_NET_DR
  --    PERIOD_NET_CR
  --    exception NO_DATA_FOUND

  PROCEDURE gl_get_period_range_activity
			  ( P_PERIOD_FROM         IN VARCHAR2
 	    		   ,P_PERIOD_TO           IN VARCHAR2
 			   ,P_CODE_COMBINATION_ID IN NUMBER
 			   ,P_LEDGER_ID           IN NUMBER
                           ,P_PERIOD_NET_DR       OUT NOCOPY NUMBER
                           ,P_PERIOD_NET_CR       OUT NOCOPY NUMBER);

END GL_BALANCES_PKG;

 

/
