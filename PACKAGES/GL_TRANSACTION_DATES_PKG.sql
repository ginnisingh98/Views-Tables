--------------------------------------------------------
--  DDL for Package GL_TRANSACTION_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TRANSACTION_DATES_PKG" AUTHID CURRENT_USER AS
  /* $Header: glitcdas.pls 120.2 2005/05/05 01:28:49 kvora ship $ */
--
-- Package
--  gl_transaction_dates_pkg
-- Purpose
--   To contain procedures for maintaining of the GL_TRANSACTION_DATES table
-- History
--   12-04-95  	E Weinstein	Created
  --
  -- Procedure
  --   extend_transaction_calendars
  -- Purpose
  --   maintains GL_TRANSACTION_DATES table
  -- History
  -- 12-04-95  	E Weinstein  	Created
  -- Arguments
  --   x_period_set_name	Name of the calendar
  --				containing the period
  --   x_period_type		Type of the period
  --   x_entered_year		the year which was entered for a period
  -- Example
  --  gl_transaction_dates_pkg.extend_transaction_calendars('Barclays',
  --  'Month','1997',sysdate,0,sysdate,0,0);
  -- Notes
  --
PROCEDURE extend_transaction_calendars
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_entered_year	  	VARCHAR2,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			);
  --
  -- Procedure
  --   insert_all_years_for_calendar
  -- Purpose
  --   maintains GL_TRANSACTION_DATES table
  -- History
  -- 12-12-95  	E Weinstein  	Created
  -- Arguments
  --   x_transaction_calendar_id	transaction_calendar_id from
  --					GL_TRANSACTION_CALENDAR
  -- Example
  --  gl_transaction_dates_pkg.insert_all_years_for_calendar
  --                                           (3,sysdate,0,sysdate,0,0);
  -- Notes
  --
PROCEDURE insert_all_years_for_calendar
			(
			x_transaction_calendar_id	NUMBER,
			x_CREATION_DATE			DATE,
			x_CREATED_BY			NUMBER,
			x_LAST_UPDATE_DATE		DATE,
			x_LAST_UPDATED_BY		NUMBER,
			x_LAST_UPDATE_LOGIN		NUMBER
			);
END gl_transaction_dates_pkg;

 

/
