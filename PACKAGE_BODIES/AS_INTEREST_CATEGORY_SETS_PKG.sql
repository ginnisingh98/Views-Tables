--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_CATEGORY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_CATEGORY_SETS_PKG" as
/* $Header: asxldcsb.pls 115.5 2002/11/06 00:43:11 appldev ship $ */
--
--
-- HISTORY
--   04-JAN-94	Jan Sondergaard		Created.
--   27-APR-94  Jan Sondergaard         Added fix for NO_DATA_FOUND
--                                      problem in ON_LOCK
--

PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Category_Set_Id                     NUMBER,
                     X_Interest_Type_Id                    NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Enabled_Flag                        VARCHAR2 DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM as_interest_category_sets
             WHERE category_set_id = X_Category_Set_Id
             AND   interest_type_id = X_Interest_Type_Id;
BEGIN
  INSERT INTO as_interest_category_sets(
          category_set_id,
          interest_type_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          enabled_flag
         ) VALUES (
          X_Category_Set_Id,
          X_Interest_Type_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Enabled_Flag
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
                   X_Category_Set_Id                       NUMBER,
                   X_Interest_Type_Id                      NUMBER,
                   X_Enabled_Flag                          VARCHAR2 DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   as_interest_category_sets
      WHERE  rowid = X_Rowid
      FOR UPDATE of Category_Set_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.category_set_id = X_Category_Set_Id)
           OR (    (Recinfo.category_set_id IS NULL)
               AND (X_Category_Set_Id IS NULL)))
      AND (   (Recinfo.interest_type_id = X_Interest_Type_Id)
           OR (    (Recinfo.interest_type_id IS NULL)
               AND (X_Interest_Type_Id IS NULL)))
      AND (   (Recinfo.enabled_flag = X_Enabled_Flag)
           OR (    (Recinfo.enabled_flag IS NULL)
               AND (X_Enabled_Flag IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Category_Set_Id                     NUMBER,
                     X_Interest_Type_Id                    NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Enabled_Flag                        VARCHAR2 DEFAULT NULL
) IS
BEGIN
  UPDATE as_interest_category_sets
  SET
    category_set_id                           =    X_Category_Set_Id,
    interest_type_id                          =    X_Interest_Type_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    enabled_flag                              =    X_Enabled_Flag
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM as_interest_category_sets
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END AS_INTEREST_CATEGORY_SETS_PKG;

/
