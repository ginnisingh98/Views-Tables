--------------------------------------------------------
--  DDL for Package GL_RECURRING_VALID_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RECURRING_VALID_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: glirjvps.pls 120.4 2005/05/05 01:20:45 kvora ship $ */
--
-- Package
--   gl_recurring_valid_periods_pkg
-- Purpose
--   To retrieve the information from the gl_recurring_valid_periods_v view.
-- History
--   07/10/96   W Ho  		Created

  --
  -- Procedure
  --   get_next_period
  -- Purpose
  --   To get the next open period and return it in x_next_period.
  -- History
  --   07/10/96  W Ho         Created
  -- Arguments
  --   x_ledger_id              Ledger id
  --   x_recurring_batch_id     Recurring batch id
  --   x_period			Last executed period
  --   x_next_period            Next open period
  -- Example
  --   gl_recurring_valid_periods_pkg.get_next_period(
  --     :block.ledger_id,
  --     :block.recurring_batch_id,
  --     :block.period,
  --     :block.next_period );
  -- Notes
  --
PROCEDURE get_next_period(
	x_ledger_id             NUMBER,
	x_recurring_batch_id    NUMBER,
       	x_period		VARCHAR2,
        x_next_period	IN OUT NOCOPY VARCHAR2 );


END gl_recurring_valid_periods_pkg;

 

/
