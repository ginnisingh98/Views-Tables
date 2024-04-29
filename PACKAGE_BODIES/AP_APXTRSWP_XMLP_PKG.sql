--------------------------------------------------------
--  DDL for Package Body AP_APXTRSWP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXTRSWP_XMLP_PKG" AS
/* $Header: APXTRSWPB.pls 120.0 2007/12/27 08:41:34 vjaganat noship $ */

USER_EXIT_FAILURE EXCEPTION;

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   cash_acct_flag VARCHAR2(1);
  prec      fnd_currencies.precision%TYPE;       min_au    fnd_currencies.minimum_accountable_unit%TYPE;  descr     fnd_currencies.description%TYPE;
BEGIN

  base_curr := '';
  cash_acct_flag := 'N';
  prec      := 0;
  min_au    := 0;
  descr     := '';


begin
  SELECT nvl(sob.sla_ledger_cash_basis_flag, 'N')
  INTO   cash_acct_flag
  FROM   gl_sets_of_books     sob
  WHERE  sob.set_of_books_id = p_set_of_books_id;
exception
   when no_data_found then
      null;
   when others then
      null;

end;

  C_BASE_CURRENCY_CODE  := base_curr;
  C_BASE_PRECISION      := prec;
  C_BASE_MIN_ACCT_UNIT  := min_au;
  C_BASE_DESCRIPTION    := descr;

  IF (cash_acct_flag = 'Y') THEN
     P_ACCT_METHOD := 'C';
  ELSE
     P_ACCT_METHOD := 'A';
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  custom_init         RETURN BOOLEAN IS

BEGIN


RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_void      ap_lookup_codes.displayed_field%TYPE;    nls_na        ap_lookup_codes.displayed_field%TYPE;    nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN

   SELECT  ly.meaning,
           ln.meaning,
           l1.displayed_field,
           l2.displayed_field,
           l3.displayed_field
   INTO    nls_yes,
	   nls_no,
	   nls_all,
	   nls_void,
	   nls_na
   FROM    fnd_lookups ly,
	   fnd_lookups ln,
	   ap_lookup_codes l1,
	   ap_lookup_codes l2,
	   ap_lookup_codes l3
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   l1.lookup_type = 'NLS REPORT PARAMETER'
     AND   l1.lookup_code = 'ALL'
     AND   l2.lookup_type = 'NLS TRANSLATION'
     AND   l2.lookup_code = 'VOID'
     AND   l3.lookup_type = 'NLS REPORT PARAMETER'
     AND   l3.lookup_code = 'NA';

   C_NLS_YES 	:= nls_yes;
   C_NLS_NO  	:= nls_no;
   C_NLS_ALL 	:= nls_all;
   C_NLS_VOID  := nls_void;
   C_NLS_NA	:= nls_na;



/*srw.user_exit('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_NLS_NO_DATA_EXISTS"');*/null;

/*srw.user_exit('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_NLS_END_OF_REPORT"');*/null;




/*srw.user_exit('FND MESSAGE_NAME APPL="FND" NAME="FND_MO_RPT_PARTIAL_LEDGER"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_LEDGER_PARTIAL_OU"');*/null;



RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function BeforeReport return boolean is
begin



DECLARE

  init_failure    EXCEPTION;

BEGIN
LEDGER_PART:=mo_utils.check_ledger_in_sp(p_set_of_books_id );
if P_SWEEP_NOW is not null
then
  P_SWEEP_NOW_1 := P_SWEEP_NOW;
  end if;
  C_REPORT_START_DATE := sysdate;




  IF p_sweep_now IS NULL
     THEN
     p_unacct_rpt := 'Y';

          p_sweep_now_1  := 'N';
     ELSE
     p_unacct_rpt := 'N';

  END IF;

  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;


  IF (p_trace_switch in ('y','Y')) THEN
     /*SRW.DO_SQL('alter session set sql_trace TRUE');*/null;

  END IF;


  IF (get_company_name() <> TRUE) THEN       RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;


  IF (get_nls_strings() <> TRUE) THEN      RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;


  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;



  IF p_period_name IS NOT NULL
     THEN SELECT start_date, end_date
            INTO p_start_date, p_end_date
            FROM gl_period_statuses
           WHERE period_name = p_period_name
             AND application_id = 201
             AND set_of_books_id = p_set_of_books_id;
  ELSE     IF P_FROM_ACCTG_DATE IS NOT NULL AND P_TO_ACCTG_DATE IS NOT NULL THEN
      p_start_date := P_FROM_ACCTG_DATE ;
      p_end_date   := P_TO_ACCTG_DATE ;
    ELSIF P_FROM_ACCTG_DATE IS NOT NULL AND P_TO_ACCTG_DATE IS NULL THEN
      p_start_date := P_FROM_ACCTG_DATE ;
      p_end_date   := sysdate + 75000 ;
    ELSIF P_FROM_ACCTG_DATE IS NULL AND P_TO_ACCTG_DATE IS NOT NULL THEN
      p_start_date := sysdate - 75000 ;
      p_end_date   := P_TO_ACCTG_DATE ;
    ELSIF P_FROM_ACCTG_DATE IS NULL AND P_TO_ACCTG_DATE IS NULL THEN
      p_start_date := sysdate - 75000 ;
      p_end_date   := sysdate + 75000 ;
      else
      p_start_date := ' ';
      p_end_date := ' ';
    END IF ;
END IF;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('4','After Getting the Start and End date');*/null;

  END IF;

 IF (p_debug_switch in ('y','Y')) THEN
       /*SRW.MESSAGE('5','After Get Sort by Alternate');*/null;

    END IF;


   IF (get_org_placeholders() <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('6','After Get_Org_Placeholders');*/null;

  END IF;

  IF (get_acctg_date() <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('7','After Get_Acctg_Date');*/null;

  END IF;
     IF (get_filtered_dates <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('71','After Get_Filtered_Dates');*/null;

  END IF;

  IF (p_sweep_now_1 = 'Y') THEN
     c_sweep_now := c_nls_yes;
  ELSE
     c_sweep_now := c_nls_no;
  END IF;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('8','After setting C_Sweep_Now');*/null;

  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.BREAK;*/null;

  END IF;



  RETURN (TRUE);
EXCEPTION

  WHEN   OTHERS  THEN
 /*RAISE SRW.PROGRAM_ABORT;*/RAISE_APPLICATION_ERROR(-20101,null);
  null;
END;
  return (TRUE);
end;

function AfterReport return boolean is
begin

DECLARE
  init_failure    EXCEPTION;
BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;

   if (p_sweep_now_1 = 'Y') then
     if (update_acctg_dates() <> TRUE) then
        RAISE init_failure;
     end if;
     if (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('20','After updating invoices and payments');*/null;

     end if;
   end if;
EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
  l_name                  gl_sets_of_books.name%TYPE;
  l_sob_id		  number;
BEGIN

  if P_SET_OF_BOOKS_ID is not null then
     l_sob_id := p_set_of_books_id;
     SELECT  name,
             chart_of_accounts_id
     INTO    l_name,
             l_chart_of_accounts_id
     FROM    gl_sets_of_books
     WHERE   set_of_books_id = l_sob_id;

     c_company_name_header     := l_name;
     c_chart_of_accounts_id    := l_chart_of_accounts_id;

  end if;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;
  function M_G_3_UNACCT_PAY_GRPFRFormatTr(co_org_id number) return varchar2 is
cup_counter number := 0;

BEGIN

    SELECT COUNT(*)
      INTO cup_counter
      FROM ap_invoice_payments_all
     WHERE accounting_date BETWEEN p_start_date AND p_end_date
       AND posted_flag IN ('N','S') --Bug3476167
       AND org_id = co_org_id
       AND rownum = 1;

   IF cup_counter = 0
      THEN RETURN('FALSE');
      ELSE RETURN('TRUE');
   END IF;

END;
function M_G_2_UNACCT_INV_GRPFRFormatTr(co_org_id number) return varchar2 is

   cui_counter NUMBER := 0;

BEGIN
   SELECT COUNT(*)
     INTO cui_counter
     FROM ap_invoice_distributions_all
    WHERE accounting_date BETWEEN p_start_date AND p_end_date
      AND accrual_posted_flag = 'N'
      AND p_acct_method = 'A'
      AND org_id = CO_org_id
      AND rownum = 1;

  IF cui_counter = 0
     THEN RETURN('FALSE');
     ELSE RETURN('TRUE');
  END IF;

END;
function M_G_4_FUTURE_PAY_GRPFRFormatTr(co_org_id number) return varchar2 is
   cfp_counter number := 0;

BEGIN

   SELECT COUNT(*)
     INTO cfp_counter
     FROM ap_checks_all
    WHERE future_pay_due_date IS NOT NULL
      AND status_lookup_code = 'ISSUED'
      AND future_pay_due_date BETWEEN p_start_date AND p_end_date
      AND org_id = co_org_id
      AND rownum = 1;

   IF cfp_counter = 0
      THEN RETURN('FALSE');
      ELSE RETURN('TRUE');
   END IF;

END;
function M_G_5_PAY_BATCH_GRPFRFormatTri(co_org_id number) return varchar2 is
cpb_counter number := 0;

BEGIN

   SELECT COUNT(*)
     INTO cpb_counter
     FROM ap_inv_selection_criteria_all
    WHERE check_date BETWEEN p_start_date AND p_end_date
      AND status NOT IN ('CONFIRMED', 'CANCELED', 'QUICKCHECK')
      AND org_id = co_org_id
      AND rownum = 1;

   IF cpb_counter = 0
      THEN RETURN('FALSE');
      ELSE RETURN('TRUE');
   END IF;

END;
function M_G_6_UNTRANS_ACCT_GRPFRFormat(co_org_id number) return varchar2 is
   cut_counter number := 0;
BEGIN

   -- Bug 3739324 - Replaced AP table with XLA table
   SELECT COUNT(*)
     INTO cut_counter
     FROM xla_ae_headers xah, xla_transaction_entities xte
    WHERE xah.accounting_date BETWEEN p_start_date AND p_end_date
      AND xah.gl_transfer_status_code = 'N'
      AND xah.entity_id = xte.entity_id
      AND xte.security_id_int_1 = co_org_id
      AND rownum = 1;

   IF cut_counter = 0
      THEN RETURN('FALSE');
      ELSE RETURN('TRUE');
   END IF;

END;
FUNCTION get_flexdata RETURN BOOLEAN IS

BEGIN

   if C_CHART_OF_ACCOUNTS_ID is not null then

 null;
      return (TRUE);
   else
      /*SRW.MESSAGE('999','Cannot use flex API without a chart of accounts ID.');*/null;

      return(FALSE);
   end if;

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;

FUNCTION GET_ORG_PLACEHOLDERS RETURN BOOLEAN IS
  multi_org_installation fnd_product_groups.multi_org_flag%TYPE ;
BEGIN
    SELECT   multi_org_flag
  INTO  multi_org_installation
  FROM  fnd_product_groups
  WHERE product_group_id = 1;


IF multi_org_installation = 'Y' THEN

   c_inv_multi_org_where :=
      ' AND aid.org_id = oi.organization_id
        AND oi.org_information_context = ''Operating Unit Information''
        AND DECODE(LTRIM(oi.org_information3,''0123456789''), NULL
            , TO_NUMBER(oi.org_information3)
            , NULL ) = '||p_set_of_books_id||'
        AND DECODE(LTRIM(oi.org_information2,''0123456789''), NULL
            , TO_NUMBER(oi.org_information2)
            , NULL ) = le.organization_id
        AND ou.organization_id = oi.organization_id
        AND ou.language = USERENV(''LANG'')
        AND le.language = USERENV(''LANG'')  ' ;

    c_aip_multi_org_where :=
      ' AND aip.org_id = oi.organization_id
        AND oi.org_information_context = ''Operating Unit Information''
        AND DECODE(LTRIM(oi.org_information3,''0123456789''), NULL
            , TO_NUMBER(oi.org_information3)
            , NULL ) = '||p_set_of_books_id||'
        AND DECODE(LTRIM(oi.org_information2,''0123456789''), NULL
            , TO_NUMBER(oi.org_information2)
            , NULL ) = le.organization_id
        AND ou.organization_id = oi.organization_id
        AND ou.language = USERENV(''LANG'')
        AND le.language = USERENV(''LANG'')  ' ;

    c_aph_multi_org_where :=
      ' AND aph.org_id = oi.organization_id
        AND oi.org_information_context = ''Operating Unit Information''
        AND DECODE(LTRIM(oi.org_information3,''0123456789''), NULL
            , TO_NUMBER(oi.org_information3)
            , NULL ) = '||p_set_of_books_id||'
        AND DECODE(LTRIM(oi.org_information2,''0123456789''), NULL
            , TO_NUMBER(oi.org_information2)
            , NULL ) = le.organization_id
        AND ou.organization_id = oi.organization_id
        AND ou.language = USERENV(''LANG'')
        AND le.language = USERENV(''LANG'')  ' ;





    c_select_le := 'le.name ';
    c_select_ou := 'ou.name ';
    c_org_from_tables :=  'HR_ORGANIZATION_INFORMATION   OI,
       HR_ALL_ORGANIZATION_UNITS_TL  LE,
      HR_ALL_ORGANIZATION_UNITS_TL  OU' ;

ELSE
   c_inv_multi_org_where := 'AND 1=1';
   c_aip_multi_org_where := 'AND 1 = 1';
   c_aph_multi_org_where := ' AND 1=1';
   c_pmts_multi_org_where := 'AND 1=1';
   c_select_le := '''Legal Entity''';
   c_select_ou := '''Operating Unit''';
   c_org_from_tables := 'sys.dual';
END IF;

RETURN (TRUE);

EXCEPTION
  WHEN   OTHERS  THEN
      RETURN (FALSE);
END;

FUNCTION UPDATE_PO_CLOSE_DATE RETURN BOOLEAN IS



  CURSOR PO_LIST IS
   SELECT DISTINCT PLL.LINE_LOCATION_ID,
          PLL.CLOSED_DATE
   FROM   PO_LINE_LOCATIONS_ALL PLL,
          PO_DISTRIBUTIONS_ALL PD,
          AP_INVOICE_DISTRIBUTIONS_ALL AID
   WHERE PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
   AND PLL.CLOSED_DATE IS NOT NULL
   AND PD.PO_DISTRIBUTION_ID = AID.PO_DISTRIBUTION_ID
   AND AID.POSTED_FLAG = 'N'
   AND NVL(AID.ORG_ID,-99) = NVL(PD.ORG_ID,-99)
   AND NVL(AID.ORG_ID,-99) IN
           (SELECT NVL(ASP.ORG_ID,-99)
            FROM HR_ORGANIZATION_INFORMATION OI,
            HR_ALL_ORGANIZATION_UNITS_TL LE,
            HR_ALL_ORGANIZATION_UNITS_TL OU,
            AP_SYSTEM_PARAMETERS_ALL ASP,
            GL_SETS_OF_BOOKS SOB
            WHERE nvl(SOB.SLA_LEDGER_CASH_BASIS_FLAG, 'N') <> 'Y'
              AND SOB.SET_OF_BOOKS_ID = ASP.SET_OF_BOOKS_ID
              AND ASP.ORG_ID = OI.ORGANIZATION_ID
              AND OU.ORGANIZATION_ID = OI.ORGANIZATION_ID
              AND OI.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
              AND DECODE(LTRIM(OI.ORG_INFORMATION3,'0123456789'), NULL ,
                         TO_NUMBER(OI.ORG_INFORMATION3), NULL ) = P_SET_OF_BOOKS_ID
              AND DECODE(LTRIM(OI.ORG_INFORMATION2,'0123456789'), NULL ,
                         TO_NUMBER(OI.ORG_INFORMATION2), NULL )
                                                     = LE.ORGANIZATION_ID
              AND OU.ORGANIZATION_ID = OI.ORGANIZATION_ID
              AND OU.LANGUAGE = USERENV('LANG')
              AND LE.LANGUAGE = USERENV('LANG')
             )
   AND (   (P_PERIOD_NAME IS NULL AND AID.ACCOUNTING_DATE BETWEEN
                                           P_FROM_ACCTG_DATE and P_TO_ACCTG_DATE)
       OR  (P_PERIOD_NAME IS NOT NULL AND AID.PERIOD_NAME = P_PERIOD_NAME ))
   AND AID.PO_DISTRIBUTION_ID IS NOT NULL
   GROUP BY PLL.LINE_LOCATION_ID, PLL.CLOSED_DATE, AID.PO_DISTRIBUTION_ID
   HAVING SUM(AID.AMOUNT) > 0;


l_ship_close_date    DATE;
l_header_close_date  DATE;
l_header_id          NUMBER;
l_line_loc_id        NUMBER;
BEGIN

  OPEN PO_LIST;

  LOOP

    FETCH PO_LIST INTO l_line_loc_id,
                       l_ship_close_date;

    EXIT WHEN PO_LIST%NOTFOUND OR PO_LIST%NOTFOUND IS NULL;

    if (l_ship_close_date is not null and
        l_ship_close_date < c_sweep_to_date) then

      update po_line_locations_all
      set    closed_date = c_sweep_to_date
      where  line_location_id = l_line_loc_id;

      select distinct POH.po_header_id,
             POH.closed_date
      into   l_header_id,
             l_header_close_date
      from   po_headers_all POH,
             po_line_locations_all PLL
      where  POH.po_header_id = PLL.po_header_id
      and    PLL.line_location_id = l_line_loc_id;

      if (l_header_close_date is not null and
          l_header_close_date < c_sweep_to_date) then
        update po_headers
        set    closed_date = c_sweep_to_date
        where  po_header_id = l_header_id;
      end if;
    end if;

  END LOOP;


 RETURN(TRUE);

RETURN NULL; exception
  WHEN OTHERS THEN
    RETURN (FALSE);
END;

FUNCTION UPDATE_ACCTG_DATES RETURN BOOLEAN IS

  CURSOR DIST_ORGS IS
  	SELECT aid.invoice_id, aid.invoice_distribution_id
	FROM ap_invoice_distributions_all aid
	WHERE aid.accrual_posted_flag = 'N'
    	AND ((p_period_name is null and aid.accounting_date between p_from_acctg_date
                                                        and p_to_acctg_date)
        OR (p_period_name is not null and aid.period_name = p_period_name))
    	AND nvl(aid.org_id, -99) IN
             (select nvl(asp.org_id, -99)
               from hr_organization_information oi,
                    hr_all_organization_units_tl le,
                    hr_all_organization_units_tl ou,
                    ap_system_parameters_all asp
              where asp.accounting_method_option = 'Accrual'
               and  asp.org_id = oi.organization_id
               and  ou.organization_id = oi.organization_id
               and  oi.org_information_context =
                   'Operating Unit Information'
               and  DECODE(LTRIM(oi.org_information3,'0123456789'), NULL
                         , TO_NUMBER(oi.org_information3) , NULL ) =
                    p_set_of_books_id
               and  DECODE(LTRIM(oi.org_information2,'0123456789'), NULL
                        , TO_NUMBER(oi.org_information2), NULL) =
                    le.organization_id
               and  ou.organization_id = oi.organization_id
               and  ou.language = USERENV('LANG')
               and  le.language = USERENV('LANG'));

  CURSOR DIST_ORG IS
	SELECT aid.invoice_id, aid.invoice_distribution_id
	FROM ap_invoice_distributions_all aid,
             ap_system_parameters_all asp
	WHERE aid.accrual_posted_flag = 'N'
	AND asp.accounting_method_option = 'Accrual'
    	AND ((p_period_name is null and aid.accounting_date between p_from_acctg_date
                                                        and p_to_acctg_date)
        OR (p_period_name is not null and aid.period_name = p_period_name));


  v_no_orgs   NUMBER(5);
  l_invoice_id 	NUMBER(15);
  l_invoice_distribution_id	NUMBER(15);

BEGIN
/*SRW.MESSAGE(0, 'UPDATE_ACCTG_DATES');*/null;

 if (update_po_close_date() <> TRUE) then
    return(FALSE);
 end if;


  select count(*)
  into v_no_orgs
  from ap_system_parameters_all;




IF v_no_orgs > 1 THEN

   /*srw.message('10', 'Updating invoice distributions....');*/null;


  OPEN DIST_ORGS;

  LOOP

    FETCH DIST_ORGS INTO l_invoice_id,
                       l_invoice_distribution_id;

    EXIT WHEN DIST_ORGS%NOTFOUND OR DIST_ORGS%NOTFOUND IS NULL;

	UPDATE ap_invoice_distributions_all aid
    	SET accounting_date = c_sweep_to_date,
        period_name = p_to_period,
        last_update_date = sysdate,
        last_updated_by = 5
  	WHERE aid.invoice_distribution_id = l_invoice_distribution_id;

	        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'U',
               p_key_value1 => l_invoice_id,
               p_key_value2 => l_invoice_distribution_id,
                p_calling_sequence => 'APXTRSWP');


  END LOOP;

   /*srw.message('11', 'Done updating invoice distributions.');*/null;

   /*srw.message('12', 'Updating invoice payments....');*/null;


  UPDATE ap_invoice_payments_all aip
    SET accounting_date = c_sweep_to_date,
        period_name = p_to_period,
        last_update_date = sysdate,
        last_updated_by = 5
  WHERE posted_flag IN ('N','S')     AND ((p_period_name is null and accounting_date between p_from_acctg_date
                                                    and p_to_acctg_date)
        OR (p_period_name is not null and period_name = p_period_name))
    AND nvl(aip.org_id, -99) IN
         (select nvl(asp.org_id, -99)
            from hr_organization_information oi,
                 hr_all_organization_units_tl le,
                 hr_all_organization_units_tl ou,
                 ap_system_parameters_all asp

          where
                            asp.org_id = oi.organization_id
            and ou.organization_id = oi.organization_id
            and oi.org_information_context =
                   'Operating Unit Information'
            and DECODE(LTRIM(oi.org_information3,'0123456789'), NULL
                         , TO_NUMBER(oi.org_information3) , NULL ) =
                   p_set_of_books_id
            and DECODE(LTRIM(oi.org_information2,'0123456789'), NULL
                        , TO_NUMBER(oi.org_information2), NULL) =
                   le.organization_id
            and ou.organization_id = oi.organization_id
            and ou.language = USERENV('LANG')
            and le.language = USERENV('LANG'));

  /*srw.message('13', 'Done updating invoice payments.');*/null;

  /*srw.message('14', 'Updating payment history records ....');*/null;


  UPDATE ap_payment_history_all aph
    SET accounting_date = c_sweep_to_date,
        last_update_date = sysdate,
        last_updated_by = 5
  WHERE nvl(aph.posted_flag, 'N') IN ('N','S')


    AND ((p_period_name is null and accounting_date between p_from_acctg_date
                                                    and p_to_acctg_date)
        OR
         (p_period_name is not null and accounting_date between c_from_acctg_date
                                                       and c_to_acctg_date))
    AND nvl(aph.org_id, -99) IN
          (select nvl(asp.org_id, -99)
             from hr_organization_information oi,
                  hr_all_organization_units_tl le,
                  hr_all_organization_units_tl ou,
                  ap_system_parameters_all asp
            where
                                                                      asp.org_id = oi.organization_id
             and  ou.organization_id = oi.organization_id
             and  oi.org_information_context =
                    'Operating Unit Information'
             and  DECODE(LTRIM(oi.org_information3,'0123456789'), NULL
                          , TO_NUMBER(oi.org_information3) , NULL ) =
                    p_set_of_books_id
             and  DECODE(LTRIM(oi.org_information2,'0123456789'), NULL
                         , TO_NUMBER(oi.org_information2), NULL) =
                    le.organization_id
             and  ou.organization_id = oi.organization_id
             and  ou.language = USERENV('LANG')
             and  le.language = USERENV('LANG'));

    /*srw.message('15', 'Done updating payment history records.');*/null;



        AP_ACCOUNTING_EVENTS_PKG.MULTI_ORG_EVENTS_SWEEP
    (
      p_ledger_id => p_set_of_books_id,
      p_period_name => p_period_name,
      p_from_date => p_from_acctg_date,
      p_to_date => p_to_acctg_date,
      p_sweep_to_date => c_sweep_to_date,
      p_calling_sequence => 'APXTRSWP.rdf (update_acctg_dates() )'
    );

    /*srw.message('16', 'Done updating accoutning events records.');*/null;


  else

     /*srw.message('10', 'Updating invoice distributions....');*/null;


  OPEN DIST_ORG;

  LOOP

    FETCH DIST_ORG INTO l_invoice_id,
                       l_invoice_distribution_id;

    EXIT WHEN DIST_ORG%NOTFOUND OR DIST_ORG%NOTFOUND IS NULL;

	UPDATE ap_invoice_distributions_all aid
    	SET accounting_date = c_sweep_to_date,
        period_name = p_to_period,
        last_update_date = sysdate,
        last_updated_by = 5
  	WHERE aid.invoice_distribution_id = l_invoice_distribution_id;

	        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'U',
               p_key_value1 => l_invoice_id,
               p_key_value2 => l_invoice_distribution_id,
                p_calling_sequence => 'APXTRSWP');


  END LOOP;

   /*srw.message('11', 'Done updating invoice distributions.');*/null;

   /*srw.message('12', 'Updating invoice payments....');*/null;


  UPDATE ap_invoice_payments_all aip
    SET accounting_date = c_sweep_to_date,
        period_name = p_to_period,
        last_update_date = sysdate,
        last_updated_by = 5
  WHERE posted_flag IN ('N','S')     AND ((p_period_name is null and accounting_date between p_from_acctg_date
                                                    and p_to_acctg_date)
        OR (p_period_name is not null and period_name = p_period_name));

  /*srw.message('13', 'Done updating invoice payments.');*/null;

  /*srw.message('14', 'Updating payment history records ....');*/null;


  UPDATE ap_payment_history_all aph
    SET accounting_date = c_sweep_to_date,
        last_update_date = sysdate,
        last_updated_by = 5
  WHERE nvl(aph.posted_flag, 'N') IN ('N','S')     AND ((p_period_name is null and accounting_date between p_from_acctg_date
                                                    and p_to_acctg_date)
        OR
         (p_period_name is not null and accounting_date between c_from_acctg_date
                                                       and c_to_acctg_date));


        AP_ACCOUNTING_EVENTS_PKG.SINGLE_ORG_EVENTS_SWEEP
    (
      p_period_name => p_period_name,
      p_from_date => p_from_acctg_date,
      p_to_date => p_to_acctg_date,
      p_sweep_to_date => c_sweep_to_date,
      p_calling_sequence => 'APXTRSWP.rdf (update_acctg_dates() )'
    );

  end if;

  RETURN (TRUE);


Exception
  WHEN OTHERS THEN
   RETURN (FALSE);
END;

FUNCTION GET_ACCTG_DATE RETURN BOOLEAN IS
 l_to_acctg_date      date;
 l_start_date         date;
 l_end_date           date;
BEGIN

         if (p_sweep_now_1 = 'Y') then


            /*srw.message('1', 'Sweep now is: '||p_sweep_now);*/null;

      /*srw.message('2', 'Sweep to Period is: '||p_to_period);*/null;

      SELECT start_date
        INTO l_to_acctg_date
        FROM gl_period_statuses
      WHERE period_name = p_to_period
        AND application_id = 200
        AND set_of_books_id = p_set_of_books_id
        AND nvl(adjustment_period_flag, 'N') = 'N';

      c_sweep_to_date := l_to_acctg_date;
      /*srw.message('3', 'sweep to date is: '||c_sweep_to_date);*/null;



   end if;



   if (p_period_name is not null) then
      SELECT start_date,
             end_date
        INTO l_start_date,
             l_end_date
        FROM gl_period_statuses
      WHERE period_name = p_period_name
        AND application_id = 200
        AND set_of_books_id = p_set_of_books_id
        AND nvl(adjustment_period_flag, 'N') = 'N';

      c_from_acctg_date := l_start_date;
      c_to_acctg_date := l_end_date;
   end if;

RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function AfterPForm return boolean is
begin
  XLA_MO_REPORTING_API.Initialize(p_reporting_level,p_reporting_entity_id,'AUTO');
  p_level_name := XLA_MO_REPORTING_API.Get_Reporting_level_name;
  p_entity_name := XLA_MO_REPORTING_API.Get_Reporting_entity_name;
  p_ac_org_where := XLA_MO_REPORTING_API.Get_Predicate('ac', null);
  p_aid_org_where := XLA_MO_REPORTING_API.Get_Predicate('aid', null);
  p_aip_org_where := XLA_MO_REPORTING_API.Get_Predicate('aip', null);
  p_aph_org_where := XLA_MO_REPORTING_API.Get_Predicate('aph', null);
  return (TRUE);
end;

FUNCTION GET_ACCRUAL_BASIS RETURN BOOLEAN IS
 l_cash_basis_flag      varchar2(1);
BEGIN

  SELECT nvl(sla_ledger_cash_basis_flag, 'N')
  INTO l_cash_basis_flag
  FROM gl_sets_of_books
  WHERE set_of_books_id = p_set_of_books_id;

  if (l_cash_basis_flag = 'N') then
    c_accrual_basis_in_use := 'Y';
  else
    c_accrual_basis_in_use := 'N';
  end if;
END;

FUNCTION get_filtered_dates RETURN BOOLEAN IS
BEGIN
   IF P_period_name IS NOT NULL THEN

      C_date_filter_inv := ' and aid.period_name = ''' || p_period_name || '''';
      C_date_filter_pay := ' and aip.period_name = ''' || p_period_name || '''';
      C_date_filter_payhist := ' and aph.accounting_date between to_date('''
                               || fnd_date.date_to_canonical(C_from_acctg_date) ||''', ''YYYY/MM/DD HH24:MI:SS'')'
                               || ' and to_date(''' || fnd_date.date_to_canonical(C_to_acctg_date)
                               ||''', ''YYYY/MM/DD HH24:MI:SS'')';

   ELSIF (P_from_acctg_date is NOT NULL and P_to_acctg_date is NOT NULL) THEN

        C_date_filter_inv :=
        ' and aid.accounting_date between to_date(''' || fnd_date.date_to_canonical(P_from_acctg_date)
        || ''', ''YYYY/MM/DD HH24:MI:SS'') and to_date('''
        || fnd_date.date_to_canonical(P_to_acctg_date) || ''', ''YYYY/MM/DD HH24:MI:SS'')';

        C_date_filter_pay :=
        ' and aip.accounting_date between to_date(''' || fnd_date.date_to_canonical(P_from_acctg_date)
        || ''', ''YYYY/MM/DD HH24:MI:SS'') and to_date('''
        || fnd_date.date_to_canonical(P_to_acctg_date) || ''', ''YYYY/MM/DD HH24:MI:SS'')';

        C_date_filter_payhist :=
        ' and aph.accounting_date between to_date(''' || fnd_date.date_to_canonical(P_from_acctg_date)
        || ''', ''YYYY/MM/DD HH24:MI:SS'') and to_date('''
        || fnd_date.date_to_canonical(P_to_acctg_date) || ''', ''YYYY/MM/DD HH24:MI:SS'')';

   ELSIF (P_to_acctg_date is NOT NULL and P_from_acctg_date is NULL) THEN

        C_date_filter_inv := ' and aid.accounting_date <= to_date('''
                              || fnd_date.date_to_canonical(P_to_acctg_date)
                              || ''', ''YYYY/MM/DD HH24:MI:SS'')';
        C_date_filter_pay := ' and aip.accounting_date <= to_date('''
                              || fnd_date.date_to_canonical(P_to_acctg_date)
                              || ''', ''YYYY/MM/DD HH24:MI:SS'')';
        C_date_filter_payhist := ' and aph.accounting_date <= to_date('''
                              || fnd_date.date_to_canonical(P_to_acctg_date)
                              || ''', ''YYYY/MM/DD HH24:MI:SS'')';

   ELSIF (P_to_acctg_date is NULL and P_from_acctg_date is NOT NULL) THEN

        C_date_filter_inv := ' and aid.accounting_date >= to_date('''
                              || fnd_date.date_to_canonical(P_from_acctg_date)
                              || ''', ''YYYY/MM/DD HH24:MI:SS'')';
        C_date_filter_pay := ' and aip.accounting_date >= to_date('''
                              || fnd_date.date_to_canonical(P_from_acctg_date)
                              || ''', ''YYYY/MM/DD HH24:MI:SS'')';
        C_date_filter_payhist := ' and aph.accounting_date >=  to_date('''
                              || fnd_date.date_to_canonical(P_from_acctg_date)
                              || ''', ''YYYY/MM/DD HH24:MI:SS'')';
   else
    C_DATE_FILTER_PAY := 'AND 1 = 1 ';
    C_DATE_FILTER_PAYHIST := 'AND 1 = 1  ';
    C_DATE_FILTER_INV := 'AND 1 = 1  ';

   END IF;


RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);




END;

function g_1_orgsgroupfilter(CO_org_id in number) return boolean is
cui_counter number := 0;
cup_counter number := 0;
cut_counter number := 0;
cfp_counter number := 0;
cpb_counter number := 0;

BEGIN
   IF p_sweep_now_1 = 'Y' OR p_unacct_rpt = 'Y'       THEN RETURN(FALSE);
      ELSE SELECT COUNT(*)
             INTO cui_counter
             FROM ap_invoice_distributions_all
            WHERE accounting_date BETWEEN p_start_date AND p_end_date
              AND accrual_posted_flag = 'N'
              AND p_acct_method = 'A'
              AND org_id = CO_org_id
              AND rownum = 1;

           SELECT COUNT(*)
             INTO cup_counter
             FROM ap_invoice_payments_all
            WHERE accounting_date BETWEEN p_start_date AND p_end_date
              AND posted_flag IN ('N','S')               AND org_id = co_org_id
              AND rownum = 1;

                      SELECT COUNT(*)
             INTO cut_counter
             FROM xla_ae_headers xah, xla_transaction_entities xte
            WHERE xah.accounting_date BETWEEN p_start_date AND p_end_date
              AND xah.gl_transfer_status_code = 'N'
              AND xah.entity_id = xte.entity_id
              AND xte.security_id_int_1 = co_org_id
              AND rownum = 1;

           SELECT COUNT(*)
             INTO cfp_counter
             FROM ap_checks_all
            WHERE future_pay_due_date IS NOT NULL
              AND status_lookup_code = 'ISSUED'
              AND future_pay_due_date BETWEEN p_start_date AND p_end_date
              AND org_id = co_org_id
              AND rownum = 1;

           SELECT COUNT(*)
             INTO cpb_counter
             FROM ap_inv_selection_criteria_all
            WHERE check_date BETWEEN p_start_date AND p_end_date
              AND status NOT IN ('CONFIRMED', 'CANCELED', 'QUICKCHECK')
              AND org_id = co_org_id
              AND rownum = 1;

           IF cui_counter + cup_counter + cut_counter + cfp_counter + cpb_counter = 0
              THEN RETURN(FALSE);
              ELSE RETURN(TRUE);
           END IF;
   END IF;

END;

--Functions to refer Oracle report placeholders--

 Function C_NLS_YES_p return varchar2 is
	Begin
	 return C_NLS_YES;
	 END;
 Function C_NLS_NO_p return varchar2 is
	Begin
	 return C_NLS_NO;
	 END;
 Function C_NLS_ALL_p return varchar2 is
	Begin
	 return C_NLS_ALL;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_NLS_VOID_p return varchar2 is
	Begin
	 return C_NLS_VOID;
	 END;
 Function C_NLS_NA_p return varchar2 is
	Begin
	 return C_NLS_NA;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_BASE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return C_BASE_CURRENCY_CODE;
	 END;
 Function C_BASE_PRECISION_p return number is
	Begin
	 return C_BASE_PRECISION;
	 END;
 Function C_BASE_MIN_ACCT_UNIT_p return number is
	Begin
	 return C_BASE_MIN_ACCT_UNIT;
	 END;
 Function C_BASE_DESCRIPTION_p return varchar2 is
	Begin
	 return C_BASE_DESCRIPTION;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 --Function Applications Template Report_p return varchar2 is
   Function Applications_Template_Report_p return varchar2 is
	Begin
	 --return Applications Template Report;
	   return Applications_Template_Report;
	 END;
 Function C_AIP_MULTI_ORG_WHERE_p return varchar2 is
	Begin
	 return C_AIP_MULTI_ORG_WHERE;
	 END;
 Function C_APH_MULTI_ORG_WHERE_p return varchar2 is
	Begin
	 return C_APH_MULTI_ORG_WHERE;
	 END;
 Function C_PMTS_MULTI_ORG_WHERE_p return varchar2 is
	Begin
	 return C_PMTS_MULTI_ORG_WHERE;
	 END;
 Function C_INV_MULTI_ORG_WHERE_p return varchar2 is
	Begin
	 return C_INV_MULTI_ORG_WHERE;
	 END;
 Function C_ORG_FROM_TABLES_p return varchar2 is
	Begin
	 return C_ORG_FROM_TABLES;
	 END;
 Function C_SELECT_LE_p return varchar2 is
	Begin
	 return C_SELECT_LE;
	 END;
 Function C_SELECT_OU_p return varchar2 is
	Begin
	 return C_SELECT_OU;
	 END;
 Function C_REP_TITLE_p return varchar2 is
	Begin
	 return C_REP_TITLE;
	 END;
 Function C_SWEEP_TO_DATE_p return date is
	Begin
	 return C_SWEEP_TO_DATE;
	 END;
 Function C_ACCRUAL_BASIS_IN_USE_p return varchar2 is
	Begin
	 return C_ACCRUAL_BASIS_IN_USE;
	 END;
 Function C_FROM_ACCTG_DATE_p return date is
	Begin
	 return C_FROM_ACCTG_DATE;
	 END;
 Function C_TO_ACCTG_DATE_p return date is
	Begin
	 return C_TO_ACCTG_DATE;
	 END;
 Function C_APH_ACCTG_DATE_p return varchar2 is
	Begin
	 return C_APH_ACCTG_DATE;
	 END;
 Function C_SWEEP_NOW_p return varchar2 is
	Begin
	 return C_SWEEP_NOW;
	 END;
 Function C_DATE_FILTER_INV_p return varchar2 is
	Begin
	 return C_DATE_FILTER_INV;
	 END;
 Function C_DATE_FILTER_PAY_p return varchar2 is
	Begin
	 return C_DATE_FILTER_PAY;
	 END;
 Function C_DATE_FILTER_PAYHIST_p return varchar2 is
	Begin
	 return C_DATE_FILTER_PAYHIST;
	 END;
 Function C_LEDGER_PARTIAL_OU_p return varchar2 is
	Begin
	 return C_LEDGER_PARTIAL_OU;
	 END;
function F_END_OF_REPORT1FormatTrigger return number is
cui_counter number := 0;
cup_counter number := 0;
cut_counter number := 0;
cfp_counter number := 0;
cpb_counter number := 0;

BEGIN
   IF P_SWEEP_NOW_1 <> 'Y' then
      SELECT COUNT(*)
             INTO cui_counter
             FROM ap_invoice_distributions_all
            WHERE accounting_date     BETWEEN p_start_date AND p_end_date
              AND accrual_posted_flag = 'N'
              AND p_acct_method      = 'A'
              AND set_of_books_id     = p_set_of_books_id
              AND rownum              = 1;

           SELECT COUNT(*)
             INTO cup_counter
             FROM ap_invoice_payments_all
            WHERE accounting_date BETWEEN p_start_date AND p_end_date
              AND posted_flag     IN ('N','S') --Bug 3476167
              AND set_of_books_id = p_set_of_books_id
              AND rownum          = 1;

           SELECT COUNT(*)
             INTO cut_counter
             FROM xla_ae_headers --Bug 3739324
            WHERE accounting_date  BETWEEN p_start_date AND p_end_date
              AND gl_transfer_status_code = 'N'
              AND ledger_id  = p_set_of_books_id
              AND rownum           = 1;

           SELECT COUNT(*)
             INTO cfp_counter
             FROM ap_checks_all AC, hr_operating_units HOU
            WHERE AC.org_id              = HOU.organization_id
              AND AC.future_pay_due_date IS NOT NULL
              AND AC.status_lookup_code  = 'ISSUED'
              AND AC.future_pay_due_date BETWEEN p_start_date AND p_end_date
              AND HOU.set_of_books_id    = to_char(p_set_of_books_id)  --Bug 2986690
              AND rownum                 = 1;

           SELECT COUNT(*)
             INTO cpb_counter
             FROM ap_inv_selection_criteria_all AIS, hr_operating_units HOU
            WHERE AIS.org_id          = HOU.organization_id
              AND AIS.check_date      BETWEEN p_start_date AND p_end_date
              AND status              NOT IN ('CONFIRMED', 'CANCELED', 'QUICKCHECK')
              AND HOU.set_of_books_id = to_char(p_set_of_books_id)     --Bug 2986690
              AND rownum              = 1;


               RETURN(cui_counter + cup_counter + cut_counter + cfp_counter + cpb_counter);


   END IF;

END;
END AP_APXTRSWP_XMLP_PKG ;



/
