--------------------------------------------------------
--  DDL for Package Body ARRX_RC_UNAPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_RC_UNAPP" AS
/* $Header: ARRXUNAB.pls 120.4.12010000.4 2009/06/18 19:24:38 nemani ship $ */


/*========================================================================+
 | PUBLIC PROCEDURE AR_UNAPP_REG                                          |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |    This procedure is the inner procedure for the RXi report. It uses   |
 |    the appropriate fa_rx_util_pkg routines to bild the report          |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |     request_id      IN       Request id for the concurrent program     |
 |   and the other input parameters of the report                         |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 04-OCT-2004           rkader            Created                        |
 | 23-Jun-2006           ggadhams          Made changes for Payment uptake|
 |					   increased col sizes for Bug5244326|
 *=======================================================================*/

PROCEDURE ar_unapp_reg(
          request_id             IN  NUMBER,
          p_reporting_level      IN  VARCHAR2,
          p_reporting_entity_id  IN  NUMBER,
          p_sob_id               IN  NUMBER,
          p_coa_id               IN  NUMBER,
          p_co_seg_low           IN  VARCHAR2,
          p_co_seg_high          IN  VARCHAR2,
          p_gl_date_from         IN  DATE,
          p_gl_date_to           IN  DATE,
          p_entered_currency     IN  VARCHAR2,
          p_batch_name_low       IN  VARCHAR2,
          p_batch_name_high      IN  VARCHAR2,
          p_batch_src_low        IN  VARCHAR2,
          p_batch_src_high       IN  VARCHAR2,
          p_customer_name_low    IN  VARCHAR2,
          p_customer_name_high   IN  VARCHAR2,
          p_customer_number_low  IN  VARCHAR2,
          p_customer_number_high IN  VARCHAR2,
          p_receipt_number_low   IN  VARCHAR2,
          p_receipt_number_high  IN  VARCHAR2,
          retcode                OUT NOCOPY NUMBER,
          errbuf                 OUT NOCOPY NUMBER) IS

   l_profile_rsob_id       NUMBER := NULL;
   l_client_info_rsob_id   NUMBER := NULL;
BEGIN

    fa_rx_util_pkg.debug('arrx_rc_unapp.ar_unapp_reg()+');

    /* Assign the parameters to the global variables
    These will be used in the before_report trigger */
    var.request_id                  :=    request_id ;
    var.p_reporting_level           :=    p_reporting_level;
    var.p_reporting_entity_id       :=    p_reporting_entity_id;
    var.p_sob_id                    :=    p_sob_id ;
    var.p_coa_id                    :=    p_coa_id ;
    var.p_co_seg_low                :=    p_co_seg_low ;
    var.p_co_seg_high               :=    p_co_seg_high ;
    var.p_gl_date_from              :=    p_gl_date_from ;
    var.p_gl_date_to                :=    p_gl_date_to ;
    var.p_entered_currency          :=    p_entered_currency;
    var.p_batch_name_low            :=    p_batch_name_low ;
    var.p_batch_name_high           :=    p_batch_name_high ;
    var.p_batch_src_low             :=    p_batch_src_low ;
    var.p_batch_src_high            :=    p_batch_src_high ;
    var.p_customer_name_low         :=    p_customer_name_low ;
    var.p_customer_name_high        :=    p_customer_name_high ;
    var.p_customer_number_low       :=    p_customer_number_low ;
    var.p_customer_number_high      :=    p_customer_number_high ;
    var.p_receipt_number_low        :=    p_receipt_number_low ;
    var.p_receipt_number_high       :=    p_receipt_number_high ;



    fa_rx_util_pkg.debug('p_reporting_level = '||var.p_reporting_level);
    fa_rx_util_pkg.debug('p_reporting_entity_id = '||var.p_reporting_entity_id);
    fa_rx_util_pkg.debug('request_id = '||var.request_id);
    fa_rx_util_pkg.debug('p_sob_id = '||var.p_sob_id);
    fa_rx_util_pkg.debug('p_coa_id = '||var.p_coa_id);
    fa_rx_util_pkg.debug('p_co_seg_low = '||var.p_co_seg_low);
    fa_rx_util_pkg.debug('p_co_seg_high = '||var.p_co_seg_high);
    fa_rx_util_pkg.debug('p_gl_date_from = '||var.p_gl_date_from);
    fa_rx_util_pkg.debug('p_gl_date_to = '||var.p_gl_date_to);
    fa_rx_util_pkg.debug('p_entered_currency = '||var.p_entered_currency);
    fa_rx_util_pkg.debug('p_batch_name_low = '||var.p_batch_name_low);
    fa_rx_util_pkg.debug('p_batch_name_high = '||var.p_batch_name_high);
    fa_rx_util_pkg.debug('p_batch_src_low = '||var.p_batch_src_low);
    fa_rx_util_pkg.debug('p_batch_src_high = '||var.p_batch_src_high);
    fa_rx_util_pkg.debug('p_customer_name_low = '||var.p_customer_name_low);
    fa_rx_util_pkg.debug('p_customer_name_high = '||var.p_customer_name_high);
    fa_rx_util_pkg.debug('p_customer_number_low = '||var.p_customer_number_low);
    fa_rx_util_pkg.debug('p_customer_number_high = '||var.p_customer_number_high);
    fa_rx_util_pkg.debug('p_receipt_number_low  = '||var.p_receipt_number_low);
    fa_rx_util_pkg.debug('p_receipt_number_high = '||var.p_receipt_number_high);

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

    /* Initialize the request */
    fa_rx_util_pkg.debug('Initializing the request');
    fa_rx_util_pkg.init_request('arrx_rc_unapp.ar_unapp_reg',request_id, 'AR_RECEIPTS_REP_ITF');

    /* Assign the report triggers to this report.
       NOTE:
           before_report is assigned 'arrx_rc_unapp.before_report;'
           bind is assigned 'arrx_rc_unapp.bind(:CURSOR_SELECT);'
           after_fetch is assigned 'arrx_rc_unapp.after_fetch;'
           Each trigger event is assigned with the full procedure name (including package name).
           They end with a ';'.
           The bind trigger requires one host variable ':CURSOR_SELECT'.
     */
     fa_rx_util_pkg.debug('Assigning the report triggers');
     fa_rx_util_pkg.assign_report('AR UNAPPLIED',
                                   true,
                                  'arrx_rc_unapp.before_report;',
                                  'arrx_rc_unapp.bind(:CURSOR_SELECT);',
                                  'arrx_rc_unapp.after_fetch;',
                                  null);

     /* Run the report */
     fa_rx_util_pkg.debug('Running the report');
     fa_rx_util_pkg.run_report('arrx_rc_unapp.ar_unapp_reg',retcode, errbuf);

     fa_rx_util_pkg.debug('arrx_rc_unapp.ar_unapp_reg()-');


EXCEPTION
    WHEN OTHERS THEN
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_rc_unapp.ar_unapp_reg(EXCEPTION)-');
END ar_unapp_reg;

PROCEDURE before_report IS
      CO_SEG_WHERE                  VARCHAR2(4000);
      GL_DATE_WHERE                 VARCHAR2(4000);
      GL_DATE_CLOSED_WHERE          VARCHAr2(4000);
      CURRENCY_CODE_WHERE           VARCHAR2(4000);
      BATCH_NAME_WHERE              VARCHAR2(4000);
      BATCH_SRC_NAME_WHERE          VARCHAR2(4000);
      CUSTOMER_NAME_WHERE           VARCHAR2(4000);
      CUSTOMER_NUMBER_WHERE         VARCHAR2(4000);
      RECEIPT_NUMBER_WHERE          VARCHAR2(4000);
      CR_STATUS_DECODE              VARCHAR2(4000);
      CRH_STATUS_DECODE             VARCHAR2(4000);
      ON_ACC_AMT_DECODE             VARCHAR2(4000);
      UNAPP_AMT_DECODE              VARCHAR2(4000);
      CLAIM_AMT_DECODE              VARCHAR2(4000);
      PREPAY_AMT_DECODE             VARCHAR2(4000);
      TOTAL_UNRESOLVED_AMT_DECODE   VARCHAR2(4000);
      FORMAT_CURRENCY_DECODE        VARCHAR2(4000);
      L_CR_ORG_WHERE                VARCHAR2(4000);
      L_CRH_ORG_WHERE               VARCHAR2(4000);
      L_ABA_ORG_WHERE               VARCHAR2(4000);
      L_CRH_CURR_ORG_WHERE          VARCHAR2(4000);
      L_BAT_ORG_WHERE               VARCHAR2(4000);
      L_BS_ORG_WHERE                VARCHAR2(4000);
      L_RA_ORG_WHERE                VARCHAR2(4000);
      L_PS_ORG_WHERE                VARCHAR2(4000);
BEGIN

     fa_rx_util_pkg.debug('arrx_rc_unapp.before_report()+');

     fa_rx_util_pkg.debug('Set of Books ID : '||var.p_sob_id);
     fa_rx_util_pkg.debug('Get Chart of Accounts ID ');

     select CHART_OF_ACCOUNTS_ID,CURRENCY_CODE,NAME
     into var.p_coa_id,var.functional_currency_code,var.organization_name
     from GL_SETS_OF_BOOKS
     where SET_OF_BOOKS_ID = var.p_sob_id;

     fa_rx_util_pkg.debug('Chart of Accounts ID : '||var.p_coa_id);
     fa_rx_util_pkg.debug('Functional Currency  : '||var.functional_currency_code);
     fa_rx_util_pkg.debug('Organization Name    : '||var.organization_name);

     XLA_MO_REPORTING_API.Initialize(var.p_reporting_level, var.p_reporting_entity_id, 'AUTO');


     L_CR_ORG_WHERE          := XLA_MO_REPORTING_API.Get_Predicate('CR',NULL);
     L_CRH_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('CRH',NULL);
--     L_ABA_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('ABA',NULL);
     L_CRH_CURR_ORG_WHERE    := XLA_MO_REPORTING_API.Get_Predicate('CRH_CURR',NULL);
     L_BAT_ORG_WHERE         := XLA_MO_REPORTING_API.Get_Predicate('BAT',NULL);
     L_BS_ORG_WHERE          := XLA_MO_REPORTING_API.Get_Predicate('BS',NULL);
     L_RA_ORG_WHERE          := XLA_MO_REPORTING_API.Get_Predicate('RA',NULL);
     L_PS_ORG_WHERE          := XLA_MO_REPORTING_API.Get_Predicate('PS',NULL);

     fa_rx_util_pkg.debug('L_CR_ORG_WHERE : '||L_CR_ORG_WHERE);
     fa_rx_util_pkg.debug('L_CRH_ORG_WHERE : '||L_CRH_ORG_WHERE);
     fa_rx_util_pkg.debug('L_ABA_ORG_WHERE : '||L_ABA_ORG_WHERE);
     fa_rx_util_pkg.debug('L_CRH_CURR_ORG_WHERE : '||L_CRH_CURR_ORG_WHERE);
     fa_rx_util_pkg.debug('L_BAT_ORG_WHERE : '||L_BAT_ORG_WHERE);
     fa_rx_util_pkg.debug('L_BS_ORG_WHERE : '||L_BS_ORG_WHERE);
     fa_rx_util_pkg.debug('L_RA_ORG_WHERE : '||L_RA_ORG_WHERE);
     fa_rx_util_pkg.debug('L_PS_ORG_WHERE : '||L_PS_ORG_WHERE);

     fa_rx_util_pkg.debug('Building Company Segment Where');

     IF var.p_co_seg_low IS NULL AND var.p_co_seg_high IS NULL THEN
         CO_SEG_WHERE := NULL;
     ELSIF var.p_co_seg_low IS NULL THEN
         CO_SEG_WHERE := ' AND ' ||
                FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.p_coa_id,
                                p_table_alias => 'GC',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => '<=',
                                p_operand1 => var.p_co_seg_high);
     ELSIF var.p_co_seg_high IS NULL THEN
         CO_SEG_WHERE := ' AND ' ||
                FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.p_coa_id,
                                p_table_alias => 'GC',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => '>=',
                                p_operand1 => var.p_co_seg_low);
     ELSE
         CO_SEG_WHERE := ' AND ' ||
                FA_RX_FLEX_PKG.FLEX_SQL(p_application_id => 101,
                                p_id_flex_code => 'GL#',
                                p_id_flex_num => var.p_coa_id,
                                p_table_alias => 'GC',
                                p_mode => 'WHERE',
                                p_qualifier => 'GL_BALANCING',
                                p_function => 'BETWEEN',
                                p_operand1 => var.p_co_seg_low,
                                p_operand2 => var.p_co_seg_high);
     END IF;
     fa_rx_util_pkg.debug('CO_SEG_WHERE = '||substr(CO_SEG_WHERE,1,100));

     fa_rx_util_pkg.debug('Building GL Date Where ');

     IF var.p_gl_date_from IS NULL and var.p_gl_date_to IS NULL THEN
         GL_DATE_WHERE := NULL;
     ELSIF var.p_gl_date_from IS NULL THEN
         GL_DATE_WHERE :=' AND RA.GL_DATE <= :p_gl_date_to';
     ELSIF var.p_gl_date_to  IS NULL THEN
         GL_DATE_WHERE :=' AND RA.GL_DATE >= :p_gl_date_from';
     ELSE
         GL_DATE_WHERE := ' AND RA.GL_DATE BETWEEN :p_gl_date_from AND :p_gl_date_to';
     END IF;

     fa_rx_util_pkg.debug('GL_DATE_WHERE = '||GL_DATE_WHERE);

     fa_rx_util_pkg.debug('Building GL Date Closed Where ');

     IF var.p_gl_date_from IS NULL and var.p_gl_date_to IS NULL THEN
         GL_DATE_CLOSED_WHERE := 'AND PS.GL_DATE_CLOSED = TO_DATE(''31-12-4712'',''DD-MM-YYYY'')';
     ELSIF var.p_gl_date_from IS NOT NULL THEN
         GL_DATE_CLOSED_WHERE := 'AND PS.GL_DATE_CLOSED >= :p_gl_date_from ';
     ELSIF var.p_gl_date_to IS NOT NULL THEN
         GL_DATE_CLOSED_WHERE := 'AND PS.GL_DATE_CLOSED >= :p_gl_date_to';
     END IF;

     fa_rx_util_pkg.debug('GL_DATE_CLOSED_WHERE = '||GL_DATE_CLOSED_WHERE);

     fa_rx_util_pkg.debug('Building Currency Code Where ');
     IF var.p_entered_currency IS NULL THEN
         CURRENCY_CODE_WHERE := NULL;
     ELSE
         CURRENCY_CODE_WHERE := ' AND CR.CURRENCY_CODE = :p_entered_currency';
     END IF;

     fa_rx_util_pkg.debug('Building Batch Name Where ');
     IF var.p_batch_name_low IS NULL and var.p_batch_name_high IS NULL THEN
         BATCH_NAME_WHERE := NULL;
     ELSIF var.p_batch_name_low IS NULL THEN
         BATCH_NAME_WHERE := ' AND BAT.NAME <= :p_batch_name_high';
     ELSIF var.p_batch_name_high IS NULL THEN
         BATCH_NAME_WHERE := ' AND BAT.NAME >= :p_batch_name_low';
     ELSE
         BATCH_NAME_WHERE := ' AND BAT.NAME BETWEEN :p_batch_name_low AND :p_batch_name_high';
     END IF;

     fa_rx_util_pkg.debug('Building Batch Source Name Where ');
     IF var.p_batch_src_low IS NULL and var.p_batch_src_high IS NULL THEN
         BATCH_SRC_NAME_WHERE := NULL;
     ELSIF var.p_batch_src_low IS NULL THEN
         BATCH_SRC_NAME_WHERE := ' AND BS.NAME <= :p_batch_src_high';
     ELSIF var.p_batch_src_high IS NULL THEN
         BATCH_SRC_NAME_WHERE := ' AND BS.NAME >= :p_batch_src_low';
     ELSE
         BATCH_SRC_NAME_WHERE := ' AND BS.NAME BETWEEN :p_batch_src_low AND :p_batch_src_high';
     END IF;

     fa_rx_util_pkg.debug('Building Customer Name Where');
     IF var.p_customer_name_low IS NULL AND var.p_customer_name_high IS NULL THEN
         CUSTOMER_NAME_WHERE := NULL;
     ELSIF var.p_customer_name_low IS NULL THEN
         CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME <= :p_customer_name_high';
     ELSIF var.p_customer_name_high IS NULL THEN
         CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME >= :p_customer_name_low';
     ELSE
         CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME BETWEEN :p_customer_name_low AND :p_customer_name_high';
     END IF;

     fa_rx_util_pkg.debug('Building Customer Number Where');
     IF var.p_customer_number_low IS NULL AND var.p_customer_number_high IS NULL THEN
         CUSTOMER_NUMBER_WHERE := NULL;
     ELSIF var.p_customer_number_low IS NULL THEN
         CUSTOMER_NUMBER_WHERE := ' AND CUST.ACCOUNT_NUMBER <= :p_customer_number_high';
     ELSIF var.p_customer_number_high IS NULL THEN
         CUSTOMER_NUMBER_WHERE := ' AND CUST.ACCOUNT_NUMBER >= :p_customer_number_low';
     ELSE
         CUSTOMER_NUMBER_WHERE := ' AND CUST.ACCOUNT_NUMBER BETWEEN :p_customer_number_low AND :p_customer_number_high';
     END IF;

     fa_rx_util_pkg.debug('Building Receipt Number Where');
     IF var.p_receipt_number_low IS NULL AND var.p_receipt_number_high IS NULL THEN
         RECEIPT_NUMBER_WHERE := NULL;
     ELSIF var.p_receipt_number_low IS NULL THEN
         RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER <= :p_receipt_number_high';
     ELSIF var.p_receipt_number_high IS NULL THEN
         RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER >= :p_receipt_number_low';
     ELSE
         RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER BETWEEN :p_receipt_number_low AND :p_receipt_number_high';
     END IF;

     fa_rx_util_pkg.debug('Building the DECODE statements');

     CR_STATUS_DECODE := 'DECODE(CR.STATUS,''APP'',:L_APP,''NSF'',:L_NSF,''REV'',:L_REV,''STOP'',:L_STOP,''UNAPP'',:L_UNAPP,''UNID'',:L_UNID)';
     CRH_STATUS_DECODE := 'DECODE(CRH.STATUS,''APPROVED'',:L_APPROVED,''CLEARED'',:L_CLEARED,''CONFIRMED'',:L_CONFIRMED,''REMITTED'',:L_REMITTED,''REVERSED'',:L_REVERSED)';
     ON_ACC_AMT_DECODE := 'SUM(DECODE(RA.STATUS,
            ''ACC'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),0))';

     UNAPP_AMT_DECODE  := 'SUM(DECODE(RA.STATUS,
            ''UNAPP'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),
            ''UNID'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),0))';

     CLAIM_AMT_DECODE := 'SUM(DECODE(RA.STATUS,
            ''OTHER ACC'', DECODE(RA.APPLIED_PAYMENT_SCHEDULE_ID,-4,
                   DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),0),0))';

     PREPAY_AMT_DECODE:= 'SUM(DECODE(RA.STATUS,
            ''OTHER ACC'', DECODE(RA.APPLIED_PAYMENT_SCHEDULE_ID,-7,
                   DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),0),0))';

     TOTAL_UNRESOLVED_AMT_DECODE := 'SUM(DECODE(RA.STATUS,
            ''ACC'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),
            ''UNAPP'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),
            ''OTHER ACC'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),
            ''UNID'',DECODE(:P_ENTERED_CURRENCY,NULL,RA.ACCTD_AMOUNT_APPLIED_FROM,RA.AMOUNT_APPLIED),0))';

     FORMAT_CURRENCY_DECODE := 'DECODE(:P_ENTERED_CURRENCY,NULL,:P_FUNCTIONAL_CURRENCY,CR.CURRENCY_CODE)';

     /* Assign the Select List */
     fa_rx_util_pkg.debug('Assign Select List');

     fa_rx_util_pkg.assign_column('10',null                        ,'ORGANIZATION_NAME'
            ,'arrx_rc_unapp.var.organization_name'                 ,'VARCHAR2', 50);
     fa_rx_util_pkg.assign_column('20',null                        ,'FUNCTIONAL_CURRENCY_CODE'
            ,'arrx_rc_unapp.var.functional_currency_code'          ,'VARCHAR2', 15);
     fa_rx_util_pkg.assign_column('30','BAT.BATCH_ID'              ,'BATCH_ID'
            ,'arrx_rc_unapp.var.batch_id'                          ,'NUMBER');
     fa_rx_util_pkg.assign_column('40','BAT.NAME'                  ,'BATCH_NAME'
           ,'arrx_rc_unapp.var.batch_name'                         ,'VARCHAR2', 20);
     fa_rx_util_pkg.assign_column('50 ','CR.CASH_RECEIPT_ID'       ,'CASH_RECEIPT_ID'
           ,'arrx_rc_unapp.var.cash_receipt_id'                    ,'NUMBER');
     fa_rx_util_pkg.assign_column('60','CR.RECEIPT_NUMBER'         ,'RECEIPT_NUMBER'
           ,'arrx_rc_unapp.var.receipt_number'                     ,'VARCHAR2', 30);
     fa_rx_util_pkg.assign_column('70','CR.CURRENCY_CODE'          ,'RECEIPT_CURRENCY_CODE'
           ,'arrx_rc_unapp.var.receipt_currency_code'              ,'VARCHAR2', 15);
     fa_rx_util_pkg.assign_column('80','CR.EXCHANGE_RATE'          ,'EXCHANGE_RATE'
           ,'arrx_rc_unapp.var.exchange_rate'                      ,'NUMBER');
     fa_rx_util_pkg.assign_column('90','CR.EXCHANGE_DATE'          ,'EXCHANGE_DATE'
           ,'arrx_rc_unapp.var.exchange_date'                      ,'DATE');
     fa_rx_util_pkg.assign_column('100','CR.EXCHANGE_RATE_TYPE'    ,'EXCHANGE_TYPE'
           ,'arrx_rc_unapp.var.exchange_type'                      ,'VARCHAR2',30);
     fa_rx_util_pkg.assign_column('110','DOCSEQ.NAME'              ,'DOC_SEQUENCE_NAME'
           ,'arrx_rc_unapp.var.doc_sequence_name'                  ,'VARCHAR2',30);
     fa_rx_util_pkg.assign_column('120','CR.DOC_SEQUENCE_VALUE'    ,'DOC_SEQUENCE_VALUE'
           ,'arrx_rc_unapp.var.doc_sequence_value'                 ,'NUMBER');
     fa_rx_util_pkg.assign_column('130','CR.DEPOSIT_DATE'          ,'DEPOSIT_DATE'
           ,'arrx_rc_unapp.var.deposit_date'                       ,'DATE');
     fa_rx_util_pkg.assign_column('140','CR.RECEIPT_DATE'          ,'RECEIPT_DATE'
           ,'arrx_rc_unapp.var.receipt_date'                       ,'DATE');
     fa_rx_util_pkg.assign_column('150',CR_STATUS_DECODE           ,'RECEIPT_STATUS'
           ,'arrx_rc_unapp.var.receipt_status'                     ,'VARCHAR2',40);
     fa_rx_util_pkg.assign_column('160','ABB.BANK_NAME'            ,'BANK_NAME'
           ,'arrx_rc_unapp.var.bank_name'                          ,'VARCHAR2',60);
     fa_rx_util_pkg.assign_column('170','ABB.BANK_NAME_ALT'        ,'BANK_NAME_ALT'
           ,'arrx_rc_unapp.var.bank_name_alt'                      ,'VARCHAR2',320);
     fa_rx_util_pkg.assign_column('180','ABB.BANK_BRANCH_NAME'     ,'BANK_BRANCH_NAME'
           ,'arrx_rc_unapp.var.bank_branch_name'                   ,'VARCHAR2',60);
     fa_rx_util_pkg.assign_column('190','ABB.BANK_BRANCH_NAME_ALT' ,'BANK_BRANCH_NAME_ALT'
           ,'arrx_rc_unapp.var.bank_name_alt'                      ,'VARCHAR2',320);
     fa_rx_util_pkg.assign_column('200','ABB.BANK_NUMBER'          ,'BANK_NUMBER'
           ,'arrx_rc_unapp.var.bank_number'                        ,'VARCHAR2',30);
     fa_rx_util_pkg.assign_column('210','ABB.BRANCH_NUMBER'        ,'BANK_BRANCH_NUMBER'
           ,'arrx_rc_unapp.var.bank_branch_number'                 ,'VARCHAR2',25);
     fa_rx_util_pkg.assign_column('220','ABA.BANK_ACCOUNT_NAME'    ,'BANK_ACCOUNT_NAME'
           ,'arrx_rc_unapp.var.bank_account_name'                  ,'VARCHAR2', 80);
     fa_rx_util_pkg.assign_column('230','ABA.BANK_ACCOUNT_NAME_ALT',    'BANK_ACCOUNT_NAME_ALT'
           ,'arrx_rc_unapp.var.bank_account_name_alt'              ,'VARCHAR2', 320);
     fa_rx_util_pkg.assign_column('240','ABA.CURRENCY_CODE'        ,'BANK_ACCOUNT_CURRENCY'
           ,'arrx_rc_unapp.var.bank_account_currency'              ,'VARCHAR2',15);
     fa_rx_util_pkg.assign_column('250','ARM.NAME'                 ,'RECEIPT_METHOD'
           ,'arrx_rc_unapp.var.receipt_method'                     ,'VARCHAR2',30);
     fa_rx_util_pkg.assign_column('260','CRH.CASH_RECEIPT_HISTORY_ID','CASH_RECEIPT_HISTORY_ID'
           ,'arrx_rc_unapp.var.cash_receipt_history_id'            ,'NUMBER');
     fa_rx_util_pkg.assign_column('270','MAX(RA.GL_DATE)'              ,'GL_DATE'
           ,'arrx_rc_unapp.var.gl_date'                            ,'DATE');
     fa_rx_util_pkg.assign_column('280','CRH_CURR.AMOUNT'          ,'RECEIPT_AMOUNT'
           ,'arrx_rc_unapp.var.receipt_amount'                     ,'NUMBER');
     fa_rx_util_pkg.assign_column('290','CRH_CURR.ACCTD_AMOUNT'    ,'ACCTD_RECEIPT_AMOUNT'
           ,'arrx_rc_unapp.var.acctd_receipt_amount'               ,'NUMBER');
     fa_rx_util_pkg.assign_column('300','CRH_CURR.FACTOR_DISCOUNT_AMOUNT','FACTOR_DISCOUNT_AMOUNT'
           ,'arrx_rc_unapp.var.factor_discount_amount'             ,'NUMBER');
     fa_rx_util_pkg.assign_column('310','CRH_CURR.ACCTD_FACTOR_DISCOUNT_AMOUNT','ACCTD_FACTOR_DISCOUNT_AMOUNT'
           ,'arrx_rc_unapp.var.acctd_factor_discount_amount'       ,'NUMBER');
     fa_rx_util_pkg.assign_column('320',CRH_STATUS_DECODE          ,'RECEIPT_HISTORY_STATUS'
           ,'arrx_rc_unapp.var.receipt_history_status'             ,'VARCHAR2', 40);
     fa_rx_util_pkg.assign_column('330','CUST.CUST_ACCOUNT_ID'     ,'CUSTOMER_ID'
           ,'arrx_rc_unapp.var.customer_id'                        ,'NUMBER');
     fa_rx_util_pkg.assign_column('340','NVL(SUBSTRB(PARTY.PARTY_NAME,1,50),:L_UNID_CUST)', 'CUSTOMER_NAME'
           ,'arrx_rc_unapp.var.customer_name'                      ,'VARCHAR2', 50);
     fa_rx_util_pkg.assign_column('350','DECODE(PARTY.PARTY_TYPE, ''ORGANIZATION'',PARTY.ORGANIZATION_NAME_PHONETIC, NULL)'                                                   ,'CUSTOMER_NAME_ALT'
           ,'arrx_rc_unapp.var.customer_name_alt'                  ,'VARCHAR2',320);
     fa_rx_util_pkg.assign_column('360','CUST.ACCOUNT_NUMBER'      ,'CUSTOMER_NUMBER'
           ,'arrx_rc_unapp.var.customer_number'                    ,'VARCHAR2', 30);
     fa_rx_util_pkg.assign_column('370','BS.NAME'                  ,'BATCH_SOURCE'
           ,'arrx_rc_unapp.var.batch_source'                       ,'VARCHAR2',30);
     fa_rx_util_pkg.assign_column('380',ON_ACC_AMT_DECODE          ,'ON_ACCOUNT_AMOUNT'
           ,'arrx_rc_unapp.var.on_acc_amount'                      ,'NUMBER');
     fa_rx_util_pkg.assign_column('390',UNAPP_AMT_DECODE           ,'UNAPP_AMOUNT'
           ,'arrx_rc_unapp.var.unapp_amount'                       ,'NUMBER');
     fa_rx_util_pkg.assign_column('400',CLAIM_AMT_DECODE           ,'CLAIM_AMOUNT'
           ,'arrx_rc_unapp.var.claim_amount'                       ,'NUMBER');
     fa_rx_util_pkg.assign_column('410',PREPAY_AMT_DECODE          ,'PREPAY_AMOUNT'
           ,'arrx_rc_unapp.var.prepay_amount'                      ,'NUMBER');
     fa_rx_util_pkg.assign_column('420',TOTAL_UNRESOLVED_AMT_DECODE,'TOTAL_UNRESOLVED_AMOUNT'
           ,'arrx_rc_unapp.var.total_unresolved_amount'            ,'NUMBER');
     fa_rx_util_pkg.assign_column('430',FORMAT_CURRENCY_DECODE     ,'FORMAT_CURRENCY_CODE'
           ,'arrx_rc_unapp.var.format_currency_code'               ,'VARCHAR2',15);
     fa_rx_util_pkg.assign_column('440','GC.CODE_COMBINATION_ID'   ,'ACCOUNT_CODE_COMBINATION_ID'
           ,'arrx_rc_unapp.var.account_code_combination_id'        ,'NUMBER');
     fa_rx_util_pkg.assign_column('450',NULL                       ,'DEBIT_BALANCING'
           ,'arrx_rc_unapp.var.debit_balancing'                          ,'VARCHAR2',240);


    /* Assign the From Clause */
    fa_rx_util_pkg.debug(' Assigning the FROM CLAUSE');

    IF NVL(var.ca_sob_type,'P') = 'P' THEN
       fa_rx_util_pkg.debug(' Report is run for Primary Set of Books');
       fa_rx_util_pkg.From_Clause := '
                          AR_CASH_RECEIPTS_ALL CR,
                          FND_DOCUMENT_SEQUENCES DOCSEQ,
--                          AP_BANK_ACCOUNTS_ALL ABA,
--                          AP_BANK_BRANCHES ABB,
 		          CE_BANK_ACCT_USES_ALL USES,
                          CE_BANK_ACCOUNTS ABA,
                          CE_BANK_BRANCHES_V ABB,
                          AR_RECEIPT_METHODS ARM,
                          AR_CASH_RECEIPT_HISTORY_ALL CRH,
                          GL_CODE_COMBINATIONS GC,
                          HZ_CUST_ACCOUNTS CUST,
                          HZ_PARTIES PARTY,
                          AR_BATCHES_ALL BAT,
                          AR_CASH_RECEIPT_HISTORY_ALL CRH_CURR,
                          AR_BATCH_SOURCES_ALL BS,
                          AR_RECEIVABLE_APPLICATIONS_ALL RA,
                          AR_PAYMENT_SCHEDULES_ALL PS';
    ELSE
       fa_rx_util_pkg.debug(' Report is run for Reporting Set of Books');
       fa_rx_util_pkg.From_Clause := '
                          AR_CASH_RECEIPTS_ALL_MRC_V CR,
                          FND_DOCUMENT_SEQUENCES DOCSEQ,
--                          AP_BANK_ACCOUNTS_ALL ABA,
	 		  CE_BANK_ACCT_USES_ALL USES,
			  CE_BANK_ACCOUNTS ABA,
                          CE_BANK_BRANCHES_V ABB,
                          AR_RECEIPT_METHODS ARM,
                          AR_CASH_RECEIPT_HIST_ALL_MRC_V CRH,
                          GL_CODE_COMBINATIONS GC,
                          HZ_CUST_ACCOUNTS CUST,
                          HZ_PARTIES PARTY,
                          AR_BATCHES_ALL_MRC_V BAT,
                          AR_CASH_RECEIPT_HIST_ALL_MRC_V CRH_CURR,
                          AR_BATCH_SOURCES_ALL BS,
                          AR_RECEIVABLE_APPS_ALL_MRC_V RA,
                          AR_PAYMENT_SCHEDULES_ALL_MRC_V PS';
   END IF;

   fa_rx_util_pkg.debug('Assigning the Where Clause ');
   fa_rx_util_pkg.Where_Clause := '
                      NVL(RA.CONFIRMED_FLAG,''Y'') = ''Y''
                AND  RA.STATUS IN (''UNAPP'',''ACC'',''UNID'',''OTHER ACC'')
                AND  PS.CASH_RECEIPT_ID  = RA.CASH_RECEIPT_ID
                AND  PS.CLASS = ''PMT''
               '|| GL_DATE_CLOSED_WHERE ||'
                AND  CR.CASH_RECEIPT_ID = RA.CASH_RECEIPT_ID
                AND  NVL(CR.CONFIRMED_FLAG,''Y'') = ''Y''
                AND  CR.DOC_SEQUENCE_ID = DOCSEQ.DOC_SEQUENCE_ID(+)
                AND  CR.REMIT_BANK_ACCT_USE_ID = USES.BANK_ACCT_USE_ID

--Bug6214927, USES.BANK_ACCOUNT_ID should be matched with ABA.BANK_ACCOUNT_ID.
	        AND  USES.BANK_ACCOUNT_ID  = ABA.BANK_account_ID
--                AND  CR.ORG_ID = ABA.ORG_ID
--                AND  ABA.BANK_BRANCH_ID = ABB.BANK_BRANCH_ID
		AND  ABA.BANK_BRANCH_ID = ABB.BRANCH_PARTY_ID
                AND  CR.RECEIPT_METHOD_ID = ARM.RECEIPT_METHOD_ID
                AND  CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND  CRH.FIRST_POSTED_RECORD_FLAG = ''Y''
                AND  CRH_CURR.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND  CRH_CURR.CURRENT_RECORD_FLAG = ''Y''
                AND  CRH.BATCH_ID =  BAT.BATCH_ID(+)
                AND  GC.CODE_COMBINATION_ID = RA.CODE_COMBINATION_ID
                AND  BAT.BATCH_SOURCE_ID  = BS.BATCH_SOURCE_ID(+)
                AND  BAT.ORG_ID = BS.ORG_ID(+)
                AND  CR.PAY_FROM_CUSTOMER = CUST.CUST_ACCOUNT_ID(+)
                AND  CUST.PARTY_ID = PARTY.PARTY_ID(+)
               '||L_CR_ORG_WHERE||'
               '||L_CRH_ORG_WHERE||'
               '||L_ABA_ORG_WHERE||'
               '||L_CRH_CURR_ORG_WHERE||'
               '||L_BAT_ORG_WHERE||'
               '||L_BS_ORG_WHERE||'
               '||L_RA_ORG_WHERE||'
               '||L_PS_ORG_WHERE||'
               '||CO_SEG_WHERE||' '||GL_DATE_WHERE||' '||CURRENCY_CODE_WHERE||' '||BATCH_NAME_WHERE||' '||BATCH_SRC_NAME_WHERE||' '||CUSTOMER_NAME_WHERE||' '||CUSTOMER_NUMBER_WHERE||' '||RECEIPT_NUMBER_WHERE;

   fa_rx_util_pkg.debug('Assigning the Group By Clause ');
   fa_rx_util_pkg.Group_By_Clause := '
                BAT.BATCH_ID,
                BAT.NAME,
                CR.CASH_RECEIPT_ID,
                CR.RECEIPT_NUMBER,
                CR.CURRENCY_CODE,
                CR.EXCHANGE_RATE,
                CR.EXCHANGE_DATE,
                CR.EXCHANGE_RATE_TYPE,
                DOCSEQ.NAME,
                CR.DOC_SEQUENCE_VALUE,
                CR.DEPOSIT_DATE,
                CR.RECEIPT_DATE, '||
                CR_STATUS_DECODE||','||'
                ABB.BANK_NAME,
                ABB.BANK_NAME_ALT,
                ABB.BANK_BRANCH_NAME,
                ABB.BANK_BRANCH_NAME_ALT,
                ABB.BANK_NUMBER,
                --ABB.BANK_NUM,
		ABB.BRANCH_NUMBER,
                ABA.BANK_ACCOUNT_NAME,
                ABA.BANK_ACCOUNT_NAME_ALT,
                ABA.CURRENCY_CODE,
                ARM.NAME,
                CRH.CASH_RECEIPT_HISTORY_ID,
                CRH_CURR.AMOUNT,
                CRH_CURR.ACCTD_AMOUNT,
                CRH_CURR.FACTOR_DISCOUNT_AMOUNT,
                CRH_CURR.ACCTD_FACTOR_DISCOUNT_AMOUNT,'||
                CRH_STATUS_DECODE ||','||'
                CUST.CUST_ACCOUNT_ID,
                NVL(SUBSTRB(PARTY.PARTY_NAME,1,50),:L_UNID_CUST),
                DECODE(PARTY.PARTY_TYPE, ''ORGANIZATION'',PARTY.ORGANIZATION_NAME_PHONETIC, NULL),
                CUST.ACCOUNT_NUMBER,
                BS.NAME,
                GC.CODE_COMBINATION_ID , '||
                FORMAT_CURRENCY_DECODE;

   fa_rx_util_pkg.debug('Assigning the Having Clause ');
   fa_rx_util_pkg.Having_Clause :=
                 ON_ACC_AMT_DECODE ||' <> 0
             OR ' || UNAPP_AMT_DECODE ||' <> 0
             OR ' || CLAIM_AMT_DECODE ||' <> 0
             OR ' || PREPAY_AMT_DECODE||' <> 0 ';



   fa_rx_util_pkg.debug('arrx_rc_unapp.before_report()-');


END before_report;

PROCEDURE bind(c IN INTEGER) IS
   l_approved                            VARCHAR2(80);
   l_cleared                             VARCHAR2(80);
   l_confirmed                           VARCHAR2(80);
   l_remitted                            VARCHAR2(80);
   l_reversed                            VARCHAR2(80);
   l_app                                 VARCHAR2(80);
   l_nsf                                 VARCHAR2(80);
   l_rev                                 VARCHAR2(80);
   l_stop                                VARCHAR2(80);
   l_unapp                               VARCHAR2(80);
   l_unid                                VARCHAR2(80);
   l_unid_cust                           VARCHAR2(80);
begin
      fa_rx_util_pkg.debug('arrx_rc_unapp.bind()+');

      IF var.p_gl_date_from IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_gl_date_from', var.p_gl_date_from);
      END IF;
      IF var.p_gl_date_to IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_gl_date_to', var.p_gl_date_to);
      END IF;

      IF var.p_reporting_entity_id IS NOT NULL AND  var.p_reporting_level = '3000' THEN
         dbms_sql.bind_variable(c, 'p_reporting_entity_id', var.p_reporting_entity_id);
      END IF;
      IF var.p_batch_name_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_batch_name_low',var.p_batch_name_low);
      END IF;
      IF var.p_batch_name_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_batch_name_high',var.p_batch_name_high);
      END IF;
      IF var.p_batch_src_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_batch_src_low',var.p_batch_src_low);
      END IF;
      IF var.p_batch_src_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_batch_src_high',var.p_batch_src_high);
      END IF;
      IF var.p_customer_name_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_customer_name_low',var.p_customer_name_low);
      END IF;
      IF var.p_customer_name_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_customer_name_high',var.p_customer_name_high);
      END IF;
      IF var.p_customer_number_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_customer_number_low',var.p_customer_number_low);
      END IF;
      IF var.p_customer_number_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_customer_number_high',var.p_customer_number_high);
      END IF;
      IF var.p_receipt_number_low IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_receipt_number_low',var.p_receipt_number_low);
      END IF;
      IF var.p_receipt_number_high IS NOT NULL THEN
         dbms_sql.bind_variable(c, 'p_receipt_number_high',var.p_receipt_number_high);
      END IF;

      dbms_sql.bind_variable(c, 'P_ENTERED_CURRENCY',var.p_entered_currency);
      dbms_sql.bind_variable(c, 'P_FUNCTIONAL_CURRENCY',var.functional_currency_code);

      select MEANING into l_app from ar_lookups
       where lookup_type='CHECK_STATUS' and lookup_code='APP';
      select MEANING into l_nsf from ar_lookups
       where lookup_type='CHECK_STATUS' and lookup_code='NSF';
      select MEANING into l_rev from ar_lookups
       where lookup_type='CHECK_STATUS' and lookup_code='REV';
      select MEANING into l_stop from ar_lookups
       where lookup_type='CHECK_STATUS' and lookup_code='STOP';
      select MEANING into l_unapp from ar_lookups
       where lookup_type='CHECK_STATUS' and lookup_code='UNAPP';
      select MEANING into l_unid from ar_lookups
       where lookup_type='CHECK_STATUS' and lookup_code='UNID';
      dbms_sql.bind_variable(c, 'L_APP'  , l_app);
      dbms_sql.bind_variable(c, 'L_NSF'  , l_nsf);
      dbms_sql.bind_variable(c, 'L_REV'  , l_rev);
      dbms_sql.bind_variable(c, 'L_STOP' , l_stop);
      dbms_sql.bind_variable(c, 'L_UNAPP', l_unapp);
      dbms_sql.bind_variable(c, 'L_UNID' , l_unid);

      select substr(MEANING,1,44) into l_unid_cust from ar_lookups
      where lookup_type = 'SPECIAL_TYPES' and lookup_code = 'UNIDENTIFIED';
      l_unid_cust := ' **** '||l_unid_cust;
      dbms_sql.bind_variable(c, 'L_UNID_CUST' , l_unid_cust);

      select MEANING into L_APPROVED from ar_lookups
       where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='APPROVED';
      select MEANING into L_CLEARED from ar_lookups
       where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='CLEARED';
      select MEANING into L_CONFIRMED from ar_lookups
       where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='CONFIRMED';
      select MEANING into L_REMITTED from ar_lookups
       where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='REMITTED';
      select MEANING into L_REVERSED from ar_lookups
       where lookup_type='RECEIPT_CREATION_STATUS' and lookup_code='REVERSED';
      dbms_sql.bind_variable(c, 'L_APPROVED'   , L_APPROVED);
      dbms_sql.bind_variable(c, 'L_CLEARED'    , L_CLEARED);
      dbms_sql.bind_variable(c, 'L_CONFIRMED'  , L_CONFIRMED);
      dbms_sql.bind_variable(c, 'L_REMITTED'   , L_REMITTED);
      dbms_sql.bind_variable(c, 'L_REVERSED'   , L_REVERSED);

      fa_rx_util_pkg.debug('arrx_rc_unapp.bind()-');

END bind;
PROCEDURE after_fetch IS
begin
      fa_rx_util_pkg.debug('arrx_rc_unapp.after_fetch()+');

      var.debit_balancing := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.p_coa_id,
                              p_qualifier => 'GL_BALANCING',
                              p_ccid => var.account_code_combination_id);

      fa_rx_util_pkg.debug('arrx_rc_unapp.after_fetch()-');
end after_fetch;

END ARRX_RC_UNAPP;

/
