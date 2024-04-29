--------------------------------------------------------
--  DDL for Package Body IGI_AP_INV_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_AP_INV_DIST_PKG" as
-- $Header: igisiaeb.pls 120.4.12000000.1 2007/09/12 11:47:40 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;


PROCEDURE Lock_Row(X_Rowid              VARCHAR2
                  ,X_igi_sap_flag     VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
	FROM AP_INVOICE_DISTRIBUTIONS_ALL
        WHERE  rowid = X_Rowid
        FOR UPDATE of  invoice_id NOWAIT;
    Recinfo C%ROWTYPE;

 /* bug # 5905278 start R12 Uptake of SIA - cursor C1 is modified to include invoice_line_number  */
 /* CURSOR C1 IS
        SELECT *
	FROM IGI_INVOICE_DISTRIBUTIONS_ALL
        WHERE  (invoice_id,distribution_line_number,org_id) =
               (SELECT invoice_id,distribution_line_number, org_id
                FROM   AP_INVOICE_DISTRIBUTIONS_ALL
                WHERE  rowid = X_Rowid)
        FOR UPDATE of  igi_sap_flag NOWAIT; */
   CURSOR C1 IS
        SELECT *
	FROM IGI_INVOICE_DISTRIBUTIONS_ALL
        WHERE  (invoice_id,invoice_line_number,distribution_line_number,org_id) =
               (SELECT invoice_id,invoice_line_number,distribution_line_number, org_id
                FROM   AP_INVOICE_DISTRIBUTIONS_ALL
                WHERE  rowid = X_Rowid)
        FOR UPDATE of  igi_sap_flag NOWAIT;
    Recinfo1 C1%ROWTYPE;
  BEGIN
--
-- Ensure that invoice record and corresponding record in extended table are both locked
--
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_ap_inv_dist_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    OPEN C1;
    FETCH C1 INTO Recinfo1;
    if (C1%NOTFOUND) then
      CLOSE C1;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_ap_inv_dist_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C1;
    if (
               (nvl(Recinfo1.igi_sap_flag,'N') =  X_igi_sap_flag)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_ap_inv_dist_pkg.lock_row.Msg3',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

PROCEDURE Update_Row	(X_Rowid                VARCHAR2
                	,X_igi_sap_flag       VARCHAR2
                	,X_Last_Update_Login    NUMBER
                	,X_Last_Update_Date     DATE
                	,X_Last_Updated_By      NUMBER
                	) IS
			BEGIN
				UPDATE IGI_INVOICE_DISTRIBUTIONS_ALL
				SET
				igi_sap_flag		= 	X_igi_sap_flag,
				last_update_login	=	X_Last_Update_Login,
				last_updated_by		=	X_Last_Updated_By,
				last_update_date	=	X_Last_Update_Date
				WHERE rowid = X_Rowid;
				if (SQL%NOTFOUND) then
      				  Raise NO_DATA_FOUND;
				end if;
			END Update_Row;
END IGI_AP_INV_DIST_PKG;

/
