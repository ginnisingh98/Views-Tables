--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_HEADERS_PKG" AS
/* $Header: cefhdrb.pls 120.1 2002/11/12 21:23:33 bhchung ship $ 	*/
--
-- Package
--   CE_FORECASTT_HEADERS_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   ce_forecast_headers table.
-- History
--   07.10.96   C. Kawamoto   	Created
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
  --   Checks the uniqueness of the forecast inserted.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Check_Unique(...);
  -- Notes
  --
  PROCEDURE Check_Unique(
		X_rowid			VARCHAR2,
		X_name			VARCHAR2) IS
	CURSOR chk_duplicates IS
		SELECT 'Duplidate'
		FROM ce_forecast_headers cfh
		WHERE cfh.name = X_name
		AND  (X_rowid IS NULL
		   OR cfh.rowid <> chartorowid(X_rowid));
	dummy VARCHAR2(100);
  BEGIN
	OPEN chk_duplicates;
	FETCH chk_duplicates INTO dummy;

	IF chk_duplicates%FOUND THEN
		FND_MESSAGE.Set_Name('CE', 'CE_DUPLICATE_FORECAST_HDR');
		APP_EXCEPTION.Raise_exception;
	END IF;
	CLOSE chk_duplicates;
  EXCEPTION
	WHEN APP_EXCEPTIONS.application_exception THEN
		RAISE;
	WHEN OTHERS THEn
		FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
		FND_MESSAGE.Set_Token('PROCEDURE', 'ce_cf_headers_pkg.check_unique');
	RAISE;
  END check_unique;

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
		X_attribute15			VARCHAR2
	) IS
		CURSOR C IS SELECT rowid FROM ce_forecast_headers
			WHERE forecast_header_id = X_forecast_header_id;
		CURSOR C2 IS SELECT ce_forecast_headers_s.nextval FROM sys.dual;
		p_row_id		VARCHAR2(100);
		p_forecast_column_id	NUMBER;

	BEGIN
		OPEN C2;
		FETCH C2 INTO X_forecast_header_id;
		CLOSE C2;

		INSERT INTO ce_forecast_headers(
			forecast_header_id,
			name,
			description,
			aging_type,
			overdue_transactions,
			cutoff_period,
			transaction_calendar_id,
                        start_project_id,
                        end_project_id,
                        treasury_template,
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
			X_forecast_header_id,
			X_name,
			X_description,
			X_aging_type,
			X_overdue_transactions,
			X_cutoff_period,
			X_transaction_calendar_id,
                	X_start_project_id,
                	X_end_project_id,
			X_treasury_template,
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

		IF(X_overdue_transactions = 'INCLUDE')THEN
			CE_FORECAST_COLUMNS_PKG.insert_row(
				X_rowid			=> p_row_id,
				X_forecast_column_id    => p_forecast_column_id,
                		X_forecast_header_id    => X_forecast_header_id,
                		X_column_number         => 0,
                		X_days_from             => -X_cutoff_period+1,
                		X_days_to               => 0,
                		X_developer_column_num  => 0,
                		X_created_by            => X_created_by,
                		X_creation_date         => X_creation_date,
                		X_last_updated_by       => X_last_updated_by,
                		X_last_update_date      => X_last_update_date,
                		X_last_update_login     => X_last_update_login,
                		X_attribute_category    => null,
                		X_attribute1            => null,
                		X_attribute2            => null,
                		X_attribute3            => null,
                		X_attribute4            => null,
                		X_attribute5            => null,
                		X_attribute6            => null,
                		X_attribute7            => null,
                		X_attribute8            => null,
                		X_attribute9            => null,
                		X_attribute10           => null,
                		X_attribute11           => null,
                		X_attribute12           => null,
                		X_attribute13           => null,
                		X_attribute14           => null,
                		X_attribute15           => null);
		END IF;

	END Insert_Row;
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
		X_attribute15			VARCHAR2
	) IS
		CURSOR C IS
			SELECT *
			FROM ce_forecast_headers
			WHERE rowid = X_rowid
			FOR UPDATE of forecast_header_id NOWAIT;
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
			(Recinfo.forecast_header_id = X_forecast_header_id)
		   AND  (Recinfo.name = X_name)
	   	   AND  (    (Recinfo.description = X_description)
			 OR  (  (Recinfo.description IS NULL)
			     AND (X_description IS NULL)))
	 	   AND  (Recinfo.aging_type = X_aging_type)
	   	   AND  (    (Recinfo.overdue_transactions = X_overdue_transactions)
			 OR  (  (Recinfo.overdue_transactions IS NULL)
			     AND (X_overdue_transactions IS NULL)))
	   	   AND  (    (Recinfo.cutoff_period = X_cutoff_period)
			 OR  (  (Recinfo.cutoff_period IS NULL)
			     AND (X_cutoff_period IS NULL)))
	   	   AND  (    (Recinfo.transaction_calendar_id = X_transaction_calendar_id)
			 OR  (  (Recinfo.transaction_calendar_id IS NULL)
			     AND (X_transaction_calendar_id IS NULL)))
	   	   AND  (    (Recinfo.start_project_id = X_start_project_id)
			 OR  (  (Recinfo.start_project_id IS NULL)
			     AND (X_start_project_id IS NULL)))
	   	   AND  (    (Recinfo.end_project_id = X_end_project_id)
			 OR  (  (Recinfo.end_project_id IS NULL)
			     AND (X_end_project_id IS NULL)))
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
  --   To update ce_forecast_headers with changes made.
  -- History
  --   07.10.96   C. Kawamoto   Created
  --   07.22.97   W. Chan       Add logic for overdue_transaction and
  --				cutoff_period update
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Update_Row(...);
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
		X_attribute15			VARCHAR2
	) IS
	p_row_id			VARCHAR2(100);
	p_overdue_transactions		VARCHAR2(30);
	p_cutoff_period			NUMBER;
	p_forecast_column_id		NUMBER;
  BEGIN

	SELECT 	overdue_transactions, cutoff_period
	INTO	p_overdue_transactions, p_cutoff_period
	FROM	CE_FORECAST_HEADERS
	WHERE	rowid = X_rowid;

	UPDATE ce_forecast_headers
	SET
		forecast_header_id 	= X_forecast_header_id,
		name			= X_name,
		description		= X_description,
		aging_type		= X_aging_type,
		overdue_transactions	= X_overdue_transactions,
		cutoff_period		= X_cutoff_period,
		transaction_calendar_id = X_transaction_calendar_id,
                start_project_id        = X_start_project_id,
		end_project_id		= X_end_project_id,
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

	--
	-- If overdue_transactions is updated from 'N' to 'Y', insert
	-- new column for overdue transactions in column table
	--
	IF(p_overdue_transactions = 'EXCLUDE' AND
	   X_overdue_transactions = 'INCLUDE')THEN
		CE_FORECAST_COLUMNS_PKG.insert_row(
				X_rowid			=> p_row_id,
				X_forecast_column_id    => p_forecast_column_id,
                		X_forecast_header_id    => X_forecast_header_id,
                		X_column_number         => 0,
                		X_days_from             => -X_cutoff_period+1,
                		X_days_to               => 0,
                		X_developer_column_num  => 0,
                		X_created_by            => X_created_by,
                		X_creation_date         => X_creation_date,
                		X_last_updated_by       => X_last_updated_by,
                		X_last_update_date      => X_last_update_date,
                		X_last_update_login     => X_last_update_login,
                		X_attribute_category    => null,
                		X_attribute1            => null,
                		X_attribute2            => null,
                		X_attribute3            => null,
                		X_attribute4            => null,
                		X_attribute5            => null,
                		X_attribute6            => null,
                		X_attribute7            => null,
                		X_attribute8            => null,
                		X_attribute9            => null,
                		X_attribute10           => null,
                		X_attribute11           => null,
                		X_attribute12           => null,
                		X_attribute13           => null,
                		X_attribute14           => null,
                		X_attribute15           => null);
 	END IF;

	--
	-- If cutoff_period is updated, update the column table accordingly
	--
  	IF(p_overdue_transactions = 'INCLUDE' AND
	   X_overdue_transactions = 'INCLUDE' AND
	   p_cutoff_period <> X_cutoff_period) THEN
		UPDATE 	CE_FORECAST_COLUMNS
			SET	days_from 		= -X_cutoff_period+1
			WHERE	forecast_header_id	= X_forecast_header_id
			AND	column_number		= 0
			AND	developer_column_num 	= 0;
	END IF;

	--
	-- If overdue_transactions is updated from 'Y' to 'N', delete
	-- the overdue column from the column table
	--
	IF(p_overdue_transactions = 'INCLUDE' AND
	   X_overdue_transactions = 'EXCLUDE')THEN
		DELETE 	FROM CE_FORECAST_COLUMNS
			WHERE	forecast_header_id 	= X_forecast_header_id
			AND	column_number		= 0
			AND	developer_column_num	= 0;
		IF(SQL%NOTFOUND)THEN
			RAISE NO_DATA_FOUND;
		END IF;
	END IF;

  END Update_Row;

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   To delete a  row from ce_forecast_headers.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_HEADERS_PKG.Delete_Row(...);
  -- Notes
  --
  PROCEDURE Delete_Row(X_rowid VARCHAR2) IS
        p_forecast_header_id	NUMBER;
  BEGIN
  --
  -- delete all rows, columns, and headers for template
  --
        SELECT   forecast_header_id
        INTO     p_forecast_header_id
        FROM     CE_FORECAST_HEADERS
        WHERE    rowid = X_rowid;

	DELETE FROM CE_FORECAST_ROWS
	WHERE	    forecast_header_id = p_forecast_header_id;

        DELETE FROM CE_FORECAST_COLUMNS
        WHERE       forecast_header_id = p_forecast_header_id;

	DELETE FROM ce_forecast_headers
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Delete_Row;

  PROCEDURE Delete_Forecasts(X_rowid VARCHAR2) IS
	p_forecast_header_id 	NUMBER;
  BEGIN
  --
  -- delete all forecasts and cells that belong to the template
  --
	SELECT	   forecast_header_id
	INTO	   p_forecast_header_id
	FROM	   CE_FORECAST_HEADERS
	WHERE	   rowid = X_rowid;

	DELETE FROM CE_FORECAST_CELLS
	WHERE	    forecast_header_id = p_forecast_header_id;

	DELETE FROM CE_FORECASTS
	WHERE	    forecast_header_id = p_forecast_header_id;

  END Delete_Forecasts;

END CE_FORECAST_HEADERS_PKG;

/
