--------------------------------------------------------
--  DDL for Package Body PA_SEGMENT_RULE_PAIRINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SEGMENT_RULE_PAIRINGS_PKG" as
/* $Header: PAXAAASB.pls 120.3 2005/08/03 10:27:36 aaggarwa noship $ */

  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Function_Code                  VARCHAR2,
                       X_Function_Transaction_Code      VARCHAR2,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Segment_Num                    NUMBER,
                       X_Rule_Id                        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Display_Flag                   VARCHAR2,
                       P_Org_Id                         NUMBER -- 12i MOAC changes
  ) IS
    CURSOR C IS SELECT rowid FROM PA_SEGMENT_RULE_PAIRINGS
                 WHERE application_id = X_Application_Id
                 AND   function_code = X_Function_Code
                 AND   function_transaction_code = X_Function_Transaction_Code;

   BEGIN
       INSERT INTO PA_SEGMENT_RULE_PAIRINGS(
              application_id,
              function_code,
              function_transaction_code,
              id_flex_code,
              id_flex_num,
              segment_num,
              rule_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              display_flag,
              Org_Id -- 12i MOAC changes
             ) VALUES (
              X_Application_Id,
              X_Function_Code,
              X_Function_Transaction_Code,
              X_Id_Flex_Code,
              X_Id_Flex_Num,
              X_Segment_Num,
              X_Rule_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Display_Flag,
              P_Org_Id -- 12i MOAC changes
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Application_Id                   NUMBER,
                     X_Function_Code                    VARCHAR2,
                     X_Function_Transaction_Code        VARCHAR2,
                     X_Id_Flex_Code                     VARCHAR2,
                     X_Id_Flex_Num                      NUMBER,
                     X_Segment_Num                      NUMBER,
                     X_Rule_Id                          NUMBER,
                     X_Display_Flag                     VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_SEGMENT_RULE_PAIRINGS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Application_Id NOWAIT;
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
               (Recinfo.application_id =  X_Application_Id)
           AND (Recinfo.function_code =  X_Function_Code)
           AND (Recinfo.function_transaction_code =  X_Function_Transaction_Code
)
           AND (Recinfo.id_flex_code =  X_Id_Flex_Code)
           AND (Recinfo.id_flex_num =  X_Id_Flex_Num)
           AND (Recinfo.segment_num =  X_Segment_Num)
           AND (Recinfo.rule_id =  X_Rule_Id)
           AND (   (Recinfo.display_flag =  X_Display_Flag)
                OR (    (Recinfo.display_flag IS NULL)
                    AND (X_Display_Flag IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Function_Code                  VARCHAR2,
                       X_Function_Transaction_Code      VARCHAR2,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Segment_Num                    NUMBER,
                       X_Rule_Id                        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Display_Flag                   VARCHAR2

  ) IS
  BEGIN
    UPDATE PA_SEGMENT_RULE_PAIRINGS
    SET
       application_id                  =     X_Application_Id,
       function_code                   =     X_Function_Code,
       function_transaction_code       =     X_Function_Transaction_Code,
       id_flex_code                    =     X_Id_Flex_Code,
       id_flex_num                     =     X_Id_Flex_Num,
       segment_num                     =     X_Segment_Num,
       rule_id                         =     X_Rule_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       display_flag                    =     X_Display_Flag
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_SEGMENT_RULE_PAIRINGS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END PA_SEGMENT_RULE_PAIRINGS_PKG;

/
