--------------------------------------------------------
--  DDL for Package Body FV_IPAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_IPAC" AS
        --$Header: FVIPPROB.pls 120.57.12010000.4 2009/10/26 11:43:45 snama ship $
        --IPAC FY2003-04
        gbl_gl_segment_name     VARCHAR2(30);
        gbl_gl_acc_value_set_id NUMBER;
        g_start_billing_id      NUMBER;
        g_end_billing_id        NUMBER;
        errcode                 NUMBER;
        errmsg                  VARCHAR2(1000);
        g_module_name           VARCHAR2(100) ;

PROCEDURE create_flat_file(p_statement  VARCHAR2,
                          p_set_of_books_id NUMBER,
                           p_customer_trx_id NUMBER);

FUNCTION get_sgl_exception(p_acct_num IN VARCHAR2,
                           p_sgl_acct_num OUT NOCOPY VARCHAR2) RETURN VARCHAR2 ;

PROCEDURE delete_records ;

                -- ------------------------------------
                -- Stored Input Parameters
                -- ------------------------------------
                parm_transaction_type  ra_cust_trx_types.cust_trx_type_id%TYPE;
                parm_profile_class_id  NUMBER;
                parm_customer_category hz_parties.category_code%TYPE;
                parm_customer_id       hz_parties.party_id%TYPE;
                parm_trx_date_low DATE;
                parm_trx_date_high DATE;
                parm_currency        ra_customer_trx.invoice_currency_code%TYPE;
                parm_contact_name    fv_ipac_trx_all.cnt_nm%TYPE;
                parm_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE;
                parm_org_id          fv_operating_units.org_id%TYPE;
                parm_contact_ph_no   VARCHAR2(17);
                -- ------------------------------------
                -- Stored Global Variables
                -- ------------------------------------
                v_segment          VARCHAR2(25);
                v_set_of_books_id  NUMBER(15);
                v_ledger_name      VARCHAR2(30);
                v_closing_status   VARCHAR2(1);
                v_bal_seg_name     VARCHAR2(25);
                v_treasury_symbol  fv_treasury_symbols.treasury_symbol%TYPE;
                v_boolean          BOOLEAN;
                flex_num           NUMBER;
                flex_code          VARCHAR2(60) ;
                apps_id            NUMBER ;
                seg_number         NUMBER;
                bl_seg_name        VARCHAR2(60);
                seg_app_name       VARCHAR2(60);
                seg_prompt         VARCHAR2(60);
                seg_value_set_name VARCHAR2(60);
                v_ccid             NUMBER;
                v_org_id           fv_operating_units.org_id%TYPE;
                v_sender_alc       fv_operating_units.alc_code%TYPE;
                v_default_alc      fv_operating_Units.alc_code%TYPE;
                --v_customer_alc   ap_bank_accounts.agency_location_code%TYPE; changed
                v_customer_alc      IBY_EXT_BANK_ACCOUNTS.agency_location_code%TYPE;
                v_receipt_method_id NUMBER;
                v_original_amount   NUMBER;
                v_paid_amount       NUMBER;
                trx_exception_flag  VARCHAR2(1) ;
                v_trx_excpt_cat     fv_ipac_trx_all.exception_category%TYPE;
                v_trx_exception     fv_ipac_trx_all.exception_category%TYPE;
                v_bulk_exception    fv_ipac_trx_all.bulk_exception%TYPE;
                v_pay_flag          VARCHAR2(1) ;
                v_invoice_currency  ra_customer_trx.invoice_currency_code%TYPE;
                -- Variables to populate who columns
                v_created_by   NUMBER(15);
                v_creation_date   DATE;
                v_last_updated_by  NUMBER(15);
                v_last_update_date  DATE;
                v_last_update_login  NUMBER(15);
                l_module_name        VARCHAR2(200) ;
                v_coa_id             NUMBER(15);
                p_status             VARCHAR2(1);
                -- ------------------------------------
                -- Cursors
                -- ------------------------------------
                -- Cursor to select the transaction info
                -- based on the input parameters
                CURSOR trx_select
        IS
                SELECT  rct.customer_trx_id,
                        hzca.cust_account_id customer_id,
                        --hzp.party_name customer_name,
                        rct.trx_number,
                        rct.trx_date,
                        rct.purchase_order,
                        rtt.TYPE,
                        arem.address_lines_phonetic,
                        ffc.eliminations_id,
                        rct.receipt_method_id,
                        rct.initial_customer_trx_id,
                        DECODE(hzp.PARTY_TYPE,'ORGANIZATION', hzp.DUNS_NUMBER_C,NULL) duns_number_c,
                        rsu.Cust_Acct_site_ID bill_to_address_id,
                        rct.invoice_currency_code
                FROM    hz_parties hzp,
                        hz_cust_accounts hzca,
                        ra_customer_trx rct,
                        ra_cust_trx_types rtt,
                        HZ_CUST_SITE_USES rsu ,
                        ar_remit_to_addresses_v arem,
                        fv_facts_customers_v ffc
                WHERE   hzp.party_id                        = hzca.party_id
                        AND rct.bill_to_customer_id         = hzca.cust_account_id
                        AND rct.set_of_books_id             = v_set_of_books_id
                        AND rct.complete_flag               = 'Y'
                        AND rtt.cust_trx_type_id            = rct.cust_trx_type_id
                        AND rsu.site_use_id                 = rct.bill_to_site_use_id
                        AND rct.remit_to_address_id         = arem.address_id
                        AND ffc.customer_id                 = hzca.cust_account_id
                        AND UPPER(hzca.customer_class_code) = 'FEDERAL'
                        AND rtt.TYPE                        = 'INV'
                        AND rct.cust_trx_type_id IN
                        (SELECT cust_trx_type_id
                        FROM    ra_cust_trx_types
                        WHERE   cust_trx_type_id =   DECODE(parm_transaction_type,NULL,   cust_trx_type_id,parm_transaction_type)
                        )
                        AND rct.bill_to_customer_id IN
                        (SELECT DISTINCT cust_account_id
                        FROM    hz_customer_profiles
                        WHERE   profile_class_id =   DECODE(parm_profile_class_id,NULL,   profile_class_id,   parm_profile_class_id)
                        )
                        AND hzca.cust_account_id IN
                        (
                                (SELECT hzca.cust_account_id
                                FROM    hz_parties hp,
                                        hz_cust_accounts hca
                                WHERE   hp.party_id = hca.party_id
                                        AND NVL(category_code,'XXX') LIKE   DECODE(parm_customer_category,NULL,   NVL(category_code,'XXX'),   parm_customer_category)
                                )
                                INTERSECT
                                (SELECT cust_account_id
                                FROM    hz_cust_accounts
                                WHERE   cust_account_id LIKE   DECODE(parm_customer_id,NULL, '%',parm_customer_id)
                                )
                        )
                        AND rct.trx_date BETWEEN   DECODE(parm_trx_date_low,NULL,   TO_DATE('1990/1/1', 'yyyy/mm/dd'),   parm_trx_date_low)   AND DECODE(parm_trx_date_high,NULL,TRUNC(SYSDATE),   parm_trx_date_high)
                        AND rct.invoice_currency_code = DECODE(parm_currency, NULL,   rct.invoice_currency_code, parm_currency);
                -- Cursor to select transaction detail line info
                -- based on the passed customer_trx_id
                -- Including the Receivable accounts
                -- to get the Receivable accounts outer joines are used
                CURSOR det_select(p_customer_trx_id VARCHAR2)
        IS
                SELECT  rctl.line_number,
                        rgld.acctd_amount,
                        rctl.quantity_invoiced,
                        rctl.description,
                        rgld.code_combination_id,
                        rctl.uom_code,
                        rctl.unit_selling_price,
                        fu.user_name,
                        rgld.percent,
                        rgld.account_class,
                        rctl.customer_trx_line_id
                FROM    ra_customer_trx_lines rctl,
                        ra_cust_trx_line_gl_dist rgld,
                        fnd_user fu
                WHERE   rgld.customer_trx_id             = p_customer_trx_id
                        AND rgld.customer_trx_id         = rctl.customer_trx_id(+)
                        AND rctl.customer_trx_line_id(+) = rgld.customer_trx_line_id
                        AND rctl.created_by              = fu.user_id(+)
                        AND rgld.set_of_books_id         = v_set_of_books_id
                        AND NOT EXISTS
                        (SELECT 'X'
                        FROM    fv_ipac_trx_all
                        WHERE   set_of_books_id     = v_set_of_books_id
                                AND org_id          = v_org_id
                                AND customer_trx_id = p_customer_trx_id
                                AND trx_line_no     = rctl.line_number
                        )
                        ;
                -- Cursor to select individual transactions which have not been yet processed
                -- for creating and applying receipts
                CURSOR trx_receipt_cur
        IS
                SELECT  SUM(amount) amount,
                        fit.customer_trx_id,
                        fit.trx_number,
                        fit.trx_date,
                        fit.customer_id,
                        fit.cash_receipt_id ,
                        fit.accounted_flag,
                        fit.cnt_nm
                FROM    fv_ipac_trx_all fit
                WHERE   fit.exclude_flag        = 'N'
                        AND set_of_books_id     = v_set_of_books_id
                        AND org_id              = v_org_id
                        AND fit.report_flag     = 'Y'
                        AND fit.processed_flag  = 'N'
                        AND  fit.account_class <>'REC'
                        AND fit.unt_iss        <> '~RA'
                        AND ( fit.cash_receipt_id IS NULL
                        OR ( fit.cash_receipt_id IS NOT NULL
                        AND NVL(fit.accounted_flag, 'N') <> 'Y' ))
                GROUP BY      fit.customer_trx_id ,
                        fit.trx_number,
                        fit.trx_date,
                        fit.customer_id,
                        fit.cash_receipt_id,
                        fit.accounted_flag,
                        fit.cnt_nm;
                -- Cursor to get all the SLA accounts generated for a particular distribution
                -- of a transaction after SLA accounting generation
                CURSOR xla_acnt_cur (p_ae_header_id NUMBER)
        IS
                SELECT  ae_header_id,
                        ae_line_num,
                        accounted_cr,
                        accounted_dr,
                        accounting_class_code,
                        code_combination_id
                FROM    xla_ae_lines
                WHERE   ae_header_id = p_ae_header_id;
                -- Cursor to get all the Receipt accounting information stored after receipt
                -- creation and SLA accounting generation
                -- grouped on the basis of customer_trx_id and treasury symbol
                -- for the purpose of bulk exception checking
                CURSOR trx_receipt_acct_cur
        IS
                SELECT  customer_trx_id,
                        snd_app_sym,
                        sgl_acct_num
                FROM    fv_ipac_trx_all
                WHERE   unt_iss             = '~RA'
                        AND set_of_books_id = v_set_of_books_id
                        AND org_id          = v_org_id
                        AND report_flag     = 'Y'
                        AND exclude_flag    = 'N'
                        AND processed_flag  = 'N'
                        AND accounted_flag  = 'Y'
                GROUP BY   customer_trx_id,
                        snd_app_sym;
                -- Cursor to get all the distinct customer_trx_ids
                -- whose receipt is already created and SLA accounting generated successfully
                CURSOR hdr_det(p_set_of_books_id NUMBER, p_org_id NUMBER)
        IS
                SELECT  DISTINCT customer_trx_id
                FROM    fv_ipac_trx_all trx
                WHERE   set_of_books_id    = p_set_of_books_id
                        AND org_id         = p_org_id
                        AND processed_flag = 'N'
                        AND exclude_flag   = 'N'
                        AND report_flag    = 'Y'
                        AND cash_receipt_id IS NOT NULL
                        AND accounted_flag = 'Y'
                        AND account_class <> 'REC'
                        AND unt_iss       <> '~RA'
                ORDER BY customer_trx_id;
                -- Cursor to get the customer transaction details record
                -- for bulk file creatation
                -- grouped by trx_line_no ,and account symbol
                CURSOR trx_detail_cur(p_cust_trx_id NUMBER)
        IS
                SELECT  SUM(fit.amount) amount,
                        fit.cnt_nm,
                        fit.cnt_phn_nr,
                        fit.contract_no,
                        fit.dpr_cd,
                        fit.dsc,
                        fit.trx_number,
                        fit.trx_date,
                        fit.trn_set_id,
                        fit.obl_dcm_nr,
                        fit.pay_flg,
                        fit.po_number,
                        SUM(fit.qty) qty,
                        fit.cust_duns_num,
                        fit.snd_app_sym,
                        fit.unt_iss,
                        fit.unt_prc,
                        fit.customer_trx_id,
                        fit.customer_id,
                        fit.taxpayer_number,
                        fit.trx_line_no trx_line_no,
                        fit.cash_receipt_id,
                        fit.sender_do_sym,
                        fit.sender_alc,
                        rct.comments comments
                FROM    fv_ipac_trx_all fit,
                        ra_customer_trx rct
                WHERE   fit.org_id              = v_org_id
                        AND fit.set_of_books_id = v_set_of_books_id
                        AND fit.customer_trx_id = p_cust_trx_id
                        AND fit.customer_trx_id = rct.customer_trx_id
                        AND fit.processed_flag  = 'N'
                        AND fit.exclude_flag    = 'N'
                        AND fit.report_flag     = 'Y'
                        AND fit.account_class  <>'REC'
                        AND fit.unt_iss        <> '~RA'
                GROUP BY fit.customer_trx_id,
                        fit.customer_id,
                        fit.taxpayer_number,
                        fit.trx_line_no,
                        fit.cash_receipt_id,
                        fit.snd_app_sym,
                        fit.cnt_nm,
                        fit.cnt_phn_nr,
                        fit.contract_no,
                        fit.dpr_cd,
                        fit.dsc,
                        fit.trx_number,
                        fit.trx_date,
                        fit.trn_set_id,
                        fit.obl_dcm_nr,
                        fit.pay_flg,
                        fit.po_number,
                        fit.cust_duns_num,
                        fit.unt_iss,
                        fit.unt_prc,
                        fit.sender_do_sym,
                        fit.sender_alc,
                        rct.comments
                ORDER BY fit.customer_trx_id,
                        fit.trx_line_no;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

                -- Procedure to initialize variables being used in the package
        PROCEDURE init_vars
        IS
                l_module_name VARCHAR2(200) ;
                errbuf        VARCHAR2(200);
        BEGIN
                l_module_name      := g_module_name || 'init_vars ';
                v_treasury_symbol  := NULL;
                v_original_amount  := 0;
                v_paid_amount      := 0;
                trx_exception_flag := 'N';
                v_trx_excpt_cat    := NULL;
                v_trx_exception    := NULL;
        EXCEPTION
        WHEN OTHERS THEN
                errbuf                        := SQLERRM;
                errbuf                        := 'When others ' || SQLERRM;
                IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                        l_module_name,        errbuf);
                END IF;
                RAISE;
        END ; --init_vars

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
        -- Procedure to delete exception records
        -- from fv_ipac_trx_all
PROCEDURE del_exception_recs
IS
        l_module_name VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name || 'del_exception_recs';
        DELETE
        FROM    fv_ipac_trx_all trx
        WHERE   set_of_books_id     = v_set_of_books_id
                AND NVL(org_id,-99) = NVL(v_org_id,-99)
                AND (report_flag    = 'N'
                OR ( report_flag    = 'Y'
                AND bulk_exception IS NOT NULL));
        COMMIT;
EXCEPTION
WHEN OTHERS THEN
        errcode                       := SQLCODE;
        errmsg                        := SQLERRM || ' -- Error IN deleleting the records'       || ' form IPAC TABLE PROCEDURE '       || ':- del_exception_recs' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,      l_module_name,      errmsg);
        END IF;
        RAISE;
END; -- del_exception_recs

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

PROCEDURE delete_records
IS
        l_module_name VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name || 'delete_records';
        DELETE
        FROM    fv_ipac_trx_all
        WHERE   set_of_books_id     = v_set_of_books_id
                AND NVL(org_id,-99) = NVL(v_org_id,-99)
                AND ipac_billing_id BETWEEN    g_start_billing_id AND      g_end_billing_id ;
EXCEPTION

WHEN NO_DATA_FOUND THEN
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                'No Records For Deletion ' );

WHEN OTHERS THEN
        errcode                       := SQLCODE;
        errmsg                        := SQLERRM || ' -- Error IN deleleting the records'       || ' form IPAC TABLE PROCEDURE '       || ':- delete_records' ;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END delete_records;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to get the balancing segment, GL Account segment name
PROCEDURE get_bal_seg_name
IS
        l_module_name VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name || 'get_bal_seg_name ';
        SELECT  chart_of_accounts_id
        INTO    flex_num
        FROM    gl_sets_of_books
        WHERE   set_of_books_id = v_set_of_books_id;
        v_boolean              := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(apps_id,flex_code,         flex_num,   'GL_BALANCING',         seg_number);
        IF (v_boolean) THEN
                v_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO(apps_id,         flex_code,flex_num,         seg_number,         bl_seg_name,      seg_app_name,         seg_prompt,         seg_value_set_name);
        END IF;
        ------------------------------------------------------------------
        -- IPAC FY2003-04
        ------------------------------------------------------------------
        -- Get the GL Account segment and the Value set ID  attached
        v_boolean:= FND_FLEX_APIS.GET_SEGMENT_COLUMN( apps_id,         flex_code,flex_num,         'GL_ACCOUNT',         gbl_gl_segment_name);
BEGIN
        SELECT  flex_value_set_id
        INTO    gbl_gl_acc_value_set_id
        FROM    fnd_id_flex_segments
        WHERE   application_column_name = gbl_gl_segment_name
                AND id_flex_code        = FLEX_CODE
                AND id_flex_num         = FLEX_NUM;
EXCEPTION
WHEN OTHERS THEN
        errcode := SQLCODE;
        errmsg  := SQLERRM ||' -- Error in geting the Value set ID '       || 'attached to the GL Account segment :'       || 'Procedure :- get_bal_seg_name' ;
        RAISE;
END;
Fv_Utility.Log_Mesg(FND_LOG.LEVEL_STATEMENT,      l_module_name,   'Chart of Accounts Id,Bal Segment,Acct Segment,Flex Value Set Id:'||    flex_num||','||bl_seg_name||','||gbl_gl_segment_name||','||    gbl_gl_acc_value_set_id);
EXCEPTION
WHEN OTHERS THEN
        IF errcode IS NULL THEN
                errcode := SQLCODE;
                errmsg  := SQLERRM ||' -- Error IN geting the Segment Name :'     || ' Procedure :- get_bal_seg_name' ;
        END IF;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,      l_module_name,      errmsg);
        END IF;
        RAISE;
END; -- get_bal_seg_name

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to get the treasury symbol
-- based on the passed balancing segment name
-- and account ccid
PROCEDURE get_treasury_symbol(lv_bal_seg_name IN VARCHAR2, v_ccid IN NUMBER)
IS
        l_module_name VARCHAR2(200);
BEGIN
        l_module_name := g_module_name || 'get_treasury_symbol';
        SELECT  fts.treasury_symbol
        INTO    v_treasury_symbol
        FROM    fv_fund_parameters ffp,
                fv_treasury_symbols fts,
                gl_code_combinations glc
        WHERE   DECODE(lv_bal_seg_name,     'SEGMENT1', glc.segment1, 'SEGMENT2', glc.segment2,   'SEGMENT3', glc.segment3, 'SEGMENT4',
glc.segment4,   'SEGMENT5', glc.segment5, 'SEGMENT6', glc.segment6,   'SEGMENT7', glc.segment7, 'SEGMENT8', glc.segment8,   'SEGMENT9',
glc.segment9, 'SEGMENT10',glc.segment10,   'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,   'SEGMENT13',glc.segment13,'SEGMENT14',
glc.segment14,   'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,   'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,   'SEGMENT19',
glc.segment19,'SEGMENT20',glc.segment20,   'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,   'SEGMENT23',glc.segment23,'SEGMENT24',
glc.segment24,   'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,   'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,   'SEGMENT29',
glc.segment29,   'SEGMENT30',glc.segment30) = ffp.fund_value
                AND glc.code_combination_id = v_ccid
                AND ffp.treasury_symbol_id  = fts.treasury_symbol_id
                AND ffp.set_of_books_id     = v_set_of_books_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
        v_treasury_symbol := '1';
WHEN OTHERS THEN
        errmsg                        := SQLERRM;
        errcode                       := SQLCODE;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END; -- get_treasury_symbol

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- Function to get the transaction exception category
-- based on the passed transaction record values
FUNCTION get_trx_exception(     transaction_rec IN OUT NOCOPY fv_ipac_trx_all%ROWTYPE,     p_cust_trx_line_id NUMBER,     p_bill_to_address_id NUMBER)   RETURN VARCHAR2
IS
        l_sgl_acct_num gl_code_combinations.segment1%TYPE;
BEGIN
        v_trx_excpt_cat := NULL;
        -- Get the exception only if the account class is not REC
        IF transaction_rec.account_class                         <> 'REC' THEN -- REC check
                IF (v_receipt_method_id IS NULL AND v_default_alc = 'N') THEN  --RM check
                        v_trx_excpt_cat                          := 'MISSING_PAYMENT_METHOD';
                        IF (FND_LOG.LEVEL_STATEMENT              >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,        l_module_name,        'MISSING_PAYMENT_METHOD');
                        END IF;
--
/*
                ELSIF v_receipt_method_id IS NOT NULL THEN                    --RM check
                        BEGIN

                            SELECT aba.agency_location_code
                            INTO v_sender_alc
                            FROM ar_receipt_method_accounts_all arma,
                            ap_bank_accounts aba
                            WHERE aba.bank_account_id = arma.bank_account_id
                            AND aba.currency_code = nvl(parm_currency,v_invoice_currency)
                            AND arma.primary_flag = 'Y'
                            AND arma.receipt_method_id = v_receipt_method_id;

                            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                            THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                l_module_name,'receipt_method_id IS NOT null,
                                v_sender_alc ='|| v_sender_alc);
                            END IF;

                            IF v_sender_alc IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_BANK_ACCT_ALC';
                                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                                THEN
                                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                    l_module_name,'MISSING_BANK_ACCT_ALC');
                                END IF;
                            END IF;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            IF  v_default_alc <> 'N' THEN
                                v_sender_alc := v_default_alc;

                                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                                THEN
                                       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                        l_module_name,'no data and DEFAULT alc v_sender_alc ='
                                        || v_sender_alc);
                                END IF;
                             ELSE
                                v_trx_excpt_cat := 'MISSING_BANK_ACCT_ALC';
                                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                                THEN
                                    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
                                    l_module_name,'MISSING_BANK_ACCT_ALC');
                                END IF;
                            END IF;
                        WHEN OTHERS THEN
                            errmsg := SQLERRM||'-- Error in Get_Trx_Exception when
                            getting the ALC,when receipt method is not null';
                            IF ( FND_LOG.LEVEL_UNEXPECTED >=
                            FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                                l_module_name,errmsg);
                            END IF;
                                RAISE;
                            END;
                            ELSIF (v_receipt_method_id IS NULL AND v_default_alc <> 'N')
                                THEN        --RM check
                                v_sender_alc := v_default_alc;
                                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                                THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
                                'Receipt Method is null and sender ALC ='|| v_sender_alc);
                                END IF;
*/

--
                END IF; -- end if for alc check              --RM check
                IF v_trx_excpt_cat IS NULL THEN
                        -- no exceptions found above so continue checking for exception
                        --find customer alc on the bill to customer account.
                        -- using the BILL_TO site to determine bank account assigned.
                        --Bug9025655.  Since there could be multiple bank accounts
		        --without end dates, this select will bring in multiple rows.
			--Restricting to fetch one row.
                        BEGIN
                                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                   'Customer ID = ' || transaction_rec.customer_id     ||
				   ' p_bill_to_address_id = ' || p_bill_to_address_id);
                                SELECT  eb.agency_location_code
                                INTO    v_customer_alc
                                FROM    hz_cust_acct_sites_all hzcas,
                                        hz_cust_site_uses_all hzcsu,
                                        iby_external_payers_all payer,
                                        iby_pmt_instr_uses_all iby_ins,
                                        iby_ext_bank_accounts_v eb
                                WHERE   hzcas.cust_account_id       = transaction_rec.customer_id
                                        AND hzcas.cust_acct_site_id = p_bill_to_address_id
                                        AND hzcsu.cust_acct_site_id =hzcas.cust_acct_site_id
                                        AND hzcsu.site_use_code     = 'BILL_TO'
                                        AND hzcsu.site_use_id       = payer.acct_site_use_id
                                        AND payer.ext_payer_id      = iby_ins.ext_pmt_party_id
                                        AND iby_ins.instrument_type = 'BANKACCOUNT'
                                        AND transaction_rec.trx_date BETWEEN
					       iby_ins.start_date AND
                                                NVL(iby_ins.end_date, TO_DATE('12/31/9999', 'MM/DD/YYYY'))
                                        AND iby_ins.instrument_id   = eb.ext_bank_account_id
                                        AND rownum = 1;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,     l_module_name,     'MISSING_CUST_ALC-No Primary Bank AcctDefined');
                                END IF;
                                v_trx_excpt_cat := 'MISSING_CUST_ALC';
                        END;
                        IF v_customer_alc IS NULL THEN
                                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,     'MISSING_CUST_ALC - No ALC defined');
                                END IF;
                                v_trx_excpt_cat := 'MISSING_CUST_ALC';
                        END IF;
                END IF; -- end customer alc check
                IF v_trx_excpt_cat IS NULL THEN
                        -- no exceptions found above so continue checking for exception
                        IF transaction_rec.cnt_nm IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_ALC_CONTACT';
                        ELSIF transaction_rec.sender_do_sym IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_DO_SYM';
                        ELSIF transaction_rec.trx_number IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_INV_NUM';
                        ELSIF transaction_rec.po_number IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_PO_NUM';
                        ELSIF transaction_rec.obl_dcm_nr IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_OBL_DOC_NUM';
                        ELSIF transaction_rec.qty IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_QUANTITY';
                        ELSIF transaction_rec.unt_prc IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_UNIT_PRICE';
                        ELSIF transaction_rec.unt_iss IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_UNIT_OF_ISSUE';
                        ELSIF transaction_rec.amount IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_AMOUNT';
                        ELSIF transaction_rec.pay_flg IS NULL THEN
                                v_trx_excpt_cat := 'MISSING_PAY_FLAG';
                        ELSIF transaction_rec.dpr_cd IS NULL THEN
                                v_trx_excpt_cat                                                      := 'MISSING_RCVR_DEPT_CODE';
                        ELSIF (transaction_rec.snd_app_sym IS NULL) OR   (transaction_rec.snd_app_sym = '1') THEN
                                v_trx_excpt_cat                                                      := 'MISSING_SNDR_APP_SYM';
                        ELSE
                                NULL;
                        END IF;
                END IF;
        END IF;-- End if account_class <> 'REC'
        RETURN v_trx_excpt_cat;
EXCEPTION
WHEN OTHERS THEN
        errmsg                        :=SQLERRM;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END ;  -- get_trx_exception

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to insert transaction records
PROCEDURE insert_trx_rec(ins_trx IN fv_ipac_trx_all%ROWTYPE)
IS
        v_trx_billing_id  NUMBER;
        v_trx_excl_flag   VARCHAR2(1) ;
        v_trx_proc_flag   VARCHAR2(1) ;
        l_module_name     VARCHAR2(200) ;
BEGIN
        v_trx_excl_flag := 'N';
        v_trx_proc_flag := 'N';
        l_module_name   := g_module_name || 'insert_trx_rec';
        SELECT fv_ipac_billing_id_s.NEXTVAL    INTO v_trx_billing_id    FROM dual;
        INSERT
        INTO    fv_ipac_trx_all
                (
                        set_of_books_id,
                        org_id,
                        run_date,
                        ipac_billing_id,
                        taxpayer_number,
                        sender_do_sym,
                        trn_set_id,
                        amount,
                        cnt_nm,
                        cnt_phn_nr,
                        dpr_cd,
                        dsc,
                        trx_number,
                        trx_date,
                        obl_dcm_nr,
                        pay_flg,
                        po_number,
                        qty,
                        snd_app_sym,
                        unt_iss,
                        unt_prc,
                        exception_category,
                        customer_trx_id,
                        customer_id,
                        report_flag,
                        trx_line_no,
                        exclude_flag,
                        processed_flag,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        contract_no,
                        cust_duns_num,
                        sgl_acct_num,
                        cr_dr_flag,
                        account_class
                )
                VALUES
                (
                        v_set_of_books_id,
                        v_org_id,
                        TRUNC(SYSDATE),
                        v_trx_billing_id,
                        ins_trx.taxpayer_number,
                        ins_trx.sender_do_sym,
                        ins_trx.trn_set_id,
                        ins_trx.amount,
                        NVL(ins_trx.cnt_nm,-99),
                        parm_contact_ph_no,
                        ins_trx.dpr_cd,
                        ins_trx.dsc,
                        ins_trx.trx_number,
                        ins_trx.trx_date,
                        ins_trx.obl_dcm_nr,
                        ins_trx.pay_flg,
                        ins_trx.po_number,
                        ins_trx.qty,
                        ins_trx.snd_app_sym,
                        ins_trx.unt_iss,
                        ins_trx.unt_prc,
                        ins_trx.exception_category,
                        ins_trx.customer_trx_id,
                        ins_trx.customer_id,
                        ins_trx.report_flag,
                        ins_trx.trx_line_no,
                        v_trx_excl_flag,
                        v_trx_proc_flag,
                        v_created_by,
                        v_creation_date,
                        v_last_updated_by,
                        v_last_update_date,
                        v_last_update_login,
                        ins_trx.contract_no,
                        ins_trx.cust_duns_num,
                        ins_trx.sgl_acct_num,
                        ins_trx.cr_dr_flag,
                        ins_trx.account_class
                )
                ;
EXCEPTION
WHEN OTHERS THEN
        errcode := SQLCODE;
        errmsg  := SQLERRM || ' -- Error in inserting the data into'     ||
         '  FV_IPAC_TRX_ALL table : Procedure :- insert_trx_rec';
        RAISE;
END;  -- insert_trx_rec

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- IPAC FY2003-04
-- Procedure to get the GL Account Value
-- Parameter    : Code combination Id
-- Return Value : GL Account Number
FUNCTION gl_account_num(p_ccid NUMBER) RETURN VARCHAR2
IS
        l_gl_account_num gl_code_combinations.segment1%TYPE;
        l_module_name          VARCHAR2(200);
BEGIN
           l_module_name:=g_module_name||'gl_account_num';

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'gl_account_num begins');


        SELECT  DECODE (gbl_gl_segment_name,
                        'SEGMENT1',glc.segment1,
                        'SEGMENT2', glc.segment2,    'SEGMENT3',
                        glc.segment3, 'SEGMENT4',
                        glc.segment4,    'SEGMENT5',
                        glc.segment5, 'SEGMENT6',
                        glc.segment6,      'SEGMENT7',
                        glc.segment7, 'SEGMENT8',
                        glc.segment8,    'SEGMENT9',
                        glc.segment9, 'SEGMENT10',
                        glc.segment10,   'SEGMENT11',
                        glc.segment11,'SEGMENT12',
                        glc.segment12,      'SEGMENT13',
                        glc.segment13,'SEGMENT14',
                        glc.segment14,      'SEGMENT15',
                        glc.segment15,'SEGMENT16',
                        glc.segment16,    'SEGMENT17',
                        glc.segment17,'SEGMENT18',
                        glc.segment18,   'SEGMENT19',
                        glc.segment19,'SEGMENT20',
                        glc.segment20,   'SEGMENT21',
                        glc.segment21,'SEGMENT22',
                        glc.segment22,   'SEGMENT23',
                        glc.segment23,'SEGMENT24',
                        glc.segment24,   'SEGMENT25',
                        glc.segment25,'SEGMENT26',
                        glc.segment26,   'SEGMENT27',
                        glc.segment27,'SEGMENT28',
                        glc.segment28,   'SEGMENT29',
                        glc.segment29,'SEGMENT30',
                        glc.segment30)
        INTO    l_gl_account_num
        FROM    gl_code_combinations glc
        WHERE   code_combination_id          = p_ccid
                AND glc.chart_of_accounts_id = flex_num;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'l_gl_account_num = '||l_gl_account_num);

        RETURN l_gl_account_num;
EXCEPTION
WHEN OTHERS THEN
        errcode                       := SQLCODE;
        errmsg                        := SQLERRM
        || ' -- Error in getting the GL Account number :'
        || '  Funcation :- gl_account_num';

        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                l_module_name,       errmsg);
        END IF;
        RAISE;
END gl_account_num;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--Function to get the GL Account Type of the given CCID
FUNCTION gl_account_type(p_gl_account VARCHAR2) RETURN VARCHAR2
IS
        l_account_type VARCHAR2(1);
        l_module_name          VARCHAR2(200);
BEGIN
       l_module_name:=g_module_name||'gl_account_type';

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'gl_account_type begins');

        -- Account Type of the Code combination ID
        SELECT  SUBSTR(compiled_value_attributes, 5, 1)
        INTO    l_account_type
        FROM    fnd_flex_values
        WHERE   flex_value            = p_gl_account
                AND flex_value_set_id = gbl_gl_acc_value_set_id;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'l_account_type='||l_account_type);

        IF (FND_LOG.LEVEL_STATEMENT  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,
                'Account: '||p_gl_account ||     '  Account type: '|| l_account_type );
        END IF;
        RETURN l_account_type;
EXCEPTION
WHEN OTHERS THEN
        errcode                       :=SQLCODE;
        errmsg                        := SQLERRM
        || ' -- Error in getting the GL Account type  :'
        || '  Funcation :- gl_account_type';
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
                errmsg);
        END IF;
        RAISE;
END gl_account_type;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Function to get the USSGL Account of GL Account
-- The function will return the USSGL account is GL Account is valid
-- The Function will set the p_valid_falg to 'Y' is the passed SGL Account is
-- USSGL Account else to 'N''
FUNCTION get_ussgl_account(p_gl_account_num IN VARCHAR2,    p_valid_flag OUT NOCOPY VARCHAR2)    RETURN VARCHAR2
IS
        l_parent_gl_account_num gl_code_combinations.segment1%TYPE;
        l_enabled_flag          VARCHAR2(1);
BEGIN
        --Check for the Validity of the SGL Account
        SELECT  ussgl_enabled_flag
        INTO    l_enabled_flag
        FROM    fv_facts_ussgl_accounts
        WHERE   ussgl_account = p_gl_account_num;
        IF l_enabled_flag    <> 'Y' THEN
                -- SGL Account is not Enabled
                p_valid_flag :='N' ;
                RETURN p_gl_account_num;
        ELSE
                -- SGL Account is Enabled
                p_valid_flag :='Y' ;
                RETURN p_gl_account_num;
        END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
        -- Check for the Parent
        -- Check for the parent SGL Account
        BEGIN
                SELECT  parent_flex_value
                INTO    l_parent_gl_account_num
                FROM    fnd_flex_value_hierarchies
                WHERE   (p_gl_account_num BETWEEN child_flex_value_low    AND child_flex_value_high)
                        AND flex_value_set_id  = gbl_gl_acc_value_set_id
                        AND parent_flex_value <> 'T'
                        AND parent_flex_value IN
                        (SELECT ussgl_account
                        FROM    fv_facts_ussgl_accounts
                        WHERE   ussgl_account          = parent_flex_value
                                AND ussgl_enabled_flag ='Y'
                        )
                        ;
                -- Parent is a valid Account
                RETURN l_parent_gl_account_num;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                -- No parent USSGL account is defined
                p_valid_flag := 'N';
                RETURN p_gl_account_num;
        WHEN TOO_MANY_ROWS THEN
                -- More than one parent exist
                p_valid_flag := 'N';
                RETURN p_gl_account_num;
        END ;
WHEN OTHERS THEN
        errcode                       := SQLCODE;
        errmsg                        := SQLERRM || ' -- Error in geting the USSGL Account :'       || '  Function :- get_ussgl_account';
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END get_ussgl_account;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--Function to get the SGL Exception
FUNCTION get_sgl_exception(p_acct_num VARCHAR2,     p_sgl_acct_num OUT NOCOPY VARCHAR2) RETURN VARCHAR2
IS
        l_sgl_acct_num gl_code_combinations.segment1%TYPE;
        l_valid_flag   VARCHAR2(1);
BEGIN
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       'IPAC FY2003-04 GET SGL EXCEPTION');
        END IF;
        -- Checking for the Account type
        -- If the account type is budgetary Cr/Dr and account class
        -- is equal to the REC then return the exception else return the
        -- type in exception category
        IF gl_account_type(p_acct_num) IN('C','D') THEN
                RETURN 'BUDGETARY';
        END IF ;
        -- Get the  USSGL Number and the Valid Flag
        p_sgl_acct_num := get_ussgl_account(p_acct_num,l_valid_flag);
        IF l_valid_flag = 'N' THEN
                -- Invalid USSGL Account
                IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL    THEN
                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,        l_module_name,      'Exception SGL Account - Invalid SGL Account: ' ||       l_sgl_acct_num);
                END IF;
                RETURN 'INVALID_SGL_ACCOUNT';
        END IF;
        -- No SGL Exception
        RETURN NULL;
EXCEPTION
WHEN OTHERS THEN
        errcode                       :=SQLCODE;
        errmsg                        :=SQLERRM|| ' -- Error in getting the USSGL Exception Function '     || ' - get_sgl_exception';
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END get_sgl_exception;
/*
-- Procedure to create REC line equal to a detail lines for each transaction
PROCEDURE equalize_rec_lines IS
-- cursor to get the customer_trx_id and  and treasury Symbol
CURSOR trx_cur IS
SELECT customer_trx_id ,
snd_app_sym
FROM  fv_ipac_trx_all
WHERE  processed_flag ='N'
AND   set_of_books_id = v_set_of_books_id
AND   org_id = v_org_id
AND   exclude_flag ='N'
AND   unt_iss <> '~RA'
AND   ipac_billing_id BETWEEN
g_start_billing_id AND
g_end_billing_id
GROUP BY  customer_trx_id,
snd_app_sym;
-- cursor to get all the revenue lines and their respective amounts
-- for a particular transaction excluding RA lines
CURSOR trx_rec_cur (p_customer_trx_id NUMBER,
p_snd_app_sym VARCHAR2 )
IS  SELECT trx_line_no,
SUM(amount) amount
FROM   fv_ipac_trx_all
WHERE   org_id = v_org_id
AND     set_of_books_id = v_set_of_books_id
AND     processed_flag ='N'
AND   customer_trx_id = p_customer_trx_id
AND    snd_app_sym = p_snd_app_sym
AND   account_class <> 'REC'
AND   unt_iss <> '~RA'
AND    set_of_books_id = v_set_of_books_id
AND    exclude_flag ='N'
GROUP BY  trx_line_no ;
l_trx_rec       FV_IPAC_TRX_ALL%ROWTYPE;
l_module_name         VARCHAR2(200)  ;
BEGIN
l_module_name        :=  g_module_name ||'equalize_rec_lines';
FOR trx_rec IN trx_cur
LOOP
FOR trx_rec_rec IN trx_rec_cur(trx_rec.customer_trx_id ,
trx_rec.snd_app_sym )
LOOP
SELECT * INTO l_trx_rec
FROM fv_ipac_trx_all
WHERE org_id = v_org_id
AND set_of_books_id = v_set_of_books_id
AND customer_trx_id = trx_rec.customer_trx_id
AND account_class = 'REC';
l_trx_rec.snd_app_sym := trx_rec.snd_app_sym ;
l_trx_rec.amount := trx_rec_rec.amount ;
l_trx_rec.unt_iss := '~R~';
l_trx_rec.trx_line_no := trx_rec_rec.trx_line_no ;
insert_trx_rec(l_trx_rec);
END LOOP;
END LOOP;
END equalize_rec_lines;
*/

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to find out the exceed_cr_dr_exception and
-- SGL Accounts SUM mismatch
PROCEDURE exceed_dr_cr_sgl_mismatch_exc
IS
        -- cursor to get the customer_trx_id and  and treasury Symbol
        CURSOR trx_cur
IS
        SELECT  customer_trx_id ,
                snd_app_sym
        FROM    fv_ipac_trx_all
        WHERE   processed_flag      ='N'
                AND org_id          = v_org_id
                AND set_of_books_id = v_set_of_books_id
                AND exclude_flag    ='N'
                AND unt_iss        <> '~RA'
                AND accounted_flag  ='Y'
                AND report_flag     ='Y'
        GROUP BY customer_trx_id,
                snd_app_sym;
        /*   AND     ipac_billing_id BETWEEN
        g_start_billing_id AND
        g_end_billing_id
        GROUP BY customer_trx_id,
        snd_app_sym;
        */
        -- cursor to get all the revenue lines and their respective amounts
        -- for a particular transaction excluding RA lines
        CURSOR trx_rec_cur (p_customer_trx_id NUMBER,      p_snd_app_sym VARCHAR2 )
IS
        SELECT  trx_line_no,
                SUM(amount) amount
        FROM    fv_ipac_trx_all
        WHERE   org_id              = v_org_id
                AND set_of_books_id = v_set_of_books_id
                AND processed_flag  ='N'
                AND customer_trx_id = p_customer_trx_id
                AND snd_app_sym     = p_snd_app_sym
                AND account_class  <> 'REC'
                AND unt_iss        <> '~RA'
                AND exclude_flag    ='N'
        GROUP BY trx_line_no ;
        -- Cursor to count the no of accounts
        CURSOR trx_lines_cur (p_customer_trx_id NUMBER,      P_snd_app_sym VARCHAR2 )
IS
        SELECT  COUNT(1) trx_count
        FROM    fv_ipac_trx_all
        WHERE   org_id              = v_org_id
                AND set_of_books_id = v_set_of_books_id
                AND customer_trx_id = p_customer_trx_id
                AND snd_app_sym     = p_snd_app_sym
                AND unt_iss         = '~RA'
                AND processed_flag  ='N'
                AND exclude_flag    ='N'
        GROUP BY trx_line_no ;
        l_total_count    NUMBER;
        l_amount         NUMBER;
        l_count_sgl_acct NUMBER;
        l_module_name    VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name ||   'exceed_dr_cr_sgl_mismatch_exc';
        FOR trx_rec IN trx_cur
        LOOP
                -- Check if the Sum of SGL Cr/Dr accounts is equal to the detail record
                -- If not raise an exception 'SGL_SUM_MISMATCH'
                SELECT  SUM(DECODE(cr_dr_flag,'D',ABS(amount),0)) -    SUM(DECODE(cr_dr_flag,'C',ABS(amount),0)),
                        COUNT(sgl_acct_num)
                INTO    l_amount,
                        l_count_sgl_acct
                FROM    fv_ipac_trx_all
                WHERE   set_of_books_id      = v_set_of_books_id
                        AND org_id           = v_org_id
                        AND customer_trx_id  = trx_rec.customer_trx_id
                        AND (bulk_exception <> 'BUDGETARY'
                        AND bulk_exception IS NULL)
                        AND unt_iss        = '~RA'
                        AND snd_app_sym    = trx_rec.snd_app_sym;
                IF MOD(l_count_sgl_acct,2) = 0 AND l_amount <> 0 THEN
                        UPDATE fv_ipac_trx_all
                                SET bulk_exception = 'SGL_SUM_MISMATCH',
                                report_flag        ='N' ,
                                amount             =
                                (SELECT SUM(amount)
                                FROM    fv_ipac_trx_all
                                WHERE   set_of_books_id     = v_set_of_books_id
                                        AND org_id          = v_org_id
                                        AND customer_trx_id =trx_rec.customer_trx_id
                                        AND ACCOUNT_CLASS  <> 'REC'
                                        AND unt_iss        <> '~RA'
                                )
                        WHERE   set_of_books_id     = v_set_of_books_id
                                AND org_id          = v_org_id
                                AND customer_trx_id = trx_rec.customer_trx_id
                                AND snd_app_sym     =trx_rec.snd_app_sym
                                AND (bulk_exception IS NULL
                                AND bulk_exception <> 'BUDGETARY')
                                AND unt_iss         = '~RA';
                END IF;
                -- Check for more than 8 SGL accounts for each  detail record
                -- (customer Trx ID , treasury Symbol and line number)
                l_total_count := 0;
                FOR trx_lines_rec IN trx_lines_cur(trx_rec.customer_trx_id ,    trx_rec.snd_app_sym )
                LOOP
                        IF trx_lines_rec.trx_count > 8 THEN
                                UPDATE fv_ipac_trx_all
                                        SET bulk_exception = 'EXCEED_DR_CR',
                                        report_flag        ='N' ,
                                        amount             =
                                        (SELECT SUM(amount)
                                        FROM    fv_ipac_trx_all
                                        WHERE   set_of_books_id     = v_set_of_books_id
                                                AND org_id          = v_org_id
                                                AND customer_trx_id =trx_rec.customer_trx_id
                                                AND ACCOUNT_CLASS  <> 'REC'
                                                AND unt_iss        <> '~RA'
                                        )
                                WHERE   set_of_books_id     = v_set_of_books_id
                                        AND org_id          = v_org_id
                                        AND customer_trx_id =trx_rec.customer_trx_id
                                        AND snd_app_sym     =trx_rec.snd_app_sym
                                        AND (bulk_exception IS NULL
                                        AND bulk_exception <> 'BUDGETARY')
                                        AND unt_iss         = '~RA';
                        END IF ;
                END LOOP;
        END LOOP;
EXCEPTION
WHEN OTHERS THEN
        errcode                       :=SQLCODE;
        errmsg                        := SQLERRM || ' -- Error IN getting'     ||' the EXCEED_CR_DR EXCEPTION :'      ||' PROCEDURE :- exceed_dr_cr_count_exception';
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END exceed_dr_cr_sgl_mismatch_exc;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

PROCEDURE main (errbuf OUT NOCOPY VARCHAR2,
                retcode OUT NOCOPY VARCHAR2,
                profile_class_id VARCHAR2,
                customer_category VARCHAR2,
                customer_id VARCHAR2,
                transaction_type VARCHAR2,
                trx_date_low VARCHAR2,
                trx_date_high VARCHAR2,
                contact_ph_no VARCHAR2)
IS
        l_req_id                 NUMBER;
        l_call_status            BOOLEAN ;
        rphase                   VARCHAR2(30);
        rstatus                  VARCHAR2(30);
        dphase                   VARCHAR2(30);
        dstatus                  VARCHAR2(30);
        message                  VARCHAR2(240);
        l_valid_flag             VARCHAR2(1);
        l_ignore_budgetary_flag  VARCHAR2(1);
        l_drcr_acct              Gl_Ussgl_Account_Pairs.dr_account_segment_value%TYPE;
        trx_rec                  fv_ipac_trx_all%ROWTYPE;
        v_commitment_id          ra_customer_trx_all.initial_customer_trx_id%TYPE;
        l_sgl_acct_num           gl_code_combinations.segment1%TYPE;
        l_module_name            VARCHAR2(200) ;
        l_bill_to_address_id     Number;
BEGIN
        l_module_name := g_module_name || 'main';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,     'Input parameters are :');
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'PROFILE_CLASS_ID :'||profile_class_id);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       'CUSTOMER_CATEGORY :'||customer_category);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'CUSTOMER_ID :'||Customer_id);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'TRANSACTION_TYPE :'||transaction_type);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'TRX_DATE_LOW :'||trx_date_low);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'TRX_DATE_HIGH :'||trx_date_high);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'CONTACT_PH_NO :'||contact_ph_no);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'CURRENCY :'||parm_currency);
        -- Assign parameter values to variables
        parm_transaction_type  := transaction_type;
        parm_profile_class_id  := profile_class_id;
        parm_customer_category := customer_category;
        parm_customer_id       := customer_id;
        parm_trx_date_low      := fnd_date.canonical_to_date(trx_date_low);
        parm_trx_date_high     := fnd_date.canonical_to_date(trx_date_high);
        -- parm_currency      := currency;
        parm_contact_ph_no  := contact_ph_no;
        -- Assign values to who column variables
        v_created_by        := fnd_global.user_id;
        v_creation_date     := SYSDATE;
        v_last_updated_by   := fnd_global.user_id;
        v_last_update_date  := SYSDATE;
        v_last_update_login := fnd_global.login_id;
        del_exception_recs;
        get_bal_seg_name;
        Fv_Utility.Log_Mesg(FND_LOG.LEVEL_STATEMENT,l_module_name,    'Default ALC is '||v_default_alc);
        --get the start of billing Id
        SELECT fv_ipac_billing_id_s.NEXTVAL+1    INTO g_start_billing_id    FROM dual ;
        FOR trx_select_rec IN trx_select
        LOOP -- trx_select
                init_vars;
                v_receipt_method_id     := trx_select_rec.receipt_method_id;
                trx_rec.taxpayer_number := NULL;
                trx_rec.sender_do_sym   := trx_select_rec.address_lines_phonetic;
                trx_rec.dpr_cd          := trx_select_rec.eliminations_id;
                trx_rec.trx_number      := trx_select_rec.trx_number;
                trx_rec.trx_date        := trx_select_rec.trx_date;
                trx_rec.obl_dcm_nr      := trx_select_rec.trx_number;
                trx_rec.pay_flg         := v_pay_flag;
                trx_rec.po_number       := trx_select_rec.purchase_order;
                trx_rec.customer_trx_id := trx_select_rec.customer_trx_id;
                trx_rec.customer_id     := trx_select_rec.customer_id;
                --trx_rec.customer_name := trx_select_rec.customer_name;
                l_bill_to_address_id  := trx_select_rec.bill_to_address_id;
                v_commitment_id       := trx_select_rec.initial_customer_trx_id;
                -------------------------------------------------------
                --IPAC FY2003 -04
                trx_rec.cust_duns_num := trx_select_rec.duns_number_c;
                v_invoice_currency    := trx_select_rec.invoice_currency_code;
                --------------------------------------------------------
                IF v_commitment_id IS NULL THEN
                        trx_rec.contract_no := NULL;
                ELSE
                        SELECT  trx_number
                        INTO    trx_rec.contract_no
                        FROM    Ra_Customer_Trx
                        WHERE   customer_trx_id = v_commitment_id;
                END IF;
                Fv_Utility.Log_Mesg(FND_LOG.LEVEL_STATEMENT,      l_module_name,    'Processing Transaction:'||trx_rec.trx_number);
                SELECT  SUM(amount_due_original),
                        SUM(NVL(amount_adjusted,0)+ NVL(amount_credited,0)+     NVL(amount_due_remaining,0) + NVL(amount_applied,0))
                INTO    v_original_amount,
                        v_paid_amount
                FROM    ar_payment_schedules
                WHERE   customer_trx_id     = trx_select_rec.customer_trx_id
                        AND org_id          = v_org_id;
                IF v_original_amount        < v_paid_amount THEN
                        trx_exception_flag := 'Y';
                END IF;
                DELETE
                FROM    fv_ipac_trx_all
                WHERE   customer_trx_id    = trx_select_rec.customer_trx_id
                        AND processed_flag = 'N'
                        AND exclude_flag   = 'N'
                        AND cash_receipt_id IS NULL
                        AND set_of_books_id = v_set_of_books_id
                        AND NVL(org_id,-99) = NVL(v_org_id,-99);
                FOR det_select_rec IN det_select(trx_select_rec.customer_trx_id)
                LOOP -- detail_select
                        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       '---- DETAILS -------');
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       'Trx Number: '||trx_select_rec.trx_number);
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       'Trx Date: '||trx_select_rec.trx_date);
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       'Amount: '||det_select_rec.acctd_amount);
                        END IF;
                        get_treasury_symbol(bl_seg_name,      det_select_rec.code_combination_id);
                        trx_rec.trn_set_id    := 810;
                        trx_rec.amount        := det_select_rec.acctd_amount;
                        trx_rec.cnt_nm        := det_select_rec.user_name;
                        trx_rec.dsc           := det_select_rec.description;
                        trx_rec.qty           := ROUND(det_select_rec.quantity_invoiced *      (det_select_rec.percent/100),2);
                        trx_rec.snd_app_sym   := v_treasury_symbol;
                        trx_rec.unt_iss       := det_select_rec.uom_code;
                        trx_rec.unt_prc       := det_select_rec.unit_selling_price;
                        trx_rec.trx_line_no   := det_select_rec.line_number;
                        trx_rec.account_class := det_select_rec.account_class;
                        trx_rec.sgl_acct_num  := gl_account_num(det_select_rec.code_combination_id);
                        Fv_Utility.Log_Mesg(FND_LOG.LEVEL_STATEMENT,l_module_name,    'Account Class,Trx Line No,SGL Acct Num = '||    trx_rec.account_class||','||trx_rec.trx_line_no||','||    trx_rec.sgl_acct_num);
                        -- Get the exception category
                        trx_rec.exception_category := get_trx_exception(trx_rec,        det_select_rec.customer_trx_line_id,        l_bill_to_address_id);
                        trx_rec.taxpayer_number    := v_customer_alc;
                        -- Set the Debit/Credit Flag based on the
                        -- Account Class and sign
                        IF (det_select_rec.account_class = 'REV' AND     SIGN(det_select_rec .acctd_amount) =1)    OR (det_select_rec.account_class = 'REC' AND     SIGN(det_select_rec .acctd_amount) =-1 )    THEN
                                trx_rec.cr_dr_flag      := 'C';
                        ELSE
                                trx_rec.cr_dr_flag := 'D';
                        END IF;
                        IF trx_rec.exception_category IS NULL THEN
                                trx_rec.report_flag := 'Y';
                        ELSE
                                trx_rec.report_flag := 'N';
                        END IF;
                        IF trx_rec.account_class = 'REC' THEN
                                trx_rec.unt_iss := '~~R' ;
                        END IF;
                        insert_trx_rec(trx_rec);
                        init_vars;
                END LOOP; -- detail_select
        END LOOP;         -- trx_SELECT
        --get the end of billing id
        SELECT fv_ipac_billing_id_s.CURRVAL   INTO g_end_billing_id   FROM dual;
        -- To create REC line equal to a detail lines for each transaction
        --     equalize_rec_lines;
        -- UPDATE the fv_ipac_trx_all with report flag ='N'
        -- FOR each distibution line of a transaction
        -- if any of the distibution line has an exception
        UPDATE fv_ipac_trx_all trx
                SET report_flag     ='N'
        WHERE   org_id              = v_org_id
                AND set_of_books_id = v_set_of_books_id
                AND report_flag    <> 'N'
                AND EXISTS
                (SELECT 'X'
                FROM    fv_ipac_trx_all
                WHERE   org_id              = v_org_id
                        AND set_of_books_id = v_set_of_books_id
                        AND customer_trx_id = trx.customer_trx_id
                        AND report_flag     = 'N'
                )
                ;
        COMMIT;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,     l_module_name,     'Process Complete');
        -- Submit the IPAC Detail Report
        l_req_id := FND_REQUEST.SUBMIT_REQUEST('FV',   'FVIPDTLR',   '',   '',   FALSE,   profile_class_id ,       customer_category ,
       customer_id,       transaction_type,       trx_date_low,       trx_date_high,       parm_currency,       v_set_of_books_id,
      v_org_id );
        -- if concurrent request submission failed then abort process
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,      'IPAC Detail Report Request ID ='       ||l_req_id);
        IF l_req_id      = 0 THEN
                errbuf  := 'Unable to Submit IPAC transaction Detail Report';
                retcode := '-1';
                ROLLBACK;
        ELSE
                COMMIT;
        END IF;
        IF retcode <> 0 THEN
                delete_records;
        END IF;
        -- Check status of completed concurrent program
        --   and if complete exit
        l_call_status   := fnd_concurrent.wait_for_request(     l_req_id,        10,        0,        rphase,        rstatus,        dphase,        dstatus,        message);
        IF l_call_status = FALSE THEN
                errbuf  := 'Can not wait for the status of IPAC '||   'Transaction Detail Report';
                retcode := '2';
        END IF;
        -- Submit the Exception report
        l_req_id := FND_REQUEST.SUBMIT_REQUEST('FV',   'FVIPEXCR',   '',   '',   FALSE,   v_set_of_books_id,        v_org_id );
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,      'IPAC TRANSACTION EXCEPTION Report '
	|| 'Request ID ='||l_req_id);
        -- if concurrent request submission failed then abort process
        IF l_req_id      = 0 THEN
                errbuf  := 'Unable to Submit IPAC Transaction '||   'Exception Report';
                retcode := '-1';
                ROLLBACK;
        ELSE
                COMMIT;
        END IF;
        IF retcode <> 0 THEN
                delete_records ;
        END IF;
        -- Check status of completed concurrent program
        --   and if complete exit
        l_call_status   := fnd_concurrent.wait_for_request(          l_req_id,           10,           0,           rphase,           rstatus,          dphase,          dstatus,           message);
        IF l_call_status = FALSE THEN
                errbuf  := 'Can not wait for the status of IPAC '||   'Transaction Exception Report';
                retcode := '-1';
        END IF;
        IF retcode <> 0 THEN
                delete_records ;
        END IF;
EXCEPTION
WHEN OTHERS THEN
        IF errcode IS NULL THEN
                errcode :=SQLCODE;
                errmsg  := SQLERRM || ' -- Error IN IPAC selection'       || ' process : Procedure :- main';
        END IF;
        retcode                       := errcode;
        errbuf                        := errmsg;
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,      l_module_name,      errmsg);
        END IF;
END; -- main
-------------------------------------------------------------------------------
---------------------------- End of Selection Process -------------------------
-------------------------------------------------------------------------------

-- Procedure to create File Id Record for the Bulk File
PROCEDURE create_file_id_rec
IS
        v_statement   VARCHAR2(200);
        l_module_name VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name ||   'create_file_id_rec';
        v_statement   := 'SELECT ''PCA    '' FROM dual';
        fv_flatfiles.create_flat_file(v_statement);
END ; -- create_file_id_rec

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to create Batch Header Record for the Bulk File
PROCEDURE create_batch_header(lv_set_of_books_id IN NUMBER)
IS
        CURSOR trx_hdr
IS
        SELECT  customer_trx_id
        FROM    fv_ipac_trx_all trx
        WHERE   set_of_books_id    = lv_set_of_books_id
                AND org_id         = v_org_id
                AND processed_flag = 'N'
                AND exclude_flag   = 'N'
                AND report_flag    = 'Y'
        GROUP BY customer_trx_id,
                trn_set_id;
        v_header_count      NUMBER ;
        v_detail_count      NUMBER ;
        v_total_count       NUMBER ; -- For file header and Batch Header
        l_total_ussgl_count NUMBER ;
        l_ussgl_count       NUMBER ;
        l_module_name          VARCHAR2(200);
        v_statement         VARCHAR2(2000);
BEGIN
        l_module_name:=g_module_name||'create_batch_header';
        v_header_count      := 0;
        v_detail_count      := 0;
        v_total_count       := 2; -- For file header and Batch Header
        l_total_ussgl_count :=0;
        l_ussgl_count       :=0;

        --  get the total no of customer transactions
        SELECT  COUNT(DISTINCT(customer_trx_id||trn_set_id))
        INTO    v_header_count
        FROM    fv_ipac_trx_all trx
        WHERE   set_of_books_id    = lv_set_of_books_id
                AND org_id         = v_org_id
                AND processed_flag = 'N'
                AND exclude_flag   = 'N'
                AND report_flag    = 'Y'
                AND account_class <> 'REC'
                AND unt_iss       <> '~RA'
                AND Bulk_Exception IS NULL
                AND cash_receipt_id IS NOT NULL
                AND accounted_flag='Y';

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'v_header_count = '||v_header_count);

        -- get the count of total ussgl accounts
        SELECT  COUNT(1)
        INTO    l_total_ussgl_count
        FROM    fv_ipac_trx_all trx
        WHERE   set_of_books_id = lv_set_of_books_id
                AND org_id      = v_org_id
                AND trx_line_no is NOT NULL
                AND unt_iss = '~RA'
		AND bulk_exception is NULL
                AND customer_trx_id IN
                (   SELECT customer_trx_id
                FROM    fv_ipac_trx_all trx
                WHERE   set_of_books_id    = lv_set_of_books_id
                        AND org_id         = v_org_id
                        AND processed_flag = 'N'
                        AND exclude_flag   = 'N'
                        AND report_flag    = 'Y'
                        AND account_class <> 'REC'
                        AND unt_iss       <> '~RA'
                        AND bulk_exception IS NULL
                        AND cash_receipt_id IS NOT NULL
                        AND accounted_flag='Y'
                )
                ;
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'l_total_ussgl_count = '||l_total_ussgl_count);

        --Geting the count of total detail record
        SELECT  COUNT(1)
        INTO    v_detail_count
        FROM
                (SELECT customer_trx_id
                FROM    fv_ipac_trx_all
                WHERE   processed_flag      = 'N'
                        AND set_of_books_id = lv_set_of_books_id
                        AND org_id          = v_org_id
                        AND exclude_flag    = 'N'
                        AND report_flag     = 'Y'
                        AND account_class  <> 'REC'
                        AND unt_iss        <> '~RA'
                GROUP BY      customer_trx_id,
                        trx_line_no,
                        snd_app_sym
                );

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'v_detail_count = '||v_detail_count);

        -- Multiply the detail Rec by 2 for Rec Records per detail record
        v_total_count :=v_total_count + v_header_count +       v_detail_count
        + l_total_ussgl_count;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'v_total_count = '||v_total_count);

        v_statement := 'SELECT ''B''||''IPAC'' || LPAD('
                ||       v_total_count||',8,''0'') ||
                RPAD('' '',19,'' '') FROM dual';
        fv_flatfiles.create_flat_file(v_statement);
EXCEPTION
WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,
                errmsg);
        END IF;
        RAISE;
END ; -- create_batch_header

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to create Transaction Header Record for the Bulk File
PROCEDURE create_trx_header(lv_set_of_books_id IN NUMBER,
                            lv_customer_trx_id IN NUMBER)
IS
        v_statement   VARCHAR2(2000);
        l_module_name VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name ||   'create_trx_header';
        -- Modified the format according to FV IPAC FY 2003-04
        v_statement :=
        'SELECT ''H''||
      LPAD(SUBSTR(fit.sender_alc,1,8),8,''0'')||
      REPLACE(TO_CHAR(SUM(fit.amount),''FM099999999999D00''),
    ''.'','''')||
      LPAD(SUBSTR(fit.taxpayer_number,1,8),8,'' '')||
      RPAD(SUBSTR(fit.sender_do_sym,1,5),5,'' '') ||
      fit.trn_set_id ||
                           RPAD(NVL(SUBSTR(rct.ct_reference, 1, 8), '' ''), 8, '' '')||
      RPAD('' '',2)
    FROM fv_ipac_trx fit,
                              ra_customer_trx rct
       WHERE fit.set_of_books_id = :b_set_of_books_id
                            AND rct.customer_trx_id = fit.customer_trx_id
       AND fit.processed_flag = ''N''
       AND fit.exclude_flag = ''N''
       AND fit.report_flag = ''Y''
       AND fit.account_class <> ''REC''
       AND fit.unt_iss  <> ''~RA''
       AND fit.customer_trx_id = :b_customer_trx_id
       GROUP BY fit.customer_trx_id,fit.sender_alc,
         fit.trn_set_id,
                fit.taxpayer_number,
         fit.sender_do_sym,rct.ct_reference
       ORDER BY fit.customer_trx_id, fit.trn_set_id'
        ;
        create_flat_file(v_statement,lv_set_of_books_id,         lv_customer_trx_id );
END ; -- create_trx_header

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- Procedure to create Transaction Detail Record for the Bulk File
PROCEDURE create_trx_dtl_rec(trx_details_rec trx_detail_cur%ROWTYPE)
IS
        l_module_name    VARCHAR2(200) ;
        l_trx_detail_rec VARCHAR2(8000);
BEGIN
        l_module_name := g_module_name ||   'create_trx_dtl_rec';
        -- Modified the format According to FV IPAC FY 2003-04
        SELECT 'D' ||    RPAD(' ',16)||RPAD(' ',12)||    REPLACE(TO_CHAR(trx_details_rec.amount,       'FM099999999999D00'),'.','')||
RPAD(SUBSTR(trx_details_rec.cnt_nm,1,60),60,' ') ||    RPAD(nvl(trx_details_rec.cnt_phn_nr,' '),17,' ')||RPAD(' ',6)||
DECODE(trx_details_rec.contract_no,NULL,RPAD(' ',17),     RPAD(SUBSTR(trx_details_rec.contract_no,1,17),17,' '))||
DECODE(trx_details_rec.dpr_cd,NULL,'  ',     RPAD(SUBSTR(trx_details_rec.dpr_cd,1,2),2,' '))||
DECODE(trx_details_rec.dsc,NULL,RPAD(' ',320),     RPAD(SUBSTR(trx_details_rec.dsc,1,320),320,' '))||    RPAD('0',8,'0')
||    DECODE(trx_details_rec.trx_number,NULL,RPAD(' ',22),     RPAD(SUBSTR(trx_details_rec.trx_number,1,22),22,' '))||
RPAD(' ',30)||RPAD(' ',20)||     RPAD(NVL(SUBSTR(trx_details_rec.comments, 1, 320),       ' '), 320, ' ')||
  DECODE(trx_details_rec.obl_dcm_nr,NULL,RPAD(' ',17),     RPAD(SUBSTR(trx_details_rec.obl_dcm_nr,1,17),17,' '))||
DECODE(trx_details_rec.pay_flg,NULL,' ', trx_details_rec.pay_flg)||    DECODE(trx_details_rec.po_number,NULL,RPAD(' ',22),
RPAD(SUBSTR(trx_details_rec.po_number,1,22),22,' '))||    LPAD(trx_details_rec.qty*100,14,0) ||    RPAD(' ',1) ||    RPAD(' ',27)||
RPAD(' ',8)||    RPAD(NVL(trx_details_rec.cust_duns_num,' '),9)||    RPAD(' ',4)||    RPAD(' ',15)||
DECODE(trx_details_rec.snd_app_sym,NULL,RPAD(' ',27),     RPAD(SUBSTR(REPLACE(trx_details_rec.snd_app_sym,        ' ', ''),1,27),27,' '))
||    RPAD(' ',8) ||    RPAD(' ',9) ||    RPAD(' ',4) ||    RPAD(' ',15) ||    DECODE(trx_details_rec.unt_iss,NULL,'  ',
RPAD(SUBSTR(trx_details_rec.unt_iss,1,2),2,' '))||    DECODE(trx_details_rec.unt_prc,NULL,RPAD('0',14,'0'),
REPLACE(TO_CHAR(trx_details_rec.unt_prc,'FM099999999999D00')    ,'.',''))||    RPAD(' ',15) trx_line_rec
        INTO    l_trx_detail_rec
        FROM    dual ;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,       l_trx_detail_rec);
EXCEPTION
WHEN OTHERS THEN
        errcode                       :=SQLCODE;
        errmsg                        :=SQLERRM || 'Error in Creating the  Detail Record '       || '- Procedure:  create_trx_dtl_rec';
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,       errmsg);
        END IF;
        RAISE;
END create_trx_dtl_rec;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

------------------------------------------------------------------------
-- IPAC FY2003-04
-- Procedure to create the USSGL Records corresponding to the
-- Transaction details
-----------------------------------------------------------------------
PROCEDURE create_ussgl_rec(p_cust_trx_id IN NUMBER, l_trx_line_no IN NUMBER, p_snd_app_sym IN VARCHAR2)
IS
        l_ussgl_rec VARCHAR2(100);
        CURSOR ussgl_cur   (   p_cust_trx_id NUMBER   )
IS
        SELECT  sgl_acct_num,
                amount,
                cr_dr_flag
        FROM    fv_ipac_trx_all trx
        WHERE   org_id              = v_org_id
                AND set_of_books_id = v_set_of_books_id
                AND customer_trx_id = p_cust_trx_id
                AND unt_iss         = '~RA'
                AND report_flag     = 'Y'
                AND processed_flag  = 'N'
                AND accounted_flag  = 'Y'
                AND exclude_flag    = 'N'
                AND bulk_exception is NULL
                AND cash_receipt_id IS NOT NULL
                AND snd_app_sym = p_snd_app_sym
                AND trx_line_no = l_trx_line_no;
        l_module_name   VARCHAR2(200) ;
        l_output_string VARCHAR2(2000);
BEGIN
        l_module_name := g_module_name || 'create_ussgl_rec';
        -- create the USSGL records
        FOR ussgl_rec IN ussgl_cur(p_cust_trx_id)
        LOOP
                IF (ussgl_rec.cr_dr_flag      = 'D') THEN
                        ussgl_rec.cr_dr_flag := 'C';
                ELSE
                        ussgl_rec.cr_dr_flag := 'D';
                END IF;
                l_output_string := 'E' ||   'A' ||   LPAD (ussgl_rec.sgl_acct_num, 4,0) ||   'S' ||   'F' ||   LPAD(REPLACE(ussgl_rec.amount*100,'-',NULL),14,0) ||   ussgl_rec.cr_dr_flag;
                fnd_file.put_line (fnd_file.output,     l_output_string);
        END LOOP ; --END of USSGL record
EXCEPTION
WHEN OTHERS THEN
        errcode :=SQLCODE;
        errmsg  :=SQLERRM|| '-- Error in creating'   || ' the USSGL Record :'   || 'Procedure - create_ussgl_rec';
        fv_utility.debug_mesg(fnd_log.level_unexpected,      l_module_name,      errmsg);
        RAISE;
END create_ussgl_rec;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Procedure for creating and applying cash receipts
-- The code also generates the SLA accounting for its distributions incase
-- it has a cash receipt applied to it.
------------------------------------------------------------------------------
PROCEDURE create_receipt_accounting(trx_receipt_rec IN trx_receipt_cur%ROWTYPE,
                                    p_currency_code IN VARCHAR2,
                                    p_receipt_method_id IN NUMBER,
                                    p_receipt_date IN DATE,
                                    p_gl_date IN DATE,
                                    p_cash_receipt_id IN NUMBER)
IS
        l_event_source_info xla_events_pub_pkg.t_event_source_info;
        l_entity_id       NUMBER;
        l_legal_entity_id NUMBER;
--        l_event_id        NUMBER;
--        l_event_type_code VARCHAR2(30);
        l_ae_header_id    NUMBER;
        l_amount          NUMBER;
        l_cr_dr_flag      VARCHAR2(1);
        l_gl_account_num  gl_code_combinations.segment1%TYPE;
        l_trx_dist_id     NUMBER;
        l_trx_line_no     NUMBER;
        l_trx_number      VARCHAR2(20);
        l_trx_date DATE;
        l_customer_trx_id     NUMBER;
        l_customer_id         NUMBER;
        ussgl_flag            VARCHAR(1);
        x_cash_receipt_id     NUMBER;
        x_accounting_batch_id NUMBER;
        x_errbuf              VARCHAR2(1000);
        x_retcode             NUMBER;
        x_request_id          NUMBER;
        sgl_acct_num          varchar2(30);
        l_sgl_acct_num        gl_code_combinations.segment1%TYPE;
        l_module_name         VARCHAR2(200) ;
--        l_event_stat          VARCHAR2(1);
        l_is_line_no          BOOLEAN;

--------- Bug 5451545 ---------------------------
        CURSOR get_evnt_cur(p_entity_id NUMBER,p_proc NUMBER)
        IS
               SELECT  event_id,
                       event_type_code
                FROM    xla_events
                WHERE   application_id = 222
                        AND entity_id  = p_entity_id
                        AND
                        ( (p_proc = 1 AND event_status_code <> 'P' )
                           OR
                           (p_proc = 2 AND event_status_code = 'P' )
                         );

--------- Bug 5451545 ---------------------------

BEGIN
        l_module_name := g_module_name || 'create_receipt_accounting';

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'Inside create_receipt_accounting');

        IF trx_receipt_rec.cash_receipt_id IS NOT NULL
        OR p_cash_receipt_id IS NOT NULL THEN

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'trx_receipt_rec.cash_receipt_id or p_Cash_receipt Is Not Null');

                x_retcode    := 0;
--                l_event_stat := '';
                /* Check if the Account information is already avaliable in
                XLA tables, then need not generate SLA Accounting */
                -- Get the entity_id  and event_id for the given
                -- transaction's cash_receipt_id
                SELECT  entity_id,
                        legal_entity_id
                INTO    l_entity_id,
                        l_legal_entity_id
                FROM    xla_transaction_entities
                WHERE   source_id_int_1   = NVL(p_cash_receipt_id ,       trx_receipt_rec.cash_receipt_id )
                        AND application_id=222;

                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                'l_entity_id ='||l_entity_id);
/*
                -- CHECK IT Won't there be two event_ids for receipt
                -- creation and application
                SELECT  event_id,
                        event_type_code
                INTO    l_event_id,
                        l_event_type_code
                FROM    xla_events
                WHERE   application_id = 222
                        AND entity_id  = l_entity_id
                        and event_status_code <> 'P';
*/

        FOR get_evnt_rec IN get_evnt_cur(l_entity_id,1)
        LOOP
               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                'l_event_id '|| get_evnt_rec.event_id);

                        l_event_source_info.application_id       := 222;
                        l_event_source_info.legal_entity_id      := l_legal_entity_id;
                        l_event_source_info.ledger_id            := v_set_of_books_id;
                        l_event_source_info.entity_type_code     := get_evnt_rec.event_type_code; --l_event_type_code; -- CHECK IT
                        l_event_source_info.transaction_number   := trx_receipt_rec.trx_number;
                        l_event_source_info.source_id_int_1      := nvl(p_cash_receipt_id,
                                                                     trx_receipt_rec.cash_receipt_id);
                        -- Submit the xla_accounting_pub_pkg.accounting_program_
                        -- document for the entity id.
                        xla_accounting_pub_pkg.accounting_program_document(p_event_source_info => l_event_source_info,
                                                                           p_application_id => 222,
                                                                           p_valuation_method => NULL,
                                                                           p_entity_id => l_entity_id,
                                                                           p_accounting_flag => 'Y',
                                                                           p_accounting_mode => 'F',
                                                                           p_transfer_flag => 'N',
                                                                           p_gl_posting_flag => 'N',
                                                                           p_offline_flag => 'N',
                                                                           p_accounting_batch_id => x_accounting_batch_id,
                                                                           p_errbuf => x_errbuf,
                                                                           p_retcode => x_retcode,
                                                                           p_request_id => x_request_id);
                       EXIT;
         END LOOP; -- End FOR get_evnt_rec IN get_evnt_cur(l_entity_id)

                -- Check if SLA Accounting is done successfully or if the
                -- Account information is already avaliable in XLA tables


                IF x_retcode = 0 THEN
                        -- Accounted flag is set for the distribution lines
                        -- And since exceptions are generated again for these
                        -- lines therefore we update them as null
                        UPDATE fv_ipac_trx_all
                                SET accounted_flag  = 'Y',
                                bulk_exception      = NULL
                        WHERE   set_of_books_id     = v_set_of_books_id
                                AND org_id          = v_org_id
                                AND customer_trx_id = trx_receipt_rec.customer_trx_id
                                AND exclude_flag    = 'N'
                                AND report_flag     = 'Y'
                                AND processed_flag  = 'N';

                 FOR get_evnt_rec IN get_evnt_cur(l_entity_id,2)
                 LOOP

                        -- Obtain accounting information
                        SELECT  ae_header_id
                        INTO    l_ae_header_id
                        FROM    xla_ae_headers
                        WHERE   event_id = get_evnt_rec.event_id;

                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                        'l_ae_header_id ='||l_ae_header_id);

                        FOR xla_acnt_rec IN xla_acnt_cur (l_ae_header_id)
                        LOOP -- Accounting Information Record

                                /* Check that if the  Receipt Line amounts are negative
                                for the Credit and Debit Account pair,
                                then Debit Account is updated with cr_dr_flag='C'
                                and Credit Account cr_dr_flag='D',
                                Amount =<positive > for both the Accounts.
                                This is required for the Bulk File reporting..*/
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                'xla_acnt_rec.accounted_cr= '||xla_acnt_rec.accounted_cr);
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                'xla_acnt_rec.accounted_dr='||xla_acnt_rec.accounted_dr);

                                IF xla_acnt_rec.accounted_cr IS NOT NULL THEN
                                        --  Credit Account
                                        l_amount                    := xla_acnt_rec.accounted_cr;
                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                'l_amount= '||l_amount);

                                        IF xla_acnt_rec.accounted_cr > 0 THEN
                                                l_cr_dr_flag        := 'C';
                                        ELSE
                                                l_cr_dr_flag := 'D';
                                                l_amount     := -l_amount;
                                        END IF;
                                ELSIF xla_acnt_rec.accounted_dr IS NOT NULL THEN
                                        -- Debit Account
                                           l_amount                    := xla_acnt_rec.accounted_dr;
                                            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                            'l_amount= '||l_amount);

                                        IF xla_acnt_rec.accounted_dr > 0 THEN
                                                l_cr_dr_flag        := 'D';
                                        ELSE
                                                l_cr_dr_flag := 'C';
                                                l_amount     := -l_amount;
                                        END IF;
                                END IF;

                                -- Determine the trx line number for each distribution
                                BEGIN

                                l_is_line_no:=TRUE;

                                SELECT  racust.line_number
                                INTO    l_trx_line_no
                                FROM    ra_customer_trx_lines racust,
                                        ar_distributions ardist,
                                        xla_distribution_links xladist
                                WHERE
                                xladist.ae_header_id       = xla_acnt_rec.ae_header_id
                                AND
                                xladist.ae_line_num    = xla_acnt_rec.ae_line_num
                                AND
                                xladist.application_id = 222
                                AND
                                xladist.SOURCE_DISTRIBUTION_ID_NUM_1 = ardist.line_id
                                AND
                                ardist.REF_CUSTOMER_TRX_LINE_ID = racust.CUSTOMER_TRX_LINE_ID;

                                EXCEPTION
                                WHEN OTHERS THEN

                                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                'No line_number exists for header_id ='||
                                xla_acnt_rec.ae_header_id || ' and line_num = ' ||
                                xla_acnt_rec.ae_line_num);

                                    l_is_line_no :=FALSE;
                                 END;

                                IF l_is_line_no = TRUE THEN

                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                 'l_trx_line_no='||l_trx_line_no);
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                 'xla_acnt_rec.code_combination_id='||xla_acnt_rec.code_combination_id);
                                 -- Determine the  Natural account from the ccid for
                                 -- each of the accounting lines.
                                 l_gl_account_num :=      gl_account_num(xla_acnt_rec.code_combination_id);
                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                 'l_gl_account_num ='||l_gl_account_num );
                                 -- Determine the Treasury Symbol

                                 get_treasury_symbol( bl_seg_name,   xla_acnt_rec.code_combination_id );

                                 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                                 'bl_seg_name='||bl_seg_name );
                                 -- Insertion of Receipt Accounting information into
                                 -- the table fv_ipac_trx_all
                                 v_bulk_exception := NULL;

                                 v_bulk_exception := get_sgl_exception( l_gl_account_num,
                                 l_sgl_acct_num);

                                 INSERT
                                 INTO    fv_ipac_trx_all
                                         (
                                                 set_of_books_id,
                                                 org_id,
                                                 ipac_billing_id,
                                                 amount,
                                                 cnt_nm,
                                                 trx_number,
                                                 trx_date,
                                                 snd_app_sym,
                                                 unt_iss,
                                                 customer_trx_id,
                                                 customer_id,
                                                 trx_line_no,
                                                 created_by,
                                                 creation_date,
                                                 last_updated_by,
                                                 last_update_date,
                                                 last_update_login,
                                                 sgl_acct_num,
                                                 bulk_exception,
                                                 cr_dr_flag,
                                                 PROCESSED_FLAG,
                                                 REPORT_FLAG,
                                                 ACCOUNTED_FLAG,
                                                 RECEIPT_FLAG,
                                                 cash_receipt_id,
                                                 exclude_flag
                                         )
                                         VALUES
                                         (
                                                 v_set_of_books_id,
                                                 v_org_id,
                                                 fv_ipac_billing_id_s.NEXTVAL,
                                                 l_amount,
                                                 nvl(trx_receipt_rec.cnt_nm,-99),
                                                 trx_receipt_rec.trx_number,
                                                 trx_receipt_rec.trx_date,
                                                 v_treasury_symbol,
                                                 '~RA',
                                                 trx_receipt_rec.customer_trx_id,
                                                 trx_receipt_rec.customer_id,
                                                 l_trx_line_no,
                                                 fnd_global.user_id,
                                                 SYSDATE,
                                                 fnd_global.user_id,
                                                 SYSDATE,
                                                 fnd_global.user_id,
                                                 l_gl_account_num,
                                                 v_bulk_exception,
                                                 l_cr_dr_flag,
                                                 'N',
                                                 'Y',
                                                 'Y',
                                                 'Y',
                                                 NVL(p_cash_receipt_id,trx_receipt_rec.cash_receipt_id),
                                                 'N'
                                         )
                                        ;
                                END IF;  -- End IF l_is_line_no = TRUE THEN
                        END LOOP; -- Accounting Information Record

                 END LOOP;  -- End  FOR get_evnt_rec IN get_evnt_cur(l_entity_id)

                ELSE              -- SLA Accounting Failed
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                        x_errbuf);
                        -- Add a new row in fv_ipac_trx_all with unt_iss = '~RA'
                        -- and bulk_exception = 'ACCOUNTING_NOT_CREATED'
                        -- for the particular transaction
                        INSERT
                        INTO    fv_ipac_trx_all
                                (
                                        set_of_books_id,
                                        org_id,
                                        ipac_billing_id,
                                        amount,
                                        cnt_nm,
                                        trx_number,
                                        trx_date,
                                        unt_iss,
                                        customer_trx_id,
                                        customer_id,
                                        report_flag,
                                        exclude_flag,
                                        processed_flag,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        receipt_flag,
                                        accounted_flag,
                                        bulk_exception,
                                        cash_receipt_id
                                )
                                VALUES
                                (
                                        v_set_of_books_id,
                                        v_org_id,
                                        fv_ipac_billing_id_s.NEXTVAL,
                                        trx_receipt_rec.amount,
                                        '-99',
                                        trx_receipt_rec.trx_number,
                                        trx_receipt_rec.trx_date,
                                        '~RA',
                                        trx_receipt_rec.customer_trx_id,
                                        trx_receipt_rec.customer_id,
                                        'Y',
                                        'N',
                                        'N',
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        'Y',
                                        'N',
                                        'ACCOUNTING_NOT_CREATED',
                                        trx_receipt_rec.cash_receipt_id
                                )
                                ;
                        -- Also Update all the detail records related to this
                        -- transaction with accounted_flag = 'N'
                        UPDATE fv_ipac_trx_all
                                SET accounted_flag = 'N'
                        WHERE   set_of_books_id    = v_set_of_books_id
                                AND org_id         = v_org_id
                                AND customer_trx_id= trx_receipt_rec.customer_trx_id
                                AND exclude_flag   = 'N'
                                AND report_flag    = 'Y'
                                AND processed_flag = 'N';
                END IF; -- Check if SLA Accounting done successfully
        END IF;         -- Check if Receipt Id
        -- created, then generate SLA Accounting -- SLA Accounting Done Successfully
EXCEPTION
WHEN OTHERS THEN

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
'Create_Receipt_Accounting - Unexpected Error, Calling Update');

        UPDATE fv_ipac_trx_all
                SET accounted_flag  = '',
                bulk_exception      = NULL
        WHERE   set_of_books_id     = v_set_of_books_id
                AND org_id          = v_org_id
                AND customer_trx_id = trx_receipt_rec.customer_trx_id
                AND exclude_flag    = 'N'
                AND report_flag     = 'Y'
                AND processed_flag  = 'N';
END create_receipt_accounting;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

PROCEDURE create_receipt_and_apply( errbuf OUT NOCOPY VARCHAR2,
                                    retcode OUT NOCOPY VARCHAR2,
                                    trx_receipt_rec IN trx_receipt_cur%ROWTYPE,
                                    p_currency_code IN VARCHAR2,
                                    p_receipt_method_id IN NUMBER,
                                    p_receipt_date IN DATE,
                                    p_gl_date IN DATE)
IS
        x_return_status       VARCHAR2(1);
        x_msg_count           NUMBER;
        x_msg_data            VARCHAR2(2000);
        x_cash_receipt_id     NUMBER;
        x_accounting_batch_id NUMBER;
        x_errbuf              VARCHAR2(1000);
        x_retcode             NUMBER;
        x_request_id          NUMBER;
        l_module_name          VARCHAR2(200);
        l_payment_trxn_extension_id  NUMBER;
BEGIN

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'create_receipt_and_apply begins');

        -- Create new receipts only for those transactions which already don't have
        -- any receipts applied to them

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'trx_receipt_rec.cash_receipt_id = ' || trx_receipt_rec.cash_receipt_id);

        IF trx_receipt_rec.cash_receipt_id IS NULL THEN

	 BEGIN  --Bug 5641377, 7113869
                SELECT cba.agency_location_code
                INTO v_sender_alc
                FROM ar_receipt_method_accounts arma,
                Ce_bank_accounts cba,
                CE_BANK_ACCT_USES_ALL cbal
                 WHERE cbal.bank_account_id =cba.bank_account_id
                 AND cbal.bank_acct_use_id = arma.remit_bank_acct_use_id
                    AND cba.currency_code = (p_currency_code)
                AND arma.primary_flag = 'Y'
                AND arma.receipt_method_id =p_receipt_method_id
 		AND arma.org_id = v_org_id;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
                        'There is no Billing ALC defined for the Transaction '||trx_receipt_rec.trx_number);
            END;

             --bug 8654573
            begin
            select PAYMENT_TRXN_EXTENSION_ID
            into
            l_payment_trxn_extension_id
            from ra_customer_trx_all
            where CUSTOMER_TRX_ID = trx_receipt_rec.customer_trx_id;

            exception
             WHEN NO_DATA_FOUND THEN
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
                        'There is no Payment_trxn_extension_id for the Transaction '||trx_receipt_rec.trx_number);
            end;
            --bug 8654573

                ar_receipt_api_pub.create_and_apply(p_api_version => 1.0,
                                                    x_return_status => x_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_msg_data,
                                                    p_currency_code => p_currency_code,
                                                    p_amount => trx_receipt_rec.amount,
                                                    p_receipt_number => trx_receipt_rec.trx_number,
                                                    p_receipt_date => p_receipt_date,
                                                    p_gl_date => p_gl_date,
                                                    p_customer_id => trx_receipt_rec.customer_id,
                                                    p_payment_trxn_extension_id => l_payment_trxn_extension_id,
                                                    p_deposit_date => SYSDATE,
                                                    p_receipt_method_id => p_receipt_method_id,
                                                    p_cr_id  => x_cash_receipt_id,
                                                    p_customer_trx_id => trx_receipt_rec.customer_trx_id,
                                                    p_trx_number => trx_receipt_rec.trx_number,
                                                    p_amount_applied => trx_receipt_rec.amount,
                                                    p_apply_date => p_receipt_date,
                                                    p_apply_gl_date => p_gl_date,
                                                    p_org_id => v_org_id);

                -- If the create_and_apply receipt is done successfully
                IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                      'create_and_apply receipt is done successfully');

                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
                        'The receipt is created for the transaction number: '
                        || trx_receipt_rec.trx_number || ' with Receipt ID: '
                        ||   to_char(x_cash_receipt_id));

                    /*    SELECT cba.agency_location_code
	                    INTO v_sender_alc
                        FROM ar_receipt_method_accounts_all arma,
                    	Ce_bank_accounts cba
                    	WHERE cba.bank_account_id = arma.remit_bank_acct_use_id
                    	AND cba.currency_code = (p_currency_code)
                    	AND arma.primary_flag = 'Y'
                    	AND arma.receipt_method_id = p_receipt_method_id; */


                        -- Updating all the detail records of the selected
                        -- transaction for its created receipt and sender alc
                        UPDATE fv_ipac_trx_all
                                SET sender_alc      = v_sender_alc,
                                cash_receipt_id     = x_cash_receipt_id,
                                receipt_flag        = 'Y'
                        WHERE   set_of_books_id     = v_set_of_books_id
                                AND org_id          = v_org_id
                                AND customer_trx_id = trx_receipt_rec.customer_trx_id
                                AND exclude_flag    = 'N'
                                AND report_flag     = 'Y'
                                AND processed_flag  = 'N';

                        -- Insert data into fv_interagency_funds table for the
                        -- created receipt id and receipt number

                        INSERT
                        INTO    fv_interagency_funds_all
                                (
                                        INTERAGENCY_FUND_ID,
                                        SET_OF_BOOKS_ID,
                                        ORG_ID,
                                        PROCESSED_FLAG,
                                        CHARGEBACK_FLAG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATE_LOGIN,
                                        CUSTOMER_ID,
                                        CASH_RECEIPT_ID,
                                        RECEIPT_NUMBER
                                )
                                VALUES
                                (
                                        fv_interagency_funds_s.NEXTVAL,
                                        v_set_of_books_id,
                                        v_org_id,
                                        'N',
                                        'N',
                                        SYSDATE,
                                        fnd_global.user_id,
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        trx_receipt_rec.customer_id,
                                        x_cash_receipt_id,
                                        trx_receipt_rec.trx_number
                                )
                                ;
                        create_receipt_accounting(trx_receipt_rec,
                                                  p_currency_code ,
                                                  p_receipt_method_id ,
                                                  p_receipt_date ,
                                                  p_gl_date,
                                                  x_cash_receipt_id);

                ELSE -- If the create_and_apply receipt fails
                        -- Add a new row in fv_ipac_trx_all with unt_iss = '~RA'
                        -- and bulk_exception = 'RECEIPT_NOT_CREATED' for the particular
                        -- transaction

                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                      'create_and_apply receipt fails');

                        INSERT
                        INTO    fv_ipac_trx_all
                                (
                                        set_of_books_id,
                                        org_id,
                                        ipac_billing_id,
                                        amount,
                                        cnt_nm,
                                        trx_number,
                                        trx_date,
                                        unt_iss,
                                        customer_trx_id,
                                        customer_id,
                                        report_flag,
                                        exclude_flag,
                                        processed_flag,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        receipt_flag,
                                        accounted_flag,
                                        bulk_exception
                                )
                                VALUES
                                (
                                        v_set_of_books_id,
                                        v_org_id,
                                        fv_ipac_billing_id_s.NEXTVAL,
                                        trx_receipt_rec.amount,
                                        '-99',
                                        trx_receipt_rec.trx_number,
                                        trx_receipt_rec.trx_date,
                                        '~RA',
                                        trx_receipt_rec.customer_trx_id,
                                        trx_receipt_rec.customer_id,
                                        'Y',
                                        'N',
                                        'N',
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        'N',
                                        'N',
                                        'RECEIPT_NOT_CREATED'
                                )
                                ;
                        -- Also Update all the detail records related to this
                        -- transaction with receipt_flag = 'N'
                        UPDATE fv_ipac_trx_all
                                SET receipt_flag    = 'N'
                        WHERE   set_of_books_id     = v_set_of_books_id
                                AND org_id          = v_org_id
                                AND customer_trx_id = trx_receipt_rec.customer_trx_id
                                AND exclude_flag    = 'N'
                                AND report_flag     = 'Y'
                                AND processed_flag  = 'N';
                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
                        'Error generated during the creation of receipt for the transaction number: '
                        || trx_receipt_rec.trx_number);

                        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
                        'Return Status: ' || x_return_status);

                        IF x_msg_data IS NOT NULL THEN
                                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,        l_module_name,
                                'Error Information: '         || x_msg_data );
                        END IF;
                END IF; -- Condition related with the success or failure
                -- of create_and_apply receipt process
        else
                if NVL(trx_receipt_rec.accounted_flag,'N')='N' then
                        create_receipt_accounting( trx_receipt_rec ,
                                                   p_currency_code,
                                                   p_receipt_method_id ,
                                                   p_receipt_date ,
                                                   p_gl_date,
                                                   NULL );
                end if;
        END IF; -- Condition related with the creation of new receipts
        -- only for those transactions which already don't have
        -- any receipts applied to them
EXCEPTION
WHEN OTHERS THEN
        IF errcode IS NULL THEN
                errcode := SQLCODE;
                errmsg  := SQLERRM;
        END IF;
        retcode := errcode;
        errbuf  := errmsg;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'Errbuf :'||errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'retcode :'||retcode);

END; -- create_receipt_and_apply

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Procedure to create bulk file for all those transactions whose receipts
-- and accounting are generated successfully without any bulk_exception.
------------------------------------------------------------------------------
PROCEDURE create_receipt_acct_main( errbuf OUT NOCOPY VARCHAR2,   retcode OUT NOCOPY VARCHAR2,     p_receipt_method_id IN NUMBER,   p_receipt_date IN DATE,   p_gl_date IN DATE    )
IS
        l_req_id        NUMBER;
        l_call_status   BOOLEAN;
        rphase          VARCHAR2(30);
        rstatus         VARCHAR2(30);
        dphase          VARCHAR2(30);
        dstatus         VARCHAR2(30);
        message         VARCHAR2(240);
        l_module_name   VARCHAR2(200);
BEGIN
        l_module_name:=g_module_name||'create_receipt_acct_main';

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'create_receipt_acct_main begins');

        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
        'Input parameters are :');
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
        'Parm_CURRENCY_CODE :'||parm_currency);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
        'P_RECEIPT_METHOD_ID :'||P_RECEIPT_METHOD_ID);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
        'P_RECIPT_DATE :'||P_RECEIPT_DATE);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
        'P_GL_DATE :'||P_GL_DATE);

        get_bal_seg_name;


        for trx_receipt_rec in trx_receipt_cur
        loop

               FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
               'Calling create_receipt_and_apply with customer_trx_id='||
               trx_receipt_rec.customer_trx_id);

                create_receipt_and_apply(errbuf,
                                        retcode,
                                        trx_receipt_rec,
                                        parm_currency,
                                        p_receipt_method_id,
                                        p_receipt_date,
                                        p_gl_date);
        end loop;

        exceed_dr_cr_sgl_mismatch_exc;
        --   submit Bulk File Report

        l_req_id := FND_REQUEST.SUBMIT_REQUEST('FV',
                                               'FVIBKRPT',
                                               '',
                                               '',
                                               FALSE,
                                               v_org_id);

        -- if concurrent request submission failed then abort process
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,
        'IPAC Bulk File Report  Request ID ='   ||l_req_id);

        IF l_req_id      = 0 THEN
                errbuf  := 'Unable to Submit Bulk File Report ';
                retcode := '-1';
                ROLLBACK;
        ELSE
                COMMIT;
        END IF;
        -- Check status of completed concurrent program
        --   and if complete exit
        l_call_status   := fnd_concurrent.wait_for_request(l_req_id,
                                                           10,
                                                           0,
                                                           rphase,
                                                           rstatus,
                                                           dphase,
                                                           dstatus,
                                                           message);
        IF l_call_status = FALSE THEN
                errbuf  := 'Can not wait for the status of '||
                'IPAC Bulk File Generation Process';
                retcode := '2';
        END IF;
BEGIN
        --   submit IPAC Bulk File Exception Report
        l_req_id := FND_REQUEST.SUBMIT_REQUEST('FV',
                                               'FVIPCRBE',
                                                         '',
                                                         '',
                                                         FALSE,
                                                         v_set_of_books_id,
                                                         v_org_id         );

        -- if concurrent request submission failed then abort process
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,      l_module_name,
        'IPAC Bulk File Exception Report  Request ID ='   ||l_req_id);

        IF l_req_id      = 0 THEN
                errbuf  := 'Unable to Submit Apply Cash Receipts Process';
                retcode := '-1';
                ROLLBACK;
        ELSE
                COMMIT;
        END IF;
        -- Check status of completed concurrent program
        --   and if complete exit
        l_call_status   := fnd_concurrent.wait_for_request(   l_req_id,
                                                              10,
                                                              0,
                                                              rphase,
                                                              rstatus,
                                                              dphase,
                                                              dstatus,
                                                              message);
        IF l_call_status = FALSE THEN
                errbuf  := 'Can not wait for the status of '||
                'IPAC Bulk File Exception Report';
                retcode := '2';

        END IF;
EXCEPTION
WHEN OTHERS THEN
        ROLLBACK;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,      l_module_name,
        ' -- Error IN IPAC Bulk Exception process:  Procedure:- create_bulk_file');

        IF errcode IS NULL THEN
                errcode := SQLCODE;
                errmsg  := SQLERRM;
        END IF;
        retcode := errcode;
        errbuf  := errmsg;

        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'Errbuf :'||errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'retcode :'||retcode);
END;
EXCEPTION
WHEN OTHERS THEN
        IF errcode IS NULL THEN
                errcode := SQLCODE;
                errmsg  := SQLERRM;
        END IF;
        retcode := errcode;
        errbuf  := errmsg;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
          'Errbuf :'||errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'retcode :'||retcode);

END;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

PROCEDURE create_bulk_file(errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY VARCHAR2,
                            p_org_id IN NUMBER)
IS
        l_count_bulk_exception NUMBER;
        l_req_id               NUMBER;
        l_call_status          BOOLEAN;
        rphase                 VARCHAR2(30);
        rstatus                VARCHAR2(30);
        dphase                 VARCHAR2(30);
        dstatus                VARCHAR2(30);
        message                VARCHAR2(240);
        l_module_name          VARCHAR2(200);
        l_rec_count            NUMBER;
BEGIN
        l_module_name:=g_module_name||'create_bulk_file';
        v_org_id     :=p_org_id;

        fv_utility.get_ledger_info(v_org_id,
                                   v_set_of_books_id,
                                   v_coa_id ,
                                   parm_currency ,
                                   p_status );
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'create_bulk_file begins'||l_rec_count);

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'Org_id = '||p_org_id);

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'v_set_of_books_id = '||v_set_of_books_id);


        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'v_coa_id = '||v_coa_id);

        SELECT  count(1)
        INTO    l_rec_count
        FROM    fv_ipac_trx_all
        WHERE    set_of_books_id    = v_set_of_books_id
                AND  org_id         = v_org_id
                AND  accounted_flag ='Y'
                AND  report_flag    ='Y'
                AND  exclude_flag   ='N'
                AND  processed_flag = 'N'
                AND  bulk_exception is null;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
        'l_rec_count = '||l_rec_count);

        IF l_rec_count>0 then
                get_bal_seg_name;

                -- Create the Header Record
                create_file_id_rec;

                -- Create the Batch Header Record
                create_batch_header(v_set_of_books_id);

                FOR hdr_det_rec IN hdr_det(v_set_of_books_id, v_org_id)
                LOOP

                        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                        'Creating trx header for customer_trx_id = '||hdr_det_rec.customer_trx_id);

                        -- Create the Transaction Header Record
                        create_trx_header(v_set_of_books_id,
                        hdr_det_rec.customer_trx_id);
                        -- IPAC FY2003 -04
                        -------------------------------------------------------
                        FOR trx_detail_rec IN trx_detail_cur(hdr_det_rec.customer_trx_id)
                        LOOP
                                -- Create the detail Header Record
                                create_trx_dtl_rec(trx_detail_rec);
                                -- Create the USSGL record
                                create_ussgl_rec(trx_detail_rec.customer_trx_id,
                                                trx_detail_rec.trx_line_no,
                                                trx_detail_rec.snd_app_sym    );
                        END LOOP;
                        ------------------------------------------------------
                END LOOP;
                -- In case the process of create_bulk_file is done
                -- successfully set the processed flag to 'Y'
                UPDATE fv_ipac_trx_all
                        SET processed_flag  = 'Y'
                WHERE       set_of_books_id = v_set_of_books_id
                        AND org_id          = v_org_id
                        AND  bulk_exception IS NULL
                        AND cash_receipt_id IS NOT NULL
                        AND accounted_flag = 'Y'
                        AND exclude_flag   = 'N'
                        AND report_flag    = 'Y';
        else
                retcode:=1;
                errbuf := 'No Records Found for Bulk File Report.';
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,   l_module_name,
                'No Records Found for Bulk File Report.');

                return;
        end if;
EXCEPTION
WHEN OTHERS THEN
        ROLLBACK;
        IF errcode IS NULL THEN
                errcode := SQLCODE;
                errmsg  := SQLERRM;
        END IF;
        retcode := errcode;
        errbuf  := errmsg;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'Errbuf :'||errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,       l_module_name,
        'retcode :'||retcode);
END ;  -- create_bulk_file;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

PROCEDURE create_flat_file(p_statement VARCHAR2,
                           p_set_of_books_id NUMBER,
                           p_customer_trx_id NUMBER)
AS
        v_cursor_id   INTEGER;
        l_fetch_count INTEGER;
        col1          VARCHAR2(2000);
        retcode       NUMBER;
        errbuf        VARCHAR2(200);
        l_module_name VARCHAR2(200) ;
BEGIN
        l_module_name := g_module_name ||   'create_flat_file';
BEGIN
        v_cursor_id := DBMS_SQL.OPEN_CURSOR;
EXCEPTION
WHEN OTHERS THEN
        errbuf  := SQLERRM;
        retcode := SQLCODE;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,       l_module_name,       errbuf);
        RAISE ;
        RETURN;
END;
BEGIN
        DBMS_SQL.PARSE(v_cursor_id, p_statement,     DBMS_SQL.V7);
        DBMS_SQL.BIND_VARIABLE(v_cursor_id,      ':b_set_of_books_id',
        p_set_of_books_id);
        DBMS_SQL.BIND_VARIABLE(v_cursor_id,      ':b_customer_trx_id',
        p_customer_trx_id);
EXCEPTION
WHEN OTHERS THEN
        retcode := SQLCODE ;
        errbuf  := SQLERRM ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,
        l_module_name,      errbuf) ;
        RAISE ;
END ;
DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, col1, 2000);
BEGIN
        l_fetch_count := DBMS_SQL.EXECUTE(v_cursor_id);
EXCEPTION
WHEN OTHERS THEN
        retcode := SQLCODE ;
        errbuf  := SQLERRM ;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,      l_module_name,
        'Create Sql  ');
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,      l_module_name,
        errbuf) ;
        RAISE ;
END;
LOOP
        l_fetch_count   := DBMS_SQL.FETCH_ROWS(v_cursor_id);
        IF l_fetch_count = 0 THEN
                RETURN;
        END IF;
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1,      col1);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,      col1);
END LOOP;
EXCEPTION
WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                l_module_name,        errmsg);
        END IF;
        RAISE;
END;

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

BEGIN
        v_org_id := mo_global.get_current_org_id;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
        'fv.plsql.fv_ipac','Org Id : '||v_org_id);

        fv_utility.get_ledger_info(v_org_id,
                                   v_set_of_books_id,
                                   v_coa_id ,
                                   parm_currency ,
                                   p_status );

        g_module_name      := 'fv.plsql.fv_ipac.';
        flex_code          := 'GL#';
        apps_id            := 101;
        trx_exception_flag := 'N';
        --New JFMIP REQUIREMENT pay flag should be P
        --v_pay_flag    := 'F';
        v_pay_flag := 'P';
        --New JFMIP REQUIREMENT ENDS
        ---l_module_name :=  g_module_name || 'delete_records';
END; -- package body

/
