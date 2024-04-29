--------------------------------------------------------
--  DDL for Package Body IGI_DUN_CUST_LET_SET_CUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DUN_CUST_LET_SET_CUR_PKG" as
  /* $Header: igidunkb.pls 115.6 2003/11/27 13:09:43 sdixit ship $ */

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

    PROCEDURE Insert_Row(X_Rowid                IN OUT NOCOPY VARCHAR2,
        X_Customer_Profile_Id                NUMBER,
        X_Currency_Code                      VARCHAR2,
        X_Created_By                         NUMBER,
        X_Creation_Date                      DATE,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER

      ) IS
        CURSOR C IS SELECT rowid FROM igi_dun_cust_letter_set_cur
              WHERE customer_profile_id = X_Customer_Profile_Id
         	AND   currency_code = X_Currency_Code;

    BEGIN

       INSERT INTO igi_dun_cust_letter_set_cur(
        customer_profile_id,
        currency_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
              ) VALUES (
        X_Customer_Profile_Id,
        X_Currency_Code,
        X_Created_By,
        X_Creation_Date,
        X_Last_Updated_By,
        X_Last_Update_Date,
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
        X_Customer_Profile_Id                NUMBER,
        X_Currency_Code                      VARCHAR2

     ) IS
       CURSOR C IS
          SELECT *
         FROM   igi_dun_cust_letter_set_cur
         WHERE  rowid = X_Rowid
         FOR UPDATE of Customer_Profile_Id NOWAIT;
     Recinfo C%ROWTYPE;

   BEGIN
     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
       CLOSE C;
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_excep_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_excep_level , 'igi.plsql.igidunkb.IGI_DUN_CUST_LET_SET_CUR_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
       APP_EXCEPTION.Raise_Exception;
     end if;
     CLOSE C;
     if (
             (Recinfo.customer_profile_id =  X_Customer_Profile_Id)
         AND (Recinfo.currency_code =  X_Currency_Code)

        ) then
        return;
      else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_excep_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_excep_level , 'igi.plsql.igidunkb.IGI_DUN_CUST_LET_SET_CUR_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        APP_EXCEPTION.Raise_Exception;
      end if;
    END Lock_Row;

      PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
         X_Customer_Profile_Id                 NUMBER,
         X_Currency_Code                       VARCHAR2,
         X_Last_Updated_By                     NUMBER,
         X_Last_Update_Date                    DATE,
         X_Last_Update_Login                   NUMBER

     ) IS
     BEGIN
       UPDATE igi_dun_cust_letter_set_cur
       SET
         customer_profile_id                =  X_Customer_Profile_Id,
         currency_code                      =  X_Currency_Code,
         last_updated_by                    =  X_Last_Updated_By,
         last_update_date                   =  X_Last_Update_Date,
         last_update_login                  =  X_Last_Update_Login
       WHERE rowid = X_Rowid;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;
     END Update_Row;

     PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
     BEGIN
       DELETE FROM igi_dun_cust_letter_set_cur
       WHERE rowid = X_Rowid;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;
     END Delete_Row;


  END IGI_DUN_CUST_LET_SET_CUR_PKG;

/
