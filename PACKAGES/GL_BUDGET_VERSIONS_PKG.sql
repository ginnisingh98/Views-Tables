--------------------------------------------------------
--  DDL for Package GL_BUDGET_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_VERSIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: glibdves.pls 120.3 2005/05/05 01:02:31 kvora ship $ */
--
-- Package
--   gl_budget_versions_pkg
-- Purpose
--   To contain validation and insertion routines for gl_budget_versions
-- History
--   10-18-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   insert_record
  -- Purpose
  --   Used to insert records into gl_budget_versions
  --   for a new budget.
  -- History
  --   10-18-93  D. J. Ogg    Created
  -- Arguments
  --   x_budget_version_id	Version ID of the new budget
  --   x_budget_name            Name of the new budget
  --   x_status			Status of the new budget
  --   x_master_budget_ver_id   Version ID of the master budget of the new
  --                            budget
  --   x_last_updated_by	User ID of last person to
  --				update the budget
  --   x_last_update_login	Login ID of the last person
  --				to update the budget
  -- Example
  --   gl_budget_versions_pkg.insert_record(
  --       1000, '3 Year Budget', 'O', null, 0, 0)
  -- Notes
  --
  PROCEDURE insert_record(
  			x_budget_version_id	NUMBER,
			x_budget_name           VARCHAR2,
			x_status		VARCHAR2,
			x_master_budget_ver_id  NUMBER,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER);

  --
  -- Procedure
  --   update_record
  -- Purpose
  --   Updates the entry in gl_budget_versions associated with a given
  --   budget.
  -- History
  --   10-18-93  D. J. Ogg    Created
  -- Arguments
  --   x_budget_version_id	Version ID of the budget
  --   x_budget_name            Name of the budget
  --   x_status			Status of the budget
  --   x_master_budget_ver_id   Version ID of the master budget of the
  --                            budget
  --   x_last_updated_by	User ID of last person to
  --				update the period
  --   x_last_update_login	Login ID of the last person
  --				to update the period
  -- Example
  --   gl_budget_versions_pkg.update_record(
  --       1000, '3 Year Budget', 'O', null, 0, 0)
  -- Notes
  --
  PROCEDURE update_record(
  			x_budget_version_id	NUMBER,
			x_budget_name           VARCHAR2,
			x_status		VARCHAR2,
			x_master_budget_ver_id  NUMBER,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER);

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the values of some columns from gl_budget_versions associated
  --   with the given budget version id
  -- History
  --   01-NOV-94  D. J. Ogg	Created
  -- Arguments
  --   x_budget_version_id		ID of the desired budget
  --   x_budget_name			Name of the budget
  --
  PROCEDURE select_columns(
	      x_budget_version_id			NUMBER,
	      x_budget_name			IN OUT NOCOPY  VARCHAR2);

END gl_budget_versions_pkg;

 

/
