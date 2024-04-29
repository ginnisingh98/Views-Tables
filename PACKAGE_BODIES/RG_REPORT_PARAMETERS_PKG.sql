--------------------------------------------------------
--  DDL for Package Body RG_REPORT_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_PARAMETERS_PKG" AS
/* $Header: rgirparb.pls 120.4 2003/04/29 00:47:50 djogg ship $ */

FUNCTION get_new_id
	RETURN NUMBER
IS
	new_id NUMBER;
BEGIN
	SELECT rg_report_parameters_s.nextval
        INTO   new_id
	FROM   dual;

	RETURN new_id;
END get_new_id;

FUNCTION dup_parameter_num(para_set_id   IN  NUMBER,
			   para_num	 IN  NUMBER,
			   para_type     IN  VARCHAR2,
                           row_id        IN  VARCHAR2)
	RETURN BOOLEAN
IS
	dummy	NUMBER;
BEGIN
        SELECT 1 INTO dummy FROM dual
        WHERE NOT EXISTS
         (SELECT 1 FROM rg_report_parameters
	  WHERE  parameter_set_id = para_set_id
	  AND    parameter_num    = para_num
          AND    data_type = para_type
	  AND    ((row_id IS NULL) OR (row_id <> rowid)));

	RETURN (FALSE);

	EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN (TRUE);

END dup_parameter_num;

FUNCTION Duplicate_Row(from_parameter_set_id	IN  NUMBER)
	RETURN NUMBER
IS
	to_parameter_set_id NUMBER;
BEGIN
	SELECT rg_report_parameters_s.nextval
        INTO   to_parameter_set_id
        FROM   dual;

	INSERT INTO 	rg_report_parameters
       		   	(parameter_set_id,
			last_update_date,
			last_updated_by,
			last_update_login,
			creation_date,
			created_by,
			parameter_num,
			data_type,
			parameter_id,
			currency_type,
			entered_currency,
			ledger_currency,
			period_num,
			fiscal_year_offset,
			context,
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
	SELECT		to_parameter_set_id,
			last_update_date,
			last_updated_by,
			last_update_login,
			creation_date,
			created_by,
			parameter_num,
			data_type,
			parameter_id,
			currency_type,
			entered_currency,
			ledger_currency,
			period_num,
			fiscal_year_offset,
			context,
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
	FROM
			rg_report_parameters
	WHERE
			parameter_set_id = from_parameter_set_id;

	RETURN(to_parameter_set_id);
END Duplicate_Row;



FUNCTION insert_row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                    X_Parameter_Set_Id      IN OUT NOCOPY NUMBER,
                    X_Last_Update_Date                    DATE,
                    X_Last_Updated_By                     NUMBER,
                    X_Last_Update_Login                   NUMBER,
                    X_Creation_Date                       DATE,
                    X_Created_By                          NUMBER,
                    X_Parameter_Num                       NUMBER,
                    X_Data_Type                           VARCHAR2,
                    X_Parameter_Id                        NUMBER,
                    X_Currency_Type                       VARCHAR2,
                    X_Entered_Currency                    VARCHAR2,
                    X_Ledger_Currency                     VARCHAR2,
                    X_Period_Num                          NUMBER,
                    X_Fiscal_Year_Offset                  NUMBER,
                    X_Context                             VARCHAR2,
                    X_Attribute1                          VARCHAR2,
                    X_Attribute2                          VARCHAR2,
                    X_Attribute3                          VARCHAR2,
                    X_Attribute4                          VARCHAR2,
                    X_Attribute5                          VARCHAR2,
                    X_Attribute6                          VARCHAR2,
                    X_Attribute7                          VARCHAR2,
                    X_Attribute8                          VARCHAR2,
                    X_Attribute9                          VARCHAR2,
                    X_Attribute10                         VARCHAR2,
                    X_Attribute11                         VARCHAR2,
                    X_Attribute12                         VARCHAR2,
                    X_Attribute13                         VARCHAR2,
                    X_Attribute14                         VARCHAR2,
                    X_Attribute15                         VARCHAR2
) RETURN BOOLEAN IS
   CURSOR C IS SELECT rowid FROM rg_report_parameters
             WHERE parameter_set_id = X_Parameter_Set_Id
             AND   parameter_num = X_Parameter_Num
             AND   data_type = X_Data_Type;

    CURSOR C2 IS SELECT rg_report_parameters_s.nextval FROM dual;
BEGIN

   IF (X_Parameter_Set_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Parameter_Set_Id;
     CLOSE C2;
   END IF;

  IF (dup_parameter_num(X_Parameter_Set_Id,
                        X_Parameter_Num,
                        X_Data_Type,
                        X_Rowid)) THEN
    RETURN(FALSE);
  END IF;

  INSERT INTO rg_report_parameters(
          parameter_set_id,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          parameter_num,
          data_type,
          parameter_id,
          currency_type,
          entered_currency,
          ledger_currency,
          period_num,
          fiscal_year_offset,
          context,
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
          X_Parameter_Set_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Creation_Date,
          X_Created_By,
          X_Parameter_Num,
          X_Data_Type,
          X_Parameter_Id,
          X_Currency_Type,
          X_Entered_Currency,
          X_Ledger_Currency,
          X_Period_Num,
          X_Fiscal_Year_Offset,
          X_Context,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  IF (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
  RETURN(TRUE);
END insert_row;

PROCEDURE lock_row(X_Rowid                                 VARCHAR2,
                   X_Parameter_Set_Id                      NUMBER,
                   X_Parameter_Num                         NUMBER,
                   X_Data_Type                             VARCHAR2,
                   X_Parameter_Id                          NUMBER,
                   X_Currency_Type                         VARCHAR2,
                   X_Entered_Currency                      VARCHAR2,
                   X_Ledger_Currency                       VARCHAR2,
                   X_Period_Num                            NUMBER,
                   X_Fiscal_Year_Offset                    NUMBER,
                   X_Context                               VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   rg_report_parameters
      WHERE  rowid = X_Rowid
      FOR UPDATE of Parameter_Set_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;
  IF (
          (   (Recinfo.parameter_set_id = X_Parameter_Set_Id)
           OR (    (Recinfo.parameter_set_id IS NULL)
               AND (X_Parameter_Set_Id IS NULL)))
      AND (   (Recinfo.parameter_num = X_Parameter_Num)
           OR (    (Recinfo.parameter_num IS NULL)
               AND (X_Parameter_Num IS NULL)))
      AND (   (Recinfo.data_type = X_Data_Type)
           OR (    (Recinfo.data_type IS NULL)
               AND (X_Data_Type IS NULL)))
      AND (   (Recinfo.parameter_id = X_Parameter_Id)
           OR (    (Recinfo.parameter_id IS NULL)
               AND (X_Parameter_Id IS NULL)))
      AND (   (Recinfo.currency_type = X_Currency_Type)
           OR (    (Recinfo.currency_type IS NULL)
               AND (X_Currency_Type IS NULL)))
      AND (   (Recinfo.entered_currency = X_Entered_Currency)
           OR (    (Recinfo.entered_currency IS NULL)
               AND (X_Entered_Currency IS NULL)))
      AND (   (Recinfo.ledger_currency = X_Ledger_Currency)
           OR (    (Recinfo.ledger_currency IS NULL)
               AND (X_Ledger_Currency IS NULL)))
      AND (   (Recinfo.period_num = X_Period_Num)
           OR (    (Recinfo.period_num IS NULL)
               AND (X_Period_Num IS NULL)))
      AND (   (Recinfo.fiscal_year_offset = X_Fiscal_Year_Offset)
           OR (    (Recinfo.fiscal_year_offset IS NULL)
               AND (X_Fiscal_Year_Offset IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END lock_row;

FUNCTION update_row(X_Rowid                               VARCHAR2,
                    X_Parameter_Set_Id                    NUMBER,
                    X_Last_Update_Date                    DATE,
                    X_Last_Updated_By                     NUMBER,
                    X_Last_Update_Login                   NUMBER,
                    X_Parameter_Num                       NUMBER,
                    X_Data_Type                           VARCHAR2,
                    X_Parameter_Id                        NUMBER,
                    X_Currency_Type                       VARCHAR2,
                    X_Entered_Currency                    VARCHAR2,
                    X_Ledger_Currency                     VARCHAR2,
                    X_Period_Num                          NUMBER,
                    X_Fiscal_Year_Offset                  NUMBER,
                    X_Context                             VARCHAR2,
                    X_Attribute1                          VARCHAR2,
                    X_Attribute2                          VARCHAR2,
                    X_Attribute3                          VARCHAR2,
                    X_Attribute4                          VARCHAR2,
                    X_Attribute5                          VARCHAR2,
                    X_Attribute6                          VARCHAR2,
                    X_Attribute7                          VARCHAR2,
                    X_Attribute8                          VARCHAR2,
                    X_Attribute9                          VARCHAR2,
                    X_Attribute10                         VARCHAR2,
                    X_Attribute11                         VARCHAR2,
                    X_Attribute12                         VARCHAR2,
                    X_Attribute13                         VARCHAR2,
                    X_Attribute14                         VARCHAR2,
                    X_Attribute15                         VARCHAR2
) RETURN BOOLEAN IS
BEGIN
  IF (dup_parameter_num(X_Parameter_Set_Id,
                        X_Parameter_Num,
                        X_Data_Type,
                        X_Rowid)) THEN
    RETURN(FALSE);
  END IF;

  UPDATE rg_report_parameters
  SET
    parameter_set_id                          =    X_Parameter_Set_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    parameter_num                             =    X_Parameter_Num,
    data_type                                 =    X_Data_Type,
    parameter_id                              =    X_Parameter_Id,
    currency_type                             =    X_Currency_Type,
    entered_currency                          =    X_Entered_Currency,
    ledger_currency                           =    X_Ledger_Currency,
    period_num                                =    X_Period_Num,
    fiscal_year_offset                        =    X_Fiscal_Year_Offset,
    context                                   =    X_Context,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  END IF;
  RETURN(TRUE);
END update_row;

PROCEDURE delete_row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM rg_report_parameters
  WHERE  rowid = X_Rowid;

  IF (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

END RG_REPORT_PARAMETERS_PKG;

/
