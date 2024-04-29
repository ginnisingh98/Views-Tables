--------------------------------------------------------
--  DDL for Package Body CE_STAT_LINES_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_STAT_LINES_DML_PKG" as
/* $Header: cestlthb.pls 120.5.12010000.3 2009/12/02 08:17:15 ckansara ship $ */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.5.12010000.3 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(
        X_Row_Id                IN OUT NOCOPY VARCHAR2,
        X_statement_line_id     IN OUT NOCOPY NUMBER,
		X_statement_header_id   IN OUT NOCOPY NUMBER,
        X_line_number           NUMBER,
        X_trx_date              DATE,
        X_trx_type              VARCHAR2,
        X_trx_status            VARCHAR2,
        X_trx_code              VARCHAR2,  --5131976
        X_effective_date        IN OUT NOCOPY DATE,
        X_bank_trx_number       VARCHAR2,
        X_trx_text              VARCHAR2,
        X_customer_text         VARCHAR2,
        X_invoice_text          VARCHAR2,
        X_bank_account_text     VARCHAR2,
        X_amount                NUMBER,
        X_charges_amount        NUMBER,
        X_status                VARCHAR2,
        X_created_by            NUMBER,
        X_creation_date         DATE,
        X_last_updated_by       NUMBER,
        X_last_update_date      DATE,
        X_currency_code         VARCHAR2,
        X_original_amount       NUMBER,
        X_exchange_rate         NUMBER,
        X_exchange_rate_type    VARCHAR2,
        X_exchange_rate_date    DATE,
        X_attribute_category    VARCHAR2,
        X_attribute1            VARCHAR2,
        X_attribute2            VARCHAR2,
        X_attribute3            VARCHAR2,
        X_attribute4            VARCHAR2,
        X_attribute5            VARCHAR2,
        X_attribute6            VARCHAR2,
        X_attribute7            VARCHAR2,
        X_attribute8            VARCHAR2,
        X_attribute9            VARCHAR2,
        X_attribute10           VARCHAR2,
        X_attribute11           VARCHAR2,
        X_attribute12           VARCHAR2,
        X_attribute13           VARCHAR2,
        X_attribute14           VARCHAR2,
        X_attribute15           VARCHAR2,
    --5916290: GDF Changes
        X_global_att_category   VARCHAR2,
        X_global_attribute1     VARCHAR2,
        X_global_attribute2     VARCHAR2,
        X_global_attribute3     VARCHAR2,
        X_global_attribute4     VARCHAR2,
        X_global_attribute5     VARCHAR2,
        X_global_attribute6     VARCHAR2,
        X_global_attribute7     VARCHAR2,
        X_global_attribute8     VARCHAR2,
        X_global_attribute9     VARCHAR2,
        X_global_attribute10    VARCHAR2,
        X_global_attribute11    VARCHAR2,
        X_global_attribute12    VARCHAR2,
        X_global_attribute13    VARCHAR2,
        X_global_attribute14    VARCHAR2,
        X_global_attribute15    VARCHAR2,
        X_global_attribute16    VARCHAR2,
        X_global_attribute17    VARCHAR2,
        X_global_attribute18    VARCHAR2,
        X_global_attribute19    VARCHAR2,
        X_global_attribute20    VARCHAR2
        ) IS
        CURSOR C IS SELECT rowid FROM CE_STATEMENT_LINES
                 WHERE statement_line_id = X_Statement_line_Id;
    CURSOR C1 IS SELECT ce_statement_lines_s.nextval from sys.dual;
        CURSOR C2 IS SELECT NVL(MAX(line_number),0) + 10 FROM CE_STATEMENT_LINES
                     WHERE statement_header_id = X_statement_header_Id;
        CURSOR C3 IS SELECT ce_statement_headers_s.nextval FROM sys.dual;
        sl_number    NUMBER;
        line_type    VARCHAR2(20);
        line_amount  NUMBER;
    p_float_days DATE;
    dates_out_of_range      EXCEPTION;
      PRAGMA EXCEPTION_INIT(dates_out_of_range, -01841);


   BEGIN
    --
    -- Determine new line number
    --
    IF( X_line_number IS NULL ) THEN
      OPEN C2;
      FETCH C2 INTO sl_number;
      CLOSE C2;
    ELSE
      sl_number := X_line_number;
    END IF;
    --
    -- X_statement_header would be NULL if passing from manual form, and header
    -- is created on the fly
    --
    IF ( X_statement_header_id IS NULL) THEN
      OPEN C3;
      FETCH C3 INTO X_statement_header_id;
      CLOSE C3;
    END IF;
    --
    -- Determine a new statement_line_id
    --
    IF( X_statement_line_id IS NULL ) THEN
      OPEN C1;
      FETCH C1 into X_statement_line_id;
      CLOSE C1;
    END IF;
    --
    -- Determine the trx type of the statement line to be created
    -- First check status of transaction, if 'STOP'/'VOID' check, create 'STOP' stmt line
    -- If 'REVERSED' receipt, create 'NSF' stmt line.
    --
    IF( X_trx_status IN ( 'STOP INITIATED', 'VOIDED', 'V' )) THEN
      line_type := 'STOP';
    ELSIF( X_trx_status = 'REVERSED' ) THEN
      line_type := 'NSF';
    --
    -- Then, if create line from ARP_AUTO_BANK_CLEAR.reconcile_trx (from stmt header)
    -- X_trx_type is the type of transaction, which can be PAYMENT/CASH/RECEIPT/MISC
    --
    ELSIF( X_trx_type IN ('PAYMENT','PBATCH')) THEN
      line_type := 'DEBIT';
    ELSIF( X_trx_type IN ('CASH', 'RECEIPT','RBATCH')) THEN
      line_type := 'CREDIT';
      -- bug 5072557  -- remittance batches with negative amounts,
      --                 set stmt ln type to misc payment
      IF ((X_trx_type = 'RECEIPT') and ( X_original_amount < 0 ))  THEN
        line_type := 'MISC_DEBIT';
      END IF;
    ELSIF( X_trx_type = 'MISC' ) THEN
      IF( X_original_amount > 0 ) THEN
        line_type := 'MISC_CREDIT';
        line_amount := X_amount;
      ELSE
        line_type := 'MISC_DEBIT';
        line_amount := -(X_amount);
      END IF;
    --
    -- Last, create line from stmt line, which X_trx_type is the line defined by the user
    --
    ELSE
    line_type := X_trx_type;
        line_amount := X_amount;
    END IF;
    --
    -- If X_effective_date is NULL and X_trx_code IS NOT NULL, determine the effective_date
    -- by the float date of the X_trx_code
    --

    IF(X_effective_date IS NULL) THEN
      X_effective_date := X_trx_date;
    /* bug 4435028 BAT: cannot get float_days, there can be multiple rows for each trx_code
      IF(X_trx_code_id IS NULL) THEN
    X_effective_date := X_trx_date;
      ELSE
      BEGIN
    SELECT  X_trx_date + float_days
    INTO    X_effective_date
    FROM    ce_transaction_codes
    WHERE   transaction_code_id = X_trx_code_id;
      EXCEPTION
    WHEN dates_out_of_range THEN
    X_effective_date := NULL;
      END;
      END IF;
    */
    END IF;
    --
    INSERT INTO CE_STATEMENT_LINES
         (statement_line_id,
         statement_header_id,
         line_number,
         trx_date,
         trx_type,
         trx_code,
         effective_date,
         bank_trx_number,
         trx_text,
         customer_text,
         invoice_text,
         bank_account_text,
         amount,
         charges_amount,
         status,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         currency_code,
         original_amount,
         exchange_rate,
         exchange_rate_type,
         exchange_rate_date,
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
         attribute15,
    -- 5916290: GDF Changes
         global_attribute_category,
         global_attribute1,
         global_attribute2,
         global_attribute3,
         global_attribute4,
         global_attribute5,
         global_attribute6,
         global_attribute7,
         global_attribute8,
         global_attribute9,
         global_attribute10,
         global_attribute11,
         global_attribute12,
         global_attribute13,
         global_attribute14,
         global_attribute15,
         global_attribute16,
         global_attribute17,
         global_attribute18,
         global_attribute19,
         global_attribute20
         ) VALUES (
         X_statement_line_id,
         X_statement_header_id,
         sl_number,
         X_trx_date,
         line_type,
         X_trx_code,
         X_effective_date,
         X_bank_trx_number,
         X_trx_text,
         X_customer_text,
         X_invoice_text,
         X_bank_account_text,
         NVL(line_amount, X_amount),
         X_charges_amount,
         X_status,
         X_created_by,
         X_creation_date,
         X_last_updated_by,
         X_last_update_date,
         X_currency_code,
         abs(X_original_amount),
         X_exchange_rate,
         X_exchange_rate_type,
         X_exchange_rate_date,
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
         X_attribute15,
         X_global_att_category,
         X_global_attribute1,
         X_global_attribute2,
         X_global_attribute3,
         X_global_attribute4,
         X_global_attribute5,
         X_global_attribute6,
         X_global_attribute7,
         X_global_attribute8,
         X_global_attribute9,
         X_global_attribute10,
         X_global_attribute11,
         X_global_attribute12,
         X_global_attribute13,
         X_global_attribute14,
         X_global_attribute15,
         X_global_attribute16,
         X_global_attribute17,
         X_global_attribute18,
         X_global_attribute19,
         X_global_attribute20);
    OPEN C;
    FETCH C INTO X_Row_Id;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END insert_row;

  PROCEDURE Delete_Row( X_Row_Id VARCHAR2 ) IS
  L_STMT_LINE_ID CE_STATEMENT_LINES.STATEMENT_LINE_ID%TYPE; -- Bug 9099087
  BEGIN
    -- Bug 9099087 Start
	SELECT STATEMENT_LINE_ID INTO L_STMT_LINE_ID
	FROM CE_STATEMENT_LINES
    WHERE rowid = X_Row_Id;

	DELETE FROM CE_STATEMENT_RECONCILS_ALL
	WHERE STATEMENT_LINE_ID = L_STMT_LINE_ID;

	-- Bug 9099087 Start

    DELETE FROM CE_STATEMENT_LINES
    WHERE rowid = X_Row_Id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Update_Row (
        X_Row_Id                VARCHAR2,
        X_statement_line_id     NUMBER,
        X_statement_header_id   NUMBER,
        X_line_number           NUMBER,
        X_trx_date              DATE,
        X_trx_type              VARCHAR2,
        X_trx_code              VARCHAR2, --5131976
        X_effective_date        DATE,
        X_bank_trx_number       VARCHAR2,
        X_trx_text              VARCHAR2,
        X_customer_text         VARCHAR2,
        X_invoice_text          VARCHAR2,
        X_bank_account_text     VARCHAR2,
        X_amount                NUMBER,
        X_charges_amount        NUMBER,
        X_status                VARCHAR2,
        X_last_updated_by       NUMBER,
        X_last_update_date      DATE,
        X_attribute_category    VARCHAR2,
        X_original_amount       NUMBER,
        X_currency_code         VARCHAR2,
        X_exchange_rate         NUMBER,
        X_exchange_rate_type    VARCHAR2,
        X_exchange_rate_date    DATE,
        X_attribute1            VARCHAR2,
        X_attribute2            VARCHAR2,
        X_attribute3            VARCHAR2,
        X_attribute4            VARCHAR2,
        X_attribute5            VARCHAR2,
        X_attribute6            VARCHAR2,
        X_attribute7            VARCHAR2,
        X_attribute8            VARCHAR2,
        X_attribute9            VARCHAR2,
        X_attribute10           VARCHAR2,
        X_attribute11           VARCHAR2,
        X_attribute12           VARCHAR2,
        X_attribute13           VARCHAR2,
        X_attribute14           VARCHAR2,
        X_attribute15           VARCHAR2,
    --5916290: GDF Changes
        X_global_att_category   VARCHAR2,
        X_global_attribute1     VARCHAR2,
        X_global_attribute2     VARCHAR2,
        X_global_attribute3     VARCHAR2,
        X_global_attribute4     VARCHAR2,
        X_global_attribute5     VARCHAR2,
        X_global_attribute6     VARCHAR2,
        X_global_attribute7     VARCHAR2,
        X_global_attribute8     VARCHAR2,
        X_global_attribute9     VARCHAR2,
        X_global_attribute10    VARCHAR2,
        X_global_attribute11    VARCHAR2,
        X_global_attribute12    VARCHAR2,
        X_global_attribute13    VARCHAR2,
        X_global_attribute14    VARCHAR2,
        X_global_attribute15    VARCHAR2,
        X_global_attribute16    VARCHAR2,
        X_global_attribute17    VARCHAR2,
        X_global_attribute18    VARCHAR2,
        X_global_attribute19    VARCHAR2,
        X_global_attribute20    VARCHAR2
        ) IS
  BEGIN
    UPDATE CE_STATEMENT_LINES
    SET
       statement_line_id = X_statement_line_id,
       statement_header_id = X_statement_header_id,
       line_number = X_line_number,
       trx_date = X_trx_date,
       trx_type = X_trx_type,
       trx_code = X_trx_code,
       effective_date = X_effective_date,
       bank_trx_number = X_bank_trx_number,
       trx_text = X_trx_text,
       customer_text = X_customer_text,
       invoice_text = X_invoice_text,
       bank_account_text = X_bank_account_text,
       amount = X_amount,
       charges_amount= X_charges_amount,
       status = X_status,
       last_updated_by = X_last_updated_by,
       last_update_date = X_last_update_date,
       attribute_category = X_attribute_category,
       original_amount = X_original_amount,
       currency_code = X_currency_code,
       exchange_rate = X_exchange_rate,
       exchange_rate_type = X_exchange_rate_type,
       exchange_rate_date = X_exchange_rate_date,
       attribute1 = X_attribute1,
       attribute2 = X_attribute2,
       attribute3 = X_attribute3,
       attribute4 = X_attribute4,
       attribute5 = X_attribute5,
       attribute6 = X_attribute6,
       attribute7 = X_attribute7,
       attribute8 = X_attribute8,
       attribute9 = X_attribute9,
       attribute10 = X_attribute10,
       attribute11 = X_attribute11,
       attribute12 = X_attribute12,
       attribute13 = X_attribute13,
       attribute14 = X_attribute14,
       attribute15 = X_attribute15,
    --Bug 6899211
       global_attribute_category = X_global_att_category,
    --5916290: GDF Changes
       global_attribute1 = X_global_attribute1,
       global_attribute2 = X_global_attribute2,
       global_attribute3 = X_global_attribute3,
       global_attribute4 = X_global_attribute4,
       global_attribute5 = X_global_attribute5,
       global_attribute6 = X_global_attribute6,
       global_attribute7 = X_global_attribute7,
       global_attribute8 = X_global_attribute8,
       global_attribute9 = X_global_attribute9,
       global_attribute10 = X_global_attribute10,
       global_attribute11 = X_global_attribute11,
       global_attribute12 = X_global_attribute12,
       global_attribute13 = X_global_attribute13,
       global_attribute14 = X_global_attribute14,
       global_attribute15 = X_global_attribute15,
       global_attribute16 = X_global_attribute16,
       global_attribute17 = X_global_attribute17,
       global_attribute18 = X_global_attribute18,
       global_attribute19 = X_global_attribute19,
       global_attribute20 = X_global_attribute20
    WHERE rowid = X_Row_Id;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Lock_Row(
        X_Row_Id                VARCHAR2,
        X_statement_line_id     NUMBER,
        X_statement_header_id   NUMBER,
        X_line_number           NUMBER,
        X_trx_date              DATE,
        X_trx_type              VARCHAR2,
        X_trx_code              VARCHAR2, --5131976
        X_effective_date        DATE,
        X_bank_trx_number       VARCHAR2,
        X_trx_text              VARCHAR2,
        X_customer_text         VARCHAR2,
        X_invoice_text          VARCHAR2,
        X_bank_account_text     VARCHAR2,
        X_amount                NUMBER,
        X_charges_amount        NUMBER,
        X_status                VARCHAR2,
        X_original_amount       NUMBER,
        X_currency_code         VARCHAR2,
        X_exchange_rate         NUMBER,
        X_exchange_rate_type    VARCHAR2,
        X_exchange_rate_date    DATE,
        X_attribute_category    VARCHAR2,
        X_attribute1            VARCHAR2,
        X_attribute2            VARCHAR2,
        X_attribute3            VARCHAR2,
        X_attribute4            VARCHAR2,
        X_attribute5            VARCHAR2,
        X_attribute6            VARCHAR2,
        X_attribute7            VARCHAR2,
        X_attribute8            VARCHAR2,
        X_attribute9            VARCHAR2,
        X_attribute10           VARCHAR2,
        X_attribute11           VARCHAR2,
        X_attribute12           VARCHAR2,
        X_attribute13           VARCHAR2,
        X_attribute14           VARCHAR2,
        X_attribute15           VARCHAR2,
    --5916290: GDF Changes
        X_global_att_category   VARCHAR2,
        X_global_attribute1     VARCHAR2,
        X_global_attribute2     VARCHAR2,
        X_global_attribute3     VARCHAR2,
        X_global_attribute4     VARCHAR2,
        X_global_attribute5     VARCHAR2,
        X_global_attribute6     VARCHAR2,
        X_global_attribute7     VARCHAR2,
        X_global_attribute8     VARCHAR2,
        X_global_attribute9     VARCHAR2,
        X_global_attribute10    VARCHAR2,
        X_global_attribute11    VARCHAR2,
        X_global_attribute12    VARCHAR2,
        X_global_attribute13    VARCHAR2,
        X_global_attribute14    VARCHAR2,
        X_global_attribute15    VARCHAR2,
        X_global_attribute16    VARCHAR2,
        X_global_attribute17    VARCHAR2,
        X_global_attribute18    VARCHAR2,
        X_global_attribute19    VARCHAR2,
        X_global_attribute20    VARCHAR2
        ) IS
    CURSOR C IS
    SELECT *
    FROM CE_STATEMENT_LINES
    WHERE rowid = X_Row_Id
    FOR UPDATE OF statement_line_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.raise_exception;
    END IF;
    CLOSE C;
    if (
           (Recinfo.statement_line_id = X_statement_line_id )
       AND (Recinfo.statement_header_id = X_statement_header_id )
       AND (Recinfo.line_number = X_line_number )
       AND (Recinfo.trx_date = X_trx_date )
       AND (Recinfo.trx_type = X_trx_type )
       AND (Recinfo.amount = X_amount )
       AND (Recinfo.status = X_status )
       AND (    (   (Recinfo.trx_code = X_trx_code )
             OR (    (Recinfo.trx_code IS NULL)
                 AND (X_trx_code IS NULL))))
       AND (    (   (Recinfo.effective_date = X_effective_date )
             OR (    (Recinfo.effective_date IS NULL)
                 AND (X_effective_date IS NULL))))
       AND (    (   (Recinfo.bank_trx_number = X_bank_trx_number )
             OR (    (Recinfo.bank_trx_number IS NULL)
                 AND (X_bank_trx_number IS NULL))))
       AND (    (   (Recinfo.trx_text = X_trx_text )
             OR (    (Recinfo.trx_text IS NULL)
                 AND (X_trx_text IS NULL))))
       AND (    (   (Recinfo.customer_text = X_customer_text )
             OR (    (Recinfo.customer_text IS NULL)
                 AND (X_customer_text IS NULL))))
       AND (    (   (Recinfo.invoice_text = X_invoice_text )
             OR (    (Recinfo.invoice_text IS NULL)
                 AND (X_invoice_text IS NULL))))
       AND (    (   (Recinfo.bank_account_text = X_bank_account_text )
             OR (    (Recinfo.bank_account_text IS NULL)
                 AND (X_bank_account_text IS NULL))))
       AND  (    (   (Recinfo.original_amount = X_original_amount )
             OR (    (Recinfo.original_amount IS NULL)
                 AND (X_original_amount IS NULL))))
       AND  (    (   (Recinfo.charges_amount = X_charges_amount )
             OR (    (Recinfo.charges_amount IS NULL)
                 AND (X_charges_amount IS NULL))))
       AND (    (   (Recinfo.currency_code = X_currency_code )
             OR (    (Recinfo.currency_code IS NULL)
                 AND (X_currency_code IS NULL))))
       AND (    (   (Recinfo.exchange_rate = X_exchange_rate )
             OR (    (Recinfo.exchange_rate IS NULL)
                 AND (X_exchange_rate IS NULL))))
       AND (    (   (Recinfo.exchange_rate_type = X_exchange_rate_type )
             OR (    (Recinfo.exchange_rate_type IS NULL)
                 AND (X_exchange_rate_type IS NULL))))
       AND (    (   (Recinfo.exchange_rate_date = X_exchange_rate_date )
             OR (    (Recinfo.exchange_rate_date IS NULL)
                 AND (X_exchange_rate_date IS NULL))))
       AND (    (   (Recinfo.attribute_category = X_attribute_category )
             OR (    (Recinfo.attribute_category IS NULL)
                 AND (X_attribute_category IS NULL))))
       AND (    (   (Recinfo.attribute1 = X_attribute1 )
             OR (    (Recinfo.attribute1 IS NULL)
                 AND (X_attribute1 IS NULL))))
       AND (    (   (Recinfo.attribute2 = X_attribute2 )
             OR (    (Recinfo.attribute2 IS NULL)
                 AND (X_attribute2 IS NULL))))
       AND (    (   (Recinfo.attribute3 = X_attribute3 )
             OR (    (Recinfo.attribute3 IS NULL)
                 AND (X_attribute3 IS NULL))))
       AND (    (   (Recinfo.attribute4 = X_attribute4 )
             OR (    (Recinfo.attribute4 IS NULL)
                 AND (X_attribute4 IS NULL))))
       AND (    (   (Recinfo.attribute5 = X_attribute5 )
             OR (    (Recinfo.attribute5 IS NULL)
                 AND (X_attribute5 IS NULL))))
       AND (    (   (Recinfo.attribute6 = X_attribute6 )
             OR (    (Recinfo.attribute6 IS NULL)
                 AND (X_attribute6 IS NULL))))
       AND (    (   (Recinfo.attribute7 = X_attribute7 )
             OR (    (Recinfo.attribute7 IS NULL)
                 AND (X_attribute7 IS NULL))))
       AND (    (   (Recinfo.attribute8 = X_attribute8 )
             OR (    (Recinfo.attribute8 IS NULL)
                 AND (X_attribute8 IS NULL))))
       AND (    (   (Recinfo.attribute9 = X_attribute9 )
             OR (    (Recinfo.attribute9 IS NULL)
                 AND (X_attribute9 IS NULL))))
       AND (    (   (Recinfo.attribute10 = X_attribute10 )
             OR (    (Recinfo.attribute10 IS NULL)
                 AND (X_attribute10 IS NULL))))
       AND (    (   (Recinfo.attribute11 = X_attribute11 )
             OR (    (Recinfo.attribute11 IS NULL)
                 AND (X_attribute11 IS NULL))))
       AND (    (   (Recinfo.attribute12 = X_attribute12 )
             OR (    (Recinfo.attribute12 IS NULL)
                 AND (X_attribute12 IS NULL))))
       AND (    (   (Recinfo.attribute13 = X_attribute13 )
             OR (    (Recinfo.attribute13 IS NULL)
                 AND (X_attribute13 IS NULL))))
       AND (    (   (Recinfo.attribute14 = X_attribute14 )
             OR (    (Recinfo.attribute14 IS NULL)
                 AND (X_attribute14 IS NULL))))
       AND (    (   (Recinfo.attribute15 = X_attribute15 )
             OR (    (Recinfo.attribute15 IS NULL)
                 AND (X_attribute15 IS NULL))))
    --5916290: GDF Changes
       AND (    (   (Recinfo.global_attribute_category = X_global_att_category)
        OR (    (Recinfo.global_attribute_category IS NULL)
           AND (X_global_att_category IS NULL))))
       AND (    (   (Recinfo.global_attribute1 = X_global_attribute1)
        OR (    (Recinfo.global_attribute1 IS NULL)
           AND (X_global_attribute1 IS NULL))))
       AND (    (   (Recinfo.global_attribute2 = X_global_attribute2)
        OR (    (Recinfo.global_attribute2 IS NULL)
           AND (X_global_attribute2 IS NULL))))
       AND (    (   (Recinfo.global_attribute3 = X_global_attribute3)
        OR (    (Recinfo.global_attribute3 IS NULL)
           AND (X_global_attribute3 IS NULL))))
       AND (    (   (Recinfo.global_attribute4 = X_global_attribute4)
        OR (    (Recinfo.global_attribute4 IS NULL)
           AND (X_global_attribute4 IS NULL))))
       AND (    (   (Recinfo.global_attribute5 = X_global_attribute5)
        OR (    (Recinfo.global_attribute5 IS NULL)
           AND (X_global_attribute5 IS NULL))))
       AND (    (   (Recinfo.global_attribute6 = X_global_attribute6)
        OR (    (Recinfo.global_attribute6 IS NULL)
           AND (X_global_attribute6 IS NULL))))
       AND (    (   (Recinfo.global_attribute7 = X_global_attribute7)
        OR (    (Recinfo.global_attribute7 IS NULL)
           AND (X_global_attribute7 IS NULL))))
       AND (    (   (Recinfo.global_attribute8 = X_global_attribute8)
        OR (    (Recinfo.global_attribute8 IS NULL)
           AND (X_global_attribute8 IS NULL))))
       AND (    (   (Recinfo.global_attribute9 = X_global_attribute9)
        OR (    (Recinfo.global_attribute9 IS NULL)
           AND (X_global_attribute9 IS NULL))))
       AND (    (   (Recinfo.global_attribute10 = X_global_attribute10)
        OR (    (Recinfo.global_attribute10 IS NULL)
           AND (X_global_attribute10 IS NULL))))
       AND (    (   (Recinfo.global_attribute11 = X_global_attribute11)
        OR (    (Recinfo.global_attribute11 IS NULL)
           AND (X_global_attribute11 IS NULL))))
       AND (    (   (Recinfo.global_attribute12 = X_global_attribute12)
        OR (    (Recinfo.global_attribute12 IS NULL)
           AND (X_global_attribute12 IS NULL))))
       AND (    (   (Recinfo.global_attribute13 = X_global_attribute13)
        OR (    (Recinfo.global_attribute13 IS NULL)
           AND (X_global_attribute13 IS NULL))))
       AND (    (   (Recinfo.global_attribute14 = X_global_attribute14)
        OR (    (Recinfo.global_attribute14 IS NULL)
           AND (X_global_attribute14 IS NULL))))
       AND (    (   (Recinfo.global_attribute15 = X_global_attribute15)
        OR (    (Recinfo.global_attribute15 IS NULL)
           AND (X_global_attribute15 IS NULL))))
       AND (    (   (Recinfo.global_attribute16 = X_global_attribute16)
        OR (    (Recinfo.global_attribute16 IS NULL)
           AND (X_global_attribute16 IS NULL))))
       AND (    (   (Recinfo.global_attribute17 = X_global_attribute17)
        OR (    (Recinfo.global_attribute17 IS NULL)
           AND (X_global_attribute17 IS NULL))))
       AND (    (   (Recinfo.global_attribute18 = X_global_attribute18)
        OR (    (Recinfo.global_attribute18 IS NULL)
           AND (X_global_attribute18 IS NULL))))
       AND (    (   (Recinfo.global_attribute19 = X_global_attribute19)
        OR (    (Recinfo.global_attribute19 IS NULL)
           AND (X_global_attribute19 IS NULL))))
       AND (    (   (Recinfo.global_attribute20 = X_global_attribute20)
        OR (    (Recinfo.global_attribute20 IS NULL)
           AND (X_global_attribute20 IS NULL))))
       ) THEN
        return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.raise_exception;
    END IF;
  END Lock_Row;

END CE_STAT_LINES_DML_PKG;

/
