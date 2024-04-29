--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_ATT_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_ATT_VAL_PKG" as
/* $Header: jlzztavb.pls 120.2 2003/03/03 19:30:55 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid                 IN OUT NOCOPY VARCHAR2,
        X_tax_categ_attr_val_id               NUMBER,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_tax_attr_value_code                 VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_last_update_date                    DATE,
        X_last_updated_by                     NUMBER,
        X_creation_date                       DATE,
        X_created_by                          NUMBER,
        X_last_update_login                   NUMBER,
        X_attribute_category                  VARCHAR2,
        X_attribute1                          VARCHAR2,
        X_attribute2                          VARCHAR2,
        X_attribute3                          VARCHAR2,
        X_attribute4                          VARCHAR2,
        X_attribute5                          VARCHAR2,
        X_attribute6                          VARCHAR2,
        X_attribute7                          VARCHAR2,
        X_attribute8                          VARCHAR2,
        X_attribute9                          VARCHAR2,
        X_attribute10                         VARCHAR2,
        X_attribute11                         VARCHAR2,
        X_attribute12                         VARCHAR2,
        X_attribute13                         VARCHAR2,
        X_attribute14                         VARCHAR2,
        X_attribute15                         VARCHAR2,
        X_calling_sequence        IN          VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM   jl_zz_ar_tx_att_val
      WHERE  tax_categ_attr_val_id = X_tax_categ_attr_val_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --     Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_ATT_VAL_PKG.INSERT_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Insert into JL_ZZ_AR_TX_ATT_VAL';
    insert into jl_zz_ar_tx_att_val(tax_categ_attr_val_id,
                                    tax_category_id,
                                    tax_attribute_type,
                                    tax_attribute_name,
                                    tax_attribute_value,
                                    tax_attr_value_code,
                                    default_to_class,
                                    org_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    last_update_login,
                                    attribute_category,
                                    attribute1,
                                    attribute2,
                                    attribute3,
                                    attribute4,
                                    attribute5,
                                    attribute6,
                                    attribute7,
                                    attribute8,
                                    attribute9,
                                    attribute10,
                                    attribute11,
                                    attribute12,
                                    attribute13,
                                    attribute14,
                                    attribute15)
                            VALUES (X_tax_categ_attr_val_id,
                                    X_tax_category_id,
                                    X_tax_attribute_type,
                                    X_tax_attribute_name,
                                    X_tax_attribute_value,
                                    X_tax_attr_value_code,
                                    X_default_to_class,
                                    X_org_id,
                                    X_last_update_date,
                                    X_last_updated_by,
                                    X_creation_date,
                                    X_created_by,
                                    X_last_update_login,
                                    X_attribute_category,
                                    X_attribute1,
                                    X_attribute2,
                                    X_attribute3,
                                    X_attribute4,
                                    X_attribute5,
                                    X_attribute6,
                                    X_attribute7,
                                    X_attribute8,
                                    X_attribute9,
                                    X_attribute10,
                                    X_attribute11,
                                    X_attribute12,
                                    X_attribute13,
                                    X_attribute14,
                                    X_attribute15);

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
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              'tax_categ_attr_val_id = ' || X_tax_categ_attr_val_id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Insert_Row;

  PROCEDURE Lock_Row
       (X_rowid                               VARCHAR2,
        X_tax_categ_attr_val_id               NUMBER,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_tax_attr_value_code                 VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_last_update_date                    DATE,
        X_last_updated_by                     NUMBER,
        X_creation_date                       DATE,
        X_created_by                          NUMBER,
        X_last_update_login                   NUMBER,
        X_attribute_category                  VARCHAR2,
        X_attribute1                          VARCHAR2,
        X_attribute2                          VARCHAR2,
        X_attribute3                          VARCHAR2,
        X_attribute4                          VARCHAR2,
        X_attribute5                          VARCHAR2,
        X_attribute6                          VARCHAR2,
        X_attribute7                          VARCHAR2,
        X_attribute8                          VARCHAR2,
        X_attribute9                          VARCHAR2,
        X_attribute10                         VARCHAR2,
        X_attribute11                         VARCHAR2,
        X_attribute12                         VARCHAR2,
        X_attribute13                         VARCHAR2,
        X_attribute14                         VARCHAR2,
        X_attribute15                         VARCHAR2,
        X_calling_sequence        IN          VARCHAR2) IS

    CURSOR C IS
      SELECT TAX_CATEG_ATTR_VAL_ID,
             TAX_CATEGORY_ID,
             TAX_ATTRIBUTE_TYPE,
             TAX_ATTRIBUTE_NAME,
             TAX_ATTRIBUTE_VALUE,
             TAX_ATTR_VALUE_CODE,
             DEFAULT_TO_CLASS,
             ORG_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
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
        FROM jl_zz_ar_tx_att_val
        WHERE  tax_categ_attr_val_id = X_tax_categ_attr_val_id
        FOR UPDATE of tax_categ_attr_val_id
        NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_ATT_VAL_PKG.LOCK_ROW<-' ||
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
    IF ((Recinfo.tax_categ_attr_val_id = X_tax_categ_attr_val_id) AND
        (Recinfo.tax_category_id       = X_tax_category_id) AND
        (Recinfo.tax_attribute_type    = X_tax_attribute_type) AND
        (Recinfo.tax_attribute_name    = X_tax_attribute_name) AND
        (Recinfo.tax_attribute_value   = X_tax_attribute_value) AND
        ((Recinfo.tax_attr_value_code  = X_tax_attr_value_code) OR
           ((Recinfo.tax_attr_value_code IS NULL) AND
             (X_tax_attr_value_code IS NULL))) AND
        (Recinfo.default_to_class = X_default_to_class) AND
        ((Recinfo.org_id = X_org_id) OR
         ((Recinfo.org_id IS NULL) AND
          (X_org_id IS NULL))) AND
        (Recinfo.last_updated_by     = X_last_updated_by) AND
        (Recinfo.last_update_date    = X_last_update_date) AND
        ((Recinfo.created_by         = X_created_by) OR
         ((Recinfo.created_by IS NULL) AND
          (X_created_by IS NULL))) AND
        ((Recinfo.creation_date     = X_creation_date) OR
         ((Recinfo.creation_date IS NULL)  AND
          (X_creation_date IS NULL))) AND
        ((Recinfo.last_update_login = X_last_update_login) OR
         ((Recinfo.last_update_login IS NULL) AND
          (X_last_update_login IS NULL))) AND
        ((Recinfo.attribute_category =  X_attribute_Category) OR
         ((Recinfo.attribute_category IS NULL) AND
          (X_attribute_category IS NULL))) AND
        ((Recinfo.attribute1 = X_attribute1) OR
         ((Recinfo.attribute1 IS NULL) AND
          (X_attribute1 IS NULL))) AND
        ((Recinfo.attribute2 = X_attribute2) OR
         ((Recinfo.attribute2 IS NULL) AND
          (X_attribute2 IS NULL))) AND
        ((Recinfo.attribute3 = X_attribute3) OR
         ((Recinfo.attribute3 IS NULL)  AND
          (X_attribute3 IS NULL))) AND
        ((Recinfo.attribute4 = X_attribute4) OR
         ((Recinfo.attribute4 IS NULL)  AND
          (X_attribute4 IS NULL))) AND
        ((Recinfo.attribute5 = X_attribute5) OR
         ((Recinfo.attribute5 IS NULL)  AND
          (X_attribute5 IS NULL))) AND
        ((Recinfo.attribute6 = X_attribute6) OR
         ((Recinfo.attribute6 IS NULL) AND
          (X_attribute6 IS NULL))) AND
        ((Recinfo.attribute7 = X_attribute7) OR
         ((Recinfo.attribute7 IS NULL) AND
          (X_attribute7 IS NULL))) AND
        ((Recinfo.attribute8 = X_attribute8) OR
         ((Recinfo.attribute8 IS NULL) AND
          (X_attribute8 IS NULL))) AND
        ((Recinfo.attribute9 = X_attribute9) OR
         ((Recinfo.attribute9 IS NULL) AND
          (X_attribute9 IS NULL))) AND
        ((Recinfo.attribute10 = X_attribute10) OR
         ((Recinfo.attribute10 IS NULL) AND
          (X_attribute10 IS NULL))) AND
        ((Recinfo.attribute11 = X_attribute11) OR
         ((Recinfo.attribute11 IS NULL) AND
          (X_attribute11 IS NULL))) AND
        ((Recinfo.attribute12 = X_attribute12) OR
         ((Recinfo.attribute12 IS NULL) AND
          (X_attribute12 IS NULL))) AND
        ((Recinfo.attribute13 = X_attribute13) OR
         ((Recinfo.attribute13 IS NULL) AND
          (X_attribute13 IS NULL))) AND
        ((Recinfo.attribute14 = X_attribute14) OR
         ((Recinfo.attribute14 IS NULL) AND
          (X_attribute14 IS NULL))) AND
        ((Recinfo.attribute15 = X_attribute15) OR
         ((Recinfo.attribute15 IS NULL) AND
          (X_attribute15 IS NULL)))) THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('AR','AR_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'tax_categ_attr_val_id = ' ||X_tax_categ_attr_val_id);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row
       (X_rowid                               VARCHAR2,
        X_tax_categ_attr_val_id               NUMBER,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_tax_attr_value_code                 VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_last_update_date                    DATE,
        X_last_updated_by                     NUMBER,
        X_creation_date                       DATE,
        X_created_by                          NUMBER,
        X_last_update_login                   NUMBER,
        X_attribute_category                  VARCHAR2,
        X_attribute1                          VARCHAR2,
        X_attribute2                          VARCHAR2,
        X_attribute3                          VARCHAR2,
        X_attribute4                          VARCHAR2,
        X_attribute5                          VARCHAR2,
        X_attribute6                          VARCHAR2,
        X_attribute7                          VARCHAR2,
        X_attribute8                          VARCHAR2,
        X_attribute9                          VARCHAR2,
        X_attribute10                         VARCHAR2,
        X_attribute11                         VARCHAR2,
        X_attribute12                         VARCHAR2,
        X_attribute13                         VARCHAR2,
        X_attribute14                         VARCHAR2,
        X_attribute15                         VARCHAR2,
        X_calling_sequence        IN          VARCHAR2) IS

  BEGIN
    UPDATE jl_zz_ar_tx_att_val
    SET tax_categ_attr_val_id  = X_tax_categ_attr_val_id,
        tax_category_id        = X_tax_category_id,
        tax_attribute_type     = X_tax_attribute_type,
        tax_attribute_name     = X_tax_attribute_name,
        tax_attribute_value    = X_tax_attribute_value,
        tax_attr_value_code    = X_tax_attr_value_code,
        default_to_class       = X_default_to_class,
        org_id                 = X_org_id,
        last_update_date       = X_last_update_date,
        last_updated_by        = X_last_updated_by,
        creation_date          = X_creation_date,
        created_by             = X_created_by,
        last_update_login      = X_last_update_login,
        attribute_category     = X_attribute_category,
        attribute1             = X_attribute1,
        attribute2             = X_attribute2,
        attribute3             = X_attribute3,
        attribute4             = X_attribute4,
        attribute5             = X_attribute5,
        attribute6             = X_attribute6,
        attribute7             = X_attribute7,
        attribute8             = X_attribute8,
        attribute9             = X_attribute9,
        attribute10            = X_attribute10,
        attribute11            = X_attribute11,
        attribute12            = X_attribute12,
        attribute13            = X_attribute13,
        attribute14            = X_attribute14,
        attribute15            = X_attribute15
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (X_rowid                               VARCHAR2) IS
  BEGIN
    DELETE FROM jl_zz_ar_tx_att_val
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

  PROCEDURE Check_Unique
       (X_rowid                               VARCHAR2,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_org_id                              NUMBER,
        X_calling_sequence        IN          VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence :='JL_ZZ_AR_TX_ATT_VAL_PKG.CHECK_UNIQUE<-' ||
                               X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_att_val
    WHERE tax_category_id   = X_tax_category_id
    AND tax_attribute_type  = X_tax_attribute_type
    AND tax_attribute_name  = X_tax_attribute_name
    AND tax_attribute_value = X_tax_attribute_value
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid))
    AND org_id = X_org_id;

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_category_id = '     || X_tax_category_id ||
                            ' tax_attribute_type = '  ||  X_tax_attribute_type ||
                            ' tax_attribute_name = '  || X_tax_attribute_name ||
                            ' tax_attribute_value = ' || X_tax_attribute_value||
                            ' org_id = '              || X_org_id);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Unique;

  PROCEDURE Check_Default_To_Class
       (X_rowid                               VARCHAR2,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_calling_sequence        IN          VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_ATT_VAL_PKG.CHECK_DEFAULT_TO_CLASS<-' ||
                                X_calling_sequence;

    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_att_val
    WHERE tax_category_id = X_tax_category_id
    AND tax_attribute_type = X_tax_attribute_type
    AND tax_attribute_name = X_tax_attribute_name
    AND default_to_class = X_default_to_class
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid))
    AND org_id = X_org_id;

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_category_id = '    || X_tax_category_id ||
                            ' tax_attribute_type = ' || X_tax_attribute_type ||
                            ' tax_attribute_name = ' || X_tax_attribute_name ||
                            ' defautl_to_class = '   || X_default_to_class||
                            ' org_id = '             || X_org_id);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Default_To_Class;

END JL_ZZ_AR_TX_ATT_VAL_PKG;

/
