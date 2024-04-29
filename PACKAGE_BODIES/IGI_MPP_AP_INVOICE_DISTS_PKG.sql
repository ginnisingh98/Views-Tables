--------------------------------------------------------
--  DDL for Package Body IGI_MPP_AP_INVOICE_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_MPP_AP_INVOICE_DISTS_PKG" as
 /* $Header: igipmudb.pls 115.7 2003/12/01 16:13:45 sdixit ship $ */

   --bug 3199481: following variables added for fnd logging changes:sdixit :start
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

     PROCEDURE Lock_Row(X_Rowid              VARCHAR2,
        X_Distribution_Line_Number           NUMBER,
        X_Invoice_Id                         NUMBER,
        X_Ignore_Mpp_Flag                    VARCHAR2,
        X_Accounting_Rule_Id                 VARCHAR2,
        X_Start_Date                         DATE,
        X_Duration                           NUMBER


     ) IS
       CURSOR C IS
          SELECT *
         FROM   igi_mpp_ap_invoice_dists
         WHERE  rowid = X_Rowid
         FOR UPDATE of Invoice_id, Distribution_Line_Number NOWAIT;
     Recinfo C%ROWTYPE;

   BEGIN
     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
       CLOSE C;
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
   --bug 3199481: fnd logging changes:sdixit :start
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmudb.IGI_MPP_AP_INVOICE_DISTS_PKG.Lock_Row.FORM_RECORD_DELETED',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
       APP_EXCEPTION.Raise_Exception;
     end if;
     CLOSE C;
     if (
             (Recinfo.distribution_line_number =  X_Distribution_Line_Number)
         AND (Recinfo.invoice_id =  X_Invoice_Id)
         AND (   (Recinfo.ignore_mpp_flag =  X_Ignore_Mpp_Flag)
              OR (    (Recinfo.ignore_mpp_flag IS NULL)
                   AND (X_Ignore_Mpp_Flag IS NULL)))
         AND (   (Recinfo.start_date =  X_start_date)
              OR (    (Recinfo.start_date IS NULL)
                   AND (X_Start_Date IS NULL)))
         AND (   (Recinfo.Duration =  X_Duration)
              OR (    (Recinfo.Duration IS NULL)
                   AND (X_Duration IS NULL)))
          AND (Recinfo.accounting_rule_id = X_Accounting_Rule_Id)

        ) then
        return;
      else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
   --bug 3199481: fnd logging changes:sdixit :start
        IF (l_error_level >=  l_debug_level ) THEN
           FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmerb.IGI_MPP_EXPENSE_RULES_PKG.Lock_Row.FORM_RECORD_CHANGED',FALSE);
        END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        APP_EXCEPTION.Raise_Exception;
      end if;
    END Lock_Row;


    PROCEDURE Update_Row(X_Rowid               VARCHAR2,
         X_Distribution_Line_Number            NUMBER,
         X_Invoice_Id                          NUMBER,
         X_Ignore_Mpp_Flag                     VARCHAR2,
         X_Accounting_Rule_Id                 VARCHAR2,
         X_Start_Date                          DATE,
         X_Duration                            NUMBER,
         X_Last_Updated_By                     NUMBER,
         X_Last_Update_Date                    DATE,
         X_Last_Update_Login                   NUMBER

     ) IS
     BEGIN
       UPDATE igi_mpp_ap_invoice_dists
       SET
         ignore_mpp_flag                    =  nvl(X_Ignore_Mpp_Flag,'N'),
         accounting_rule_id                 =  X_Accounting_Rule_Id,
         start_date                         =  X_Start_Date,
         duration                           =  X_Duration,
         last_updated_by                    =  X_Last_Updated_By,
         last_update_date                   =  X_Last_Update_Date,
         last_update_login                  =  X_Last_Update_Login
       WHERE rowid = X_Rowid;

       if (SQL%NOTFOUND) then
   --bug 3199481: fnd logging changes:sdixit :start
           IF (l_error_level >=  l_debug_level ) THEN
              FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmudb.IGI_MPP_AP_INVOICE_DISTS_PKG.Update_Row.NO_DATA_FOUND',FALSE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
         Raise NO_DATA_FOUND;
       end if;
     END Update_Row;


END IGI_MPP_AP_INVOICE_DISTS_PKG;

/
