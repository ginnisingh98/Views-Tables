--------------------------------------------------------
--  DDL for Package Body GL_STAT_ACCOUNT_UOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_STAT_ACCOUNT_UOM_PKG" as
/* $Header: glisuomb.pls 120.5 2005/05/05 01:28:27 kvora ship $ */

--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular source row
  -- History
  --   01-20-94  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_stat_account_uom_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_stat_account_uom%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_stat_account_uom
    WHERE chart_of_accounts_id = recinfo.chart_of_accounts_id
    AND   account_segment_value = recinfo.account_segment_value;
  END SELECT_ROW;


--
-- PUBLIC FUNCTIONS
--

  PROCEDURE select_columns(
			x_chart_of_accounts_id		IN OUT NOCOPY NUMBER,
			x_account_segment_value		IN OUT NOCOPY VARCHAR2,
			x_unit_of_measure		IN OUT NOCOPY VARCHAR2,
			x_description			IN OUT NOCOPY VARCHAR2) IS

    recinfo gl_stat_account_uom%ROWTYPE;

  BEGIN
    recinfo.chart_of_accounts_id := x_chart_of_accounts_id;
    recinfo.account_segment_value := x_account_segment_value;

    select_row(recinfo);

    x_unit_of_measure := recinfo.unit_of_measure;
    x_description := recinfo.description;

  END select_columns;


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Account_Segment_Value               VARCHAR2,
                     X_Unit_Of_Measure                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Description                         VARCHAR2 DEFAULT NULL,
                     X_Last_Update_Date                    DATE DEFAULT NULL,
                     X_Last_Updated_By                     NUMBER DEFAULT NULL,
                     X_Creation_Date                       DATE DEFAULT NULL,
                     X_Created_By                          NUMBER DEFAULT NULL,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM gl_stat_account_uom

             WHERE account_segment_value = X_Account_Segment_Value

             AND   chart_of_accounts_id = X_Chart_Of_Accounts_Id;




BEGIN






  INSERT INTO gl_stat_account_uom(
          account_segment_value,
          unit_of_measure,
          chart_of_accounts_id,
          description,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login
         ) VALUES (
          X_Account_Segment_Value,
          X_Unit_Of_Measure,
          X_Chart_Of_Accounts_Id,
          X_Description,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Account_Segment_Value                 VARCHAR2,
                   X_Unit_Of_Measure                       VARCHAR2,
                   X_Chart_Of_Accounts_Id                  NUMBER,
                   X_Description                           VARCHAR2 DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_stat_account_uom
      WHERE  rowid = X_Rowid
      FOR UPDATE of Account_Segment_Value NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.account_segment_value = X_Account_Segment_Value)
           OR (    (Recinfo.account_segment_value IS NULL)
               AND (X_Account_Segment_Value IS NULL)))
      AND (   (Recinfo.unit_of_measure = X_Unit_Of_Measure)
           OR (    (Recinfo.unit_of_measure IS NULL)
               AND (X_Unit_Of_Measure IS NULL)))
      AND (   (Recinfo.chart_of_accounts_id = X_Chart_Of_Accounts_Id)
           OR (    (Recinfo.chart_of_accounts_id IS NULL)
               AND (X_Chart_Of_Accounts_Id IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Account_Segment_Value               VARCHAR2,
                     X_Unit_Of_Measure                     VARCHAR2,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Description                         VARCHAR2 DEFAULT NULL,
                     X_Last_Update_Date                    DATE DEFAULT NULL,
                     X_Last_Updated_By                     NUMBER DEFAULT NULL,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL
) IS
BEGIN
  UPDATE gl_stat_account_uom
  SET

    account_segment_value                     =    X_Account_Segment_Value,
    unit_of_measure                           =    X_Unit_Of_Measure,
    chart_of_accounts_id                      =    X_Chart_Of_Accounts_Id,
    description                               =    X_Description,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM gl_stat_account_uom
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Check_Unique(X_Rowid				   VARCHAR2,
                       X_Account_Segment_Value		   VARCHAR2,
                       X_Chart_Of_Accounts_Id		   NUMBER) IS
  dummy	number;
BEGIN
  select 1 into dummy from dual where not exists
    (select 1 from gl_stat_account_uom
     where account_segment_value = X_Account_Segment_Value
      and  chart_of_accounts_id  = X_Chart_Of_Accounts_Id
      and  ((X_Rowid is null) or (rowid <> X_Rowid))
     );
EXCEPTION
  when no_data_found then
  fnd_message.set_name('SQLGL','GL_ONE_UNIT_PER_ACCOUNT');
  app_exception.raise_exception;
END Check_Unique;

END GL_STAT_ACCOUNT_UOM_PKG;

/
