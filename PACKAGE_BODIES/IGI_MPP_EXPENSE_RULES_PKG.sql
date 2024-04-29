--------------------------------------------------------
--  DDL for Package Body IGI_MPP_EXPENSE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_MPP_EXPENSE_RULES_PKG" as
 /* $Header: igipmerb.pls 115.7 2003/12/01 14:57:30 sdixit ship $ */

 --bug 3199481: following variables added for fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

     PROCEDURE Lock_Row(X_Rowid              VARCHAR2,
        X_Expense_Ccid                       NUMBER,
        X_Default_Accounting_Rule_Id         NUMBER,
        X_Enabled_Flag                       VARCHAR2,
        X_Org_Id                             NUMBER,
        X_Set_Of_Books_Id                    NUMBER

     ) IS
       CURSOR C IS
          SELECT *
         FROM   igi_mpp_expense_rules
         WHERE  rowid = X_Rowid
         FOR UPDATE of Expense_Ccid NOWAIT;
     Recinfo C%ROWTYPE;

   BEGIN
     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
       CLOSE C;
   --bug 3199481 fnd logging changes: sdixit: start block
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmerb.IGI_MPP_EXPENSE_RULES_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
       APP_EXCEPTION.Raise_Exception;
     end if;
     CLOSE C;
     if (
             (Recinfo.expense_ccid =  X_Expense_Ccid)
         AND (Recinfo.default_accounting_rule_id =  X_Default_Accounting_Rule_Id)
         AND (   (Recinfo.enabled_flag =  X_Enabled_Flag)
              OR (    (Recinfo.enabled_flag IS NULL)
                   AND (X_Enabled_Flag IS NULL)))
         AND (   (Recinfo.org_id =  X_Org_Id)
              OR (    (Recinfo.org_id IS NULL)
                   AND (X_Org_Id IS NULL)))
         AND (Recinfo.set_of_books_id = X_Set_Of_Books_Id)


        ) then
        return;
      else
   --bug 3199481 fnd logging changes: sdixit: start block
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        IF (l_error_level >=  l_debug_level ) THEN
           FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmerb.IGI_MPP_EXPENSE_RULES_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        APP_EXCEPTION.Raise_Exception;
      end if;
    END Lock_Row;


    PROCEDURE Update_Row(X_Rowid               VARCHAR2,
         X_Expense_Ccid                        NUMBER,
         X_Default_Accounting_Rule_Id          NUMBER,
         X_Enabled_Flag                        VARCHAR2,
         X_Last_Updated_By                     NUMBER,
         X_Last_Update_Date                    DATE,
         X_Last_Update_Login                   NUMBER

     ) IS
     BEGIN
       UPDATE igi_mpp_expense_rules
       SET
         expense_ccid                       =  X_Expense_Ccid,
         default_accounting_rule_id         =  X_Default_Accounting_Rule_Id,
         enabled_flag                       =  X_Enabled_Flag,
         last_updated_by                    =  X_Last_Updated_By,
         last_update_date                   =  X_Last_Update_Date,
         last_update_login                  =  X_Last_Update_Login
       WHERE rowid = X_Rowid;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;
     END Update_Row;


     PROCEDURE Insert_Row(X_Rowid          IN OUT NOCOPY     VARCHAR2,
         X_Expense_Ccid                         NUMBER,
         X_Default_Accounting_Rule_Id           NUMBER,
         X_Enabled_Flag                         VARCHAR2,
         X_Org_Id                               NUMBER,
         X_Set_Of_Books_Id                      NUMBER,
         X_Created_By                           NUMBER,
         X_Creation_Date                        DATE,
         X_Last_Updated_By                      NUMBER,
         X_Last_Update_Date                     DATE,
         X_Last_Update_Login                    NUMBER
      ) IS
        CURSOR C IS SELECT rowid FROM igi_mpp_expense_rules
           WHERE expense_ccid = X_Expense_Ccid;

        BEGIN

            INSERT INTO igi_mpp_expense_rules(
                           expense_ccid,
                           default_accounting_rule_id,
                           enabled_flag,
                           org_id,
                           set_of_books_id,
                           created_by,
                           creation_date,
			   last_updated_by,
                           last_update_date,
			   last_update_login
                         )
                  VALUES ( X_Expense_Ccid,
                           X_Default_Accounting_Rule_Id,
                           X_Enabled_Flag,
                           X_Org_Id,
                           X_Set_Of_Books_Id,
                           X_Created_By,
                           X_Creation_Date,
			   X_Last_Updated_By,
			   X_Last_Update_Date,
			   X_Last_Update_Login
                         );

       OPEN C;
       FETCH C INTO X_Rowid;
       IF (C%NOTFOUND) THEN
          CLOSE C;
          RAISE no_data_found;
       END IF;
       CLOSE C;
     END Insert_Row;


     PROCEDURE Delete_Row(X_Rowid      VARCHAR2) IS
     BEGIN
        DELETE FROM igi_mpp_expense_rules
        WHERE rowid = X_Rowid;
        IF (SQL%NOTFOUND) THEN
           RAISE no_data_found;
        END IF;
     END Delete_Row;

END IGI_MPP_EXPENSE_RULES_PKG;

/
