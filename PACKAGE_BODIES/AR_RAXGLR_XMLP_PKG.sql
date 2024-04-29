--------------------------------------------------------
--  DDL for Package Body AR_RAXGLR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXGLR_XMLP_PKG" AS
/* $Header: RAXGLRB.pls 120.1 2008/01/07 14:52:50 abraghun noship $ */
 function BeforeReport return boolean is
/*Added for value retriving for bug 4327441*/
l_ld_sp varchar2(1);
begin

--SRW.USER_EXIT('FND SRWINIT');

/*Following section is added to print message for user for bug 4327441*/
rp_message:=null;
IF to_number(p_reporting_level) = 1000 THEN
l_ld_sp:= mo_utils.check_ledger_in_sp(TO_NUMBER(p_reporting_entity_id));

IF l_ld_sp = 'N' THEN
     FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
     rp_message := FND_MESSAGE.get;
END IF;
END IF;
/*End bug 4327441*/
/* For Bug:4942083 - To display a notification that the report will not
include transaction for which accounting has not been run */
FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
cp_acc_message := FND_MESSAGE.get;
/* Changes for Bug:4942083 ends */


DECLARE


BEGIN



	IF (p_currency_code IS NOT NULL ) THEN
		p_where_1 := '	AND trx.invoice_currency_code = ''' || p_currency_code || '''';
		p_select_1 := ' sum(decode(sign(gl_dist.amount),
                  				 1, round(gl_dist.amount, 2), NULL)) curr_credit_amount,
        			 sum(decode(sign(gl_dist.amount),
                   				-1, -round(gl_dist.amount, 2), NULL)) curr_debit_amount ' ;

	END IF;

	IF	(p_gl_account_type = 'TAX' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''TAX'' ';

	ELSIF	(p_gl_account_type = 'UNBILL' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''UNBILL'' ';

	ELSIF	(p_gl_account_type = 'UNEARN' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''UNEARN'' ';

	ELSIF	(p_gl_account_type = 'SUSPENSE' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''SUSPENSE'' ';

	ELSIF	(p_gl_account_type = 'FREIGHT' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''FREIGHT'' ';

	ELSIF	(p_gl_account_type = 'REV' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''REV'' ';

	ELSIF	(p_gl_account_type = 'REC' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''REC'' ';

        ELSIF   (p_gl_account_type = 'CHARGES' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''CHARGES'' ';
/* Bug No 1890366 */
	ELSIF   (p_gl_account_type = 'ROUND' ) THEN
			p_where_gl_type := 'AND LOOKUP_CODE = ''ROUND'' ';

	ELSIF	(p_gl_account_type is NULL) THEN
			p_where_gl_type := 'AND LOOKUP_CODE in (''REV'',''UNEARN'',''UNBILL'',''SUSPENSE'',''TAX'',''REC'', ''FREIGHT'', ''CHARGES'',  ''ROUND'')';
	END IF;



--SRW.REFERENCE(:p_coaid);
if p_coaid is null
then

   select chart_of_accounts_id
     into p_coaid
     from  ar_system_parameters,
           gl_sets_of_books
    where ar_system_parameters.set_of_books_id =
          gl_sets_of_books.set_of_books_id;

end if;

/*SRW.USER_EXIT('FND FLEXSQL
                   CODE="GL#"
                   NUM=":p_coaid"
                   APPL_SHORT_NAME="SQLGL"
                   TABLEALIAS="gl"
                   OUTPUT=":WHERE_GL_FLEX_CLAUSE"
                   MODE="WHERE"
                   DISPLAY="ALL"
		   OPERATOR="BETWEEN"
		   OPERAND1=":p_min_gl_flex"
                   OPERAND2=":p_max_gl_flex"');*/null;



/* Modification made for to report on consolidated billing # rreichen Nov 96 */

begin

    --SRW.message ('101', 'Consolidated Billing Profile');
    null;

    P_CONS_PROFILE_VALUE := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);
    -- null will be replaced by org_id, for x-ross org context

    --SRW.message ('101', 'Consolidated Billing Profile:  ' || :P_CONS_PROFILE_VALUE);

exception
     when others then
          --SRW.message ('101', 'BeforeReport:  Consolidated Billing Profile:  Failed.');
	  null;
end;


If    ( P_CONS_PROFILE_VALUE = 'N' ) then
      lp_query_show_bill        := 'to_char(NULL)';
      lp_table_show_bill        := '  ';
      lp_where_show_bill        := '  ';
      P_ORG_WHERE_CI            := '  ';
      P_ORG_WHERE_PS            := '  ';
Else

 lp_query_show_bill     := 'ci.cons_billing_number';
 P_ORG_WHERE_CI         := XLA_MO_REPORTING_API.Get_Predicate('CI', null);
 P_ORG_WHERE_PS         := XLA_MO_REPORTING_API.Get_Predicate('PS', null);

 IF (upper(p_mrcsobtype) = 'R') THEN
      lp_table_show_bill        := 'ar_payment_schedules_all_mrc_v ps,ar_cons_inv_all ci,';
      lp_where_show_bill        := 'and trx.customer_trx_id = ps.customer_trx_id(+)
		and nvl(ps.due_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) = (
 		select nvl(min(x.due_date), TO_DATE(''01/01/0001'',''MM/DD/YYYY''))
   		from ar_payment_schedules_all_mrc_v x
    		 where x.customer_trx_id = ps.customer_trx_id)
 			and ps.cons_inv_id = ci.cons_inv_id(+)';
 ELSE
      lp_table_show_bill        := 'ar_payment_schedules_all ps,ar_cons_inv_all ci,';
      lp_where_show_bill        := 'and trx.customer_trx_id = ps.customer_trx_id(+)
		and nvl(ps.due_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) = (
 		select nvl(min(x.due_date), TO_DATE(''01/01/0001'',''MM/DD/YYYY''))
   		from ar_payment_schedules_all x
    		 where x.customer_trx_id = ps.customer_trx_id)
 			and ps.cons_inv_id = ci.cons_inv_id(+)';
 END IF;

End if;
/* End of Modification */

END;
  return (TRUE);
end;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(240);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := 'Sales Journal By GL Account';
        RETURN ('Sales Journal By GL Account');
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION REPORT_SUBTITLEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RP_REPORT_SUBTITLE := NVL(TO_CHAR(P_START_GL_DATE
                                     ,'DD-MON-YYYY')
                             ,'     ') || ' - ' || NVL(TO_CHAR(P_END_GL_DATE
                                     ,'DD-MON-YYYY')
                             ,'     ');
    RETURN NULL;
  END REPORT_SUBTITLEFORMULA;

  FUNCTION C_SUM_TEXTFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GL_ACCOUNT_TYPE IS NULL THEN
      RETURN ('Subtotal by Invoice Currency : ');
    ELSE
      RETURN ('Totals : ');
    END IF;
    RETURN NULL;
  END C_SUM_TEXTFORMULA;

  FUNCTION SET_CURR_CODE_REVFORMULA(CURRENCY_CODE_REV IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(CURRENCY_CODE_REV)*/NULL;
      C_CURR_CODE_REV := CURRENCY_CODE_REV;
      RETURN (CURRENCY_CODE_REV);
    END;
    RETURN NULL;
  END SET_CURR_CODE_REVFORMULA;

  FUNCTION SET_CURR_CODE_TAXFORMULA(CURRENCY_CODE_TAX IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(CURRENCY_CODE_TAX)*/NULL;
      C_CURR_CODE_TAX := CURRENCY_CODE_TAX;
      RETURN (CURRENCY_CODE_TAX);
    END;
    RETURN NULL;
  END SET_CURR_CODE_TAXFORMULA;

  FUNCTION SET_CURR_CODE_RECFORMULA(CURRENCY_CODE_REC IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(CURRENCY_CODE_REC)*/NULL;
      C_CURR_CODE_REC := CURRENCY_CODE_REC;
      RETURN (CURRENCY_CODE_REC);
    END;
    RETURN NULL;
  END SET_CURR_CODE_RECFORMULA;

  FUNCTION TRX_NUMBER_CONSFORMULA(TRX_NUMBER IN VARCHAR2
                                 ,CONS_BILLING_NUMBER IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(TRX_NUMBER)*/NULL;
    /*SRW.REFERENCE(CONS_BILLING_NUMBER)*/NULL;
    IF (P_CONS_PROFILE_VALUE = 'N') THEN
      RETURN (SUBSTR(TRX_NUMBER
                   ,1
                   ,40));
    ELSIF (P_CONS_PROFILE_VALUE = 'Y') AND (CONS_BILLING_NUMBER IS NULL) THEN
      RETURN (SUBSTR(TRX_NUMBER
                   ,1
                   ,40));
    ELSE
      RETURN (SUBSTR(SUBSTR(TRX_NUMBER
                          ,1
                          ,NVL(LENGTH(TRX_NUMBER)
                             ,0)) || '/' || CONS_BILLING_NUMBER
                   ,1
                   ,40));
    END IF;
    RETURN NULL;
  END TRX_NUMBER_CONSFORMULA;

  FUNCTION TRX_NUMBER_TAX_CONSFORMULA(TRX_NUMBER_TAX IN VARCHAR2
                                     ,CONS_BILLING_NUMBER_TAX IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(TRX_NUMBER_TAX)*/NULL;
    /*SRW.REFERENCE(CONS_BILLING_NUMBER_TAX)*/NULL;
    IF (P_CONS_PROFILE_VALUE = 'N') THEN
      RETURN (SUBSTR(TRX_NUMBER_TAX
                   ,1
                   ,40));
    ELSIF (P_CONS_PROFILE_VALUE = 'Y') AND (CONS_BILLING_NUMBER_TAX IS NULL) THEN
      RETURN (SUBSTR(TRX_NUMBER_TAX
                   ,1
                   ,40));
    ELSE
      RETURN (SUBSTR(SUBSTR(TRX_NUMBER_TAX
                          ,1
                          ,NVL(LENGTH(TRX_NUMBER_TAX)
                             ,0)) || '/' || CONS_BILLING_NUMBER_TAX
                   ,1
                   ,40));
    END IF;
    RETURN NULL;
  END TRX_NUMBER_TAX_CONSFORMULA;

  FUNCTION TRX_NUMBER_REC_CONSFORMULA(TRX_NUMBER_REC IN VARCHAR2
                                     ,CONS_BILLING_NUMBER_REC IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(TRX_NUMBER_REC)*/NULL;
    /*SRW.REFERENCE(CONS_BILLING_NUMBER_REC)*/NULL;
    IF (P_CONS_PROFILE_VALUE = 'N') THEN
      RETURN (SUBSTR(TRX_NUMBER_REC
                   ,1
                   ,40));
    ELSIF (P_CONS_PROFILE_VALUE = 'Y') AND (CONS_BILLING_NUMBER_REC IS NULL) THEN
      RETURN (SUBSTR(TRX_NUMBER_REC
                   ,1
                   ,40));
    ELSE
      RETURN (SUBSTR(SUBSTR(TRX_NUMBER_REC
                          ,1
                          ,NVL(LENGTH(TRX_NUMBER_REC)
                             ,0)) || '/' || CONS_BILLING_NUMBER_REC
                   ,1
                   ,40));
    END IF;
    RETURN NULL;
  END TRX_NUMBER_REC_CONSFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_MRCSOBTYPE := 'P';
    LP_AR_SYSTEM_PARAMETERS := 'AR_SYSTEM_PARAMETERS';
    LP_AR_SYSTEM_PARAMETERS_ALL := 'AR_SYSTEM_PARAMETERS_ALL';
    LP_AR_PAYMENT_SCHEDULES := 'AR_PAYMENT_SCHEDULES';
    LP_AR_PAYMENT_SCHEDULES_ALL := 'AR_PAYMENT_SCHEDULES_ALL';
    LP_AR_ADJUSTMENTS := 'AR_ADJUSTMENTS';
    LP_AR_ADJUSTMENTS_ALL := 'AR_ADJUSTMENTS_ALL';
    LP_AR_CASH_RECEIPT_HISTORY := 'AR_CASH_RECEIPT_HISTORY';
    LP_AR_CASH_RECEIPT_HISTORY_ALL := 'AR_CASH_RECEIPT_HISTORY_ALL';
    LP_AR_BATCHES := 'AR_BATCHES';
    LP_AR_BATCHES_ALL := 'AR_BATCHES_ALL';
    LP_AR_CASH_RECEIPTS := 'AR_CASH_RECEIPTS';
    LP_AR_CASH_RECEIPTS_ALL := 'AR_CASH_RECEIPTS_ALL';
    LP_AR_DISTRIBUTIONS := 'AR_XLA_ARD_LINES_V';
    LP_AR_DISTRIBUTIONS_ALL := 'AR_XLA_ARD_LINES_V';
    LP_RA_CUSTOMER_TRX := 'RA_CUSTOMER_TRX';
    LP_RA_CUSTOMER_TRX_ALL := 'RA_CUSTOMER_TRX_ALL';
    LP_RA_BATCHES := 'RA_BATCHES';
    LP_RA_BATCHES_ALL := 'RA_BATCHES_ALL';
    LP_RA_CUST_TRX_GL_DIST := 'AR_XLA_CTLGD_LINES_V';
    LP_RA_CUST_TRX_GL_DIST_ALL := 'AR_XLA_CTLGD_LINES_V';
    LP_AR_MISC_CASH_DISTS := 'AR_MISC_CASH_DISTRIBUTIONS';
    LP_AR_MISC_CASH_DISTS_ALL := 'AR_MISC_CASH_DISTRIBUTIONS_ALL';
    LP_AR_RATE_ADJUSTMENTS := 'AR_RATE_ADJUSTMENTS';
    LP_AR_RATE_ADJUSTMENTS_ALL := 'AR_RATE_ADJUSTMENTS_ALL';
    LP_AR_RECEIVABLE_APPS := 'AR_RECEIVABLE_APPLICATIONS';
    LP_AR_RECEIVABLE_APPS_ALL := 'AR_RECEIVABLE_APPLICATIONS_ALL';
    XLA_MO_REPORTING_API.INITIALIZE(P_REPORTING_LEVEL
                                   ,P_REPORTING_ENTITY_ID
                                   ,'AUTO');
    P_REPORTING_ENTITY_NAME := SUBSTRB(XLA_MO_REPORTING_API.GET_REPORTING_ENTITY_NAME
                                      ,1
                                      ,200);
    P_REPORTING_LEVEL_NAME := SUBSTRB(XLA_MO_REPORTING_API.GET_REPORTING_LEVEL_NAME
                                     ,1
                                     ,30);
    P_ORG_WHERE_CUST_ACCT := XLA_MO_REPORTING_API.GET_PREDICATE('CUST_ACCT'
                                                               ,NULL);
    P_ORG_WHERE_TRX := XLA_MO_REPORTING_API.GET_PREDICATE('TRX'
                                                         ,NULL);
    P_ORG_WHERE_GL_DIST := XLA_MO_REPORTING_API.GET_PREDICATE('GL_DIST'
                                                             ,NULL);
    IF P_START_GL_DATE IS NOT NULL THEN
      LP_START_GL_DATE := 'and gl_dist.gl_date >= :p_start_gl_date ';
    END IF;
    IF P_END_GL_DATE IS NOT NULL THEN
      LP_END_GL_DATE := 'and gl_dist.gl_date <= :p_end_gl_date ';
    END IF;
    IF P_TRX_DATE_LOW IS NOT NULL THEN
      LP_TRX_DATE_LOW := ' and trx.trx_date >= :p_trx_date_low ';
    END IF;
    IF P_TRX_DATE_HIGH IS NOT NULL THEN
      LP_TRX_DATE_HIGH := ' and trx.trx_date <= :p_trx_date_high ';
    END IF;
    IF (P_TRX_TYPE_LOW IS NOT NULL) THEN
      LP_TRX_TYPE_LOW := 'and arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') >=  :p_trx_type_low ';
    END IF;
    IF (P_TRX_TYPE_HIGH IS NOT NULL) THEN
      LP_TRX_TYPE_HIGH := 'and arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') <= :p_trx_type_high ';
    END IF;
    IF (P_TRX_NUMBER_LOW IS NOT NULL) THEN
      LP_TRX_NUMBER_LOW := 'and trx.trx_number >= :p_trx_number_low ';
    END IF;
    IF (P_TRX_NUMBER_HIGH IS NOT NULL) THEN
      LP_TRX_NUMBER_HIGH := 'and trx.trx_number <= :p_trx_number_high ';
    END IF;
    IF (P_CUSTOMER_LOW IS NOT NULL) THEN
      LP_CUSTOMER_LOW := 'and party.party_name >=  :p_customer_low ';
    END IF;
    IF (P_CUSTOMER_HIGH IS NOT NULL) THEN
      LP_CUSTOMER_HIGH := 'and party.party_name <=  :p_customer_high ';
    END IF;
    IF (P_CUSTOMER_NUMBER_LOW IS NOT NULL) THEN
      LP_CUSTOMER_NUMBER_LOW := 'and cust_acct.account_number >= :p_customer_number_low ';
    END IF;
    IF (P_CUSTOMER_NUMBER_HIGH IS NOT NULL) THEN
      LP_CUSTOMER_NUMBER_HIGH := 'and cust_acct.account_number <= :p_customer_number_high ';
    END IF;
    IF (P_ZERO_ROUND = 'Y') THEN
      LP_ZERO_ROUND := ' and (gl_dist.account_class <> ''ROUND''  OR  ' || ' (gl_dist.account_class  = ''ROUND'' and gl_dist.acctd_amount <> 0)) ';
    ELSE
      LP_ZERO_ROUND := NULL;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_GL_ACCOUNT_TYPE_MEANINGFORMU RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ACCT_MEANING VARCHAR2(200);
    BEGIN
      ACCT_MEANING := '';
      IF (P_GL_ACCOUNT_TYPE IS NOT NULL) THEN
        SELECT
          MEANING
        INTO ACCT_MEANING
        FROM
          AR_LOOKUPS
        WHERE LOOKUP_TYPE = 'AUTOGL_TYPE'
          AND LOOKUP_CODE = P_GL_ACCOUNT_TYPE;
      END IF;
      RETURN (ACCT_MEANING);
    END;
    RETURN NULL;
  END C_GL_ACCOUNT_TYPE_MEANINGFORMU;

  FUNCTION C_ORDER_BY_MEANINGFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_MEANING VARCHAR2(200);
    BEGIN
      ORDER_MEANING := '';
      IF (P_SORT_BY IS NOT NULL) THEN
        SELECT
          MEANING
        INTO ORDER_MEANING
        FROM
          AR_LOOKUPS
        WHERE LOOKUP_TYPE = 'SORT_BY_RAXGLR'
          AND LOOKUP_CODE = P_SORT_BY;
      END IF;
      RETURN (ORDER_MEANING);
    END;
    RETURN NULL;
  END C_ORDER_BY_MEANINGFORMULA;

  FUNCTION C_POSTING_STATUS_MEANINGFORMUL RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      STATUS_MEANING VARCHAR2(200);
    BEGIN
      STATUS_MEANING := '';
      SELECT
        MEANING
      INTO STATUS_MEANING
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'POSTING_STATUS'
        AND LOOKUP_CODE = NVL(P_POSTING_STATUS
         ,'ALL');
      RETURN (STATUS_MEANING);
    END;
    RETURN NULL;
  END C_POSTING_STATUS_MEANINGFORMUL;

  FUNCTION ACCT_BAL_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_BAL_APROMPT;
  END ACCT_BAL_APROMPT_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION F_REPORTING_ENTITY_p RETURN VARCHAR2 IS
  l_code    varchar2(30);
  BEGIN
  select lookup_code
     into l_code
     from fnd_lookups
    where meaning = p_reporting_level_name
      and lookup_type = 'XLA_MO_REPORTING_LEVEL' ;

  if l_code = '3000' then
     return (P_REPORTING_ENTITY_NAME);
     else
     return (' ');
     end if;
  END F_REPORTING_ENTITY_p;


  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_SUBTITLE;
  END RP_REPORT_SUBTITLE_P;

  FUNCTION GSUM_FUNC_CR_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN GSUM_FUNC_CR_AMT;
  END GSUM_FUNC_CR_AMT_P;

  FUNCTION GSUM_FUNC_DR_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN GSUM_FUNC_DR_AMT;
  END GSUM_FUNC_DR_AMT_P;

  FUNCTION GSUM_CURR_CR_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN GSUM_CURR_CR_AMT;
  END GSUM_CURR_CR_AMT_P;

  FUNCTION GSUM_CURR_DR_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN GSUM_CURR_DR_AMT;
  END GSUM_CURR_DR_AMT_P;

  FUNCTION C_CURR_CODE_REV_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURR_CODE_REV;
  END C_CURR_CODE_REV_P;

  FUNCTION C_CURR_CODE_TAX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURR_CODE_TAX;
  END C_CURR_CODE_TAX_P;

  FUNCTION C_CURR_CODE_REC_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURR_CODE_REC;
  END C_CURR_CODE_REC_P;

  FUNCTION GSUM_FUNC_CREDIT_AMT_P RETURN NUMBER IS
  BEGIN
    RETURN GSUM_FUNC_CREDIT_AMT;
  END GSUM_FUNC_CREDIT_AMT_P;

  FUNCTION GSUM_FUNC_DEBIT_AMT_P RETURN NUMBER IS
  BEGIN
    RETURN GSUM_FUNC_DEBIT_AMT;
  END GSUM_FUNC_DEBIT_AMT_P;

  FUNCTION GSUM_CURR_CREDIT_AMT_P RETURN NUMBER IS
  BEGIN
    RETURN GSUM_CURR_CREDIT_AMT;
  END GSUM_CURR_CREDIT_AMT_P;

  FUNCTION GSUM_CURR_DEBIT_AMT_P RETURN NUMBER IS
  BEGIN
    RETURN GSUM_CURR_DEBIT_AMT;
  END GSUM_CURR_DEBIT_AMT_P;

  FUNCTION RP_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
  if arp_util.open_period_exists(p_reporting_level,p_reporting_entity_id,p_start_gl_date,p_end_gl_date) then
    RETURN RP_MESSAGE;
else
   return ' ';
   end if;
  END RP_MESSAGE_P;

  FUNCTION CP_ACC_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACC_MESSAGE;
  END CP_ACC_MESSAGE_P;

END AR_RAXGLR_XMLP_PKG;


/
