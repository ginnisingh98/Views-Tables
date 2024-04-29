--------------------------------------------------------
--  DDL for Package Body ARRX_TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_TX" as
/* $Header: ARRXTXB.pls 120.15 2007/12/19 05:54:25 bsuri ship $ */

--
-- Main AR TRANSACTION RX Report function
--
-- bug3940958 added new parameters
procedure artx_rep (
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_transaction_date      in   date,
   end_transaction_date        in   date,
   start_transaction_type      in   varchar2,
   end_transaction_type        in   varchar2,
   start_transaction_class     in   varchar2,
   end_transaction_class       in   varchar2,
   start_balancing_segment     in   varchar2,
   end_balancing_segment       in   varchar2,
   start_bill_to_customer_name in   varchar2,
   end_bill_to_customer_name   in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   payment_method              in   varchar2,
   doc_sequence_name           in   varchar2,
   doc_sequence_number_from    in   number,
   doc_sequence_number_to      in   number,
   start_bill_to_customer_number in   varchar2,
   end_bill_to_customer_number   in   varchar2,
   reporting_level             IN   VARCHAR2,
   reporting_entity_id         IN   NUMBER,
   start_account               in   VARCHAR2,
   end_account                 in   VARCHAR2,
   batch_source_name           in   VARCHAR2,
   transaction_class           in   varchar2,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is
   l_profile_rsob_id NUMBER := NULL;
   l_client_info_rsob_id NUMBER := NULL;
   l_client_info_org_id NUMBER := NULL;
begin
   fa_rx_util_pkg.debug('arrx_tx.artx_rep()+');

  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger
   -- bug4214582 added nvl for completed_flag
   var.completed_flag := nvl(completed_flag,'Y');
   var.posted_flag := posted_flag;
   var.start_gl_date := start_gl_date;
   var.end_gl_date := end_gl_date;
   var.start_transaction_date := Trunc(start_transaction_date);
   var.end_transaction_date := Trunc(end_transaction_date)+1-1/24/60/60;
   var.start_transaction_type := start_transaction_type;
   var.end_transaction_type := end_transaction_type;
   var.start_transaction_class := start_transaction_class;
   var.end_transaction_class := end_transaction_class;
   var.start_balancing_segment := start_balancing_segment;
   var.end_balancing_segment := end_balancing_segment;
   var.start_bill_to_customer_name := start_bill_to_customer_name;
   var.end_bill_to_customer_name := end_bill_to_customer_name;
   var.start_currency := start_currency;
   var.end_currency := end_currency;
   var.payment_method := payment_method;
   var.doc_sequence_name        := doc_sequence_name;
   var.doc_sequence_number_from := doc_sequence_number_from;
   var.doc_sequence_number_to   := doc_sequence_number_to;
   var.start_bill_to_customer_number := start_bill_to_customer_number;
   var.end_bill_to_customer_number := end_bill_to_customer_number;
   var.request_id := request_id;

  SELECT TO_NUMBER(NVL( REPLACE(SUBSTRB(USERENV('CLIENT_INFO'),1,10),' '),-99))
  INTO l_client_info_org_id
  FROM dual;

   var.reporting_level := nvl(reporting_level,'3000');
   var.reporting_entity_id := nvl(reporting_entity_id,l_client_info_org_id);
   var.start_account := start_account;
   var.end_account := end_account;
   var.batch_source_name := batch_source_name;
   var.transaction_class := transaction_class;
/*
 * Bug 2498344 - MRC Reporting project
 *   Set the appropriate sob type into the global variable var.ca_sob_type.
 *
 *   value        Case
 *   =====        ========
 *    P           (When run for primary book) OR (When run for reporting
 *                 book and from APPS_MRC schema)
 *    R            When run for reporting book from APPS schema
 *
 */

     /*
      * Bug fix 2801076
      *  Using replace to change spaces to null when RSOB not set
      */
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


   fa_rx_util_pkg.debug('completed_flag = '|| var.completed_flag);
   fa_rx_util_pkg.debug('posted_flag = '|| var.posted_flag);
   fa_rx_util_pkg.debug('start_gl_date = '|| var.start_gl_date);
   fa_rx_util_pkg.debug('end_gl_date = '|| var.end_gl_date);
   fa_rx_util_pkg.debug('start_transaction_date = '|| var.start_transaction_date);
   fa_rx_util_pkg.debug('end_transaction_date = '|| var.end_transaction_date);
   fa_rx_util_pkg.debug('start_transaction_type = '|| var.start_transaction_type);
   fa_rx_util_pkg.debug('end_transaction_type = '|| var.end_transaction_type);
   fa_rx_util_pkg.debug('start_transaction_class = '|| var.start_transaction_class);
   fa_rx_util_pkg.debug('end_transaction_class = '|| var.end_transaction_class);
   fa_rx_util_pkg.debug('start_balancing_segment = '|| var.start_balancing_segment);
   fa_rx_util_pkg.debug('end_balancing_segment = '|| var.end_balancing_segment);
   fa_rx_util_pkg.debug('start_bill_to_customer_name = '|| var.start_bill_to_customer_name);
   fa_rx_util_pkg.debug('end_bill_to_customer_name = '|| var.end_bill_to_customer_name);
   fa_rx_util_pkg.debug('start_currency = '|| var.start_currency);
   fa_rx_util_pkg.debug('end_currency = '|| var.end_currency);
   fa_rx_util_pkg.debug('payment_method = '|| var.payment_method);
   fa_rx_util_pkg.debug('doc_sequence_name = '|| var.doc_sequence_name);
   fa_rx_util_pkg.debug('doc_sequence_number_from = '|| var.doc_sequence_number_from);
   fa_rx_util_pkg.debug('doc_sequence_number_to = '|| var.doc_sequence_number_to);
   fa_rx_util_pkg.debug('start_bill_to_customer_number = '|| var.start_bill_to_customer_number);
   fa_rx_util_pkg.debug('end_bill_to_customer_number = '|| var.end_bill_to_customer_number);
   fa_rx_util_pkg.debug('request_id = '|| var.request_id);

   -- bug3940958 added
   fa_rx_util_pkg.debug('start_account = '|| var.start_account);
   fa_rx_util_pkg.debug('end_account = '|| var.end_account);
   fa_rx_util_pkg.debug('batch_source_name = '|| var.batch_source_name);
   fa_rx_util_pkg.debug('transaction_class = '|| var.start_transaction_class);

-- Start Bug 5571594 - Added modification to code change of bug 5244313
-- changing in-parameter variable with local variable
  -- Bug 5244313 Setting the Org context based on the Reporting context
   if var.reporting_level= 1000 then

    var.books_id := var.reporting_entity_id;
    mo_global.init('AR');
    mo_global.set_policy_context('M',null);

  elsif var.reporting_level=3000 then

   select set_of_books_id
   into   var.books_id
   from ar_system_parameters_all
   where org_id = var.reporting_entity_id;

   mo_global.init('AR');
   mo_global.set_policy_context('S',var.reporting_entity_id);
  END IF;
  --End bug 5571594 SPDIXIT
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_tx.artx_rep',request_id,'AR_TRANSACTIONS_REP_ITF');

  --
  -- Assign report triggers for this report.
  -- This report has one section called AR TRANSACTION
  -- NOTE:
  --    before_report is assigned 'arrx_tx.before_report;'
  --    bind is assigned 'arrx_tx.bind(:CURSOR_SELECT);'
  --  Each trigger event is assigned with the full procedure name (including package name).
  --  They end with a ';'.
  --  The bind trigger requires one host variable ':CURSOR_SELECT'.
   fa_rx_util_pkg.assign_report('AR TRANSACTIONS',
                true,
                'arrx_tx.before_report;',
                'arrx_tx.bind(:CURSOR_SELECT);',
                'arrx_tx.after_fetch;',
                null);

  --
  -- Run the report. Make sure to pass as parameter the same
  -- value passed to p_calling_proc in init_request().
   fa_rx_util_pkg.run_report('arrx_tx.artx_rep', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_tx.artx_rep()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_tx.artx_rep(EXCEPTION)-');
end artx_rep;


--
-- This is the before report trigger for the main arrx_tx report.
procedure before_report
is
   REC_ACCOUNT_SEL			 varchar2(2000); /*4653230*/
   REC_BALANCE_SEL			 varchar2(2000); /*4653230*/
   REC_NATURAL_SEL			 varchar2(2000); /*4653230*/
   COMPLETE_FLAG_WHERE                   varchar2(500);
   POSTED_FLAG_WHERE                     varchar2(500);
   REC_GL_DATE_WHERE                     varchar2(500);
   TRX_DATE_WHERE                        varchar2(500);
   TRX_TYPE_WHERE                        varchar2(500);
   TRX_CLASS_WHERE                       varchar2(500);
   REC_BALANCING_WHERE                   varchar2(500);
   BILL_TO_CUSTOMER_NAME_WHERE           varchar2(500);
   CURRENCY_CODE_WHERE                   varchar2(500);
   PAYMENT_METHOD_WHERE                  varchar2(500);
   SELECT_BILL_NUMBER                    varchar2(500);
   DOC_SEQUENCE_NAME_WHERE               varchar2(500);
   DOC_SEQUENCE_NUMBER_WHERE             varchar2(500);
   BILL_TO_CUSTOMER_NUMBER_WHERE         varchar2(500);
   OPER                                  varchar2(10);
   OP1                                   varchar2(2000); /*4653230*/
   OP2                                   varchar2(2000); /*4653230*/

   -- bug3940958 added
   L_RECDIST_ORG_WHERE                   varchar2(500);
   L_CT_ORG_WHERE                        varchar2(500);
   L_TRX_TYPE_ORG_WHERE                  varchar2(500);
   L_BILL_TO_ORG_WHERE                  varchar2(500);
   L_BS_ORG_WHERE                       varchar2(500);
   BATCH_SOURCE_WHERE                    varchar2(500);
   REC_ACCOUNT_WHERE                   varchar2(4500); /*4653230*/
begin
   fa_rx_util_pkg.debug('arrx_tx.before_report()+');

  --
  -- Get Profile GL_SET_OF_BKS_ID
  --
   fa_rx_util_pkg.debug('GL_GET_PROFILE_BKS_ID');
/* bug2018415 replace fnd_profile call with arp_global.sysparam
   fnd_profile.get(
          name => 'GL_SET_OF_BKS_ID',
          val => var.books_id);
*/
/*
 * Bug 2498344 - MRC Reporting project
 *    Set var.books_id either from sysparam or the sob_id passed
 *    depending on sob_type
 */
/*Bug 5244313

   IF var.ca_sob_type = 'P'
   THEN
     var.books_id := arp_global.sysparam.set_of_books_id;

     -- Bug:3302771
     var.tax_header_level_flag :=arp_global.sysparam.tax_header_level_flag;

   ELSE
     var.books_id := var.ca_sob_id;

     -- bug:3256137
     -- Get TAX_HEADER_LEVEL_FLAG
     --
     select TAX_HEADER_LEVEL_FLAG
       into var.tax_header_level_flag
       from AR_SYSTEM_PARAMETERS_MRC_V;
   END IF;
*/


  --
  -- Get CHART_OF_ACCOUNTS_ID
  --
   fa_rx_util_pkg.debug('GL_GET_CHART_OF_ACCOUNTS_ID');

-- bug:3256137
   select CHART_OF_ACCOUNTS_ID
         ,NAME
         ,CURRENCY_CODE
   into var.chart_of_accounts_id
       ,var.organization_name
       ,var.functional_currency_code
   from GL_SETS_OF_BOOKS
   where SET_OF_BOOKS_ID = var.books_id;



  --
  -- Figure out NOCOPY the where clause for the parameters
  --
   fa_rx_util_pkg.debug('AR_GET_PARAMETERS');

  -- bug3940958 added for cross-org
  if var.reporting_entity_id <> -99 then
     XLA_MO_REPORTING_API.Initialize(var.reporting_level, var.reporting_entity_id, 'AUTO');

     L_RECDIST_ORG_WHERE  := XLA_MO_REPORTING_API.Get_Predicate('RECDIST',NULL);
     L_CT_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('CT',NULL);
     L_TRX_TYPE_ORG_WHERE := XLA_MO_REPORTING_API.Get_Predicate('TRX_TYPE',NULL);
     L_BILL_TO_ORG_WHERE := XLA_MO_REPORTING_API.Get_Predicate('BILL_TO',NULL);
     L_BS_ORG_WHERE := XLA_MO_REPORTING_API.Get_Predicate('BS',NULL);
  end if;



   IF var.completed_flag IS NULL THEN
      COMPLETE_FLAG_WHERE := NULL;
   ELSE
      COMPLETE_FLAG_WHERE := ' AND CT.COMPLETE_FLAG = '''|| var.completed_flag ||'''';
   END IF;


   IF var.posted_flag IS NULL THEN
      POSTED_FLAG_WHERE := NULL;
   ELSIF var.posted_flag = 'Y' THEN
      POSTED_FLAG_WHERE := ' AND RECDIST.POSTING_CONTROL_ID <> -3';
   ELSE
      POSTED_FLAG_WHERE := ' AND RECDIST.POSTING_CONTROL_ID = -3';
   END IF;



   /* Modifying for bug 1740514 */
   IF var.start_gl_date IS NULL AND var.end_gl_date IS NULL THEN
      REC_GL_DATE_WHERE := NULL;
   ELSIF var.start_gl_date IS NULL THEN
      REC_GL_DATE_WHERE := ' AND ((RECDIST.GL_DATE <= :end_gl_date) OR (CT.TRX_DATE <= :end_gl_date AND RECDIST.GL_DATE IS NULL)) ';
   ELSIF var.end_gl_date IS NULL THEN
      REC_GL_DATE_WHERE := ' AND ((RECDIST.GL_DATE >= :start_gl_date) OR (CT.TRX_DATE >= :start_gl_date AND RECDIST.GL_DATE IS NULL))';
   ELSE
      REC_GL_DATE_WHERE := ' AND ((RECDIST.GL_DATE BETWEEN :start_gl_date AND :end_gl_date) OR (CT.TRX_DATE BETWEEN :start_gl_date AND :end_gl_date AND RECDIST.GL_DATE IS NULL))';
   END IF;



   IF var.start_transaction_date IS NULL AND var.end_transaction_date IS NULL THEN
      TRX_DATE_WHERE := NULL;
   ELSIF var.start_transaction_date IS NULL THEN
      TRX_DATE_WHERE := ' AND CT.TRX_DATE <= :end_transaction_date';
   ELSIF var.end_transaction_date IS NULL THEN
      TRX_DATE_WHERE := ' AND CT.TRX_DATE >= :start_transaction_date';
   ELSE
      TRX_DATE_WHERE := ' AND CT.TRX_DATE BETWEEN :start_transaction_date AND :end_transaction_date';
   END IF;




   IF var.start_transaction_type IS NULL AND var.end_transaction_type IS NULL THEN
      TRX_TYPE_WHERE := NULL;
   ELSIF var.start_transaction_type IS NULL THEN
      TRX_TYPE_WHERE := ' AND TRX_TYPE.NAME <= :end_transaction_type ';
   ELSIF var.end_transaction_type IS NULL THEN
      TRX_TYPE_WHERE := ' AND TRX_TYPE.NAME >= :start_transaction_type ';
   ELSE
      TRX_TYPE_WHERE := ' AND TRX_TYPE.NAME BETWEEN :start_transaction_type AND :end_transaction_type ';
   END IF;

   IF var.start_transaction_class IS NULL AND var.end_transaction_class IS NULL THEN
      TRX_CLASS_WHERE := NULL;
   ELSIF var.start_transaction_class IS NULL THEN
      TRX_CLASS_WHERE := ' AND TRX_TYPE.TYPE <= :end_transaction_class ';
   ELSIF var.end_transaction_class IS NULL THEN
      TRX_CLASS_WHERE := ' AND TRX_TYPE.TYPE >= :start_transaction_class ';
   ELSE
      TRX_CLASS_WHERE := ' AND TRX_TYPE.TYPE BETWEEN :start_transaction_class AND :end_transaction_class ';
   END IF;

   IF var.start_balancing_segment IS NULL AND var.end_balancing_segment IS NULL THEN
      OPER := NULL;
   ELSIF var.start_balancing_segment IS NULL THEN
      OPER := '<=';
      OP1 := var.end_balancing_segment;
      OP2 := NULL;
   ELSIF var.end_balancing_segment IS NULL THEN
      OPER := '>=';
      OP1 := var.start_balancing_segment;
      OP2 := NULL;
   ELSE
      OPER := 'BETWEEN';
      OP1 := var.start_balancing_segment;
      OP2 := var.end_balancing_segment;
   END IF;


   IF OPER IS NULL THEN
      REC_BALANCING_WHERE := NULL;
   ELSE
      REC_BALANCING_WHERE := ' AND '||
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCRECDIST',
                             p_mode => 'WHERE',
                             p_qualifier => 'GL_BALANCING',
                             p_function => OPER,
                             p_operand1 => OP1,
                             p_operand2 => OP2);
   END IF;

   -- bug3940958 added for new parameters
   IF var.start_account IS NULL AND var.end_account IS NULL THEN
      OPER := NULL;
   ELSIF var.start_account IS NULL THEN
      OPER := '<=';
      OP1 := var.end_account;
      OP2 := NULL;
   ELSIF var.end_account IS NULL THEN
      OPER := '>=';
      OP1 := var.start_account;
      OP2 := NULL;
   ELSE
      OPER := 'BETWEEN';
      OP1 := var.start_account;
      OP2 := var.end_account;
   END IF;
   IF OPER IS NULL THEN
      REC_ACCOUNT_WHERE := NULL;
   ELSE
      REC_ACCOUNT_WHERE := ' AND '||
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCRECDIST',
                             p_mode => 'WHERE',
                             p_qualifier => 'ALL',
                             p_function => OPER,
                             p_operand1 => OP1,
                             p_operand2 => OP2);
   END IF;


 --begin for bug 1814839: used bind variable instead of converting to string
   IF var.start_bill_to_customer_name IS NULL AND var.end_bill_to_customer_name IS NULL THEN
      BILL_TO_CUSTOMER_NAME_WHERE := NULL;
   ELSIF var.start_bill_to_customer_name IS NULL THEN
      BILL_TO_CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME <= :end_bill_to_customer_name ';
   ELSIF var.end_bill_to_customer_name IS NULL THEN
      BILL_TO_CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME >= :start_bill_to_customer_name ';
   ELSE
      BILL_TO_CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME BETWEEN :start_bill_to_customer_name and :end_bill_to_customer_name ';
   END IF;
 --end for bug 1814839

   IF var.start_bill_to_customer_number IS NULL AND var.end_bill_to_customer_number IS NULL THEN
      BILL_TO_CUSTOMER_NUMBER_WHERE := NULL;
   ELSIF var.start_bill_to_customer_number IS NULL THEN
      BILL_TO_CUSTOMER_NUMBER_WHERE := ' AND BILL_TO.ACCOUNT_NUMBER <= :end_bill_to_customer_number ';
   ELSIF var.end_bill_to_customer_number IS NULL THEN
      BILL_TO_CUSTOMER_NUMBER_WHERE := ' AND BILL_TO.ACCOUNT_NUMBER >= :start_bill_to_customer_number ';
   ELSE
      BILL_TO_CUSTOMER_NUMBER_WHERE := ' AND BILL_TO.ACCOUNT_NUMBER BETWEEN :start_bill_to_customer_number AND :end_bill_to_customer_number ';
   END IF;

   IF var.start_currency IS NULL AND var.end_currency IS NULL THEN
      CURRENCY_CODE_WHERE := NULL;
   ELSIF var.start_currency IS NULL THEN
      CURRENCY_CODE_WHERE := ' AND CT.INVOICE_CURRENCY_CODE <= :end_currency ';
   ELSIF var.end_currency IS NULL THEN
      CURRENCY_CODE_WHERE := ' AND CT.INVOICE_CURRENCY_CODE >= :start_currency ';
   ELSE
      CURRENCY_CODE_WHERE := ' AND CT.INVOICE_CURRENCY_CODE BETWEEN :start_currency AND :end_currency ';
   END IF;

   IF var.payment_method IS NULL THEN
      PAYMENT_METHOD_WHERE := NULL;
   ELSE
      PAYMENT_METHOD_WHERE := ' AND METHODS.NAME = :payment_method ';
   END IF;

  --
  -- DOCUMENT WHERE Clauses
  --
  /* For bug 2252811 changed  the where clause to retrieve based on doc_sequence_id
     since var.doc_sequence_name has doc_sequence_id */

     IF var.doc_sequence_name is not null THEN
     	DOC_SEQUENCE_NAME_WHERE := ' AND DOC_SEQ.doc_sequence_id= :doc_sequence_name ';
     ELSE
     	DOC_SEQUENCE_NAME_WHERE := null;
     END IF;

     IF var.doc_sequence_number_from IS NOT NULL THEN
          IF var.doc_sequence_number_to IS NOT NULL THEN
               	DOC_SEQUENCE_NUMBER_WHERE := ' AND CT.DOC_SEQUENCE_VALUE between :doc_sequence_number_from AND :doc_sequence_number_to ';
          ELSE
          	DOC_SEQUENCE_NUMBER_WHERE := ' AND CT.DOC_SEQUENCE_VALUE >=  :doc_sequence_number_from ';
      	  END IF;
   ELSE
          IF var.doc_sequence_number_to IS NOT NULL THEN
        	DOC_SEQUENCE_NUMBER_WHERE := ' AND CT.DOC_SEQUENCE_VALUE <=  :doc_sequence_number_to ';
          ELSE
        	DOC_SEQUENCE_NUMBER_WHERE := NULL;
          END IF;
   END IF;

   -- bug3940958 modified
   IF var.transaction_class IS NULL THEN
      TRX_CLASS_WHERE := NULL;
   ELSE
      TRX_CLASS_WHERE := ' AND TRX_TYPE.TYPE = :transaction_class ';
   END IF;

   -- bug3940958 added for new parameter
   IF var.batch_source_name IS NULL THEN
      BATCH_SOURCE_WHERE := NULL;
   ELSE
      BATCH_SOURCE_WHERE := ' AND (CT.ORG_ID, CT.BATCH_SOURCE_ID) ' ||
		'in (select ' ||
		'org_id, batch_source_id ' ||
		'from ra_batch_sources_all BS ' ||
		'where name = :batch_source_name  ' ||
		L_BS_ORG_WHERE || ' ) ';
   END IF;


  --
  -- Get BILLING NUMBER Function
  --
   fa_rx_util_pkg.debug('AR_GET_BILLING_NUMBER');
/*   fnd_profile.get(
          name => 'AR_SHOW_BILLING_NUMBER',
          val => var.bill_flag);
*/

/*Commented for Bug 5244313
   var.bill_flag := NVL(ar_setup.value('AR_SHOW_BILLING_NUMBER',null),'N');
   var.bill_flag := 'N';

   -- Null will be replaced with org_id, for x-org scenario

   IF var.bill_flag = 'N' THEN
      SELECT_BILL_NUMBER := null;
   ELSE
*/
      SELECT_BILL_NUMBER := 'DECODE(SYSPARAM.SHOW_BILLING_NUMBER_FLAG,''Y'',ARRX_TX.GET_CONS_BILL_NUMBER(CT.CUSTOMER_TRX_ID),NULL) ';

 --  END IF;



  --
  -- Flex SQL
  --
  REC_ACCOUNT_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCRECDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'ALL');
  REC_BALANCE_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCRECDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'GL_BALANCING');
  REC_NATURAL_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCRECDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'GL_ACCOUNT');

  --6506811
  var.tax_header_level_flag := NVL(var.tax_header_level_flag,'N');
  --
  -- Assign SELECT list
  --
   fa_rx_util_pkg.debug('ARTX_ASSIGN_SELECT_LIST');

  -- fa_rx_util_pkg.assign_column(#, select, insert, place, type, len);
-->>SELECT_START<<--
   fa_rx_util_pkg.assign_column('10 ','CCRECDIST.CODE_COMBINATION_ID',               null,                          'arrx_tx.var.ccid',                        'NUMBER');
   fa_rx_util_pkg.assign_column('20 ',null,                                          'ORGANIZATION_NAME',           'arrx_tx.var.organization_name',           'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('30 ',null,                                          'FUNCTIONAL_CURRENCY_CODE',    'arrx_tx.var.functional_currency_code',    'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('40 ','CT.CUSTOMER_TRX_ID',                          'CUSTOMER_TRX_ID',             'arrx_tx.var.customer_trx_id',             'NUMBER');
   fa_rx_util_pkg.assign_column('50 ','CT.TRX_NUMBER',                               'TRX_NUMBER',                  'arrx_tx.var.trx_number',                  'VARCHAR2', 20);
   fa_rx_util_pkg.assign_column('60 ',SELECT_BILL_NUMBER,                            'CONS_BILL_NUMBER',            'arrx_tx.var.cons_bill_number',            'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('70 ','RECDIST.CUST_TRX_LINE_GL_DIST_ID',            'REC_CUST_TRX_LINE_GL_DIST_ID','arrx_tx.var.rec_cust_trx_line_gl_dist_id','NUMBER');
   fa_rx_util_pkg.assign_column('80 ',REC_ACCOUNT_SEL,                               'REC_ACCOUNT',                 'arrx_tx.var.rec_account',                 'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('90 ',null,                                          'REC_ACCOUNT_DESC',            'arrx_tx.var.rec_account_desc',            'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('100',REC_BALANCE_SEL,                               'REC_BALANCE',                 'arrx_tx.var.rec_balance',                 'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('110',null,                                          'REC_BALANCE_DESC',            'arrx_tx.var.rec_balance_desc',            'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('120',REC_NATURAL_SEL,                               'REC_NATACCT',                 'arrx_tx.var.rec_natacct',                 'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('130',null,                                          'REC_NATACCT_DESC',            'arrx_tx.var.rec_natacct_desc',            'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('140','DECODE(RECDIST.GL_DATE,NULL,:NO,:YES)',       'REC_POSTABLE_FLAG',           'arrx_tx.var.rec_postable_flag',           'VARCHAR2', 10);
   fa_rx_util_pkg.assign_column('150','ARRX_TX.LAST_UPDATED_BY(CT.CUSTOMER_TRX_ID)', 'TRX_LAST_UPDATED_BY',         'arrx_tx.var.trx_last_updated_by',         'NUMBER');
   fa_rx_util_pkg.assign_column('160','ARRX_TX.LAST_UPDATE_DATE(CT.CUSTOMER_TRX_ID)','TRX_LAST_UPDATE_DATE',        'arrx_tx.var.trx_last_update_date',        'DATE');
   fa_rx_util_pkg.assign_column('170','CT.TRX_DATE',                                     'TRX_DATE',                    'arrx_tx.var.trx_date',                    'DATE');
   fa_rx_util_pkg.assign_column('180','CT.INVOICE_CURRENCY_CODE',                    'TRX_CURRENCY',                'arrx_tx.var.trx_currency',                'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('190','CT.EXCHANGE_RATE',                            'EXCHANGE_RATE',               'arrx_tx.var.exchange_rate',               'NUMBER');
   fa_rx_util_pkg.assign_column('200','CT.EXCHANGE_DATE',                            'EXCHANGE_DATE',               'arrx_tx.var.exchange_date',               'DATE');
   fa_rx_util_pkg.assign_column('210','CT.EXCHANGE_RATE_TYPE',                       'EXCHANGE_TYPE',               'arrx_tx.var.exchange_type',               'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('220','RECDIST.GL_DATE',                             'RECEIVABLES_GL_DATE',         'arrx_tx.var.receivables_gl_date',         'DATE');
    -- bug4274502 added nvl because AutoInvoice does not set term_due_date
    fa_rx_util_pkg.assign_column('230','NVL(CT.TERM_DUE_DATE,ARPT_SQL_FUNC_UTIL.GET_FIRST_REAL_DUE_DATE(CT.CUSTOMER_TRX_ID, CT.TERM_ID, CT.TRX_DATE)) ', 'TRX_DUE_DATE',                'arrx_tx.var.trx_due_date', 'DATE');
   fa_rx_util_pkg.assign_column('240', null,                                          'TAX_HEADER_LEVEL_FLAG',       'arrx_tx.var.tax_header_level_flag',       'VARCHAR2', 1);
   fa_rx_util_pkg.assign_column('250','CT.DOC_SEQUENCE_VALUE',                       'DOC_SEQUENCE_VALUE',          'arrx_tx.var.doc_sequence_value',          'NUMBER');
   fa_rx_util_pkg.assign_column('260','RECDIST.AMOUNT',                              'TRX_AMOUNT',                  'arrx_tx.var.trx_amount',                  'NUMBER');
   fa_rx_util_pkg.assign_column('270','RECDIST.ACCTD_AMOUNT',                        'TRX_ACCTD_AMOUNT',            'arrx_tx.var.trx_acctd_amount',            'NUMBER');
   fa_rx_util_pkg.assign_column('280','CT.SHIP_TO_CUSTOMER_ID',                      'SHIP_TO_CUSTOMER_ID',         'arrx_tx.var.ship_to_customer_id',         'NUMBER', 15);
   fa_rx_util_pkg.assign_column('290','CT.SHIP_TO_SITE_USE_ID',                      'SHIP_TO_SITE_USE_ID',         'arrx_tx.var.ship_to_site_use_id',         'NUMBER', 15);
   fa_rx_util_pkg.assign_column('300','CT.BILL_TO_CUSTOMER_ID',                      'BILL_TO_CUSTOMER_ID',         'arrx_tx.var.bill_to_customer_id',         'NUMBER', 15);
   fa_rx_util_pkg.assign_column('310','CT.BILL_TO_SITE_USE_ID',                      'BILL_TO_SITE_USE_ID',         'arrx_tx.var.bill_to_site_use_id',         'NUMBER', 15);
   fa_rx_util_pkg.assign_column('320','CT.CUST_TRX_TYPE_ID',                         'CUST_TRX_TYPE_ID',            'arrx_tx.var.cust_trx_type_id',            'NUMBER', 15);
   fa_rx_util_pkg.assign_column('330','CT.TERM_ID',                                  'TERM_ID',                     'arrx_tx.var.term_id',                     'NUMBER', 15);
   fa_rx_util_pkg.assign_column('340','CT.DOC_SEQUENCE_ID',                          'DOC_SEQUENCE_ID',             'arrx_tx.var.doc_sequence_id',             'NUMBER', 15);
   fa_rx_util_pkg.assign_column('350','CT.RECEIPT_METHOD_ID',                        'RECEIPT_METHOD_ID',           'arrx_tx.var.receipt_method_id',           'NUMBER', 15);
   fa_rx_util_pkg.assign_column('360','CT.ORG_ID',                                   'ORG_ID',                      'arrx_tx.var.org_id',                      'NUMBER', 15);
-- bug3940958 added batch_id and batch_source_id
   fa_rx_util_pkg.assign_column('370','CT.BATCH_ID', 			             'BATCH_ID',                    'arrx_tx.var.batch_id',                    'NUMBER', 15);
   fa_rx_util_pkg.assign_column('380','CT.BATCH_SOURCE_ID', 			     'BATCH_SOURCE_ID',             'arrx_tx.var.batch_source_id',             'NUMBER', 15);
-->>SELECT_END<<--


  --
  -- Assign From Clause
  --
   fa_rx_util_pkg.debug('AR_ASSIGN_FORM_CLAUSE');

   -- bug3940958 changed to _ALL for cross-org
   IF var.ca_sob_type = 'P'
   THEN
     fa_rx_util_pkg.From_Clause := 'RA_CUST_TRX_LINE_GL_DIST_ALL RECDIST,
                RA_CUSTOMER_TRX_ALL CT,
                RA_CUST_TRX_TYPES_ALL TRX_TYPE,
                HZ_CUST_ACCOUNTS_ALL BILL_TO,
                HZ_PARTIES  PARTY,
                GL_CODE_COMBINATIONS CCRECDIST,
                AR_RECEIPT_METHODS  METHODS,
                FND_DOCUMENT_SEQUENCES DOC_SEQ,
                AR_SYSTEM_PARAMETERS_ALL SYSPARAM';
    ELSE
      fa_rx_util_pkg.From_Clause := 'RA_TRX_LINE_GL_DIST_ALL_MRC_V RECDIST,
                RA_CUSTOMER_TRX_ALL_MRC_V CT,
                RA_CUST_TRX_TYPES_ALL TRX_TYPE,
                HZ_CUST_ACCOUNTS_ALL BILL_TO,
                HZ_PARTIES  PARTY,
                GL_CODE_COMBINATIONS CCRECDIST,
                AR_RECEIPT_METHODS  METHODS,
                FND_DOCUMENT_SEQUENCES DOC_SEQ';
    END IF;

  --
  -- Assign Where Clause (including the where clause from the parameters)
  --
   fa_rx_util_pkg.debug('AR_ASSIGN_WHERE_CLAUSE');


-- bug:3256137

   -- bug3940958 added where condition for cross-org and new paramereters
   fa_rx_util_pkg.Where_Clause := 'CT.CUST_TRX_TYPE_ID = TRX_TYPE.CUST_TRX_TYPE_ID
                AND CT.BILL_TO_CUSTOMER_ID = BILL_TO.CUST_ACCOUNT_ID
                AND BILL_TO.PARTY_ID = PARTY.PARTY_ID
                AND CT.receipt_method_id = METHODS.receipt_method_id(+)
                AND CT.CUSTOMER_TRX_ID = RECDIST.CUSTOMER_TRX_ID
                AND RECDIST.ACCOUNT_CLASS = ''REC''
                AND RECDIST.LATEST_REC_FLAG = ''Y''
                AND RECDIST.CODE_COMBINATION_ID = CCRECDIST.CODE_COMBINATION_ID
                AND CT.DOC_SEQUENCE_ID = DOC_SEQ.DOC_SEQUENCE_ID(+)
  	        AND   NVL(CT.ORG_ID, -99) = NVL(SYSPARAM.ORG_ID,-99)
        	AND NVL(CT.ORG_ID, -99) = NVL(TRX_TYPE.ORG_ID, -99) '||
                COMPLETE_FLAG_WHERE ||' '||
                POSTED_FLAG_WHERE ||' '||
                REC_GL_DATE_WHERE ||' '||
                TRX_DATE_WHERE ||' '||
                TRX_TYPE_WHERE ||' '||
                TRX_CLASS_WHERE ||' '||
                REC_BALANCING_WHERE ||' '||
                BILL_TO_CUSTOMER_NAME_WHERE ||' '||
                BILL_TO_CUSTOMER_NUMBER_WHERE ||' '||
                CURRENCY_CODE_WHERE ||' '||
                PAYMENT_METHOD_WHERE || ' ' ||
                DOC_SEQUENCE_NAME_WHERE || ' ' ||
   		DOC_SEQUENCE_NUMBER_WHERE || ' ' ||
                L_RECDIST_ORG_WHERE || ' ' ||
                L_CT_ORG_WHERE || ' ' ||
                L_TRX_TYPE_ORG_WHERE || ' ' ||
                L_BILL_TO_ORG_WHERE || ' ' ||
		BATCH_SOURCE_WHERE || ' ' ||
		REC_ACCOUNT_WHERE ;

   fa_rx_util_pkg.debug('arrx_tx.before_report()-');

end before_report;


--
-- This is the bind trigger for the main artx_rep report
procedure bind(c in integer)
is
   b_type_a                              varchar2(240);
   b_j_type_n                            varchar2(80);
   YES_NO_Y                              varchar2(80);
   YES_NO_N                              varchar2(80);
begin
   fa_rx_util_pkg.debug('AR_GET_BIND');
  --
  -- These bind variables(Date Type) were included in the WHERE clause
  --
   IF var.start_gl_date IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_gl_date', var.start_gl_date);
   END IF;
   IF var.end_gl_date IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_gl_date', var.end_gl_date);
   END IF;

   --begin for bug 1814839

   IF var.start_bill_to_customer_name IS NULL AND var.end_bill_to_customer_name IS NULL THEN
      NULL;
   ELSIF var.start_bill_to_customer_name IS NULL THEN
      dbms_sql.bind_variable(c, 'end_bill_to_customer_name', var.end_bill_to_customer_name);
   ELSIF var.end_bill_to_customer_name IS NULL THEN
      dbms_sql.bind_variable(c, 'start_bill_to_customer_name', var.start_bill_to_customer_name);
   ELSE
      dbms_sql.bind_variable(c, 'end_bill_to_customer_name', var.end_bill_to_customer_name);
      dbms_sql.bind_variable(c, 'start_bill_to_customer_name', var.start_bill_to_customer_name);

   END IF;

   --end for bug 1814839

   IF var.start_transaction_date IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_transaction_date', var.start_transaction_date);
   END IF;
   IF var.end_transaction_date IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_transaction_date', var.end_transaction_date);
   END IF;

   select MEANING into YES_NO_Y from ar_lookups
      where lookup_type = 'YES/NO' and LOOKUP_CODE = 'Y';
   select MEANING into YES_NO_N from ar_lookups
      where lookup_type = 'YES/NO' and LOOKUP_CODE = 'N';
   dbms_sql.bind_variable(c, 'YES', YES_NO_Y);
   dbms_sql.bind_variable(c, 'NO', YES_NO_N);

   -- Bug 1988421
   IF var.start_transaction_type IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_transaction_type', var.start_transaction_type);
   END IF;
   IF var.end_transaction_type IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_transaction_type', var.end_transaction_type);
   END IF;
   IF var.start_transaction_class IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_transaction_class', var.start_transaction_class);
   END IF;
   IF var.end_transaction_class IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_transaction_class', var.end_transaction_class);
   END IF;
   IF var.start_bill_to_customer_number IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_bill_to_customer_number', var.start_bill_to_customer_number);
   END IF;
   IF var.end_bill_to_customer_number IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_bill_to_customer_number', var.end_bill_to_customer_number);
   END IF;
   IF var.start_currency IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_currency', var.start_currency);
   END IF;
   IF var.end_currency IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_currency', var.end_currency);
   END IF;
   IF var.payment_method IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'payment_method', var.payment_method);
   END IF;
   IF var.doc_sequence_name IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'doc_sequence_name', var.doc_sequence_name);
   END IF;
   IF var.doc_sequence_number_from IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'doc_sequence_number_from', var.doc_sequence_number_from);
   END IF;
   IF var.doc_sequence_number_to IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'doc_sequence_number_to', var.doc_sequence_number_to);
   END IF;

   -- bug3940958 added for new binds
   -- p_reporting_entity_id is used only for operating unit level
   IF var.reporting_level = '3000' THEN
      dbms_sql.bind_variable(c, 'p_reporting_entity_id', var.reporting_entity_id);
   END IF;

   IF var.batch_source_name IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'batch_source_name', var.batch_source_name);
   END IF;

   IF var.transaction_class IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'transaction_class', var.transaction_class);
   END IF;
end bind;


--
-- This is the after fetch trigger for the main artx_rep report
procedure after_fetch
is
begin
  --
  -- Get FLEX FIELD VALUE and DESCRIPTION
  --
   fa_rx_util_pkg.debug('GL_GET_FLEX_KEYWORD');

/*   var.rec_account := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_ccid => var.ccid);*/

   var.rec_account_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_data => var.rec_account),1,240);

/*   var.rec_balance := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_ccid => var.ccid);*/

   var.rec_balance_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_data => var.rec_balance),1,240);

/*   var.rec_natacct := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_ccid => var.ccid);*/

   var.rec_natacct_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_data => var.rec_natacct),1,240);

end after_fetch;


--
-- Main AR TRANSACTION CHECK RX Report function(Plug-In)
--
procedure artx_rep_check (
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_transaction_date      in   date,
   end_transaction_date        in   date,
   start_transaction_type      in   varchar2,
   end_transaction_type        in   varchar2,
   start_transaction_class     in   varchar2,
   end_transaction_class       in   varchar2,
   start_balancing_segment     in   varchar2,
   end_balancing_segment       in   varchar2,
   start_bill_to_customer_name in   varchar2,
   end_bill_to_customer_name   in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   payment_method              in   varchar2,
   start_update_date           in   date,
   end_update_date             in   date,
   last_updated_by             in   number,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is

-- Document sequence parameter declarations
    doc_sequence_name		varchar2(30)	:= NULL;
    doc_sequence_number_from    number		:= NULL;
    doc_sequence_number_to	number		:= NULL;
-- Customer Number parameter declarations
   start_bill_to_customer_number  varchar2(30)  := NULL;
   end_bill_to_customer_number    varchar2(30)  := NULL;
begin
   fa_rx_util_pkg.debug('arrx_tx.artx_rep_check()+');

  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger

   var.start_update_date := Trunc(start_update_date);
   var.end_update_date := Trunc(end_update_date)+1-1/24/60/60;
   var.last_updated_by := last_updated_by;

   fa_rx_util_pkg.debug('start_update_date = '|| var.start_update_date);
   fa_rx_util_pkg.debug('end_update_date = '|| var.end_update_date);
   fa_rx_util_pkg.debug('last_updated_by = '|| var.last_updated_by);

  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_tx.artx_rep_check',request_id,'AR_TRANSACTIONS_REP_ITF');

  --
  -- Call the main journal report

  -- bug3940958 added some parameters
   arrx_tx.artx_rep(
    completed_flag,
    posted_flag,
    start_gl_date,
    end_gl_date,
    start_transaction_date,
    end_transaction_date,
    start_transaction_type,
    end_transaction_type,
    start_transaction_class,
    end_transaction_class,
    start_balancing_segment,
    end_balancing_segment,
    start_bill_to_customer_name,
    end_bill_to_customer_name,
    start_currency,
    end_currency,
    payment_method,
    doc_sequence_name,
    doc_sequence_number_from,
    doc_sequence_number_to,
    start_bill_to_customer_number,
    end_bill_to_customer_number,
    null,
    null,
    null,
    null,
    null,
    null,
    request_id,
    retcode,
    errbuf);


  --
  -- Assign triggers specific to this report
  -- Make sure that you make your assignment to the correct section ('AR TRANSACTION')
   fa_rx_util_pkg.assign_report('AR TRANSACTIONS',
                true,
                'arrx_tx.check_before_report;',
                'arrx_tx.check_bind(:CURSOR_SELECT);',
                'arrx_tx.check_after_fetch;',
                null);

  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure ('arrx_tx.artx_rep_check')
   fa_rx_util_pkg.run_report('arrx_tx.artx_rep_check', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_tx.artx_rep_check()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_tx.artx_rep_check(EXCEPTION)-');
end artx_rep_check;


--
-- This is the before report trigger for the artx_rep_check report.
procedure check_before_report
is
   CC_ACCOUNT_SEL			 varchar2(500);
   CC_BALANCE_SEL			 varchar2(500);
   CC_NATURAL_SEL			 varchar2(500);

   decode_inv                            varchar2(500);
   get_item                              varchar2(500);
   LAST_UPDATE_WHERE                     varchar2(500);
begin
   fa_rx_util_pkg.debug('arrx_tx.check_before_report()+');

   fa_rx_util_pkg.debug('GL_GET_PROFILE_SO_FLEX_CODE');

   oe_profile.get(
          name => 'SO_ID_FLEX_CODE',
          val => var.so_id_flex_code);


   fa_rx_util_pkg.debug('GL_GET_PROFILE_SO_ORG_ID');

   oe_profile.get(
           name => 'SO_ORGANIZATION_ID',
           val => var.so_organization_id);

   get_item := fa_rx_flex_pkg.flex_sql(
                              p_application_id => 401,
                              p_id_flex_code => var.so_id_flex_code,
                              p_id_flex_num => null,
                              p_table_alias => 'ITEM',
                              p_mode => 'SELECT',
                              p_qualifier => 'ALL');

   decode_inv := 'DECODE(CTL.INVENTORY_ITEM_ID,NULL,DECODE(CTL.MEMO_LINE_ID,NULL,CTL.DESCRIPTION,MEMO.NAME),
                  '|| get_item ||' ) ';

  --
  -- Flex SQL
  --
  CC_ACCOUNT_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'ALL');
  CC_BALANCE_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'GL_BALANCING');
  CC_NATURAL_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'GL_ACCOUNT');

  --
  -- Assign another column specific to this report
   fa_rx_util_pkg.debug('AR_ADD_SELECT_COLUMNS');

   fa_rx_util_pkg.assign_column('c1 ','CCDIST.CODE_COMBINATION_ID',           null,                          'arrx_tx.var.ccid2',                       'NUMBER');
   fa_rx_util_pkg.assign_column('c2 ','CTL.CUSTOMER_TRX_LINE_ID',             'CUSTOMER_TRX_LINE_ID',        'arrx_tx.var.customer_trx_line_id',        'NUMBER');
   fa_rx_util_pkg.assign_column('c3 ','CTL.LINK_TO_CUST_TRX_LINE_ID',         'LINK_TO_CUST_TRX_LINE_ID',    'arrx_tx.var.link_to_cust_trx_line_id',    'NUMBER');
   fa_rx_util_pkg.assign_column('c4 ',decode_inv,                             'INVENTORY_ITEM',              'arrx_tx.var.inventory_item',              'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c5 ','DIST.CUST_TRX_LINE_GL_DIST_ID',        'CUST_TRX_LINE_GL_DIST_ID',    'arrx_tx.var.cust_trx_line_gl_dist_id',    'NUMBER');
   fa_rx_util_pkg.assign_column('c6 ',CC_ACCOUNT_SEL,                         'ACCOUNT',                     'arrx_tx.var.account',                     'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c7 ',null,                                   'ACCOUNT_DESC',                'arrx_tx.var.account_desc',                'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c8 ',CC_BALANCE_SEL,                         'BALANCE',                     'arrx_tx.var.balance',                     'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c9 ',null,                                   'BALANCE_DESC',                'arrx_tx.var.balance_desc',                'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c10',CC_NATURAL_SEL,                         'NATACCT',                     'arrx_tx.var.natacct',                     'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c11',null,                                   'NATACCT_DESC',                'arrx_tx.var.natacct_desc',                'VARCHAR2',240);

  --
  -- Add to the  FROM clause specific to this report
   fa_rx_util_pkg.debug('AR_ADD_FORM_CLAUSE');
   fa_rx_util_pkg.From_Clause :=
                 fa_rx_util_pkg.From_Clause || ',
                       RA_CUSTOMER_TRX_LINES CTL,
                       RA_CUST_TRX_LINE_GL_DIST DIST,
                       MTL_SYSTEM_ITEMS ITEM,
                       AR_MEMO_LINES MEMO,
                       GL_CODE_COMBINATIONS CCDIST';

  --
  -- Add to the  WHERE clause specific to this report
   fa_rx_util_pkg.debug('AR_ADD_WHERE_CLAUSE');

   IF var.last_updated_by is null THEN
      LAST_UPDATE_WHERE := ' AND ARRX_TX.WHERE_LAST_UPDATE(CT.CUSTOMER_TRX_ID,null,
                                                        :start_update_date,:end_update_date) = ''Y'' ';
   ELSE
      LAST_UPDATE_WHERE := ' AND ARRX_TX.WHERE_LAST_UPDATE(CT.CUSTOMER_TRX_ID,'|| var.last_updated_by ||',
                                                        :start_update_date,:end_update_date) = ''Y'' ';
   END IF;

   fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause || '
                          AND CT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
                          AND ITEM.ORGANIZATION_ID(+) = '|| var.so_organization_id ||'
                          AND CTL.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID(+)
                          AND CTL.MEMO_LINE_ID = MEMO.MEMO_LINE_ID(+)
                          AND CT.CUSTOMER_TRX_ID = DIST.CUSTOMER_TRX_ID
                          AND CTL.CUSTOMER_TRX_LINE_ID = DIST.CUSTOMER_TRX_LINE_ID
                          AND DIST.ACCOUNT_SET_FLAG = ''N''
                          AND DIST.CODE_COMBINATION_ID = CCDIST.CODE_COMBINATION_ID '||
                          LAST_UPDATE_WHERE;

   fa_rx_util_pkg.debug('arrx_tx.check_before_report()-');

end check_before_report;


--
-- This is the bind trigger for the main artx_rep report
procedure check_bind(c in integer)
is
begin
   fa_rx_util_pkg.debug('AR_GET_BIND');
  --
  -- These bind variables(Date Type) were included in the WHERE clause
  --
   dbms_sql.bind_variable(c, 'start_update_date', var.start_update_date);
   dbms_sql.bind_variable(c, 'end_update_date', var.end_update_date);

end check_bind;


--
-- This is the after fetch trigger for the main artx_rep report
procedure check_after_fetch
is
begin

  --
  -- Get FLEX FIELD VALUE and DESCRIPTION
  --
   fa_rx_util_pkg.debug('AR_GET_FLEX_KEYWORD');

/*   var.account := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_ccid => var.ccid2);*/

   var.account_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_data => var.account), 1, 240);

/*   var.balance := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_ccid => var.ccid2);*/

   var.balance_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_data => var.balance), 1, 240);

/*   var.natacct := fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_ccid => var.ccid2);*/

   var.natacct_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_data => var.natacct), 1, 240);

end check_after_fetch;


--
-- Main AR TRANSACTION FORECAST RX Report function(Plug-In)
--
procedure artx_rep_forecast(
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_transaction_date      in   date,
   end_transaction_date        in   date,
   start_transaction_type      in   varchar2,
   end_transaction_type        in   varchar2,
   start_transaction_class     in   varchar2,
   end_transaction_class       in   varchar2,
   start_balancing_segment     in   varchar2,
   end_balancing_segment       in   varchar2,
   start_bill_to_customer_name in   varchar2,
   end_bill_to_customer_name   in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   payment_method              in   varchar2,
   start_due_date              in   date,
   end_due_date                in   date,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is

-- Document sequence parameter declarations
    doc_sequence_name		varchar2(30)	:= NULL;
    doc_sequence_number_from    number		:= NULL;
    doc_sequence_number_to	number		:= NULL;
-- Customer Number parameter declarations
   start_bill_to_customer_number  varchar2(30)  := NULL;
   end_bill_to_customer_number    varchar2(30)  := NULL;

begin
   fa_rx_util_pkg.debug('arrx_tx.artx_rep_forecast()+');

  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger

   var.start_due_date := Trunc(start_due_date);
   var.end_due_date := Trunc(end_due_date)+1-1/24/60/60;

   fa_rx_util_pkg.debug('start_due_date = '|| var.start_due_date);
   fa_rx_util_pkg.debug('end_due_date = '|| var.end_due_date);

  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_tx.artx_rep_forecast',request_id,'AR_TRANSACTIONS_REP_ITF');

  --
  -- Call the main journal report

  -- bug3940958 added some parameters
   arrx_tx.artx_rep(
    completed_flag,
    posted_flag,
    start_gl_date,
    end_gl_date,
    start_transaction_date,
    end_transaction_date,
    start_transaction_type,
    end_transaction_type,
    start_transaction_class,
    end_transaction_class,
    start_balancing_segment,
    end_balancing_segment,
    start_bill_to_customer_name,
    end_bill_to_customer_name,
    start_currency,
    end_currency,
    payment_method,
    doc_sequence_name,
    doc_sequence_number_from,
    doc_sequence_number_to,
    start_bill_to_customer_number,
    end_bill_to_customer_number,
    null,
    null,
    null,
    null,
    null,
    null,
    request_id,
    retcode,
    errbuf);

  --
  -- Assign triggers specific to this report
  -- Make sure that you make your assignment to the correct section ('AR TRANSACTION')
   fa_rx_util_pkg.assign_report('AR TRANSACTIONS',
                true,
                'arrx_tx.forecast_before_report;',
                'arrx_tx.forecast_bind(:CURSOR_SELECT);',
                null,
                null);

  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure ('arrx_tx.artx_rep_forecast')
   fa_rx_util_pkg.run_report('arrx_tx.artx_rep_forecast', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_tx.artx_rep_forecast()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_tx.artx_rep_forecast(EXCEPTION)-');
end artx_rep_forecast;

--
-- This is the before report trigger for the artx_rep_forecast report.
procedure forecast_before_report
is
   SCHEDULE_DUE_DATE_WHERE               varchar2(500);
begin
   fa_rx_util_pkg.debug('arrx_tx.forecast_before_report()+');

  --
  -- Assign another column specific to this report
   fa_rx_util_pkg.debug('AR_ADD_SELECT_COLUMNS');

   fa_rx_util_pkg.assign_column('f1 ','PS.PAYMENT_SCHEDULE_ID',               'TRX_PAYMENT_SCHEDULE_ID',     'arrx_tx.var.trx_payment_schedule_id',     'NUMBER');
   fa_rx_util_pkg.assign_column('60 ','CONS_INV.CONS_BILLING_NUMBER',         'CONS_BILL_NUMBER',            'arrx_tx.var.cons_bill_number',            'VARCHAR2', 30);

  --
  -- Add to the  FROM clause specific to this report
   fa_rx_util_pkg.debug('AR_ADD_FORM_CLAUSE');
   fa_rx_util_pkg.From_Clause := '
                       AR_PAYMENT_SCHEDULES PS,'||
                 fa_rx_util_pkg.From_Clause || ',
                       AR_CONS_INV CONS_INV';

  --
  -- Add to the  WHERE clause specific to this report
   fa_rx_util_pkg.debug('AR_ADD_WHERE_CLAUSE');

   IF var.start_due_date IS NULL AND var.end_due_date IS NULL THEN
      SCHEDULE_DUE_DATE_WHERE := NULL;
   ELSIF var.start_due_date IS NULL THEN
      SCHEDULE_DUE_DATE_WHERE := ' AND PS.DUE_DATE <= :end_due_date';
   ELSIF var.end_due_date IS NULL THEN
      SCHEDULE_DUE_DATE_WHERE := ' AND PS.DUE_DATE >= :start_due_date';
   ELSE
      SCHEDULE_DUE_DATE_WHERE := ' AND PS.DUE_DATE BETWEEN :start_due_date AND :end_due_date';
   END IF;

   fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause || '
                          AND	CT.CUSTOMER_TRX_ID = PS.CUSTOMER_TRX_ID
                          AND	PS.STATUS = ''OP''
                          AND	PS.CONS_INV_ID = CONS_INV.CONS_INV_ID(+) '||
                          SCHEDULE_DUE_DATE_WHERE;

   fa_rx_util_pkg.debug('arrx_tx.forecast_before_report()-');

end forecast_before_report;


--
-- This is the bind trigger for the main artx_rep report
procedure forecast_bind(c in integer)
is
begin
   fa_rx_util_pkg.debug('AR_GET_BIND');
  --
  -- These bind variables(Date Type) were included in the WHERE clause
  --
   IF var.start_due_date IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_due_date', var.start_due_date);
   END IF;
   IF var.end_due_date IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_due_date', var.end_due_date);
   END IF;

end forecast_bind;


--
-- Main AR SALES REGISTER RX Report function(Plug-In)
--
procedure artx_sales_rep (
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   transaction_type            in   varchar2,
   line_invoice                in   varchar2,
   start_invoice_num           in   varchar2,
   end_invoice_num             in   varchar2,
   doc_sequence_name           in   varchar2,
   start_doc_sequence_value    in   number,
   end_doc_sequence_value      in   number,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_company_segment       in   varchar2,
   end_company_segment         in   varchar2,
   start_rec_nat_acct          in   varchar2,
   end_rec_nat_acct            in   varchar2,
   start_account               in   varchar2,
   end_account                 in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   start_amount                in   number,
   end_amount                  in   number,
   start_customer_name         in   varchar2,
   end_customer_name           in   varchar2,
   start_customer_number       in   varchar2,
   end_customer_number         in   varchar2,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2)
is

-- Some parameter for main procedure declarations
    start_transaction_date      date            := to_date(NULL);
    end_transaction_date        date            := to_date(NULL);
    start_transaction_class     varchar2(20)    := NULL;
    end_transaction_class       varchar2(20)    := NULL;
    payment_method              varchar2(30)    := NULL;

begin
   fa_rx_util_pkg.debug('arrx_tx.artx_sales_rep()+');
  --
  -- Set global variables (This variable will be used in before report trigger.)
  --
   var.line_invoice 		:= line_invoice;
   var.start_invoice_num 	:= start_invoice_num;
   var.end_invoice_num 		:= end_invoice_num;
   var.start_rec_nat_acct 	:= start_rec_nat_acct;
   var.end_rec_nat_acct 	:= end_rec_nat_acct;
   var.start_account 		:= start_account;
   var.end_account 		:= end_account;
   var.start_amount 		:= start_amount;
   var.end_amount 		:= end_amount;

  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_tx.artx_sales_rep',request_id,'AR_TRANSACTIONS_REP_ITF');

  --
  -- Call the main journal report

  -- bug3940958 added new parameters
   arrx_tx.artx_rep(
    completed_flag,
    posted_flag,
    start_gl_date,
    end_gl_date,
    start_transaction_date,
    end_transaction_date,
    transaction_type,
    transaction_type,
    start_transaction_class,
    end_transaction_class,
    start_company_segment,
    end_company_segment,
    start_customer_name,
    end_customer_name,
    start_currency,
    end_currency,
    payment_method,
    doc_sequence_name,
    start_doc_sequence_value,
    end_doc_sequence_value,
    start_customer_number,
    end_customer_number,
    null,
    null,
    start_account,-- Start bug 5571594
    end_account,-- End bug 5571594 SPDIXIT
    null,
    null,
    request_id,
    retcode,
    errbuf);

  --
  -- Assign triggers specific to this report
  -- Make sure that you make your assignment to the correct section ('AR TRANSACTION')
   fa_rx_util_pkg.assign_report('AR TRANSACTIONS',
                true,
                'arrx_tx.sales_before_report;',
                'arrx_tx.sales_bind(:CURSOR_SELECT);',
                'arrx_tx.sales_after_fetch;',
                null);

  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure ('arrx_tx.artx_sales_rep')
   fa_rx_util_pkg.run_report('arrx_tx.artx_sales_rep', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_tx.artx_sales_rep()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_tx.artx_sales_rep(EXCEPTION)-');
end artx_sales_rep;


--
-- This is the before report trigger for the artx_sales_rep report.
procedure sales_before_report
is
   CC_ACCOUNT_SEL			 varchar2(500);
   CC_BALANCE_SEL			 varchar2(500);
   CC_NATURAL_SEL			 varchar2(500);

   decode_inv                            varchar2(500);
   get_item                              varchar2(500);
   LAST_UPDATE_WHERE                     varchar2(500);

   transaction_number_where		 varchar2(1000); -- where-clause statement for transaction numbers(invoice numbers)
   natural_account_where		 varchar2(1000); -- where-clause statement for receivables natural accounts
   account_where			 varchar2(1000); -- where-clause statement for line accounts
   amount_where				 varchar2(1000); -- where-clause statement for line amounts
   line_select_statement 		 varchar2(1000); -- where-clause statement for sub-query of line information

begin
   fa_rx_util_pkg.debug('arrx_tx.sales_before_report()+');

   fa_rx_util_pkg.debug('GL_GET_PROFILE_SO_FLEX_CODE');

   oe_profile.get(
          name => 'SO_ID_FLEX_CODE',
          val => var.so_id_flex_code);


   fa_rx_util_pkg.debug('GL_GET_PROFILE_SO_ORG_ID');

   oe_profile.get(
           name => 'SO_ORGANIZATION_ID',
           val => var.so_organization_id);

   get_item := fa_rx_flex_pkg.flex_sql(
                              p_application_id => 401,
                              p_id_flex_code => var.so_id_flex_code,
                              p_id_flex_num => null,
                              p_table_alias => 'ITEM',
                              p_mode => 'SELECT',
                              p_qualifier => 'ALL');

   decode_inv := 'DECODE(CTL.INVENTORY_ITEM_ID,NULL,DECODE(CTL.MEMO_LINE_ID,NULL,CTL.DESCRIPTION,MEMO.NAME),
                  '|| get_item ||' ) ';

  --
  -- Flex SQL for Select columns
  --
  CC_ACCOUNT_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'ALL');
  CC_BALANCE_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'GL_BALANCING');
  CC_NATURAL_SEL :=
         FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'CCDIST',
                             p_mode => 'SELECT',
                             p_qualifier => 'GL_ACCOUNT');

  --
  -- Create some Where-Clause
  -- Invoice Number parameters
   if (var.start_invoice_num is NULL) and (var.end_invoice_num is NULL) then
  	transaction_number_where := NULL;
   elsif var.start_invoice_num is NULL then
	transaction_number_where := ' AND CT.TRX_NUMBER <= :end_invoice_num ';
   elsif var.end_invoice_num is NULL then
 	transaction_number_where := ' AND CT.TRX_NUMBER >= :start_invoice_num ';
   else
	transaction_number_where := ' AND CT.TRX_NUMBER between :start_invoice_num and :end_invoice_num ';
   end if;

  -- Receivables Natural Account parameters
   if (var.start_rec_nat_acct is NULL) and (var.end_rec_nat_acct is NULL) then
	natural_account_where := NULL;
   elsif var.start_rec_nat_acct is NULL then
        natural_account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             			p_application_id => 101,
                             			p_id_flex_code => 'GL#',
                             			p_id_flex_num => var.chart_of_accounts_id,
                             			p_table_alias => 'CCRECDIST',
                             			p_mode => 'WHERE',
                             			p_qualifier => 'GL_ACCOUNT',
						P_function => '<=',
						p_operand1 => var.end_rec_nat_acct);
   elsif var.end_rec_nat_acct is NULL then
        natural_account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             			p_application_id => 101,
                            	 		p_id_flex_code => 'GL#',
                             			p_id_flex_num => var.chart_of_accounts_id,
                             			p_table_alias => 'CCRECDIST',
                             			p_mode => 'WHERE',
                             			p_qualifier => 'GL_ACCOUNT',
						p_function => '>=',
						p_operand1 => var.start_rec_nat_acct);
   else
  	natural_account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             			p_application_id => 101,
                             			p_id_flex_code => 'GL#',
                           	  		p_id_flex_num => var.chart_of_accounts_id,
                             			p_table_alias => 'CCRECDIST',
                             			p_mode => 'WHERE',
                             			p_qualifier => 'GL_ACCOUNT',
						p_function => 'BETWEEN',
						p_operand1 => var.start_rec_nat_acct,
						p_operand2 => var.end_rec_nat_acct);
   end if;

  -- Line Account parameters
  if var.line_invoice = 'LINE' then
   if (var.start_account is NULL) and (var.end_account is NULL) then
	account_where := NULL;
   elsif var.start_account is NULL then
    	account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             		p_application_id => 101,
                             		p_id_flex_code => 'GL#',
                             		p_id_flex_num => var.chart_of_accounts_id,
                             		p_table_alias => 'CCDIST',      -- This alias is used in main select statement
                             		p_mode => 'WHERE',
                             		p_qualifier => 'ALL',
					p_function => '<=',
					p_operand1 => var.end_account);
   elsif var.end_account is NULL then
    	account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             		p_application_id => 101,
                             		p_id_flex_code => 'GL#',
                             		p_id_flex_num => var.chart_of_accounts_id,
                             		p_table_alias => 'CCDIST',      -- This alias is used in main select statement
                             		p_mode => 'WHERE',
                             		p_qualifier => 'ALL',
					p_function => '>=',
					p_operand1 => var.start_account);
   else
   	account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             		p_application_id => 101,
                             		p_id_flex_code => 'GL#',
                             		p_id_flex_num => var.chart_of_accounts_id,
                             		p_table_alias => 'CCDIST',      -- This alias is used in main select statement
                             		p_mode => 'WHERE',
                             		p_qualifier => 'ALL',
					p_function => 'BETWEEN',
					p_operand1 => var.start_account,
					p_operand2 => var.end_account);
   end if;
  else
   if (var.start_account is NULL) and (var.end_account is NULL) then
	account_where := NULL;
   elsif var.start_account is NULL then
    	account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             		p_application_id => 101,
                             		p_id_flex_code => 'GL#',
                             		p_id_flex_num => var.chart_of_accounts_id,
                             		p_table_alias => 'LINEGL',         -- This alias is used in sub query.
                             		p_mode => 'WHERE',
                             		p_qualifier => 'ALL',
					p_function => '<=',
					p_operand1 => var.end_account);
   elsif var.end_account is NULL then
    	account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                            		p_application_id => 101,
                             		p_id_flex_code => 'GL#',
                             		p_id_flex_num => var.chart_of_accounts_id,
                             		p_table_alias => 'LINEGL',         -- This alias is used in sub query.
                             		p_mode => 'WHERE',
                             		p_qualifier => 'ALL',
					p_function => '>=',
					p_operand1 => var.start_account);
   else
    	account_where := ' AND '|| FA_RX_FLEX_PKG.FLEX_SQL(
                             		p_application_id => 101,
                             		p_id_flex_code => 'GL#',
                             		p_id_flex_num => var.chart_of_accounts_id,
                             		p_table_alias => 'LINEGL',         -- This alias is used in sub query.
                             		p_mode => 'WHERE',
                             		p_qualifier => 'ALL',
					p_function => 'BETWEEN',
					p_operand1 => var.start_account,
					p_operand2 => var.end_account);
   end if;
  end if;

  -- Amount parameters
  -- This parameters depend on a line_invoice parameter.
  -- When parameter is 'LINE', this amount parameter will be used to select only lines matched with the condition,
  -- so where clause uses CTL, which is used in main select statement, as an alias.
  -- When parameter is 'INVOICE', this amount parameter will be used to select lines matched with the condition
  -- in a sub query statement. That sub query will return customer_trx_ids which identify the invoice
  -- information. So where clause uses LINE, which is used in sub query statement, as an alias.
  --
   if var.line_invoice = 'LINE' then
	if (to_char(var.start_amount) is NULL) and (to_char(var.end_amount) is NULL) then
		amount_where := NULL;
	elsif to_char(var.start_amount) is NULL then
		amount_where := ' AND DIST.ACCTD_AMOUNT :end_amount ';
	elsif to_char(var.end_amount) is NULL then
		amount_where := ' AND DIST.ACCTD_AMOUNT >= :start_amount ';
	else
		amount_where := ' AND DIST.ACCTD_AMOUNT between :start_amount and :end_amount ';
   	end if;
   else
	if (to_char(var.start_amount) is NULL) and (to_char(var.end_amount) is NULL) then
		amount_where := NULL;
	elsif to_char(var.start_amount) is NULL then
		amount_where := ' AND LINEDIST.ACCTD_AMOUNT <= :end_amount ';
	elsif to_char(var.end_amount) is NULL then
		amount_where := ' AND LINEDIST.ACCTD_AMOUNT >= :start_amount ';
	else
		amount_where := ' AND LINEDIST.ACCTD_AMOUNT between :start_amount and :end_amount ';
   	end if;
   end if;

  --
  -- Assign another column specific to this report
   fa_rx_util_pkg.debug('AR_ADD_SELECT_COLUMNS');

   fa_rx_util_pkg.assign_column('c1 ','CCDIST.CODE_COMBINATION_ID',           null,                          'arrx_tx.var.ccid2',                       'NUMBER');
   fa_rx_util_pkg.assign_column('c2 ','CTL.CUSTOMER_TRX_LINE_ID',             'CUSTOMER_TRX_LINE_ID',        'arrx_tx.var.customer_trx_line_id',        'NUMBER');
   fa_rx_util_pkg.assign_column('c3 ','CTL.LINK_TO_CUST_TRX_LINE_ID',         'LINK_TO_CUST_TRX_LINE_ID',    'arrx_tx.var.link_to_cust_trx_line_id',    'NUMBER');
   fa_rx_util_pkg.assign_column('c4 ',decode_inv,                             'INVENTORY_ITEM',              'arrx_tx.var.inventory_item',              'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c5 ','DIST.CUST_TRX_LINE_GL_DIST_ID',        'CUST_TRX_LINE_GL_DIST_ID',    'arrx_tx.var.cust_trx_line_gl_dist_id',    'NUMBER');
   fa_rx_util_pkg.assign_column('c6 ',CC_ACCOUNT_SEL,                         'ACCOUNT',                     'arrx_tx.var.account',                     'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c7 ',null,                                   'ACCOUNT_DESC',                'arrx_tx.var.account_desc',                'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c8 ',CC_BALANCE_SEL,                         'BALANCE',                     'arrx_tx.var.balance',                     'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c9 ',null,                                   'BALANCE_DESC',                'arrx_tx.var.balance_desc',                'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c10',CC_NATURAL_SEL,                         'NATACCT',                     'arrx_tx.var.natacct',                     'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c11',null,                                   'NATACCT_DESC',                'arrx_tx.var.natacct_desc',                'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('c12','ITEM.DESCRIPTION',                     'ITEM_DESCRIPTION',            'arrx_tx.var.item_description',                'VARCHAR2',240);

  --
  -- Add to the  FROM clause specific to this report
   fa_rx_util_pkg.debug('AR_ADD_FORM_CLAUSE');
   fa_rx_util_pkg.From_Clause :=
                 fa_rx_util_pkg.From_Clause || ',
                       RA_CUSTOMER_TRX_LINES CTL,
                       RA_CUST_TRX_LINE_GL_DIST DIST,
                       MTL_SYSTEM_ITEMS ITEM,
                       AR_MEMO_LINES MEMO,
                       GL_CODE_COMBINATIONS CCDIST';

  --
  -- Add to the  WHERE clause specific to this report
   fa_rx_util_pkg.debug('AR_ADD_WHERE_CLAUSE');

   if var.line_invoice = 'LINE' then
	   fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause || '
                          AND CT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID'||
			  transaction_number_where ||
			  natural_account_where ||
			  account_where ||'
                          AND ITEM.ORGANIZATION_ID(+) = '|| var.so_organization_id ||'
                          AND CTL.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID(+)
                          AND CTL.MEMO_LINE_ID = MEMO.MEMO_LINE_ID(+)
                          AND CT.CUSTOMER_TRX_ID = DIST.CUSTOMER_TRX_ID
                          AND CTL.CUSTOMER_TRX_LINE_ID = DIST.CUSTOMER_TRX_LINE_ID'||
			  amount_where ||'
                          AND DIST.ACCOUNT_SET_FLAG = ''N''
                          AND DIST.CODE_COMBINATION_ID = CCDIST.CODE_COMBINATION_ID ';
   else
      -- create sub-query to select customer transaction id to pickup invoice information
      -- which includes lines matched with specified line parameters.

       --Bug:3825294
       if (account_where is not null or amount_where is not null)
         then
	   line_select_statement :=
                ' AND CT.CUSTOMER_TRX_ID in '||
		'(select distinct line.customer_trx_id
		    from ra_cust_trx_line_gl_dist	linedist,
			 ra_customer_trx_lines		line,
			 gl_code_combinations		linegl
		   where linedist.account_class <> ''REC''
		     and linedist.customer_trx_line_id = line.customer_trx_line_id
		     and linedist.code_combination_id = linegl.code_combination_id
		     and linedist.account_set_flag = ''N'''||
			 account_where ||
			 amount_where ||')';
         else
           line_select_statement := null;
       end if;

	   fa_rx_util_pkg.Where_Clause :=
                    fa_rx_util_pkg.Where_Clause ||
			  line_select_statement ||
			  transaction_number_where ||
			  natural_account_where ||'
			  AND CT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
                          AND ITEM.ORGANIZATION_ID(+) = '|| var.so_organization_id ||'
                          AND CTL.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID(+)
                          AND CTL.MEMO_LINE_ID = MEMO.MEMO_LINE_ID(+)
                          AND CT.CUSTOMER_TRX_ID = DIST.CUSTOMER_TRX_ID
                          AND CTL.CUSTOMER_TRX_LINE_ID = DIST.CUSTOMER_TRX_LINE_ID
                          AND DIST.ACCOUNT_SET_FLAG = ''N''
                          AND DIST.CODE_COMBINATION_ID = CCDIST.CODE_COMBINATION_ID ';
   end if;

   fa_rx_util_pkg.debug('arrx_tx.sales_before_report()-');

end sales_before_report;

procedure sales_bind(c in integer)
is
begin
   fa_rx_util_pkg.debug('AR_GET_BIND');
  --
  -- These bind variables(Date Type) were included in the WHERE clause
  --
   IF var.start_invoice_num IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_invoice_num', var.start_invoice_num);
   END IF;
   IF var.end_invoice_num IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_invoice_num', var.end_invoice_num);
   END IF;
   IF var.start_amount IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'start_amount', var.start_amount);
   END IF;
   IF var.end_amount IS NOT NULL THEN
      dbms_sql.bind_variable(c, 'end_amount', var.end_amount);
   END IF;

end sales_bind;

--
-- This is the after fetch trigger for the main artx_rep report
procedure sales_after_fetch
is
begin

  --
  -- Get FLEX FIELD VALUE and DESCRIPTION
  --
   fa_rx_util_pkg.debug('AR_GET_FLEX_KEYWORD');

   var.account_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_data => var.account), 1, 240);

   var.balance_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_data => var.balance), 1, 240);

   var.natacct_desc := substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_data => var.natacct), 1, 240);

end sales_after_fetch;


Function GET_CONS_BILL_NUMBER(P_CUSTOMER_TRX_ID in number)
   return VARCHAR2
is
   CURSOR CONS_BILL(CTID IN NUMBER) IS
      SELECT CONS_INV.CONS_BILLING_NUMBER
      FROM AR_PAYMENT_SCHEDULES PS, AR_CONS_INV CONS_INV
      WHERE PS.CONS_INV_ID = CONS_INV.CONS_INV_ID
        AND PS.STATUS = 'OP'
        AND PS.CUSTOMER_TRX_ID = CTID;

   L_CONS_BILL_NUMBER  varchar2(30);
begin
   OPEN CONS_BILL(P_CUSTOMER_TRX_ID);
   FETCH CONS_BILL INTO L_CONS_BILL_NUMBER;
      IF CONS_BILL%NOTFOUND THEN
         L_CONS_BILL_NUMBER := NULL;
      END IF;
   CLOSE CONS_BILL;

   RETURN L_CONS_BILL_NUMBER;
end GET_CONS_BILL_NUMBER;

procedure GET_LAST_UPDATE(P_CUSTOMER_TRX_ID in number)
is
   cursor H is
      select last_update_date,last_updated_by
      from ra_customer_trx
      where customer_trx_id = P_CUSTOMER_TRX_ID
      order by last_update_date desc;

   cursor L is
      select last_update_date,last_updated_by
      from ra_customer_trx_lines
      where customer_trx_id =  P_CUSTOMER_TRX_ID
      order by last_update_date desc;

   cursor D is
      select last_update_date,last_updated_by
      from ra_cust_trx_line_gl_dist
      where customer_trx_id = P_CUSTOMER_TRX_ID
        and ((account_class = 'REC' and latest_rec_flag = 'Y')
         or (account_class <> 'REC' and account_set_flag = 'N'))
      order by last_update_date desc;

   HEADER_DATE        date;
   HEADER_BY          number;
   LINE_DATE          date;
   LINE_BY            number;
   DIST_DATE          date;
   DIST_BY            number;
begin
   var.ctid := P_CUSTOMER_TRX_ID;

   OPEN H;
      FETCH H INTO HEADER_DATE, HEADER_BY;
   CLOSE H;

   OPEN L;
      FETCH L INTO LINE_DATE, LINE_BY;
   CLOSE L;

   OPEN D;
      FETCH D INTO DIST_DATE, DIST_BY;
   CLOSE D;

   IF HEADER_DATE > NVL(LINE_DATE,HEADER_DATE-1) AND HEADER_DATE > NVL(DIST_DATE,HEADER_DATE-1) THEN
      var.update_date := HEADER_DATE;
      var.user_id := HEADER_BY;
   ELSIF LINE_DATE > NVL(HEADER_DATE,LINE_DATE-1) AND LINE_DATE > NVL(DIST_DATE,LINE_DATE-1) THEN
      var.update_date := LINE_DATE;
      var.user_id := LINE_BY;
   ELSE
      var.update_date := DIST_DATE;
      var.user_id := DIST_BY;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      var.user_id := -1;
END GET_LAST_UPDATE;


function LAST_UPDATED_BY(P_CUSTOMER_TRX_ID in number)
return number
is
begin
   IF P_CUSTOMER_TRX_ID <> var.ctid THEN
      GET_LAST_UPDATE(P_CUSTOMER_TRX_ID);
   END IF;

   return var.user_id;
end LAST_UPDATED_BY;


function LAST_UPDATE_DATE(P_CUSTOMER_TRX_ID in number)
return date
is
begin
   IF P_CUSTOMER_TRX_ID <> var.ctid THEN
      GET_LAST_UPDATE(P_CUSTOMER_TRX_ID);
   END IF;

   return var.update_date;
end LAST_UPDATE_DATE;


function WHERE_LAST_UPDATE(P_CUSTOMER_TRX_ID in number, P_LAST_UPDATED_BY in number, P_START_UPDATE_DATE in date, P_END_UPDATE_DATE in date)
return varchar2
is
begin
   IF P_CUSTOMER_TRX_ID <> var.ctid THEN
      GET_LAST_UPDATE(P_CUSTOMER_TRX_ID);
   END IF;

   IF var.update_date BETWEEN P_START_UPDATE_DATE AND P_END_UPDATE_DATE THEN
      IF P_LAST_UPDATED_BY IS NULL THEN
         return 'Y';
      ELSIF P_LAST_UPDATED_BY = var.user_id THEN
         return 'Y';
      END IF;
   END IF;

  return 'N';
end WHERE_LAST_UPDATE;

end ARRX_TX;

/
