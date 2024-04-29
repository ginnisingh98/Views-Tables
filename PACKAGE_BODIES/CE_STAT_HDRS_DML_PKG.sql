--------------------------------------------------------
--  DDL for Package Body CE_STAT_HDRS_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_STAT_HDRS_DML_PKG" as
/* $Header: cesththb.pls 120.9.12000000.2 2007/07/27 10:41:46 csutaria ship $ */

        G_action_flag            varchar2(2);
        G_xtr_company_code       varchar2(100);
        G_xtr_acct_number        varchar2(100);


  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.9.12000000.2 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(
            X_rowid                 IN OUT NOCOPY  VARCHAR2,
            X_statement_header_id   IN OUT NOCOPY NUMBER,
            X_bank_account_id       NUMBER,
            X_statement_number      VARCHAR2,
            X_statement_date        DATE,
            X_check_digits          VARCHAR2,
            X_control_begin_balance NUMBER,
            X_control_end_balance   NUMBER,
            X_cashflow_balance      NUMBER,
            X_int_calc_balance      NUMBER,
            X_one_day_float         NUMBER,
            X_two_day_float         NUMBER,
            X_control_total_dr      NUMBER,
            X_control_total_cr      NUMBER,
            X_control_dr_line_count NUMBER,
            X_control_cr_line_count NUMBER,
            X_doc_sequence_id       NUMBER,
            X_doc_sequence_value    NUMBER,
            X_created_by            NUMBER,
            X_creation_date         DATE,
            X_last_updated_by       NUMBER,
            X_last_update_date      DATE,
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
            X_auto_loaded_flag      VARCHAR2,
            X_statement_complete_flag   VARCHAR2,
            X_gl_date               DATE,
            X_balance_flag          VARCHAR2 DEFAULT 'N',
            X_average_close_ledger_mtd      NUMBER DEFAULT NULL,
            X_average_close_ledger_ytd      NUMBER DEFAULT NULL,
            X_average_close_available_mtd   NUMBER DEFAULT NULL,
            X_average_close_available_ytd   NUMBER DEFAULT NULL,
            X_bank_acct_balance_id          NUMBER DEFAULT NULL,
        -- 5916290: GDF Changes
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
    p_bank_acct_balance_id  number;
    p_xtr_val           boolean;
    CURSOR C IS SELECT rowid
        FROM CE_STATEMENT_HEADERS
            WHERE statement_header_id = X_Statement_Header_Id;
    CURSOR C2 IS SELECT CE_STATEMENT_HEADERS_S.nextval FROM SYS.dual;
    CURSOR C3 IS SELECT CE_BANK_ACCT_BALANCES_S.nextval FROM SYS.dual;
   BEGIN
      IF (X_statement_header_id IS NULL) THEN
        OPEN C2;
        FETCH C2 INTO X_statement_header_id;
        CLOSE C2;
      END IF;
      INSERT INTO CE_STATEMENT_HEADERS (
                statement_header_id,
                bank_account_id,
                statement_number,
                statement_date,
                check_digits,
                control_begin_balance,
                control_end_balance,
                cashflow_balance,
                int_calc_balance,
                one_day_float,
                two_day_float,
                control_total_dr,
                control_total_cr,
                control_dr_line_count,
                control_cr_line_count,
                doc_sequence_id,
                doc_sequence_value,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
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
                auto_loaded_flag,
                statement_complete_flag,
                gl_date,
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
                global_attribute20) VALUES
                (X_statement_header_id,
                X_bank_account_id,
                X_statement_number,
                X_statement_date,
                X_check_digits,
                X_control_begin_balance,
                X_control_end_balance,
                X_cashflow_balance,
                X_int_calc_balance,
                X_one_day_float,
                X_two_day_float,
                X_control_total_dr,
                X_control_total_cr,
                X_control_dr_line_count,
                X_control_cr_line_count,
                X_doc_sequence_id,
                X_doc_sequence_value,
                X_created_by,
                X_creation_date,
                X_last_updated_by,
                X_last_update_date,
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
                X_auto_loaded_flag,
                X_statement_complete_flag,
                X_gl_date,
        -- 5916290: GDF Changes
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

    IF X_balance_flag in ('N','NM') THEN
        IF X_bank_acct_balance_id IS NULL THEN
            OPEN C3;
            FETCH C3 INTO p_bank_acct_balance_id;
            CLOSE C3;
        ELSE
            p_bank_acct_balance_id := X_bank_acct_balance_id;
        END IF;
    --if ((p_xtr_val and x_balance_flag= 'N') or x_balance_flag = 'NM') then
        INSERT INTO CE_BANK_ACCT_BALANCES
            (bank_acct_balance_id,
             bank_account_id,
             balance_date,
             ledger_balance,
             available_balance,
             value_dated_balance,
             one_day_float,
             two_day_float,
             average_close_ledger_mtd,
             average_close_ledger_ytd,
             average_close_available_mtd,
             average_close_available_ytd,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             object_version_number)
            values
            (p_bank_acct_balance_id,
             X_bank_account_id,
             X_statement_date,
             X_control_end_balance,
             X_cashflow_balance,
             X_int_calc_balance,
             X_one_day_float,
             X_two_day_float,
             X_average_close_ledger_mtd,
             X_average_close_ledger_ytd,
             X_average_close_available_mtd,
             X_average_close_available_ytd,
             X_last_update_date,
             X_last_updated_by,
             X_creation_date,
             X_created_by,
             X_last_updated_by,
             '1');
    --end if;
    ELSIF X_balance_flag = 'YO' THEN
        UPDATE CE_BANK_ACCT_BALANCES
            SET
            BALANCE_DATE = X_statement_date,
            LEDGER_BALANCE = X_control_end_balance,
            AVAILABLE_BALANCE = X_cashflow_balance,
            VALUE_DATED_BALANCE = X_int_calc_balance,
            ONE_DAY_FLOAT = X_one_day_float,
            TWO_DAY_FLOAT = X_two_day_float,
            LAST_UPDATE_DATE = X_last_update_date,
            LAST_UPDATED_BY = X_last_updated_by,
            LAST_UPDATE_LOGIN = X_last_updated_by
            WHERE
            BANK_ACCOUNT_ID = X_bank_account_id and
            BALANCE_DATE = X_statement_date;
   END IF;

   OPEN C;
   FETCH C INTO X_rowid;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      Raise NO_DATA_FOUND;
   END IF;
   CLOSE C;

  END insert_row;

  PROCEDURE Update_Row( X_Row_id        VARCHAR2,
                X_statement_header_id   NUMBER,
                X_statement_number  VARCHAR2,
                X_statement_date    DATE,
                X_check_digits      VARCHAR2,
                X_control_begin_balance NUMBER,
                X_control_end_balance   NUMBER,
                X_cashflow_balance  NUMBER,
                X_int_calc_balance  NUMBER,
                X_one_day_float     NUMBER,
                X_two_day_float     NUMBER,
                X_control_total_dr  NUMBER,
                X_control_total_cr  NUMBER,
                X_control_dr_line_count NUMBER,
                X_control_cr_line_count NUMBER,
                X_doc_sequence_value    NUMBER,
                X_doc_sequence_id   NUMBER,
                X_last_updated_by   NUMBER,
                X_last_update_date  DATE,
                X_attribute_category    VARCHAR2,
                X_attribute1        VARCHAR2,
                X_attribute2        VARCHAR2,
                X_attribute3        VARCHAR2,
                X_attribute4        VARCHAR2,
                X_attribute5        VARCHAR2,
                X_attribute6        VARCHAR2,
                X_attribute7        VARCHAR2,
                X_attribute8        VARCHAR2,
                X_attribute9        VARCHAR2,
                X_attribute10       VARCHAR2,
                X_attribute11       VARCHAR2,
                X_attribute12       VARCHAR2,
                X_attribute13       VARCHAR2,
                X_attribute14       VARCHAR2,
                X_attribute15       VARCHAR2,
                X_statement_complete_flag VARCHAR2,
                X_gl_date       DATE,
                X_flag          VARCHAR2,
            -- 5916290: GDF Changes
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

  X_bank_account_id NUMBER;
  X_balance_date    DATE;

  BEGIN
    --from headers_event.update_row to override x_flag will be YO
    IF (x_flag = 'YO') THEN
    BEGIN
        SELECT BANK_ACCOUNT_ID,STATEMENT_DATE
        INTO X_bank_account_id,X_Balance_Date
        FROM CE_STATEMENT_HEADERS
        WHERE STATEMENT_HEADER_ID = X_Statement_Header_Id;

            UPDATE CE_BANK_ACCT_BALANCES
        SET
            BALANCE_DATE = X_statement_date,
            LEDGER_BALANCE = X_control_end_balance,
            AVAILABLE_BALANCE = X_cashflow_balance,
            VALUE_DATED_BALANCE = X_int_calc_balance,
            ONE_DAY_FLOAT = X_one_day_float,
            TWO_DAY_FLOAT = X_two_day_float,
            LAST_UPDATE_DATE = X_last_update_date,
            LAST_UPDATED_BY = X_last_updated_by,
            LAST_UPDATE_LOGIN = X_last_updated_by
            WHERE
            BANK_ACCOUNT_ID = X_Bank_Account_ID and
            BALANCE_DATE = X_Balance_Date;
    EXCEPTION
        WHEN OTHERS THEN
        NULL;
    END;
    END IF;

    --
    -- Standard ON-UPDATE routine
    --
    UPDATE CE_STATEMENT_HEADERS
    SET
       statement_header_id = X_statement_header_id,
       statement_number = X_statement_number,
       statement_date = X_statement_date,
       check_digits = X_check_digits,
       control_begin_balance = X_control_begin_balance,
       control_end_balance = X_control_end_balance,
       cashflow_balance = X_cashflow_balance,
       int_calc_balance = X_int_calc_balance,
       one_day_float = X_one_day_float,
       two_day_float = X_two_day_float,
       control_total_dr = X_control_total_dr,
       control_total_cr = X_control_total_cr,
       control_dr_line_count = X_control_dr_line_count,
       control_cr_line_count = X_control_cr_line_count,
       doc_sequence_value = X_doc_sequence_value,
       doc_sequence_id = X_doc_sequence_id,
       last_updated_by = X_last_updated_by,
       last_update_date = X_last_update_date,
       attribute_category = X_attribute_category,
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
       statement_complete_flag = X_statement_complete_flag,
       gl_date = X_gl_date,
    -- 5916290: GDF Changes
       global_attribute_category = X_global_att_category,
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
  END update_row;

  PROCEDURE Delete_Row( X_Row_id VARCHAR2 ) IS
   X_bank_account_id    NUMBER;
   X_balance_date       DATE;

  BEGIN

    /*BEGIN
        SELECT BANK_ACCOUNT_ID,STATEMENT_DATE
        INTO X_bank_account_id,X_balance_date
        FROM CE_STATEMENT_HEADERS
        WHERE rowid = X_Row_Id;

        DELETE FROM CE_BANK_ACCT_BALANCES
            WHERE bank_account_id = X_bank_account_id
            AND   balance_date = X_balance_date;
    EXCEPTION
        WHEN OTHERS THEN
        NULL;
    END;*/

    DELETE FROM CE_STATEMENT_HEADERS
    WHERE rowid = X_Row_Id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Lock_Row(   X_Row_id        VARCHAR2,
                    X_statement_header_id   NUMBER,
                    X_bank_account_id   NUMBER,
                    X_statement_number  VARCHAR2,
                    X_statement_date    DATE,
            X_check_digits          VARCHAR2,
                    X_doc_sequence_id   NUMBER,
                    X_doc_sequence_value    NUMBER,
                    X_control_begin_balance NUMBER,
                    X_control_end_balance   NUMBER,
                    X_cashflow_balance      NUMBER,
                    X_int_calc_balance      NUMBER,
                    X_one_day_float         NUMBER,
                    X_two_day_float         NUMBER,
                    X_control_total_dr      NUMBER,
                    X_control_total_cr      NUMBER,
                    X_control_dr_line_count NUMBER,
                    X_control_cr_line_count NUMBER,
                    X_attribute_category    VARCHAR2,
                    X_attribute1        VARCHAR2,
                    X_attribute2        VARCHAR2,
                    X_attribute3        VARCHAR2,
                    X_attribute4        VARCHAR2,
                    X_attribute5        VARCHAR2,
                    X_attribute6        VARCHAR2,
                    X_attribute7        VARCHAR2,
                    X_attribute8        VARCHAR2,
                    X_attribute9        VARCHAR2,
                    X_attribute10       VARCHAR2,
                    X_attribute11       VARCHAR2,
                    X_attribute12       VARCHAR2,
                    X_attribute13       VARCHAR2,
                    X_attribute14       VARCHAR2,
                    X_attribute15       VARCHAR2,
                    X_auto_loaded_flag  VARCHAR2,
                    X_statement_complete_flag  VARCHAR2,
                    X_gl_date           DATE,
                -- 5916290: GDF Changes
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
        FROM   CE_STATEMENT_HEADERS
        WHERE  rowid = X_Row_Id
        FOR UPDATE of Statement_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;

   /* CURSOR C1 IS
    SELECT *
    FROM CE_BANK_ACCT_BALANCES
    WHERE BANK_ACCOUNT_ID = X_bank_account_id
    AND   BALANCE_DATE = X_statement_date
    FOR UPDATE of BANK_ACCT_BALANCE_ID NOWAIT;
     Recinfo1 C1%ROWTYPE;*/

  BEGIN
     OPEN C;
     FETCH C INTO Recinfo;
     IF (C%NOTFOUND) then
       CLOSE C;
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.raise_exception;
     end if;
     CLOSE C;
    /* OPEN C1;
     FETCH C1 INTO Recinfo1;
     CLOSE C1;*/

     IF (
      (    (   (Recinfo.statement_header_id = X_statement_header_id )
        OR (    (Recinfo.statement_header_id IS NULL)
            AND (X_statement_header_id IS NULL))))
       AND (    (   (Recinfo.bank_account_id = X_bank_account_id )
        OR (    (Recinfo.bank_account_id IS NULL)
            AND (X_bank_account_id IS NULL))))
       AND (    (   (Recinfo.statement_number = X_statement_number )
        OR (    (Recinfo.statement_number IS NULL)
            AND (X_statement_number IS NULL))))
       AND (    (   (Recinfo.statement_date = X_statement_date )
        OR (    (Recinfo.statement_date IS NULL)
            AND (X_statement_date IS NULL))))
       AND (    (   (Recinfo.check_digits = X_check_digits )
    OR (    (Recinfo.check_digits IS NULL)
        AND (X_check_digits IS NULL))))
       AND (    (   (Recinfo.doc_sequence_value = X_doc_sequence_value )
        OR (    (Recinfo.doc_sequence_value IS NULL)
            AND (X_doc_sequence_value IS NULL))))
       AND (    (   (Recinfo.doc_sequence_id = X_doc_sequence_id )
        OR (    (Recinfo.doc_sequence_id IS NULL)
            AND (X_doc_sequence_id IS NULL))))
       AND (    (   (Recinfo.control_begin_balance = X_control_begin_balance )
        OR (    (Recinfo.control_begin_balance IS NULL)
            AND (X_control_begin_balance IS NULL))))
       AND (    (   (Recinfo.control_end_balance = X_control_end_balance)
        OR (    (Recinfo.control_end_balance IS NULL)
            AND (X_control_end_balance IS NULL))))
       AND (    (   (Recinfo.cashflow_balance = X_cashflow_balance)
        OR (    (Recinfo.cashflow_balance IS NULL)
            AND (X_cashflow_balance IS NULL))))
       AND (    (   (Recinfo.int_calc_balance = X_int_calc_balance)
        OR (    (Recinfo.int_calc_balance IS NULL)
            AND (X_int_calc_balance IS NULL))))
       AND (    (   (Recinfo.one_day_float = X_one_day_float)
        OR (    (Recinfo.one_day_float IS NULL)
            AND (X_one_day_float IS NULL)))) -- bug 3927648
       AND (    (   (Recinfo.two_day_float = X_two_day_float)
        OR (    (Recinfo.two_day_float IS NULL)
            AND (X_two_day_float IS NULL))))
       AND (    (   (Recinfo.control_total_dr = X_control_total_dr )
        OR (    (Recinfo.control_total_dr IS NULL)
            AND (X_control_total_dr IS NULL))))
       AND (    (   (Recinfo.control_total_cr = X_control_total_cr )
        OR (    (Recinfo.control_total_cr IS NULL)
            AND (X_control_total_cr IS NULL))))
       AND (    (   (Recinfo.control_dr_line_count = X_control_dr_line_count )
        OR (    (Recinfo.control_dr_line_count IS NULL)
            AND (X_control_dr_line_count IS NULL))))
       AND (    (   (Recinfo.control_cr_line_count = X_control_cr_line_count )
        OR (    (Recinfo.control_cr_line_count IS NULL)
            AND (X_control_cr_line_count IS NULL))))
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
       AND (   (    (Recinfo.attribute13 = X_attribute13 )
        OR (    (Recinfo.attribute13 IS NULL)
            AND (X_attribute13 IS NULL))))
       AND (    (   (Recinfo.attribute14 = X_attribute14 )
        OR (    (Recinfo.attribute14 IS NULL)
           AND (X_attribute14 IS NULL))))
       AND (    (   (Recinfo.attribute15 = X_attribute15 )
        OR (    (Recinfo.attribute15 IS NULL)
           AND (X_attribute15 IS NULL))))
       AND (    (   (Recinfo.auto_loaded_flag = X_auto_loaded_flag )
        OR (    (Recinfo.auto_loaded_flag IS NULL)
           AND (X_auto_loaded_flag IS NULL))))
       AND (    (   (Recinfo.statement_complete_flag = X_statement_complete_flag )
        OR (    (Recinfo.statement_complete_flag IS NULL)
           AND (X_statement_complete_flag IS NULL))))
       AND (    (   (Recinfo.gl_date = X_gl_date )
        OR (    (Recinfo.gl_date IS NULL)
           AND (X_gl_date IS NULL))))
    -- 5916290: GDF Changes
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
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Lock_Row;


END CE_STAT_HDRS_DML_PKG;

/
