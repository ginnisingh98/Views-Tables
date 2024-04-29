--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CONTACTS_PKG" as
/* $Header: PAXPRCOB.pls 120.1 2005/08/19 17:17:12 mwasowic noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895

                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
		       X_Bill_Ship_Customer_Id          NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Project_Contact_Type_Code      VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Record_Version_Number          NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM pa_project_contacts
                 WHERE project_id = X_Project_Id
                 AND   customer_id = X_Customer_Id
                 AND   contact_id = X_Contact_Id;

   BEGIN


       INSERT INTO pa_project_contacts(

              project_id,
              customer_id,
	      bill_ship_customer_id,
              contact_id,
              project_contact_type_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              record_version_number
             ) VALUES (

              X_Project_Id,
              X_Customer_Id,
	      X_Bill_Ship_Customer_Id,
              X_Contact_Id,
              X_Project_Contact_Type_Code,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Record_Version_Number
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

                     X_Project_Id                       NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Contact_Id                       NUMBER,
                     X_Project_Contact_Type_Code        VARCHAR2,
                     X_Record_Version_Number            NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_contacts
        WHERE  rowid = X_Rowid
        FOR UPDATE of Project_Id NOWAIT;
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
    if recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    if (

               (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.customer_id =  X_Customer_Id)
           AND (Recinfo.contact_id =  X_Contact_Id)
           AND (Recinfo.project_contact_type_code =  X_Project_Contact_Type_Code
)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Project_Id                     NUMBER,
                       X_Customer_Id                    NUMBER,
		       X_Bill_Ship_Customer_Id          NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Project_Contact_Type_Code      VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Record_Version_Number          NUMBER

  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_contacts
        WHERE  rowid = X_Rowid;
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
    if recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    UPDATE pa_project_contacts
    SET
       project_id                      =     X_Project_Id,
       customer_id                     =     X_Customer_Id,
       bill_ship_customer_id           =     X_Bill_Ship_Customer_Id,
       contact_id                      =     X_Contact_Id,
       project_contact_type_code       =     X_Project_Contact_Type_Code,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       record_Version_number           =     X_Record_Version_Number + 1
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       x_record_version_number number) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_contacts
        WHERE  rowid = X_Rowid;
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
    if recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    DELETE FROM pa_project_contacts
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_PROJECT_CONTACTS_PKG;

/
