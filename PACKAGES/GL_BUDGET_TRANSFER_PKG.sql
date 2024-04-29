--------------------------------------------------------
--  DDL for Package GL_BUDGET_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: glibdxfs.pls 120.4 2005/05/05 01:02:47 kvora ship $ */
--
-- Package
--   gl_budget_transfer_pkg
-- Purpose
--   To contain validation and insertion routines for gl_budget_transfer
-- History
--   03-25-94  	D. J. Ogg	Created

  --
  -- Procedure
  --   get_from_to_balance
  -- Purpose
  --   Gets the indicated budget transfer balance for the from and to
  --   code_combinations for the given budget and currency
  -- History
  --   03-25-93   D. J. Ogg		Created
  -- Arguments
  --   balance_type			PTD, QTD, YTD, or PJTD
  --   xledger_id			Ledger ID
  --   xbc_enabled_flag			Indicates whether or not budgetary
  --			        	control is enabled.
  --   xperiod_name			Period to get balances for
  --   xbudget_version_id		ID of budget to get balances for
  --   xcurrency_code 			Currency to get balances for
  --   from_code_combination_id		From code combination
  --   to_code_combination_id		To code combination
  --   from_balance			Holds the balance of the from
  -- 					code combination
  --   to_balance			Holds the balance of the to
  --					code combination
  -- Example
  --   get_from_to_balance('PTD', 2, 'Y', 'JAN-91', 1000, 'USD', 2000, 2230,
  --                       from_bal, to_bal);
  PROCEDURE get_from_to_balance (balance_type		   VARCHAR2,
				 xledger_id                NUMBER,
				 xbc_enabled_flag          VARCHAR2,
				 xperiod_name              VARCHAR2,
                                 xbudget_version_id	   NUMBER,
                                 xcurrency_code		   VARCHAR2,
				 from_code_combination_id  NUMBER,
				 to_code_combination_id    NUMBER,
                                 from_balance              IN OUT NOCOPY NUMBER,
				 to_balance		   IN OUT NOCOPY NUMBER);

  --
  -- Procedure
  --   get_balance
  -- Purpose
  --   Gets the indicated budget transfer balance for the given
  --   code_combination, budget, and currency
  -- History
  --   05-09-93   D. J. Ogg		Created
  -- Arguments
  --   balance_type			PTD, QTD, YTD, or PJTD
  --   xledger_id			Ledger ID
  --   xbc_enabled_flag			Indicates whether or not budgetary
  --			        	control is enabled.
  --   xperiod_name			Period to get balances for
  --   xbudget_version_id		ID of budget to get balances for
  --   xcurrency_code 			Currency to get balances for
  --   code_combination_id		Code combination
  -- Example
  --   balance := get_balance('PTD', 2, 'Y', 'JAN-91', 1000, 'USD', 2000);
  FUNCTION get_balance (balance_type	     VARCHAR2,
			xledger_id           NUMBER,
			xbc_enabled_flag     VARCHAR2,
			xperiod_name         VARCHAR2,
                        xbudget_version_id   NUMBER,
                        xcurrency_code       VARCHAR2,
			code_combination_id  NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   get_from_to_bc_balance
  -- Purpose
  --   Gets the indicated budgetary control balance for the from and to
  --   code_combinations for the given budget and currency
  -- History
  --   03-25-93   D. J. Ogg		Created
  -- Arguments
  --   balance_type			PTD, QTD, YTD, or PJTD
  --   xledger_id			Ledger ID
  --   xperiod_name			Period to get balances for
  --   xactual_flag                     Actual, Budget, or Encumbrance
  --   xbudget_version_id		ID of budget or encumbrance to get
  --					balances for
  --   xcurrency_code 			Currency to get balances for
  --   from_code_combination_id		From code combination
  --   to_code_combination_id		To code combination
  --   from_balance			Holds the balance of the from
  -- 					code combination
  --   to_balance			Holds the balance of the to
  --					code combination
  -- Example
  --   get_from_to_bc_balance('PTD', 2, 'JAN-91', 1000, 'USD', 2000, 2230,
  --                          from_bal, to_bal);
  PROCEDURE get_from_to_bc_balance (balance_type	      VARCHAR2,
				    xledger_id          NUMBER,
				    xperiod_name              VARCHAR2,
				    xactual_flag	      VARCHAR2,
                                    xbudget_version_id	      NUMBER,
                                    xcurrency_code	      VARCHAR2,
				    from_code_combination_id  NUMBER,
				    to_code_combination_id    NUMBER,
                                    from_balance              IN OUT NOCOPY NUMBER,
				    to_balance		      IN OUT NOCOPY NUMBER);

  --
  -- Procedure
  --   get_bc_balance
  -- Purpose
  --   Gets the balance in gl_bc_packets for the given code combination
  -- History
  --   03-28-93   D. J. Ogg		Created
  -- Arguments
  --   balance_type			PTD, QTD, YTD, or PJTD
  --   xledger_id			Ledger ID
  --   xperiod_name			Period to get balances for
  --   xactual_flag			Actual Flag
  --   xbudget_version_id		ID of budget or encumbrance to
  --					get balances for
  --   xcurrency_code 			Currency to get balances for
  --   xcode_combination_id		Code combination
  -- Example
  --   get_bc_balance('YTD', 2, 'JAN-91', 'A', -1, 'USD', 2034);
  FUNCTION get_bc_balance  (balance_type         VARCHAR2,
		            xledger_id     NUMBER,
			    xperiod_name         VARCHAR2,
			    xactual_flag	 VARCHAR2,
                            xbudget_version_id	 NUMBER,
                            xcurrency_code       VARCHAR2,
		            xcode_combination_id NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   get_posted_balance
  -- Purpose
  --   Gets the balance in gl_balances for the given code combination
  -- History
  --   03-28-93   D. J. Ogg		Created
  -- Arguments
  --   balance_type			PTD, QTD, YTD, or PJTD
  --   xledger_id			Ledger ID
  --   xperiod_name			Period to get balances for
  --   xactual_flag			Actual Flag
  --   xbudget_version_id		ID of budget or encumbrance to
  --					get balances for
  --   xcurrency_code 			Currency to get balances for
  --   xcode_combination_id		Code combination
  -- Example
  --   get_posted_balance('YTD', 2, 'JAN-91', 'A', -1, 'USD', 2034);
  FUNCTION get_posted_balance  (balance_type         VARCHAR2,
		                xledger_id           NUMBER,
			        xperiod_name         VARCHAR2,
			        xactual_flag	     VARCHAR2,
                                xbudget_version_id   NUMBER,
                                xcurrency_code       VARCHAR2,
		                xcode_combination_id NUMBER) RETURN NUMBER;

END gl_budget_transfer_pkg;

 

/
