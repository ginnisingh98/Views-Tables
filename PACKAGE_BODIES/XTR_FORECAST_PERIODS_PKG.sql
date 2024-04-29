--------------------------------------------------------
--  DDL for Package Body XTR_FORECAST_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FORECAST_PERIODS_PKG" AS
/* $Header: xtrfprdb.pls 115.1 99/07/17 00:30:48 porting ship $ */
--
-- Package
--   XTR_FORECAST_PERIODS_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   xtr_forecast_periods table.
-- History
--   12/24/98   BHCHUNG   Created
--


  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Checks the uniqueness of the forecast period inserted.
  -- History
  --   12/24/98   BHCHUNG   Created
  -- Example
  --   XTR_FORECAST_PERIODS_PKG.Check_Unique(...)
  -- Notes
  --

  PROCEDURE Check_Unique(
		X_rowid			VARCHAR2,
		X_forecast_header_id	NUMBER,
		X_period_number		NUMBER) IS
	CURSOR chk_duplicates IS
		SELECT 'Duplicate'
		FROM xtr_forecast_periods cfc
		WHERE cfc.forecast_header_id = X_forecast_header_id
	 	AND   cfc.period_number = X_period_number
		AND  (X_rowid IS NULL
		   OR cfc.rowid <> chartorowid(X_rowid));
	dummy VARCHAR2(100);
  BEGIN
	OPEN chk_duplicates;
	FETCH chk_duplicates INTO dummy;

	IF chk_duplicates%FOUND THEN
		FND_MESSAGE.Set_Name('CE', 'CE_DUPLICATE_COLUMN_NUMBER');
		APP_EXCEPTION.Raise_exception;
	END IF;
	CLOSE chk_duplicates;

  EXCEPTION
	WHEN APP_EXCEPTIONS.application_exception THEN
		RAISE;
	WHEN OTHERS THEN
		FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
		FND_MESSAGE.Set_Token('PROCEDURE', 'ce_cf_periods_pkg.check_unique');
	RAISE;
  END Check_Unique;

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
		X_last_update_login		NUMBER
	) IS
		CURSOR C IS SELECT rowid FROM xtr_forecast_periods
			WHERE forecast_period_id = TO_NUMBER(X_forecast_period_id);
                CURSOR C2 IS SELECT ce_forecast_columns_s.nextval FROM sys.dual;


	BEGIN
		OPEN C2;
		FETCH C2 INTO X_forecast_period_id;
		CLOSE C2;

		INSERT INTO xtr_forecast_periods(
			forecast_period_id,
			forecast_header_id,
			period_number,
			level_of_summary,
			length_of_period,
			length_type,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login
		) VALUES (
			X_forecast_period_id,
			X_forecast_header_id,
			X_period_number,
			X_level_of_summary,
			X_length_of_period,
			X_length_type,
			X_created_by,
			X_creation_date,
			X_last_updated_by,
			X_last_update_date,
			X_last_update_login
		);
		OPEN C;
		FETCH C INTO X_rowid;
		if (C%NOTFOUND) then
			CLOSE C;
			Raise NO_DATA_FOUND;
		end if;
		CLOSE C;
	END Insert_Row;
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
		X_last_update_login		NUMBER
	) IS
		CURSOR C IS
			SELECT *
			FROM xtr_forecast_periods
			WHERE rowid = X_rowid
			FOR UPDATE of forecast_period_id NOWAIT;
		Recinfo C%ROWTYPE;
  BEGIN
	OPEN C;
	FETCH C INTO recinfo;
	if (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
			(Recinfo.forecast_period_id = X_forecast_period_id)
		   AND  (Recinfo.forecast_header_id = X_forecast_header_id)
		   AND  (Recinfo.period_number = X_period_number)
		   AND  (Recinfo.level_of_summary = X_level_of_summary)
		   AND  (Recinfo.length_of_period = X_length_of_period)
	   	   AND  (Recinfo.length_type = X_length_type)
	) then
	return;
	else
		FND_MESSAGE.Set_name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;
  END Lock_Row;

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
		X_last_update_login		NUMBER
	) IS
  BEGIN
	UPDATE xtr_forecast_periods
	SET
		forecast_period_id	= X_forecast_period_id,
		forecast_header_id 	= X_forecast_header_id,
		period_number		= X_period_number,
		level_of_summary	= X_level_of_summary,
		length_of_period	= X_length_of_period,
		length_type		= X_length_type
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Update_Row;

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
  PROCEDURE Delete_Row(X_rowid VARCHAR2) IS
  BEGIN
	DELETE FROM xtr_forecast_periods
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Delete_Row;

END XTR_FORECAST_PERIODS_PKG;


/
