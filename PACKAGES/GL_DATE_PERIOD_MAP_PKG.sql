--------------------------------------------------------
--  DDL for Package GL_DATE_PERIOD_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DATE_PERIOD_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: gliprmps.pls 120.3 2005/05/05 01:18:05 kvora ship $ */
--
-- Package
--  gl_date_period_map_pkg
-- Purpose
--   To contain procedures for maintaining of the GL_DATE_PERIOD_MAP table
-- History
--   12-04-95  	E Weinstein	Created
  --
  -- Procedure
  --   maintain_date_period_map
  -- Purpose
  --   maintains GL_DATE_PERIOD_MAP table
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_period_set_name	Name of the calendar
  --				containing the period
  --   x_period_type		Type of the period
  --   x_adjust_period_flag	Calendar period adjustment status
  --   x_operation		UPDATE or INSERT
  --   x_start_date		date on which accounting period begins
  --   x_end_date		date on which accounting period ends
  --   x_period_name		system genrated accounting period name
  -- Example
  --  maintain_date_period_map ('Barclays', 'Month', 'N', 'UPDATE',
  -- TO_DATE('01-02-1996','DD-MM-YYYY'), TO_DATE('28-02-1996','DD-MM-YYYY'),
  -- 'FEB-96', sysdate,0,sysdate,0,0);
  -- Notes
  --
PROCEDURE maintain_date_period_map
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_adjust_period_flag	VARCHAR2,
			x_operation		VARCHAR2,
			x_start_date		DATE,
			x_end_date		DATE,
			x_period_name		VARCHAR2,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			);

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select period_name given period_set_name, period_type
  --   and accounting_date.
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_period_set_name	Name of the calendar
  --				containing the period
  --   x_period_type		Type of the period
  --   x_accounting_date	Date for which we want to find the period
  --   x_period_name		period_name which will be returned
  -- Example
  --  select_columns('Standard', 'Month', '10-MAY-96', x_period_name);
  -- Notes
  --
PROCEDURE select_columns
			(
			x_period_set_name 	       VARCHAR2,
			x_period_type     	       VARCHAR2,
			x_accounting_date	       DATE,
			x_period_name		IN OUT NOCOPY VARCHAR2);


END gl_date_period_map_pkg;

 

/
