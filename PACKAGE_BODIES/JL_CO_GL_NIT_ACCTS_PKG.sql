--------------------------------------------------------
--  DDL for Package Body JL_CO_GL_NIT_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_GL_NIT_ACCTS_PKG" as
/* $Header: jlcoglab.pls 115.1 2002/03/01 16:54:21 pkm ship      $ */

  PROCEDURE Lock_Row(
                      X_rowid                   VARCHAR2,
                      X_chart_of_accounts_id    NUMBER,
                      X_flex_value_id           NUMBER,
                      X_account_code            VARCHAR2,
                      X_nit_required            VARCHAR2,
                      X_last_updated_by         NUMBER,
                      X_last_update_date        DATE,
                      X_last_update_login       NUMBER,
                      X_creation_date           DATE,
                      X_created_by              NUMBER,
                      X_attribute_category      VARCHAR2,
                      X_attribute1              VARCHAR2,
                      X_attribute2              VARCHAR2,
                      X_attribute3              VARCHAR2,
                      X_attribute4              VARCHAR2,
                      X_attribute5              VARCHAR2,
                      X_attribute6              VARCHAR2,
                      X_attribute7              VARCHAR2,
                      X_attribute8              VARCHAR2,
                      X_attribute9              VARCHAR2,
                      X_attribute10             VARCHAR2,
                      X_attribute11             VARCHAR2,
                      X_attribute12             VARCHAR2,
                      X_attribute13             VARCHAR2,
                      X_attribute14             VARCHAR2,
                      X_attribute15             VARCHAR2
  ) IS
    CURSOR C IS SELECT CHART_OF_ACCOUNTS_ID,
FLEX_VALUE_ID,
ACCOUNT_CODE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
LAST_UPDATE_LOGIN,
NIT_REQUIRED,
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
ATTRIBUTE15
                FROM   jl_co_gl_nit_accts
                WHERE  chart_of_accounts_id = X_chart_of_accounts_id
                AND    flex_value_id = X_flex_value_id
                FOR UPDATE of nit_required
                NOWAIT;

    Recinfo C%ROWTYPE;

    debug_info                  VARCHAR2(100);

  BEGIN
    debug_info := 'Open cursor C in LOCK_ROW';
    OPEN C;
    debug_info := 'Fetch cursor C in LOCK_ROW';
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
    IF (Recinfo.chart_of_accounts_id = X_chart_of_accounts_id AND
        Recinfo.flex_value_id = X_flex_value_id AND
        Recinfo.account_code = X_account_code AND
	Recinfo.creation_date = X_creation_date AND
        Recinfo.created_by = X_created_by AND
	Recinfo.last_updated_by = X_last_updated_by AND
	Recinfo.last_update_date = X_last_update_date AND
	(Recinfo.nit_required = X_nit_required OR
	   X_nit_required IS NULL) AND
	(Recinfo.last_update_login = X_last_update_login OR
	   X_last_update_login IS NULL) AND
	(Recinfo.creation_date = X_creation_date OR
	   X_creation_date IS NULL) AND
	(Recinfo.created_by = X_created_by OR
	   X_created_by IS NULL) AND
	(Recinfo.attribute_category =  X_attribute_Category OR
           X_attribute_Category IS NULL) AND
        (Recinfo.attribute1 =  X_attribute1 OR
           X_attribute1 IS NULL)  AND
        (Recinfo.attribute2 =  X_attribute2 OR
           X_attribute2 IS NULL)  AND
        (Recinfo.attribute3 =  X_attribute3 OR
           X_attribute3 IS NULL)  AND
        (Recinfo.attribute4 =  X_attribute4 OR
           X_attribute4 IS NULL)  AND
        (Recinfo.attribute5 =  X_attribute5 OR
           X_attribute5 IS NULL)  AND
        (Recinfo.attribute6 =  X_attribute6 OR
           X_attribute6 IS NULL)  AND
        (Recinfo.attribute7 =  X_attribute7 OR
           X_attribute7 IS NULL)  AND
        (Recinfo.attribute8 =  X_attribute8 OR
           X_attribute8 IS NULL)  AND
        (Recinfo.attribute9 =  X_attribute9 OR
           X_attribute9 IS NULL)  AND
        (Recinfo.attribute10 =  X_attribute10 OR
           X_attribute10 IS NULL) AND
	(Recinfo.attribute11 =  X_attribute11 OR
           X_attribute11 IS NULL) AND
        (Recinfo.attribute12 =  X_attribute12 OR
           X_attribute12 IS NULL) AND
        (Recinfo.attribute13 =  X_attribute13 OR
           X_attribute13 IS NULL) AND
        (Recinfo.attribute14 =  X_attribute14 OR
           X_attribute14 IS NULL) AND
	(Recinfo.attribute15 =  X_attribute15 OR
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
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',NULL);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',NULL);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row(
                      X_rowid                   VARCHAR2,
                      X_chart_of_accounts_id    NUMBER,
                      X_flex_value_id           NUMBER,
                      X_account_code            VARCHAR2,
                      X_nit_required            VARCHAR2,
                      X_last_updated_by         NUMBER,
                      X_last_update_date        DATE,
                      X_last_update_login       NUMBER,
                      X_creation_date           DATE,
                      X_created_by              NUMBER,
                      X_attribute_category      VARCHAR2,
                      X_attribute1              VARCHAR2,
                      X_attribute2              VARCHAR2,
                      X_attribute3              VARCHAR2,
                      X_attribute4              VARCHAR2,
                      X_attribute5              VARCHAR2,
                      X_attribute6              VARCHAR2,
                      X_attribute7              VARCHAR2,
                      X_attribute8              VARCHAR2,
                      X_attribute9              VARCHAR2,
                      X_attribute10             VARCHAR2,
                      X_attribute11             VARCHAR2,
                      X_attribute12             VARCHAR2,
                      X_attribute13             VARCHAR2,
                      X_attribute14             VARCHAR2,
                      X_attribute15             VARCHAR2
  ) IS

  BEGIN
    UPDATE jl_co_gl_nit_accts
    SET    chart_of_accounts_id   = X_chart_of_accounts_id,
           flex_value_id          = X_flex_value_id,
           account_code           = X_account_code,
           nit_required           = X_nit_required,
           last_updated_by        = X_last_updated_by,
           last_update_date       = X_last_update_date,
           last_update_login      = X_last_update_login,
           creation_date          = X_creation_date,
           created_by             = X_created_by,
	   attribute_category	  = X_attribute_category,
           attribute1      	  = X_attribute1,
           attribute2         	  = X_attribute2,
           attribute3         	  = X_attribute3,
           attribute4         	  = X_attribute4,
           attribute5         	  = X_attribute5,
           attribute6         	  = X_attribute6,
           attribute7         	  = X_attribute7,
           attribute8             = X_attribute8,
           attribute9         	  = X_attribute9,
           attribute10        	  = X_attribute10,
           attribute11        	  = X_attribute11,
           attribute12        	  = X_attribute12,
           attribute13        	  = X_attribute13,
           attribute14        	  = X_attribute14,
           attribute15        	  = X_attribute15

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
    FROM   jl_co_gl_nit_accts
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

END JL_CO_GL_NIT_ACCTS_PKG;

/
