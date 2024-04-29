--------------------------------------------------------
--  DDL for Package Body PA_EVENT_TYPE_OUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_TYPE_OUS_PKG" as
/* $Header: PAXETOUB.pls 120.1 2005/08/19 17:13:24 mwasowic noship $ */

   PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Event_Type                     VARCHAR2,
                       X_Output_tax_code                VARCHAR2,
                       X_ORG_ID                         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS

   BEGIN

      INSERT INTO PA_EVENT_TYPE_OUS_ALL
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
        X_ORG_ID );

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Event_Type                       VARCHAR2,
                     X_Output_tax_code                  VARCHAR2,
                     X_ORG_ID                           NUMBER
  ) IS
    --hsiu: modified cursor
    CURSOR C IS
        SELECT EOUS.EVENT_TYPE,
               EOUS.OUTPUT_TAX_CLASSIFICATION_CODE OUTPUT_TAX_CODE,
               EOUS.ORG_ID
        FROM   PA_EVENT_TYPE_OUS_ALL EOUS
        WHERE  EOUS.rowid = RTRIM(X_Rowid)
        FOR UPDATE of EOUS.OUTPUT_TAX_CLASSIFICATION_CODE NOWAIT;

    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (  RTRIM(Recinfo.event_type) =  RTRIM(X_Event_Type)
           AND rtrim(Recinfo.output_tax_code) =  rtrim(X_Output_tax_code)
           AND recinfo.org_id =X_oRG_ID)
       then
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
                       X_Output_tax_code                VARCHAR2,
                       X_ORG_ID                         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
 ) IS

    L_TAX_ID            NUMBER;
    L_ORG_ID            NUMBER;

  BEGIN

    UPDATE PA_EVENT_TYPE_OUS_ALL
    SET    OUTPUT_TAX_CLASSIFICATION_CODE = x_output_tax_code,
           LAST_UPDATE_DATE    = X_Last_Update_Date,
           LAST_UPDATED_BY     = X_Last_Updated_By,
           LAST_UPDATE_LOGIN   = X_Last_Update_Login
    WHERE  EVENT_TYPE          = X_Event_Type
      AND  ORG_ID              = X_ORG_ID;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN               /* Rearranged the DELETE statements for bug 3182079 */
   BEGIN
     /*       Delete record from PA_EVENT_TYPE_OUS  */
           DELETE FROM PA_EVENT_TYPE_OUS_ALL
           WHERE  ROWID = X_ROWID;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
               null;
           WHEN OTHERS THEN
               raise ;
   END;
  END Delete_Row;

END PA_EVENT_TYPE_OUS_PKG;

/
