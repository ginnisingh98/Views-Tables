--------------------------------------------------------
--  DDL for Package Body IGI_DUN_LETTER_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DUN_LETTER_SETS_PKG" as
  /* $Header: igidunob.pls 120.4.12000000.1 2007/10/26 13:30:19 gigupta ship $ */

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

    PROCEDURE Insert_Row(X_Rowid                IN OUT NOCOPY VARCHAR2,
        X_Dunning_Letter_Set_Id              NUMBER,
        X_Use_Dunning_Flag                   VARCHAR2,
        X_Charge_Per_Invoice_Flag            VARCHAR2,
        X_Created_By                         NUMBER,
        X_Creation_Date                      DATE,
        X_Last_Updated_By                    NUMBER,
        X_Last_Update_Date                   DATE,
        X_Last_Update_Login                  NUMBER


      ) IS
        CURSOR C IS SELECT rowid FROM igi_dun_letter_sets
              WHERE dunning_letter_set_id = X_Dunning_Letter_Set_Id;


      BEGIN


       INSERT INTO igi_dun_letter_sets(
        dunning_letter_set_id,
        use_dunning_flag,
        charge_per_invoice_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
              ) VALUES (
        X_Dunning_Letter_Set_Id,
        X_Use_Dunning_Flag,
        X_Charge_Per_Invoice_Flag,
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
        X_Dunning_Letter_Set_Id              NUMBER,
        X_Use_Dunning_Flag                   VARCHAR2,
        X_Charge_Per_Invoice_Flag            VARCHAR2

     ) IS
       CURSOR C IS
          SELECT *
         FROM   igi_dun_letter_sets
         WHERE  rowid = X_Rowid
         FOR UPDATE of Dunning_Letter_Set_Id NOWAIT;
     Recinfo C%ROWTYPE;


   BEGIN
     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
       CLOSE C;
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_excep_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_excep_level , 'igi.plsql.igidunob.IGI_DUN_LETTER_SETS_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
       APP_EXCEPTION.Raise_Exception;
     end if;
     CLOSE C;
     if (
             (Recinfo.dunning_letter_set_id =  X_Dunning_Letter_Set_Id)
         AND (Recinfo.use_dunning_flag =  X_Use_Dunning_Flag)
         AND (Recinfo.charge_per_invoice_flag =  X_Charge_Per_Invoice_Flag)

        ) then
        return;
      else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_excep_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_excep_level , 'igi.plsql.igidunob.IGI_DUN_LETTER_SETS_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        APP_EXCEPTION.Raise_Exception;
      end if;
    END Lock_Row;


      PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
         X_Dunning_Letter_Set_Id               NUMBER,
         X_Use_Dunning_Flag                    VARCHAR2,
         X_Charge_Per_Invoice_Flag             VARCHAR2,
         X_Last_Updated_By                     NUMBER,
         X_Last_Update_Date                    DATE,
         X_Last_Update_Login                   NUMBER

     ) IS
     BEGIN
       UPDATE igi_dun_letter_sets
       SET
         dunning_letter_set_id              =  X_Dunning_Letter_Set_Id,
         use_dunning_flag                   =  X_Use_Dunning_Flag,
         charge_per_invoice_flag            =  X_Charge_Per_Invoice_Flag,
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
       DELETE FROM igi_dun_letter_sets
       WHERE rowid = X_Rowid;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;
     END Delete_Row;


  END IGI_DUN_LETTER_SETS_PKG;

/
