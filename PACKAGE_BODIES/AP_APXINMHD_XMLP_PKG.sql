--------------------------------------------------------
--  DDL for Package Body AP_APXINMHD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINMHD_XMLP_PKG" AS
/* $Header: APXINMHDB.pls 120.0 2007/12/27 07:57:29 vjaganat noship $ */

function BeforeReport return boolean is
begin

DECLARE

  init_failure    EXCEPTION;

BEGIN



  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;


  IF (get_company_name() <> TRUE) THEN          RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;


  IF (get_nls_strings() <> TRUE) THEN           RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;


  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;


  IF (get_nls_released_held() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('5','After Get_nls_released_held');*/null;

  END IF;


  IF (get_flexdata() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('6','After get_flexdata() ');*/null;

  END IF;


  IF (custom_init() <> TRUE) THEN          RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('7','After Custom_Init');*/null;

  END IF;

  IF P_MATCH_TYPE = 'HOLD' THEN
     P_WHERE := (' WHERE V.vendor_id = decode('''||P_TEST_VENDOR_ID||''', NULL, V.vendor_id,
                            ''All'',V.vendor_id, '''||P_TEST_VENDOR_ID||''')
                    AND   V.vendor_id = I.vendor_id
                    AND   I.invoice_id = M.invoice_id
                    AND   I.cancelled_date IS NULL
                    AND   I.batch_id = B.batch_id (+)
                    AND   EXISTS
                            (SELECT null FROM ap_holds M2
                             WHERE  M2.invoice_id = I.invoice_id
                             AND    M2.last_update_date between
                                    NVL('''||to_char(P_START_ACTIVITY_DATE)||''',
                                        M2.last_update_date) and
                                    NVL('''||to_char(P_END_ACTIVITY_DATE)||''',
                                        M2.last_update_date)
                             AND    M2.line_location_id IS NOT NULL)
                             AND EXISTS
                                   (SELECT null FROM ap_holds M2
                                    WHERE M2.invoice_id = I.invoice_id
                                    AND   M2.release_lookup_code is null)
                             AND ((UPPER('''||P_HOLD_DETAIL_TYPE||''')=''ALL APPROVALS'') OR
                                 ((UPPER('''||P_HOLD_DETAIL_TYPE||''')=''AUDIT REPORT'')
                             AND (M.STATUS_FLAG=''R'' OR M.STATUS_FLAG=''S'')))
                 ');

   ELSE IF P_MATCH_TYPE = 'RELEASE' THEN
           P_WHERE := (' WHERE V.vendor_id = decode('''||P_TEST_VENDOR_ID||''', null,
                                V.vendor_id,''All'',V.vendor_id,'''||P_TEST_VENDOR_ID||''')
                          AND   V.vendor_id = I.vendor_id
                          AND   I.invoice_id = M.invoice_id
                          AND   I.batch_id = B.batch_id (+)
                          AND   EXISTS
                                  (SELECT null FROM ap_holds M2
                                   WHERE  M2.invoice_id = I.invoice_id
                                   AND    M2.last_update_date between
                                          NVL('''||to_char(P_START_ACTIVITY_DATE)||''',
                                              M2.last_update_date) and
                                          NVL('''||to_char(P_END_ACTIVITY_DATE)||''',
                                              M2.last_update_date)
                                   AND    M2.line_location_id IS NOT NULL)
                          AND NOT EXISTS
                                    (SELECT null FROM ap_holds M2
                                     WHERE  M2.invoice_id = I.invoice_id
                                     AND    M2.release_lookup_code is null)
                                     AND ((UPPER('''||P_HOLD_DETAIL_TYPE||''')=''ALL APPROVALS'') OR
                                         ((UPPER('''||P_HOLD_DETAIL_TYPE||''')=''AUDIT REPORT'')
                                     AND (M.STATUS_FLAG=''R'' OR M.STATUS_FLAG=''S'')))
                      ');

   ELSE IF P_MATCH_TYPE = 'All' OR P_MATCH_TYPE = 'ALL' OR P_MATCH_TYPE IS NULL THEN
           P_WHERE := (' WHERE V.vendor_id = decode('''||P_TEST_VENDOR_ID||''',null, V.vendor_id,
                                                     ''All'',V.vendor_id,'''||P_TEST_VENDOR_ID||''')
                          AND   V.vendor_id = I.vendor_id
                          AND   I.invoice_id = M.invoice_id
                          AND   I.batch_id = B.batch_id (+)
                          AND   EXISTS
                                  (SELECT null FROM ap_holds M2
                                   WHERE  M2.invoice_id = I.invoice_id
                                   AND    M2.last_update_date between
                                          NVL('''||to_char(P_START_ACTIVITY_DATE)||''',
                                              M2.last_update_date) and
                                          NVL('''||to_char(P_END_ACTIVITY_DATE)||''',
                                              M2.last_update_date)
                                   AND    M2.line_location_id IS NOT NULL)
                                   AND    ((UPPER('''||P_HOLD_DETAIL_TYPE||''')=''ALL APPROVALS'') OR
                                          ((UPPER('''||P_HOLD_DETAIL_TYPE||''')=''AUDIT REPORT'')) AND
                                          (M.STATUS_FLAG=''R'' OR M.STATUS_FLAG=''S''))
                      ');
   ELSE
         P_WHERE := ' ';
   END IF;
   END IF;
   END IF;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN

    /*SRW.USER_EXIT('FND SRWEXIT');*/
    null;

    --RETURN (FALSE);

END;  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
/*SRW.USER_EXIT('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

FUNCTION  custom_init         RETURN BOOLEAN IS

BEGIN


RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  l_base_curr   VARCHAR2(15);        l_prec        NUMBER;          l_min_au      NUMBER;          l_sob_id      NUMBER;
BEGIN

  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit
  INTO    l_base_curr,
          l_prec,
          l_min_au
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;

  c_base_currency_code  := l_base_curr;
  c_base_precision      := l_prec;
  c_base_min_acct_unit  := l_min_au;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_company_name    RETURN BOOLEAN IS

  l_chart_of_accounts_id  NUMBER;
  l_name                  VARCHAR2(30);     l_sob_id                NUMBER;
  l_report_start_date     date;

BEGIN

  l_sob_id := p_sob_id;         l_report_start_date := sysdate;

  SELECT  substr(name,1,30),
          chart_of_accounts_id
  INTO    l_name,
          l_chart_of_accounts_id
  FROM    gl_sets_of_books
  WHERE   set_of_books_id   = l_sob_id;

  c_company_name_header     := l_name;
  c_chart_of_accounts_id    := l_chart_of_accounts_id;
  c_report_start_date       := l_report_start_date;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   l_nls_yes   fnd_lookups.meaning%TYPE;
   l_nls_no    fnd_lookups.meaning%TYPE;
   l_nls_all   ap_lookup_codes.displayed_field%TYPE;
   l_nls_na    ap_lookup_codes.displayed_field%TYPE;

BEGIN
   SELECT  ly.meaning,
           ln.meaning,
           la.displayed_field,
           la1.displayed_field
   INTO    l_nls_yes,  l_nls_no,  l_nls_all ,l_nls_na
   FROM    fnd_lookups ly,  fnd_lookups ln,  ap_lookup_codes la,
           ap_lookup_codes la1
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   la.lookup_type = 'NLS REPORT PARAMETER'
     AND   la.lookup_code = 'ALL'

     AND   la1.lookup_type = 'NLS REPORT PARAMETER'
     AND   la1.lookup_code = 'NA';


   c_nls_yes := l_nls_yes;
   c_nls_no  := l_nls_no;
   c_nls_all := l_nls_all;
   c_nls_na  := l_nls_na;

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;

   c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;

   c_nls_end_of_report := '*** '||c_nls_end_of_report||' ***';


RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

FUNCTION  get_nls_released_held    RETURN BOOLEAN IS
  l_nls_released   ap_lookup_codes.displayed_field%TYPE;
  l_nls_held       ap_lookup_codes.displayed_field%TYPE;

BEGIN

  SELECT  a1c1.displayed_field, a1c2.displayed_field
  INTO    l_nls_released, l_nls_held
  FROM    ap_lookup_codes a1c1, ap_lookup_codes a1c2
  WHERE   a1c1.lookup_type = 'INVOICE HOLD STATUS'
  AND     a1c1.lookup_code = 'RELEASED'
  AND     a1c2.lookup_type = 'INVOICE HOLD STATUS'
  AND     a1c2.lookup_code = 'HELD';



  c_nls_released   := l_nls_released;
  c_nls_held       := l_nls_held;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION get_flexdata RETURN BOOLEAN IS

BEGIN


 null;
   RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;

--function c_accepted_fmtformula(C_MATCHING_BASIS in varchar2, C_ACCEPTED in varchar2) return varchar2 is
function c_accepted_fmtformula(C_MATCHING_BASIS in varchar2, C_ACCEPTED in varchar2) return varchar2 is
begin
   /*SRW.REFERENCE(C_ACCEPTED);*/null;

   /*SRW.REFERENCE(C_NLS_NA);*/null;


  IF(C_MATCHING_BASIS ='QUANTITY') THEN

    RETURN(C_ACCEPTED);

  ELSIF (C_MATCHING_BASIS ='AMOUNT') THEN

    RETURN(C_NLS_NA);

  END IF;
end;

--Functions to refer Oracle report placeholders--

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
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_NLS_RELEASED_p return varchar2 is
	Begin
	 return C_NLS_RELEASED;
	 END;
 Function C_NLS_HELD_p return varchar2 is
	Begin
	 return C_NLS_HELD;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_NLS_NA_p return varchar2 is
	Begin
	 return C_NLS_NA;
	 END;
END AP_APXINMHD_XMLP_PKG ;


/
