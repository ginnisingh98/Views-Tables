--------------------------------------------------------
--  DDL for Package GL_RJE_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RJE_ACCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: glirecas.pls 120.4 2005/05/05 01:19:32 kvora ship $ */

--
-- Package
--   gl_rje_access_pkg
-- Purpose
--   To contain validation routines for gl_rje_access_pkg
-- History
--   10-23-02	  J Wu    	Created

  --
  -- PUBLIC CONSTANTS
  --
  DEFAULT_NUM_FORMULAS_TO_CHECK	CONSTANT NUMBER := 5;


  --
  -- Function
  --   validate_calc_effective_date
  -- Purpose
  --   Checks certain number of formulas, see if the given calculation
  --   effective date falls in a never opened period for the ledgers
  --   in these formulas.
  -- History
  --   10-23-02   J Wu    Created
  -- Arguments
  --   x_batch_id   batch id
  --   x_selected_ced          the calculation effective date
  -- Returns
  --   TRUE if the calculation effective date does not fall in any of the
  --   ledgers being checked. FALSE otherwise.
  -- Notes
  --
  FUNCTION validate_calc_effective_date (x_batch_id NUMBER,
                                         x_selected_ced DATE) RETURN BOOLEAN;


  --
  -- Function
  --   allow_average_usage
  -- Purpose
  --   Check for "certain number of formulas" in the batch whether the ledgers
  --   are all consolidation ledgers. Only if so will average usage be allowed.
  -- History
  --   10-23-02    J Wu    Created
  -- Arguments
  --   x_batch_id          batch id
  -- Returns
  --   TRUE if average usage is allowed. FALSE otherwise.
  -- Notes
  --

  FUNCTION allow_average_usage(x_batch_id NUMBER) RETURN BOOLEAN;


  --
  -- Function
  --   set_random_ledger_id
  -- Purpose
  --   Select a random header ledger for the recurring batch.
  --
  -- History
  --   10-23-02   J Wu       Created
  -- Arguments
  --   x_allocation_batch_id     batch id
  -- Notes
  --
  FUNCTION set_random_ledger_id (x_allocation_batch_id NUMBER) RETURN NUMBER;

END gl_rje_access_pkg;

 

/
