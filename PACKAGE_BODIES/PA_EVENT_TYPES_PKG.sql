--------------------------------------------------------
--  DDL for Package Body PA_EVENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_TYPES_PKG" as
/* $Header: PAXSUETB.pls 120.3 2005/08/19 17:20:53 mwasowic noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Event_type_Id                  NUMBER, /** 2363945 **/
                       X_Event_Type                     VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date_Active              DATE,
                       X_Event_Type_Classification      VARCHAR2,
                       X_End_Date_Active                DATE,
                       X_Description                    VARCHAR2,
                       X_Revenue_Category_Code          VARCHAR2,
                       /*  X_Output_tax_code                VARCHAR2,  Shared Services*/
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2

  ) IS
    CURSOR C IS SELECT rowid FROM PA_EVENT_TYPES
                 WHERE event_type = X_Event_Type;

/*
    CURSOR T IS SELECT VAT_TAX_ID
                FROM   PA_OUTPUT_TAX_CODE_SETUP_V
                WHERE  TAX_CODE    = X_Output_tax_code ;
*/ --by hsiu

    CURSOR O IS SELECT ORG_ID
                FROM   PA_IMPLEMENTATIONS;

    L_TAX_ID            NUMBER;
    L_ORG_ID            NUMBER;

   BEGIN


       INSERT INTO PA_EVENT_TYPES(

              event_type,
              event_type_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              start_date_active,
              event_type_classification,
              end_date_active,
              description,
              revenue_category_code,
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

              X_Event_Type,
	      X_Event_Type_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Start_Date_Active,
              X_Event_Type_Classification,
              X_End_Date_Active,
              X_Description,
              X_Revenue_Category_Code,
              X_Attribute_Category,
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
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    /* Commented this block for shared Service
    REM OPEN T;
    REM FETCH T INTO L_TAX_ID;
    REM CLOSE T;

    OPEN O;
    FETCH O INTO L_ORG_ID;
    CLOSE O;

    If x_output_tax_code IS NOT NULL
    Then
      INSERT INTO PA_EVENT_TYPE_OUS
      ( EVENT_TYPE,
        OUTPUT_TAX_CLASSIFICATION_CODE,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        LAST_UPDATED_BY,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        ORG_ID
      )
      VALUES
      ( X_Event_Type,
        X_OUTPUT_TAX_CODE,
        X_Last_Update_Date,
        X_Creation_Date,
        X_Last_Updated_By,
        X_Created_By,
        X_Last_Update_Login,
        L_ORG_ID );
    END IF;*/

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Event_Type                       VARCHAR2,
                     X_Start_Date_Active                DATE,
                     X_Event_Type_Classification        VARCHAR2,
                     X_End_Date_Active                  DATE,
                     X_Description                      VARCHAR2,
                     X_Revenue_Category_Code            VARCHAR2,
                     /*  X_Output_tax_code                  VARCHAR2,  Shared Services*/
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
    --hsiu: modified cursor
    CURSOR C IS
	SELECT ET.*
        FROM   PA_EVENT_TYPES ET
        WHERE  ET.rowid = RTRIM(X_Rowid)
        FOR UPDATE of ET.Event_Type NOWAIT;

        /*Shared Services
	SELECT ET.*, EOUS.OUTPUT_TAX_CLASSIFICATION_CODE OUTPUT_TAX_CODE
        FROM   PA_EVENT_TYPES ET,
               PA_EVENT_TYPE_OUS EOUS
        WHERE  ET.rowid = RTRIM(X_Rowid)
        and   RTRIM(ET.EVENT_TYPE) =  RTRIM(EOUS.EVENT_TYPE(+))
        FOR UPDATE of ET.Event_Type NOWAIT;*/
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    if (

               (RTRIM(Recinfo.event_type) =  RTRIM(X_Event_Type))
           AND (trunc(Recinfo.start_date_active) =  trunc(X_Start_Date_Active))
           AND (RTRIM(Recinfo.event_type_classification) =  RTRIM(X_Event_Type_Classification)
)
           AND (   (trunc(Recinfo.end_date_active) =  trunc(X_End_Date_Active))
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
           AND (   (rtrim(Recinfo.description) =  rtrim(X_Description))
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND ( rtrim(Recinfo.revenue_category_code) =  rtrim(X_Revenue_Category_Code))
           /* Shared Services
	   AND (   (trim(Recinfo.output_tax_code) =  rtrim(X_Output_tax_code))
                OR (    (Recinfo.output_tax_code IS NULL)
                    AND (X_Output_tax_code IS NULL)))*/
           AND (   (trim(Recinfo.Attribute_Category) =  rtrim(X_Attribute_Category))
                OR (    (Recinfo.Attribute_Category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (trim(Recinfo.Attribute1) =  rtrim(X_Attribute1))
                OR (    (Recinfo.Attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (trim(Recinfo.Attribute2) =  rtrim(X_Attribute2))
                OR (    (Recinfo.Attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (trim(Recinfo.Attribute3) =  rtrim(X_Attribute3))
                OR (    (Recinfo.Attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (trim(Recinfo.Attribute4) =  rtrim(X_Attribute4))
                OR (    (Recinfo.Attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (trim(Recinfo.Attribute5) =  rtrim(X_Attribute5))
                OR (    (Recinfo.Attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (trim(Recinfo.Attribute6) =  rtrim(X_Attribute6))
                OR (    (Recinfo.Attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (trim(Recinfo.Attribute7) =  rtrim(X_Attribute7))
                OR (    (Recinfo.Attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (trim(Recinfo.Attribute8) =  rtrim(X_Attribute8))
                OR (    (Recinfo.Attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (trim(Recinfo.Attribute9) =  rtrim(X_Attribute9))
                OR (    (Recinfo.Attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (trim(Recinfo.Attribute10) =  rtrim(X_Attribute10))
                OR (    (Recinfo.Attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (trim(Recinfo.Attribute11) =  rtrim(X_Attribute11))
                OR (    (Recinfo.Attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (trim(Recinfo.Attribute12) =  rtrim(X_Attribute12))
                OR (    (Recinfo.Attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (trim(Recinfo.Attribute13) =  rtrim(X_Attribute13))
                OR (    (Recinfo.Attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (trim(Recinfo.Attribute14) =  rtrim(X_Attribute14))
                OR (    (Recinfo.Attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (trim(Recinfo.Attribute15) =  rtrim(X_Attribute15))
                OR (    (Recinfo.Attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
      ) then
    CLOSE C;
      return;
    else
    CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Event_Type                     VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date_Active              DATE,
                       X_Event_Type_Classification      VARCHAR2,
                       X_End_Date_Active                DATE,
                       X_Description                    VARCHAR2,
                       X_Revenue_Category_Code          VARCHAR2,
                       /*  X_Output_tax_code                VARCHAR2,  Shared Services*/
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
 ) IS

/*
    CURSOR T IS SELECT VAT_TAX_ID
                FROM   PA_OUTPUT_TAX_CODE_SETUP_V
                WHERE  TAX_CODE    = X_Output_tax_code ;
*/--commented by hsiu

    /* Shared Services
              CURSOR O IS SELECT ORG_ID
                FROM   PA_IMPLEMENTATIONS;*/

    L_TAX_ID            NUMBER;
    L_ORG_ID            NUMBER;

  BEGIN
    UPDATE PA_EVENT_TYPES
    SET
       event_type                      =     X_Event_Type,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       start_date_active               =     X_Start_Date_Active,
       event_type_classification       =     X_Event_Type_Classification,
       end_date_active                 =     X_End_Date_Active,
       description                     =     X_Description,
       revenue_category_code           =     X_Revenue_Category_Code,
       attribute_Category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
   WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    /* Get Tax Id for X_Output_tax_code */
    /*
    OPEN T;
    FETCH T INTO L_TAX_ID;
    CLOSE T;
    */

   /* Commented for shared Service
    UPDATE PA_EVENT_TYPE_OUS
    SET    OUTPUT_TAX_CLASSIFICATION_CODE = x_output_tax_code,
           LAST_UPDATE_DATE    = X_Last_Update_Date,
           LAST_UPDATED_BY     = X_Last_Updated_By,
           LAST_UPDATE_LOGIN   = X_Last_Update_Login
    WHERE  EVENT_TYPE          = X_Event_Type;

    IF  (SQL%ROWCOUNT = 0 )
    AND (X_OUTPUT_TAX_CODE IS NOT NULL)
    THEN
     OPEN O;
     FETCH O INTO L_ORG_ID;
     CLOSE O;

     INSERT INTO PA_EVENT_TYPE_OUS
     ( EVENT_TYPE,
       OUTPUT_TAX_CLASSIFICATION_CODE,
       LAST_UPDATE_DATE,
       CREATION_DATE,
       LAST_UPDATED_BY,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       ORG_ID
     )
     VALUES
     ( X_Event_Type,
       X_OUTPUT_TAX_CODE,
       X_Last_Update_Date,
       X_Last_Update_Date,
       X_Last_Updated_By,
       X_Last_Updated_By,
       X_Last_Update_Login,
       L_ORG_ID );

    END IF;*/

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN               /* Rearranged the DELETE statements for bug 3182079 */
   BEGIN
     /*       Delete record from PA_EVENT_TYPE_OUS  */
           DELETE FROM PA_EVENT_TYPE_OUS_ALL
           WHERE  EVENT_TYPE = ( SELECT EVENT_TYPE
                                 FROM PA_EVENT_TYPES
                                 WHERE rowid = X_Rowid);
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
               null;
           WHEN OTHERS THEN
               raise ;
   END;
   BEGIN

        DELETE FROM PA_EVENT_TYPES
        WHERE rowid = X_Rowid;

         if (SQL%NOTFOUND) then
             Raise NO_DATA_FOUND;
         end if;
         EXCEPTION
	 WHEN OTHERS THEN
              raise ;
    END;
  END Delete_Row;

END PA_EVENT_TYPES_PKG;

/
