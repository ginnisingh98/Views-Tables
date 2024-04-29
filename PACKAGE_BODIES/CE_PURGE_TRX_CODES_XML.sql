--------------------------------------------------------
--  DDL for Package Body CE_PURGE_TRX_CODES_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_PURGE_TRX_CODES_XML" AS
/* $Header: ceputxcb.pls 120.0.12010000.2 2009/09/15 23:32:33 vnetan noship $ */

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
        debug_log('>>CE_PURGE_TRX_CODES_XML.init_variables');
        --bank
        IF p_bank_id IS NOT NULL
        THEN
            SELECT SUBSTR(BNK.party_name,0,50) INTO g_bank_name
            FROM hz_parties BNK WHERE BNK.party_id = p_bank_id;
        ELSE
            g_bank_name := NULL;
        END IF;
        debug_log('g_bank_name::'||g_bank_name);

        --bank branch
        IF p_bank_branch_id IS NOT NULL
        THEN
            SELECT SUBSTR(BRN.party_name,0,50) INTO g_branch_name
            FROM hz_parties BRN WHERE BRN.party_id = p_bank_branch_id;
        ELSE
            g_branch_name := NULL;
        END IF;
        debug_log('g_bank_branch_name::'||g_branch_name);

        --bank account
        IF p_bank_acct_id IS NOT NULL
        THEN
            SELECT CBA.bank_account_num INTO g_account_num
            FROM ce_bank_accounts CBA
            WHERE CBA.bank_account_id = p_bank_acct_id;
        ELSE
            g_account_num := NULL;
        END IF;
        debug_log('g_account_num::'||g_account_num);

        --bank account type
        IF p_acct_type IS NOT NULL
        THEN
            SELECT substr(LKP.meaning,0,50) INTO g_account_type
            FROM ce_lookups LKP
            WHERE LKP.lookup_type = 'BANK_ACCOUNT_TYPE'
              AND LKP.lookup_code = p_acct_type;
        ElSE
            g_account_type := NULL;
        END IF;
        debug_log('g_account_type::'||g_account_type);

        --Process option
        IF p_process_option IS NOT NULL
        THEN
            SELECT substr(LKP.meaning,0,50) INTO g_process_option
            FROM ce_lookups LKP
            WHERE LKP.lookup_type = 'PURGE_TXCD_PROCESS_OPTION'
              AND LKP.lookup_code = p_process_option;
        ELSE
            g_process_option := NULL;
        END IF;

        debug_log('<<CE_PURGE_TRX_CODES_XML.init_variables');
    END init_variables;

  /*========================================================================+
   | PRIVATE PROCEDURE                                                      |
   |   purge_trx_codes                                                      |
   |                                                                        |
   | DESCRIPTION                                                            |
   |    This procedures deletes the bank transaction codes setup for        |
   |    a set of bank accounts.                                             |
   +========================================================================*/
    PROCEDURE purge_trx_codes
    IS
        l_conc_request_id   NUMBER(15);
    BEGIN
        debug_log('>>CE_PURGE_TRX_CODES_XML.purge_trx_codes');

        --parameter values
        debug_log('p_process_option::'||p_process_option);
        debug_log('p_request_id::'||p_request_id);
        debug_log('p_bank_acct_id::'||p_bank_acct_id);
        debug_log('p_bank_branch_id::'||p_bank_branch_id);
        debug_log('p_bank_id::'||p_bank_id);
        debug_log('p_acct_type::'||p_acct_type);

        l_conc_request_id := FND_GLOBAL.conc_request_id;
        --fetch transaction codes which can be deleted and insert into tmp table
        INSERT INTO ce_trx_codes_util_gt (
            status,
            request_id,
            trx_code_id,
            trx_code,
            bank_account_id,
            description,
            trx_type
        )
        SELECT  'DELETED',
                l_conc_request_id,
                CTC.transaction_code_id,
                CTC.trx_code,
                CTC.bank_account_id,
                CTC.description,
                CTC.trx_type
         FROM    CE_TRANSACTION_CODES CTC, CE_BANK_ACCOUNTS_V CBA
        WHERE   -- fetch codes as per input parameters
                DECODE(p_process_option, 'COPIED', CTC.request_id, 'ALL', 1) =
                DECODE(p_process_option, 'COPIED', NVL(p_request_id, CTC.request_id), 'ALL', 1)
            AND  CTC.bank_account_id = CBA.bank_account_id
            AND  CBA.bank_account_id = NVL(p_bank_acct_id, CBA.bank_account_id)
            AND  CBA.bank_branch_id = NVL(p_bank_branch_id, CBA.bank_branch_id)
            AND  CBA.bank_id = NVL(p_bank_id, CBA.bank_id)
            AND ((CBA.bank_account_type IS NULL AND p_acct_type IS NULL)
                OR CBA.bank_account_type = NVL(p_acct_type, CBA.bank_account_type))
            -- code should not be used in bank statement lines
            AND NOT EXISTS (
                SELECT NULL
                FROM ce_statement_lines CSL, ce_statement_headers CSH
                WHERE CSL.statement_header_id = CSH.statement_header_id
                AND  CSH.bank_account_id = CTC.bank_account_id
                AND  CSL.trx_type = CTC.trx_type
                AND  CSL.trx_code = CTC.trx_code)
            -- code should not be used in archived lines
            AND NOT EXISTS (
                SELECT NULL
                FROM ce_arch_lines CAL
                WHERE CAL.trx_code_id = CTC.transaction_code_id)
            -- code should not be used in statment cashflow mappings
            AND NOT EXISTS (
                SELECT NULL
                FROM ce_je_mappings JEM
                WHERE JEM.TRX_CODE_ID = CTC.TRANSACTION_CODE_ID
            )
            -- 8892534: code should not be used in intra-day statements
            AND NOT EXISTS (
                SELECT NULL
                FROM ce_intra_stmt_lines ISL
                WHERE ISL.trx_code_id = CTC.transaction_code_id
            )
            -- 8892534: code should not be used in archived intra-day statements
            AND NOT EXISTS (
                SELECT NULL
                FROM ce_arch_intra_lines ASL
                WHERE ASL.trx_code_id = CTC.transaction_code_id
            );

        debug_log('Deleting transaction codes');
        DELETE ce_transaction_codes CTC
        WHERE EXISTS(
            SELECT 1
            FROM ce_trx_codes_util_gt GT
            WHERE GT.trx_code_id = CTC.transaction_code_id);

        debug_log('<<CE_PURGE_TRX_CODES_XML.purge_trx_codes');

    END purge_trx_codes;

  /*========================================================================+
   | PUBLIC FUNCTION                                                        |
   |   beforeReport                                                         |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Before Report trigger for CEPUTXCD.                                  |
   |                                                                        |
   | CALLS                                                                  |
   |    CE_PURGE_TRX_CODES_XML.init_variables                               |
   |    CE_PURGE_TRX_CODES_XML.purge_trx_codes                              |
   +========================================================================*/
    FUNCTION beforeReport RETURN BOOLEAN IS
    BEGIN
        debug_log('>>CE_PURGE_TRX_CODES_XML.beforeReport');
        cep_standard.init_security;

        init_variables;

        purge_trx_codes;

        --store deleted codes
        SELECT count(*)
        INTO G_DELETE_COUNT
        FROM ce_trx_codes_util_gt GT
        WHERE GT.request_id = FND_GLOBAL.conc_request_id;

        debug_log('g_delete_count::'||g_delete_count);

        debug_log('<<CE_PURGE_TRX_CODES_XML.beforeReport');
        RETURN (TRUE);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            debug_log('EXCEPTION: CE_PURGE_TRX_CODES_XML.beforeReport trigger. Error : ' || SUBSTR(SQLERRM, 1, 200));
            RETURN (FALSE);
    END beforeReport;

  /*========================================================================+
   | PUBLIC FUNCTION                                                        |
   |   beforeReport                                                         |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   After Report trigger for CEPUTXCD. Once processing is done           |
   |   commit the changes and purge GT table                                |
   |                                                                        |
   | ARGUMENTS                                                              |
   +========================================================================*/
    FUNCTION afterReport RETURN BOOLEAN IS
    BEGIN
        debug_log('>>CE_PURGE_TRX_CODES_XML.afterReport');
        DELETE ce_trx_codes_util_gt;
        COMMIT;
        debug_log('<<CE_PURGE_TRX_CODES_XML.afterReport');
        RETURN (TRUE);
    END afterReport;

END CE_PURGE_TRX_CODES_XML;

/
