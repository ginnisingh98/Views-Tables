--------------------------------------------------------
--  DDL for Package Body IGI_IGI_ITR_CHARGE_CENTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGI_ITR_CHARGE_CENTER_PKG" as
-- $Header: igiitreb.pls 120.5.12000000.1 2007/09/12 10:30:49 mbremkum ship $
--


  l_debug_level number  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level number   :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level number  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level number  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level number  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level number  :=      FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Charge_Center_Id               IN OUT NOCOPY NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_ITR_CHARGE_CENTER
                 WHERE charge_center_id = X_Charge_Center_Id
                 AND   set_of_books_id = X_Set_Of_Books_Id;
      CURSOR C2 IS SELECT IGI_IGI_itr_charge_center_s.nextval FROM sys.dual;
   BEGIN
      if (X_Charge_Center_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Charge_Center_Id;
        CLOSE C2;
      end if;

       INSERT INTO IGI_ITR_CHARGE_CENTER(
              charge_center_id,
              name,
              set_of_books_id,
              start_date_active,
              end_date_active,
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by
             ) VALUES (
              X_Charge_Center_Id,
              X_Name,
              X_Set_Of_Books_Id,
              X_Start_Date_Active,
              X_End_Date_Active,
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
                     X_Charge_Center_Id                 NUMBER,
                     X_Name                             VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE
  ) IS

    CURSOR C IS
        SELECT *
        FROM   IGI_ITR_CHARGE_CENTER
        WHERE  rowid = X_Rowid
        FOR UPDATE of Charge_Center_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF ( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitreb.IGI_IGI_ITR_CHARGE_CENTER_PKG.lock_row.msg1', FALSE);
	END IF;


      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.charge_center_id =  X_Charge_Center_Id)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.start_date_active =  X_Start_Date_Active)
           AND (   (Recinfo.end_date_active =  X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF ( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitreb.IGI_IGI_ITR_CHARGE_CENTER_PKG.lock_row.msg2', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
  BEGIN
    UPDATE IGI_ITR_CHARGE_CENTER
    SET
       charge_center_id                =     X_Charge_Center_Id,
       name                            =     X_Name,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       start_date_active               =     X_Start_Date_Active,
       end_date_active                 =     X_End_Date_Active,
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
    DELETE FROM IGI_ITR_CHARGE_CENTER
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_IGI_ITR_CHARGE_CENTER_PKG;

/
