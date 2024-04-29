--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_CELLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_CELLS_PKG" as
/* $Header: cefcellb.pls 120.1 2002/11/12 21:35:02 bhchung ship $ */

  PROCEDURE Insert_Row(	X_Rowid			IN OUT NOCOPY	VARCHAR2,
			X_forecast_cell_id	IN OUT NOCOPY	NUMBER,
			X_forecast_id			NUMBER,
			X_forecast_header_id		NUMBER,
			X_forecast_row_id		NUMBER,
			X_forecast_column_id		NUMBER,
			X_amount			NUMBER,
		        X_Created_By                    NUMBER,
                       	X_Creation_Date                 DATE,
                       	X_Last_Updated_By               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Update_Login             NUMBER) IS
    CURSOR C1 IS SELECT rowid
		 FROM CE_FORECAST_CELLS
		 WHERE forecast_cell_id = X_forecast_cell_id;
    CURSOR C2 IS SELECT CE_FORECAST_CELLS_S.nextval FROM sys.dual;
  BEGIN
    IF (X_forecast_cell_id IS NULL) THEN
      OPEN C2;
      FETCH C2 INTO X_forecast_cell_id;
      CLOSE C2;
    END IF;
    INSERT INTO CE_FORECAST_CELLS(
			FORECAST_CELL_ID,
 			FORECAST_ID,
 			FORECAST_HEADER_ID,
 			FORECAST_ROW_ID,
 			FORECAST_COLUMN_ID,
 			AMOUNT,
 			CREATED_BY,
 			CREATION_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATE_LOGIN ) VALUES
		(	X_forecast_cell_id,
			X_forecast_id,
			X_forecast_header_id,
			X_forecast_row_id,
			X_forecast_column_id,
			X_amount,
			X_created_by,
			X_creation_date,
			X_last_updated_by,
			X_last_update_date,
			X_last_update_login);
    OPEN C1;
    FETCH C1 INTO X_rowid;
    IF (C1%NOTFOUND) THEN
      CLOSE C1;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE C1;
  END insert_row;

  PROCEDURE Update_Row(	X_cellid			NUMBER,
			X_amount			NUMBER,
                       	X_Last_Updated_By               NUMBER,
                       	X_Last_Update_Date              DATE,
                       	X_Last_Update_Login             NUMBER) IS
  BEGIN
    UPDATE CE_FORECAST_CELLS
    SET
	amount			= X_amount,
	last_updated_by		= X_last_updated_by,
	last_update_date	= X_last_update_date,
	last_update_login	= X_last_update_login
    WHERE forecast_cell_id = X_cellid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM CE_FORECAST_CELLS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Lock_Row(   X_forecast_cell_id              NUMBER,
                        X_amount                        NUMBER) IS
    CURSOR C IS
	SELECT	*
	FROM	CE_FORECAST_CELLS
	WHERE 	forecast_cell_id = X_forecast_cell_id
	FOR UPDATE of forecast_cell_id NOWAIT;
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

    IF (Recinfo.amount = X_amount ) THEN
	return;
    ELSE
      FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.raise_exception;
    END IF;
  END Lock_Row;



END CE_FORECAST_CELLS_PKG;

/
