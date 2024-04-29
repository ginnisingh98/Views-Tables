--------------------------------------------------------
--  DDL for Package Body IGI_ITR_APPROVAL_LINES_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_APPROVAL_LINES_SS_PKG" as
-- $Header: igiitrmb.pls 120.4.12000000.1 2007/09/12 10:31:55 mbremkum ship $
--

  l_debug_level number  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level number   :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level number  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level number  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level number  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level number  :=      FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Lock_Row(X_Rowid                      VARCHAR2,
                     X_It_Service_Line_Id         NUMBER,
                     X_Status_Flag                VARCHAR2,
                     X_Rejection_Note             VARCHAR2,
                     X_Suggested_Amount           NUMBER,
                     X_Suggested_Recv_Ccid        NUMBER
                    )
      IS

      CURSOR C IS
        SELECT * FROM igi_itr_charge_lines
        WHERE rowid = X_Rowid
        FOR UPDATE OF It_Service_Line_Id NOWAIT;

      Recinfo C%ROWTYPE;

  BEGIN
        OPEN C;
        FETCH C INTO Recinfo;
        IF (C%NOTFOUND) THEN
           CLOSE C;
           FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrmb.IGI_ITR_APPROVAL_LINES_SS_PKG.lock_row.msg1', FALSE);
	END IF;

           APP_EXCEPTION.Raise_Exception;
        END IF;
        CLOSE C;
        IF (
                   (Recinfo.It_Service_Line_Id = X_It_Service_Line_Id)
              AND  (    (Recinfo.Status_Flag = X_Status_Flag)
                    OR  (    (Recinfo.Status_Flag IS NULL)
                         AND (X_Status_Flag IS NULL)))
              AND  (    (Recinfo.Rejection_Note = X_Rejection_Note)
                    OR  (     (Recinfo.Rejection_Note IS NULL)
                         AND  (X_Rejection_Note IS NULL)))
              AND  (    (Recinfo.Suggested_Amount = X_Suggested_Amount)
                    OR  (     (Recinfo.Suggested_Amount IS NULL)
                         AND  (X_Suggested_Amount IS NULL)))
              AND  (    (Recinfo.Suggested_Recv_Ccid = X_Suggested_Recv_Ccid)
                    OR  (     (Recinfo.Suggested_Recv_Ccid IS NULL)
                         AND  (X_Suggested_Recv_Ccid IS NULL)))
          ) THEN
          RETURN;
       ELSE
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrmb.IGI_ITR_APPROVAL_LINES_SS_PKG.lock_row.msg2', FALSE);
	END IF;

          APP_EXCEPTION.Raise_Exception;
       END IF;
  END Lock_Row;




  PROCEDURE Update_Row(X_Rowid                      VARCHAR2,
                       X_Status_Flag                VARCHAR2,
                       X_Rejection_Note             VARCHAR2,
                       X_Suggested_Amount           NUMBER,
                       X_Suggested_Recv_Ccid        NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Last_Updated_By            NUMBER,
                       X_Last_Update_Date           DATE
                      ) IS
  BEGIN
     UPDATE igi_itr_charge_lines
     SET
        Status_Flag           =     X_Status_Flag,
        Rejection_Note        =     X_Rejection_Note,
        Suggested_Amount      =     X_Suggested_Amount,
        Suggested_Recv_Ccid   =     X_Suggested_Recv_Ccid,
        Last_Update_Login     =     X_Last_Update_Login,
        Last_Updated_By       =     X_Last_Updated_By,
        Last_Update_Date      =     X_Last_Update_Date
    WHERE rowid = X_Rowid;
    IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
    END IF;
  END Update_Row;


END IGI_ITR_APPROVAL_LINES_SS_PKG;

/
