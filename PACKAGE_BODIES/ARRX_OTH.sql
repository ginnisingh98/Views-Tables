--------------------------------------------------------
--  DDL for Package Body ARRX_OTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_OTH" as
/* $Header: ARRXOTHB.pls 120.8 2006/07/25 12:05:51 ggadhams noship $ */

--
-- Main Other Receipt Applications Report function
--
procedure oth_rec_app (
   request_id                 in   number,
   p_reporting_level          in   number,
   p_reporting_entity         in   number,
   p_sob_id                   in   number,
   p_coa_id                   in   number,
   p_co_seg_low               in   varchar2,
   p_co_seg_high              in   varchar2,
   p_gl_date_low              in   date,
   p_gl_date_high             in   date,
   p_currency_code            in   varchar2,
   p_customer_name_low        in   varchar2,
   p_customer_name_high       in   varchar2,
   p_customer_number_low      in   varchar2,
   p_customer_number_high     in   varchar2,
   p_receipt_date_low         in   date,
   p_receipt_date_high        in   date,
   p_apply_date_low           in   date,
   p_apply_date_high          in   date,
   p_remit_batch_low          in   varchar2,
   p_remit_batch_high         in   varchar2,
   p_receipt_batch_low        in   varchar2,
   p_receipt_batch_high       in   varchar2,
   p_receipt_number_low       in   varchar2,
   p_receipt_number_high      in   varchar2,
   p_app_type                 in   varchar2,
   retcode                    out NOCOPY  number,
   errbuf                     out NOCOPY  varchar2)
is

begin

  -- Asssign parameters to global variable
  -- These values will be used within the before_report trigger

   var.p_reporting_level        := p_reporting_level;
   var.p_reporting_entity_id    := p_reporting_entity;
   var.p_sob_id                 := p_sob_id;
   var.request_id               := request_id;
   var.p_coa_id			:= p_coa_id;
   var.p_gl_date_low            := p_gl_date_low;
   var.p_gl_date_high           := p_gl_date_high;
   var.p_currency_code          := p_currency_code;
   var.p_co_seg_low             := p_co_seg_low;
   var.p_co_seg_high            := p_co_seg_high;
   var.p_customer_name_low      := p_customer_name_low;
   var.p_customer_name_high     := p_customer_name_high;
   var.p_customer_number_low    := p_customer_number_low;
   var.p_customer_number_high   := p_customer_number_high;
   var.p_receipt_date_low       := p_receipt_date_low;
   var.p_receipt_date_high      := p_receipt_date_high;
   var.p_apply_date_low         := p_apply_date_low;
   var.p_apply_date_high        := p_apply_date_high;
   var.p_remit_batch_low        := p_remit_batch_low;
   var.p_remit_batch_high       := p_remit_batch_high;
   var.p_receipt_batch_low      := p_receipt_batch_low;
   var.p_receipt_batch_high     := p_receipt_batch_high;
   var.p_receipt_number_low     := p_receipt_number_low;
   var.p_receipt_number_high    := p_receipt_number_high;
   var.p_app_type               := p_app_type;


    --Bug 5373461
    if p_reporting_level = 1000 then
     var.books_id := p_reporting_entity;
    elsif p_reporting_level =3000 then
     select set_of_books_id
     into  var.books_id
     from   ar_system_parameters_all
     where org_id = p_reporting_entity;
    end if;
  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_oth.oth_rec_app',request_id,'AR_RECEIPTS_REP_ITF');

  --
  -- Assign report triggers for this report.
  -- This report has one section called AR OTHERREC
  -- NOTE:
  --    before_report is assigned 'arrx_oth.before_report;'
  --    bind is assigned 'arrx_rc.bind(:CURSOR_SELECT);'
  --  Each trigger event is assigned with the full procedure name (including package name).
  --  They end with a ';'.
  --  The bind trigger requires one host variable ':CURSOR_SELECT'.
   fa_rx_util_pkg.assign_report('AR OTHERREC',
                true,
                'arrx_oth.before_report;',
                'arrx_oth.bind(:CURSOR_SELECT);',
                'arrx_oth.after_fetch;',
                null);

  --
  -- Run the report. Make sure to pass as parameter the same
  -- value passed to p_calling_proc in init_request().
   fa_rx_util_pkg.run_report('arrx_oth.oth_rec_app', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_oth.oth_rec_app()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_oth.oth_rec_app(EXCEPTION)-');
end oth_rec_app;


-- This is the before trigger for the main Adj Report ---

procedure before_report
is
        CO_SEG_WHERE                    varchar2(500);
        GL_DATE_WHERE                   varchar2(500);
	CURRENCY_CODE_WHERE		varchar2(500);
        CUSTOMER_NAME_WHERE             varchar2(500);
        CUSTOMER_NUMBER_WHERE           varchar2(500);
        RECEIPT_DATE_WHERE              varchar2(500);
        APPLY_DATE_WHERE                varchar2(500);
        REMIT_BATCH_WHERE               varchar2(500);
        RECEIPT_BATCH_WHERE             varchar2(500);
        RECEIPT_NUMBER_WHERE            varchar2(500);
        APP_TYPE_WHERE                  varchar2(500);

        ACCT_FLEX                       varchar2(500);
        DECODE_ACT_NAME                 varchar2(500);
        DECODE_REF_TYPE                 varchar2(500);
        DECODE_CURRENCY                 varchar2(500);

	OPER				varchar2(10);
	OP1				varchar2(25);
	OP2				varchar2(25);

	SORTBY_DECODE			varchar2(200);
	D_OR_I_DECODE			varchar2(200);
	ADJ_CLASS_DECODE		varchar2(200);
	POSTABLE_DECODE			varchar2(100);

	BALANCING_ORDER_BY		varchar2(100);

	-- Bug 2099632
	SHOW_BILL_WHERE			varchar2(100);
	SHOW_BILL_FROM			varchar2(100);
	BILL_FLAG			varchar2(1);

        -- Bug 2155885
	ACCOUNTING_METHOD_FLAG		varchar2(30);

        L_APP_ORG_WHERE                 varchar2(500);
        L_CR_ORG_WHERE                  varchar2(500);
        L_CRH_ORG_WHERE                 varchar2(500);
        L_PS_ORG_WHERE                  varchar2(500);
        L_CUST_ORG_WHERE                varchar2(500);
        L_BS_ORG_WHERE                  varchar2(500);
        L_RB_ORG_WHERE                  varchar2(500);
        L_AB_ORG_WHERE                  varchar2(500);
        L_BSFIRST_ORG_WHERE             varchar2(500);
        L_CRHFIRST_ORG_WHERE            varchar2(500);
        L_RBFIRST_ORG_WHERE             varchar2(500);
begin

	fa_rx_util_pkg.debug('arrx_oth.before_report()+');

        --
  	-- Get Profile GL_SET_OF_BKS_ID
  	--
   	fa_rx_util_pkg.debug('GL_GET_PROFILE_BKS_ID');

--Bug5373461
--        var.books_id := arp_global.sysparam.set_of_books_id;

	--
  	-- Get CHART_OF_ACCOUNTS_ID
  	--
  	fa_rx_util_pkg.debug('GL_GET_CHART_OF_ACCOUNTS_ID');

	select CHART_OF_ACCOUNTS_ID,CURRENCY_CODE,NAME
	into var.chart_of_accounts_id,var.functional_currency_code,var.organization_name
	from GL_SETS_OF_BOOKS
	where SET_OF_BOOKS_ID = var.books_id;

        fa_rx_util_pkg.debug('Chart of Accounts ID : '||var.chart_of_accounts_id);
        fa_rx_util_pkg.debug('Functional Currency  : '||var.functional_currency_code);
        fa_rx_util_pkg.debug('Organization Name    : '||var.organization_name);

        XLA_MO_REPORTING_API.Initialize(var.p_reporting_level, var.p_reporting_entity_id, 'AUTO');

        L_APP_ORG_WHERE      := XLA_MO_REPORTING_API.Get_Predicate('APP',NULL);
        L_CR_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('CR',NULL);
        L_CRH_ORG_WHERE      := XLA_MO_REPORTING_API.Get_Predicate('CRH',NULL);
--        L_PS_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('PS',NULL);
        L_CUST_ORG_WHERE     := XLA_MO_REPORTING_API.Get_Predicate('CUST',NULL);
        L_BS_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('BS',NULL);
        L_RB_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('RB',NULL);
        L_AB_ORG_WHERE       := XLA_MO_REPORTING_API.Get_Predicate('CBA',NULL);
        L_BSFIRST_ORG_WHERE  := XLA_MO_REPORTING_API.Get_Predicate('BSFIRST',NULL);
        L_CRHFIRST_ORG_WHERE := XLA_MO_REPORTING_API.Get_Predicate('CRHFIRST',NULL);
        L_RBFIRST_ORG_WHERE  := XLA_MO_REPORTING_API.Get_Predicate('RBFIRST',NULL);
	--
	-- Figure out NOCOPY the where clause for the parameters
	--
	fa_rx_util_pkg.debug('AR_GET_PARAMETERS');

-- CO_SEG_WHERE clause
        IF var.p_co_seg_low IS NULL AND var.p_co_seg_high IS NULL THEN
                OPER := NULL;
        ELSIF var.p_co_seg_low IS NULL THEN
                OPER := '<=';
                OP1 := var.p_co_seg_high;
                OP2 := NULL;
        ELSIF var.p_co_seg_high IS NULL THEN
                OPER := '>=';
                OP1 := var.p_co_seg_low;
                OP2 := NULL;
        ELSE
                OPER := 'BETWEEN';
                OP1 := var.p_co_seg_low;
                OP2 := var.p_co_seg_high;
        END IF;
        IF OPER IS NULL THEN
                CO_SEG_WHERE := NULL;
        ELSE
                CO_SEG_WHERE := ' AND '||
                FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'glc',
                             p_mode => 'WHERE',
                             p_qualifier => 'GL_BALANCING',
                             p_function => OPER,
                             p_operand1 => OP1,
                             p_operand2 => OP2);
   END IF;

-- GL_DATE_WHERE clause
        IF var.p_gl_date_low IS NULL AND var.p_gl_date_high IS NULL THEN
              GL_DATE_WHERE := NULL;
        ELSIF var.p_gl_date_low IS NULL THEN
              GL_DATE_WHERE := ' AND APP.GL_DATE <= :p_gl_date_high';
        ELSIF var.p_gl_date_high IS NULL THEN
              GL_DATE_WHERE := ' AND APP.GL_DATE >= :p_gl_date_low';
        ELSE
              GL_DATE_WHERE := ' AND APP.GL_DATE BETWEEN :p_gl_date_low AND :p_gl_date_high';
        END IF;

--CURRENCY_CODE where clause
	IF var.p_currency_code IS NULL THEN
	      CURRENCY_CODE_WHERE := NULL;
        ELSE
	      CURRENCY_CODE_WHERE := ' AND CR.CURRENCY_CODE = :p_currency_code';
   	END IF;

-- CUSTOMER_NAME where clause
     IF var.p_customer_name_low IS NULL AND var.p_customer_name_high IS NULL THEN
         CUSTOMER_NAME_WHERE := NULL;
     ELSIF var.p_customer_name_low IS NULL THEN
         CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME <= :p_customer_name_high';
     ELSIF var.p_customer_name_high IS NULL THEN
         CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME >= :p_customer_name_low';
     ELSE
         CUSTOMER_NAME_WHERE := ' AND PARTY.PARTY_NAME BETWEEN :p_customer_name_low AND :p_customer_name_high';
     END IF;

-- CUSTOMER_NUMBER where clause
     IF var.p_customer_number_low IS NULL AND var.p_customer_number_high IS NULL THEN
         CUSTOMER_NUMBER_WHERE := NULL;
     ELSIF var.p_customer_number_low IS NULL THEN
         CUSTOMER_NUMBER_WHERE := ' AND CUST.ACCOUNT_NUMBER <= :p_customer_number_high';
     ELSIF var.p_customer_number_high IS NULL THEN
         CUSTOMER_NUMBER_WHERE := ' AND CUST.ACCOUNT_NUMBER >= :p_customer_number_low';
     ELSE
         CUSTOMER_NUMBER_WHERE := ' AND CUST.ACCOUNT_NUMBER BETWEEN :p_customer_number_low AND :p_customer_number_high';
     END IF;

-- RECEIPT_DATE where clause
     IF var.p_receipt_date_low IS NULL AND var.p_receipt_date_high IS NULL THEN
         RECEIPT_DATE_WHERE := NULL;
     ELSIF var.p_receipt_date_low IS NULL THEN
         RECEIPT_DATE_WHERE := ' AND CR.RECEIPT_DATE <= :p_receipt_date_high';
    --bug 5397276 changed elsif
   --     ELSIF var.p_customer_number_high IS NULL THEN
     ELSIF var.p_receipt_date_high IS NULL THEN
         RECEIPT_DATE_WHERE := ' AND CR.RECEIPT_DATE  >= :p_receipt_date_low';
     ELSE
         RECEIPT_DATE_WHERE := ' AND CR.RECEIPT_DATE BETWEEN :p_receipt_date_low AND :p_receipt_date_high';
     END IF;

-- APPLY_DATE where clause
     IF var.p_apply_date_low IS NULL AND var.p_apply_date_high IS NULL THEN
         APPLY_DATE_WHERE := NULL;
     ELSIF var.p_apply_date_low IS NULL THEN
         APPLY_DATE_WHERE := ' AND APP.APPLY_DATE <= :p_apply_date_high';
     ELSIF var.p_apply_date_high IS NULL THEN
         APPLY_DATE_WHERE := ' AND APP.APPLY_DATE  >= :p_apply_date_low';
     ELSE
         APPLY_DATE_WHERE := ' AND APP.APPLY_DATE BETWEEN :p_apply_date_low AND :p_apply_date_high';
     END IF;

-- REMIT_BATCH where clause
    IF var.p_remit_batch_low IS NULL and var.p_remit_batch_high IS NULL THEN
       REMIT_BATCH_WHERE := NULL;
    ELSIF var.p_remit_batch_low is NULL THEN
       REMIT_BATCH_WHERE := ' AND RB.NAME  <= :p_remit_batch_high';
    ELSIF var.p_remit_batch_high is NULL THEN
       REMIT_BATCH_WHERE := ' AND RB.NAME  >= :p_remit_batch_low';
    ELSE
       REMIT_BATCH_WHERE := ' AND RB.NAME BETWEEN :p_remit_batch_low and :p_remit_batch_high';
    END IF;

-- RECEIPT_BATCH where clause
    IF var.p_receipt_batch_low IS NULL and var.p_receipt_batch_high IS NULL THEN
       RECEIPT_BATCH_WHERE := NULL;
    ELSIF var.p_receipt_batch_low is NULL THEN
       RECEIPT_BATCH_WHERE := ' AND RBFIRST.NAME  <= :p_receipt_batch_high';
    ELSIF var.p_receipt_batch_high is NULL THEN
       RECEIPT_BATCH_WHERE := ' AND RBFIRST.NAME  >= :p_receipt_batch_low';
    ELSE
       RECEIPT_BATCH_WHERE := ' AND RBFIRST.NAME BETWEEN :p_receipt_batch_low and :p_receipt_batch_high';
    END IF;

-- RECEIPT_NUMBER where clause
    IF var.p_receipt_number_low IS NULL and var.p_receipt_number_high IS NULL THEN
       RECEIPT_NUMBER_WHERE := NULL;
    ELSIF var.p_receipt_number_low is NULL THEN
       RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER  <= :p_receipt_number_high';
    ELSIF var.p_receipt_number_high is NULL THEN
       RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER  >= :p_receipt_number_low';
    ELSE
       RECEIPT_NUMBER_WHERE := ' AND CR.RECEIPT_NUMBER BETWEEN :p_receipt_number_low and :p_receipt_number_high';
    END IF;

-- APP_TYPE where clause
    IF var.p_app_type IS NULL THEN
       APP_TYPE_WHERE := NULL;
    ELSE
       APP_TYPE_WHERE := ' AND PS.TRX_NUMBER = :p_app_type';
    END IF;

-- DECODE/LONG statements
    ACCT_FLEX := 'FA_RX_FLEX_PKG.GET_VALUE(101,''GL#'',GLS.CHART_OF_ACCOUNTS_ID, ''ALL'',APP.CODE_COMBINATION_ID) ACCOUNTING_FLEX_FIELD ';
    DECODE_ACT_NAME := 'DECODE(SIGN(APP.APPLIED_PAYMENT_SCHEDULE_ID), -1, ' ||
                       ' arpt_sql_func_util.get_rec_trx_type(app.receivables_trx_id,''NAME''),NULL)';
    DECODE_REF_TYPE := 'arpt_sql_func_util.get_lookup_meaning(DECODE(APP.APPLIED_PAYMENT_SCHEDULE_ID, -7, ''AR_PREPAYMENT_TYPE'', ' ||
                       ' ''APPLICATION_REF_TYPE''), APP.APPLICATION_REF_TYPE) ';
    DECODE_CURRENCY := 'DECODE(:P_ENTERED_CURRENCY,NULL,:P_FUNCTIONAL_CURRENCY,CR.CURRENCY_CODE)';

--  Assign SELECT list
-- sequence, select, field in itf, into, type, len
    fa_rx_util_pkg.debug('ARTX_ASSIGN_SELECT_LIST');

    fa_rx_util_pkg.assign_column('10',NULL,'ORGANIZATION_NAME',
                                 'arrx_oth.var.organization_name','VARCHAR2',50);
    fa_rx_util_pkg.assign_column('20',NULL,'FUNCTIONAL_CURRENCY_CODE',
                                 'arrx_oth.var.functional_currency_code','VARCHAR2',15);
    fa_rx_util_pkg.assign_column('30',ACCT_FLEX,'ACCOUNTING_FLEXFIELD',
                                 'arrx_oth.var.accounting_flexfield','VARCHAR2',4000);
    fa_rx_util_pkg.assign_column('40','glc.code_combination_id','ACCOUNT_CODE_COMBINATION_ID',
                                 'arrx_oth.var.code_combination_id','NUMBER');
    fa_rx_util_pkg.assign_column('50','AB.BANK_ACCOUNT_NUM','ACCOUNT_NUMBER',
                                 'arrx_oth.var.bank_account_number','VARCHAR2',30);
    fa_rx_util_pkg.assign_column('60','APP.ACCTD_AMOUNT_APPLIED_FROM','ACCTD_AMOUNT_APPLIED_FROM',
                                 'arrx_oth.var.acctd_amount_applied_from','NUMBER');
    fa_rx_util_pkg.assign_column('70','APP.ACCTD_AMOUNT_APPLIED_TO','ACCTD_AMOUNT_APPLIED_TO',
                                 'arrx_oth.var.acctd_amount_applied_to','NUMBER');
    fa_rx_util_pkg.assign_column('80',DECODE_ACT_NAME ,'ACTIVITY_NAME',
                                 'arrx_oth.var.activity_name','VARCHAR2',50);
    fa_rx_util_pkg.assign_column('90','APP.AMOUNT_APPLIED','AMOUNT_APPLIED',
                                 'arrx_oth.var.amount_applied','NUMBER');
    fa_rx_util_pkg.assign_column('100','APP.APPLICATION_REF_NUM','APPLICATION_REF_NUMBER',
                                 'arrx_oth.var.application_ref_num','VARCHAR2',30);
    fa_rx_util_pkg.assign_column('110',DECODE_REF_TYPE,'APPLICATION_REF_TYPE',
                                 'arrx_oth.var.application_ref_type','VARCHAR2',80);
    fa_rx_util_pkg.assign_column('120','APP.STATUS','APPLICATION_STATUS',
                                 'arrx_oth.var.application_status','VARCHAR2',20);
    fa_rx_util_pkg.assign_column('130','APP.APPLY_DATE','APPLY_DATE',
                                 'arrx_oth.var.apply_date','DATE');
    fa_rx_util_pkg.assign_column('140', 'RBFIRST.BATCH_ID','BATCH_ID',
                                 'arrx_oth.var.batch_id','NUMBER');
    fa_rx_util_pkg.assign_column('150','RBFIRST.NAME','BATCH_NAME',
                                 'arrx_oth.var.batch_name','VARCHAR2',20);
    fa_rx_util_pkg.assign_column('160','BSFIRST.NAME','BATCH_SOURCE',
                                 'arrx_oth.var.batch_source','VARCHAR2',50);
    fa_rx_util_pkg.assign_column('170','CR.CASH_RECEIPT_ID','CASH_RECEIPT_ID',
                                 'arrx_oth.var.cash_receipt_id','NUMBER');
    fa_rx_util_pkg.assign_column('180' ,'SUBSTRB(PARTY.PARTY_NAME,1,50)','CUSTOMER_NAME',
                                 'arrx_oth.var.customer_name','VARCHAR2',50);
    fa_rx_util_pkg.assign_column('190','CUST.ACCOUNT_NUMBER','CUSTOMER_NUMBER',
                                 'arrx_oth.var.customer_number','VARCHAR2',30);
    fa_rx_util_pkg.assign_column('200',null,'DEBIT_BALANCING',
                                 'arrx_oth.var.debit_balancing','VARCHAR2',240);
    fa_rx_util_pkg.assign_column('210',DECODE_CURRENCY,'FORMAT_CURRENCY_CODE',
                                 'arrx_oth.var.format_currency_code','VARCHAR2',15);
    fa_rx_util_pkg.assign_column('220','APP.GL_DATE','GL_DATE',
                                 'arrx_oth.var.gl_date','DATE');
    fa_rx_util_pkg.assign_column('230','CR.CURRENCY_CODE','RECEIPT_CURRENCY_CODE',
                                 'arrx_oth.var.receipt_currency_code','VARCHAR2',15);
    fa_rx_util_pkg.assign_column('240','CR.RECEIPT_DATE','RECEIPT_DATE',
                                 'arrx_oth.var.receipt_date','DATE');
    fa_rx_util_pkg.assign_column('250','CR.RECEIPT_NUMBER','RECEIPT_NUMBER',
                                 'arrx_oth.var.receipt_number','VARCHAR2',30);
    fa_rx_util_pkg.assign_column('260','CR.STATUS','RECEIPT_STATUS',
                                 'arrx_oth.var.receipt_status','VARCHAR2',40);
    fa_rx_util_pkg.assign_column('270','CR.TYPE','RECEIPT_TYPE',
                                 'arrx_oth.var.receipt_type','VARCHAR2',30);
    fa_rx_util_pkg.assign_column('275','CR.AMOUNT','RECEIPT_AMOUNT',
                                 'arrx_oth.var.receipt_amount','NUMBER');
    fa_rx_util_pkg.assign_column('280','RB.NAME','REMIT_BATCH_NAME',
                                 'arrx_oth.var.remit_batch_name','VARCHAR2',20);

-- Assign  FROM clause

fa_rx_util_pkg.debug('Assign FROM Clause using ALL tables');
fa_rx_util_pkg.from_clause := ' AR_RECEIVABLE_APPLICATIONS_ALL APP
                              , AR_CASH_RECEIPTS_ALL CR
                              , AR_CASH_RECEIPT_HISTORY_ALL CRH
                              , AR_PAYMENT_SCHEDULES_ALL PS
                              , HZ_CUST_ACCOUNTS_ALL CUST
                              , HZ_PARTIES PARTY
                              , AR_BATCH_SOURCES_ALL BS
                              , AR_BATCHES_ALL RB
                              , GL_SETS_OF_BOOKS GLS
                              , GL_CODE_COMBINATIONS GLC
--                              , AP_BANK_ACCOUNTS_ALL AB
--                              , AP_BANK_BRANCHES BB
			      , CE_BANK_ACCOUNTS AB
			      , CE_BANK_ACCT_USES CBA
			      , CE_BANK_BRANCHES_V BB
                              , AR_BATCHES_ALL RBFIRST
                              , AR_CASH_RECEIPT_HISTORY_ALL CRHFIRST
                              , AR_BATCH_SOURCES_ALL BSFIRST';

-- Assign WHERE clause
fa_rx_util_pkg.debug('AR_ASSIGN_WHERE_CLAUSE');
fa_rx_util_pkg.where_clause := '
        APP.CASH_RECEIPT_ID             = CR.CASH_RECEIPT_ID
    AND APP.CASH_RECEIPT_ID             = CRH.CASH_RECEIPT_ID
    AND APP.APPLIED_PAYMENT_SCHEDULE_ID = PS.PAYMENT_SCHEDULE_ID
    AND CRH.CURRENT_RECORD_FLAG         = ''Y''
    AND APP.STATUS                      IN (''ACTIVITY'',''OTHER ACC'')
    AND APP.AMOUNT_APPLIED              <> 0
    AND APP.DISPLAY                     = ''Y''
    AND BS.BATCH_SOURCE_ID (+)          = RB.BATCH_SOURCE_ID
    AND RB.BATCH_ID (+)                 = CR.SELECTED_REMITTANCE_BATCH_ID
--    AND AB.BANK_ACCOUNT_ID (+)          = CR.REMITTANCE_BANK_ACCOUNT_ID
    AND CBA.BANK_ACCT_USE_ID(+)		= CR.REMIT_BANK_ACCT_USE_ID
    AND CBA.BANK_ACCOUNT_ID 		= AB.BANK_ACCOUNT_ID
    AND BB.BRANCH_PARTY_ID              = AB.BANK_BRANCH_ID
    AND CUST.CUST_ACCOUNT_ID(+)         = CR.PAY_FROM_CUSTOMER
    AND CUST.PARTY_ID                   = PARTY.PARTY_ID(+)
    AND GLS.SET_OF_BOOKS_ID             = CR.SET_OF_BOOKS_ID
    AND GLC.CODE_COMBINATION_ID(+)      = APP.CODE_COMBINATION_ID
    AND CR.CASH_RECEIPT_ID              = CRHFIRST.CASH_RECEIPT_ID
    AND CRHFIRST.FIRST_POSTED_RECORD_FLAG = ''Y''
    AND CRHFIRST.BATCH_ID               = RBFIRST.BATCH_ID(+)
    AND BSFIRST.BATCH_SOURCE_ID(+)      = RBFIRST.BATCH_SOURCE_ID ' ||
    CO_SEG_WHERE          || ' ' ||
    GL_DATE_WHERE         || ' ' ||
    CURRENCY_CODE_WHERE   || ' ' ||
    CUSTOMER_NAME_WHERE   || ' ' ||
    CUSTOMER_NUMBER_WHERE || ' ' ||
    RECEIPT_DATE_WHERE    || ' ' ||
    APPLY_DATE_WHERE      || ' ' ||
    REMIT_BATCH_WHERE     || ' ' ||
    RECEIPT_BATCH_WHERE   || ' ' ||
    RECEIPT_NUMBER_WHERE  || ' ' ||
    APP_TYPE_WHERE        || ' ' ||
    L_APP_ORG_WHERE       || ' ' ||
    L_CR_ORG_WHERE        || ' ' ||
    L_CRH_ORG_WHERE       || ' ' ||
--    L_PS_ORG_WHERE        || ' ' ||
    L_CUST_ORG_WHERE      || ' ' ||
    L_BS_ORG_WHERE        || ' ' ||
    L_RB_ORG_WHERE        || ' ' ||
    L_AB_ORG_WHERE        || ' ' ||
    L_BSFIRST_ORG_WHERE   || ' ' ||
    L_CRHFIRST_ORG_WHERE  || ' ' ||
    L_RBFIRST_ORG_WHERE;

fa_rx_util_pkg.debug('arrx_oth.adj_before_report()-');

end before_report;

--
-- Bind trigger for main Other Receipt Applications Report
--

procedure bind (c in integer)
is

begin
	fa_rx_util_pkg.debug('AR_GET_BIND');
--
-- Binding vars that appear in SELECT statement depending on input params
--
        IF var.p_reporting_level = 3000 THEN
           IF var.p_reporting_entity_id IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_reporting_entity_id', var.p_reporting_entity_id);
           END IF;
        END IF;

        IF var.p_currency_code IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_currency_code', var.p_currency_code);
        END IF;

	IF var.p_gl_date_low IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_gl_date_low', var.p_gl_date_low);
   	END IF;

	IF var.p_gl_date_high IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_gl_date_high', var.p_gl_date_high);
   	END IF;

        IF var.p_customer_name_low IS NOT NULL THEN
               dbms_sql.bind_variable(c, 'p_customer_name_low', var.p_customer_name_low);
        END IF;

        IF var.p_customer_name_high IS NOT NULL THEN
               dbms_sql.bind_variable(c, 'p_customer_name_high', var.p_customer_name_high);
        END IF;

        IF var.p_customer_number_low IS NOT NULL THEN
               dbms_sql.bind_variable(c, 'p_customer_number_low', var.p_customer_number_low);
        END IF;

        IF var.p_customer_number_high IS NOT NULL THEN
               dbms_sql.bind_variable(c, 'p_customer_number_high', var.p_customer_number_high);
        END IF;

        IF var.p_receipt_date_low IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_receipt_date_low', var.p_receipt_date_low);
        END IF;

        IF var.p_receipt_date_high IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_receipt_date_high', var.p_receipt_date_high);
        END IF;

        IF var.p_apply_date_low IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_apply_date_low', var.p_apply_date_low);
        END IF;

        IF var.p_apply_date_high IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_apply_date_high', var.p_apply_date_high);
        END IF;

        IF var.p_remit_batch_low IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_remit_batch_low', var.p_remit_batch_low);
        END IF;

        IF var.p_remit_batch_high IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_remit_batch_high', var.p_remit_batch_high);
        END IF;

        IF var.p_receipt_batch_low IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_receipt_batch_low', var.p_receipt_batch_low);
        END IF;

        IF var.p_receipt_batch_high IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_receipt_batch_high', var.p_receipt_batch_high);
        END IF;

        IF var.p_receipt_number_low IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_receipt_number_low', var.p_receipt_number_low);
        END IF;

        IF var.p_receipt_number_high IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_receipt_number_high', var.p_receipt_number_high);
        END IF;

        IF var.p_app_type IS NOT NULL THEN
              dbms_sql.bind_variable(c, 'p_app_type', var.p_app_type);
        END IF;

        dbms_sql.bind_variable(c, 'P_ENTERED_CURRENCY',var.p_currency_code);
        dbms_sql.bind_variable(c, 'P_FUNCTIONAL_CURRENCY',var.functional_currency_code);

end bind;

--
-- After Fetch trigger
--

procedure after_fetch
is
begin

--
-- Assign acount data
--

   var.debit_balancing :=     fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_ccid => var.code_combination_id);

--

end after_fetch;

end ARRX_OTH;

/
