--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ASSET_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ASSET_ASSIGN_PKG" as
/* $Header: PAXASSNB.pls 120.2 2005/08/19 16:18:54 ramurthy noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,

                       X_Project_Asset_Id               NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  		) IS
    CURSOR C IS SELECT rowid FROM pa_project_asset_assignments
                 WHERE  project_asset_id = X_project_asset_id AND
			project_id = X_project_id AND
			task_id = X_task_id;

   BEGIN

       INSERT INTO pa_project_asset_assignments(
              project_asset_id,
              task_id,
              project_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login
             ) VALUES (
              X_Project_Asset_Id,
              X_Task_Id,
              X_Project_Id,
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
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Asset_Id                 NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Project_Id                       NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_project_asset_assignments
        WHERE  rowid = X_Rowid
        FOR UPDATE of project_asset_id, project_id, task_id  NOWAIT;
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
               (Recinfo.project_asset_id =  X_Project_Asset_Id)
           AND (   (Recinfo.task_id =  X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (Recinfo.project_id =  X_Project_Id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Project_Asset_Id               NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE pa_project_asset_assignments
    SET
       project_asset_id                =     X_Project_Asset_Id,
       task_id                         =     X_Task_Id,
       project_id                      =     X_Project_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM pa_project_asset_assignments
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_PROJ_ASSET_ASSIGN_PKG;

/
