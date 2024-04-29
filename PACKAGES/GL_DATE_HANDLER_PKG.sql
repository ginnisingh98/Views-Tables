--------------------------------------------------------
--  DDL for Package GL_DATE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DATE_HANDLER_PKG" AUTHID CURRENT_USER as
/* $Header: glustdts.pls 120.5 2005/05/05 01:44:37 kvora ship $ */

--
-- Package
--   GL_DATE_HANDLER_PKG
-- Purpose
--   To implement a variety of routines related to dates
-- History
--   10-DEC-96  D J Ogg          Created
--

  --
  -- Procedure
  --   find_active_period
  -- Purpose
  --   Finds the open or future enterable period associated with this
  --   date.
  -- History
  --   27-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   lgr_id			Current ledger
  --   calendar			Calendar used by current ledger
  --   per_type			Accounting Period Type of current ledger
  --   active_date		Date of interest
  --   active_period		The desired period
  --   per_start_date		The desired period's start date
  --   per_end_date		The desired period's end date
  --   per_number		The desired period's number
  --   per_year			The desired period's year
  -- Notes
  --
  PROCEDURE find_active_period(	lgr_id			NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				active_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
			 	per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY 	NUMBER
			      );

  --
  -- Procedure
  --   find_enc_period
  -- Purpose
  --   Finds the period in an open encumbrance year associated with this date
  -- History
  --   27-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   lgr_id			Current ledger
  --   calendar			Calendar used by current ledger
  --   per_type			Accounting Period Type of current ledger
  --   active_date		Date of interest
  --   active_period		The desired period
  --   per_start_date		The desired period's start date
  --   per_end_date		The desired period's end date
  --   per_number		The desired period's number
  --   per_year			The desired period's year
  -- Notes
  --
  PROCEDURE find_enc_period(	lgr_id			NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				active_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
			 	per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY 	NUMBER
			      );

  --
  -- Procedure
  --   find_enc_period_batch
  -- Purpose
  --   Finds the period associated with this date which is in an open
  --   encumbrance year for all the ledgers in the journal
  -- History
  --   14-JUN-01  D. J. Ogg    Created
  -- Arguments
  --   batch_id			Batch whose ledgers are to be checked
  --   calendar			Calendar used by current ledger
  --   per_type			Accounting Period Type of current ledger
  --   active_date		Date of interest
  --   active_period		The desired period
  --   per_start_date		The desired period's start date
  --   per_end_date		The desired period's end date
  --   per_number		The desired period's number
  --   per_year			The desired period's year
  -- Notes
  --
  PROCEDURE find_enc_period_batch(
				batch_id		NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				active_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
			 	per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY 	NUMBER
			      );

  --
  -- Procedure
  --   validate_date
  -- Purpose
  --   Takes the accounting date, checks that it is in an open or future
  --   enterable period, and finds the corresponding working date
  -- History
  --   27-DEC-96  D. J. Ogg    Copied from glfjeenb_pkg
  -- Arguments
  --   lgr_id				The current ledger
  --   roll_date			If this is 'Y', then validate_date
  --					will try to roll the date to a
  --					working date, if it isn't one
  --   initial_accounting_date	        The accounting date to be checked
  --   minimum_date			The date, when rolled, must be after
  --                                    or equal to this date.  This date
  --                                    must be less than or equal to the
  --                                    initial_accounting_date
  --   minimum_period			Period must be equal to or after
  --					this period
  --   period_name			The period containing the date
  --   start_date			Start date of period
  --   end_date				End date of period
  --   period_num			Number of period
  --   period_year			Period year of period
  --   rolled_accounted_date		The business date corresponding to
  --					the minimum date
  -- Notes
  --
  PROCEDURE validate_date(lgr_id				NUMBER,
			  roll_date				VARCHAR2,
			  initial_accounting_date		DATE,
                          minimum_date                          DATE,
                          minimum_period                        VARCHAR2,
			  period_name			IN OUT NOCOPY	VARCHAR2,
                          start_date			IN OUT NOCOPY  DATE,
			  end_date			IN OUT NOCOPY  DATE,
			  period_num			IN OUT NOCOPY  NUMBER,
			  period_year			IN OUT NOCOPY  NUMBER,
			  rolled_accounting_date	IN OUT NOCOPY 	DATE);


  --
  -- Procedure
  --   validate_date_batch
  -- Purpose
  --   Takes the accounting date, checks that it is in an open or future
  --   enterable period, and finds the corresponding working date.
  --   Checks this for all of the ledgers in the given batch
  -- History
  --   14-JUN-01  D. J. Ogg    Copied from validate_date
  -- Arguments
  --   batch_id				The batch whose ledgers are to be
  --                                    checked
  --   roll_date			If this is 'Y', then validate_date
  --					will try to roll the date to a
  --					working date, if it isn't one
  --   initial_accounting_date	        The accounting date to be checked
  --   minimum_date			The date, when rolled, must be after
  --                                    or equal to this date.  This date
  --                                    must be less than or equal to the
  --                                    initial_accounting_date
  --   minimum_period			Period must be equal to or after
  --					this period
  --   period_name			The period containing the date
  --   start_date			Start date of period
  --   end_date				End date of period
  --   period_num			Number of period
  --   period_year			Period year of period
  --   rolled_accounted_date		The business date corresponding to
  --					the minimum date
  -- Notes
  --
  PROCEDURE validate_date_batch(
                          batch_id				NUMBER,
			  roll_date				VARCHAR2,
			  initial_accounting_date		DATE,
                          minimum_date                          DATE,
                          minimum_period                        VARCHAR2,
			  period_name			IN OUT NOCOPY	VARCHAR2,
                          start_date			IN OUT NOCOPY  DATE,
			  end_date			IN OUT NOCOPY  DATE,
			  period_num			IN OUT NOCOPY  NUMBER,
			  period_year			IN OUT NOCOPY  NUMBER,
			  rolled_accounting_date	IN OUT NOCOPY 	DATE);


  --
  -- Procedure
  --   find_from_period
  -- Purpose
  --   Finds the closed, open or permanently closed period associated with this
  --   date.
  -- History
  --   21-FEB-97        R Goyal    Created
  -- Arguments
  --   lgr_id			Current ledger
  --   calendar			Calendar used by current ledger
  --   per_type			Accounting Period Type of current ledger
  --   active_date		Date of interest
  --   from_period		The desired period
  --   per_start_date		The desired period's start date
  --   per_end_date		The desired period's end date
  --   per_number		The desired period's number
  --   per_year			The desired period's year
  -- Notes
  --
  PROCEDURE find_from_period(	lgr_id			NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				from_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
			 	per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY 	NUMBER
			      );


END GL_DATE_HANDLER_PKG;

 

/
