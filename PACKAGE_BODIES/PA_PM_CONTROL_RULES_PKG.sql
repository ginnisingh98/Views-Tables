--------------------------------------------------------
--  DDL for Package Body PA_PM_CONTROL_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PM_CONTROL_RULES_PKG" as
/* $Header: PAPMPCRB.pls 120.2 2005/08/23 22:39:02 avaithia noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Control_Rule_id         IN     NUMBER,
                       X_Pm_product_code         IN     VARCHAR2,
                       X_Field_value_code        IN     VARCHAR2,
                       X_Start_Date              IN     DATE,
                       X_End_Date                IN     DATE,
                       X_Creation_Date           IN     DATE,
                       X_Created_By              IN     NUMBER,
                       X_Last_Update_Date        IN     DATE,
                       X_Last_Updated_By         IN     NUMBER,
                       X_Last_Update_Login       IN     NUMBER
  ) IS

    CURSOR C IS SELECT rowid FROM pa_pm_product_control_rules
                 WHERE control_rule_id = X_Control_Rule_id
                 AND   pm_product_code = X_Pm_product_code ;
   BEGIN

       INSERT INTO pa_pm_product_control_rules(
              control_rule_id,
              pm_product_code,
              field_value_code,
              start_date_active,
              end_date_active,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES
             (
              X_Control_Rule_id,
              X_Pm_product_code,
              X_Field_value_code,
              X_Start_Date,
              X_End_Date,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
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


  PROCEDURE Lock_Row(X_Rowid                     IN     VARCHAR2,
                     X_Control_Rule_id           IN     NUMBER,
                     X_Field_value_code          IN     VARCHAR2,
                     X_Start_Date                IN     DATE,
                     X_End_Date                  IN     DATE
  ) IS

    CURSOR C IS
        SELECT *
        FROM   pa_pm_product_control_rules
        WHERE  rowid = X_Rowid
        FOR UPDATE of end_date_active NOWAIT;
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
               (Recinfo.control_rule_id   =  X_Control_Rule_id)
           AND (Recinfo.start_date_active =  X_Start_Date)
           AND ( (Recinfo.end_date_active =  X_end_Date)
                  OR
                ( (Recinfo.end_date_active IS NULL )
                   AND (X_end_date IS NULL)))
           AND ( (Recinfo.field_value_code = X_Field_value_code)
                OR
                 ( (Recinfo.field_value_code IS NULL)
                    AND (X_Field_value_code IS NULL )))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                   IN     VARCHAR2,
                       X_Start_Date              IN     DATE,
                       X_End_Date                IN     DATE,
                       X_Control_rule_id         IN     NUMBER,
                       X_Last_Update_Date        IN     DATE,
                       X_Last_Updated_By         IN     NUMBER,
                       X_Last_Update_Login       IN     NUMBER

  ) IS
  BEGIN
    UPDATE pa_pm_product_control_rules
    SET
       start_date_active               =     x_start_date,
       end_date_active                 =     X_end_date
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM pa_pm_product_control_rules
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END PA_PM_CONTROL_RULES_PKG;

/
