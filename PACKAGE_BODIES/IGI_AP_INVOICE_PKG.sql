--------------------------------------------------------
--  DDL for Package Body IGI_AP_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_AP_INVOICE_PKG" as
-- $Header: igisiafb.pls 120.3.12000000.1 2007/09/12 11:47:47 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;


PROCEDURE Lock_Row(X_Rowid		VARCHAR2
		  ,X_Invoice_Id		NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AP_INVOICES
        WHERE  rowid = X_Rowid
        FOR UPDATE of  Invoice_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_ap_invoice_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.invoice_id =  X_Invoice_Id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_ap_invoice_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


PROCEDURE Update_Row  (X_Rowid                VARCHAR2
                        ,X_igi_sap_flag       VARCHAR2
                        ,X_Last_Update_Login    NUMBER
                        ,X_Last_Update_Date     DATE
                        ,X_Last_Updated_By      NUMBER
                        ) IS
                        BEGIN
 				UPDATE IGI_INVOICE_DISTRIBUTIONS_ALL
                                SET
                                igi_sap_flag            =       X_igi_sap_flag,
                                last_update_login       =       X_Last_Update_Login,
                                last_updated_by         =       X_Last_Updated_By,
                                last_update_date        =       X_Last_Update_Date
                                WHERE rowid = X_Rowid;
                                if (SQL%NOTFOUND) then
                                  Raise NO_DATA_FOUND;
                                end if;
END Update_Row;
END IGI_AP_INVOICE_PKG;

/
