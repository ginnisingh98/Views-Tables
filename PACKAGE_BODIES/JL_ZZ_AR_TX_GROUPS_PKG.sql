--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_GROUPS_PKG" AS
/* $Header: jlzzttgb.pls 120.5 2005/03/31 23:34:33 nipatel ship $ */

  PROCEDURE Insert_Row
       (X_rowid                    IN OUT NOCOPY VARCHAR2,
        X_group_tax_id                           NUMBER,
        X_tax_category_id                        NUMBER,
        X_tax_group_record_id                    NUMBER,
        X_establishment_type                     VARCHAR2,
        X_contributor_type                       VARCHAR2,
        X_transaction_nature                     VARCHAR2,
        X_end_date_active                        DATE,
        X_use_tx_categ_thresholds                VARCHAR2,
        X_last_update_date                       DATE,
        X_last_updated_by                        NUMBER,
        X_compound_precedence                    NUMBER,
        X_min_amount                             NUMBER,
        X_min_taxable_basis                      NUMBER,
        X_min_percentage                         NUMBER,
        X_tax_inclusive                          VARCHAR2,
        X_tributary_substitution                 VARCHAR2,
        X_used_to_reduce                         VARCHAR2,
        X_tax_code                               VARCHAR2,
        X_base_rate                              NUMBER,
        X_start_date_active                      DATE,
        X_org_id                                 NUMBER,
        X_last_update_login                      NUMBER,
        X_creation_date                          DATE,
        X_created_by                             NUMBER,
        X_tax_category_to_reduce_id              NUMBER,
        X_calculate_in_oe                        VARCHAR2,
        X_attribute_category                     VARCHAR2,
        X_attribute1                             VARCHAR2,
        X_attribute2                             VARCHAR2,
        X_attribute3                             VARCHAR2,
        X_attribute4                             VARCHAR2,
        X_attribute5                             VARCHAR2,
        X_attribute6                             VARCHAR2,
        X_attribute7                             VARCHAR2,
        X_attribute8                             VARCHAR2,
        X_attribute9                             VARCHAR2,
        X_attribute10                            VARCHAR2,
        X_attribute11                            VARCHAR2,
        X_attribute12                            VARCHAR2,
        X_attribute13                            VARCHAR2,
        X_attribute14                            VARCHAR2,
        X_attribute15                            VARCHAR2,
        X_calling_sequence         IN            VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM JL_ZZ_AR_TX_GROUPS
      WHERE group_tax_id      = X_group_tax_id
      AND tax_category_id     = X_tax_category_id
      AND tax_group_record_id = X_tax_group_record_id
      AND transaction_nature  = X_transaction_nature
      AND contributor_type    = X_contributor_type
      AND establishment_type  = X_establishment_type
      AND end_date_active     = X_end_date_active
      AND org_id              = X_org_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --     Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.INSERT_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Insert into JL_ZZ_AR_TX_GROUPS  ';
    INSERT INTO JL_ZZ_AR_TX_GROUPS (group_tax_id,
                                    tax_category_id,
                                    tax_group_record_id,
                                    establishment_type,
                                    contributor_type,
                                    transaction_nature,
                                    end_date_active,
                                    use_tx_categ_thresholds,
                                    last_update_date,
                                    last_updated_by,
                                    compound_precedence,
                                    min_amount,
                                    min_taxable_basis,
                                    min_percentage,
                                    tax_inclusive,
                                    tributary_substitution,
                                    used_to_reduce,
                                    tax_code,
                                    base_rate,
                                    start_date_active,
                                    org_id,
                                    last_update_login,
                                    creation_date,
                                    created_by,
                                    tax_category_to_reduce_id,
                                    calculate_in_oe,
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
                            VALUES (X_group_tax_id,
                                    X_tax_category_id,
                                    X_tax_group_record_id,
                                    X_establishment_type,
                                    X_contributor_type,
                                    X_transaction_nature,
                                    X_end_date_active,
                                    X_use_tx_categ_thresholds,
                                    X_last_update_date,
                                    X_last_updated_by,
                                    X_compound_precedence,
                                    X_min_amount,
                                    X_min_taxable_basis,
                                    X_min_percentage,
                                    X_tax_inclusive,
                                    X_tributary_substitution,
                                    X_used_to_reduce,
                                    X_tax_code,
                                    X_base_rate,
                                    NVL(X_start_date_active,TO_DATE('01/01/1000', 'DD/MM/YYYY')),
                                    x_org_id,
                                    X_last_update_login,
                                    X_creation_date,
                                    X_created_by,
                                    X_tax_category_to_reduce_id,
                                    X_calculate_in_oe,
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
                              ' group_tax_id = '|| X_group_tax_id ||
                              ' tax_category_id = ' || X_tax_category_id ||
                              ' end_date_active = ' || to_char(X_end_date_active,'YYYY/MM/DD') );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Insert_Row;

  PROCEDURE Lock_Row
       (X_rowid                                  VARCHAR2,
        X_group_tax_id                           NUMBER,
        X_tax_category_id                        NUMBER,
        X_tax_group_record_id                    NUMBER,
        X_establishment_type                     VARCHAR2,
        X_contributor_type                       VARCHAR2,
        X_transaction_nature                     VARCHAR2,
        X_end_date_active                        DATE,
        X_use_tx_categ_thresholds                VARCHAR2,
        X_last_update_date                       DATE,
        X_last_updated_by                        NUMBER,
        X_compound_precedence                    NUMBER,
        X_min_amount                             NUMBER,
        X_min_taxable_basis                      NUMBER,
        X_min_percentage                         NUMBER,
        X_tax_inclusive                          VARCHAR2,
        X_tributary_substitution                 VARCHAR2,
        X_used_to_reduce                         VARCHAR2,
        X_tax_code                               VARCHAR2,
        X_base_rate                              NUMBER,
        X_start_date_active                      DATE,
        X_org_id                                 NUMBER,
        X_last_update_login                      NUMBER,
        X_creation_date                          DATE,
        X_created_by                             NUMBER,
        X_tax_category_to_reduce_id              NUMBER,
        X_calculate_in_oe                        VARCHAR2,
        X_attribute_category                     VARCHAR2,
        X_attribute1                             VARCHAR2,
        X_attribute2                             VARCHAR2,
        X_attribute3                             VARCHAR2,
        X_attribute4                             VARCHAR2,
        X_attribute5                             VARCHAR2,
        X_attribute6                             VARCHAR2,
        X_attribute7                             VARCHAR2,
        X_attribute8                             VARCHAR2,
        X_attribute9                             VARCHAR2,
        X_attribute10                            VARCHAR2,
        X_attribute11                            VARCHAR2,
        X_attribute12                            VARCHAR2,
        X_attribute13                            VARCHAR2,
        X_attribute14                            VARCHAR2,
        X_attribute15                            VARCHAR2,
        X_calling_sequence         IN            VARCHAR2) IS

    CURSOR C IS
      SELECT GROUP_TAX_ID,
             TAX_GROUP_RECORD_ID,
             TAX_CATEGORY_ID,
             ESTABLISHMENT_TYPE,
             CONTRIBUTOR_TYPE,
             TRANSACTION_NATURE,
             END_DATE_ACTIVE,
             USE_TX_CATEG_THRESHOLDS,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             COMPOUND_PRECEDENCE,
             MIN_AMOUNT,
             MIN_TAXABLE_BASIS,
             MIN_PERCENTAGE,
             TAX_INCLUSIVE,
             TRIBUTARY_SUBSTITUTION,
             USED_TO_REDUCE,
             TAX_CODE,
             START_DATE_ACTIVE,
             ORG_ID,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             TAX_CATEGORY_TO_REDUCE_ID,
             CALCULATE_IN_OE,
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
             ATTRIBUTE15,
             BASE_RATE
      FROM JL_ZZ_AR_TX_GROUPS
      WHERE rowid = X_rowid
      FOR UPDATE OF group_tax_id
      NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.LOCK_ROW<-' ||
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

    IF ((Recinfo.group_tax_id = X_group_tax_id) AND
        (Recinfo.tax_category_id = X_tax_category_id) AND
        ((Recinfo.tax_group_record_id = X_tax_group_record_id) OR
         ((Recinfo.tax_group_record_id IS NULL) AND
          (X_tax_group_record_id IS NULL))) AND
        (Recinfo.establishment_type = X_establishment_type) AND
        (Recinfo.contributor_type = X_contributor_type) AND
        (Recinfo.transaction_nature = X_transaction_nature) AND
        (Recinfo.end_date_active = X_end_date_active) AND
        (Recinfo.use_tx_categ_thresholds = X_use_tx_categ_thresholds) AND
        (Recinfo.last_update_date  = X_last_update_date) AND
        (Recinfo.last_updated_by   = X_last_updated_by) AND
        ((Recinfo.compound_precedence  = X_compound_precedence) OR
         ((Recinfo.compound_precedence IS NULL) AND
          (X_compound_precedence IS NULL))) AND
        ((Recinfo.min_amount  = X_min_amount) OR
         ((Recinfo.min_amount IS NULL) AND
          (X_min_amount IS NULL))) AND
        ((Recinfo.min_taxable_basis = X_min_taxable_basis) OR
         ((Recinfo.min_taxable_basis IS NULL) AND
          (X_min_taxable_basis IS NULL))) AND
        ((Recinfo.min_percentage   = X_min_percentage) OR
         ((Recinfo.min_percentage IS NULL) AND
          (X_min_percentage IS NULL))) AND
        ((Recinfo.tax_inclusive       = X_tax_inclusive) OR
         ((Recinfo.tax_inclusive IS NULL) AND
          (X_tax_inclusive IS NULL ))) AND
        ((Recinfo.tributary_substitution = X_tributary_substitution) OR
         ((Recinfo.tributary_substitution IS NULL) AND
          (X_tributary_substitution IS NULL))) AND
        ((Recinfo.used_to_reduce  = X_used_to_reduce) OR
         ((Recinfo.used_to_reduce IS NULL) AND
          (X_used_to_reduce IS NULL))) AND
        ((Recinfo.tax_code = X_tax_code) OR
         ((Recinfo.tax_code IS NULL) AND
          (X_tax_code IS NULL))) AND
        ((Recinfo.base_rate = X_base_rate) OR
         ((Recinfo.base_rate IS NULL) AND
          (X_base_rate IS NULL))) AND
        ((Recinfo.start_date_active = X_start_date_active) OR
         ((Recinfo.start_date_active IS NULL) AND
          (X_start_date_active IS NULL))) AND
        ((Recinfo.org_id =  X_org_id) OR
         ((Recinfo.org_id IS NULL) AND
          (X_org_id IS NULL))) AND
        ((Recinfo.last_update_login = X_last_update_login) OR
         ((Recinfo.last_update_login IS NULL) AND
          (X_last_update_login IS NULL))) AND
        ((Recinfo.creation_date = X_creation_date) OR
         ((Recinfo.creation_date IS NULL) AND
          (X_creation_date IS NULL))) AND
        ((Recinfo.created_by = X_created_by) OR
         ((Recinfo.created_by IS NULL) AND
          (X_created_by IS NULL))) AND
        ((Recinfo.tax_category_to_reduce_id = X_tax_category_to_reduce_id) OR
         ((Recinfo.tax_category_to_reduce_id IS NULL) AND
          (X_tax_category_to_reduce_id IS NULL))) AND
        ((Recinfo.calculate_in_oe = X_calculate_in_oe) OR
         ((Recinfo.calculate_in_oe IS NULL) AND
          (X_calculate_in_oe IS NULL))) AND
        ((Recinfo.attribute_category =  X_attribute_Category) OR
         ((Recinfo.attribute_category IS NULL) AND
          (X_attribute_Category IS NULL))) AND
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
                                ' group_tax_id = '|| X_group_tax_id ||
                                ' tax_category_id = ' || X_tax_category_id ||
                                ' end_date_active = ' || to_char(X_end_date_active,'YYYY/MM/DD') );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE UpDate_Row
       (X_rowid                                  VARCHAR2,
        X_group_tax_id                           NUMBER,
        X_tax_category_id                        NUMBER,
        X_tax_group_record_id                    NUMBER,
        X_establishment_type                     VARCHAR2,
        X_contributor_type                       VARCHAR2,
        X_transaction_nature                     VARCHAR2,
        X_end_date_active                        DATE,
        X_use_tx_categ_thresholds                VARCHAR2,
        X_last_update_date                       DATE,
        X_last_updated_by                        NUMBER,
        X_compound_precedence                    NUMBER,
        X_min_amount                             NUMBER,
        X_min_taxable_basis                      NUMBER,
        X_min_percentage                         NUMBER,
        X_tax_inclusive                          VARCHAR2,
        X_tributary_substitution                 VARCHAR2,
        X_used_to_reduce                         VARCHAR2,
        X_tax_code                               VARCHAR2,
        X_base_rate                              NUMBER,
        X_start_date_active                      DATE,
        X_org_id                                 NUMBER,
        X_last_update_login                      NUMBER,
        X_creation_date                          DATE,
        X_created_by                             NUMBER,
        X_tax_category_to_reduce_id              NUMBER,
        X_calculate_in_oe                        VARCHAR2,
        X_attribute_category                     VARCHAR2,
        X_attribute1                             VARCHAR2,
        X_attribute2                             VARCHAR2,
        X_attribute3                             VARCHAR2,
        X_attribute4                             VARCHAR2,
        X_attribute5                             VARCHAR2,
        X_attribute6                             VARCHAR2,
        X_attribute7                             VARCHAR2,
        X_attribute8                             VARCHAR2,
        X_attribute9                             VARCHAR2,
        X_attribute10                            VARCHAR2,
        X_attribute11                            VARCHAR2,
        X_attribute12                            VARCHAR2,
        X_attribute13                            VARCHAR2,
        X_attribute14                            VARCHAR2,
        X_attribute15                            VARCHAR2,
        X_calling_sequence         IN            VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.UPDATE_ROW' ||
                                X_calling_sequence;

    debug_info := 'Open cursor C';
    UPDATE JL_ZZ_AR_TX_GROUPS
    SET group_tax_id              = X_group_tax_id,
        tax_category_id           = X_tax_category_id,
        tax_group_record_id       = X_tax_group_record_id,
        establishment_type        = X_establishment_type,
        contributor_type          = X_contributor_type,
        transaction_nature        = X_transaction_nature,
        end_date_active           = X_end_date_active,
        use_tx_categ_thresholds   = X_use_tx_categ_thresholds,
        last_update_date          = X_last_update_date,
        last_updated_by           = X_last_updated_by,
        compound_precedence       = X_compound_precedence,
        min_amount                = X_min_amount,
        min_taxable_basis         = X_min_taxable_basis,
        min_percentage            = X_min_percentage,
        tax_inclusive             = X_tax_inclusive,
        tributary_substitution    = X_tributary_substitution,
        used_to_reduce            = X_used_to_reduce,
        tax_code                  = X_tax_code,
        base_rate                 = X_base_rate,
        start_date_active         = X_start_Date_active,
        org_id                    = X_org_id,
        last_upDate_login         = X_last_upDate_login,
        creation_Date             = X_creation_Date,
        created_by                = X_created_by,
        tax_category_to_reduce_id = X_tax_category_to_reduce_id,
        calculate_in_oe           = X_calculate_in_oe,
        attribute_category        = X_attribute_category,
        attribute1                = X_attribute1,
        attribute2                = X_attribute2,
        attribute3                = X_attribute3,
        attribute4                = X_attribute4,
        attribute5                = X_attribute5,
        attribute6                = X_attribute6,
        attribute7                = X_attribute7,
        attribute8                = X_attribute8,
        attribute9                = X_attribute9,
        attribute10               = X_attribute10,
        attribute11               = X_attribute11,
        attribute12               = X_attribute12,
        attribute13               = X_attribute13,
        attribute14               = X_attribute14,
        attribute15               = X_attribute15
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('AR','AR_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                ' group_tax_id = '|| X_group_tax_id ||
                                ' tax_category_id = ' || X_tax_category_id ||
                                ' end_date_active = ' || to_char(X_end_date_active,'YYYY/MM/DD') );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END UpDate_Row;

  PROCEDURE Delete_Row
       (X_rowid                                  VARCHAR2,
        X_calling_sequence         IN            VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.UPDATE_ROW' ||
                                X_calling_sequence;
    debug_info := 'Open cursor C';

    DELETE FROM   JL_ZZ_AR_TX_GROUPS
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',' ROWID = '|| X_rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Delete_Row;

  PROCEDURE Check_Unique
       (X_rowid                                  VARCHAR2,
        X_group_tax_id                           NUMBER,
        X_tax_category_id                        NUMBER,
        X_tax_group_record_id                    NUMBER,
        X_transaction_nature                     VARCHAR2,
        X_contributor_type                       VARCHAR2,
        X_establishment_type                     VARCHAR2,
        X_end_date_active                        DATE,
        X_calling_sequence         IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.CHECK_UNIQUE<-' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM JL_ZZ_AR_TX_GROUPS
    WHERE group_tax_id = X_group_tax_id
    AND tax_category_id = X_tax_category_id
    AND tax_group_record_id = X_tax_group_record_id
    AND transaction_nature = X_transaction_nature
    AND contributor_type = X_contributor_type
    AND establishment_type = X_establishment_type
    AND end_date_active = X_end_date_active
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' group_tax_id = '    || X_group_tax_id ||
                            ' tax_category_id = ' || X_tax_category_id ||
                            ' end_date_active = ' || to_char(X_end_date_active,'YYYY/MM/DD') );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END Check_Unique;

  PROCEDURE Check_Overlapped_Dates
       (X_rowid                                  VARCHAR2,
        X_group_tax_id                           NUMBER,
        X_tax_category_id                        NUMBER,
        X_tax_group_record_id                    NUMBER,
        X_transaction_nature                     VARCHAR2,
        X_contributor_type                       VARCHAR2,
        X_establishment_type                     VARCHAR2,
        X_end_date_active                        DATE,
        X_start_date_active                      DATE,
        X_calling_sequence         IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.<-CHECK_OVERLAPPED_DATES' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_GROUPS a
    WHERE group_tax_id = X_group_tax_id
    AND tax_category_id = X_tax_category_id
    AND tax_group_record_id = X_tax_group_record_id
    AND transaction_nature = X_transaction_nature
    AND contributor_type = X_contributor_type
    AND establishment_type = X_establishment_type
    AND ((a.end_date_active <= X_end_date_active AND
          a.end_date_active >= X_start_date_active) OR
         (a.start_date_active <= X_end_date_active AND
          a.start_date_active >= X_start_date_active) OR
         (a.start_date_active <= X_start_date_active AND
          a.end_date_active >= X_end_date_active))
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' group_tax_id = '      || X_group_tax_id ||
                            ' tax_category_id = '   || to_char(X_tax_category_id) ||
                            ' end_date_active = '   || to_char(X_end_date_active,'YYYY/MM/DD') ||
                            ' start_date_active = ' || to_char(X_start_date_active,'YYYY/MM/DD') );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Overlapped_Dates;

  PROCEDURE Check_Gaps
       (X_rowid                                  VARCHAR2,
        X_group_tax_id                           NUMBER,
        X_tax_category_id                        NUMBER,
        X_tax_group_record_id                    NUMBER,
        X_transaction_nature                     VARCHAR2,
        X_contributor_type                       VARCHAR2,
        X_establishment_type                     VARCHAR2,
        X_end_date_active                        DATE,
        X_start_date_active                      DATE,
        X_calling_sequence         IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    l_dummy1                 NUMBER;
    l_dummy2                 NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_GROUPS_PKG.CHECK_GAPS<-' ||
                                 X_calling_sequence;
    --
    --  Check if there is one row with it's end date exactly one day
    --  less than the current row's start date
    --
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_GROUPS a
    WHERE group_tax_id = X_group_tax_id
    AND tax_category_id = X_tax_category_id
    AND tax_group_record_id = X_tax_group_record_id
    AND transaction_nature = X_transaction_nature
    AND contributor_type = X_contributor_type
    AND establishment_type = X_establishment_type
    AND trunc(a.end_date_active) = (trunc(X_start_date_active) -1)
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy = 0) THEN
      BEGIN
        --
        -- Check if there is one row with the start date one day more than the
        -- the current row's end-date
        --
        SELECT COUNT(1)
        INTO l_dummy1
        FROM jl_zz_ar_tx_GROUPS a
        WHERE group_tax_id = X_group_tax_id
        AND tax_category_id = X_tax_category_id
        AND tax_group_record_id = X_tax_group_record_id
        AND transaction_nature = X_transaction_nature
        AND contributor_type = X_contributor_type
        AND establishment_type = X_establishment_type
        AND (trunc(a.start_date_active) = (trunc(X_end_date_active) + 1))
        AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));
        --
        -- Check if there are no (other) rows at all for the primary key.
        -- If there are no rows, then it is not an error.  Otherwise, it is.
        --
        IF (l_dummy1 = 0) THEN
          BEGIN
            SELECT COUNT(1)
            INTO l_dummy2
            FROM jl_zz_ar_tx_GROUPS a
            WHERE group_tax_id = X_group_tax_id
            AND tax_category_id = X_tax_category_id
            AND tax_group_record_id = X_tax_group_record_id
            AND transaction_nature = X_transaction_nature
            AND contributor_type = X_contributor_type
            AND establishment_type = X_establishment_type
            AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

            IF (l_dummy2 <> 0) THEN
              FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                    ' group_tax_id = '      || X_group_tax_id ||
                                    ' tax_category_id = '   || to_char(X_tax_category_id) ||
                                    ' end_date_active = '   || to_char(X_end_date_active,'YYYY/MM/DD') ||
                                    ' start_date_active = ' || to_char(X_start_date_active,'YYYY/MM/DD') );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
              APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
          END;
        END IF;
      END;
    END IF;
  END Check_Gaps;

END JL_ZZ_AR_TX_GROUPS_PKG;

/
