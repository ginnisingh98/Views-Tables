--------------------------------------------------------
--  DDL for Package CE_FORECAST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: cefhdrs.pls 120.1 2002/11/12 21:23:52 bhchung ship $ 	*/
--
-- Package
--   CE_FORECAST_HEADERS_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   ce_forecast_headers table.
-- History
--   07.10.96   C. Kawamoto   Created
--

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Checks the uniqueness of the forecast inserted.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Check_Unique(...);
  -- Notes
  --
  PROCEDURE Check_Unique(
		X_rowid			VARCHAR2,
		X_name			VARCHAR2);

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   To insert new row to ce_forecast_headers.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Insert_Row(...)
  -- Notes
  --

  PROCEDURE Insert_Row(
		X_rowid			IN OUT NOCOPY	VARCHAR2,
		X_forecast_header_id	IN OUT NOCOPY	NUMBER,
		X_name				VARCHAR2,
		X_description			VARCHAR2,
		X_aging_type			VARCHAR2,
		X_overdue_transactions		VARCHAR2,
		X_cutoff_period			NUMBER,
		X_transaction_calendar_id	NUMBER,
                X_start_project_id		NUMBER,
                X_end_project_id		NUMBER,
		X_treasury_template		VARCHAR2,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER,
		X_attribute_category		VARCHAR2,
		X_attribute1			VARCHAR2,
		X_attribute2			VARCHAR2,
		X_attribute3			VARCHAR2,
		X_attribute4			VARCHAR2,
		X_attribute5			VARCHAR2,
		X_attribute6			VARCHAR2,
		X_attribute7			VARCHAR2,
		X_attribute8			VARCHAR2,
		X_attribute9			VARCHAR2,
		X_attribute10			VARCHAR2,
		X_attribute11			VARCHAR2,
		X_attribute12			VARCHAR2,
		X_attribute13			VARCHAR2,
		X_attribute14			VARCHAR2,
		X_attribute15			VARCHAR2);

  --
  -- Procedure
  --   lock_row
  -- Purpose
  --   To lock a row from ce_forecast_headers.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Lock_Row(...)
  -- Notes
  --


  PROCEDURE Lock_Row(
		X_rowid				VARCHAR2,
		X_forecast_header_id		NUMBER,
		X_name				VARCHAR2,
		X_description			VARCHAR2,
		X_aging_type			VARCHAR2,
		X_overdue_transactions		VARCHAR2,
		X_cutoff_period			NUMBER,
		X_transaction_calendar_id	NUMBER,
                X_start_project_id		NUMBER,
                X_end_project_id		NUMBER,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER,
		X_attribute_category		VARCHAR2,
		X_attribute1			VARCHAR2,
		X_attribute2			VARCHAR2,
		X_attribute3			VARCHAR2,
		X_attribute4			VARCHAR2,
		X_attribute5			VARCHAR2,
		X_attribute6			VARCHAR2,
		X_attribute7			VARCHAR2,
		X_attribute8			VARCHAR2,
		X_attribute9			VARCHAR2,
		X_attribute10			VARCHAR2,
		X_attribute11			VARCHAR2,
		X_attribute12			VARCHAR2,
		X_attribute13			VARCHAR2,
		X_attribute14			VARCHAR2,
		X_attribute15			VARCHAR2);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   To update ce_forecast_headers with changes made.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Update_Row(...)
  -- Notes
  --
  PROCEDURE Update_Row(
		X_rowid				VARCHAR2,
		X_forecast_header_id		NUMBER,
		X_name				VARCHAR2,
		X_description			VARCHAR2,
		X_aging_type			VARCHAR2,
		X_overdue_transactions		VARCHAR2,
		X_cutoff_period			NUMBER,
		X_transaction_calendar_id	NUMBER,
                X_start_project_id		NUMBER,
                X_end_project_id		NUMBER,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER,
		X_attribute_category		VARCHAR2,
		X_attribute1			VARCHAR2,
		X_attribute2			VARCHAR2,
		X_attribute3			VARCHAR2,
		X_attribute4			VARCHAR2,
		X_attribute5			VARCHAR2,
		X_attribute6			VARCHAR2,
		X_attribute7			VARCHAR2,
		X_attribute8			VARCHAR2,
		X_attribute9			VARCHAR2,
		X_attribute10			VARCHAR2,
		X_attribute11			VARCHAR2,
		X_attribute12			VARCHAR2,
		X_attribute13			VARCHAR2,
		X_attribute14			VARCHAR2,
		X_attribute15			VARCHAR2);

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   To delete a  row from ce_forecast_headers.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Delete_Row(...)
  -- Notes
  --
PROCEDURE Delete_Row(X_rowid VARCHAR2);

  --
  -- Procedure
  --   Delete_Forecasts
  -- Purpose
  --   To delete all forecasts and cells belonging the forecast template
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Delete_Forecasts(...)
  -- Notes
  --
PROCEDURE Delete_Forecasts(X_rowid VARCHAR2);

END CE_FORECAST_HEADERS_PKG;

 

/
