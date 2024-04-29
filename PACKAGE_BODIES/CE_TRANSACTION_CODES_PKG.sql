--------------------------------------------------------
--  DDL for Package Body CE_TRANSACTION_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_TRANSACTION_CODES_PKG" as
/* $Header: cetrxcdb.pls 120.4.12010000.2 2009/07/31 09:34:48 vnetan ship $ */
--
-- Package
--  ce_transaction_codes_pkg
-- Purpose
--   To contain validation and insertion routines for ce_transaction_codes
-- History
--   00-00-94   Dean McCarthy           Created

    FUNCTION body_revision RETURN VARCHAR2 IS
    BEGIN
        RETURN '$Revision: 120.4.12010000.2 $';
    END body_revision;

    FUNCTION spec_revision RETURN VARCHAR2 IS
    BEGIN
        RETURN G_spec_revision;
    END spec_revision;

    --
    -- Procedure
    --  Insert_Row
    -- Purpose
    --   Inserts a row into ce_transaction_codes
    -- History
    --   00-00-94  Dean McCarthy           Created
    --   07-20-09  vnetan                  8707463: Added REQUEST_ID
    -- Arguments
    -- all the columns of the table CE_TRANSACTION_CODES
    -- Example
    --   CE_TRANSACTION_CODES.Insert_Row(....;
    -- Notes
    --
    PROCEDURE Insert_Row(
        X_Rowid                   IN OUT NOCOPY VARCHAR2,
        X_Transaction_Code_Id     IN OUT NOCOPY NUMBER,
        X_Bank_Account_Id                NUMBER,
        X_Trx_Code                       VARCHAR2,
        X_Trx_Type                       VARCHAR2,
        X_Description                    VARCHAR2,
        X_Receivables_Trx_Id             NUMBER,
        X_Receipt_Method_Id              NUMBER,
        X_Create_Misc_Trx_Flag           VARCHAR2,
        X_Reconcile_Flag                 VARCHAR2,
        X_Float_Days                     NUMBER,
        X_Matching_Against               VARCHAR2,
        X_Correction_Method              VARCHAR2,
        X_Start_Date                     DATE,
        X_End_Date                       DATE,
        X_Attribute_Category             VARCHAR2,
        X_Attribute1                     VARCHAR2,
        X_Attribute2                     VARCHAR2,
        X_Attribute3                     VARCHAR2,
        X_Attribute4                     VARCHAR2,
        X_Attribute5                     VARCHAR2,
        X_Attribute6                     VARCHAR2,
        X_Attribute7                     VARCHAR2,
        X_Attribute8                     VARCHAR2,
        X_Attribute9                     VARCHAR2,
        X_Attribute10                    VARCHAR2,
        X_Attribute11                    VARCHAR2,
        X_Attribute12                    VARCHAR2,
        X_Attribute13                    VARCHAR2,
        X_Attribute14                    VARCHAR2,
        X_Attribute15                    VARCHAR2,
        X_Last_Updated_By                NUMBER,
        X_Last_Update_Date               DATE,
        X_Last_Update_Login              NUMBER,
        X_Created_By                     NUMBER,
        X_Creation_Date                  DATE,
        X_payroll_payment_format_Id      NUMBER DEFAULT NULL,
        X_reconciliation_sequence        NUMBER,
        X_request_id                     NUMBER DEFAULT NULL --8707463: Added
    ) IS

    CURSOR C IS
        SELECT rowid FROM CE_TRANSACTION_CODES
        WHERE transaction_code_id = X_Transaction_Code_Id;

    CURSOR C2 IS
        SELECT ce_transaction_codes_s.nextval
        FROM sys.dual;

    BEGIN
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.Insert_Row');

        cep_standard.debug('open c2 ');

        OPEN C2;
        FETCH C2 INTO X_transaction_code_id;
        CLOSE C2;


        cep_standard.debug('insert into CE_TRANSACTION_CODES begin');

        INSERT INTO CE_TRANSACTION_CODES(
            transaction_code_id,
            bank_account_id,
            trx_code,
            trx_type,
            description,
            receivables_trx_id,
            receipt_method_id,
            create_misc_trx_flag,
            reconcile_flag,
            float_days,
            matching_against,
            correction_method,
            start_date,
            end_date,
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
            last_updated_by,
            last_update_date,
            last_update_login,
            created_by,
            creation_date,
            payroll_payment_format_id,
            reconciliation_sequence,
            request_id --8707463: Added
        ) VALUES (
            X_Transaction_Code_Id,
            X_Bank_Account_Id,
            X_Trx_Code,
            X_Trx_Type,
            X_Description,
            X_Receivables_Trx_Id,
            X_Receipt_Method_Id,
            X_Create_Misc_Trx_Flag,
            X_Reconcile_Flag,
            X_Float_Days,
            X_Matching_Against,
            X_Correction_Method,
            X_Start_Date,
            X_End_Date,
            X_Attribute_Category,
            X_Attribute1,
            X_Attribute2,
            X_Attribute3,
            X_Attribute4,
            X_Attribute5,
            X_Attribute6,
            X_Attribute7,
            X_Attribute8,
            X_Attribute9,
            X_Attribute10,
            X_Attribute11,
            X_Attribute12,
            X_Attribute13,
            X_Attribute14,
            X_Attribute15,
            X_Last_Updated_By,
            X_Last_Update_Date,
            X_Last_Update_Login,
            X_Created_By,
            X_Creation_Date,
            X_payroll_payment_format_id,
            X_reconciliation_sequence,
            X_request_id -- 8707463:Added
        );

        cep_standard.debug('insert into CE_TRANSACTION_CODES end');

        OPEN C;
        FETCH C INTO X_Rowid;

        IF (C%NOTFOUND) THEN
            CLOSE C;
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE C;
        cep_standard.debug('<<CE_TRANSACTION_CODES_PKG.Insert_Row');

    END Insert_Row;

    --
    -- Procedure
    --  Lock_Row
    -- Purpose
    --   Locks a row into gl_daily_conversion_rates
    -- History
    --   00-00-94  Dean McCarthy     Created
    -- Arguments
    -- all the columns of the table CE_TRANSACTION_CODES
    -- Example
    --   ce_transaction_codes.Lock_Row(....;
    -- Notes
    --
    PROCEDURE Lock_Row(
        X_Rowid                            VARCHAR2,
        X_Transaction_Code_Id              NUMBER,
        X_Bank_Account_Id                  NUMBER,
        X_Trx_Code                         VARCHAR2,
        X_Trx_Type                         VARCHAR2,
        X_Description                      VARCHAR2,
        X_Receivables_Trx_Id               NUMBER,
        X_Receipt_Method_Id                NUMBER,
        X_Create_Misc_Trx_Flag             VARCHAR2,
        X_Reconcile_Flag                   VARCHAR2,
        X_Float_Days                       NUMBER,
        X_Matching_Against                 VARCHAR2,
        X_Correction_Method                VARCHAR2,
        X_Start_Date                       DATE,
        X_End_Date                         DATE,
        X_Attribute_Category               VARCHAR2,
        X_Attribute1                       VARCHAR2,
        X_Attribute2                       VARCHAR2,
        X_Attribute3                       VARCHAR2,
        X_Attribute4                       VARCHAR2,
        X_Attribute5                       VARCHAR2,
        X_Attribute6                       VARCHAR2,
        X_Attribute7                       VARCHAR2,
        X_Attribute8                       VARCHAR2,
        X_Attribute9                       VARCHAR2,
        X_Attribute10                      VARCHAR2,
        X_Attribute11                      VARCHAR2,
        X_Attribute12                      VARCHAR2,
        X_Attribute13                      VARCHAR2,
        X_Attribute14                      VARCHAR2,
        X_Attribute15                      VARCHAR2,
        X_payroll_payment_format_id        NUMBER DEFAULT NULL,
        X_reconciliation_sequence          NUMBER
    ) IS
        CURSOR C IS
            SELECT *
            FROM   CE_TRANSACTION_CODES
            WHERE  rowid = X_Rowid
            FOR UPDATE of Transaction_Code_Id NOWAIT;

        Recinfo C%ROWTYPE;
    BEGIN
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.Lock_Row');
        OPEN C;
        FETCH C INTO Recinfo;

        IF (C%NOTFOUND) THEN
            CLOSE C;
            FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
            APP_EXCEPTION.Raise_Exception;
        END IF;

        CLOSE C;

        IF (    (Recinfo.transaction_code_id = X_Transaction_Code_Id)
            AND (Recinfo.bank_account_id = X_Bank_Account_Id)
            AND (Recinfo.trx_code = X_Trx_Code)
            AND (Recinfo.trx_type = X_Trx_Type)
            AND ((Recinfo.description = X_Description)
                OR ((Recinfo.description IS NULL) AND (X_Description IS NULL)))
            AND ((Recinfo.receivables_trx_id = X_Receivables_Trx_Id)
                OR ((Recinfo.receivables_trx_id IS NULL) AND (X_Receivables_Trx_Id IS NULL)))
            AND ((Recinfo.receipt_method_id = X_Receipt_Method_Id)
                OR ((Recinfo.receipt_method_id IS NULL) AND (X_Receipt_Method_Id IS NULL)))
            AND ((Recinfo.create_misc_trx_flag = X_Create_Misc_Trx_Flag)
                OR ((Recinfo.create_misc_trx_flag IS NULL) AND(X_Create_Misc_Trx_Flag IS NULL)))
            AND ((Recinfo.reconcile_flag = X_reconcile_flag)
                OR ((Recinfo.reconcile_flag IS NULL) AND (X_reconcile_flag IS NULL)))
            AND ((Recinfo.float_days = X_float_days)
                OR ((Recinfo.float_days IS NULL) AND (X_float_days IS NULL)))
            AND ((Recinfo.matching_against = X_matching_against)
                OR ((Recinfo.matching_against IS NULL) AND (X_matching_against IS NULL)))
            AND ((Recinfo.correction_method = X_correction_method)
                OR ((Recinfo.correction_method IS NULL) AND (X_correction_method IS NULL)))
            AND ((Recinfo.start_date = X_Start_Date)
                OR ((Recinfo.start_date IS NULL) AND (X_Start_Date IS NULL)))
            AND ((Recinfo.end_date = X_End_Date)
                OR ((Recinfo.end_date IS NULL) AND (X_End_Date IS NULL)))
            AND ((Recinfo.attribute_category = X_Attribute_Category)
                OR ((Recinfo.attribute_category IS NULL) AND (X_Attribute_Category IS NULL)))
            AND ((Recinfo.attribute1 = X_Attribute1)
                OR ((Recinfo.attribute1 IS NULL) AND (X_Attribute1 IS NULL)))
            AND ((Recinfo.attribute2 = X_Attribute2)
                OR ((Recinfo.attribute2 IS NULL) AND (X_Attribute2 IS NULL)))
            AND ((Recinfo.attribute3 = X_Attribute3)
                OR ((Recinfo.attribute3 IS NULL) AND (X_Attribute3 IS NULL)))
            AND ((Recinfo.attribute4 = X_Attribute4)
                OR ((Recinfo.attribute4 IS NULL) AND (X_Attribute4 IS NULL)))
            AND ((Recinfo.attribute5 = X_Attribute5)
                OR ((Recinfo.attribute5 IS NULL) AND (X_Attribute5 IS NULL)))
            AND ((Recinfo.attribute6 = X_Attribute6)
                OR ((Recinfo.attribute6 IS NULL) AND (X_Attribute6 IS NULL)))
            AND ((Recinfo.attribute7 = X_Attribute7)
                OR ((Recinfo.attribute7 IS NULL) AND (X_Attribute7 IS NULL)))
            AND ((Recinfo.attribute8 = X_Attribute8)
                OR ((Recinfo.attribute8 IS NULL) AND (X_Attribute8 IS NULL)))
            AND ((Recinfo.attribute9 = X_Attribute9)
                OR ((Recinfo.attribute9 IS NULL) AND (X_Attribute9 IS NULL)))
            AND ((Recinfo.attribute10 = X_Attribute10)
                OR ((Recinfo.attribute10 IS NULL) AND (X_Attribute10 IS NULL)))
            AND ((Recinfo.attribute11 = X_Attribute11)
                OR ((Recinfo.attribute11 IS NULL) AND (X_Attribute11 IS NULL)))
            AND ((Recinfo.attribute12 = X_Attribute12)
                OR ((Recinfo.attribute12 IS NULL) AND (X_Attribute12 IS NULL)))
            AND ((Recinfo.attribute13 = X_Attribute13)
                OR ((Recinfo.attribute13 IS NULL) AND (X_Attribute13 IS NULL)))
            AND ((Recinfo.attribute14 = X_Attribute14)
                OR ((Recinfo.attribute14 IS NULL) AND (X_Attribute14 IS NULL)))
            AND ((Recinfo.attribute15 = X_Attribute15)
                OR ((Recinfo.attribute15 IS NULL) AND (X_Attribute15 IS NULL)))
            AND ((Recinfo.payroll_payment_format_id = X_payroll_payment_format_id)
                OR ((Recinfo.payroll_payment_format_id IS NULL) AND (X_payroll_payment_format_id IS NULL)))
            AND ((Recinfo.reconciliation_sequence = X_reconciliation_sequence)
                OR ((Recinfo.reconciliation_sequence IS NULL) AND (X_reconciliation_sequence IS NULL)))
        ) THEN
            cep_standard.debug('row locked');
            RETURN;
        ELSE
            cep_standard.debug('form_record_changed');
            FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
            APP_EXCEPTION.Raise_Exception;
        END IF;
        cep_standard.debug('<<CE_TRANSACTION_CODES_PKG.Lock_Row');
    END Lock_Row;

    --
    -- Procedure
    --  Update_Row
    -- Purpose
    --   Updates a row into ce_transaction_codes
    -- History
    --   00-00-94  Dean McCarthy Created
    --   07-20-09  vnetan        8707463: Added REQUEST_ID
    -- Arguments
    -- all the columns of the table CE_TRANSACTION_CODES
    -- Example
    --   ce_transaction_codes.Update_Row(....;
    -- Notes
    --
    PROCEDURE Update_Row(
        X_Rowid                          VARCHAR2,
        X_Transaction_Code_Id            NUMBER,
        X_Bank_Account_Id                NUMBER,
        X_Trx_Code                       VARCHAR2,
        X_Trx_Type                       VARCHAR2,
        X_Description                    VARCHAR2,
        X_Receivables_Trx_Id             NUMBER,
        X_Receipt_Method_Id              NUMBER,
        X_Create_Misc_Trx_Flag           VARCHAR2,
        X_Reconcile_Flag                 VARCHAR2,
        X_Float_Days                     NUMBER,
        X_Matching_Against               VARCHAR2,
        X_Correction_Method              VARCHAR2,
        X_Start_Date                     DATE,
        X_End_Date                       DATE,
        X_Attribute_Category             VARCHAR2,
        X_Attribute1                     VARCHAR2,
        X_Attribute2                     VARCHAR2,
        X_Attribute3                     VARCHAR2,
        X_Attribute4                     VARCHAR2,
        X_Attribute5                     VARCHAR2,
        X_Attribute6                     VARCHAR2,
        X_Attribute7                     VARCHAR2,
        X_Attribute8                     VARCHAR2,
        X_Attribute9                     VARCHAR2,
        X_Attribute10                    VARCHAR2,
        X_Attribute11                    VARCHAR2,
        X_Attribute12                    VARCHAR2,
        X_Attribute13                    VARCHAR2,
        X_Attribute14                    VARCHAR2,
        X_Attribute15                    VARCHAR2,
        X_Last_Updated_By                NUMBER,
        X_Last_Update_Date               DATE,
        X_Last_Update_Login              NUMBER,
        X_payroll_payment_format_id      NUMBER DEFAULT NULL,
        X_reconciliation_sequence        NUMBER ,
        X_request_id                     NUMBER DEFAULT NULL -- 8707463: Added
    ) IS
    BEGIN
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.update_Row');
        UPDATE CE_TRANSACTION_CODES SET
            transaction_code_id             =     X_Transaction_Code_Id,
            bank_account_id                 =     X_Bank_Account_Id,
            trx_code                        =     X_Trx_Code,
            trx_type                        =     X_Trx_Type,
            description                     =     X_Description,
            receivables_trx_id              =     X_Receivables_Trx_Id,
            receipt_method_id               =     X_Receipt_Method_Id,
            create_misc_trx_flag            =     X_Create_Misc_Trx_Flag,
            reconcile_flag                  =     X_Reconcile_Flag,
            float_days                      =     X_Float_Days,
            matching_against                =     X_Matching_Against,
            correction_method               =     X_Correction_Method,
            start_date                      =     X_Start_Date,
            end_date                        =     X_End_Date,
            attribute_category              =     X_Attribute_Category,
            attribute1                      =     X_Attribute1,
            attribute2                      =     X_Attribute2,
            attribute3                      =     X_Attribute3,
            attribute4                      =     X_Attribute4,
            attribute5                      =     X_Attribute5,
            attribute6                      =     X_Attribute6,
            attribute7                      =     X_Attribute7,
            attribute8                      =     X_Attribute8,
            attribute9                      =     X_Attribute9,
            attribute10                     =     X_Attribute10,
            attribute11                     =     X_Attribute11,
            attribute12                     =     X_Attribute12,
            attribute13                     =     X_Attribute13,
            attribute14                     =     X_Attribute14,
            attribute15                     =     X_Attribute15,
            last_updated_by                 =     X_Last_Updated_By,
            last_update_date                =     X_Last_Update_Date,
            last_update_login               =     X_Last_Update_Login,
            payroll_payment_format_id       =     X_payroll_payment_format_id,
            reconciliation_sequence         =     X_reconciliation_sequence,
            request_id                      =     X_request_id --8707463: Added
        WHERE rowid = X_Rowid;
        --
        IF (SQL%NOTFOUND) THEN
            cep_standard.debug('NO_DATA_FOUND');
            RAISE NO_DATA_FOUND;
        END IF;
        cep_standard.debug('<<CE_TRANSACTION_CODES_PKG.update_Row');
    END Update_Row;

    --
    -- Procedure
    --  Delete_Row
    -- Purpose
    --   Deletes a row from ce_transaction_codes
    -- History
    --   00-00-94  Dean McCarthy  Created
    -- Arguments
    --    x_rowid         Rowid of a row
    -- Example
    --   ce_transaction_codes.delete_row('ajfdshj');
    -- Notes
    --
    PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    BEGIN
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.delete_Row');
        DELETE FROM CE_TRANSACTION_CODES
        WHERE ROWID = X_Rowid;
        --
        IF (SQL%NOTFOUND) THEN
            cep_standard.debug('NO_DATA_FOUND');
            RAISE NO_DATA_FOUND;
        END IF;
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.update_Row');
    END Delete_Row;

    --
    -- Procedure
    --  check_unique_txn_code
    -- Purpose
    --   Checks for uniquness of Transaction codes before
    --   insertion and updates for a given bank code
    -- History
    --   11-Jun-95  Ganesh Vaidee  Created
    --   16-Jun-05  lkwan          bug 4435028 - new unique validate rules

    --         Users should be able to enter the following
    --         Type    Code    Transaction Source    Priority
    --         Payment     100    AP Payments        1
    --         Payment    100    Payroll            2
    --         Payment    100    Cash Management        3
    --
    -- Arguments
    --    x_row_id           Rowid of a row
    --    X_trx_code         Transaction code of row to be inserted or updated
    --    X_bank_account_id  Bank Account Id
    --     X_trx_type        DEBIT, CREDIT, MISC_DEBIT, MISC_CREDIT, NSF, REJECTED, STOP
    --     X_RECONCILE_FLAG    null, AR, AP, JE, CE, OI
    --    X_RECONCILIATION_SEQUENCE   null, 1,2,3 ...
    -- Example
    --   ce_transaction_codes.check_unique_txn_code('ajfdshj', 11, '123.657.99', DEBIT, AP, 1 );
    -- Notes
    --
    PROCEDURE check_unique_txn_code(
        X_TRX_CODE                IN VARCHAR2,
        X_BANK_ACCOUNT_ID         IN NUMBER,
        X_ROW_ID                  IN VARCHAR2,
        X_TRX_TYPE                IN VARCHAR2,
        X_RECONCILE_FLAG          IN VARCHAR2,
        X_RECONCILIATION_SEQUENCE IN NUMBER
    ) IS
        -- each trx_code cannot be used by more than one trx_type
        -- check Type, Code
        CURSOR chk_duplicates is
            SELECT 'Duplicate'
            FROM   ce_transaction_codes tc
            WHERE  tc.trx_code     = X_trx_code
             AND   tc. bank_account_id = X_bank_account_id
             AND  (X_Row_id IS NULL OR tc.ROWID <> CHARTOROWID(X_Row_id))
             AND   EXISTS(
                    SELECT 'x'
                    FROM ce_transaction_codes tc2
                    WHERE  tc2.trx_code         = tc.trx_code
                    AND    tc2.bank_account_id  = tc.bank_account_id
                    AND    tc2.TRX_TYPE        <> X_trx_type);

        -- check Code, Priority combiniation
        CURSOR chk_duplicates2 IS
            SELECT 'Duplicate'
            FROM   ce_transaction_codes tc
            WHERE  tc.trx_code     = X_trx_code
             AND   tc.bank_account_id = X_bank_account_id
             AND   NVL(tc.RECONCILIATION_SEQUENCE,0) = NVL(X_RECONCILIATION_SEQUENCE,0)
             AND  (X_Row_id IS NULL OR tc.ROWID <> CHARTOROWID(X_Row_id));


        -- check Code, Transaction Source combiniation
        CURSOR chk_duplicates3 IS
            SELECT 'Duplicate'
            FROM   ce_transaction_codes tc
            WHERE  tc.trx_code     = X_trx_code
             AND   tc. bank_account_id = X_bank_account_id
             AND   NVL(tc.RECONCILE_FLAG, 'X') = NVL(X_RECONCILE_FLAG, 'X')
             AND  (X_Row_id IS NULL OR tc.ROWID <> CHARTOROWID( X_Row_id ) );


        dummy VARCHAR2(100);
    --
    BEGIN
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.check_unique_txn_code');

        OPEN chk_duplicates;
        FETCH chk_duplicates INTO dummy;

        IF chk_duplicates%FOUND THEN
            cep_standard.debug( 'Duplicate: CE_DUP_BANK_TRX_CODE');
            CLOSE chk_duplicates;
            fnd_message.set_name( 'CE', 'CE_DUP_BANK_TRX_CODE' );
            app_exception.raise_exception;
        END IF;

        CLOSE chk_duplicates;

        OPEN chk_duplicates2;
        FETCH chk_duplicates2 INTO dummy;

        IF chk_duplicates2%FOUND THEN
            cep_standard.debug( 'Duplicate: CE_DUP_BANK_TRX_CODE_COMB2');
            CLOSE chk_duplicates2;
            fnd_message.set_name( 'CE', 'CE_DUP_BANK_TRX_CODE_COMB2' );
            app_exception.raise_exception;
        END IF;

        CLOSE chk_duplicates2;

        OPEN chk_duplicates3;
        FETCH chk_duplicates3 INTO dummy;

        IF chk_duplicates3%FOUND THEN
            cep_standard.debug( 'Duplicate: CE_DUP_BANK_TRX_CODE_COMB1');
            CLOSE chk_duplicates3;
            fnd_message.set_name( 'CE', 'CE_DUP_BANK_TRX_CODE_COMB1' );
            app_exception.raise_exception;
        END IF;

        CLOSE chk_duplicates3;

        cep_standard.debug('<<CE_TRANSACTION_CODES_PKG.check_unique_txn_code');
    EXCEPTION
        WHEN app_exceptions.application_exception THEN
            IF ( chk_duplicates%ISOPEN ) THEN
                CLOSE chk_duplicates;
            END IF;
            IF ( chk_duplicates2%ISOPEN ) THEN
                CLOSE chk_duplicates2;
            END IF;
            IF ( chk_duplicates3%ISOPEN ) THEN
                CLOSE chk_duplicates3;
            END IF;
            RAISE;
        WHEN OTHERS THEN
            cep_standard.debug('EXCEPTION: CE_TRANSACTION_CODES_PKG.check_unique_txn_code');
            fnd_message.set_name( 'SQLCE', 'CE_UNHANDLED_EXCEPTION');
            fnd_message.set_token( 'PROCEDURE','CE_TRANSACTION_CODES_pkg.check_unique_txn_code');
            IF ( chk_duplicates%ISOPEN ) THEN
                CLOSE chk_duplicates;
            END IF;
            IF ( chk_duplicates2%ISOPEN ) THEN
                CLOSE chk_duplicates2;
            END IF;
            IF ( chk_duplicates3%ISOPEN ) THEN
                CLOSE chk_duplicates3;
            END IF;
            RAISE;
    END check_unique_txn_code;



    FUNCTION is_in_use( X_ce_transaction_code_id NUMBER) RETURN BOOLEAN IS

        CURSOR chk_stmt_line is
            SELECT 'Exists'
            FROM   ce_statement_lines sl
            WHERE  sl.trx_code_id = X_ce_transaction_code_id;

        CURSOR chk_arch_stmt_line is
            SELECT 'Exists'
            FROM   ce_arch_lines al
            WHERE  al.trx_code_id = X_ce_transaction_code_id;

            dummy        VARCHAR2(240);

    BEGIN
        cep_standard.debug('>>CE_TRANSACTION_CODES_PKG.is_in_use');

        /*
        * Check for transaction code in the statement lines.
        */
        OPEN chk_stmt_line;
        FETCH chk_stmt_line INTO dummy;

        IF chk_stmt_line%FOUND THEN
            cep_standard.debug('Used in statement lines');
            CLOSE chk_stmt_line;
            RETURN TRUE;
        END IF;

        CLOSE chk_stmt_line;


        /*
        * Check for transaction code in the archived statement lines.
        */
        OPEN chk_arch_stmt_line;

        FETCH chk_arch_stmt_line INTO dummy;

        IF chk_arch_stmt_line%FOUND THEN
            cep_standard.debug('Used in archvied statement lines');
            CLOSE chk_arch_stmt_line;
            RETURN TRUE;
        END IF;

        CLOSE chk_arch_stmt_line;

        cep_standard.debug('No reference. Return FALSE');
        RETURN FALSE;

        cep_standard.debug('<<CE_TRANSACTION_CODES_PKG.is_in_use');
    EXCEPTION
        WHEN app_exceptions.application_exception THEN
            cep_standard.debug('EXCEPTION: Application_exception CE_TRANSACTION_CODES_pkg.Is_In_Use');
            IF ( chk_stmt_line%ISOPEN ) THEN
                CLOSE chk_stmt_line;
            END IF;
            IF ( chk_arch_stmt_line%ISOPEN ) THEN
                CLOSE chk_arch_stmt_line;
            END IF;
            RAISE;
        WHEN OTHERS THEN
            cep_standard.debug('EXCEPTION: CE_TRANSACTION_CODES_pkg.Is_In_Use');
            fnd_message.set_name( 'SQLCE', 'CE_UNHANDLED_EXCEPTION');
            fnd_message.set_token( 'FUNCTION','CE_TRANSACTION_CODES_pkg.Is_In_Use');
            IF ( chk_stmt_line%ISOPEN ) THEN
                CLOSE chk_stmt_line;
            END IF;
            IF ( chk_arch_stmt_line%ISOPEN ) THEN
                CLOSE chk_arch_stmt_line;
            END IF;
            RAISE;
    END is_in_use;

END CE_TRANSACTION_CODES_PKG;

/
