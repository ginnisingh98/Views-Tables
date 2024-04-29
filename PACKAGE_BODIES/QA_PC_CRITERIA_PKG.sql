--------------------------------------------------------
--  DDL for Package Body QA_PC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PC_CRITERIA_PKG" as
/* $Header: qapccrib.pls 120.2 2005/12/19 04:12:54 srhariha noship $ */
  PROCEDURE Insert_Row( X_Rowid                 IN OUT  NOCOPY VARCHAR2,
                       X_Criteria_Id            IN OUT  NOCOPY NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Char_Id                        NUMBER,
                       X_Operator                       NUMBER,
                       X_Low_Value                      VARCHAR2,
                       X_Low_Value_Id                   NUMBER,
                       X_High_Value                     VARCHAR2,
                       X_High_Value_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
     CURSOR C IS SELECT rowid FROM QA_PC_CRITERIA
                 WHERE criteria_id = X_Criteria_Id;
     CURSOR C2 IS SELECT qa_pc_criteria_s.nextval FROM dual;
   BEGIN
      if (X_Criteria_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Criteria_Id;
        CLOSE C2;
      end if;

      INSERT INTO QA_PC_CRITERIA(
                   criteria_id,
                   plan_relationship_id,
                   char_id,
                   operator,
                   low_value,
                   low_value_id,
                   high_value,
                   high_value_id,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login
           )VALUES (
                   X_Criteria_Id,
                   X_Plan_Relationship_Id,
                   X_Char_Id,
                   X_Operator,
                   X_Low_Value,
                   X_Low_Value_Id,
                   X_High_Value,
                   X_High_Value_Id ,
                   X_Last_Update_Date,
                   X_Last_Updated_By ,
                   X_Creation_Date,
                   X_Created_By ,
                   X_Last_Update_Login
          );
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

  PROCEDURE Lock_Row( X_Rowid                           VARCHAR2,
                       X_Criteria_Id                    NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Char_Id                        NUMBER,
                       X_Operator                       NUMBER,
                       X_Low_Value                      VARCHAR2,
                       X_Low_Value_Id                   NUMBER,
                       X_High_Value                     VARCHAR2,
                       X_High_Value_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER

   ) IS
    CURSOR C IS
        SELECT *
        FROM   QA_PC_CRITERIA
        WHERE  rowid = X_Rowid
        FOR UPDATE of Criteria_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
         if (
               (Recinfo.criteria_id                     =  X_Criteria_Id)
           AND (Recinfo.plan_relationship_id            =  X_Plan_Relationship_Id)
           AND (Recinfo.char_id                         =  X_Char_Id)
           AND (Recinfo.operator                        =  X_Operator)
           AND ((Recinfo.low_value    = X_Low_Value)
                 OR ((Recinfo.low_value IS NULL )
                      AND (X_Low_Value IS NULL)))
           AND ((Recinfo.low_value_id = X_Low_Value_Id)
                 OR ((Recinfo.low_value_id IS NULL )
                      AND (X_Low_Value_Id IS NULL)))
           AND ((Recinfo.high_value = X_High_Value)
                 OR ((Recinfo.high_value IS NULL )
                      AND (X_High_Value IS NULL)))
           AND ((Recinfo.high_value_id = X_High_Value_Id)
                 OR ((Recinfo.high_value_id IS NULL )
                      AND (X_High_Value_Id IS NULL)))
           AND (Recinfo.last_update_date =  X_Last_Update_Date)
           AND (Recinfo.last_updated_by =  X_Last_Updated_By)
           AND (Recinfo.creation_date =  X_Creation_Date)
           AND (Recinfo.created_by =  X_Created_By)
        ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row( X_Rowid                         VARCHAR2,
                       X_Criteria_Id                    NUMBER,
                       X_Plan_Relationship_Id           NUMBER,
                       X_Char_Id                        NUMBER,
                       X_Operator                       NUMBER,
                       X_Low_Value                      VARCHAR2,
                       X_Low_Value_Id                   NUMBER,
                       X_High_Value                     VARCHAR2,
                       X_High_Value_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
  BEGIN
    UPDATE QA_PC_CRITERIA
    SET
           criteria_id                 = X_Criteria_Id ,
           plan_relationship_id        = X_Plan_Relationship_Id ,
           char_id                     = X_Char_Id,
           operator                    = X_Operator,
           low_value                   = X_Low_Value,
           low_value_id                = X_Low_Value_Id,
           high_value                  = X_High_Value,
           high_value_id               = X_High_Value_Id,
           last_update_date            = X_Last_Update_Date,
           last_updated_by             = X_Last_Updated_By,
           creation_date               = X_Creation_Date,
           created_by                  = X_Created_By,
           last_update_login           = X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM QA_PC_CRITERIA
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END QA_PC_CRITERIA_PKG;

/
