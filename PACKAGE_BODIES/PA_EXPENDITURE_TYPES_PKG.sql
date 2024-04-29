--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURE_TYPES_PKG" as
/* $Header: PAXTETSB.pls 120.3 2005/08/17 23:03:57 vthakkar noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Expenditure_Type           VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Expenditure_Category       VARCHAR2,
                       X_Revenue_Category_Code      VARCHAR2,
                       X_System_Linkage_Function    VARCHAR2,
                       X_Unit_Of_Measure            VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_Cost_Rate_Flag             VARCHAR2,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2
                      -- MOAC changes
              --        , X_output_tax_code            VARCHAR2

  ) IS
    CURSOR C IS SELECT rowid FROM pa_expenditure_types
                 WHERE expenditure_type = X_Expenditure_Type;

    L_output_vat_tax_id          NUMBER;

   BEGIN


       INSERT INTO pa_expenditure_types(
	      expenditure_type_id,
              expenditure_type,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              expenditure_category,
              revenue_category_code,
              system_linkage_function,
              unit_of_measure,
              start_date_active,
              cost_rate_flag,
              end_date_active,
              description,
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
	      pa_exp_event_type_s.nextval ,
              X_Expenditure_Type,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Expenditure_Category,
              X_Revenue_Category_Code,
              X_System_Linkage_Function,
              X_Unit_Of_Measure,
              X_Start_Date_Active,
              X_Cost_Rate_Flag,
              X_End_Date_Active,
              X_Description,
              X_ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1,
              X_ATTRIBUTE2,
              X_ATTRIBUTE3,
              X_ATTRIBUTE4,
              X_ATTRIBUTE5,
              X_ATTRIBUTE6,
              X_ATTRIBUTE7,
              X_ATTRIBUTE8,
              X_ATTRIBUTE9,
              X_ATTRIBUTE10,
              X_ATTRIBUTE11,
              X_ATTRIBUTE12,
              X_ATTRIBUTE13,
              X_ATTRIBUTE14,
              X_ATTRIBUTE15
             );

 -- Tax impact changes
--MOAC chagnes`
--       IF X_output_tax_code IS NOT NULL THEN

--       BEGIN

/*
        SELECT vat_tax_id
          INTO L_output_vat_tax_id
          FROM pa_output_tax_code_setup_v
         WHERE tax_code = x_output_tax_code ;
*/ --for eTax changes
/*
        INSERT INTO pa_expenditure_type_ous(
              expenditure_type,
              output_tax_classification_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login
              )
        VALUES
             (
 	     X_expenditure_type,
	     X_output_tax_code,
	     X_last_update_date,
	     X_last_updated_by,
	     X_creation_date,
	     X_created_by,
	     X_last_update_login
             );

       END;

     END IF; */

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                      VARCHAR2,
                     X_Expenditure_Type           VARCHAR2,
                     X_Last_Update_Date           DATE,
                     X_Last_Updated_By            NUMBER,
                     X_Creation_Date              DATE,
                     X_Created_By                 NUMBER,
                     X_Last_Update_Login          NUMBER,
                     X_Expenditure_Category       VARCHAR2,
                     X_Revenue_Category_Code      VARCHAR2,
                     X_System_Linkage_Function    VARCHAR2,
                     X_Unit_Of_Measure            VARCHAR2,
                     X_Start_Date_Active          DATE,
                     X_Cost_Rate_Flag             VARCHAR2,
                     X_End_Date_Active            DATE,
                     X_Description                VARCHAR2,
                     X_Attribute_Category         VARCHAR2,
                     X_Attribute1                 VARCHAR2,
                     X_Attribute2                 VARCHAR2,
                     X_Attribute3                 VARCHAR2,
                     X_Attribute4                 VARCHAR2,
                     X_Attribute5                 VARCHAR2,
                     X_Attribute6                 VARCHAR2,
                     X_Attribute7                 VARCHAR2,
                     X_Attribute8                 VARCHAR2,
                     X_Attribute9                 VARCHAR2,
                     X_Attribute10                VARCHAR2,
                     X_Attribute11                VARCHAR2,
                     X_Attribute12                VARCHAR2,
                     X_Attribute13                VARCHAR2,
                     X_Attribute14                VARCHAR2,
                     X_Attribute15                VARCHAR2
                   -- MOAC changes
                    --, X_output_tax_code            VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_expenditure_types
        WHERE  rowid = X_Rowid
        FOR UPDATE of Expenditure_Type NOWAIT;
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
              (    Recinfo.expenditure_type        = X_Expenditure_Type)
         AND  (    Recinfo.expenditure_category    = X_Expenditure_Category)
         AND  (    Recinfo.revenue_category_code   = X_Revenue_Category_Code)
         AND  (    Recinfo.unit_of_measure         = X_Unit_Of_Measure)
         AND  (    Recinfo.cost_rate_flag          = X_Cost_Rate_Flag)
         AND  (   (Recinfo.start_date_active       = X_Start_Date_Active)
               OR (    (Recinfo.start_date_active IS NULL)
                   AND (X_Start_Date_Active IS NULL)))
         AND  (   (Recinfo.end_date_active         = X_End_Date_Active)
               OR (    (Recinfo.end_date_active IS NULL)
                   AND (X_End_Date_Active IS NULL)))
         AND  (   (Recinfo.description             = X_Description)
               OR (    (Recinfo.description IS NULL)
                   AND (X_Description IS NULL)))
         AND  (   (Recinfo.attribute_category      = X_Attribute_Category)
               OR (    (Recinfo.attribute_category IS NULL)
                   AND (X_Attribute_Category IS NULL)))
         AND  (   (Recinfo.attribute1              = X_Attribute1)
               OR (    (Recinfo.attribute1 IS NULL)
                   AND (X_Attribute1 IS NULL)))
         AND  (   (Recinfo.attribute2              = X_Attribute2)
               OR (    (Recinfo.attribute2 IS NULL)
                   AND (X_Attribute2 IS NULL)))
         AND  (   (Recinfo.attribute3              = X_Attribute3)
               OR (    (Recinfo.attribute3 IS NULL)
                   AND (X_Attribute3 IS NULL)))
         AND  (   (Recinfo.attribute4              = X_Attribute4)
               OR (    (Recinfo.attribute4 IS NULL)
                   AND (X_Attribute4 IS NULL)))
         AND  (   (Recinfo.attribute5              = X_Attribute5)
               OR (    (Recinfo.attribute5 IS NULL)
                   AND (X_Attribute5 IS NULL)))
         AND  (   (Recinfo.attribute6              = X_Attribute6)
               OR (    (Recinfo.attribute6 IS NULL)
                   AND (X_Attribute6 IS NULL)))
         AND  (   (Recinfo.attribute7              = X_Attribute7)
               OR (    (Recinfo.attribute7 IS NULL)
                   AND (X_Attribute7 IS NULL)))
         AND  (   (Recinfo.attribute8              = X_Attribute8)
               OR (    (Recinfo.attribute8 IS NULL)
                   AND (X_Attribute8 IS NULL)))
         AND  (   (Recinfo.attribute9              = X_Attribute9)
               OR (    (Recinfo.attribute9 IS NULL)
                   AND (X_Attribute9 IS NULL)))
         AND  (   (Recinfo.attribute10             = X_Attribute10)
               OR (    (Recinfo.attribute10 IS NULL)
                   AND (X_Attribute10 IS NULL)))
         AND  (   (Recinfo.attribute11             = X_Attribute11)
               OR (    (Recinfo.attribute11 IS NULL)
                   AND (X_Attribute11 IS NULL)))
         AND  (   (Recinfo.attribute12             = X_Attribute12)
               OR (    (Recinfo.attribute12 IS NULL)
                   AND (X_Attribute12 IS NULL)))
         AND  (   (Recinfo.attribute13             = X_Attribute13)
               OR (    (Recinfo.attribute13 IS NULL)
                   AND (X_Attribute13 IS NULL)))
         AND  (   (Recinfo.attribute14             = X_Attribute14)
               OR (    (Recinfo.attribute14 IS NULL)
                   AND (X_Attribute14 IS NULL)))
         AND  (   (Recinfo.attribute15             = X_Attribute15)
               OR (    (Recinfo.attribute15 IS NULL)
                   AND (X_Attribute15 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                      VARCHAR2,
                       X_Expenditure_Type           VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Expenditure_Category       VARCHAR2,
                       X_Revenue_Category_Code      VARCHAR2,
                       X_System_Linkage_Function    VARCHAR2,
                       X_Unit_Of_Measure            VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_Cost_Rate_Flag             VARCHAR2,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2
                   --MOAC changes
                   -- , X_output_tax_code            VARCHAR2
  ) IS

    L_output_vat_tax_id    NUMBER;

  BEGIN
    UPDATE pa_expenditure_types
    SET
       expenditure_type         =  X_Expenditure_Type,
       last_update_date         =  X_Last_Update_Date,
       last_updated_by          =  X_Last_Updated_By,
       creation_date            =  X_Creation_Date,
       created_by               =  X_Created_By,
       last_update_login        =  X_Last_Update_Login,
       expenditure_category     =  X_Expenditure_Category,
       revenue_category_code    =  X_Revenue_Category_Code,
       system_linkage_function  =  X_System_Linkage_Function,
       unit_of_measure          =  X_Unit_Of_Measure,
       start_date_active        =  X_Start_Date_Active,
       cost_rate_flag           =  X_Cost_Rate_Flag,
       end_date_active          =  X_End_Date_Active,
       description              =  X_Description,
       attribute_category       =  X_Attribute_Category,
       attribute1               =  X_Attribute1,
       attribute2               =  X_Attribute2,
       attribute3               =  X_Attribute3,
       attribute4               =  X_Attribute4,
       attribute5               =  X_Attribute5,
       attribute6               =  X_Attribute6,
       attribute7               =  X_Attribute7,
       attribute8               =  X_Attribute8,
       attribute9               =  X_Attribute9,
       attribute10              =  X_Attribute10,
       attribute11              =  X_Attribute11,
       attribute12              =  X_Attribute12,
       attribute13              =  X_Attribute13,
       attribute14              =  X_Attribute14,
       attribute15              =  X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

 -- Tax impact changes
-- MOAC changes
/*
      IF X_output_tax_code IS NOT NULL THEN

       BEGIN

        SELECT vat_tax_id
          INTO L_output_vat_tax_id
          FROM pa_output_tax_code_setup_v
         WHERE tax_code = x_output_tax_code ;

        UPDATE pa_expenditure_type_ous
           SET output_tax_classification_code = X_output_tax_code,
               last_update_date  = X_last_update_date,
               last_updated_by   = X_last_updated_by
         WHERE expenditure_type = X_expenditure_type;

 -- If no row exists then create new row
 --
        IF SQL%rowcount = 0 THEN
         INSERT INTO pa_expenditure_type_ous(
              expenditure_type,
              output_tax_classification_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login
              )
         VALUES
             (
 	     X_expenditure_type,
	     X_output_tax_code,
	     X_last_update_date,
	     X_last_updated_by,
	     X_last_update_date,
	     X_last_updated_by,
	     X_last_update_login
             );

       END IF;
      END;

     ELSE -- If the X_output_tax_code is NULL. Added else part in 1782377.

	 delete from pa_expenditure_type_ous
	 where expenditure_type = X_expenditure_type;

     END IF;
*/
  END Update_Row;

END PA_EXPENDITURE_TYPES_PKG;

/
