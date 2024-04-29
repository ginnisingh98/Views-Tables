--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_NAT_RAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_NAT_RAT_PKG" AS
/* $Header: jlzztnrb.pls 120.3 2003/09/02 22:00:24 opedrega ship $*/

  PROCEDURE Insert_row
       (X_rowid                 IN OUT NOCOPY VARCHAR2,
        X_txn_nature_id                       NUMBER,
        X_last_update_date                    DATE,
        X_last_updated_by                     NUMBER,
        X_creation_date                       DATE,
        X_created_by                          NUMBER,
        X_last_update_login                   NUMBER,
        X_tax_categ_attr_val_id               NUMBER,
        X_end_date_active                     DATE,
        X_tax_code                            VARCHAR2,
        X_min_taxable_basis                   NUMBER,
        X_min_amount                          NUMBER,
        X_min_percentage                      NUMBER,
        X_base_rate                           NUMBER,
        X_start_date_active                   DATE,
        X_org_id                              NUMBER,
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
        X_calling_sequence      IN            VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM JL_ZZ_AR_TX_NAT_RAT
      WHERE tax_categ_attr_val_id = X_tax_categ_attr_val_id
      AND end_date_active = X_end_date_active
      AND org_id = X_org_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info            VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.INSERT_ROW<-' ||
                                X_calling_sequence;
    debug_info:= 'Insert into JL_ZZ_AR_TX_NAT_RAT';

    INSERT INTO JL_ZZ_AR_TX_NAT_RAT(txn_nature_id,
                                    tax_categ_attr_val_id,
                                    end_date_active,
                                    tax_code,
                                    last_update_date,
                                    last_updated_by,
                                    min_taxable_basis,
                                    min_amount,
                                    min_percentage,
                                    base_rate,
                                    start_date_active,
                                    org_id,
                                    last_update_login,
                                    creation_date,
                                    created_by  ,
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
                            VALUES (X_txn_nature_id,
                                    X_tax_categ_attr_val_id,
                                    X_end_date_active,
                                    X_tax_code,
                                    X_last_update_date,
                                    X_last_updated_by,
                                    X_min_taxable_basis,
                                    X_min_amount,
                                    X_min_percentage,
                                    X_base_rate,
                                    X_start_date_active,
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
    fetch C into X_rowid;
    IF (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      close C;
      raise NO_DATA_FOUND;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR','SQLERRM');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', ' txn_nature_id = '||TO_CHAR(X_txn_nature_id)||
                              ' tax_categ_attr_val_id = '||TO_CHAR(X_tax_categ_attr_val_id)||
                              ' start_date_active = '||TO_CHAR(X_start_date_active,'YYYY/MM/DD')||
                              ' end_date_active = '|| TO_CHAR(X_end_date_active,'YYYY/MM/DD'));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF ;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Insert_row;

  PROCEDURE lock_row
       (X_rowid                 IN OUT NOCOPY VARCHAR2,
        X_txn_nature_id                       NUMBER,
        X_tax_categ_attr_val_id               NUMBER,
        X_end_date_active                     DATE,
        X_tax_code                            VARCHAR2,
        X_min_taxable_basis                   NUMBER,
        X_min_amount                          NUMBER,
        X_min_percentage                      NUMBER,
        X_base_rate                           NUMBER,
        X_start_date_active                   DATE,
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
        X_calling_sequence      IN            VARCHAR2) IS

    CURSOR c IS
      SELECT TXN_NATURE_ID,
             TAX_CATEG_ATTR_VAL_ID,
             END_DATE_ACTIVE,
             TAX_CODE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             MIN_TAXABLE_BASIS,
             MIN_AMOUNT,
             MIN_PERCENTAGE,
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
        FROM JL_ZZ_AR_TX_NAT_RAT
        WHERE ROWID = X_rowid
        FOR UPDATE OF tax_categ_attr_val_id,
                      end_date_active NOWAIT;
    recinfo c%ROWTYPE;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Sequence assigned in form(X_calling_sequence).
    debug_info := 'Insert into JL_ZZ_AR_TX_NAT_RAT';
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.lock_row<-'||
                                X_calling_sequence;

    debug_info := 'Open cursor C';
    OPEN c;
    debug_info := 'Fetch cursor C';
    FETCH c INTO recinfo;
    IF (c%notfound) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE c;
      FND_MESSAGE.Set_name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE c;

    IF ((recinfo.txn_nature_id         = X_txn_nature_id) AND
        (recinfo.tax_categ_attr_val_id = X_tax_categ_attr_val_id) AND
        (recinfo.end_date_active       = X_end_date_active) AND
        (recinfo.tax_code              = X_tax_code) AND
        ((recinfo.min_taxable_basis = X_min_taxable_basis) OR
         ((recinfo.min_taxable_basis is null) AND
          (X_min_taxable_basis is null))) AND
        ((recinfo.min_amount = X_min_amount) OR
         ((recinfo.min_amount is null) AND
          (X_min_amount is null))) AND
        ((recinfo.min_percentage = X_min_percentage) OR
         ((recinfo.min_percentage is null) AND
          (X_min_percentage is null))) AND
        ((recinfo.base_rate = X_base_rate) OR
         ((recinfo.base_rate is null) AND
          (X_base_rate is null))) AND
        ((Recinfo.start_date_active = X_start_date_active) OR
         ((Recinfo.start_date_active IS NULL) AND
          (X_start_date_active IS NULL))) AND
        ((Recinfo.org_id = X_org_id) OR
         ((Recinfo.org_id IS NULL) AND
          (X_org_id IS NULL))) AND
        ((Recinfo.creation_date    = X_creation_date) OR
         ((Recinfo.creation_date IS NULL) AND
          (X_creation_date IS NULL))) AND
        ((Recinfo.created_by    = X_created_by) OR
         ((Recinfo.created_by IS NULL) AND
          (X_created_by IS NULL))) AND
        ((Recinfo.last_update_login = X_last_update_login) OR
         ((Recinfo.last_update_login IS NULL) AND
          (X_last_update_login IS NULL))) AND
        ((Recinfo.attribute_category =  X_attribute_Category) OR
         ((Recinfo.attribute_category IS NULL) AND
          (X_attribute_Category IS NULL))) AND
        ((Recinfo.attribute1 =  X_attribute1) OR
         ((Recinfo.attribute1 IS NULL) AND
          (X_attribute1 IS NULL))) AND
        ((Recinfo.attribute2 =  X_attribute2) OR
         ((Recinfo.attribute2 IS NULL) AND
          (X_attribute2 IS NULL))) AND
        ((Recinfo.attribute3 =  X_attribute3) OR
         ((Recinfo.attribute3 IS NULL) AND
          (X_attribute3 IS NULL))) AND
        ((Recinfo.attribute4 =  X_attribute4) OR
         ((Recinfo.attribute4 IS NULL) AND
          (X_attribute4 IS NULL))) AND
        ((Recinfo.attribute5 =  X_attribute5) OR
         ((Recinfo.attribute5 IS NULL) AND
          (X_attribute5 IS NULL))) AND
        ((Recinfo.attribute6 =  X_attribute6) OR
         ((Recinfo.attribute6 IS NULL) AND
          (X_attribute6 IS NULL))) AND
        ((Recinfo.attribute7 =  X_attribute7) OR
         ((Recinfo.attribute7 IS NULL) AND
          (X_attribute7 IS NULL))) AND
        ((Recinfo.attribute8 =  X_attribute8) OR
         ((Recinfo.attribute8 IS NULL) AND
          (X_attribute8 IS NULL))) AND
        ((Recinfo.attribute9 =  X_attribute9) OR
         ((Recinfo.attribute9 IS NULL) AND
          (X_attribute9 IS NULL))) AND
        ((Recinfo.attribute10 =  X_attribute10) OR
         ((Recinfo.attribute10 IS NULL) AND
          (X_attribute10 IS NULL))) AND
        ((Recinfo.attribute11 =  X_attribute11) OR
         ((Recinfo.attribute11 IS NULL) AND
          (X_attribute11 IS NULL))) AND
        ((Recinfo.attribute12 =  X_attribute12) OR
         ((Recinfo.attribute12 IS NULL) AND
          (X_attribute12 IS NULL))) AND
        ((Recinfo.attribute13 =  X_attribute13) OR
         ((Recinfo.attribute13 IS NULL) AND
          (X_attribute13 IS NULL))) AND
        ((Recinfo.attribute14 =  X_attribute14) OR
         ((Recinfo.attribute14 IS NULL) AND
          (X_attribute14 IS NULL))) AND
        ((Recinfo.attribute15 =  X_attribute15) OR
         ((Recinfo.attribute15 IS NULL) AND
          (X_attribute15 IS NULL)))) THEN
      return;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_exception;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('AR', 'AR_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('AR', 'AR_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                ' txn_nature_id = '||TO_CHAR(X_txn_nature_id)||
                                ' tax_categ_attr_val_id = '||TO_CHAR(X_tax_categ_attr_val_id)||
                                ' start_date_active = '||TO_CHAR(X_start_date_active,'YYYY/MM/DD')||
                                ' end_date_active = '|| TO_CHAR(X_end_date_active,'YYYY/MM/DD'));
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END lock_row;

  PROCEDURE Update_row
       (X_rowid                 IN OUT NOCOPY VARCHAR2,
        X_txn_nature_id                       NUMBER,
        X_tax_categ_attr_val_id               NUMBER,
        X_end_date_active                     DATE,
        X_tax_code                            VARCHAR2,
        X_min_taxable_basis                   NUMBER,
        X_min_amount                          NUMBER,
        X_min_percentage                      NUMBER,
        X_base_rate                           NUMBER,
        X_start_date_active                   DATE,
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
        X_calling_sequence      IN            VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.UPDATE_ROW<-' ||
                                X_calling_sequence;
    debug_info:= 'Update into JL_ZZ_AR_TX_NAT_RAT';

    UPDATE jl_zz_ar_tx_nat_rat
      SET txn_nature_id         = X_txn_nature_id,
          tax_categ_attr_val_id = X_tax_categ_attr_val_id,
          end_date_active       = X_end_date_active,
          tax_code              = X_tax_code,
          last_update_date      = X_last_update_date,
          last_updated_by       = X_last_updated_by,
          min_taxable_basis     = X_min_taxable_basis,
          min_amount            = X_min_amount,
          min_percentage        = X_min_percentage,
          base_rate             = X_base_rate,
          start_date_active     = X_start_date_active,
          org_id                = X_org_id,
          last_update_login     = X_last_update_login,
          creation_date         = X_creation_date,
          created_by            = X_created_by,
          attribute_category    = X_attribute_category,
          attribute1            = X_attribute1,
          attribute2            = X_attribute2,
          attribute3            = X_attribute3,
          attribute4            = X_attribute4,
          attribute5            = X_attribute5,
          attribute6            = X_attribute6,
          attribute7            = X_attribute7,
          attribute8            = X_attribute8,
          attribute9            = X_attribute9,
          attribute10           = X_attribute10,
          attribute11           = X_attribute11,
          attribute12           = X_attribute12,
          attribute13           = X_attribute13,
          attribute14           = X_attribute14,
          attribute15           = X_attribute15
      WHERE rowid = X_rowid;

    IF (SQL%NOTFOUND) then
      raise NO_DATA_FOUND;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (SQLCODE = -54) THEN
        FND_MESSAGE.SET_NAME('AR', 'AR_RESOURCE_BUSY');
      ELSE
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR','SQLERRM');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Rowid = '||X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Row;

  PROCEDURE delete_row
      (X_rowid                      VARCHAR2,
       X_calling_sequence       IN  VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.DELETE_ROW<-' ||
                                X_calling_sequence;
    debug_info:= 'Delete into JL_ZZ_AR_TX_NAT_RAT';
    DELETE FROM jl_zz_ar_tx_nat_rat
    WHERE  rowid = X_rowid;

    IF (sql%notfound) THEN
      raise NO_DATA_FOUND;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (SQLCODE = -54) THEN
        FND_MESSAGE.SET_NAME('AR', 'AR_RESOURCE_BUSY');
      ELSE
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR','SQLERRM');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Rowid = '||X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END delete_row;

  PROCEDURE check_unique
       (X_rowid                    VARCHAR2,
        X_tax_categ_attr_val_id    NUMBER,
        X_end_date_active          DATE,
        X_org_id                   NUMBER,
        X_calling_sequence      IN VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.Check Unique<-' ||
                                X_calling_sequence;

    debug_info:= 'Check Unique';

    SELECT COUNT(1)
    INTO l_dummy
    FROM JL_ZZ_AR_TX_NAT_RAT
    WHERE tax_categ_attr_val_id = X_tax_categ_attr_val_id
    AND end_date_active = X_end_date_active
    AND org_id = X_org_id
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid));

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_categ_attr_val_id = '||TO_CHAR(X_tax_categ_attr_val_id)||
                            ' end_date_active = '|| TO_CHAR(X_end_date_active,'YYYY/MM/DD')||
                            'Rowid = '||X_Rowid);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END check_unique;

  PROCEDURE Check_Overlapped_Dates
       (X_rowid                    VARCHAR2,
        X_tax_categ_attr_val_id    NUMBER,
        X_end_date_active          DATE,
        X_start_date_active        DATE,
        X_org_id                   NUMBER,
        X_calling_sequence      IN VARCHAR2) IS

    l_dummy                  NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.<-CHECK_OVERLAPPED_DATES' ||
                                X_calling_sequence;
    debug_info:= 'Check Overlapped dates';

    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_nat_rat   a
    WHERE a.tax_categ_attr_val_id = X_tax_categ_attr_val_id
    AND ((a.end_date_active <= X_end_date_active AND
          a.end_date_active >= X_start_date_active) OR
         (a.start_date_active <= X_end_date_active AND
          a.start_date_active >= X_start_date_active) OR
         (a.start_date_active <= X_start_date_active AND
          a.end_date_active >= X_end_date_active))
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid))
    AND org_id = X_org_id;

    IF (l_dummy >=1) THEN
      FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' tax_categ_attr_val_id = ' || to_char(X_tax_categ_attr_val_id)||
                            ' end_date_active = ' || X_end_date_active ||
                            ' start_date_active = ' || X_start_date_active );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Overlapped_Dates;

  PROCEDURE Check_Gaps
       (X_rowid                    VARCHAR2,
        X_tax_categ_attr_val_id    NUMBER,
        X_end_date_active          DATE,
        X_start_date_active        DATE,
        X_org_id                   NUMBER,
        X_calling_sequence      IN VARCHAR2) IS

    l_dummy                  NUMBER;
    l_dummy1                 NUMBER;
    l_dummy2                 NUMBER;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_NAT_RAT_PKG.CHECK_GAPS<-' ||
                                X_calling_sequence;
    --
    --  Check if there is one row with it's end date exactly one day
    --  less than the current row's start date
    --
    SELECT COUNT(1)
    INTO l_dummy
    FROM jl_zz_ar_tx_nat_rat  a
    WHERE a.tax_categ_attr_val_id = X_tax_categ_attr_val_id
    AND trunc(a.end_date_active) = (trunc(X_start_date_active) -1)
    AND org_id = X_org_id
    AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy = 0) THEN
      BEGIN
        --
        --    Check if there is one row with the start date one day more than the
        --    the current row's end-date
        --
        SELECT COUNT(1)
        INTO l_dummy1
        FROM jl_zz_ar_tx_nat_rat  a
        WHERE a.tax_categ_attr_val_id = X_tax_categ_attr_val_id
        AND (trunc(a.start_date_active) = (trunc(X_end_date_active) + 1))
        AND org_id = X_org_id
        AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));
        --
        -- Check if there are no (other) rows at all for the primary key.
        -- If there are no rows, then it is not an error.  Otherwise, it is.
        --
        IF (l_dummy1 = 0) THEN
          BEGIN
            SELECT COUNT(1)
            INTO l_dummy2
            FROM jl_zz_ar_tx_nat_rat  a
            WHERE a.tax_categ_attr_val_id = X_tax_categ_attr_val_id
            AND org_id = X_org_id
            AND ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

            IF (l_dummy2 <> 0) THEN
              FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                    ' tax_categ_attr_val_id = '||to_char(X_tax_categ_attr_val_id)||
                                    ' end_date_active = ' || X_end_date_active ||
                                    ' start_date_active = ' || X_start_date_active );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
              APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
          END;
        END IF;
      END;
    END IF;
  END Check_Gaps;

END JL_ZZ_AR_TX_NAT_RAT_PKG;

/
