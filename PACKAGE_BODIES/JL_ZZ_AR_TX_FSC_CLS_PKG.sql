--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_FSC_CLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_FSC_CLS_PKG" as
/* $Header: jlzztfcb.pls 120.3.12010000.2 2009/06/16 11:44:31 ssohal ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       NUMBER;
  g_level_procedure       NUMBER;
  g_level_event           NUMBER;
  g_level_exception       NUMBER;
  g_level_unexpected      NUMBER;

  PROCEDURE Insert_Row
       (X_Rowid                      IN OUT NOCOPY VARCHAR2,
        X_fsc_cls_id                               NUMBER,
        X_fiscal_classification_code               VARCHAR2,
        X_tax_category_id                          NUMBER,
        X_tax_code                                 VARCHAR2,
        X_end_date_active                          DATE,
        X_base_rate                                NUMBER,
        X_start_date_active                        DATE,
        X_org_id                                   NUMBER,
        X_enabled_flag                             VARCHAR2,
        X_last_update_date                         DATE,
        X_last_updated_by                          NUMBER,
        X_creation_date                            DATE,
        X_created_by                               NUMBER,
        X_last_update_login                        NUMBER,
        X_attribute_category                       VARCHAR2,
        X_attribute1                               VARCHAR2,
        X_attribute2                               VARCHAR2,
        X_attribute3                               VARCHAR2,
        X_attribute4                               VARCHAR2,
        X_attribute5                               VARCHAR2,
        X_attribute6                               VARCHAR2,
        X_attribute7                               VARCHAR2,
        X_attribute8                               VARCHAR2,
        X_attribute9                               VARCHAR2,
        X_attribute10                              VARCHAR2,
        X_attribute11                              VARCHAR2,
        X_attribute12                              VARCHAR2,
        X_attribute13                              VARCHAR2,
        X_attribute14                              VARCHAR2,
        X_attribute15                              VARCHAR2,
        X_calling_sequence                         VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM JL_ZZ_AR_TX_FSC_CLS
      WHERE fiscal_classification_code = X_fiscal_classification_code
      AND tax_category_id = X_tax_category_id
      AND end_date_active = X_end_date_active;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
    --     Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.INSERT_ROW<-' ||
                                X_calling_sequence;

    debug_info := 'Insert into JL_ZZ_AR_TX_FSC_CLS';
    INSERT INTO JL_ZZ_AR_TX_FSC_CLS (fsc_cls_id,
                                     fiscal_classification_code,
                                     tax_category_id,
                                     tax_code,
                                     end_date_active,
                                     base_rate,
                                     start_date_active,
                                     enabled_flag,
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
                             VALUES (X_fsc_cls_id,
                                     X_fiscal_classification_code,
                                     X_tax_category_id,
                                     X_tax_code,
                                     X_end_date_active,
                                     X_base_rate,
                                     X_start_date_active,
                                     X_enabled_flag,
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
    FETCH C INTO X_Rowid;
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
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','fiscal_classification_code = ' ||
                                    X_fiscal_classification_code ||
                              'tax_category_id = ' || X_tax_category_id  ||
                              'end_date_active = ' || X_end_date_active );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Insert_Row;

  PROCEDURE Lock_Row
       (X_Rowid                                    VARCHAR2,
        X_fsc_cls_id                               NUMBER,
        X_fiscal_classification_code               VARCHAR2,
        X_tax_category_id                          NUMBER,
        X_tax_code                                 VARCHAR2,
        X_end_date_active                          DATE,
        X_base_rate                                NUMBER,
        X_start_date_active                        DATE,
        X_org_id                                   NUMBER,
        X_enabled_flag                             VARCHAR2,
        X_last_update_date                         DATE,
        X_last_updated_by                          NUMBER,
        X_creation_date                            DATE,
        X_created_by                               NUMBER,
        X_last_update_login                        NUMBER,
        X_attribute_category                       VARCHAR2,
        X_attribute1                               VARCHAR2,
        X_attribute2                               VARCHAR2,
        X_attribute3                               VARCHAR2,
        X_attribute4                               VARCHAR2,
        X_attribute5                               VARCHAR2,
        X_attribute6                               VARCHAR2,
        X_attribute7                               VARCHAR2,
        X_attribute8                               VARCHAR2,
        X_attribute9                               VARCHAR2,
        X_attribute10                              VARCHAR2,
        X_attribute11                              VARCHAR2,
        X_attribute12                              VARCHAR2,
        X_attribute13                              VARCHAR2,
        X_attribute14                              VARCHAR2,
        X_attribute15                              VARCHAR2,
        X_calling_sequence                         VARCHAR2) IS

    CURSOR C IS
      SELECT FSC_CLS_ID,
             FISCAL_CLASSIFICATION_CODE,
             TAX_CATEGORY_ID,
             TAX_CODE,
             END_DATE_ACTIVE,
             ENABLED_FLAG,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             BASE_RATE,
             START_DATE_ACTIVE,
             ORG_ID,
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
        FROM JL_ZZ_AR_TX_FSC_CLS
        WHERE rowid = X_Rowid
        FOR UPDATE of fiscal_classification_code,
                      tax_category_id,
                      end_date_active,
                      org_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.LOCK_ROW<-' ||
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
    IF ((Recinfo.fsc_cls_id =  X_fsc_cls_id) AND
        (Recinfo.fiscal_classification_code =  X_fiscal_classification_code) AND
        (Recinfo.tax_category_id =  X_tax_category_id) AND
        (Recinfo.end_date_active =  X_end_date_active) AND
        (Recinfo.tax_code =  X_tax_code) AND
        (Recinfo.enabled_flag = X_enabled_flag) AND
        ((Recinfo.base_rate =  X_base_rate) OR
         ((Recinfo.base_rate IS NULL) AND
          (X_base_rate IS NULL))) AND
        ((Recinfo.start_date_active =  X_start_date_active) OR
         ((Recinfo.start_date_active IS NULL) AND
          (X_start_date_active IS NULL))) AND
        ((Recinfo.org_id =  X_org_id) OR
         ((Recinfo.org_id IS NULL) AND
          (X_org_id IS NULL))) AND
        ((Recinfo.attribute_category = X_attribute_category) OR
         ((Recinfo.attribute_category IS NULL) AND
          (X_attribute_category IS NULL))) AND
        ((Recinfo.attribute1 = X_attribute1) OR
         ((Recinfo.attribute1 IS NULL) AND
          (X_attribute1 IS NULL))) AND
        ((Recinfo.attribute2 = X_attribute2) OR
         ((Recinfo.attribute2 IS NULL) AND
          (X_attribute2 IS NULL))) AND
        ((Recinfo.attribute3 = X_attribute3) OR
         ((Recinfo.attribute3 IS NULL) AND
          (X_attribute3 IS NULL))) AND
        ((Recinfo.attribute4 = X_attribute4) OR
         ((Recinfo.attribute4 IS NULL) AND
          (X_attribute4 IS NULL))) AND
        ((Recinfo.attribute5 = X_attribute5) OR
         ((Recinfo.attribute5 IS NULL) AND
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
          FND_MESSAGE.SET_TOKEN('PARAMETERS','fiscal_classification_code = ' ||
                                X_fiscal_classification_code ||
                                'tax_category_id = ' || X_tax_category_id  ||
                                'end_date_active = ' || X_end_date_active );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row
       (X_Rowid                                    VARCHAR2,
        X_fsc_cls_id                               NUMBER,
        X_fiscal_classification_code               VARCHAR2,
        X_tax_category_id                          NUMBER,
        X_tax_code                                 VARCHAR2,
        X_end_date_active                          DATE,
        X_base_rate                                NUMBER,
        X_start_date_active                        DATE,
        X_org_id                                   NUMBER,
        X_enabled_flag                             VARCHAR2,
        X_last_update_date                         DATE,
        X_last_updated_by                          NUMBER,
        X_creation_date                            DATE,
        X_created_by                               NUMBER,
        X_last_update_login                        NUMBER,
        X_attribute_category                       VARCHAR2,
        X_attribute1                               VARCHAR2,
        X_attribute2                               VARCHAR2,
        X_attribute3                               VARCHAR2,
        X_attribute4                               VARCHAR2,
        X_attribute5                               VARCHAR2,
        X_attribute6                               VARCHAR2,
        X_attribute7                               VARCHAR2,
        X_attribute8                               VARCHAR2,
        X_attribute9                               VARCHAR2,
        X_attribute10                              VARCHAR2,
        X_attribute11                              VARCHAR2,
        X_attribute12                              VARCHAR2,
        X_attribute13                              VARCHAR2,
        X_attribute14                              VARCHAR2,
        X_attribute15                              VARCHAR2,
        X_calling_sequence                         VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_ZZ_AR_TX_FSC_CLS';

    UPDATE JL_ZZ_AR_TX_FSC_CLS
      SET fsc_cls_id                 = X_fsc_cls_id,
          fiscal_classification_code = X_fiscal_classification_code,
          tax_category_id            = X_tax_category_id,
          end_date_active            = X_end_date_active,
          tax_code                   = X_tax_code,
          base_rate                  = X_base_rate,
          start_date_active          = X_start_date_active,
          enabled_flag               = X_enabled_flag,
          last_update_date           = X_last_update_date,
          last_updated_by            = X_last_updated_by,
          creation_date              = X_creation_date,
          created_by                 = X_created_by,
          last_update_login          = X_last_update_login ,
          attribute_category         = X_attribute_category,
          attribute1                 = X_attribute1,
          attribute2                 = X_attribute2,
          attribute3                 = X_attribute3,
          attribute4                 = X_attribute4,
          attribute5                 = X_attribute5,
          attribute6                 = X_attribute6,
          attribute7                 = X_attribute7,
          attribute8                 = X_attribute8,
          attribute9                 = X_attribute9,
          attribute10                = X_attribute10,
          attribute11                = X_attribute11,
          attribute12                = X_attribute12,
          attribute13                = X_attribute13,
          attribute14                = X_attribute14,
          attribute15                = X_attribute15
      WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','fiscal_classification_code = ' ||
                              X_fiscal_classification_code ||
                              'tax_category_id = ' || X_tax_category_id  ||
                              'end_date_active = ' || X_end_date_active );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Row;

  PROCEDURE Delete_Row
       (X_Rowid                                    VARCHAR2,
        X_calling_sequence                         VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_ZZ_AR_TX_FSC_CLS';

    DELETE FROM JL_ZZ_AR_TX_FSC_CLS
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;


  PROCEDURE Check_Unique
       (X_rowid                                    VARCHAR2,
        X_fiscal_classification_code               VARCHAR2,
        X_tax_category_id                          NUMBER,
        X_end_date_active                          DATE,
        X_org_id                                   NUMBER,
        X_calling_sequence           IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.CHECK_UNIQUE<-' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_fsc_cls
    WHERE fiscal_classification_code = X_fiscal_classification_code
    AND tax_category_id = X_tax_category_id
    AND end_date_active = X_end_date_active
    AND org_id = X_org_id
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' fiscal_classification_code = ' || X_fiscal_classification_code ||
                            ' tax_category_id = ' || X_tax_category_id ||
                            ' end_date_active = ' || X_end_date_active);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Unique;

  PROCEDURE Check_Overlapped_Dates
       (X_rowid                                    VARCHAR2,
        X_fiscal_classification_code               VARCHAR2,
        X_tax_category_id                          NUMBER,
        X_end_date_active                          DATE,
        X_start_date_active                        DATE,
        X_org_id                                   NUMBER,
        X_calling_sequence           IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.<-CHECK_OVERLAPPED_DATES' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_fsc_cls a
    WHERE a.fiscal_classification_code = X_fiscal_classification_code
    AND a.tax_category_id = X_tax_category_id
    AND ((a.end_date_active <= X_end_date_active AND
          a.end_date_active >= X_start_date_active) OR
         (a.start_date_active <= X_end_date_active AND
          a.start_date_active >= X_start_date_active) OR
         (a.start_date_active <= X_start_date_active AND
          a.end_date_active >= X_end_date_active))
    AND org_id = X_org_id
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' fiscal_classification_code = ' || X_fiscal_classification_code ||
                            ' tax_category_id = ' || X_tax_category_id ||
                            ' end_date_active = ' || X_end_date_active );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Overlapped_Dates;


  PROCEDURE Check_Gaps
       (X_rowid                                    VARCHAR2,
        X_fiscal_classification_code               VARCHAR2,
        X_tax_category_id                          NUMBER,
        X_end_date_active                          DATE,
        X_start_date_active                        DATE,
        X_org_id                                   NUMBER,
        X_calling_sequence           IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    l_dummy1                 NUMBER;
    l_dummy2                 NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.CHECK_GAPS<-' ||
                                 X_calling_sequence;
    --
    --  Check if there is one row with it's end date exactly one day
    --  less than the current row's start date
    --
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_fsc_cls a
    WHERE a.fiscal_classification_code = X_fiscal_classification_code
    AND a.tax_category_id = X_tax_category_id
    AND trunc(a.end_date_active) = (trunc(X_start_date_active) -1)
    AND org_id = X_org_id
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy = 0) THEN
      BEGIN
        --
        -- Check if there is one row with the start date one day more than the
        -- the current row's end-date
        --
        SELECT COUNT(1)
        INTO l_dummy1
        FROM jl_zz_ar_tx_fsc_cls a
        WHERE a.fiscal_classification_code = X_fiscal_classification_code
        AND a.tax_category_id = X_tax_category_id
        AND (trunc(a.start_date_active) = (trunc(X_end_date_active) + 1))
        AND org_id = X_org_id
        AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

        -- Check if there are no (other) rows at all for the primary key.
        -- If there are no rows, then it is not an error.  Otherwise, it is.
        --
        IF (l_dummy1 = 0) THEN
          BEGIN
            SELECT COUNT(1)
            INTO   l_dummy2
            FROM   jl_zz_ar_tx_fsc_cls a
            WHERE  a.fiscal_classification_code = X_fiscal_classification_code
            AND    a.tax_category_id = X_tax_category_id
            AND org_id = X_org_id
            AND    ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

            IF (l_dummy2 <> 0) THEN
              FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                    ' fiscal_classification_code = ' || X_fiscal_classification_code           ||
                                    ' tax_category_id = ' || X_tax_category_id ||
                                    ' end_date_active = ' || X_end_date_active );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
              APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
          END;
        END IF;
      END;
    END IF;
  END Check_Gaps;

  PROCEDURE Create_Category
       (X_Rowid                      IN OUT NOCOPY VARCHAR2,
        X_structure_id                             NUMBER,
        X_segment1                                 VARCHAR2,
        X_summary_flag                             VARCHAR2,
        X_enabled_flag                             VARCHAR2,
        X_start_date_active                        DATE,
        X_end_date_active                          DATE,
        X_description                              VARCHAR2,
        X_attribute_category                       VARCHAR2,
        X_attribute1                               VARCHAR2,
        X_attribute2                               VARCHAR2,
        X_attribute3                               VARCHAR2,
        X_attribute4                               VARCHAR2,
        X_attribute5                               VARCHAR2,
        X_attribute6                               VARCHAR2,
        X_attribute7                               VARCHAR2,
        X_attribute8                               VARCHAR2,
        X_attribute9                               VARCHAR2,
        X_attribute10                              VARCHAR2,
        X_attribute11                              VARCHAR2,
        X_attribute12                              VARCHAR2,
        X_attribute13                              VARCHAR2,
        X_attribute14                              VARCHAR2,
        X_attribute15                              VARCHAR2,
        X_calling_sequence                         VARCHAR2) IS

    l_category_rec  INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
    l_return_status VARCHAR2(80);
    l_errorcode     NUMBER;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    l_category_id   NUMBER;

    l_api_version   CONSTANT NUMBER    := 1.0;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
    --     Update the calling sequence
    --
    g_current_runtime_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.CREATE_CATEGORY<-' ||
                                X_calling_sequence;

    l_category_rec.structure_id         := X_structure_id;
    l_category_rec.segment1             := X_segment1;
    l_category_rec.summary_flag         := X_summary_flag;
    l_category_rec.enabled_flag         := X_enabled_flag;
    l_category_rec.start_date_active    := X_start_date_active;
    l_category_rec.end_date_active      := X_end_date_active;
    l_category_rec.description          := X_description;
    l_category_rec.attribute_category   := X_attribute_category;
    l_category_rec.attribute1           := X_attribute1;
    l_category_rec.attribute2           := X_attribute2;
    l_category_rec.attribute3           := X_attribute3;
    l_category_rec.attribute4           := X_attribute4;
    l_category_rec.attribute5           := X_attribute5;
    l_category_rec.attribute6           := X_attribute6;
    l_category_rec.attribute7           := X_attribute7;
    l_category_rec.attribute8           := X_attribute8;
    l_category_rec.attribute9           := X_attribute9;
    l_category_rec.attribute10          := X_attribute10;
    l_category_rec.attribute11          := X_attribute11;
    l_category_rec.attribute12          := X_attribute12;
    l_category_rec.attribute13          := X_attribute13;
    l_category_rec.attribute14          := X_attribute14;
    l_category_rec.attribute15          := X_attribute15;

    debug_info := 'calling INV_ITEM_CATEGORY_PUB.GET_CATEGORY_ID_FROM_CAT_REC';

    INV_ITEM_CATEGORY_PUB.GET_CATEGORY_ID_FROM_CAT_REC
         (
          p_category_rec  => l_category_rec,
          x_category_id   => l_category_id,
          x_return_status => l_return_status,
          x_msg_data      => l_msg_data
         );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF l_category_id = -1  THEN  -- Category does not exist, create new category
         debug_info := 'calling INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY';

         INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY
             (
              P_API_VERSION      => l_api_version,
              P_INIT_MSG_LIST    => FND_API.G_FALSE,
              P_COMMIT           => FND_API.G_FALSE,
              X_RETURN_STATUS    => l_return_status,
              X_ERRORCODE        => l_errorcode,
              X_MSG_COUNT        => l_msg_count,
              X_MSG_DATA         => l_msg_data,
              P_CATEGORY_REC     => l_category_rec,
              X_CATEGORY_ID      => l_category_id
             );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF l_msg_count > 0 THEN
             FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR', l_msg_data);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','segment1 = ' || X_segment1 ||
                                   'structure_id = ' || X_structure_id ||
                                   'end_date_active = ' || X_end_date_active );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                       'JL.PLSQL.JL_ZZ_AR_TX_FSC_CLS_PKG.CREATE_CATEGORY',
                       'New Category created in MTL_CATEGORIES_B. '||
                       'Category_Id : '||l_category_id);
         END IF;

       ELSE   -- Category already exists
         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                       'JL.PLSQL.JL_ZZ_AR_TX_FSC_CLS_PKG.CREATE_CATEGORY',
                       'Category Already Exists in MTL_CATEGORIES_B. '||
                       'Category_Id : '||l_category_id);
         END IF;
       END IF;

    ELSE
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', l_msg_data);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','segment1 = ' || X_segment1 ||
                            'structure_id = ' || X_structure_id ||
                            'end_date_active = ' || X_end_date_active );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','segment1 = ' ||
                                    X_segment1 ||
                              'structure_id = ' || X_structure_id ||
                              'end_date_active = ' || X_end_date_active );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Create_category;


  PROCEDURE Update_Category
       (X_category_id                              NUMBER,
        X_structure_id                             NUMBER,
        X_disable_date                             DATE,
        X_web_status                               VARCHAR2,
        X_supplier_enabled_flag                    VARCHAR2,
        X_segment1                                 VARCHAR2,
        X_segment2                                 VARCHAR2,
        X_segment3                                 VARCHAR2,
        X_segment4                                 VARCHAR2,
        X_segment5                                 VARCHAR2,
        X_segment6                                 VARCHAR2,
        X_segment7                                 VARCHAR2,
        X_segment8                                 VARCHAR2,
        X_segment9                                 VARCHAR2,
        X_segment10                                VARCHAR2,
        X_segment11                                VARCHAR2,
        X_segment12                                VARCHAR2,
        X_segment13                                VARCHAR2,
        X_segment14                                VARCHAR2,
        X_segment15                                VARCHAR2,
        X_segment16                                VARCHAR2,
        X_segment17                                VARCHAR2,
        X_segment18                                VARCHAR2,
        X_segment19                                VARCHAR2,
        X_segment20                                VARCHAR2,
        X_summary_flag                             VARCHAR2,
        X_enabled_flag                             VARCHAR2,
        X_start_date_active                        DATE,
        X_end_date_active                          DATE,
        X_description                              VARCHAR2,
        X_attribute_category                       VARCHAR2,
        X_attribute1                               VARCHAR2,
        X_attribute2                               VARCHAR2,
        X_attribute3                               VARCHAR2,
        X_attribute4                               VARCHAR2,
        X_attribute5                               VARCHAR2,
        X_attribute6                               VARCHAR2,
        X_attribute7                               VARCHAR2,
        X_attribute8                               VARCHAR2,
        X_attribute9                               VARCHAR2,
        X_attribute10                              VARCHAR2,
        X_attribute11                              VARCHAR2,
        X_attribute12                              VARCHAR2,
        X_attribute13                              VARCHAR2,
        X_attribute14                              VARCHAR2,
        X_attribute15                              VARCHAR2,
        X_calling_sequence                         VARCHAR2) IS

    l_category_rec  INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
    l_return_status VARCHAR2(80);
    l_errorcode     NUMBER;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);

    l_api_version   CONSTANT NUMBER    := 1.0;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
    --     Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_FSC_CLS_PKG.UPDATE_CATEGORY<-' ||
                                X_calling_sequence;

    debug_info := 'calling INV_ITEM_CATEGORY_PUB.UPDATE_CATEGORY';

    l_category_rec.category_id           := X_category_id;
    l_category_rec.structure_id          := X_structure_id;
    l_category_rec.disable_date          := X_disable_date;
    l_category_rec.web_status            := X_web_status;
    l_category_rec.supplier_enabled_flag := X_supplier_enabled_flag;
    l_category_rec.segment1              := X_segment1;
    l_category_rec.segment2              := X_segment2;
    l_category_rec.segment3              := X_segment3;
    l_category_rec.segment4              := X_segment4;
    l_category_rec.segment5              := X_segment5;
    l_category_rec.segment6              := X_segment6;
    l_category_rec.segment7              := X_segment7;
    l_category_rec.segment8              := X_segment8;
    l_category_rec.segment9              := X_segment9;
    l_category_rec.segment10             := X_segment10;
    l_category_rec.segment11             := X_segment11;
    l_category_rec.segment12             := X_segment12;
    l_category_rec.segment13             := X_segment13;
    l_category_rec.segment14             := X_segment14;
    l_category_rec.segment15             := X_segment15;
    l_category_rec.segment16             := X_segment16;
    l_category_rec.segment17             := X_segment17;
    l_category_rec.segment18             := X_segment18;
    l_category_rec.segment19             := X_segment19;
    l_category_rec.segment20             := X_segment20;
    l_category_rec.summary_flag          := X_summary_flag;
    l_category_rec.enabled_flag          := X_enabled_flag;
    l_category_rec.start_date_active     := X_start_date_active;
    l_category_rec.end_date_active       := X_end_date_active;
    l_category_rec.description           := X_description;
    l_category_rec.attribute_category    := X_attribute_category;
    l_category_rec.attribute1            := X_attribute1;
    l_category_rec.attribute2            := X_attribute2;
    l_category_rec.attribute3            := X_attribute3;
    l_category_rec.attribute4            := X_attribute4;
    l_category_rec.attribute5            := X_attribute5;
    l_category_rec.attribute6            := X_attribute6;
    l_category_rec.attribute7            := X_attribute7;
    l_category_rec.attribute8            := X_attribute8;
    l_category_rec.attribute9            := X_attribute9;
    l_category_rec.attribute10           := X_attribute10;
    l_category_rec.attribute11           := X_attribute11;
    l_category_rec.attribute12           := X_attribute12;
    l_category_rec.attribute13           := X_attribute13;
    l_category_rec.attribute14           := X_attribute14;
    l_category_rec.attribute15           := X_attribute15;

    INV_ITEM_CATEGORY_PUB.UPDATE_CATEGORY
           (
             P_API_VERSION      => l_api_version,
             P_INIT_MSG_LIST    => FND_API.G_FALSE,
             P_COMMIT           => FND_API.G_FALSE,
             X_RETURN_STATUS    => l_return_status,
             X_ERRORCODE        => l_errorcode,
             X_MSG_COUNT        => l_msg_count,
             X_MSG_DATA         => l_msg_data,
             P_CATEGORY_REC     => l_category_rec
           );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF l_msg_count > 0 THEN
         FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR', l_msg_data);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','segment1 = ' ||
                                     X_segment1 ||
                               'structure_id = ' || X_structure_id ||
                               'end_date_active = ' || X_end_date_active );
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;


  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','segment1 = ' ||
                                    X_segment1 ||
                              'structure_id = ' || X_structure_id ||
                              'category_id = ' || X_category_id );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Category;

-- Constructor
BEGIN
  g_level_statement       := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           := FND_LOG.LEVEL_EVENT;
  g_level_exception       := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      := FND_LOG.LEVEL_UNEXPECTED;

END JL_ZZ_AR_TX_FSC_CLS_PKG;

/
