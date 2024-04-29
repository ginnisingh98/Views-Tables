--------------------------------------------------------
--  DDL for Package Body IGI_BUD_PROFILE_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD_PROFILE_PERIODS_PKG" as
-- $Header: igibudcb.pls 120.4 2005/10/30 05:51:37 appldev ship $

--Bug 3199481

l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
l_event_level   number := FND_LOG.LEVEL_EVENT ;
l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
l_error_level   number := FND_LOG.LEVEL_ERROR ;
l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

--Bug 3199481

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Period_Number                  NUMBER,
                       X_Period_Ratio                   NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM igi_bud_profile_periods
                 WHERE period_number = X_Period_Number;

   BEGIN

       INSERT INTO igi_bud_profile_periods(
              profile_code,
              set_of_books_id,
              period_number,
              period_ratio,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Profile_Code,
              X_Set_Of_Books_Id,
              X_Period_Number,
              X_Period_Ratio,
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


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Profile_Code                     VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Period_Number                    NUMBER,
                     X_Period_Ratio                     NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   igi_bud_profile_periods
        WHERE  rowid = X_Rowid
        FOR UPDATE of Period_Number NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
            FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_profiles_period_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.profile_code =  X_Profile_Code)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.period_number =  X_Period_Number)
           AND (Recinfo.period_ratio =  X_Period_Ratio)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
       --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
          FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_profiles_period_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Period_Number                  NUMBER,
                       X_Period_Ratio                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE igi_bud_profile_periods
    SET
       profile_code                    =     X_Profile_Code,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       period_number                   =     X_Period_Number,
       period_ratio                    =     X_Period_Ratio,
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
    DELETE FROM igi_bud_profile_periods
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_BUD_PROFILE_PERIODS_PKG;

/
