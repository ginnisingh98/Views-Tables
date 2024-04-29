--------------------------------------------------------
--  DDL for Package Body CE_COPY_TRX_CODES_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_COPY_TRX_CODES_XML" AS
/* $Header: cecptxcb.pls 120.1.12010000.1 2009/07/31 08:39:23 vnetan noship $ */

  /*========================================================================+
   | PRIVATE PROCEDURE                                                      |
   |   debug_log                                                            |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Procedure to print debug messages to logs.                           |
   +========================================================================*/
    PROCEDURE debug_log( p_message IN VARCHAR2 ) IS
    BEGIN
        cep_standard.debug(p_message);
        --vn_debug_proc(p_message);
    END debug_log;

  /*========================================================================+
   | PRIVATE PROCEDURE                                                      |
   |   debug_log                                                            |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Procedure to initialize global variables.                            |
   +========================================================================*/
    PROCEDURE init_variables IS
    BEGIN
        debug_log('>>CE_COPY_TRX_CODES_XML.init_variables');

        -- source account
        IF p_source_acct_id IS NOT NULL
        THEN
            SELECT SUBSTR(CBA.bank_account_name,0,50), CBA.bank_account_num
            INTO g_source_account_name, g_source_account_num
            FROM ce_bank_accounts CBA
            WHERE CBA.bank_account_id = p_source_acct_id;
        ELSE
            g_source_account_name := NULL;
            g_source_account_num := NULL;
        END IF;
        debug_log('g_source_account_name::'||g_source_account_name);
        debug_log('g_source_account_num::'||g_source_account_num);

        -- destination bank
        IF p_dest_bank_id IS NOT NULL
        THEN
            SELECT SUBSTR(BNK.party_name,0,50) INTO g_dest_bank_name
            FROM hz_parties BNK WHERE BNK.party_id = p_dest_bank_id;
        ELSE
            g_dest_bank_name := NULL;
        END IF;
        debug_log('g_dest_bank_name::'||g_dest_bank_name);

        --destination branch
        IF p_dest_branch_id IS NOT NULL
        THEN
            SELECT SUBSTR(BRN.party_name,0,50) INTO g_dest_branch_name
            FROM hz_parties BRN WHERE BRN.party_id = p_dest_branch_id;
        ELSE
            g_dest_branch_name := NULL;
        END IF;
        debug_log('g_dest_branch_name::'||g_dest_branch_name);

        --destination account
        IF p_dest_acct_id IS NOT NULL
        THEN
            SELECT CBA.bank_account_num INTO g_dest_account_num
            FROM ce_bank_accounts CBA
            WHERE CBA.bank_account_id = p_dest_acct_id;
        ELSE
            g_dest_account_num := NULL;
        END IF;
        debug_log('g_dest_account_num::'||g_dest_account_num);

        --destination type
        IF p_dest_acct_type IS NOT NULL
        THEN
            SELECT substr(LKP.meaning,0,50) INTO g_dest_account_type
            FROM ce_lookups LKP
            WHERE LKP.lookup_type = 'BANK_ACCOUNT_TYPE'
              AND LKP.lookup_code = p_dest_acct_type;
        ElSE
            g_dest_account_type := NULL;
        END IF;
        debug_log('g_dest_account_type::'||g_dest_account_type);

        --request_id
        g_conc_request_id := FND_GLOBAL.CONC_REQUEST_ID;
        debug_log('g_conc_request_id::'||g_conc_request_id);

        debug_log('<<CE_COPY_TRX_CODES_XML.init_variables');

    END init_variables;

  /*========================================================================+
   | PRIVATE FUNCTION                                                       |
   |   check_unique_trxn_code                                               |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Checks for uniquness of Transaction codes before insertion.          |
   |                                                                        |
   | ARGUMENTS                                                              |
   |    X_row_id                    Rowid of a row                          |
   |    X_trx_code                  Transaction code of row to be inserted  |
   |    X_bank_account_id           Bank Account Id                         |
   |    X_trx_type                  DEBIT, CREDIT, MISC_DEBIT, MISC_CREDIT, |
   |                                NSF, REJECTED, STOP, SWEEP_IN, SWEEP_OUT|
   |    X_RECONCILE_FLAG            null, AR, AP, JE, CE, OI                |
   |    X_RECONCILIATION_SEQUENCE   null, 1,2,3 ...                         |
   |                                                                        |
   +========================================================================*/
    FUNCTION check_unique_trxn_code(
        X_TRX_CODE                IN VARCHAR2,
        X_BANK_ACCOUNT_ID         IN NUMBER,
        X_ROW_ID                  IN VARCHAR2,
        X_TRX_TYPE                IN VARCHAR2,
        X_RECONCILE_FLAG          IN VARCHAR2,
        X_RECONCILIATION_SEQUENCE IN NUMBER
    ) RETURN VARCHAR2 IS
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
        cep_standard.debug('>>CE_COPY_TRX_CODES_XML.check_unique_trxn_code');

        OPEN chk_duplicates;
        FETCH chk_duplicates INTO dummy;

        IF chk_duplicates%FOUND THEN
            cep_standard.debug( 'Duplicate: CE_DUP_BANK_TRX_CODE');
            CLOSE chk_duplicates;
            RETURN 'CE_DUP_BANK_TRX_CODE';
        END IF;

        CLOSE chk_duplicates;

        OPEN chk_duplicates3;
        FETCH chk_duplicates3 INTO dummy;

        IF chk_duplicates3%FOUND THEN
            cep_standard.debug( 'Duplicate: CE_DUP_BANK_TRX_CODE_COMB1');
            CLOSE chk_duplicates3;
            RETURN 'CE_DUP_BANK_TRX_CODE_COMB1';
        END IF;

        CLOSE chk_duplicates3;

        OPEN chk_duplicates2;
        FETCH chk_duplicates2 INTO dummy;

        IF chk_duplicates2%FOUND THEN
            cep_standard.debug( 'Duplicate: CE_DUP_BANK_TRX_CODE_COMB2');
            CLOSE chk_duplicates2;
            RETURN 'CE_DUP_BANK_TRX_CODE_COMB2';
        END IF;

        CLOSE chk_duplicates2;

        cep_standard.debug('<<CE_COPY_TRX_CODES_XML.check_unique_trxn_code');
        RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
            cep_standard.debug('EXCEPTION: CE_COPY_TRX_CODES_XML.check_unique_trxn_code');
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
    END check_unique_trxn_code;

  /*========================================================================+
   | PRIVATE PROCEDURE                                                      |
   |   copy_trx_codes                                                       |
   |                                                                        |
   | DESCRIPTION                                                            |
   |    This procedures copies the bank transaction codes setup for the     |
   |    source account to the destination accounts.                         |
   |                                                                        |
   | ARGUMENTS                                                              |
   |                                                                        |
   | CALLS                                                                  |
   |    CE_TRANSACTION_CODES_PKG.insert_row                                 |
   |    CE_COPY_TRX_CODES_XML.check_unique_trxn_code                        |
   +========================================================================*/
    PROCEDURE copy_trx_codes
    IS
        -- cursor to fetch transaction codes
        CURSOR get_source_trx_codes IS
        SELECT  trx_code,
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
                payroll_payment_format_id,
                reconciliation_sequence
        FROM    ce_transaction_codes
        WHERE   bank_account_id = p_source_acct_id;

        --cursor to fetch destination accounts
        CURSOR get_dest_accounts IS
            SELECT  CBA.bank_account_id
            FROM    ce_bank_accounts_v CBA
            WHERE   CBA.bank_account_id = NVL(p_dest_acct_id, CBA.bank_account_id)
              AND ((CBA.bank_account_type IS NULL AND p_dest_acct_type IS NULL)
                 OR CBA.bank_account_type = NVL(p_dest_acct_type, CBA.bank_account_type))
              AND   CBA.bank_branch_id = NVL(p_dest_branch_id, CBA.bank_branch_id)
              AND   CBA.bank_id = NVL(p_dest_bank_id, CBA.bank_id)
              AND   CBA.bank_account_id <> p_source_acct_id;

        -- local variables
        l_row_id              VARCHAR2(18);
        l_transaction_code_id NUMBER(15);
        l_validate_uniq       VARCHAR2(30);
        l_last_update_login   NUMBER;
        l_user_id             NUMBER;


    BEGIN
        debug_log('>>CE_COPY_TRX_CODES_XML.copy_trx_codes');

        --parameter values
        debug_log('p_source_acct_id::'||p_source_acct_id);
        debug_log('p_dest_bank_id::'||p_dest_bank_id);
        debug_log('p_dest_branch_id::'||p_dest_branch_id);
        debug_log('p_dest_acct_id::'||p_dest_acct_id);
        debug_log('p_dest_acct_type::'||p_dest_acct_type);

        -- WHO columns
        l_last_update_login := FND_GLOBAL.CONC_LOGIN_ID;
        l_user_id := FND_GLOBAL.USER_ID;

        --fetch transaction codes from source account
        FOR src_trx_code IN get_source_trx_codes
        LOOP
            debug_log('TrxCode::'||SRC_TRX_CODE.trx_code||'-----------------');
            --fetch destination accounts to which codes have to be copied
            FOR dest_acct IN get_dest_accounts
            LOOP

                debug_log('..DestAcct::'||DEST_ACCT.bank_account_id);
                l_validate_uniq := NULL;
                l_validate_uniq :=  check_unique_trxn_code(
                        X_trx_code          => SRC_TRX_CODE.trx_code,
                        X_bank_account_id   => DEST_ACCT.bank_account_id,
                        X_row_id            => NULL,
                        X_trx_type          => SRC_TRX_CODE.trx_type,
                        X_reconcile_flag    => SRC_TRX_CODE.reconcile_flag,
                        X_reconciliation_sequence => SRC_TRX_CODE.reconciliation_sequence);
                IF l_validate_uniq = 'SUCCESS' THEN
                    --no exception: transaction code can be inserted
                    CE_TRANSACTION_CODES_PKG.insert_row(
                        X_Rowid                       =>   l_row_id,
                        X_Transaction_Code_Id         =>   l_Transaction_Code_Id,
                        X_Bank_Account_Id             =>   DEST_ACCT.Bank_Account_Id,
                        X_Trx_Code                    =>   SRC_TRX_CODE.Trx_Code,
                        X_Trx_Type                    =>   SRC_TRX_CODE.Trx_Type,
                        X_Description                 =>   SRC_TRX_CODE.Description,
                        X_Receivables_Trx_Id          =>   SRC_TRX_CODE.Receivables_Trx_Id,
                        X_Receipt_Method_Id           =>   SRC_TRX_CODE.Receipt_Method_Id,
                        X_Create_Misc_Trx_Flag        =>   SRC_TRX_CODE.Create_Misc_Trx_Flag,
                        X_Reconcile_Flag              =>   SRC_TRX_CODE.Reconcile_Flag,
                        X_Float_Days                  =>   SRC_TRX_CODE.Float_Days,
                        X_Matching_Against            =>   SRC_TRX_CODE.Matching_Against,
                        X_Correction_Method           =>   SRC_TRX_CODE.Correction_Method,
                        X_Start_Date                  =>   SRC_TRX_CODE.Start_Date,
                        X_End_Date                    =>   SRC_TRX_CODE.End_Date,
                        X_Attribute_Category          =>   SRC_TRX_CODE.Attribute_Category,
                        X_Attribute1                  =>   SRC_TRX_CODE.Attribute1,
                        X_Attribute2                  =>   SRC_TRX_CODE.Attribute2,
                        X_Attribute3                  =>   SRC_TRX_CODE.Attribute3,
                        X_Attribute4                  =>   SRC_TRX_CODE.Attribute4,
                        X_Attribute5                  =>   SRC_TRX_CODE.Attribute5,
                        X_Attribute6                  =>   SRC_TRX_CODE.Attribute6,
                        X_Attribute7                  =>   SRC_TRX_CODE.Attribute7,
                        X_Attribute8                  =>   SRC_TRX_CODE.Attribute8,
                        X_Attribute9                  =>   SRC_TRX_CODE.Attribute9,
                        X_Attribute10                 =>   SRC_TRX_CODE.Attribute10,
                        X_Attribute11                 =>   SRC_TRX_CODE.Attribute11,
                        X_Attribute12                 =>   SRC_TRX_CODE.Attribute12,
                        X_Attribute13                 =>   SRC_TRX_CODE.Attribute13,
                        X_Attribute14                 =>   SRC_TRX_CODE.Attribute14,
                        X_Attribute15                 =>   SRC_TRX_CODE.Attribute15,
                        X_Last_Updated_By             =>   l_user_id,
                        X_Last_Update_Date            =>   sysdate,
                        X_Last_Update_Login           =>   l_last_update_login,
                        X_Created_By                  =>   l_user_id,
                        X_Creation_Date               =>   sysdate,
                        X_payroll_payment_format_Id   =>   SRC_TRX_CODE.payroll_payment_format_Id,
                        X_reconciliation_sequence     =>   SRC_TRX_CODE.reconciliation_sequence,
                        X_request_id                  =>   g_conc_request_id
                    );
                ELSE --uniqness validation failed
                     debug_log('Inserting into error table');

                     --insert status into reports table.
                     INSERT INTO ce_trx_codes_util_gt (
                            request_id,
                            bank_account_id,
                            trx_code,
                            trx_type,
                            reconcile_flag,
                            reconciliation_sequence,
                            description,
                            status
                        ) VALUES (
                            g_conc_request_id,
                            DEST_ACCT.bank_account_id,
                            SRC_TRX_CODE.trx_code,
                            SRC_TRX_CODE.trx_type,
                            SRC_TRX_CODE.reconcile_flag,
                            SRC_TRX_CODE.reconciliation_sequence,
                            SRC_TRX_CODE.description,
                            l_validate_uniq
                        );
                END IF;
            END LOOP;
        END LOOP;
        debug_log('<<CE_COPY_TRX_CODES_XML.copy_trx_codes');

    END copy_trx_codes;

  /*========================================================================+
   | PUBLIC FUNCTION                                                        |
   |   beforeReport                                                         |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Before Report trigger for CECPTXCD.                                  |
   |                                                                        |
   | CALLS                                                                  |
   |    CE_COPY_TRX_CODES_XML.init_variables                                |
   |    CE_COPY_TRX_CODES_XML.copy_trx_codes                                |
   +========================================================================*/
    FUNCTION beforeReport RETURN BOOLEAN IS
    BEGIN
        debug_log('>>CE_COPY_TRX_CODES_XML.beforeReport');

        --initializations
        cep_standard.init_security;
        init_variables;

        --copy the transaction codes
        copy_trx_codes;

        --store count of copied codes
        SELECT count(*)
        INTO G_INSERT_COUNT
        FROM ce_transaction_codes
        WHERE request_id = G_CONC_REQUEST_ID;
        debug_log('g_insert_count::'||g_insert_count);

        debug_log('<<CE_COPY_TRX_CODES_XML.beforeReport');
        RETURN (TRUE);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            debug_log('EXCEPTION: CE_COPY_TRX_CODES_XML.beforeReport trigger. Error : ' || SUBSTR(SQLERRM, 1, 200));
            RETURN (FALSE);
    END beforeReport;

  /*========================================================================+
   | PUBLIC FUNCTION                                                        |
   |   afterReport                                                          |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   After Report trigger for CECPTXCD. Once processing is done           |
   |   commit the changes and purge GT table                                |
   |                                                                        |
   | ARGUMENTS                                                              |
   +========================================================================*/
    FUNCTION afterReport RETURN BOOLEAN IS
    BEGIN
        debug_log('>>CE_COPY_TRX_CODES_XML.afterReport');
        DELETE ce_trx_codes_util_gt;
        COMMIT;
        debug_log('<<CE_COPY_TRX_CODES_XML.afterReport');
        RETURN (TRUE);
    END afterReport;

END CE_COPY_TRX_CODES_XML;

/
