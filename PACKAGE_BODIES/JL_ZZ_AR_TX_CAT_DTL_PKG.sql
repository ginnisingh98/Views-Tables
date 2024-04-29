--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_CAT_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_CAT_DTL_PKG" AS
/* $Header: jlzztcdb.pls 120.2 2003/03/03 19:34:17 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid               IN OUT NOCOPY VARCHAR2,
        X_tax_categ_dtl_id                  NUMBER,
        X_tax_category_id                   NUMBER,
        X_end_date_active                   DATE,
        X_min_taxable_basis                 NUMBER,
        X_last_update_date                  DATE,
        X_last_updated_by                   NUMBER,
        X_min_amount                        NUMBER,
        X_min_percentage                    NUMBER,
        X_tax_code                          VARCHAR2,
        X_start_date_active                 DATE,
        X_org_id                            NUMBER,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_attribute_category                VARCHAR2,
        X_attribute1                        VARCHAR2,
        X_attribute2                        VARCHAR2,
        X_attribute3                        VARCHAR2,
        X_attribute4                        VARCHAR2,
        X_attribute5                        VARCHAR2,
        X_attribute6                        VARCHAR2,
        X_attribute7                        VARCHAR2,
        X_attribute8                        VARCHAR2,
        X_attribute9                        VARCHAR2,
        X_attribute10                       VARCHAR2,
        X_attribute11                       VARCHAR2,
        X_attribute12                       VARCHAR2,
        X_attribute13                       VARCHAR2,
        X_attribute14                       VARCHAR2,
        X_attribute15                       VARCHAR2,
        X_calling_sequence    IN            VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM   jl_zz_ar_tx_cat_dtl
      WHERE  tax_category_id = X_tax_category_id
      AND tax_categ_dtl_id   = X_tax_categ_dtl_id;
      --AND end_date_active    = X_end_date_active;

      current_calling_sequence    VARCHAR2(2000);
      debug_info                  VARCHAR2(100);

  BEGIN
    --Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_CAT_DTL_PKG.INSERT_ROW<-' ||X_calling_sequence;

    debug_info := 'Insert into JL_ZZ_AR_TX_CAT_DTL';
    INSERT INTO jl_zz_ar_tx_cat_dtl (tax_categ_dtl_id,
                                     tax_category_id,
                                     end_date_active,
                                     min_taxable_basis,
                                     last_update_date,
                                     last_updated_by,
                                     min_amount,
                                     min_percentage,
                                     tax_code,
                                     start_date_active,
                                     org_id,
                                     last_update_login,
                                     creation_date,
                                     created_by,
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
                             VALUES (X_tax_categ_dtl_id,
                                     X_tax_category_id,
                                     NVL(X_end_date_active,
                                         TO_DATE('31/12/4712', 'DD/MM/YYYY')),
                                     X_min_taxable_basis,
                                     X_last_update_date,
                                     X_last_updated_by,
                                     X_min_amount,
                                     X_min_percentage,
                                     X_tax_code,
                                     NVL(X_start_date_active,
                                         TO_DATE('01/01/1000', 'DD/MM/YYYY')),
                                     X_org_id,
                                     X_last_update_login,
                                     X_creation_date,
                                     X_created_by,
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
        FND_MESSAGE.SET_NAME('SQLAR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              ' tax_category_id = ' || X_tax_category_id ||
                              ' tax_categ_dtl_id= ' || X_tax_categ_dtl_id ||
                              ' end_date_active = ' || X_end_date_active );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row
       (X_rowid               IN OUT NOCOPY VARCHAR2,
        X_tax_categ_dtl_id                  NUMBER,
        X_tax_category_id                   NUMBER,
        X_end_date_active                   DATE,
        X_min_taxable_basis                 NUMBER,
        X_last_update_date                  DATE,
        X_last_updated_by                   NUMBER,
        X_min_amount                        NUMBER,
        X_min_percentage                    NUMBER,
        X_tax_code                          VARCHAR2,
        X_start_date_active                 DATE,
        X_org_id                            NUMBER,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_attribute_category                VARCHAR2,
        X_attribute1                        VARCHAR2,
        X_attribute2                        VARCHAR2,
        X_attribute3                        VARCHAR2,
        X_attribute4                        VARCHAR2,
        X_attribute5                        VARCHAR2,
        X_attribute6                        VARCHAR2,
        X_attribute7                        VARCHAR2,
        X_attribute8                        VARCHAR2,
        X_attribute9                        VARCHAR2,
        X_attribute10                       VARCHAR2,
        X_attribute11                       VARCHAR2,
        X_attribute12                       VARCHAR2,
        X_attribute13                       VARCHAR2,
        X_attribute14                       VARCHAR2,
        X_attribute15                       VARCHAR2,
        X_calling_sequence    IN            VARCHAR2) IS

    CURSOR C IS
      SELECT TAX_CATEG_DTL_ID,
             TAX_CATEGORY_ID,
             END_DATE_ACTIVE,
             MIN_TAXABLE_BASIS,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             MIN_AMOUNT,
             MIN_PERCENTAGE,
             TAX_CODE,
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
        FROM JL_ZZ_AR_TX_CAT_DTL
        WHERE rowid = X_rowid
        --AND tax_category_id  = X_tax_category_id
        --AND tax_categ_dtl_id = X_tax_categ_dtl_id
        --AND end_date_active  = X_end_date_active
        FOR UPDATE OF tax_categ_dtl_id
        NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence     VARCHAR2(2000);
    debug_info                   VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_CAT_DTL_PKG.LOCK_ROW<-' ||X_calling_sequence;
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

    IF ((Recinfo. tax_categ_dtl_id = X_tax_categ_dtl_id) AND
        (Recinfo.tax_category_id = X_tax_category_id) AND
        (Recinfo.end_date_active = X_end_date_active) AND
        --(Recinfo.min_taxable_basis = X_min_taxable_basis) AND
        (Recinfo.last_update_date = X_last_update_date) AND
        (Recinfo.last_updated_by = X_last_updated_by) AND
        ((Recinfo.min_taxable_basis = X_min_taxable_basis) OR
         ((Recinfo.min_taxable_basis IS NULL) AND
          (X_min_taxable_basis IS NULL))) AND
        ((Recinfo.min_amount = X_min_amount) OR
         ((Recinfo.min_amount IS NULL) AND
          (X_min_amount IS NULL))) AND
        ((Recinfo.min_percentage = X_min_percentage) OR
         ((Recinfo.min_percentage IS NULL) AND
          (X_min_percentage IS NULL))) AND
        ((Recinfo.tax_code = X_tax_code) OR
         ((Recinfo.tax_code IS NULL) AND
          (X_tax_code IS NULL))) AND
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
          FND_MESSAGE.SET_NAME('SQLAR','AR_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('SQLAR','AR_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                ' tax_category_id = '  || X_tax_category_id  ||
                                ' tax_categ_dtl_id = ' || X_tax_categ_dtl_id ||
                                ' end_date_active = '  || X_end_date_active );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE UpDate_Row
       (X_rowid               IN OUT NOCOPY VARCHAR2,
        X_tax_categ_dtl_id                  NUMBER,
        X_tax_category_id                   NUMBER,
        X_end_date_active                   DATE,
        X_min_taxable_basis                 NUMBER,
        X_last_update_date                  DATE,
        X_last_updated_by                   NUMBER,
        X_min_amount                        NUMBER,
        X_min_percentage                    NUMBER,
        X_tax_code                          VARCHAR2,
        X_start_date_active                 DATE,
        X_org_id                            NUMBER,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_attribute_category                VARCHAR2,
        X_attribute1                        VARCHAR2,
        X_attribute2                        VARCHAR2,
        X_attribute3                        VARCHAR2,
        X_attribute4                        VARCHAR2,
        X_attribute5                        VARCHAR2,
        X_attribute6                        VARCHAR2,
        X_attribute7                        VARCHAR2,
        X_attribute8                        VARCHAR2,
        X_attribute9                        VARCHAR2,
        X_attribute10                       VARCHAR2,
        X_attribute11                       VARCHAR2,
        X_attribute12                       VARCHAR2,
        X_attribute13                       VARCHAR2,
        X_attribute14                       VARCHAR2,
        X_attribute15                       VARCHAR2,
        X_calling_sequence    IN            VARCHAR2) IS

    current_calling_sequence  VARCHAR2(2000);
    debug_info                VARCHAR2(100);

  BEGIN
    UPDATE jl_zz_ar_tx_cat_dtl
      SET tax_categ_dtl_id   = X_tax_categ_dtl_id,
          tax_category_id    = X_tax_category_id,
          end_date_active    = X_end_date_active,
          min_taxable_basis  = X_min_taxable_basis,
          last_update_date   = X_last_update_date,
          last_updated_by    = X_last_updated_by,
          min_amount         = X_min_amount,
          min_percentage     = X_min_percentage,
          tax_code           = X_tax_code,
          start_Date_active  = X_start_Date_active,
          org_id             = X_org_id,
          last_upDate_login  = X_last_upDate_login,
          creation_Date      = X_creation_Date,
          created_by         = X_created_by,
          attribute_category = X_attribute_category,
          attribute1         = X_attribute1,
          attribute2         = X_attribute2,
          attribute3         = X_attribute3,
          attribute4         = X_attribute4,
          attribute5         = X_attribute5,
          attribute6         = X_attribute6,
          attribute7         = X_attribute7,
          attribute8         = X_attribute8,
          attribute9         = X_attribute9,
          attribute10        = X_attribute10,
          attribute11        = X_attribute11,
          attribute12        = X_attribute12,
          attribute13        = X_attribute13,
          attribute14        = X_attribute14,
          attribute15        = X_attribute15
    WHERE rowid = X_rowid
    AND tax_category_id = X_tax_category_id
    AND tax_categ_dtl_id = X_tax_categ_dtl_id;

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
                                ' tax_categ_dtl_id = ' || X_tax_categ_dtl_id ||
                                ' tax_category_id = '  || X_tax_category_id ||
                                ' end_date_active = '  || X_end_date_active );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END UpDate_Row;

  PROCEDURE Delete_Row
       (X_rowid                             VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_categ_dtl_id                  NUMBER,
        X_end_date_active                   DATE,
        X_calling_sequence    IN            VARCHAR2) IS

    current_calling_sequence   VARCHAR2(2000);
    debug_info                 VARCHAR2(100);

  BEGIN
    DELETE FROM jl_zz_ar_tx_cat_dtl
    WHERE rowid = X_rowid
    AND tax_category_id = X_tax_category_id
    AND tax_categ_dtl_id = X_tax_categ_dtl_id;

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
                              ' tax_categ_dtl_id = '|| X_tax_categ_dtl_id ||
                              ' tax_category_id = ' || X_tax_category_id ||
                              ' end_date_active = ' || X_end_date_active );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END Delete_Row;

  PROCEDURE Check_Unique
       (X_rowid                             VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_categ_dtl_id                  NUMBER,
        X_end_date_active                   DATE,
        X_calling_sequence    IN            VARCHAR2) IS

    l_dummy NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info                   VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence :='JL_ZZ_AR_TX_CAT_PKG.CHECK_UNIQUE<-' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_cat_dtl
    WHERE tax_category_id = X_tax_category_id
    AND tax_categ_dtl_id = X_tax_categ_dtl_id
    AND end_date_active = X_end_date_active
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('SQLAR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_category_id = '  || X_tax_category_id ||
                            ' tax_categ_dtl_id = ' || X_tax_categ_dtl_id ||
                            ' end_date_active = '  || X_end_date_active );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Unique;

  PROCEDURE Check_Overlapped_Dates
       (X_rowid                             VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_categ_dtl_id                  NUMBER,
        X_end_date_active                   DATE,
        X_start_date_active                 DATE,
        X_calling_sequence    IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_CAT_DTL_PKG.<-CHECK_OVERLAPPED_DATES' ||
                                 X_calling_sequence;
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_cat_dtl a
    WHERE tax_category_id = X_tax_category_id
    AND tax_categ_dtl_id = X_tax_categ_dtl_id
    AND ((a.end_date_active <= X_end_date_active AND a.end_date_active >= X_start_date_active) OR
               (a.start_date_active <= X_end_date_active AND a.start_date_active >= X_start_date_active) OR
               (a.start_date_active <= X_start_date_active AND a.end_date_active >= X_end_date_active))
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('SQLAR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_category_id   = ' || to_char(X_tax_category_id) ||
                            ' tax_categ_dtl_id  = ' || X_tax_categ_dtl_id ||
                            ' end_date_active   = ' || X_end_date_active ||
                            ' start_date_active = ' || X_start_date_active );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Overlapped_Dates;

  PROCEDURE Check_Gaps
       (X_rowid                             VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_categ_dtl_id                  NUMBER,
        X_end_date_active                   DATE,
        X_start_date_active                 DATE,
        X_calling_sequence    IN            VARCHAR2) IS

    l_dummy                  NUMBER;
    l_dummy1                 NUMBER;
    l_dummy2                 NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_CAT_DTL_PKG.CHECK_GAPS<-' ||
                                 X_calling_sequence;
    --
    --  Check if there is one row with it's end date exactly one day
    --  less than the current row's start date
    --
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_cat_dtl a
    WHERE tax_category_id = X_tax_category_id
    AND tax_categ_dtl_id = X_tax_categ_dtl_id
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy = 0) THEN
      BEGIN
        --
        -- Check if there is one row with the start date one day more than the
        -- the current row's end-date
        --
        SELECT COUNT(1)
        INTO   l_dummy1
        FROM   jl_zz_ar_tx_cat_dtl a
        WHERE tax_category_id = X_tax_category_id
        AND tax_categ_dtl_id = X_tax_categ_dtl_id
        AND (trunc(a.start_date_active) = (trunc(X_end_date_active) + 1))
        AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));
        --
        -- Check if there are no (other) rows at all for the primary key.
        -- If there are no rows, then it is not an error.  Otherwise, it is.
        --
        IF (l_dummy1 = 0) THEN
          BEGIN
            SELECT COUNT(1)
            INTO   l_dummy2
            FROM   jl_zz_ar_tx_cat_dtl a
            WHERE tax_category_id = X_tax_category_id
            AND tax_categ_dtl_id = X_tax_categ_dtl_id
            AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

            IF (l_dummy2 <> 0) THEN
              FND_MESSAGE.SET_NAME('SQLAR','AR_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                    ' tax_category_id   = ' || to_char(X_tax_category_id) ||
                                    ' tax_categ_dtl_id = '  || X_tax_categ_dtl_id ||
                                    ' end_date_active   = ' || X_end_date_active ||
                                    ' start_date_active = ' || X_start_date_active );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
              APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
          END;
        END IF;
      END;
    END IF;
  END Check_Gaps;

END JL_ZZ_AR_TX_CAT_DTL_PKG;

/
