--------------------------------------------------------
--  DDL for Package GL_ALLOC_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ALLOC_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: glimahis.pls 120.5 2005/05/05 01:17:16 kvora ship $ */
--
-- Package
--   gl_alloc_history_pkg
-- Purpose
--   To contain validation and insertion routines for gl_alloc_history
-- History
--   12-31-93  	D. J. Ogg	Created

  --
  -- PUBLIC CONSTANTS
  --
  DEFAULT_NUM_FORMULAS_TO_CHECK	CONSTANT NUMBER := 5;


  --
  -- Procedure
  --   period_last_run
  -- Purpose
  --   Determines the period, calculation effective date, journal effective date
  --   for which a particular MassAllocation batch was last run for a given set
  --   of books.
  -- History
  --   04-20-96  R Goyal    Created
  -- Arguments
  --   batch_id		      ID of MassAllocation batch
  --   access_set_id   		      ID of current access set
  --   period_name            The period the MA batch was last run for
  --   calculation_eff_date   The CED the MA batch was last run for
  --   journal_eff_date       The JED the MA batch was last run for
  -- Returns
  --   The period, calculation and journal effective dates for which the
  --   MassAllocation batch was last run
  -- Notes
  --
  PROCEDURE period_last_run(batch_id NUMBER,
			    access_set_id NUMBER,
                            period_name IN OUT NOCOPY VARCHAR2,
                            calculation_eff_date IN OUT NOCOPY DATE,
                            journal_eff_date IN OUT NOCOPY DATE);

  --
  -- Function
  --   set_random_ledger_id
  -- Purpose
  --   Randomly select a ledger from T or O line of the batch. If no ledger
  --   is available, use the given ledger override id.
  -- History
  --   03-05-02   T Cheng   Created
  -- Arguments
  --   x_allocation_batch_id     batch id
  --   x_line_selection          'ABC' or 'TO', to select line 1,2,3 or 4,5
  --   x_ledger_override_id      ledger override id
  -- Notes
  --
  FUNCTION set_random_ledger_id (x_allocation_batch_id NUMBER,
                                 x_line_selection VARCHAR2,
                                 x_ledger_override_id NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   validate_calc_effective_date
  -- Purpose
  --   Checks certain number of formulas, see if the given calculation
  --   effective date falls in a never opened period for the ledgers
  --   in these formulas.
  -- History
  --   03-13-02   T Cheng   Created
  -- Arguments
  --   x_allocation_batch_id   batch id
  --   x_check_date            the date used to read ledger sets
  --   x_selected_ced          the calculation effective date
  -- Returns
  --   TRUE if the calculation effective date does not fall in any of the
  --   ledgers being checked. FALSE otherwise.
  -- Notes
  --
  FUNCTION validate_calc_effective_date(x_allocation_batch_id NUMBER,
                                        x_check_date DATE,
                                        x_selected_ced DATE) RETURN BOOLEAN;

  --
  -- Function
  --   allow_average_usage
  -- Purpose
  --   Check for "certain number of formulas" in the batch whether the ledgers
  --   (including ledgers within ledger sets) in T/O lines are all
  --   consolidation ledgers. Only if so will average usage be allowed.
  -- History
  --   03-04-02   T Cheng   Created
  -- Arguments
  --   x_allocation_batch_id    batch id
  --   x_period_end_date        period end date
  --   x_ledger_override_id     ledger id of the ledger override
  -- Notes
  --
  FUNCTION allow_average_usage(x_allocation_batch_id NUMBER,
                               x_period_end_date DATE,
                               x_ledger_override_id NUMBER) RETURN BOOLEAN;

END gl_alloc_history_pkg;

 

/
