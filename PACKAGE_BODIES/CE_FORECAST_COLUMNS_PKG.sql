--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_COLUMNS_PKG" AS
/* $Header: cefcolb.pls 120.1 2002/11/12 21:19:39 bhchung ship $ */
--
-- Package
--   CE_FORECAST_COLUMNS_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   ce_forecast_columns table.
-- History
--   07.10.96   C. Kawamoto   Created
--

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;
  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Checks the uniqueness of the forecast column inserted.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_COLUMNS_PKG.Check_Unique(...)
  -- Notes
  --

  PROCEDURE Check_Unique(
		X_rowid			VARCHAR2,
		X_forecast_header_id	NUMBER,
		X_column_number		NUMBER) IS
	CURSOR chk_duplicates IS
		SELECT 'Duplicate'
		FROM ce_forecast_columns cfc
		WHERE cfc.forecast_header_id = X_forecast_header_id
	 	AND   cfc.column_number = X_column_number
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
		FND_MESSAGE.Set_Token('PROCEDURE', 'ce_cf_columns_pkg.check_unique');
	RAISE;
  END Check_Unique;

  --
  -- Procedure
  --   Check_Unique_Aging
  -- Purpose
  --   Checks the uniqueness of the forecast agings inserted.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_COLUMNS_PKG.Check_Unique_Aging(...)
  -- Notes
  --

  PROCEDURE Check_Unique_Aging(
		X_rowid			VARCHAR2,
		X_forecast_header_id	NUMBER,
		X_days_from		NUMBER,
		X_days_to		NUMBER) IS
	CURSOR chk_duplicate_agings IS
		SELECT 'Duplicate'
		FROM ce_forecast_columns cfc
		WHERE cfc.forecast_header_id = X_forecast_header_id
	 	AND   cfc.days_from = X_days_from
		AND   cfc.days_to = X_days_to
		AND  (X_rowid IS NULL
		   OR cfc.rowid <> chartorowid(X_rowid));
	dummy VARCHAR2(100);
  BEGIN
	OPEN chk_duplicate_agings;
	FETCH chk_duplicate_agings INTO dummy;

	IF chk_duplicate_agings%FOUND THEN
		FND_MESSAGE.Set_Name('CE', 'CE_DUPLICATE_FORECAST_AGING');
		APP_EXCEPTION.Raise_exception;
	END IF;
	CLOSE chk_duplicate_agings;

  EXCEPTION
	WHEN APP_EXCEPTIONS.application_exception THEN
		RAISE;
	WHEN OTHERS THEN
		FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
		FND_MESSAGE.Set_Token('PROCEDURE', 'ce_cf_columns_pkg.check_unique_aging');
	RAISE;
  END Check_Unique_Aging;


  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   To insert new row to ce_forecast_columns.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_COLUMNS_PKG.Insert_Row(...)
  -- Notes
  --

  PROCEDURE Insert_Row(
		X_rowid			IN OUT NOCOPY	VARCHAR2,
		X_forecast_column_id	IN OUT NOCOPY	NUMBER,
		X_forecast_header_id		NUMBER,
		X_column_number			NUMBER,
		X_days_from			NUMBER,
		X_days_to			NUMBER,
		X_developer_column_num		NUMBER,
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
		X_attribute15			VARCHAR2
	) IS
		CURSOR C IS SELECT rowid FROM ce_forecast_columns
			WHERE forecast_column_id = TO_NUMBER(X_forecast_column_id);
                CURSOR C2 IS SELECT ce_forecast_columns_s.nextval FROM sys.dual;
	BEGIN
		OPEN C2;
		FETCH C2 INTO X_forecast_column_id;
		CLOSE C2;

		INSERT INTO ce_forecast_columns(
			forecast_column_id,
			forecast_header_id,
			column_number,
			days_from,
			days_to,
			developer_column_num,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15
		) VALUES (
			X_forecast_column_id,
			X_forecast_header_id,
			X_column_number,
			X_days_from,
			X_days_to,
			X_developer_column_num,
			X_created_by,
			X_creation_date,
			X_last_updated_by,
			X_last_update_date,
			X_last_update_login,
			X_attribute_category,
			X_attribute1,
			X_attribute2,
			X_attribute3,
			X_attribute4,
			X_attribute5,
			X_attribute6,
			X_attribute7,
			X_attribute8,
			X_attribute9,
			X_attribute10,
			X_attribute11,
			X_attribute12,
			X_attribute13,
			X_attribute14,
			X_attribute15
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
  --   To lock a row from ce_forecast_columns.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_COLUMNS_PKG.Lock_Row(...)
  -- Notes
  --

  PROCEDURE Lock_Row(
		X_rowid				VARCHAR2,
		X_forecast_column_id		NUMBER,
		X_forecast_header_id		NUMBER,
		X_column_number			NUMBER,
		X_days_from			NUMBER,
		X_days_to			NUMBER,
		X_developer_column_num		NUMBER,
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
		X_attribute15			VARCHAR2
	) IS
		CURSOR C IS
			SELECT *
			FROM ce_forecast_columns
			WHERE rowid = X_rowid
			FOR UPDATE of forecast_column_id NOWAIT;
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
			(Recinfo.forecast_column_id = X_forecast_column_id)
		   AND  (Recinfo.forecast_header_id = X_forecast_header_id)
		   AND  (Recinfo.column_number = X_column_number)
		   AND  (Recinfo.days_from = X_days_from)
		   AND  (Recinfo.days_to = X_days_to)
	   	   AND  (    (Recinfo.developer_column_num = X_developer_column_num)
			 OR  (  (Recinfo.developer_column_num IS NULL)
			     AND (X_developer_column_num IS NULL)))
	   	   AND  (    (Recinfo.attribute_category = X_attribute_category)
			 OR  (  (Recinfo.attribute_category IS NULL)
			     AND (X_attribute_category IS NULL)))
		   AND  (    (Recinfo.attribute1 = X_attribute1)
			 OR  (  (Recinfo.attribute1 IS NULL)
			     AND (X_attribute1 IS NULL)))
		   AND  (    (Recinfo.attribute2 = X_attribute2)
			 OR  (  (Recinfo.attribute2 IS NULL)
			     AND (X_attribute2 IS NULL)))
		   AND  (    (Recinfo.attribute3 = X_attribute3)
			 OR  (  (Recinfo.attribute3 IS NULL)
			     AND (X_attribute3 IS NULL)))
		   AND  (    (Recinfo.attribute4 = X_attribute4)
			 OR  (  (Recinfo.attribute4 IS NULL)
			     AND (X_attribute4 IS NULL)))
		   AND  (    (Recinfo.attribute5 = X_attribute5)
			 OR  (  (Recinfo.attribute5 IS NULL)
			     AND (X_attribute5 IS NULL)))
		   AND  (    (Recinfo.attribute6 = X_attribute6)
			 OR  (  (Recinfo.attribute6 IS NULL)
			     AND (X_attribute6 IS NULL)))
		   AND  (    (Recinfo.attribute7 = X_attribute7)
			 OR  (  (Recinfo.attribute7 IS NULL)
			     AND (X_attribute7 IS NULL)))
		   AND  (    (Recinfo.attribute8 = X_attribute8)
			 OR  (  (Recinfo.attribute8 IS NULL)
			     AND (X_attribute8 IS NULL)))
		   AND  (    (Recinfo.attribute9 = X_attribute9)
			 OR  (  (Recinfo.attribute9 IS NULL)
			     AND (X_attribute9 IS NULL)))
		   AND  (    (Recinfo.attribute10 = X_attribute10)
			 OR  (  (Recinfo.attribute10 IS NULL)
			     AND (X_attribute10 IS NULL)))
		   AND  (    (Recinfo.attribute11 = X_attribute11)
			 OR  (  (Recinfo.attribute11 IS NULL)
			     AND (X_attribute11 IS NULL)))
		   AND  (    (Recinfo.attribute12 = X_attribute12)
			 OR  (  (Recinfo.attribute12 IS NULL)
			     AND (X_attribute12 IS NULL)))
		   AND  (    (Recinfo.attribute13 = X_attribute13)
			 OR  (  (Recinfo.attribute13 IS NULL)
			     AND (X_attribute13 IS NULL)))
		   AND  (    (Recinfo.attribute14 = X_attribute14)
			 OR  (  (Recinfo.attribute14 IS NULL)
			     AND (X_attribute14 IS NULL)))
		   AND  (    (Recinfo.attribute15 = X_attribute15)
			 OR  (  (Recinfo.attribute15 IS NULL)
			     AND (X_attribute15 IS NULL)))
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
  --   To update ce_forecast_columns with changes made.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_COLUMNS_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(
		X_rowid				VARCHAR2,
		X_forecast_column_id		NUMBER,
		X_forecast_header_id		NUMBER,
		X_column_number			NUMBER,
		X_days_from			NUMBER,
		X_days_to			NUMBER,
		X_developer_column_num		NUMBER,
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
		X_attribute15			VARCHAR2
	) IS
  BEGIN
	UPDATE ce_forecast_columns
	SET
		forecast_column_id	= X_forecast_column_id,
		forecast_header_id 	= X_forecast_header_id,
		column_number		= X_column_number,
		days_from		= X_days_from,
		days_to			= X_days_to,
		developer_column_num	= X_developer_column_num,
		attribute_category	= X_attribute_category,
		attribute1		= X_attribute1,
		attribute2		= X_attribute2,
		attribute3		= X_attribute3,
		attribute4		= X_attribute4,
		attribute5		= X_attribute5,
		attribute6		= X_attribute6,
		attribute7		= X_attribute7,
		attribute8		= X_attribute8,
		attribute9		= X_attribute9,
		attribute10		= X_attribute10,
		attribute11		= X_attribute11,
		attribute12		= X_attribute12,
		attribute13		= X_attribute13,
		attribute14		= X_attribute14,
		attribute15		= X_attribute15
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Update_Row;

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   To delete a  row from ce_forecast_columns.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_COLUMNS_PKG.Delete_Row(...);
  -- Notes
  --
  PROCEDURE Delete_Row(X_rowid VARCHAR2) IS
  BEGIN
	DELETE FROM ce_forecast_columns
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Delete_Row;

  PROCEDURE Delete_Forecast_Cells(X_rowid VARCHAR2) IS
        p_forecast_header_id    NUMBER;
        p_forecast_column_id       NUMBER;
  BEGIN
  --
  -- delete all forecast cells that belong to the template column
  --
        SELECT     forecast_header_id, forecast_column_id
        INTO       p_forecast_header_id, p_forecast_column_id
        FROM       CE_FORECAST_COLUMNS
        WHERE      rowid = X_rowid;

        DELETE FROM CE_FORECAST_CELLS
        WHERE       forecast_header_id = p_forecast_header_id AND
                    forecast_column_id    = p_forecast_column_id;

  END Delete_Forecast_Cells;


END CE_FORECAST_COLUMNS_PKG;

/
