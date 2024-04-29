--------------------------------------------------------
--  DDL for Package Body PA_COST_DIST_OVERRIDES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_DIST_OVERRIDES_PKG" as
/* $Header: PAXPRORB.pls 120.2 2005/08/03 13:57:27 aaggarwa noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Cost_Dist_Override_Id  IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Override_To_Org_Id    NUMBER,
                       X_Start_Date_Active              DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Person_Id                      NUMBER,
                       X_Expenditure_Category           VARCHAR2,
                       X_Override_From_Org_Id   NUMBER,
                       X_End_Date_Active                DATE
  ) IS
    CURSOR C IS SELECT rowid FROM PA_COST_DIST_OVERRIDES
     WHERE cost_distribution_override_id = X_Cost_Dist_Override_Id;
      CURSOR C2 IS SELECT pa_cost_dist_overrides_s.nextval FROM sys.dual;
   BEGIN
      if (X_Cost_Dist_Override_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Cost_Dist_Override_Id;
        CLOSE C2;
      end if;

       INSERT INTO PA_COST_DIST_OVERRIDES(
              cost_distribution_override_id,
              project_id,
              override_to_organization_id,
              start_date_active,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              person_id,
              expenditure_category,
              override_from_organization_id,
              end_date_active
             ) VALUES (
              X_Cost_Dist_Override_Id,
              X_Project_Id,
              X_Override_To_Org_Id,
              X_Start_Date_Active,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Person_Id,
              X_Expenditure_Category,
              X_Override_From_Org_Id,
              X_End_Date_Active
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
                     X_Cost_Dist_Override_Id    NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Override_To_Org_Id      NUMBER,
                     X_Start_Date_Active                DATE,
                     X_Person_Id                        NUMBER,
                     X_Expenditure_Category             VARCHAR2,
                     X_Override_From_Org_Id    NUMBER,
                     X_End_Date_Active                  DATE
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_COST_DIST_OVERRIDES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Cost_Distribution_Override_Id NOWAIT;
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
    (Recinfo.cost_distribution_override_id =  X_Cost_Dist_Override_Id)
           AND (Recinfo.project_id =  X_Project_Id)
    AND (Recinfo.override_to_organization_id =  X_Override_To_Org_Id)
           AND (Recinfo.start_date_active =  X_Start_Date_Active)
           AND (   (Recinfo.person_id =  X_Person_Id)
                OR (    (Recinfo.person_id IS NULL)
                    AND (X_Person_Id IS NULL)))
           AND (   (Recinfo.expenditure_category =  X_Expenditure_Category)
                OR (    (Recinfo.expenditure_category IS NULL)
                    AND (X_Expenditure_Category IS NULL)))
    AND ( (Recinfo.override_from_organization_id =  X_Override_From_Org_Id)
                OR (    (Recinfo.override_from_organization_id IS NULL)
                    AND (X_Override_From_Org_Id IS NULL)))
           AND (   (Recinfo.end_date_active =  X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cost_Dist_Override_Id  NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Override_To_Org_Id    NUMBER,
                       X_Start_Date_Active              DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Person_Id                      NUMBER,
                       X_Expenditure_Category           VARCHAR2,
                       X_Override_From_Org_Id  NUMBER,
                       X_End_Date_Active                DATE
  ) IS
  BEGIN
    UPDATE PA_COST_DIST_OVERRIDES
    SET
       cost_distribution_override_id   =     X_Cost_Dist_Override_Id,
       project_id                      =     X_Project_Id,
       override_to_organization_id     =     X_Override_To_Org_Id,
       start_date_active               =     X_Start_Date_Active,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       person_id                       =     X_Person_Id,
       expenditure_category            =     X_Expenditure_Category,
       override_from_organization_id   =     X_Override_From_Org_Id,
       end_date_active                 =     X_End_Date_Active
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_COST_DIST_OVERRIDES
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_COST_DIST_OVERRIDES_PKG;

/
