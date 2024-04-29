--------------------------------------------------------
--  DDL for Package GL_BUDGET_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: glibdbts.pls 120.6 2005/05/05 01:01:05 kvora ship $ */
--
-- Package
--   gl_budget_batches_pkg
-- Purpose
--   To contain validation and insertion routines for gl_budget_batches
-- History
--   10-18-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   insert_budget
  -- Purpose
  --   Used to insert records into gl_budget_batches
  --   for a new budget.
  -- History
  --   10-18-93  D. J. Ogg    Created
  -- Arguments
  --   x_budget_version_id	Version ID of the new budget
  --   x_ledger_id              Ledger budget belongs to
  --   x_last_updated_by	User ID of last person to
  --				update the budget
  -- Example
  --   gl_budget_batches_pkg.insert_budget(1000, 2, 0)
  -- Notes
  --
  PROCEDURE insert_budget(
  			x_budget_version_id	NUMBER,
			x_ledger_id      	NUMBER,
			x_last_updated_by	NUMBER);

  --
  -- Procedure
  --   insert_recurring
  -- Purpose
  --   Used to insert records into gl_budget_batches for the new created
  --   recurring formula budget.
  -- History
  --   20-FEB-1994  ERumanan  Created.
  -- Arguments
  --   x_recurring_batch_id     Recurring Batch ID of the new budget formula
  --   x_last_updated_by        User ID of last person to
  --                            update the budget
  -- Example
  --   gl_budget_batches_pkg.insert_recurring( 100, 0 )
  -- Notes
  --
  PROCEDURE insert_recurring(
                        x_recurring_batch_id    NUMBER,
                        x_last_updated_by       NUMBER );


  --
  -- Procedure
  --   delete_recurring
  -- Purpose
  --   Used to delete records from gl_budget_batches for the deleted
  --   recurring formula budget.
  -- History
  --   20-FEB-1994  ERumanan  Created.
  -- Arguments
  --   x_recurring_batch_id     Recurring Batch ID of the new budget formula
  -- Example
  --   gl_budget_batches_pkg.delete_recurring( 100 )
  -- Notes
  --
  PROCEDURE delete_recurring( x_recurring_batch_id    NUMBER );


  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_budget_batches.
  -- History
  --   26-MAR-94  ERumanan  Created.
  -- Arguments
  --   recinfo
  --   gl_budget_batches
  -- Example
  --   select_row.recinfo;
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_budget_batches%ROWTYPE );


  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the values for some columns.
  -- History
  --   26-MAR-94  ERumanan  Created.
  -- Arguments
  --   x_budget_version_id
  --   x_recurring_batch_id
  --   x_last_executed_date
  --   x_last_executed_start_period
  --   x_last_executed_end_period
  --   x_status
  -- Example
  --   gl_budget_batches_pkg.select_columns( :block.x_budget_version_id,
  --     :block.x_recurring_batch_id,
  --     :block.x_last_executed_date,
  --     :block.x_last_executed_start_period,
  --     :block.x_last_executed_end_period,
  --     :block.x_status );
  -- Notes
  --
  PROCEDURE select_columns(
    x_budget_version_id            	NUMBER,
    x_recurring_batch_id           	NUMBER,
    x_last_executed_date           	IN OUT NOCOPY  DATE,
    x_last_executed_start_period   	IN OUT NOCOPY  VARCHAR2,
    x_last_executed_end_period		IN OUT NOCOPY  VARCHAR2,
    x_status          			IN OUT NOCOPY  VARCHAR2 );



END gl_budget_batches_pkg;

 

/
