--------------------------------------------------------
--  DDL for Package GL_ENTITY_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ENTITY_BUDGETS_PKG" AUTHID CURRENT_USER AS
/* $Header: glibdebs.pls 120.3 2005/05/05 01:01:37 kvora ship $ */
--
-- Package
--   gl_entity_budgets_pkg
-- Purpose
--   To contain validation and insertion routines for gl_entity_budgets
-- History
--   10-18-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   insert_budget
  -- Purpose
  --   Used to insert records into gl_entity_budgets
  --   for a new budget.
  -- History
  --   10-18-93  D. J. Ogg    Created
  -- Arguments
  --   x_budget_version_id	Version ID of the new budget
  --   x_ledger_id		Ledger the new budget belongs to
  --   x_last_updated_by	User ID of last person to
  --				update the budget
  --   x_last_update_login      Login ID of last period to update the budget
  -- Example
  --   gl_entity_budgets_pkg.insert_budget(1000, 2, 0, 0)
  -- Notes
  --
  PROCEDURE insert_budget(
  			x_budget_version_id	NUMBER,
			x_ledger_id		NUMBER,
			x_last_updated_by	NUMBER,
			x_last_update_login     NUMBER);

  --
  -- Procedure
  --   insert_entity
  -- Purpose
  --   Used to insert records into gl_entity_budgets
  --   for a new budget organization.
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   x_budget_entity_id	ID of the new budget organization
  --   x_ledger_id		Ledger the new budget organization
  --                            belongs to
  --   x_last_updated_by	User ID of last person to
  --				update the budget
  --   x_last_update_login      Login ID of last period to update the budget
  -- Example
  --   gl_entity_budgets_pkg.insert_entity(1000, 2, 0, 0)
  -- Notes
  --
  PROCEDURE insert_entity(
  			x_budget_entity_id	NUMBER,
			x_ledger_id		NUMBER,
			x_last_updated_by	NUMBER,
			x_last_update_login     NUMBER);

END gl_entity_budgets_pkg;

 

/
