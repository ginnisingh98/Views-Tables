--------------------------------------------------------
--  DDL for Package Body AP_APXUCPRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXUCPRP_XMLP_PKG" AS
/* $Header: APXUCPRPB.pls 120.1 2008/01/06 11:52:48 vjaganat noship $ */

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies.precision%TYPE;       min_au    fnd_currencies.minimum_accountable_unit%TYPE;  descr     fnd_currencies.description%TYPE;
BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';





  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_void       ap_lookup_codes.displayed_field%TYPE;
   nls_na         ap_lookup_codes.displayed_field%TYPE;
   nls_all        ap_lookup_codes.displayed_field%TYPE;
   nls_yes        fnd_lookups.meaning%TYPE;
   nls_no         fnd_lookups.meaning%TYPE;
   nls_pay_method ap_lookup_codes.displayed_field%TYPE;
BEGIN


 IF p_pmt_method IS NOT NULL THEN

   SELECT  ly.meaning,
           ln.meaning,
           l1.displayed_field,
           l2.displayed_field,
           l3.displayed_field,
           l4.displayed_field
   INTO    nls_yes,
	   nls_no,
	   nls_all,
	   nls_void,
	   nls_na,
           nls_pay_method
   FROM    fnd_lookups ly,
	   fnd_lookups ln,
	   ap_lookup_codes l1,
	   ap_lookup_codes l2,
	   ap_lookup_codes l3,
           ap_lookup_codes l4
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   l1.lookup_type = 'NLS REPORT PARAMETER'
     AND   l1.lookup_code = 'ALL'
     AND   l2.lookup_type = 'NLS TRANSLATION'
     AND   l2.lookup_code = 'VOID'
     AND   l3.lookup_type = 'NLS REPORT PARAMETER'
     AND   l3.lookup_code = 'NA'
     AND   l4.lookup_type = 'PAYMENT METHOD'
     AND   (l4.lookup_code = P_PMT_METHOD OR P_PMT_METHOD IS NULL);

   C_NLS_YES 	      := nls_yes;
   C_NLS_NO  	      := nls_no;
   C_NLS_ALL 	      := nls_all;
   C_NLS_VOID        := nls_void;
   C_NLS_NA	      := nls_na;
   CP_PAYMENT_METHOD := nls_pay_method;

  ELSE

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

   C_NLS_YES 	      := nls_yes;
   C_NLS_NO  	      := nls_no;
   C_NLS_ALL 	      := nls_all;
   C_NLS_VOID        := nls_void;
   C_NLS_NA	      := nls_na;
   CP_PAYMENT_METHOD := '';

  END IF;


/*srw.user_exit('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_NLS_NO_DATA_EXISTS"');*/null;

/*srw.user_exit('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_NLS_END_OF_REPORT"');*/null;


C_NLS_NO_DATA_EXISTS := 'No Data Found';
C_NLS_END_OF_REPORT  := 'End of Report';

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


  C_REPORT_START_DATE := sysdate;

P_FROM_CHECK_DATE_v:= to_char(P_FROM_CHECK_DATE,'DD-MON-YY');
P_TO_CHECK_DATE_v:= to_char(P_TO_CHECK_DATE,'DD-MON-YY');
F_LEDGER_PARTIAL_OU:=mo_utils.check_ledger_in_sp(p_set_of_books_id );


  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;




  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;


  IF (GET_NLS_STRINGS <> TRUE) THEN      RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;


  IF (get_base_curr_data <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;


  IF (get_org_placeholders <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('5','After Get_Org_Placeholders');*/null;

  END IF;


  IF p_bank_account_id IS NOT NULL
     THEN IF (get_bank_account_info <> TRUE)
             THEN RAISE init_failure;
          END IF;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('5','After get_bank_account_info');*/null;

  END IF;




  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.BREAK;*/null;

  END IF;



  RETURN (TRUE);



EXCEPTION

  WHEN   OTHERS  THEN

    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;
  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;

   IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('20','After SRWEXIT');*/null;

   END IF;
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

FUNCTION GET_ORG_PLACEHOLDERS RETURN BOOLEAN IS
  multi_org_installation fnd_product_groups.multi_org_flag%TYPE ;
  l_sob_type_code  gl_sets_of_books.mrc_sob_type_code%TYPE;
  l_primary_set_of_books_id  gl_sets_of_books.set_of_books_id%TYPE;
  l_org_id  ap_system_parameters.org_id%TYPE;
BEGIN
  SELECT multi_org_flag
  INTO   multi_org_installation
  FROM   fnd_product_groups
  WHERE  product_group_id = 1 ;

  IF multi_org_installation = 'Y' THEN

    SELECT mrc_sob_type_code INTO l_sob_type_code
    FROM gl_sets_of_books WHERE set_of_books_id = p_set_of_books_id;


    IF l_sob_type_code = 'R' THEN

   l_primary_set_of_books_id := GL_MC_INFO.GET_SOURCE_LEDGER_ID
            (p_set_of_books_id);


    ELSE
      l_primary_set_of_books_id := p_set_of_books_id;
    END IF;

    c_multi_org_where :=
       'AND ac.org_id  = oi.organization_id
        AND asp1.org_id = oi.organization_id
        AND oi.org_information_context = ''Operating Unit Information''
        AND DECODE(LTRIM(oi.org_information3,''0123456789''), NULL
            , TO_NUMBER(oi.org_information3)
            , NULL ) = '||l_primary_set_of_books_id||'
        AND DECODE(LTRIM(oi.org_information2,''0123456789''), NULL
            , TO_NUMBER(oi.org_information2)
            , NULL ) = le.organization_id
        AND ou.organization_id = oi.organization_id
        AND ou.language = USERENV(''LANG'')
        AND le.language = USERENV(''LANG'')  ' ;

    c_select_le := 'le.name' ;
    c_select_ou := 'ou.name' ;
    c_org_from_tables := ' hr_organization_information oi, hr_all_organization_units_tl le, hr_all_organization_units_tl ou ' ;


  ELSE
    c_multi_org_where := ' AND 1=1 ' ;
    c_select_le := '''Legal Entity''' ;
    c_select_ou := '''Operating Unit''' ;
    c_org_from_tables := ' sys.dual ' ;
  END IF ;

  RETURN ( TRUE ) ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN (FALSE) ;

END;

function AfterPForm return boolean is
begin

  XLA_MO_REPORTING_API.Initialize(p_reporting_level,p_reporting_entity_id,'AUTO');
  p_org_where_ac  := XLA_MO_REPORTING_API.Get_Predicate('ac',null);
  p_org_where_asp := XLA_MO_REPORTING_API.Get_Predicate('asp1',null);
  p_level_name := XLA_MO_REPORTING_API.Get_Reporting_level_name;
  p_entity_name := XLA_MO_REPORTING_API.Get_Reporting_entity_name;

  return (TRUE);
end;

FUNCTION GET_BANK_ACCOUNT_INFO
   RETURN BOOLEAN IS

BEGIN

   SELECT CBA.bank_account_name
     INTO cp_bank_account_name
     FROM ce_bank_accounts CBA, ce_bank_acct_uses_all CBAU
    WHERE  CBA.bank_account_id  =  CBAU.bank_account_id
     AND  CBAU.bank_acct_use_id = p_bank_account_id;

   RETURN (TRUE);

EXCEPTION

   WHEN OTHERS
      THEN RETURN(FALSE);
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
 Function Applications_Template_Rep_p return varchar2 is
	Begin
	 return Applications_Template_Report;
	 END;
 Function C_MULTI_ORG_WHERE_p return varchar2 is
	Begin
	 return C_MULTI_ORG_WHERE;
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
 Function CP_PAYMENT_METHOD_p return varchar2 is
	Begin
	 return CP_PAYMENT_METHOD;
	 END;
 Function CP_BANK_ACCOUNT_NAME_p return varchar2 is
	Begin
	 return CP_BANK_ACCOUNT_NAME;
	 END;
 Function C_LEDGER_PARTIAL_OU_p return varchar2 is
	Begin
	 return C_LEDGER_PARTIAL_OU;
	 END;
END AP_APXUCPRP_XMLP_PKG ;



/
