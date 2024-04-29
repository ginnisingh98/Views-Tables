--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_ASSET_APPRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_ASSET_APPRS_PKG" as
/* $Header: jlcoftab.pls 115.1 2002/11/13 23:30:45 vsidhart ship $ */

  PROCEDURE Insert_Row(X_rowid                   IN OUT NOCOPY VARCHAR2,
                       X_appraisal_id                    NUMBER,
                       X_asset_number                    VARCHAR2,
                       X_appraisal_value                 NUMBER,
                       X_status                          VARCHAR2,
                       X_LAST_UPDATE_DATE                DATE,
                       X_LAST_UPDATED_BY                 NUMBER,
                       X_CREATION_DATE                   DATE,
                       X_CREATED_BY                      NUMBER,
                       X_LAST_UPDATE_LOGIN               NUMBER,
                       X_ATTRIBUTE_CATEGORY              VARCHAR2,
                       X_ATTRIBUTE1                      VARCHAR2,
                       X_ATTRIBUTE2                      VARCHAR2,
                       X_ATTRIBUTE3                      VARCHAR2,
                       X_ATTRIBUTE4                      VARCHAR2,
                       X_ATTRIBUTE5                      VARCHAR2,
                       X_ATTRIBUTE6                      VARCHAR2,
                       X_ATTRIBUTE7                      VARCHAR2,
                       X_ATTRIBUTE8                      VARCHAR2,
                       X_ATTRIBUTE9                      VARCHAR2,
                       X_ATTRIBUTE10                     VARCHAR2,
                       X_ATTRIBUTE11                     VARCHAR2,
                       X_ATTRIBUTE12                     VARCHAR2,
                       X_ATTRIBUTE13                     VARCHAR2,
                       X_ATTRIBUTE14                     VARCHAR2,
                       X_ATTRIBUTE15                     VARCHAR2,
                       X_calling_sequence        IN  VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid
                FROM   jl_co_fa_asset_apprs
                WHERE  appraisal_id = X_appraisal_id;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

    BEGIN
--     Update the calling sequence
--
      current_calling_sequence := 'JL_CO_FA_ASSET_APPRS_PKG.INSERT_ROW<-' ||
                                   X_calling_sequence;
--
      debug_info := 'Insert into JL_CO_FA_ASSET_APPRS';
      insert into jl_co_fa_asset_apprs(
                                       appraisal_id,
                                       asset_number,
                                       appraisal_value,
                                       status,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       LAST_UPDATE_LOGIN,
                                       ATTRIBUTE_CATEGORY,
                                       ATTRIBUTE1,
                                       ATTRIBUTE2,
                                       ATTRIBUTE3,
                                       ATTRIBUTE4,
                                       ATTRIBUTE5,
                                       ATTRIBUTE6,
                                       ATTRIBUTE7,
                                       ATTRIBUTE8,
                                       ATTRIBUTE9,
                                       ATTRIBUTE10,
                                       ATTRIBUTE11,
                                       ATTRIBUTE12,
                                       ATTRIBUTE13,
                                       ATTRIBUTE14,
                                       ATTRIBUTE15)
       VALUES        (
                                       X_appraisal_id,
                                       X_asset_number,
                                       X_appraisal_value,
                                       X_status,
                                       X_LAST_UPDATE_DATE,
                                       X_LAST_UPDATED_BY,
                                       X_CREATION_DATE,
                                       X_CREATED_BY,
                                       X_LAST_UPDATE_LOGIN,
                                       X_ATTRIBUTE_CATEGORY,
                                       X_ATTRIBUTE1,
                                       X_ATTRIBUTE2,
                                       X_ATTRIBUTE3,
                                       X_ATTRIBUTE4,
                                       X_ATTRIBUTE5,
                                       X_ATTRIBUTE6,
                                       X_ATTRIBUTE7,
                                       X_ATTRIBUTE8,
                                       X_ATTRIBUTE9,
                                       X_ATTRIBUTE10,
                                       X_ATTRIBUTE11,
                                       X_ATTRIBUTE12,
                                       X_ATTRIBUTE13,
                                       X_ATTRIBUTE14,
                                       X_ATTRIBUTE15);

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'appraisal_id = ' || X_appraisal_id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row(  X_rowid                   VARCHAR2,

                       X_appraisal_id                    NUMBER,
                       X_asset_number                    VARCHAR2,
                       X_appraisal_value                 NUMBER,
                       X_status                          VARCHAR2,
                       X_LAST_UPDATE_DATE                DATE,
                       X_LAST_UPDATED_BY                 NUMBER,
                       X_CREATION_DATE                   DATE,
                       X_CREATED_BY                      NUMBER,
                       X_LAST_UPDATE_LOGIN               NUMBER,
                       X_ATTRIBUTE_CATEGORY              VARCHAR2,
                       X_ATTRIBUTE1                      VARCHAR2,
                       X_ATTRIBUTE2                      VARCHAR2,
                       X_ATTRIBUTE3                      VARCHAR2,
                       X_ATTRIBUTE4                      VARCHAR2,
                       X_ATTRIBUTE5                      VARCHAR2,
                       X_ATTRIBUTE6                      VARCHAR2,
                       X_ATTRIBUTE7                      VARCHAR2,
                       X_ATTRIBUTE8                      VARCHAR2,
                       X_ATTRIBUTE9                      VARCHAR2,
                       X_ATTRIBUTE10                     VARCHAR2,
                       X_ATTRIBUTE11                     VARCHAR2,
                       X_ATTRIBUTE12                     VARCHAR2,
                       X_ATTRIBUTE13                     VARCHAR2,
                       X_ATTRIBUTE14                     VARCHAR2,
                       X_ATTRIBUTE15                     VARCHAR2,
                       X_calling_sequence        IN    VARCHAR2
  ) IS
    CURSOR C IS SELECT *
                FROM   jl_co_fa_asset_apprs
                WHERE  appraisal_id = X_appraisal_id
                AND    asset_number = X_asset_number
                FOR UPDATE of appraisal_id, asset_number
                NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_CO_FA_ASSET_APPR_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND)
    THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;
    IF (Recinfo.appraisal_id = X_appraisal_id       AND
        Recinfo.asset_number = X_asset_number AND
	Recinfo.appraisal_value = X_appraisal_value AND
        Recinfo.status = X_status                  AND
	Recinfo.last_updated_by = X_last_updated_by AND
	Recinfo.last_update_date = X_last_update_date AND
	Recinfo.creation_date = X_creation_date AND
	Recinfo.created_by = X_created_by AND
	(Recinfo.last_update_login = X_last_update_login OR
           X_last_update_login IS NULL) AND
	(Recinfo.attribute1 = X_attribute1 OR
	   X_attribute1 IS NULL) AND
	(Recinfo.attribute2 = X_attribute2 OR
	   X_attribute2 IS NULL) AND
	(Recinfo.attribute3 = X_attribute3 OR
	   X_attribute3 IS NULL) AND
	(Recinfo.attribute4 = X_attribute4 OR
	   X_attribute4 IS NULL) AND
	(Recinfo.attribute5 = X_attribute5 OR
	   X_attribute5 IS NULL) AND
	(Recinfo.attribute6 = X_attribute6 OR
	   X_attribute6 IS NULL) AND
	(Recinfo.attribute7 = X_attribute7 OR
	   X_attribute7 IS NULL) AND
	(Recinfo.attribute8 = X_attribute8 OR
	   X_attribute8 IS NULL) AND
	(Recinfo.attribute9 = X_attribute9 OR
	   X_attribute9 IS NULL) AND
	(Recinfo.attribute10 = X_attribute10 OR
	   X_attribute10 IS NULL) AND
	(Recinfo.attribute11 = X_attribute11 OR
	   X_attribute11 IS NULL) AND
	(Recinfo.attribute12 = X_attribute12 OR
	   X_attribute12 IS NULL) AND
	(Recinfo.attribute13 = X_attribute13 OR
	   X_attribute13 IS NULL) AND
	(Recinfo.attribute14 = X_attribute14 OR
	   X_attribute14 IS NULL) AND
	(Recinfo.attribute15 = X_attribute15 OR
	   X_attribute15 IS NULL)
        )
    THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
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
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                        'appraisal_id = ' || X_appraisal_id);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row(X_rowid                   VARCHAR2,

                       X_appraisal_id                    NUMBER,
                       X_asset_number                    VARCHAR2,
                       X_appraisal_value                 NUMBER,
                       X_status                          VARCHAR2,
                       X_LAST_UPDATE_DATE                DATE,
                       X_LAST_UPDATED_BY                 NUMBER,
                       X_CREATION_DATE                   DATE,
                       X_CREATED_BY                      NUMBER,
                       X_LAST_UPDATE_LOGIN               NUMBER,
                       X_ATTRIBUTE_CATEGORY              VARCHAR2,
                       X_ATTRIBUTE1                      VARCHAR2,
                       X_ATTRIBUTE2                      VARCHAR2,
                       X_ATTRIBUTE3                      VARCHAR2,
                       X_ATTRIBUTE4                      VARCHAR2,
                       X_ATTRIBUTE5                      VARCHAR2,
                       X_ATTRIBUTE6                      VARCHAR2,
                       X_ATTRIBUTE7                      VARCHAR2,
                       X_ATTRIBUTE8                      VARCHAR2,
                       X_ATTRIBUTE9                      VARCHAR2,
                       X_ATTRIBUTE10                     VARCHAR2,
                       X_ATTRIBUTE11                     VARCHAR2,
                       X_ATTRIBUTE12                     VARCHAR2,
                       X_ATTRIBUTE13                     VARCHAR2,
                       X_ATTRIBUTE14                     VARCHAR2,
                       X_ATTRIBUTE15                     VARCHAR2,

                       X_calling_sequence        IN    VARCHAR2
  ) IS

  BEGIN
    UPDATE jl_co_fa_asset_apprs
    SET appraisal_id = X_appraisal_id,
        asset_number     = X_asset_number,
        appraisal_value = X_appraisal_value,
        status   = X_status,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY  = X_LAST_UPDATED_BY,
        CREATION_DATE    = X_CREATION_DATE,
        CREATED_BY       = X_CREATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
        ATTRIBUTE1  = X_ATTRIBUTE1,
        ATTRIBUTE2  = X_ATTRIBUTE2,
        ATTRIBUTE3  = X_ATTRIBUTE3,
        ATTRIBUTE4  = X_ATTRIBUTE4,
        ATTRIBUTE5  = X_ATTRIBUTE5,
        ATTRIBUTE6  = X_ATTRIBUTE6,
        ATTRIBUTE7  = X_ATTRIBUTE7,
        ATTRIBUTE8  = X_ATTRIBUTE8,
        ATTRIBUTE9  = X_ATTRIBUTE9,
        ATTRIBUTE10 = X_ATTRIBUTE10,
        ATTRIBUTE11 = X_ATTRIBUTE11,
        ATTRIBUTE12 = X_ATTRIBUTE12,
        ATTRIBUTE13 = X_ATTRIBUTE13,
        ATTRIBUTE14 = X_ATTRIBUTE14,
        ATTRIBUTE15 = X_ATTRIBUTE15
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row(  X_rowid                   VARCHAR2
  ) IS
  BEGIN
    DELETE
    FROM   jl_co_fa_asset_apprs
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

END JL_CO_FA_ASSET_APPRS_PKG;

/
