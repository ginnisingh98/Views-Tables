--------------------------------------------------------
--  DDL for Package GLXJEENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GLXJEENT_PKG" AUTHID CURRENT_USER as
/* $Header: glfjeens.pls 120.7 2004/07/14 21:53:54 djogg ship $ */

--
-- Package
--   GLXJEENT_PKG
-- Purpose
--   To implement various data checking needed for the
--   Enter Journals form
-- History
--   06-FEB-95  D J Ogg          Created
--

  --
  -- Procedure
  --   cashe_data
  -- Purpose
  --   Gets all of the data needed for cashing by the form
  -- History
  --   06-FEB-95  D. J. Ogg    Created
  -- Arguments
  --   acc_id                           The current access set id
  --   default_ledger_id                The default ledger
  --   form_mode                	The mode the form was brought up in
  --   default_je_source		Default source name
  --   user_default_je_source		Translation of default source name
  --   journal_approval_flag            Does the default source require
  --                                    approval?
  --   default_je_category		Default category name
  --   user_default_je_category		Translation of default category name
  --   default_rev_change_sign_flag	Reversal option for default category
  --   default_reversal_period 		Reversal period for default category
  --   default_reversal_date		Reversal date for default category
  --   default_reversal_start_date	Start Date of default reversal period
  --   default_reversal_end_date	Start Date of default reversal period
  --   default_period_name		Default period name for actuals
  --   default_start_date		Start date of period
  --   default_end_date			End date of period
  --   default_eff_date                 Default effective date
  --   default_period_year		Year of period
  --   default_period_num		Number of period
  --   default_conversion_type		Default conversion type
  --   user_default_conversion_type	Translation of default conversion type
  --   user_fixed_conversion_type       Translation of EMU Fixed conv type
  --   start_active_date		First date in an open or future
  --					enterable period
  --   end_active_date			Last date in an open or future
  --					enterable period
  -- Notes
  --
  PROCEDURE cache_data(	acc_id                                  NUMBER,
                        default_ledger_id                       NUMBER,
			form_mode				VARCHAR2,
			default_je_source		IN OUT NOCOPY	VARCHAR2,
			user_default_je_source		IN OUT NOCOPY  VARCHAR2,
			journal_approval_flag        	IN OUT NOCOPY	VARCHAR2,
			default_je_category		IN OUT NOCOPY  VARCHAR2,
			user_default_je_category	IN OUT NOCOPY  VARCHAR2,
			default_rev_change_sign_flag	IN OUT NOCOPY	VARCHAR2,
                        default_reversal_period         IN OUT NOCOPY  VARCHAR2,
                        default_reversal_date           IN OUT NOCOPY  DATE,
                        default_reversal_start_date     IN OUT NOCOPY  DATE,
                        default_reversal_end_date       IN OUT NOCOPY  DATE,
			default_period_name		IN OUT NOCOPY  VARCHAR2,
			default_start_date		IN OUT NOCOPY  DATE,
			default_end_date		IN OUT NOCOPY  DATE,
		        default_eff_date		IN OUT NOCOPY  DATE,
			default_period_year		IN OUT NOCOPY	NUMBER,
			default_period_num		IN OUT NOCOPY 	NUMBER,
			default_conversion_type		IN OUT NOCOPY  VARCHAR2,
			user_default_conversion_type	IN OUT NOCOPY	VARCHAR2,
		        user_fixed_conversion_type      IN OUT NOCOPY  VARCHAR2,
			start_active_date		IN OUT NOCOPY	DATE,
			end_active_date			IN OUT NOCOPY	DATE);

  --
  -- Procedure
  --   get_period
  -- Purpose
  --   Takes the accounting date and gets the period associated with it
  -- History
  --   03-JUN-96  D. J. Ogg    Created
  -- Arguments
  --   x_lgr_id				The current ledger
  --   x_accounting_date	        The accounting date to be used
  --   x_period_name			The period containing the date
  --   x_start_date			Start date of period
  --   x_end_date			End date of period
  -- Notes
  --
  PROCEDURE get_period(x_lgr_id				NUMBER,
		       x_accounting_date		DATE,
		       x_period_name			IN OUT NOCOPY	VARCHAR2,
		       x_period_status			IN OUT NOCOPY  VARCHAR2,
                       x_start_date			IN OUT NOCOPY  DATE,
		       x_end_date			IN OUT NOCOPY  DATE);

  --
  -- Procedure
  --   is_prior_period
  -- Purpose
  --   Takes a period and a ledger id or a batch id, and indicates
  --   whether that period is a prior period (i.e. a period earlier than
  --   the latest open) for that ledger or the ledgers in that batch
  -- History
  --   13-NOV-01  D. J. Ogg    Created
  -- Arguments
  --   x_period_name			The period name
  --   x_arg_type			'L' -- ledger id, 'B' -- batch id
  --   x_arg_id                         Ledger or batch id
  -- Notes
  --
  FUNCTION is_prior_period(x_period_name	VARCHAR2,
			   x_arg_type		VARCHAR2,
			   x_arg_id		NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   default_still_good
  -- Purpose
  --   Takes the default ledger, the current access set, a period,
  --   and an average journal flag.   Determines if the ledger is
  --   still a good default given the access set, period, and the
  --   average journal flag.
  -- History
  --   04-FEB-02  D. J. Ogg    Created
  -- Arguments
  --   x_ledger_id                      The default ledger
  --   x_period_name                    The period name
  --   x_average_journal_flag           The average journal flag
  -- Notes
  --
  FUNCTION default_still_good(x_access_set_id           NUMBER,
			      x_ledger_id       	NUMBER,
                              x_period_name		VARCHAR2,
			      x_average_journal_flag	VARCHAR2
                             ) RETURN VARCHAR2;

  --
  -- Procedure
  --   default_actual_period
  -- Purpose
  --   Determines the default period for an autocopied batch
  -- History
  --   24-NOV-03  D. J. Ogg    Created
  -- Arguments
  --   x_period_set_name		Current calendar
  --   x_period_type			Current accounted period type
  --   x_je_batch_id			Autocopied batch
  --   period_name			Default period name
  --   start_date			Default start date
  --   end_date				Default end date
  --   period_year			Default period year
  --   period_num			Default period number
  -- Notes
  --
  PROCEDURE default_actual_period(x_period_set_name		VARCHAR2,
				  x_period_type			VARCHAR2,
			 	  x_je_batch_id			NUMBER,
				  period_name IN OUT NOCOPY	VARCHAR2,
				  start_date IN OUT NOCOPY	DATE,
				  end_date IN OUT NOCOPY	DATE,
				  period_year IN OUT NOCOPY     NUMBER,
				  period_num IN OUT NOCOPY	NUMBER);

  --
  -- Procedure
  --   set_find_window_state
  -- Purpose
  --   Saves the state of the find window.  Uses autonomous_transactions
  -- History
  --   07-MAY-03  D. J. Ogg    Created
  -- Arguments
  --   w_state				The current window state
  -- Notes
  --
  PROCEDURE set_find_window_state(w_state		VARCHAR2);

END GLXJEENT_PKG;

 

/
