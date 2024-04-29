--------------------------------------------------------
--  DDL for Package Body ARRX_RC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_RC" as
/* $Header: ARRXRCB.pls 120.33.12010000.5 2009/09/08 06:26:38 kknekkal ship $ */

-- create generic procedure to reset to NULL all var type variables
procedure init_var is

begin
/* Bug 5724171*/
   var.len1                       := NULL;
   var.len2                       := NULL;
   var.p_batch_name_low           := NULL;
   var.p_batch_name_high          := NULL;

   var.p_customer_name_low        := NULL;
   var.p_customer_name_high       := NULL;
   var.p_customer_number_low      := NULL;
   var.p_customer_number_high     := NULL;

   var.p_apply_date_low           := NULL;
   var.p_apply_date_high          := NULL;
   var.p_deposit_date_low         := NULL;
   var.p_deposit_date_high        := NULL;
   var.p_receipt_date_low         := NULL;
   var.p_receipt_date_high        := NULL;
   var.p_gl_date_low              := NULL;
   var.p_gl_date_high             := NULL;

   var.p_receipt_status_low       := NULL;
   var.p_receipt_status_high      := NULL;
   var.p_receipt_number_low       := NULL;
   var.p_receipt_number_high      := NULL;

   var.p_invoice_type_low         := NULL;
   var.p_invoice_type_high        := NULL;
   var.p_invoice_number_low       := NULL;
   var.p_invoice_number_high      := NULL;

   var.p_currency_code            := NULL;
   var.p_bank_account_name        := NULL;
   var.p_payment_method           := NULL;
   var.p_confirmed_flag           := NULL;

   var.p_doc_sequence_name        := NULL;
   var.p_doc_sequence_number_from := NULL;
   var.p_doc_sequence_number_to   := NULL;

   var.request_id                 := NULL;
   var.p_reporting_level          := NULL;
   var.p_reporting_entity_id      := NULL;
   var.p_sob_id                   := NULL;
   var.p_coa_id                   := NULL;
   var.p_co_seg_low               := NULL;
   var.p_co_seg_high              := NULL;
   var.ca_sob_type                := NULL;
   var.ca_sob_id                  := NULL;

   var.calling_program            := NULL;
end;

----------------------------
-- Consolidated Before Report
-----------------------------
procedure before_report
is

-- make the following variable global, so they can be passed around procedures
   -- parameter based where clauses
   BATCH_NAME_WHERE                        varchar2(500);
   CUSTOMER_NAME_WHERE                     varchar2(500);
   DEPOSIT_DATE_WHERE                      varchar2(500);
   RECEIPT_STATUS_WHERE                    varchar2(500);
   RECEIPT_NUMBER_WHERE                    varchar2(500);
   INVOICE_NUMBER_WHERE                    varchar2(500); --Bug 1579930
   RECEIPT_DATE_WHERE                      varchar2(500);
   CURRENCY_CODE_WHERE                     varchar2(500);
   BANK_NAME_WHERE                         varchar2(500);
   PAYMENT_METHOD_WHERE                    varchar2(500);
   CONFIRMED_FLAG_WHERE                    varchar2(500);
   CRH_GL_DATE_WHERE                       varchar2(500);
   INCRH_GL_DATE_WHERE                     varchar2(500);
   CRHNEW_GL_DATE_WHERE                    varchar2(500);
   RA_GL_DATE_WHERE                        varchar2(500);
   DOC_SEQUENCE_NAME_WHERE                 varchar2(500);
   DOC_SEQUENCE_NUMBER_WHERE               varchar2(500);
   CO_SEG_WHERE                            VARCHAR2(500);
   APPLY_DATE_WHERE                        varchar2(500);
   GL_DATE_WHERE                           varchar2(500);
   CUST_NUM_WHERE                          varchar2(500);
   INV_TYPE_WHERE                          varchar2(500);
   SHOW_BILL_WHERE                         varchar2(100);
   SHOW_BILL_FROM                          varchar2(100);
   BILL_FLAG                               varchar2(1);
   MCD_GL_DATE_WHERE                       varchar2(500);  -- bug 2328165

   -- decode strings used in assign_column
   DECODE_CR_TYPE                          varchar2(500);
   DECODE_CR_STATUS                        varchar2(500);
   DECODE_CR_REFERENCE_TYPE                varchar2(500);
   DECODE_CRH_STATUS                       varchar2(500);
   DECODE_CRH_AMOUNT                       varchar2(500);
   DECODE_CRH_ACCTD_AMOUNT                 varchar2(500);
   DECODE_CRH_FD_AMOUNT                    varchar2(500);
   DECODE_CRH_AFD_AMOUNT                   varchar2(500);
   DECODE_RA_STATUS                        varchar2(200);

   -- multi-org where clauses
   L_CR_ORG_WHERE                          VARCHAR2(500);
   L_TAX_ORG_WHERE                         VARCHAR2(500);
   L_ABA_ORG_WHERE                         VARCHAR2(500);
   L_CRH_ORG_WHERE                         VARCHAR2(500);
   L_CUST_ORG_WHERE                        VARCHAR2(500);
   L_CRHFIRST_ORG_WHERE                    VARCHAR2(500);
   L_BATCHFIRST_ORG_WHERE                  VARCHAR2(500);
   L_RA_ORG_WHERE                          VARCHAR2(500);
   L_MISC_ORG_WHERE                        VARCHAR2(500);
   L_INCRH_ORG_WHERE                       VARCHAR2(500);
   L_CRHNEW_ORG_WHERE                      VARCHAR2(500);
   L_BATCH_ORG_WHERE                       VARCHAR2(500);
   L_CI_ORG_WHERE                          VARCHAR2(500);
   L_TRX_ORG_WHERE                         VARCHAR2(500);
   L_REC_ORG_WHERE                         VARCHAR2(500);
   L_RAC_ORG_WHERE                         VARCHAR2(500);
   L_PS_ORG_WHERE                          VARCHAR2(500);
   L_MCD_ORG_WHERE                         VARCHAR2(500);
   L_ARD_ORG_WHERE                         VARCHAR2(500);
   L_BS_ORG_WHERE                          VARCHAR2(500);

   rec_gain_loss                           varchar2(200);
   applied_total                           varchar2(200);
   tag                                     number;  /*  bug 5724171*/


begin
  fa_rx_util_pkg.debug('arrx_rc.before_report()+');

  -- define common lexical params and assign_column

   fa_rx_util_pkg.debug('Get SOB ID'||var.books_id);

/*Bug 5244313
   IF var.ca_sob_type = 'P'
   THEN
     var.books_id := arp_global.sysparam.set_of_books_id;
   ELSE
     var.books_id := var.ca_sob_id;
   END IF;

*/
  --
  -- Get CHART_OF_ACCOUNTS_ID
  --
   fa_rx_util_pkg.debug('Get COA ID');

   select CHART_OF_ACCOUNTS_ID,CURRENCY_CODE,NAME
   into var.chart_of_accounts_id,var.currency_code,var.org_name
   from GL_SETS_OF_BOOKS
   where SET_OF_BOOKS_ID = var.books_id;

  --
  -- Figure out NOCOPY the where clause for the parameters
  --
   fa_rx_util_pkg.debug('Build Where clauses based on parameters');

   IF var.p_batch_name_low IS NULL AND var.p_batch_name_high IS NULL THEN
      BATCH_NAME_WHERE := NULL;
   ELSIF var.p_batch_name_low IS NULL THEN
      BATCH_NAME_WHERE := ' AND BATCHFIRST.NAME <= :p_batch_name_high';
   ELSIF var.p_batch_name_high IS NULL THEN
      BATCH_NAME_WHERE := ' AND BATCHFIRST.NAME >= :p_batch_name_low';
   ELSE
      BATCH_NAME_WHERE := ' AND BATCHFIRST.NAME BETWEEN :p_batch_name_low AND :p_batch_name_high';
   END IF;

/*  bug 5724171*/
   -- strip customer number
/* Bug 7165910 */
   IF var.p_customer_name_low IS NOT NULL then
      tag := instrb(var.p_customer_name_low,'(',-1,1) - 1;
      If tag >= 0 then
        var.p_customer_name_low := substrb(var.p_customer_name_low,1, tag);
      End If;
      var.len1 := lengthb(var.p_customer_name_low);
   END IF;
   IF var.p_customer_name_high IS NOT NULL THEN
      tag := instrb(var.p_customer_name_high,'(',-1,1) - 1;
      If tag >= 0 then
        var.p_customer_name_high := substrb(var.p_customer_name_high,1,tag);
      End If;
      var.len2 := lengthb(var.p_customer_name_high);
   END IF;

   IF var.p_customer_name_low IS NULL AND var.p_customer_name_high IS NULL THEN
      CUSTOMER_NAME_WHERE := NULL;
   ELSIF var.p_customer_name_low IS NULL THEN
      CUSTOMER_NAME_WHERE := ' AND substrb(PARTY.PARTY_NAME,1,:len2) <= :p_customer_name_high';
   ELSIF var.p_customer_name_high IS NULL THEN
      CUSTOMER_NAME_WHERE := ' AND substrb(PARTY.PARTY_NAME,1,:len1) >= :p_customer_name_low';
   ELSE
      CUSTOMER_NAME_WHERE := ' AND substrb(PARTY.PARTY_NAME,1,:len1) >= :p_customer_name_low ' ||
                             ' AND substrb(PARTY.PARTY_NAME,1,:len2) <= :p_customer_name_high';
   END IF;

    fa_rx_util_pkg.debug('CUSTOMER_NAME_WHERE = ' || CUSTOMER_NAME_WHERE);

   IF var.p_deposit_date_low IS NULL AND var.p_deposit_date_high IS NULL THEN
      DEPOSIT_DATE_WHERE := NULL;
   ELSIF var.p_deposit_date_low IS NULL THEN
      DEPOSIT_DATE_WHERE := ' AND CR.DEPOSIT_DATE <= :p_deposit_date_high';
   ELSIF var.p_deposit_date_high IS NULL THEN
      DEPOSIT_DATE_WHERE := ' AND CR.DEPOSIT_DATE >= :p_deposit_date_low';
   ELSE
      DEPOSIT_DATE_WHERE := ' AND CR.DEPOSIT_DATE BETWEEN :p_deposit_date_low AND :p_deposit_date_high';
   END IF;

   IF var.p_receipt_status_low IS NULL AND var.p_receipt_status_high IS NULL THEN
      RECEIPT_STATUS_WHERE := NULL;
   ELSIF var.p_receipt_status_low IS NULL THEN
      RECEIPT_STATUS_WHERE := ' AND CR.STATUS <= :p_receipt_status_high';
   ELSIF var.p_receipt_status_high IS NULL THEN
      RECEIPT_STATUS_WHERE := ' AND CR.STATUS >= :p_receipt_status_low';
   ELSE
      RECEIPT_STATUS_WHERE := ' AND CR.STATUS BETWEEN :p_receipt_status_low AND :p_receipt_status_high';
   END IF;

   IF var.p_receipt_number_low IS NULL AND var.p_receipt_number_high IS NULL THEN
      RECEIPT_NUMBER_WHERE := NULL;
   ELSIF var.p_receipt_number_low IS NULL THEN
      RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER <= :p_receipt_number_high';
   ELSIF var.p_receipt_number_high IS NULL THEN
      RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER >= :p_receipt_number_low';
   ELSE
      RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER BETWEEN :p_receipt_number_low AND :p_receipt_number_high';
   END IF;

   IF var.p_invoice_number_low IS NULL AND var.p_invoice_number_high IS NULL THEN
      INVOICE_NUMBER_WHERE := NULL;
   ELSIF var.p_invoice_number_low IS NULL THEN
      INVOICE_NUMBER_WHERE := ' AND TRX.TRX_NUMBER <= :p_invoice_number_high';
   ELSIF var.p_invoice_number_high IS NULL THEN
      INVOICE_NUMBER_WHERE := ' AND TRX.TRX_NUMBER >= :p_invoice_number_low';
   ELSE
      INVOICE_NUMBER_WHERE := ' AND TRX.TRX_NUMBER BETWEEN :p_invoice_number_low AND :p_invoice_number_high';
   END IF;

   IF var.p_receipt_date_low IS NULL AND var.p_receipt_date_high IS NULL THEN
      RECEIPT_DATE_WHERE := NULL;
   ELSIF var.p_receipt_date_low IS NULL THEN
      RECEIPT_DATE_WHERE := ' AND CR.RECEIPT_DATE <= :p_receipt_date_high';
   ELSIF var.p_receipt_date_high IS NULL THEN
      RECEIPT_DATE_WHERE := ' AND CR.RECEIPT_DATE >= :p_receipt_date_low';
   ELSE
      RECEIPT_DATE_WHERE := ' AND CR.RECEIPT_DATE BETWEEN :p_receipt_date_low AND :p_receipt_date_high';
   END IF;

   IF var.p_currency_code IS NULL THEN
      CURRENCY_CODE_WHERE := NULL;
   ELSE
      CURRENCY_CODE_WHERE := ' AND CR.CURRENCY_CODE = :p_currency_code';
   END IF;

   IF var.p_bank_account_name IS NULL THEN
      BANK_NAME_WHERE := NULL;
   ELSE
      BANK_NAME_WHERE := ' AND CBA.BANK_ACCOUNT_NAME = :p_bank_account_name';
   END IF;

   IF var.p_payment_method IS NULL THEN
      PAYMENT_METHOD_WHERE := NULL;
   ELSE
      PAYMENT_METHOD_WHERE := ' AND ARM.NAME = :p_payment_method';
   END IF;

   IF var.p_confirmed_flag IS NULL THEN
      CONFIRMED_FLAG_WHERE := NULL;
   ELSE
      CONFIRMED_FLAG_WHERE := ' AND nvl(CR.CONFIRMED_FLAG,''Y'') = :p_confirmed_flag';
   END IF;

   -- reset next variables to NULL, for APPLIED receipts, we want to use gl_date range against RA and not CRH
   CRH_GL_DATE_WHERE := NULL;
   INCRH_GL_DATE_WHERE := NULL;
   RA_GL_DATE_WHERE := NULL;
   CRHNEW_GL_DATE_WHERE := NULL;

   IF var.p_gl_date_low IS NULL AND var.p_gl_date_high IS NULL THEN
      CRH_GL_DATE_WHERE := NULL;
      INCRH_GL_DATE_WHERE := NULL;
      CRHNEW_GL_DATE_WHERE := NULL;
   ELSIF var.p_gl_date_low IS NULL THEN
      if var.calling_program <> 'APPLIED' THEN
         CRH_GL_DATE_WHERE := ' AND CRH.GL_DATE <= :p_gl_date_high';
         INCRH_GL_DATE_WHERE := ' AND INCRH.GL_DATE <= :p_gl_date_high';
         CRHNEW_GL_DATE_WHERE := ' AND CRHNEW.GL_DATE(+) <= :p_gl_date_high';

      else
         RA_GL_DATE_WHERE := ' AND RA.GL_DATE <= :p_gl_date_high';
      end if;
   ELSIF var.p_gl_date_high IS NULL THEN
      if var.calling_program <> 'APPLIED' THEN
         CRH_GL_DATE_WHERE := ' AND CRH.GL_DATE >= :p_gl_date_low';
         INCRH_GL_DATE_WHERE := ' AND INCRH.GL_DATE >= :p_gl_date_low';
         CRHNEW_GL_DATE_WHERE := ' AND CRHNEW.GL_DATE(+) >= :p_gl_date_low';

      else
         RA_GL_DATE_WHERE := ' AND RA.GL_DATE >= :p_gl_date_low';
      end if;
   ELSE
      if var.calling_program <> 'APPLIED' THEN
         CRH_GL_DATE_WHERE := ' AND CRH.GL_DATE BETWEEN :p_gl_date_low AND :p_gl_date_high';
         INCRH_GL_DATE_WHERE := ' AND INCRH.GL_DATE BETWEEN :p_gl_date_low AND :p_gl_date_high';
         CRHNEW_GL_DATE_WHERE := ' AND CRHNEW.GL_DATE(+) BETWEEN :p_gl_date_low AND :p_gl_date_high';

      else
         RA_GL_DATE_WHERE := ' AND RA.GL_DATE  BETWEEN :p_gl_date_low AND :p_gl_date_high';
      end if;
   END IF;


   IF var.p_doc_sequence_name is not null THEN
     DOC_SEQUENCE_NAME_WHERE := ' AND DOCSEQ.DOC_SEQUENCE_ID = '''|| var.p_doc_sequence_name ||'''';
   ELSE
     DOC_SEQUENCE_NAME_WHERE := null;
   END IF;

   IF var.p_doc_sequence_number_from IS NULL and var.p_doc_sequence_number_from is NULL THEN
      DOC_SEQUENCE_NUMBER_WHERE := NULL;
   ELSIF var.p_doc_sequence_number_from IS NULL THEN
      DOC_SEQUENCE_NUMBER_WHERE := ' AND CR.DOC_SEQUENCE_VALUE <=  '''|| var.p_doc_sequence_number_to ||'''';
   ELSIF var.p_doc_sequence_number_to IS NULL THEN
      DOC_SEQUENCE_NUMBER_WHERE := ' AND CR.DOC_SEQUENCE_VALUE >=  '''|| var.p_doc_sequence_number_from ||'''';
   ELSE
      DOC_SEQUENCE_NUMBER_WHERE := ' AND CR.DOC_SEQUENCE_VALUE between '''|| var.p_doc_sequence_number_from ||
                                   ''' AND '''|| var.p_doc_sequence_number_to ||'''';
   END IF;

   fa_rx_util_pkg.debug('Define DECODE strings');

   DECODE_CR_TYPE           := 'DECODE(CR.TYPE,''CASH'',:L_CASH,''MISC'',:L_MISC)';
   DECODE_CR_STATUS         := 'DECODE(CR.STATUS,''APP'',:L_APP,''NSF'',:L_NSF,''REV'',:L_REV,''STOP'',:L_STOP, ' ||
                               ' ''UNAPP'',:L_UNAPP,''UNID'',:L_UNID)';
   DECODE_CR_REFERENCE_TYPE := 'DECODE(CR.REFERENCE_TYPE,''PAYMENT'',:L_PAYMENT,''RECEIPT'',:L_RECEIPT,''REMITTANCE'',:L_REMITTANCE)';
   DECODE_CRH_STATUS        := 'DECODE(CRH.STATUS,''APPROVED'',:L_APPROVED,''CLEARED'',:L_CLEARED,''CONFIRMED'',:L_CONFIRMED, ' ||
                               ' ''REMITTED'',:L_REMITTED,''REVERSED'',:L_REVERSED)';
   DECODE_CRH_AMOUNT        := 'DECODE(CRH.STATUS,''REVERSED'',CRH.AMOUNT*-1,CRH.AMOUNT)';
   DECODE_CRH_ACCTD_AMOUNT  := 'DECODE(CRH.STATUS,''REVERSED'',CRH.ACCTD_AMOUNT*-1,CRH.ACCTD_AMOUNT)';
   DECODE_CRH_FD_AMOUNT     := 'DECODE(CRH.STATUS,''REVERSED'',CRH.FACTOR_DISCOUNT_AMOUNT*-1,CRH.FACTOR_DISCOUNT_AMOUNT)';
   DECODE_CRH_AFD_AMOUNT    := 'DECODE(CRH.STATUS,''REVERSED'',CRH.ACCTD_FACTOR_DISCOUNT_AMOUNT*-1,CRH.ACCTD_FACTOR_DISCOUNT_AMOUNT)';

   fa_rx_util_pkg.debug('Start Assign_columns');
   -- fa_rx_util_pkg.assign_column(unique seq#, select field, field in itf, into variable, type, len);

   fa_rx_util_pkg.assign_column('10 ',null                                          ,'ORGANIZATION_NAME'               ,
                                'arrx_rc.var.organization_name'              ,'VARCHAR2', 50);
   fa_rx_util_pkg.assign_column('20 ',null                                          ,'FUNCTIONAL_CURRENCY_CODE'        ,
                                'arrx_rc.var.functional_currency_code'       ,'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('30 ','CR.STATUS'                                   ,null                              ,
                                'arrx_rc.var.cr_status'                      ,'VARCHAR2', 40);
   fa_rx_util_pkg.assign_column('40 ','CRH.STATUS'                                  ,null                              ,
                                'arrx_rc.var.crh_status'                     ,'VARCHAR2', 40);
   fa_rx_util_pkg.assign_column('50 ','DECODE(CRH.STATUS, ''REVERSED'', BATCHFIRST.BATCH_ID, BATCH.BATCH_ID)','BATCH_ID'  ,
                                'arrx_rc.var.batch_id'                       ,'NUMBER');
   fa_rx_util_pkg.assign_column('60 ','DECODE(CRH.STATUS, ''REVERSED'', BATCHFIRST.NAME, BATCH.NAME)','BATCH_NAME'     ,
                                'arrx_rc.var.batch_name'                     ,'VARCHAR2', 20);
   fa_rx_util_pkg.assign_column('70 ','CR.CASH_RECEIPT_ID'                          ,'CASH_RECEIPT_ID'                 ,
                                'arrx_rc.var.cash_receipt_id'                ,'NUMBER');
   fa_rx_util_pkg.assign_column('80 ','CR.RECEIPT_NUMBER'                           ,'RECEIPT_NUMBER'                  ,
                                'arrx_rc.var.receipt_number'                 ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('90 ','CR.CURRENCY_CODE'                            ,'RECEIPT_CURRENCY_CODE'           ,
                                'arrx_rc.var.receipt_currency_code'          ,'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('100','CR.EXCHANGE_RATE'                            ,'EXCHANGE_RATE'                   ,
                                'arrx_rc.var.exchange_rate'                  ,'NUMBER');
   fa_rx_util_pkg.assign_column('110','CR.EXCHANGE_DATE'                            ,'EXCHANGE_DATE'                   ,
                                'arrx_rc.var.exchange_date'                  ,'DATE');
   fa_rx_util_pkg.assign_column('120','CR.EXCHANGE_RATE_TYPE'                       ,'EXCHANGE_TYPE'                   ,
                                'arrx_rc.var.exchange_type'                  ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('130','DOCSEQ.NAME'                                 ,'DOC_SEQUENCE_NAME'               ,
                                'arrx_rc.var.doc_sequence_name'              ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('140','CR.DOC_SEQUENCE_VALUE'                       ,'DOC_SEQUENCE_VALUE'              ,
                                'arrx_rc.var.doc_sequence_value'             ,'NUMBER');
   fa_rx_util_pkg.assign_column('150','CR.DEPOSIT_DATE'                             ,'DEPOSIT_DATE'                    ,
                                'arrx_rc.var.deposit_date'                   ,'DATE');
   fa_rx_util_pkg.assign_column('160','CR.RECEIPT_DATE'                             ,'RECEIPT_DATE'                    ,
                                'arrx_rc.var.receipt_date'                   ,'DATE');
   fa_rx_util_pkg.assign_column('170',DECODE_CR_TYPE                                ,'RECEIPT_TYPE'                    ,
                                'arrx_rc.var.receipt_type'                   ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('180',DECODE_CR_STATUS                              ,'RECEIPT_STATUS'                  ,
                                'arrx_rc.var.receipt_status'                 ,'VARCHAR2', 40);
   fa_rx_util_pkg.assign_column('190','CR.MISC_PAYMENT_SOURCE'                      ,'MISC_PAYMENT_SOURCE'             ,
                                'arrx_rc.var.misc_payment_source'            ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('200','TAX.TAX_CODE'                                ,'TAX_CODE'                        ,
                                'arrx_rc.var.tax_code'                       ,'VARCHAR2', 50);
   fa_rx_util_pkg.assign_column('210',DECODE_CR_REFERENCE_TYPE                      ,'REFERENCE_TYPE'                  ,
                                'arrx_rc.var.reference_type'                 ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('220','CR.ANTICIPATED_CLEARING_DATE'                ,'ANTICIPATED_CLEARING_DATE'       ,
                                'arrx_rc.var.anticipated_clearing_date'      ,'DATE');
   fa_rx_util_pkg.assign_column('230','ABB.BANK_NAME'                               ,'BANK_NAME'                       ,
                                'arrx_rc.var.bank_name'                      ,'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('240','ABB.BANK_NAME_ALT'                           ,'BANK_NAME_ALT'                   ,
                                'arrx_rc.var.bank_name_alt'                  ,'VARCHAR2',320);
   fa_rx_util_pkg.assign_column('250','ABB.BANK_BRANCH_NAME'                        ,'BANK_BRANCH_NAME'                ,
                                'arrx_rc.var.bank_branch_name'               ,'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('260','ABB.BANK_BRANCH_NAME_ALT'                    ,'BANK_BRANCH_NAME_ALT'            ,
                                'arrx_rc.var.bank_branch_name_alt'           ,'VARCHAR2',320);
   fa_rx_util_pkg.assign_column('270','ABB.BANK_NUMBER'                             ,'BANK_NUMBER'                     ,
                                'arrx_rc.var.bank_number'                    ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('280','ABB.BRANCH_NUMBER'                           ,'BANK_BRANCH_NUMBER'              ,
                                'arrx_rc.var.bank_branch_number'             ,'VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('290','CBA.BANK_ACCOUNT_NAME'                       ,'BANK_ACCOUNT_NAME'               ,
                                'arrx_rc.var.bank_account_name'              ,'VARCHAR2', 80);
   fa_rx_util_pkg.assign_column('300','CBA.BANK_ACCOUNT_NAME_ALT'                   ,'BANK_ACCOUNT_NAME_ALT'           ,
                                'arrx_rc.var.bank_account_name_alt'          ,'VARCHAR2',320);
   fa_rx_util_pkg.assign_column('310','CBA.CURRENCY_CODE'                           ,'BANK_ACCOUNT_CURRENCY'           ,
                                'arrx_rc.var.bank_account_currency'          ,'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('320','ARM.NAME'                                    ,'RECEIPT_METHOD'                  ,
                                'arrx_rc.var.receipt_method'                 ,'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('330','CRH.CASH_RECEIPT_HISTORY_ID'                 ,'CASH_RECEIPT_HISTORY_ID'         ,
                                'arrx_rc.var.cash_receipt_history_id'        ,'NUMBER');
   fa_rx_util_pkg.assign_column('340','CRH.GL_DATE'                                 ,'GL_DATE'                         ,
                                'arrx_rc.var.gl_date'                        ,'DATE');
   fa_rx_util_pkg.assign_column('350',DECODE_CRH_AMOUNT                             ,'RECEIPT_AMOUNT'                  ,
                                'arrx_rc.var.receipt_amount'                 ,'NUMBER');
   fa_rx_util_pkg.assign_column('360',DECODE_CRH_STATUS                             ,'RECEIPT_HISTORY_STATUS'          ,
                                'arrx_rc.var.receipt_history_status'         ,'VARCHAR2', 40);
   fa_rx_util_pkg.assign_column('370',DECODE_CRH_ACCTD_AMOUNT                       ,'ACCTD_RECEIPT_AMOUNT'            ,
                                'arrx_rc.var.acctd_receipt_amount'           ,'NUMBER');
   fa_rx_util_pkg.assign_column('380',DECODE_CRH_FD_AMOUNT                          ,'FACTOR_DISCOUNT_AMOUNT'          ,
                                'arrx_rc.var.factor_discount_amount'         ,'NUMBER');
   fa_rx_util_pkg.assign_column('390',DECODE_CRH_AFD_AMOUNT                         ,'ACCTD_FACTOR_DISCOUNT_AMOUNT'    ,
                                'arrx_rc.var.acctd_factor_discount_amount'   ,'NUMBER');
   fa_rx_util_pkg.assign_column('400','CC.CODE_COMBINATION_ID'                      ,'ACCOUNT_CODE_COMBINATION_ID'     ,
                                'arrx_rc.var.account_code_combination_id'    ,'NUMBER');
   fa_rx_util_pkg.assign_column('410',null                                          ,'DEBIT_ACCOUNT'                   ,
                                'arrx_rc.var.debit_account'                  ,'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('420',null                                          ,'DEBIT_ACCOUNT_DESC'              ,
                                'arrx_rc.var.debit_account_desc'             ,'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('430',null                                          ,'DEBIT_BALANCING'                 ,
                                'arrx_rc.var.debit_balancing'                ,'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('440',null                                          ,'DEBIT_BALANCING_DESC'            ,
                                'arrx_rc.var.debit_balancing_desc'           ,'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('450',null                                          ,'DEBIT_NATACCT'                   ,
                                'arrx_rc.var.debit_natacct'                  ,'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('460',null                                          ,'DEBIT_NATACCT_DESC'              ,
                                'arrx_rc.var.debit_natacct_desc'             ,'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('470','CUST.CUST_ACCOUNT_ID'                            ,'CUSTOMER_ID'                 ,
                                'arrx_rc.var.customer_id'                    ,'NUMBER');
/*  bug 5724171*/
   fa_rx_util_pkg.assign_column('480','SUBSTRB(PARTY.PARTY_NAME,1,240)'             ,'CUSTOMER_NAME'       ,
                                'arrx_rc.var.customer_name'                  ,'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('490','DECODE(PARTY.PARTY_TYPE, ''ORGANIZATION'',PARTY.ORGANIZATION_NAME_PHONETIC, NULL)','CUSTOMER_NAME_ALT',
                                'arrx_rc.var.customer_name_alt'              ,'VARCHAR2',320);
   fa_rx_util_pkg.assign_column('500','CUST.ACCOUNT_NUMBER'                        ,'CUSTOMER_NUMBER'                  ,
                                'arrx_rc.var.customer_number'                ,'VARCHAR2', 30);

   -- define FROM_CLAUSE
   IF var.calling_program in ('RECEIPT','APPLIED','MISC','ACTUAL') then

      fa_rx_util_pkg.debug('Define FROM_CLAUSE using _ALL tables');

      IF NVL(var.ca_sob_type,'P') = 'P' THEN
         fa_rx_util_pkg.From_Clause :=
               'AR_CASH_RECEIPTS_ALL CR,
                FND_DOCUMENT_SEQUENCES DOCSEQ,
                AR_VAT_TAX_ALL TAX,
                CE_BANK_ACCOUNTS CBA,
                CE_BANK_ACCT_USES_ALL ABA,
                CE_BANK_BRANCHES_V ABB,
                AR_RECEIPT_METHODS ARM,
                AR_CASH_RECEIPT_HISTORY_ALL CRH,
                GL_CODE_COMBINATIONS CC,
                HZ_CUST_ACCOUNTS_ALL CUST,
                HZ_PARTIES PARTY,
                AR_BATCHES_ALL BATCH,
                AR_CASH_RECEIPT_HISTORY_ALL CRHFIRST,
                AR_BATCHES_ALL BATCHFIRST';
      ELSE
         fa_rx_util_pkg.From_Clause :=
               'AR_CASH_RECEIPTS_ALL_MRC_V CR,
                FND_DOCUMENT_SEQUENCES DOCSEQ,
                AR_VAT_TAX_ALL TAX,
                CE_BANK_ACCOUNTS CBA,
                CE_BANK_ACCT_USES_ALL ABA,
                CE_BANK_BRANCHES_V ABB,
                AR_RECEIPT_METHODS ARM,
                AR_CASH_RECEIPT_HIST_ALL_MRC_V CRH,
                GL_CODE_COMBINATIONS CC,
                HZ_CUST_ACCOUNTS_ALL CUST,
                HZ_PARTIES PARTY,
                AR_BATCHES_ALL_MRC_V BATCH,
                AR_CASH_RECEIPT_HIST_ALL_MRC_V CRHFIRST,
                AR_BATCHES_ALL_MRC_V BATCHFIRST';
      END IF;

  ELSE

      fa_rx_util_pkg.debug('Define FROM_CLAUSE using org-striped views');

      IF NVL(var.ca_sob_type,'P') = 'P' THEN
         fa_rx_util_pkg.From_Clause :=
               'AR_CASH_RECEIPTS CR,
                FND_DOCUMENT_SEQUENCES DOCSEQ,
                AR_VAT_TAX TAX,
--                AP_BANK_ACCOUNTS ABA,
--                AP_BANK_BRANCHES ABB,
		 CE_BANK_ACCOUNTS CBA,
                CE_BANK_ACCT_USES_ALL ABA,
                CE_BANK_BRANCHES_V ABB,
                AR_RECEIPT_METHODS ARM,
                AR_CASH_RECEIPT_HISTORY CRH,
                GL_CODE_COMBINATIONS CC,
                HZ_CUST_ACCOUNTS CUST,
                HZ_PARTIES PARTY,
                AR_BATCHES BATCH,
                AR_CASH_RECEIPT_HISTORY CRHFIRST,
                AR_BATCHES BATCHFIRST';
      ELSE
         fa_rx_util_pkg.From_Clause :=
               'AR_CASH_RECEIPTS_MRC_V CR,
                FND_DOCUMENT_SEQUENCES DOCSEQ,
                AR_VAT_TAX TAX,
--                AP_BANK_ACCOUNTS ABA,
--                AP_BANK_BRANCHES ABB,
	         CE_BANK_ACCOUNTS CBA,
                CE_BANK_ACCT_USES_ALL ABA,
                CE_BANK_BRANCHES_V ABB,
                AR_RECEIPT_METHODS ARM,
                AR_CASH_RECEIPT_HIST_MRC_V CRH,
                GL_CODE_COMBINATIONS CC,
                HZ_CUST_ACCOUNTS CUST,
                HZ_PARTIES PARTY,
                AR_BATCHES_MRC_V BATCH,
                AR_CASH_RECEIPT_HIST_MRC_V CRHFIRST,
                AR_BATCHES_MRC_V BATCHFIRST';
      END IF;

  END IF;

  fa_rx_util_pkg.debug('Define WHERE_CLAUSE');

  fa_rx_util_pkg.Where_Clause := '
                CR.CASH_RECEIPT_ID = CRHFIRST.CASH_RECEIPT_ID
                AND CRHFIRST.FIRST_POSTED_RECORD_FLAG = ''Y''
                AND CRHFIRST.BATCH_ID = BATCHFIRST.BATCH_ID(+)
                AND CRH.BATCH_ID = BATCH.BATCH_ID(+)
                AND CR.DOC_SEQUENCE_ID = DOCSEQ.DOC_SEQUENCE_ID(+)
                AND CR.VAT_TAX_ID = TAX.VAT_TAX_ID(+)
                AND CR.REMIT_BANK_ACCT_USE_ID = ABA.BANK_ACCT_USE_ID
                AND CBA.BANK_BRANCH_ID = ABB.BRANCH_PARTY_ID
                AND ABA.BANK_ACCOUNT_ID = CBA.BANK_ACCOUNT_ID
                AND CR.RECEIPT_METHOD_ID = ARM.RECEIPT_METHOD_ID
                AND CR.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
                AND CC.CODE_COMBINATION_ID = CRH.ACCOUNT_CODE_COMBINATION_ID
                AND CR.PAY_FROM_CUSTOMER = CUST.CUST_ACCOUNT_ID(+)
                AND CUST.PARTY_ID = PARTY.PARTY_ID(+) '||
                BATCH_NAME_WHERE ||' '||
                CUSTOMER_NAME_WHERE ||' '||
                DEPOSIT_DATE_WHERE ||' '||
                RECEIPT_STATUS_WHERE ||' '||
                RECEIPT_NUMBER_WHERE ||' '||
                INVOICE_NUMBER_WHERE ||' '||
                RECEIPT_DATE_WHERE ||' '||
                CURRENCY_CODE_WHERE ||' '||
                BANK_NAME_WHERE ||' '||
                PAYMENT_METHOD_WHERE ||' '||
                DOC_SEQUENCE_NUMBER_WHERE || ' ' ||
                DOC_SEQUENCE_NAME_WHERE || ' ' ||
                CONFIRMED_FLAG_WHERE || ' ' ||
                CRH_GL_DATE_WHERE;

  if var.calling_program in ('RECEIPT','APPLIED','MISC','ACTUAL') THEN

     fa_rx_util_pkg.debug('Define Multi-org logic');

    --Bug 5244313 added the var.books_id in the where clause to pickup the sob based on the reporting context
    -- if p_sob_id is null
     select CHART_OF_ACCOUNTS_ID,CURRENCY_CODE,NAME
     into var.p_coa_id,var.functional_currency_code,var.organization_name
     from GL_SETS_OF_BOOKS
     where SET_OF_BOOKS_ID =nvl( var.p_sob_id,var.books_id);

     fa_rx_util_pkg.debug('Set of Books ID      : '||var.p_sob_id);
     fa_rx_util_pkg.debug('Chart of Accounts ID : '||var.p_coa_id);
     fa_rx_util_pkg.debug('Functional Currency  : '||var.functional_currency_code);
     fa_rx_util_pkg.debug('Organization Name    : '||var.organization_name);

     XLA_MO_REPORTING_API.Initialize(var.p_reporting_level, var.p_reporting_entity_id, 'AUTO');

     L_CR_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('CR',NULL);
     L_TAX_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('TAX',NULL);
     L_ABA_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('ABA',NULL);
     L_CRH_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('CRH',NULL);
     L_CUST_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('CUST',NULL);
     L_CRHFIRST_ORG_WHERE   := XLA_MO_REPORTING_API.Get_Predicate('CRHFIRST',NULL);
     L_BATCHFIRST_ORG_WHERE := XLA_MO_REPORTING_API.Get_Predicate('BATCHFIRST',NULL);
     L_BATCH_ORG_WHERE      := XLA_MO_REPORTING_API.Get_Predicate('BATCH',NULL);
     L_RA_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('RA',NULL);
     L_MISC_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('MISC',NULL);
     L_INCRH_ORG_WHERE      := XLA_MO_REPORTING_API.Get_Predicate('INCRH',NULL);
     L_CRHNEW_ORG_WHERE     := XLA_MO_REPORTING_API.Get_Predicate('CRHNEW',NULL);

     L_CI_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('CI',NULL);
     L_RA_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('RA',NULL);
     L_TRX_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('TRX',NULL);
     L_REC_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('REC',NULL);
     L_RAC_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('RAC',NULL);
     L_PS_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('PS',NULL);
     L_MCD_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('MCD',NULL);
     L_ARD_ORG_WHERE        := XLA_MO_REPORTING_API.Get_Predicate('ARD',NULL);
     L_BS_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('BS',NULL);

     IF var.p_co_seg_low IS NULL AND var.p_co_seg_high IS NULL THEN
        CO_SEG_WHERE := NULL;
     ELSIF var.p_co_seg_low IS NULL THEN
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.p_coa_id,
                             p_table_alias => 'CC',
                             p_mode => 'WHERE',
                             p_qualifier => 'GL_BALANCING',
                             p_function => '<=',
                             p_operand1 => var.p_co_seg_high);
     ELSIF var.p_co_seg_high IS NULL THEN
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.p_coa_id,
                             p_table_alias => 'CC',
                             p_mode => 'WHERE',
                             p_qualifier => 'GL_BALANCING',
                             p_function => '>=',
                             p_operand1 => var.p_co_seg_low);
     ELSE
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.p_coa_id,
                             p_table_alias => 'CC',
                             p_mode => 'WHERE',
                             p_qualifier => 'GL_BALANCING',
                             p_function => 'BETWEEN',
                             p_operand1 => var.p_co_seg_low,
                             p_operand2 => var.p_co_seg_high);
     END IF;

  end if;

  if var.calling_program = 'RECEIPT' then

     fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Receipts Register');

     IF var.p_gl_date_low is NOT NULL THEN
        fa_rx_util_pkg.Where_Clause :=
           fa_rx_util_pkg.Where_Clause ||'
           AND ( NOT EXISTS
                 (SELECT ''App Exists''
                  FROM     AR_RECEIVABLE_APPLICATIONS_ALL RA
                  WHERE CR.CASH_RECEIPT_ID            = RA.CASH_RECEIPT_ID
                  AND   CR.TYPE                       = ''CASH''
                  AND   NVL(RA.CONFIRMED_FLAG, ''Y'') = ''Y''
                  AND   RA.GL_DATE                    < :p_gl_date_low ' || L_RA_ORG_WHERE ||
                 ')
                AND NOT EXISTS
                 (SELECT ''App Exists''
                  FROM   AR_MISC_CASH_DISTRIBUTIONS_ALL MISC
                  WHERE  CR.CASH_RECEIPT_ID    = MISC.CASH_RECEIPT_ID
                  AND    CR.TYPE              = ''MISC''
                  AND    MISC.GL_DATE         < :p_gl_date_low ' || L_MISC_ORG_WHERE ||
                 ')
                OR CRH.STATUS = ''REVERSED'' )';
      END IF;


     fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Receipts Registe Pos1');

      IF NVL(var.ca_sob_type,'P') = 'P' THEN
         fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause ||
                      ' AND ((CRH.CURRENT_RECORD_FLAG = ''Y'' AND CRH.STATUS = ''REVERSED'' )
                      OR (CRH.CASH_RECEIPT_HISTORY_ID IN (
                             SELECT NVL(MAX(CRHNEW.CASH_RECEIPT_HISTORY_ID ), MAX(INCRH.CASH_RECEIPT_HISTORY_ID))
                               FROM AR_CASH_RECEIPT_HISTORY_ALL INCRH ,
                                    AR_CASH_RECEIPT_HISTORY_ALL CRHNEW
                              WHERE INCRH.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
                              AND   CRHNEW.CASH_RECEIPT_ID(+) = INCRH.CASH_RECEIPT_ID
                              AND   CRHNEW.CURRENT_RECORD_FLAG(+) = ''Y''
                              AND   CRHNEW.STATUS(+) <> ''REVERSED''
                              AND   INCRH.STATUS <> ''REVERSED'' ' ||
                             INCRH_GL_DATE_WHERE ||
                             CRHNEW_GL_DATE_WHERE ||
                             L_INCRH_ORG_WHERE   ||
                             L_CRHNEW_ORG_WHERE   ||
                             ' )))' || CO_SEG_WHERE;
      ELSE
         fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause ||
                      ' AND ((CRH.CURRENT_RECORD_FLAG = ''Y'' AND CRH.STATUS = ''REVERSED'' )
                      OR (CRH.CASH_RECEIPT_HISTORY_ID IN (
                             SELECT MAX(INCRH.CASH_RECEIPT_HISTORY_ID)
                               FROM AR_CASH_RECEIPT_HIST_ALL_MRC_V INCRH
                              WHERE INCRH.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
                             AND INCRH.STATUS <> ''REVERSED'' ' ||
                             INCRH_GL_DATE_WHERE ||
                             L_INCRH_ORG_WHERE || ' )))' || CO_SEG_WHERE;
      END IF;
    fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Receipts Registe Pos2');

      fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause || ' ' ||
                    L_CR_ORG_WHERE || ' ' ||
                    L_TAX_ORG_WHERE || ' ' ||
                    L_ABA_ORG_WHERE || ' ' ||
                    L_CRH_ORG_WHERE || ' ' ||
                    L_CUST_ORG_WHERE || ' ' ||
                    L_BATCH_ORG_WHERE || ' ' ||
                    L_CRHFIRST_ORG_WHERE || ' ' ||
                    L_BATCHFIRST_ORG_WHERE;
  fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Receipts Registe Pos3');

   -----------------------------------------
   ELSIF var.calling_program = 'ACTUAL' then
   -----------------------------------------

     fa_rx_util_pkg.debug('Define additional ASSIGN_COLUMN for Actual Receipts Register');

     DECODE_RA_STATUS := 'DECODE(RA.STATUS,''ACC'',:L_ACCO,''APP'',:L_APPL,''UNAPP'',:L_UNAPPL,''UNID'',:L_UNIDE)';

     fa_rx_util_pkg.assign_column('A1 ','RA.RECEIVABLE_APPLICATION_ID' ,'RECEIVABLE_APPLICATION_ID',
                                  'arrx_rc.var.receivable_application_id' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A2 ','RA.APPLY_DATE','APPLY_DATE',
                                  'arrx_rc.var.apply_date'                     ,'DATE');
     fa_rx_util_pkg.assign_column('A3 ',DECODE_RA_STATUS,'APPLICATION_STATUS',
                                  'arrx_rc.var.application_status' ,'VARCHAR2', 20);
     fa_rx_util_pkg.assign_column('A4 ','RA.AMOUNT_APPLIED' ,'AMOUNT_APPLIED_TO',
                                  'arrx_rc.var.amount_applied_to' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A5 ','NVL(RA.AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED)' ,'AMOUNT_APPLIED_FROM',
                                  'arrx_rc.var.amount_applied_from' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A6 ','NVL(RA.ACCTD_AMOUNT_APPLIED_TO,RA.ACCTD_AMOUNT_APPLIED_FROM)' ,'ACCTD_AMOUNT_APPLIED_TO',
                                  'arrx_rc.var.acctd_amount_applied_to' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A7 ','RA.ACCTD_AMOUNT_APPLIED_FROM' ,'ACCTD_AMOUNT_APPLIED_FROM',
                                  'arrx_rc.var.acctd_amount_applied_from' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A8 ','RA.EARNED_DISCOUNT_TAKEN' ,'EARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.earned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A9 ','RA.UNEARNED_DISCOUNT_TAKEN','UNEARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.unearned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A10','RA.ACCTD_EARNED_DISCOUNT_TAKEN' ,'ACCTD_EARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.acctd_earned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A11','RA.ACCTD_UNEARNED_DISCOUNT_TAKEN' ,'ACCTD_UNEARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.acctd_unearned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A12','TRX.CUSTOMER_TRX_ID' ,'APPLIED_CUSTOMER_TRX_ID',
                                  'arrx_rc.var.applied_customer_trx_id' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A13','DECODE(RA.STATUS, ''ACC'', :l_trx_on_acc, TRX.TRX_NUMBER)','TRX_NUMBER' ,
                                  'arrx_rc.var.trx_number','VARCHAR2', 20);
     fa_rx_util_pkg.assign_column('A14','TRX.INVOICE_CURRENCY_CODE','TRX_CURRENCY_CODE',
                                  'arrx_rc.var.trx_currency_code' ,'VARCHAR2', 15);
     fa_rx_util_pkg.assign_column('A15','TRX.TRX_DATE','TRX_DATE',
                                  'arrx_rc.var.trx_date','DATE');
     fa_rx_util_pkg.assign_column('A16','REC.AMOUNT','TRX_AMOUNT' ,
                                  'arrx_rc.var.trx_amount','NUMBER');
     fa_rx_util_pkg.assign_column('A17','REC.ACCTD_AMOUNT' ,'ACCTD_TRX_AMOUNT',
                                  'arrx_rc.var.acctd_trx_amount' ,'NUMBER');

     fa_rx_util_pkg.debug('Define additional FROM_CLAUSE for Actual Receipts Register');

     IF NVL(var.ca_sob_type,'P') = 'P' THEN
     fa_rx_util_pkg.From_Clause :=
               fa_rx_util_pkg.From_Clause || ',
                AR_RECEIVABLE_APPLICATIONS_ALL RA,
                RA_CUSTOMER_TRX_ALL TRX,
                RA_CUST_TRX_LINE_GL_DIST_ALL REC';
     ELSE
     fa_rx_util_pkg.From_Clause :=
               fa_rx_util_pkg.From_Clause || ',
                AR_RECEIVABLE_APPS_ALL_MRC_V RA,
                RA_CUSTOMER_TRX_ALL_MRC_V TRX,
                RA_TRX_LINE_GL_DIST_ALL_MRC_V REC';
     END IF;

     fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Actual Receipts Register');

     fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause || '
                          AND RA.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                          AND RA.DISPLAY = ''Y''
                          AND RA.APPLIED_CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID(+)
                          AND RA.APPLIED_CUSTOMER_TRX_ID = REC.CUSTOMER_TRX_ID(+)
                          AND REC.LATEST_REC_FLAG(+) = ''Y''
                          AND CRH.FIRST_POSTED_RECORD_FLAG = ''Y'' ';

    fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Actual Receipts Register Pos2');

      fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause || ' ' ||
                    L_CR_ORG_WHERE || ' ' ||
                    L_TAX_ORG_WHERE || ' ' ||
		    L_ABA_ORG_WHERE || ' ' ||
                    L_CRH_ORG_WHERE || ' ' ||
		    L_CUST_ORG_WHERE || ' ' ||
                    L_BATCH_ORG_WHERE || ' ' ||
                    L_CRHFIRST_ORG_WHERE || ' ' ||
                    L_BATCHFIRST_ORG_WHERE || ' ' ||
                    L_RA_ORG_WHERE || ' ' ||
                    L_TRX_ORG_WHERE || ' ' ||
                    L_REC_ORG_WHERE ;

   ------------------------------------------
   ELSIF var.calling_program = 'APPLIED' then
   ------------------------------------------

     fa_rx_util_pkg.debug('Define additional WHERE_CLAUSE for Applied Receipts Register');

     IF var.p_apply_date_low IS NULL AND var.p_apply_date_high IS NULL THEN
        APPLY_DATE_WHERE := NULL;
     ELSIF var.p_apply_date_low IS NULL THEN
        APPLY_DATE_WHERE := ' AND RA.APPLY_DATE <= :p_apply_date_high';
     ELSIF var.p_apply_date_high IS NULL THEN
        APPLY_DATE_WHERE := ' AND RA.APPLY_DATE >= :p_apply_date_low';
     ELSE
        APPLY_DATE_WHERE := ' AND RA.APPLY_DATE BETWEEN :p_apply_date_low AND :p_apply_date_high';
     END IF;

     IF var.p_co_seg_low IS NULL AND var.p_co_seg_high IS NULL THEN
        CO_SEG_WHERE := NULL;
     ELSIF var.p_co_seg_low IS NULL THEN
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.chart_of_accounts_id,
                                p_table_alias => 'CC2',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => '<=',
                                p_operand1 => var.p_co_seg_high);
     ELSIF var.p_co_seg_high IS NULL THEN
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.chart_of_accounts_id,
                                p_table_alias => 'CC2',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => '>=',
                                p_operand1 => var.p_co_seg_low);
     ELSE
       CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.chart_of_accounts_id,
                                p_table_alias => 'CC2',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => 'BETWEEN',
                                p_operand1 => var.p_co_seg_low,
                                p_operand2 => var.p_co_seg_high);
     END IF;

     IF var.p_receipt_gl_date_low IS NULL AND var.p_receipt_gl_date_high IS NULL THEN
        GL_DATE_WHERE := NULL;
     ELSIF var.p_receipt_gl_date_low IS NULL THEN
        GL_DATE_WHERE := ' AND RA.GL_DATE <= :p_receipt_gl_date_high';
     ELSIF var.p_receipt_gl_date_high IS NULL THEN
        GL_DATE_WHERE := ' AND RA.GL_DATE >= :p_receipt_gl_date_low';
     ELSE
        GL_DATE_WHERE := ' AND RA.GL_DATE BETWEEN :p_receipt_gl_date_low AND :p_receipt_gl_date_high';
     END IF;

     IF var.p_customer_number_low IS NULL AND var.p_customer_number_high IS NULL THEN
        CUST_NUM_WHERE := NULL;
     ELSIF var.p_customer_number_low IS NULL THEN
        CUST_NUM_WHERE := ' AND CUST.ACCOUNT_NUMBER <= :p_customer_number_high';
     ELSIF var.p_customer_number_high IS NULL THEN
        CUST_NUM_WHERE := ' AND CUST.ACCOUNT_NUMBER >= :p_customer_number_low';
     ELSE
        CUST_NUM_WHERE := ' AND CUST.ACCOUNT_NUMBER BETWEEN :p_customer_number_low AND :p_customer_number_high';
     END IF;

     if  var.p_invoice_type_low IS NULL AND var.p_invoice_type_high IS NUll THEN
        INV_TYPE_WHERE :=NULL;
     ELSIF var.p_invoice_type_low IS NULL THEN
        INV_TYPE_WHERE := ' AND arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') <= :p_invoice_type_high';
     ELSIF var.p_invoice_type_high IS NULL THEN
        INV_TYPE_WHERE := ' AND arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') >= :p_invoice_type_low';
     ELSE
        INV_TYPE_WHERE :=' AND arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') ' ||
                         ' BETWEEN :p_invoice_type_low AND :p_invoice_type_high';
     END IF;

     rec_gain_loss := 'NVL(RA.ACCTD_AMOUNT_APPLIED_FROM - RA.ACCTD_AMOUNT_APPLIED_TO,0)';
     applied_total :='NVL(RA.ACCTD_AMOUNT_APPLIED_TO,0)';

     ar_setup.get( name => 'AR_SHOW_BILLING_NUMBER', val  => BILL_FLAG );
     IF (BILL_FLAG = 'Y') THEN
       SHOW_BILL_WHERE := ' AND ps.cons_inv_id = ci.cons_inv_id(+)';
       SHOW_BILL_FROM := ', ar_cons_inv ci ';
     ELSE
       SHOW_BILL_WHERE := NULL;
       SHOW_BILL_FROM := NULL;
       L_CI_ORG_WHERE := NULL;
     END IF;

     fa_rx_util_pkg.debug('Define additional ASSIGN_COLUMNS for Applied Receipts Register');

     fa_rx_util_pkg.assign_column('A1 ','RA.RECEIVABLE_APPLICATION_ID' ,'RECEIVABLE_APPLICATION_ID',
                                  'arrx_rc.var.receivable_application_id' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A2 ','RA.APPLY_DATE' ,'APPLY_DATE' ,
                                  'arrx_rc.var.apply_date','DATE');
     fa_rx_util_pkg.assign_column('A3 ','RAC.ACCOUNT_NUMBER' ,'RELATED_CUSTOMER' ,
                                 'arrx_rc.var.related_customer','VARCHAR2', 50);
     fa_rx_util_pkg.assign_column('A4 ','NVL(RA.AMOUNT_APPLIED,0)','AMOUNT_APPLIED_TO',
                                  'arrx_rc.var.amount_applied_to' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A5 ','NVL(RA.AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED)' ,'AMOUNT_APPLIED_FROM',
                                  'arrx_rc.var.amount_applied_from' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A6 ',applied_total ,'ACCTD_AMOUNT_APPLIED_TO',
                                  'arrx_rc.var.acctd_amount_applied_to' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A7 ','NVL(RA.ACCTD_AMOUNT_APPLIED_FROM,0)' ,'ACCTD_AMOUNT_APPLIED_FROM',
                                  'arrx_rc.var.acctd_amount_applied_from' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A8 ','NVL(RA.EARNED_DISCOUNT_TAKEN,0)' ,'EARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.earned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A9 ','NVL(RA.UNEARNED_DISCOUNT_TAKEN,0)' ,'UNEARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.unearned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A10','NVL(RA.ACCTD_EARNED_DISCOUNT_TAKEN,0)' ,'ACCTD_EARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.acctd_earned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A11','NVL(RA.ACCTD_UNEARNED_DISCOUNT_TAKEN,0)' ,'ACCTD_UNEARNED_DISCOUNT_TAKEN',
                                  'arrx_rc.var.acctd_unearned_discount_taken' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A12','TRX.CUSTOMER_TRX_ID' ,'APPLIED_CUSTOMER_TRX_ID',
                                  'arrx_rc.var.applied_customer_trx_id' ,'NUMBER');

     IF (BILL_FLAG = 'Y') THEN
        fa_rx_util_pkg.assign_column('A13','decode(ra.status, ''ACC'', :L_ONACCOUNT
              , decode(ci.cons_billing_number, null, ps.trx_number
              , substrb(rtrim(ci.cons_billing_number)||''/''||rtrim(to_char(trx.trx_number)),1,30)))' ,'TRX_NUMBER',
              'arrx_rc.var.trx_number' ,'VARCHAR2', 30);-- bug 5767413
     ELSE
        fa_rx_util_pkg.assign_column('A13','decode(ra.status, ''ACC'', :L_ONACCOUNT, PS.TRX_NUMBER)','TRX_NUMBER' ,
                                     'arrx_rc.var.trx_number','VARCHAR2', 30);--bug 5767413
     END IF;

     fa_rx_util_pkg.assign_column('A14','TRX.INVOICE_CURRENCY_CODE' ,'TRX_CURRENCY_CODE',
                                  'arrx_rc.var.trx_currency_code' ,'VARCHAR2', 15);
     fa_rx_util_pkg.assign_column('A15','TRX.TRX_DATE' ,'TRX_DATE' ,
                                  'arrx_rc.var.trx_date','DATE');
     fa_rx_util_pkg.assign_column('A16','NVL(REC.AMOUNT,0)' ,'TRX_AMOUNT' ,
                                  'arrx_rc.var.trx_amount','NUMBER');
     fa_rx_util_pkg.assign_column('A17','NVL(REC.ACCTD_AMOUNT,0)' ,'ACCTD_TRX_AMOUNT',
                                  'arrx_rc.var.acctd_trx_amount' ,'NUMBER');
     fa_rx_util_pkg.assign_column('A18',rec_gain_loss ,'RECEIPT_GAIN_LOSS',
                                  'arrx_rc.var.receipt_gain_loss' ,'NUMBER');
     -- bug 1821300.  Override RR gl_date with ARR gl_date to avoid ora-00957
     fa_rx_util_pkg.assign_column('340','RA.GL_DATE' ,'GL_DATE' ,
                                  'arrx_rc.var.gl_date','DATE');
     -- bug 2379856.  Override CRH.ccid with RA.ccid
     fa_rx_util_pkg.assign_column('400','CC2.CODE_COMBINATION_ID' ,'ACCOUNT_CODE_COMBINATION_ID',
                                  'arrx_rc.var.account_code_combination_id' ,'NUMBER');

     fa_rx_util_pkg.debug('Define additional FROM_CLAUSE for Applied Receipts Register');

     IF NVL(var.ca_sob_type,'P') = 'P' THEN
        fa_rx_util_pkg.From_Clause :=
               fa_rx_util_pkg.From_Clause ||
               ', AR_RECEIVABLE_APPLICATIONS_ALL RA,
                  RA_CUSTOMER_TRX_ALL TRX,
                  RA_CUST_TRX_LINE_GL_DIST_ALL REC,
                  HZ_CUST_ACCOUNTS_ALL RAC ,
                  AR_PAYMENT_SCHEDULES_ALL PS ,
                  GL_CODE_COMBINATIONS CC2 ' || SHOW_BILL_FROM;
     ELSE
       fa_rx_util_pkg.From_Clause :=
               fa_rx_util_pkg.From_Clause ||
               ', AR_RECEIVABLE_APPS_ALL_MRC_V RA,
                  RA_CUSTOMER_TRX_ALL_MRC_V TRX,
                  RA_TRX_LINE_GL_DIST_ALL_MRC_V REC,
                  HZ_CUST_ACCOUNTS_ALL RAC ,
                  AR_PAYMENT_SCHEDULES_ALL_MRC_V PS ,
                  GL_CODE_COMBINATIONS CC2 ' || SHOW_BILL_FROM;
     END IF;

     fa_rx_util_pkg.Where_Clause :=
                 fa_rx_util_pkg.Where_Clause ||
                 ' AND RA.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                   AND ( RA.STATUS = ''APP'' OR
                       (RA.STATUS = ''ACTIVITY'' AND
                        RA.RECEIVABLES_TRX_ID = -16))
                  AND RA.APPLIED_CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID(+)
                  AND RA.APPLIED_CUSTOMER_TRX_ID = REC.CUSTOMER_TRX_ID(+)
                  AND RA.APPLIED_PAYMENT_SCHEDULE_ID = PS.PAYMENT_SCHEDULE_ID(+)
                  AND PS.CUSTOMER_ID = RAC.CUST_ACCOUNT_ID(+)
                  AND REC.LATEST_REC_FLAG(+) = ''Y''
                  AND RA.CODE_COMBINATION_ID = CC2.CODE_COMBINATION_ID
                  AND CRH.FIRST_POSTED_RECORD_FLAG = ''Y'' ' ||
                    APPLY_DATE_WHERE ||
                    GL_DATE_WHERE ||
                    RA_GL_DATE_WHERE ||
                    CUST_NUM_WHERE ||
                    INV_TYPE_WHERE ||
                    CO_SEG_WHERE ||
                    SHOW_BILL_WHERE || ' ' ||
                    L_CR_ORG_WHERE || ' ' ||
                    L_TAX_ORG_WHERE || ' ' ||
                    L_ABA_ORG_WHERE || ' ' ||
                    L_CRH_ORG_WHERE || ' ' ||
                    L_CUST_ORG_WHERE || ' ' ||
                    L_BATCH_ORG_WHERE || ' ' ||
                    L_CRHFIRST_ORG_WHERE || ' ' ||
                    L_BATCHFIRST_ORG_WHERE || ' ' ||
                    L_CI_ORG_WHERE || ' ' ||
                    L_RA_ORG_WHERE || ' ' ||
                    L_TRX_ORG_WHERE || ' ' ||
                    L_REC_ORG_WHERE || ' ' ||
                    L_RAC_ORG_WHERE || ' ' ||
                    L_PS_ORG_WHERE;

   ---------------------------------------
   ELSIF var.calling_program = 'MISC' then
   ---------------------------------------

     fa_rx_util_pkg.debug('Define additional ASSIGN_COLUMNS for Misc Receipts Register');

     fa_rx_util_pkg.assign_column('A1 ','decode(ARD.SOURCE_TYPE,''TAX'',NULL,MCD.PERCENT)' ,'MISC_PERCENT',
                                  'arrx_rc.var.percent' ,'NUMBER');
     -- bug5444415
     IF arp_global.sysparam.accounting_method='ACCRUAL' THEN
       fa_rx_util_pkg.assign_column('A2 ','decode(SIGN(MCD.AMOUNT), 1, ARD.AMOUNT_CR,-1, SIGN(MCD.AMOUNT) * ARD.AMOUNT_DR, 0)' ,'MISC_AMOUNT' ,
                                    'arrx_rc.var.misc_amount'          ,'NUMBER');
     ELSE
       fa_rx_util_pkg.assign_column('A2 ','MCD.AMOUNT','MISC_AMOUNT'           ,'arrx_rc.var.misc_amount'          ,'NUMBER');
     END IF ;
     fa_rx_util_pkg.assign_column('A3 ','BS.NAME' ,'BATCH_SOURCE',
                                  'arrx_rc.var.batch_source'         ,'VARCHAR2',50);
     /* Bugfix 2842928.  Override CRH.ccid with ARD.ccid */
     fa_rx_util_pkg.assign_column('400','CC2.CODE_COMBINATION_ID' ,'ACCOUNT_CODE_COMBINATION_ID',
                                  'arrx_rc.var.account_code_combination_id' ,'NUMBER');
     /* Bugfix 2842928.  Tax Code should be displayed only for TAX lines. */
     fa_rx_util_pkg.assign_column('200','decode(ARD.SOURCE_TYPE,''TAX'', TAX.TAX_CODE, NULL)' ,'TAX_CODE',
                                  'arrx_rc.var.tax_code' ,'VARCHAR2', 50);

     fa_rx_util_pkg.debug('Define additional FROM_CLAUSE for Misc Receipts Register');

   /* Bugfix 2842928.  Added GL_CODE_COMBINATIONS CC2, AR_DISTRIBUTIONS ARD */
     fa_rx_util_pkg.From_Clause :=
               fa_rx_util_pkg.From_Clause ||
               ' ,AR_MISC_CASH_DISTRIBUTIONS_ALL MCD,
                  AR_DISTRIBUTIONS_ALL ARD,
                  GL_CODE_COMBINATIONS CC2,
                  AR_BATCH_SOURCES_ALL BS ';

     IF var.p_gl_date_low IS NULL AND var.p_gl_date_high IS NULL THEN
       MCD_GL_DATE_WHERE := NULL;
     ELSIF var.p_gl_date_low IS NULL THEN
       MCD_GL_DATE_WHERE := ' AND MCD.GL_DATE <= :p_gl_date_high';
     ELSIF var.p_gl_date_high IS NULL THEN
       MCD_GL_DATE_WHERE := ' AND MCD.GL_DATE >= :p_gl_date_low';
     ELSE
       MCD_GL_DATE_WHERE := ' AND MCD.GL_DATE BETWEEN :p_gl_date_low AND :p_gl_date_high';
     END IF;
  /*bug 5030073-5039469*/
 IF var.p_co_seg_low IS NULL AND var.p_co_seg_high IS NULL THEN
        CO_SEG_WHERE := NULL;
     ELSIF var.p_co_seg_low IS NULL THEN
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.chart_of_accounts_id,
                                p_table_alias => 'CC2',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => '<=',
                                p_operand1 => var.p_co_seg_high);
     ELSIF var.p_co_seg_high IS NULL THEN
        CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.chart_of_accounts_id,
                                p_table_alias => 'CC2',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => '>=',
                                p_operand1 => var.p_co_seg_low);
     ELSE
       CO_SEG_WHERE := ' AND ' ||
        FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.chart_of_accounts_id,
                                p_table_alias => 'CC2',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => 'BETWEEN',
                                p_operand1 => var.p_co_seg_low,
                                p_operand2 => var.p_co_seg_high);
     END IF;

   -- Bug 2328165.  Removed "CR.REVERSAL_DATE IS NULL" so that reversed
   -- receipts shows up, added MCD_GL_DATE_WHERE to restrict the appearance
   -- of the receipt.

   -- Bug 2514857
   -- Added " CRH.FIRST_POSTED_RECORD_FLAG = 'Y' "
   /* Bugfix 2842928. */
   -- Bug 3376034
   -- Modified  (CRH.FIRST_POSTED_RECORD_FLAG = ''Y''  OR CRH.STATUS =''REVERSED'') '

   /*bug 5444415, Changed ARD.SOURCE_ID to ARD.SOURCE_ID(+), ARD.SOURCE_TABLE to ARD.SOURCE_TABLE(+) and
     ARD.CODE_COMBINATION_ID to MCD.CODE_COMBINATION_ID */
/*bug 5030073-5039469 Added Co_seg_where*/
     fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause ||
                     ' AND MCD.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID ' ||
                     ' AND MCD.MISC_CASH_DISTRIBUTION_ID = ARD.SOURCE_ID(+) AND ARD.SOURCE_TABLE(+) = ''MCD'''||
                     ' AND ARD.CODE_COMBINATION_ID = CC2.CODE_COMBINATION_ID'||
                     ' AND NVL(BATCH.BATCH_SOURCE_ID,-1) = BS.BATCH_SOURCE_ID(+) ' ||
                     ' AND CR.TYPE = ''MISC'' ' ||
                     ' AND ((CRH.CURRENT_RECORD_FLAG = ''Y'' AND CRH.STATUS = ''REVERSED'')
                             OR (CRH.CASH_RECEIPT_HISTORY_ID IN (
                                 SELECT NVL(CRHNEW.CASH_RECEIPT_HISTORY_ID, INCRH.CASH_RECEIPT_HISTORY_ID)
                                 FROM AR_CASH_RECEIPT_HISTORY_ALL INCRH ,
                                 AR_CASH_RECEIPT_HISTORY_ALL CRHNEW
                                 WHERE INCRH.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
                                 AND   INCRH.FIRST_POSTED_RECORD_FLAG = ''Y''
                                 AND   CRHNEW.CASH_RECEIPT_ID(+) = INCRH.CASH_RECEIPT_ID
                                 AND   CRHNEW.CURRENT_RECORD_FLAG(+) = ''Y''
                                 AND   CRHNEW.STATUS(+) <> ''REVERSED''
                                 AND   INCRH.STATUS <> ''REVERSED'' ' ||
                                 INCRH_GL_DATE_WHERE ||
                                 CRHNEW_GL_DATE_WHERE ||
                                 L_INCRH_ORG_WHERE   ||
                                 L_CRHNEW_ORG_WHERE   ||
                                 ' ))) ' ||
                     CO_SEG_WHERE ||' ' ||
                     MCD_GL_DATE_WHERE || ' ' ||
                     L_MCD_ORG_WHERE || ' ' ||
                     L_ARD_ORG_WHERE || ' ' ||
                     L_BS_ORG_WHERE;
   END IF;


   fa_rx_util_pkg.debug('arrx_rc.before_report()-');

end before_report;

procedure bind(c in integer)
is
   L_CASH                                varchar2(80);
   L_MISC                                varchar2(80);
   L_PAYMENT                             varchar2(80);
   L_RECEIPT                             varchar2(80);
   L_REMITTANCE                          varchar2(80);
   L_APPROVED                            varchar2(80);
   L_CLEARED                             varchar2(80);
   L_CONFIRMED                           varchar2(80);
   L_REMITTED                            varchar2(80);
   L_REVERSED                            varchar2(80);
   L_ACCO                                varchar2(80);
   L_APPL                                varchar2(80);
   L_UNAPPL                              varchar2(80);
   L_UNIDE                               varchar2(80);
   L_ONACCOUNT                           VARCHAR2(80);

begin
   fa_rx_util_pkg.debug('Define BIND variables');

   -- Bug 4219081
   IF var.p_reporting_level = 3000 then
      IF var.p_reporting_entity_id IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_reporting_entity_id', var.p_reporting_entity_id);
      END IF;
   END IF;

   IF var.p_deposit_date_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_deposit_date_low', var.p_deposit_date_low);
   END IF;
   IF var.p_deposit_date_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_deposit_date_high', var.p_deposit_date_high);
   END IF;

   IF var.p_receipt_date_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_receipt_date_low', var.p_receipt_date_low);
   END IF;
   IF var.p_receipt_date_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_receipt_date_high', var.p_receipt_date_high);
   END IF;

   IF var.p_gl_date_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_gl_date_low', var.p_gl_date_low);
   END IF;
   IF var.p_gl_date_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_gl_date_high', var.p_gl_date_high);
   END IF;

   IF var.p_batch_name_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_batch_name_low', var.p_batch_name_low);
   END IF;
   IF var.p_batch_name_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_batch_name_high', var.p_batch_name_high);
   END IF;
   /* bug 5724171*/
   IF var.p_customer_name_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_customer_name_low', var.p_customer_name_low);
      dbms_sql.bind_variable(c, 'len1',var.len1);
   END IF;
   IF var.p_customer_name_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_customer_name_high', var.p_customer_name_high);
      dbms_sql.bind_variable(c, 'len2',var.len2);
   END IF;

   IF var.p_receipt_status_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_receipt_status_low', var.p_receipt_status_low);
   END IF;
   IF var.p_receipt_status_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_receipt_status_high', var.p_receipt_status_high);
   END IF;

   IF var.p_receipt_number_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_receipt_number_low', var.p_receipt_number_low);
   END IF;
   IF var.p_receipt_number_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_receipt_number_high', var.p_receipt_number_high);
   END IF;

   IF var.p_invoice_number_low IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_invoice_number_low', var.p_invoice_number_low);
   END IF;
   IF var.p_invoice_number_high IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_invoice_number_high', var.p_invoice_number_high);
   END IF;

   IF var.p_currency_code IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_currency_code', var.p_currency_code);
   END IF;

   IF var.p_bank_account_name IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_bank_account_name', var.p_bank_account_name);
   END IF;

   IF var.p_payment_method IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_payment_method', var.p_payment_method);
   END IF;

   IF var.p_confirmed_flag IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'p_confirmed_flag', var.p_confirmed_flag);
   END IF;

   select MEANING into L_CASH       from ar_lookups where lookup_type='PAYMENT_CATEGORY_TYPE'   and lookup_code='CASH';
   select MEANING into L_MISC       from ar_lookups where lookup_type='PAYMENT_CATEGORY_TYPE'   and lookup_code='MISC';
   select MEANING into var.l_app    from ar_lookups where lookup_type='CHECK_STATUS'            and lookup_code='APP';
   select MEANING into var.l_nsf    from ar_lookups where lookup_type='CHECK_STATUS'            and lookup_code='NSF';
   select MEANING into var.l_rev    from ar_lookups where lookup_type='CHECK_STATUS'            and lookup_code='REV';
   select MEANING into var.l_stop   from ar_lookups where lookup_type='CHECK_STATUS'            and lookup_code='STOP';
   select MEANING into var.l_unapp  from ar_lookups where lookup_type='CHECK_STATUS'            and lookup_code='UNAPP';
   select MEANING into var.l_unid   from ar_lookups where lookup_type='CHECK_STATUS'            and lookup_code='UNID';
   select MEANING into L_PAYMENT    from ar_lookups where lookup_type='CB_REFERENCE_TYPE'       and lookup_code='PAYMENT';
   select MEANING into L_RECEIPT    from ar_lookups where lookup_type='CB_REFERENCE_TYPE'       and lookup_code='RECEIPT';
   select MEANING into L_REMITTANCE from ar_lookups where lookup_type='CB_REFERENCE_TYPE'       and lookup_code='REMITTANCE';
   select MEANING into L_APPROVED   from ar_lookups where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='APPROVED';
   select MEANING into L_CLEARED    from ar_lookups where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='CLEARED';
   select MEANING into L_CONFIRMED  from ar_lookups where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='CONFIRMED';
   select MEANING into L_REMITTED   from ar_lookups where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='REMITTED';
   select MEANING into L_REVERSED   from ar_lookups where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='REVERSED';

   dbms_sql.bind_variable(c, 'L_CASH'       , L_CASH);
   dbms_sql.bind_variable(c, 'L_MISC'       , L_MISC);
   dbms_sql.bind_variable(c, 'L_APP'        , var.l_app);
   dbms_sql.bind_variable(c, 'L_NSF'        , var.l_nsf);
   dbms_sql.bind_variable(c, 'L_REV'        , var.l_rev);
   dbms_sql.bind_variable(c, 'L_STOP'       , var.l_stop);
   dbms_sql.bind_variable(c, 'L_UNAPP'      , var.l_unapp);
   dbms_sql.bind_variable(c, 'L_UNID'       , var.l_unid);
   dbms_sql.bind_variable(c, 'L_PAYMENT'    , L_PAYMENT);
   dbms_sql.bind_variable(c, 'L_RECEIPT'    , L_RECEIPT);
   dbms_sql.bind_variable(c, 'L_REMITTANCE' , L_REMITTANCE);
   dbms_sql.bind_variable(c, 'L_APPROVED'   , L_APPROVED);
   dbms_sql.bind_variable(c, 'L_CLEARED'    , L_CLEARED);
   dbms_sql.bind_variable(c, 'L_CONFIRMED'  , L_CONFIRMED);
   dbms_sql.bind_variable(c, 'L_REMITTED'   , L_REMITTED);
   dbms_sql.bind_variable(c, 'L_REVERSED'   , L_REVERSED);

   if var.calling_program = 'ACTUAL' then

      fa_rx_util_pkg.debug('Define additional BIND variables for Actual Receipts Register');

      select MEANING into L_ACCO   from ar_lookups where lookup_type='PAYMENT_TYPE' and lookup_code='ACC';
      select MEANING into L_APPL   from ar_lookups where lookup_type='PAYMENT_TYPE' and lookup_code='APP';
      select MEANING into L_UNAPPL from ar_lookups where lookup_type='PAYMENT_TYPE' and lookup_code='UNAPP';
      select MEANING into L_UNIDE  from ar_lookups where lookup_type='PAYMENT_TYPE' and lookup_code='UNID';

      dbms_sql.bind_variable(c, 'L_ACCO'      , L_ACCO);
      dbms_sql.bind_variable(c, 'L_APPL'      , L_APPL);
      dbms_sql.bind_variable(c, 'L_UNAPPL'    , L_UNAPPL);
      dbms_sql.bind_variable(c, 'L_UNIDE'     , L_UNIDE);
      dbms_sql.bind_variable(c, 'l_trx_on_acc', l_acco);

   elsif var.calling_program = 'APPLIED' then

      fa_rx_util_pkg.debug('Define additional BIND variables for Applied  Receipts Register');

      SELECT substrb(meaning,1,20) INTO L_ONACCOUNT FROM ar_lookups WHERE lookup_type='PAYMENT_TYPE' AND lookup_code='ACC';

      dbms_sql.bind_variable(c, 'L_ONACCOUNT'  , L_ONACCOUNT);

      IF var.p_apply_date_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_apply_date_low', var.p_apply_date_low);
      END IF;
      IF var.p_apply_date_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_apply_date_high', var.p_apply_date_high);
      END IF;

      IF var.p_customer_number_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_customer_number_low', var.p_customer_number_low);
      END IF;
      IF var.p_customer_number_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_customer_number_high', var.p_customer_number_high);
      END IF;

      IF var.p_invoice_type_low IS NOT NULL THEN
        dbms_sql.bind_variable(c,'p_invoice_type_low', var.p_invoice_type_low);
      END IF;
      IF var.p_invoice_type_high IS NOT NULL THEN
        dbms_sql.bind_variable(c, 'p_invoice_type_high',var.p_invoice_type_high);
      END IF;

   end if;


end bind;

procedure after_fetch
is
begin
   fa_rx_util_pkg.debug('Get Flexfield value and Description');

   var.functional_currency_code := var.currency_code;
   var.organization_name        := var.org_name;

   IF NVL(var.ca_sob_type,'P') = 'P' THEN
      IF var.cr_status in ('REV', 'NSF', 'STOP') AND
         var.crh_status <> 'REVERSED' THEN
         select decode(
                    sum(decode(status,'UNID', amount_applied,0)),
                    0,
                    decode(sum(decode(status,'UNAPP', amount_applied,0))
                    , 0 , var.l_app , var.l_unapp),
                    var.l_unid)
         into var.receipt_status
         from ar_receivable_applications
         where cash_receipt_id = var.cash_receipt_id;
      END IF;
   ELSE
     IF var.cr_status in ('REV', 'NSF', 'STOP') AND
        var.crh_status <> 'REVERSED' THEN
        select decode(
                    sum(decode(status,'UNID', amount_applied,0)),
                    0,
                    decode(sum(decode(status,'UNAPP', amount_applied,0))
                    , 0 , var.l_app , var.l_unapp),
                    var.l_unid)
        into var.receipt_status
        from ar_receivable_apps_mrc_v
        where cash_receipt_id = var.cash_receipt_id;
     END IF;
   END IF;

   var.debit_account := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_ccid => var.account_code_combination_id);

   var.debit_account_desc := substrb(fa_rx_flex_pkg.get_description (
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_data => var.debit_account),1,240);

   var.debit_balancing := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_ccid => var.account_code_combination_id);

   var.debit_balancing_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_data => var.debit_balancing),1,240);

   var.debit_natacct := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_ccid => var.account_code_combination_id);

   var.debit_natacct_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_data => var.debit_natacct),1,240);

end after_fetch;

-------------------
-- Receipt Register
-------------------
procedure arrc_rep (
   p_reporting_level           IN   VARCHAR2,
   p_reporting_entity_id       IN   NUMBER,
   p_sob_id                    IN   NUMBER,
   p_coa_id                    IN   NUMBER,
   p_co_seg_low                IN   VARCHAR2,
   p_co_seg_high               IN   VARCHAR2,
   p_gl_date_low               in   date,
   p_gl_date_high              in   date,
   p_currency_code             in   varchar2,
   p_batch_name_low            in   varchar2,
   p_batch_name_high           in   varchar2,
   p_customer_name_low         in   varchar2,
   p_customer_name_high        in   varchar2,
   p_deposit_date_low          in   date,
   p_deposit_date_high         in   date,
   p_receipt_status_low        in   varchar2,
   p_receipt_status_high       in   varchar2,
   p_receipt_number_low        in   varchar2,
   p_receipt_number_high       in   varchar2,
   p_invoice_number_low        in   varchar2, --Bug 1579930
   p_invoice_number_high       in   varchar2, --Bug 1579930
   p_receipt_date_low          in   date,
   p_receipt_date_high         in   date,
   p_bank_account_name         in   varchar2,
   p_payment_method            in   varchar2,
   p_confirmed_flag            in   varchar2,
   p_doc_sequence_name	       in   varchar2,
   p_doc_sequence_number_from  in   number,
   p_doc_sequence_number_to    in   number,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is
   l_profile_rsob_id       NUMBER := NULL;
   l_client_info_rsob_id   NUMBER := NULL;
begin
   fa_rx_util_pkg.debug('arrx_rc.arrc_rep()+');

   -- initialize all var to null
   arrx_rc.init_var;

   -- Assign parameters to global variable
   -- These values will be used within the arrc_before_report trigger
   var.calling_program                  := 'RECEIPT';
   var.p_reporting_level                := p_reporting_level;
   var.p_reporting_entity_id            := p_reporting_entity_id;
   var.p_sob_id                         := p_sob_id;
   var.p_coa_id                         := p_coa_id;
   var.p_co_seg_low                     := p_co_seg_low;
   var.p_co_seg_high                    := p_co_seg_high;
   var.p_gl_date_low                    := Trunc(p_gl_date_low);
   var.p_gl_date_high                   := Trunc(p_gl_date_high)+1-1/24/60/60;
   var.p_currency_code                  := p_currency_code;
   var.p_batch_name_low                 := p_batch_name_low;
   var.p_batch_name_high                := p_batch_name_high;
   var.p_customer_name_low              := p_customer_name_low;
   var.p_customer_name_high             := p_customer_name_high;
   var.p_deposit_date_low               := Trunc(p_deposit_date_low);
   var.p_deposit_date_high              := Trunc(p_deposit_date_high)+1-1/24/60/60;
   var.p_receipt_status_low             := p_receipt_status_low;
   var.p_receipt_status_high            := p_receipt_status_high;
   var.p_receipt_number_low             := p_receipt_number_low;
   var.p_receipt_number_high            := p_receipt_number_high;
   var.p_invoice_number_low             := p_invoice_number_low; --Bug 1579930
   var.p_invoice_number_high            := p_invoice_number_high; --Bug 1579930
   var.p_receipt_date_low               := Trunc(p_receipt_date_low);
   var.p_receipt_date_high              := Trunc(p_receipt_date_high)+1-1/24/60/60;
   var.p_bank_account_name              := p_bank_account_name;
   var.p_payment_method                 := p_payment_method;
   var.p_confirmed_flag                 := p_confirmed_flag;
   var.p_doc_sequence_name              := p_doc_sequence_name;
   var.p_doc_sequence_number_from       := p_doc_sequence_number_from;
   var.p_doc_sequence_number_to         := p_doc_sequence_number_to;
   var.request_id                       := request_id;


/* Bug 5244313 Setting the SOB based on the Reporting context */

  if p_reporting_level = 1000 then
   var.books_id := p_reporting_entity_id;
    mo_global.init('AR');
    mo_global.set_policy_context('M',null);

  elsif p_reporting_level = 3000 then

   select set_of_books_id
    into   var.books_id
    from  ar_system_parameters_all
    where org_id = p_reporting_entity_id;

    mo_global.init('AR');
    mo_global.set_policy_context('S',p_reporting_entity_id);

  end if;

   fa_rx_util_pkg.debug('p_reporting_level          = '||var.p_reporting_level);
   fa_rx_util_pkg.debug('p_reporting_entity_id      = '||var.p_reporting_entity_id);
   fa_rx_util_pkg.debug('p_sob_id                   = '||var.p_sob_id);
   fa_rx_util_pkg.debug('p_coa_id                   = '||var.p_coa_id);
   fa_rx_util_pkg.debug('p_co_seg_low               = '||var.p_co_seg_low);
   fa_rx_util_pkg.debug('p_co_seg_high              = '||var.p_co_seg_high);
   fa_rx_util_pkg.debug('p_gl_date_from             = '||var.p_gl_date_low);
   fa_rx_util_pkg.debug('p_gl_date_to               = '||var.p_gl_date_high);
   fa_rx_util_pkg.debug('p_entered_currency         = '||var.p_currency_code);
   fa_rx_util_pkg.debug('p_batch_name_low           = '||var.p_batch_name_low);
   fa_rx_util_pkg.debug('p_batch_name_high          = '||var.p_batch_name_high);
   fa_rx_util_pkg.debug('p_customer_name_low        = '||var.p_customer_name_low);
   fa_rx_util_pkg.debug('p_customer_name_high       = '||var.p_customer_name_high);
   fa_rx_util_pkg.debug('p_deposit_date_low         = '||var.p_deposit_date_low);
   fa_rx_util_pkg.debug('p_deposit_date_high        = '||var.p_deposit_date_high);
   fa_rx_util_pkg.debug('p_receipt_status_low       = '||var.p_receipt_status_low);
   fa_rx_util_pkg.debug('p_receipt_status_high      = '||var.p_receipt_status_high);
   fa_rx_util_pkg.debug('p_receipt_number_low       = '||var.p_receipt_number_low);
   fa_rx_util_pkg.debug('p_receipt_number_high      = '||var.p_receipt_number_high);
   fa_rx_util_pkg.debug('p_invoice_number_low       = '||var.p_invoice_number_low);
   fa_rx_util_pkg.debug('p_invoice_number_high      = '||var.p_invoice_number_high);
   fa_rx_util_pkg.debug('p_receipt_date_low         = '||var.p_receipt_date_low);
   fa_rx_util_pkg.debug('p_receipt_date_high        = '||var.p_receipt_date_high);
   fa_rx_util_pkg.debug('p_bank_account_name        = '||var.p_bank_account_name);
   fa_rx_util_pkg.debug('p_payment_method           = '||var.p_payment_method);
   fa_rx_util_pkg.debug('p_confirmed_flag           = '||var.p_confirmed_flag);
   fa_rx_util_pkg.debug('p_doc_sequence_name        = '||var.p_doc_sequence_name);
   fa_rx_util_pkg.debug('p_doc_sequence_number_from = '||var.p_doc_sequence_number_from);
   fa_rx_util_pkg.debug('p_doc_sequence_number_to   = '||var.p_doc_sequence_number_to);
   fa_rx_util_pkg.debug('request_id                 = '||var.request_id);

    /* Set the appropriate sob type into the global variable var.ca_sob_type */
    select to_number(nvl(replace(substr(userenv('CLIENT_INFO'),45,10),' '),-99))
    into  l_client_info_rsob_id
    from  dual;

    fnd_profile.get('MRC_REPORTING_SOB_ID', l_profile_rsob_id);
    IF (l_client_info_rsob_id = NVL(l_profile_rsob_id,-1)) OR
        (l_client_info_rsob_id = -99)
    THEN
        fa_rx_util_pkg.debug('Setting the sob type to P');
        var.ca_sob_type := 'P';
    ELSE
        fa_rx_util_pkg.debug('Setting the sob type to R');
        var.ca_sob_id   := l_client_info_rsob_id;
        var.ca_sob_type := 'R';
    END IF;
   --
   -- Initialize request
   fa_rx_util_pkg.debug('Initializing the request');
   fa_rx_util_pkg.init_request('arrx_rc.arrc_rep',request_id,'AR_RECEIPTS_REP_ITF');

   fa_rx_util_pkg.assign_report('AR RECEIPTS',
                true,
                'arrx_rc.before_report;',
                'arrx_rc.bind(:CURSOR_SELECT);',
                'arrx_rc.after_fetch;',
                null);

   --
   -- Run the report.
   -- Make sure to pass the p_calling_proc assigned from within this procedure ('arrx_rc.arrc_rep')
   fa_rx_util_pkg.run_report('arrx_rc.arrc_rep', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_rc.arrc_rep()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_rc.arrc_rep(EXCEPTION)-');
end arrc_rep;

------------------
-- Actual Register
------------------
procedure arrc_rep_actual (
   p_reporting_level           IN   varchar2,
   p_reporting_entity_id       IN   NUMBER,
   p_sob_id                    IN   NUMBER,
   p_coa_id                    IN   NUMBER,
   p_batch_name_low            in   varchar2,
   p_batch_name_high           in   varchar2,
   p_customer_name_low         in   varchar2,
   p_customer_name_high        in   varchar2,
   p_deposit_date_low          in   date,
   p_deposit_date_high         in   date,
   p_receipt_status_low        in   varchar2,
   p_receipt_status_high       in   varchar2,
   p_receipt_number_low        in   varchar2,
   p_receipt_number_high       in   varchar2,
   p_receipt_date_low          in   date,
   p_receipt_date_high         in   date,
   p_gl_date_low               in   date,
   p_gl_date_high              in   date,
   p_currency_code             in   varchar2,
   p_bank_account_name         in   varchar2,
   p_payment_method            in   varchar2,
   p_confirmed_flag            in   varchar2,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is
   l_profile_rsob_id       NUMBER := NULL;
   l_client_info_rsob_id   NUMBER := NULL;
begin
   fa_rx_util_pkg.debug('arrx_rc.arrc_rep_actual()+');

   -- initialize all var to null
   arrx_rc.init_var;

  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger
   var.calling_program                  := 'ACTUAL';
   var.p_reporting_level                := p_reporting_level;
   var.p_reporting_entity_id            := p_reporting_entity_id;
   var.p_sob_id                         := p_sob_id;
   var.p_coa_id                         := p_coa_id;
   var.ca_sob_type                      := 'P';
   var.p_batch_name_low                 := p_batch_name_low;
   var.p_batch_name_high                := p_batch_name_high;
   var.p_customer_name_low              := p_customer_name_low;
   var.p_customer_name_high             := p_customer_name_high;
   var.p_deposit_date_low               := Trunc(p_deposit_date_low);
   var.p_deposit_date_high              := Trunc(p_deposit_date_high)+1-1/24/60/60;
   var.p_receipt_status_low             := p_receipt_status_low;
   var.p_receipt_status_high            := p_receipt_status_high;
   var.p_receipt_number_low             := p_receipt_number_low;
   var.p_receipt_number_high            := p_receipt_number_high;
   var.p_receipt_date_low               := Trunc(p_receipt_date_low);
   var.p_receipt_date_high              := Trunc(p_receipt_date_high)+1-1/24/60/60;
   var.p_gl_date_low                    := Trunc(p_gl_date_low);
   var.p_gl_date_high                   := Trunc(p_gl_date_high)+1-1/24/60/60;
   var.p_currency_code                  := p_currency_code;
   var.p_bank_account_name              := p_bank_account_name;
   var.p_payment_method                 := p_payment_method;
   var.p_confirmed_flag                 := p_confirmed_flag;
   var.request_id                       := request_id;

   if p_reporting_level = 1000 then
    var.books_id := p_reporting_entity_id;
     mo_global.init('AR');
     mo_global.set_policy_context('M',null);

   elsif p_reporting_level = 3000 then
    select set_of_books_id
     into   var.books_id
     from  ar_system_parameters_all
     where org_id = var.p_reporting_entity_id;

     mo_global.init('AR');
     mo_global.set_policy_context('S',var.p_reporting_entity_id);

   end if;
   /* Set the appropriate sob type into the global variable var.ca_sob_type */
   select to_number(nvl(replace(substr(userenv('CLIENT_INFO'),45,10),' '),-99))
   into  l_client_info_rsob_id from  dual;
   fnd_profile.get('MRC_REPORTING_SOB_ID', l_profile_rsob_id);
   IF (l_client_info_rsob_id = NVL(l_profile_rsob_id,-1)) OR
      (l_client_info_rsob_id = -99)
   THEN
       fa_rx_util_pkg.debug('Setting the sob type to P');
       fa_rx_util_pkg.debug(l_client_info_rsob_id);
       var.ca_sob_type := 'P';
   ELSE
       fa_rx_util_pkg.debug('Setting the sob type to R');
       var.ca_sob_id   := l_client_info_rsob_id;
       var.ca_sob_type := 'R';
   END IF;

  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_rc.arrc_rep_actual',request_id,'AR_RECEIPTS_REP_ITF');

  --
  -- Assign triggers specific to this report
  -- Make sure that you make your assignment to the correct section ('AR RECEIPTS')
   fa_rx_util_pkg.assign_report('AR RECEIPTS',
                true,
                'arrx_rc.before_report;',
                'arrx_rc.bind(:CURSOR_SELECT);',
                'arrx_rc.after_fetch;',
                null);

  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure ('arrx_rc.arrc_rep_actual')
   fa_rx_util_pkg.run_report('arrx_rc.arrc_rep_actual', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_rc.arrc_rep_actual()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_rc.arrc_rep_actual(EXCEPTION)-');
end arrc_rep_actual;

-------------------
-- Applied Register
-------------------
procedure arar_rep (
   p_reporting_level             IN     VARCHAR2,
   p_reporting_entity_id         IN     NUMBER,
   p_sob_id                      IN     NUMBER,
   p_coa_id                      in     number,
   p_co_seg_low                  in     varchar2,
   p_co_seg_high                 in     varchar2,
   p_gl_date_low                 in     date,
   p_gl_date_high                in     date,
   p_currency_code               in     varchar2,
   p_batch_name_low              in     varchar2,
   p_batch_name_high             in     varchar2,
   p_customer_name_low           in     varchar2,
   p_customer_name_high          in     varchar2,
   p_customer_number_low         in     varchar2,
   p_customer_number_high        in     varchar2,
   p_apply_date_low              in     date,
   p_apply_date_high             in     date,
   p_receipt_number_low          in     varchar2,
   p_receipt_number_high         in     varchar2,
   p_invoice_number_low          in     varchar2,
   p_invoice_number_high         in     varchar2,
   p_invoice_type_low            in     varchar2,
   p_invoice_type_high           in     varchar2,
   request_id                    in     number,
   retcode                       out NOCOPY     number,
   errbuf                        out NOCOPY     varchar2)
is
   l_profile_rsob_id NUMBER := NULL;
   l_client_info_rsob_id NUMBER := NULL;


begin

   fa_rx_util_pkg.debug('arrx_rc.arar_rep()+');

   -- initialize all var to null
   arrx_rc.init_var;

 --5255926
   if p_reporting_level = 1000 then
   var.books_id := p_reporting_entity_id;
    mo_global.init('AR');
    mo_global.set_policy_context('M',null);

  elsif p_reporting_level = 3000 then

   select set_of_books_id
    into   var.books_id
    from  ar_system_parameters_all
    where org_id = p_reporting_entity_id;

    mo_global.init('AR');
    mo_global.set_policy_context('S',p_reporting_entity_id);

  end if;


  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger

  var.calling_program           := 'APPLIED';
  var.p_reporting_level         := p_reporting_level;
  var.p_reporting_entity_id     := p_reporting_entity_id;
  var.p_sob_id                  := p_sob_id;
  var.p_coa_id                  := p_coa_id;
  var.p_co_seg_low              := p_co_seg_low;
  var.p_co_seg_high             := p_co_seg_high;
  var.p_gl_date_low             := Trunc(p_gl_date_low);
  var.p_gl_date_high            := Trunc(p_gl_date_high)+1-1/24/60/60;
  var.p_currency_code           := p_currency_code;
  var.p_batch_name_low          := p_batch_name_low;
  var.p_batch_name_high         := p_batch_name_high;
  var.p_customer_name_low       := p_customer_name_low;
  var.p_customer_name_high      := p_customer_name_high;
  var.p_customer_number_low     := p_customer_number_low;
  var.p_customer_number_high    := p_customer_number_high;
  var.p_apply_date_low          := p_apply_date_low;
  var.p_apply_date_high         := p_apply_date_high;
  var.p_receipt_number_low      := p_receipt_number_low;
  var.p_receipt_number_high     := p_receipt_number_high;
  var.p_invoice_number_low      := p_invoice_number_low; --Bug 1579930
  var.p_invoice_number_high     := p_invoice_number_high; --Bug 1579930
  var.p_invoice_type_low        := p_invoice_type_low;
  var.p_invoice_type_high       := p_invoice_type_high;
  var.request_id                := request_id;

  SELECT TO_NUMBER(NVL( REPLACE(SUBSTRB(USERENV('CLIENT_INFO'),45,10),' '),-99))
  INTO l_client_info_rsob_id
  FROM dual;

  fnd_profile.get('MRC_REPORTING_SOB_ID', l_profile_rsob_id);
  IF (l_client_info_rsob_id = NVL(l_profile_rsob_id,-1)) OR
     (l_client_info_rsob_id = -99)
  THEN
    var.ca_sob_type := 'P';
  ELSE
    var.ca_sob_id   := l_client_info_rsob_id;
    var.ca_sob_type := 'R';
  END IF;

  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_rc.arar_rep',request_id,'AR_RECEIPTS_REP_ITF');

  -- Assign triggers specific to this report
  -- Make sure that you make your assignment to the correct section ('AR RECEIPTS')

   fa_rx_util_pkg.assign_report('AR RECEIPTS',
                true,
                'arrx_rc.before_report;',
                'arrx_rc.bind(:CURSOR_SELECT);',
                'arrx_rc.after_fetch;',
                null);
  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure
   fa_rx_util_pkg.run_report('arrx_rc.arar_rep', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_rc.arar_rep()-');
exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
end arar_rep;

-----------------------------------
-- Miscellaneous Receipts Register
-----------------------------------
procedure armtr_rep (
   p_reporting_level           IN   VARCHAR2,
   p_reporting_entity_id       IN   NUMBER,
   p_sob_id                    IN   NUMBER,
   p_coa_id                    in   number,
   p_co_seg_low                in   varchar2,
   p_co_seg_high               in   varchar2,
   p_gl_date_low               in   date,
   p_gl_date_high              in   date,
   p_currency_code             in   varchar2,
   p_batch_name_low            in   varchar2,
   p_batch_name_high           in   varchar2,
   p_deposit_date_low          in   date,
   p_deposit_date_high         in   date,
   p_receipt_number_low        in   varchar2,
   p_receipt_number_high       in   varchar2,
   p_doc_sequence_name         in   varchar2,
   p_doc_sequence_number_from  in   number,
   p_doc_sequence_number_to    in   number,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is
begin

   fa_rx_util_pkg.debug('arrx_rc.arar_rep()+');

   -- initialize all var to null
   arrx_rc.init_var;
  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger

   var.calling_program                  := 'MISC';
   var.p_reporting_level                := p_reporting_level;
   var.p_reporting_entity_id            := p_reporting_entity_id;
   var.p_sob_id                         := p_sob_id;
   var.p_coa_id                         := p_coa_id;
   var.p_co_seg_low                     := p_co_seg_low;
   var.p_co_seg_high                    := p_co_seg_high;
   var.p_gl_date_low                    := Trunc(p_gl_date_low);
   var.p_gl_date_high                   := Trunc(p_gl_date_high)+1-1/24/60/60;
   var.p_currency_code                  := p_currency_code;
   var.p_batch_name_low                 := p_batch_name_low;
   var.p_batch_name_high                := p_batch_name_high;
   var.p_deposit_date_low               := Trunc(p_deposit_date_low);
   var.p_deposit_date_high              := Trunc(p_deposit_date_high)+1-1/24/60/60;
   var.p_receipt_number_low             := p_receipt_number_low;
   var.p_receipt_number_high            := p_receipt_number_high;
   var.p_doc_sequence_name              := p_doc_sequence_name;
   var.p_doc_sequence_number_from       := p_doc_sequence_number_from;
   var.p_doc_sequence_number_to         := p_doc_sequence_number_to;
   var.request_id                       := request_id;


/* Bug 5255942 Setting the SOB based on the Reporting context */

  if p_reporting_level = 1000 then
   var.books_id := p_reporting_entity_id;
    mo_global.init('AR');
    mo_global.set_policy_context('M',null);
 elsif p_reporting_level = 3000 then
   select set_of_books_id
    into   var.books_id
    from  ar_system_parameters_all
    where org_id = p_reporting_entity_id;
    mo_global.init('AR');
    mo_global.set_policy_context('S',p_reporting_entity_id);
  end if;


/*
  Compatibility with MRC changes.  Treat other reports as regular and
  not to use any MRC views.
*/
   var.ca_sob_type := 'P';

  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_rc.armtr_rep',request_id,'AR_RECEIPTS_REP_ITF');

   fa_rx_util_pkg.assign_report('AR RECEIPTS',
                true,
                'arrx_rc.before_report;',
                'arrx_rc.bind(:CURSOR_SELECT);',
                'arrx_rc.after_fetch;',
                null);
  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure
     fa_rx_util_pkg.run_report('arrx_rc.armtr_rep', retcode, errbuf);

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
end armtr_rep;

end ARRX_RC;


/
