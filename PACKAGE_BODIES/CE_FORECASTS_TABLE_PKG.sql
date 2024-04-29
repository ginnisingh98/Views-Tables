--------------------------------------------------------
--  DDL for Package Body CE_FORECASTS_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECASTS_TABLE_PKG" AS
/* $Header: ceforcab.pls 120.3 2003/05/12 23:14:52 sspoonen ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.3 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row( X_Rowid			IN OUT NOCOPY	VARCHAR2,
			X_forecast_id		IN OUT NOCOPY	NUMBER,
			X_forecast_header_id		NUMBER,
			X_name				VARCHAR2,
                        X_description			VARCHAR2,
			X_start_date			DATE,
			X_period_set_name		VARCHAR2,
			X_start_period			VARCHAR2,
			X_forecast_currency		VARCHAR2,
			X_currency_type			VARCHAR2,
			X_source_currency		VARCHAR2,
			X_exchange_rate_type		VARCHAR2,
			X_exchange_date                 DATE,
                        X_exchange_rate                 NUMBER,
			X_error_status			VARCHAR2,
			X_amount_threshold		NUMBER,
			X_project_id			NUMBER,
			X_drilldown_flag		VARCHAR2,
			X_bank_balance_type		VARCHAR2,
			X_float_type			VARCHAR2,
			X_view_by			VARCHAR2,
			X_include_sub_account		VARCHAR2,
			X_factor			NUMBER,
			X_request_id			NUMBER,
			X_Created_By                    NUMBER,
                       	X_Creation_Date                 DATE,
                       	X_Last_Updated_By               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Update_Login             NUMBER,
			X_attribute_category            VARCHAR2,
			X_attribute1                    VARCHAR2,
			X_attribute2                    VARCHAR2,
			X_attribute3                    VARCHAR2,
			X_attribute4                    VARCHAR2,
			X_attribute5                    VARCHAR2,
			X_attribute6                    VARCHAR2,
			X_attribute7                    VARCHAR2,
			X_attribute8                    VARCHAR2,
			X_attribute9                    VARCHAR2,
			X_attribute10                   VARCHAR2,
			X_attribute11                   VARCHAR2,
			X_attribute12                   VARCHAR2,
			X_attribute13                   VARCHAR2,
			X_attribute14                   VARCHAR2,
			X_attribute15                   VARCHAR2) IS
    CURSOR C1 IS SELECT rowid
		 FROM CE_FORECASTS
		 WHERE forecast_id = X_forecast_id;
    CURSOR C2 IS SELECT CE_FORECASTS_S.nextval FROM sys.dual;
    BEGIN
    IF (X_forecast_id IS NULL) THEN
      OPEN C2;
      FETCH C2 INTO X_forecast_id;
      CLOSE C2;
    END IF;
    INSERT INTO CE_FORECASTS(
			forecast_id,
			forecast_header_id,
			name,
                        description,
			start_date,
			period_set_name,
			start_period,
			forecast_currency,
			currency_type,
			source_currency,
			exchange_rate_type,
			exchange_date,
			exchange_rate,
			error_status,
			amount_threshold,
			project_id,
			drilldown_flag,
			bank_balance_type,
			float_type,
			view_by,
			include_sub_account,
			factor,
			request_id,
			Created_By,
                       	Creation_Date,
                       	Last_Updated_By,
                       	Last_Update_Date,
                       	Last_Update_Login,
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
			attribute15)
		 VALUES
		(	X_forecast_id,
			X_forecast_header_id,
			X_name,
                        X_description,
			X_start_date,
			X_period_set_name,
			X_start_period,
			X_forecast_currency,
			X_currency_type,
			X_source_currency,
			X_exchange_rate_type,
			X_exchange_date,
			X_exchange_rate,
			X_error_status,
			X_amount_threshold,
			X_project_id,
			X_drilldown_flag,
			X_bank_balance_type,
			X_float_type,
			X_view_by,
			X_include_sub_account,
			X_factor,
			X_request_id,
			X_Created_By ,
                       	X_Creation_Date,
                       	X_Last_Updated_By,
                       	X_Last_Update_Date,
                       	X_Last_Update_Login,
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
			X_attribute15) ;
    OPEN C1;
    FETCH C1 INTO X_rowid;
    IF (C1%NOTFOUND) THEN
      CLOSE C1;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE C1;
  END Insert_row;

  PROCEDURE Update_Row( X_rowid				VARCHAR2,
			X_forecast_id			NUMBER,
			X_forecast_header_id		NUMBER,
			X_name				VARCHAR2,
                        X_description			VARCHAR2,
			X_start_date			DATE,
			X_period_set_name			VARCHAR2,
			X_start_period			VARCHAR2,
			X_forecast_currency		VARCHAR2,
			X_currency_type			VARCHAR2,
			X_source_currency		VARCHAR2,
			X_exchange_rate_type		VARCHAR2,
			X_exchange_date                 DATE,
                        X_exchange_rate                 NUMBER,
			X_error_status			VARCHAR2,
			X_amount_threshold		NUMBER,
			X_project_id			NUMBER,
                       	X_Last_Updated_By               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Update_Login             NUMBER,
			X_attribute_category            VARCHAR2,
			X_attribute1                    VARCHAR2,
			X_attribute2                    VARCHAR2,
			X_attribute3                    VARCHAR2,
			X_attribute4                    VARCHAR2,
			X_attribute5                    VARCHAR2,
			X_attribute6                    VARCHAR2,
			X_attribute7                    VARCHAR2,
			X_attribute8                    VARCHAR2,
			X_attribute9                    VARCHAR2,
			X_attribute10                   VARCHAR2,
			X_attribute11                   VARCHAR2,
			X_attribute12                   VARCHAR2,
			X_attribute13                   VARCHAR2,
			X_attribute14                   VARCHAR2,
			X_attribute15                   VARCHAR2) IS
  BEGIN
    UPDATE CE_FORECASTS
    SET
	forecast_id		=	X_forecast_id,
	forecast_header_id	=	X_forecast_header_id,
	name			=	X_name,
        description		=	X_description,
	start_date		=	X_start_date,
	period_set_name		=	X_period_set_name,
	start_period		=	X_start_period,
	forecast_currency	=	X_forecast_currency,
	currency_type		=	X_currency_type,
	source_currency		=	X_source_currency,
	exchange_rate_type	=	X_exchange_rate_type,
	exchange_date		=	X_exchange_date,
	exchange_rate		= 	X_exchange_rate,
	error_status		=	X_error_status,
	amount_threshold	=	X_amount_threshold,
	project_id		= 	X_project_id,
        Last_Updated_By		=	X_Last_Updated_By,
        Last_Update_Date	=	X_Last_Update_Date,
        Last_Update_Login	=	X_Last_Update_Login,
	attribute_category	=	X_attribute_category,
	attribute1		=	X_attribute1,
	attribute2		=	X_attribute2,
	attribute3		=	X_attribute3,
	attribute4		=	X_attribute4,
	attribute5		=	X_attribute5,
	attribute6		=	X_attribute6,
	attribute7		=	X_attribute7,
	attribute8		=	X_attribute8,
	attribute9		=	X_attribute9,
	attribute10		=	X_attribute10,
	attribute11		=	X_attribute11,
	attribute12		=	X_attribute12,
	attribute13		=	X_attribute13,
	attribute14		=	X_attribute14,
	attribute15		=	X_attribute15
    WHERE	rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
     END IF;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    p_forecast_id	NUMBER;
  BEGIN
    --
    -- delete all cells belongs to the forecast
    --
    SELECT	forecast_id
    INTO	p_forecast_id
    FROM	CE_FORECASTS
    WHERE	rowid = X_Rowid;

    DELETE FROM CE_FORECAST_ERRORS
    WHERE	forecast_id = p_forecast_id;

    DELETE FROM CE_FORECAST_CELLS
    WHERE	forecast_id = p_forecast_id;

    DELETE FROM CE_FORECASTS
    WHERE 	rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Delete_Row;

  PROCEDURE Lock_Row  ( X_RowId				VARCHAR2,
			X_forecast_id			NUMBER,
			X_forecast_header_id		NUMBER,
			X_name				VARCHAR2,
                        X_description			VARCHAR2,
			X_start_date			DATE,
			X_period_set_name		VARCHAR2,
			X_start_period			VARCHAR2,
			X_forecast_currency		VARCHAR2,
			X_currency_type			VARCHAR2,
			X_source_currency		VARCHAR2,
			X_exchange_rate_type		VARCHAR2,
			X_exchange_date                 DATE,
                        X_exchange_rate                 NUMBER,
			X_error_status			VARCHAR2,
			X_amount_threshold		NUMBER,
			X_project_id			NUMBER,
			X_attribute_category            VARCHAR2,
			X_attribute1                    VARCHAR2,
			X_attribute2                    VARCHAR2,
			X_attribute3                    VARCHAR2,
			X_attribute4                    VARCHAR2,
			X_attribute5                    VARCHAR2,
			X_attribute6                    VARCHAR2,
			X_attribute7                    VARCHAR2,
			X_attribute8                    VARCHAR2,
			X_attribute9                    VARCHAR2,
			X_attribute10                   VARCHAR2,
			X_attribute11                   VARCHAR2,
			X_attribute12                   VARCHAR2,
			X_attribute13                   VARCHAR2,
			X_attribute14                   VARCHAR2,
			X_attribute15                   VARCHAR2) IS
    CURSOR C IS
	SELECT 	*
	FROM	CE_FORECASTS
	WHERE	rowid = X_rowid
	FOR UPDATE OF forecast_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.raise_exception;
    END IF;
    CLOSE C;
    IF(
	(Recinfo.forecast_id = X_forecast_id )
       AND (Recinfo.name = X_name )
       AND (Recinfo.forecast_currency = X_forecast_currency )
       AND (Recinfo.currency_type = X_currency_type )
       AND (    (   (Recinfo.exchange_rate_type = X_exchange_rate_type )
             OR (    (Recinfo.exchange_rate_type IS NULL)
                 AND (X_exchange_rate_type IS NULL))))
       AND (    (   (Recinfo.exchange_date = X_exchange_date )
             OR (    (Recinfo.exchange_date IS NULL)
                 AND (X_exchange_date IS NULL))))
       AND (Recinfo.forecast_header_id = X_forecast_header_id )
       AND (    (   (Recinfo.description = X_description )
             OR (    (Recinfo.description IS NULL)
                 AND (X_description IS NULL))))
       AND (    (   (Recinfo.start_date = X_start_date )
             OR (    (Recinfo.start_date IS NULL)
                 AND (X_start_date IS NULL))))
       AND (    (   (Recinfo.start_period = X_start_period )
             OR (    (Recinfo.start_period IS NULL)
                 AND (X_start_period IS NULL))))
       AND (    (   (Recinfo.project_id = X_project_id )
             OR (    (Recinfo.project_id IS NULL)
                 AND (X_project_id IS NULL))))
       AND (    (   (Recinfo.source_currency = X_source_currency )
             OR (    (Recinfo.source_currency IS NULL)
                 AND (X_source_currency IS NULL))))
       AND (    (   (Recinfo.error_status = X_error_status )
             OR (    (Recinfo.error_status IS NULL)
                 AND (X_error_status IS NULL))))
       AND (    (   (Recinfo.attribute_category = X_attribute_category )
             OR (    (Recinfo.attribute_category IS NULL)
                 AND (X_attribute_category IS NULL))))
       AND (    (   (Recinfo.attribute1 = X_attribute1 )
             OR (    (Recinfo.attribute1 IS NULL)
                 AND (X_attribute1 IS NULL))))
       AND (    (   (Recinfo.attribute2 = X_attribute2 )
             OR (    (Recinfo.attribute2 IS NULL)
                 AND (X_attribute2 IS NULL))))
       AND (    (   (Recinfo.attribute3 = X_attribute3 )
             OR (    (Recinfo.attribute3 IS NULL)
                 AND (X_attribute3 IS NULL))))
       AND (    (   (Recinfo.attribute4 = X_attribute4 )
             OR (    (Recinfo.attribute4 IS NULL)
                 AND (X_attribute4 IS NULL))))
       AND (    (   (Recinfo.attribute5 = X_attribute5 )
             OR (    (Recinfo.attribute5 IS NULL)
                 AND (X_attribute5 IS NULL))))
       AND (    (   (Recinfo.attribute6 = X_attribute6 )
             OR (    (Recinfo.attribute6 IS NULL)
                 AND (X_attribute6 IS NULL))))
       AND (    (   (Recinfo.attribute7 = X_attribute7 )
             OR (    (Recinfo.attribute7 IS NULL)
                 AND (X_attribute7 IS NULL))))
       AND (    (   (Recinfo.attribute8 = X_attribute8 )
             OR (    (Recinfo.attribute8 IS NULL)
                 AND (X_attribute8 IS NULL))))
       AND (    (   (Recinfo.attribute9 = X_attribute9 )
             OR (    (Recinfo.attribute9 IS NULL)
                 AND (X_attribute9 IS NULL))))
       AND (    (   (Recinfo.attribute10 = X_attribute10 )
             OR (    (Recinfo.attribute10 IS NULL)
                 AND (X_attribute10 IS NULL))))
       AND (    (   (Recinfo.attribute11 = X_attribute11 )
             OR (    (Recinfo.attribute11 IS NULL)
                 AND (X_attribute11 IS NULL))))
       AND (    (   (Recinfo.attribute12 = X_attribute12 )
             OR (    (Recinfo.attribute12 IS NULL)
                 AND (X_attribute12 IS NULL))))
       AND (    (   (Recinfo.attribute13 = X_attribute13 )
             OR (    (Recinfo.attribute13 IS NULL)
                 AND (X_attribute13 IS NULL))))
       AND (    (   (Recinfo.attribute14 = X_attribute14 )
             OR (    (Recinfo.attribute14 IS NULL)
                 AND (X_attribute14 IS NULL))))
       AND (    (   (Recinfo.attribute15 = X_attribute15 )
             OR (    (Recinfo.attribute15 IS NULL)
                 AND (X_attribute15 IS NULL))))
       AND (    (   (Recinfo.exchange_rate = X_exchange_rate )
             OR (    (Recinfo.exchange_rate IS NULL)
                 AND (X_exchange_rate IS NULL))))
       AND (    (   (Recinfo.period_set_name = X_period_set_name )
             OR (    (Recinfo.period_set_name IS NULL)
                 AND (X_period_set_name IS NULL))))
       AND (    (   (Recinfo.amount_threshold = X_amount_threshold )
             OR (    (Recinfo.amount_threshold IS NULL)
                 AND (X_amount_threshold IS NULL))))
       AND (    (   (Recinfo.project_id = X_project_id )
             OR (    (Recinfo.project_id IS NULL)
                 AND (X_project_id IS NULL))))
	) THEN
        return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.raise_exception;
    END IF;
  END Lock_Row;

END CE_FORECASTS_TABLE_PKG;

/
