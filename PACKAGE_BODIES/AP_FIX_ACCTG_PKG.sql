--------------------------------------------------------
--  DDL for Package Body AP_FIX_ACCTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_FIX_ACCTG_PKG" as
/* $Header: apfixacb.pls 115.2 2002/03/13 18:15:07 pkm ship      $ */

  PROCEDURE Update_Row(
                   X_Rowid                 IN VARCHAR2,
                   X_Code_Combination_Id   IN NUMBER,
                   X_Description           IN VARCHAR2,
                   X_Last_Update_Date      IN DATE,
                   X_Last_Updated_By       IN NUMBER,
                   X_Last_Update_Login     IN NUMBER ,
                   X_Calling_Sequence      IN VARCHAR2,
                   X_Accounting_Error_Code IN VARCHAR2 -- Bug 1369125
                      ) IS
    Current_Calling_Sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    Current_Calling_Sequence := 'AP_FIX_ACCTG_PKG.UPDATE_ROW<-' ||
                                 X_Calling_Sequence;

    debug_info := 'Update ap_ae_lines';

    UPDATE ap_ae_lines
    SET    code_combination_id   = X_Code_Combination_Id,
           description           = X_Description,
           last_update_date      = X_Last_Update_Date,
           last_updated_by       = X_Last_Updated_By,
           last_update_login     = X_Last_Update_Login,
           Accounting_Error_Code = X_Accounting_Error_Code -- Bug 1369125
    WHERE  Rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',Current_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;


  PROCEDURE Lock_Row(
                 X_Rowid               IN VARCHAR2,
                 X_Code_Combination_Id IN NUMBER,
                 X_Description         IN VARCHAR2,
                 X_Calling_Sequence    IN VARCHAR2
                     ) IS
    CURSOR C IS
        SELECT   *
        FROM     ap_ae_lines
        WHERE    rowid = X_Rowid
        FOR UPDATE of code_combination_id, description NOWAIT;
    Recinfo                     C%ROWTYPE;
    Current_Calling_Sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    Current_Calling_Sequence := 'AP_FIX_ACCTG_PKG.LOCK_ROW<-' ||
                                 X_Calling_Sequence;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;
    IF (
        (Recinfo.Code_Combination_Id =  X_Code_Combination_Id)
         AND (   (Recinfo.Description =  X_Description)
         OR  (   (Recinfo.Description IS NULL)
             AND (X_Description IS NULL)))
        ) THEN
           RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          IF (SQLCODE = -54) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
          ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',Current_Calling_Sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid );
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          END IF;
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


END AP_FIX_ACCTG_PKG;

/
