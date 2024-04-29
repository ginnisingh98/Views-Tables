--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_CUS_CLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_CUS_CLS_PKG" AS
/* $Header: jlzztacb.pls 120.2 2003/03/03 19:32:04 opedrega ship $ */


  PROCEDURE Populate_Cus_Cls_Rows
       (X_address_id                        NUMBER,
        X_class_code                        VARCHAR2,
        X_org_id                            NUMBER) IS
  BEGIN
    Insert into JL_ZZ_AR_TX_CUS_CLS(cus_class_id,
                                    address_id,
                                    tax_attr_class_code,
                                    tax_category_id,
                                    tax_attribute_name,
                                    tax_attribute_value,
                                    enabled_flag,
                                    org_id,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login,
                                    creation_date,
                                    created_by)
                             SELECT JL_ZZ_AR_TX_CUS_CLS_S.nextval,
                                    X_address_id,
                                    X_class_code,
                                    tax_category_id,
                                    tax_attribute_name,
                                    tax_attribute_value,
                                    'Y',
                                    X_org_id,
                                    SYSDATE,
                                    TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
                                    TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                    SYSDATE,
                                    TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                             FROM JL_ZZ_AR_TX_ATT_CLS
                             WHERE tax_attr_class_type = 'CONTRIBUTOR_CLASS'
                             AND tax_attribute_type =  'CONTRIBUTOR_ATTRIBUTE'
                             AND tax_attr_class_code = X_class_code
                             AND org_id = X_org_id;
                            --commit;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      NULL;
  END Populate_Cus_Cls_Rows;

  PROCEDURE Insert_Row
       (X_rowid               IN OUT NOCOPY VARCHAR2,
        X_cus_class_id                      NUMBER,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_tax_attribute_value               VARCHAR2,
        X_enabled_flag                      VARCHAR2,
        X_org_id                            NUMBER,
        X_last_updated_by                   NUMBER,
        X_last_update_date                  DATE,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_calling_sequence    IN            VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM JL_ZZ_AR_TX_CUS_CLS
      WHERE tax_attr_class_code = X_tax_attr_class_code
      AND tax_category_id = X_tax_category_id
      AND tax_attribute_name = X_tax_attribute_name
      AND org_id = X_org_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN

    -- Update the calling sequence

    current_calling_sequence := 'JL_ZZ_AR_TX_CUS_CLS_PKG.INSERT_ROW<-' ||
                                X_calling_sequence;

    debug_info := 'Insert into JL_ZZ_AR_TX_CUS_CLS  ';

    INSERT INTO JL_ZZ_AR_TX_CUS_CLS(cus_class_id,
                                    address_id,
                                    tax_attr_class_code,
                                    tax_category_id,
                                    tax_attribute_name,
                                    tax_attribute_value,
                                    enabled_flag,
                                    org_id,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login,
                                    creation_date,
                                    created_by)
                             VALUES(X_cus_class_id,
                                    X_address_id,
                                    X_tax_attr_class_code,
                                    X_tax_category_id,
                                    X_tax_attribute_name,
                                    X_tax_attribute_value,
                                    X_enabled_flag,
                                    X_org_id,
                                    X_last_updated_by,
                                    X_last_update_date,
                                    X_last_update_login,
                                    X_creation_date,
                                    X_created_by);

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_rowid;
    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              ' tax_attr_class_code = ' || X_tax_attr_class_code ||
                              ' tax_category_id = '     || X_tax_category_id     ||
                              ' tax_attribute_name = '  || X_tax_attribute_name );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Insert_Row;

  PROCEDURE Update_Row
       (X_rowid                             VARCHAR2,
        X_cus_class_id                      NUMBER,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_tax_attribute_value               VARCHAR2,
        X_enabled_flag                      VARCHAR2,
        X_org_id                            NUMBER,
        X_last_updated_by                   NUMBER,
        X_last_update_date                  DATE,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_calling_sequence    IN            VARCHAR2) IS

  BEGIN
    UPDATE JL_ZZ_AR_TX_CUS_CLS
      SET cus_class_id           = X_cus_class_id,
          address_id             = X_address_id,
          tax_attr_class_code    = X_tax_attr_class_code,
          tax_category_id        = X_tax_category_id,
          tax_attribute_name     = X_tax_attribute_name,
          tax_attribute_value    = X_tax_attribute_value,
          enabled_flag           = X_enabled_flag,
          org_id                 = X_org_id,
          last_updated_by        = X_last_updated_by,
          last_update_date       = X_last_update_date,
          last_update_login      = X_last_update_login,
          creation_date          = X_creation_date,
          created_by             = X_created_by
    WHERE rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
        raise NO_DATA_FOUND;
    END IF;

  END Update_Row;

  PROCEDURE Delete_Row
       (x_Rowid                   VARCHAR2) IS

  BEGIN

    DELETE
    FROM JL_ZZ_AR_TX_CUS_CLS
    WHERE rowid = X_rowid;

      IF (SQL%NOTFOUND) THEN
        raise NO_DATA_FOUND;
      END IF;

  END Delete_Row;

  PROCEDURE Lock_Row
       (X_rowid                             VARCHAR2,
        X_cus_class_id                      NUMBER,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_tax_attribute_value               VARCHAR2,
        X_enabled_flag                      VARCHAR2,
        X_org_id                            NUMBER,
        X_last_updated_by                   NUMBER,
        X_last_update_date                  DATE,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_calling_sequence    IN            VARCHAR2) IS

    CURSOR C IS
      SELECT CUS_CLASS_ID,
             ADDRESS_ID,
             TAX_ATTR_CLASS_CODE,
             TAX_CATEGORY_ID,
             TAX_ATTRIBUTE_NAME,
             TAX_ATTRIBUTE_VALUE,
             ENABLED_FLAG,
             ORG_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY
      FROM JL_ZZ_AR_TX_CUS_CLS
      WHERE cus_class_id = X_cus_class_id
      FOR UPDATE of tax_attr_class_code,
                    tax_category_id,
                    tax_attribute_name,
                    ORG_ID
      NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN

    current_calling_sequence := 'JL_ZZ_AR_TX_CUS_CLS_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    debug_info := 'Close cursor C';
    CLOSE C;
    IF ((Recinfo.cus_class_id        = X_cus_class_id) AND
        (Recinfo.tax_attr_class_code = X_tax_attr_class_code) AND
        (Recinfo.tax_category_id     = X_tax_category_id) AND
        (Recinfo.tax_attribute_name  = X_tax_attribute_name) AND
        (Recinfo.tax_attribute_value = X_tax_attribute_value) AND
        (Recinfo.enabled_flag        = X_enabled_flag) AND
        ((Recinfo.org_id = X_org_id) OR
         ((Recinfo.org_id IS NULL) AND
          (X_org_id IS NULL))) AND
        (Recinfo.last_updated_by     = X_last_updated_by) AND
        (Recinfo.last_update_date    = X_last_update_date) AND
        ((Recinfo.last_update_login  = X_last_update_login) OR
         ((Recinfo.last_update_login IS NULL) AND
          (X_last_update_login IS NULL))) AND
        ((Recinfo.creation_date = X_creation_date) OR
         ((Recinfo.creation_date IS NULL) AND
          (X_creation_date IS NULL))) AND
        ((Recinfo.created_by = X_created_by) OR
         ((Recinfo.created_by IS NULL) AND
          (X_created_by IS NULL)))) THEN
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
                                ' tax_attr_class_code = ' || X_tax_attr_class_code ||
                                ' tax_category_id = '     || X_tax_category_id     ||
                                ' tax_attribute_name = '  || X_tax_attribute_name );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Check_Unique
       (X_rowid                             VARCHAR2,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_org_id                            NUMBER,
        X_calling_sequence    IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_CUS_CLS_PKG.CHECK_UNIQUE<-' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM JL_ZZ_AR_TX_CUS_CLS
    WHERE address_id        = X_address_id
    AND tax_attr_class_code = X_tax_attr_class_code
    AND tax_category_id     = X_tax_category_id
    AND tax_attribute_name  = X_tax_attribute_name
    AND org_id              = X_org_id
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_attr_class_code = ' || X_tax_attr_class_code ||
                            ' tax_category_id = '     || X_tax_category_id     ||
                            ' tax_attribute_name = '  || X_tax_attribute_name  );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Unique;

END JL_ZZ_AR_TX_CUS_CLS_PKG;

/
