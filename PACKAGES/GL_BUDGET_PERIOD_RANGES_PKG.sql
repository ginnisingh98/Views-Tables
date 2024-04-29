--------------------------------------------------------
--  DDL for Package GL_BUDGET_PERIOD_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_PERIOD_RANGES_PKG" AUTHID CURRENT_USER AS
/* $Header: glibpras.pls 120.3 2005/05/05 01:03:16 kvora ship $  */
--
-- Package
--    gl_budget_period_ranges_pkg
-- Purpose
--   To contain validation and insertion routines for gl_budget_period_ranges
-- History
--   06-14-94  	Kai Pigg	Created

  --
  -- Procedure
  --   get_open_flag
  -- Purpose
  --   To get the open_flag ffor given budget_version and year
  -- History
  --   06-14-94	Kai Pigg		Created
  -- Arguments
  --   x_budget_version_id	Budget Version Id
  --   x_period_year		Period Year
  --   x_open_flag		Open Flag
  -- Example
  --   gl_period_statuses_pkg.get_open_flag(
  --     :block.budget_version_id,
  --     :block.period_year,
  --     :block.open_flag);
  -- Notes
  --
PROCEDURE get_open_flag(
	x_budget_version_id	NUMBER,
       	x_period_year		NUMBER,
        x_open_flag 	IN OUT NOCOPY 	VARCHAR2 );


END  gl_budget_period_ranges_pkg;

 

/
