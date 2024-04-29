--------------------------------------------------------
--  DDL for Package XTR_FORECAST_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FORECAST_PERIODS_PKG" AUTHID CURRENT_USER as
/* $Header: xtrfprds.pls 115.0 99/07/17 00:30:52 porting ship $	*/
--
-- Package
--   XTR_FORECAST_PERIODS_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   xtr_forecast_PERIODs table.
-- History
--   12/24/98   BHCHUNG   Created
--


  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Checks the uniqueness of the forecast PERIOD inserted.
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Check_Unique(...);
  -- Notes
  --
  PROCEDURE Check_Unique(
		X_rowid			VARCHAR2,
		X_forecast_header_id    NUMBER,
		X_period_number		NUMBER);

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   To insert new row to xtr_forecast_periods.
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Insert_Row(...)
  -- Notes
  --

  PROCEDURE Insert_Row(
		X_rowid			IN OUT	VARCHAR2,
		X_forecast_period_id	IN OUT	NUMBER,
		X_forecast_header_id		NUMBER,
		X_period_number			NUMBER,
		X_level_of_summary		VARCHAR2,
		X_length_of_period		NUMBER,
		X_length_type			VARCHAR2,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER);

  --
  -- Procedure
  --   lock_row
  -- Purpose
  --   To lock a row from xtr_forecast_periods.
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Lock_Row(...)
  -- Notes
  --


PROCEDURE Lock_Row(
		X_rowid				VARCHAR2,
		X_forecast_period_id		NUMBER,
		X_forecast_header_id		NUMBER,
		X_period_number			NUMBER,
		X_level_of_summary		VARCHAR2,
		X_length_of_period		NUMBER,
		X_length_type			VARCHAR2,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   To update xtr_forecast_periods with changes made.
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(
		X_rowid				VARCHAR2,
		X_forecast_period_id		NUMBER,
		X_forecast_header_id		NUMBER,
		X_period_number			NUMBER,
		X_level_of_summary		VARCHAR2,
		X_length_of_period		NUMBER,
		X_length_type			VARCHAR2,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER);

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   To delete a  row from xtr_forecast_periods.
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Delete_Row(...);
  -- Notes
  --
PROCEDURE Delete_Row(X_rowid VARCHAR2);

/*
  --
  -- Procedure
  --   Delete_Forecast_Cells
  -- Purpose
  --   To delete all forecast cells belonging the forecast template period
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Delete_Forecast_Cells(...)
  -- Notes
  --
PROCEDURE Delete_Forecast_Cells(X_rowid VARCHAR2);
*/

END XTR_FORECAST_PERIODS_PKG;


 

/
