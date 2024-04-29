--------------------------------------------------------
--  DDL for Package Body IGI_SAP_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SAP_GROUP_PKG" as
-- $Header: igisiabb.pls 120.6.12000000.1 2007/09/12 11:47:17 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Group_Id                       IN OUT NOCOPY NUMBER,
                       X_Group_Name                     VARCHAR2,
                       X_Org_Id                         NUMBER,  /* bug # 5905278 start SIA R12 Uptake*/
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
 CURSOR C IS SELECT rowid FROM IGI_SAP_GROUP
                 WHERE group_id = X_Group_Id;
    CURSOR C2 IS SELECT igi_igi_sap_group_s.nextval FROM sys.dual;
   BEGIN
      if (X_Group_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Group_Id;
        CLOSE C2;
      end if;
   INSERT INTO IGI_SAP_GROUP(
              group_id,
              group_name,
              org_id,          /* bug # 5905278 start SIA R12 Uptake */
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by
             ) VALUES (
              X_Group_Id,
              X_Group_Name,
              X_Org_Id,        /* bug # 5905278 start SIA R12 Uptake */
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Last_Update_Date,
              X_Last_Updated_By
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
                     X_Group_Id                         NUMBER,
                     X_Group_Name                       VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
 	FROM	IGI_SAP_GROUP
        WHERE  rowid = X_Rowid
        FOR UPDATE of Group_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
          FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_sap_group_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.group_id =  X_Group_Id)
           AND (Recinfo.group_name =  X_Group_Name)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
          FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_sap_group_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Group_Id                       NUMBER,
                       X_Group_Name                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
  BEGIN
 	UPDATE IGI_SAP_GROUP
    SET
       group_id                        =     X_Group_Id,
       group_name                      =     X_Group_Name,
       last_update_login               =     X_Last_Update_Login,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_SAP_GROUP
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
END IGI_SAP_GROUP_PKG;

/
