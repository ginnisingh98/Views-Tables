--------------------------------------------------------
--  DDL for Package Body AP_PBATCH_SET_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PBATCH_SET_HEADER_PKG" as
/* $Header: apbsethb.pls 120.2 2004/10/27 01:28:34 pjena noship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY   VARCHAR2,
                     X_Batch_Set_Name                   VARCHAR2,
                     X_Batch_Set_Id            IN OUT NOCOPY   NUMBER,
                     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Last_Update_Login                NUMBER DEFAULT NULL,
                     X_Creation_Date                    DATE DEFAULT NULL,
                     X_Created_By                       NUMBER DEFAULT NULL,
                     X_Inactive_Date                    DATE DEFAULT NULL,
		     X_calling_sequence	      IN	VARCHAR2
  ) IS
    l_Batch_Set_Id           NUMBER;
    CURSOR C IS SELECT rowid FROM ap_pbatch_sets
                 WHERE batch_set_id = l_Batch_Set_Id;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

   BEGIN
    -- Update the calling sequence
    --
       current_calling_sequence :=
       'AP_PBATCH_SET_HEADER_PKG.INSERT_ROW<-'||X_Calling_Sequence;

       debug_info := 'Get next Batch set Id';

       select ap_pbatch_sets_s.nextval
       into l_batch_set_id
       from sys.dual;

       debug_info := 'Insert into ap_pbatch_sets';
       INSERT INTO ap_pbatch_sets(
              batch_set_name,
              batch_set_id,
              inactive_date,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by
             ) VALUES (
              X_Batch_Set_Name,
              l_Batch_Set_Id,
              X_Inactive_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By
              );

   debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    X_Batch_Set_Id := l_Batch_Set_Id ;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Batch Set Id = '||X_Batch_Set_Id
                                       ||', ROWID = '||X_ROWID);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

    PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Set_Name                 VARCHAR2,
                       X_Batch_Set_Id                   NUMBER,
                       X_Inactive_Date                  DATE DEFAULT NULL,
		       X_calling_sequence	IN	VARCHAR2

  ) IS
    CURSOR C IS
        SELECT *
        FROM   ap_pbatch_sets
        WHERE  rowid = X_Rowid
        FOR UPDATE of Batch_Set_Name NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_HEADER_PKG.LOCK_ROW<-'||X_Calling_Sequence;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C -ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (
               (Recinfo.batch_set_name =  X_Batch_Set_Name)
           AND (Recinfo.batch_set_id =  X_Batch_Set_Id)
       ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
       IF (SQLCODE = -54) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
       ELSE
         FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','Batch Set Name = '||
                                X_Batch_Set_Name
                               ||', ROWID = '||X_Rowid);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
       END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Set_Name                 VARCHAR2,
                       X_Batch_Set_Id                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Inactive_Date                  DATE DEFAULT NULL,
		       X_calling_sequence	IN	VARCHAR2

  ) IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_HEADER_PKG.UPDATE_ROW<-'||X_Calling_Sequence;

    debug_info := 'Update ap_pbatch_sets';
    UPDATE ap_pbatch_sets
    SET
       batch_set_name                  =     X_Batch_Set_Name,
       batch_set_id                    =     X_Batch_Set_Id,
       inactive_date                   =     X_Inactive_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Batch Set Id ='||X_Batch_Set_Id
                                        ||', ROWID = '||X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Row;

/*
   PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_HEADER_PKG.DELETE_ROW<-'||X_Calling_Sequence;

    debug_info := 'Delete from ap_pbatch_sets';
    DELETE FROM ap_pbatch_sets
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'ROWID = ' || X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Delete_Row;
*/

END AP_PBATCH_SET_HEADER_PKG;

/
