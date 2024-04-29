--------------------------------------------------------
--  DDL for Package Body AP_APXMTDCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXMTDCR_XMLP_PKG" AS
/* $Header: APXMTDCRB.pls 120.1 2007/12/28 06:23:23 vjaganat noship $ */

function BeforeReport return boolean is
begin

DECLARE

  init_failure    EXCEPTION;

BEGIN

   /*SRW.USER_EXIT('FND SRWINIT');*/null;
	CP_END_DATE := to_char(P_END_DATE,'DD-MON-YY');
	CP_START_DATE := to_char(P_START_DATE,'DD-MON-YY');
   C_CURRENCY_FLAG := 'NULL';
   C_PLACE_FLAG := 'N';
   C_PAY_CURRENCY_FLAG := 'NULL';

  IF (get_company_name() <> TRUE) THEN          RAISE init_failure;
  END IF;
  IF (get_nls_strings() <> TRUE) THEN
       null;
  END IF;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;

  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;

EXCEPTION

  WHEN   OTHERS  THEN
   RETURN (FALSE);

END;  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
/*SRW.USER_EXIT('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

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
  l_name                  VARCHAR2(30);     l_sob_id                  NUMBER;

BEGIN

  l_sob_id := p_sob_id;
  SELECT  substr(name,1,30),
          chart_of_accounts_id
  INTO    l_name,
          l_chart_of_accounts_id
  FROM    gl_sets_of_books
  WHERE   set_of_books_id   = l_sob_id;

  c_company_name_header     := l_name;
  c_chart_of_accounts_id    := l_chart_of_accounts_id;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   l_nls_yes       fnd_lookups.meaning%TYPE;
   l_nls_all       ap_lookup_codes.displayed_field%TYPE;
   l_payment_type  ap_lookup_codes.displayed_field%TYPE;
   l_nls_void_payment_not_incl  varchar2(100);
   l_nls_display_supp_address   varchar2(80);
   l_nls_none_ep   ap_lookup_codes.displayed_field%TYPE;

BEGIN




   BEGIN

      SELECT  ly.meaning,
	      la.displayed_field,
              lnep.displayed_field
      INTO    l_nls_yes, l_nls_all, l_nls_none_ep
      FROM    fnd_lookups ly, ap_lookup_codes la, ap_lookup_codes lnep
      WHERE   ly.lookup_type = 'YES_NO'
        AND   ly.lookup_code = 'Y'
	AND   la.lookup_type = 'NLS REPORT PARAMETER'
	AND   la.lookup_code = 'ALL'
        AND   lnep.lookup_type = 'NLS TRANSLATION'
        AND   lnep.lookup_code = 'NONE ELECTRONIC PAYMENT';


      c_nls_yes := l_nls_yes;
      c_nls_all := l_nls_all;
      c_nls_none_ep := l_nls_none_ep;


   EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
   END;


   if P_PAYMENT_TYPE is null then
	C_NLS_PAYMENT_TYPE := C_NLS_ALL;
   else
	SELECT  displayed_field
	INTO    l_payment_type
	FROM    ap_lookup_codes
	WHERE   lookup_code = P_PAYMENT_TYPE
	AND     lookup_type = 'PAYMENT TYPE';

	C_NLS_PAYMENT_TYPE := l_payment_type;
   end if;




   SELECT meaning
   INTO   l_nls_display_supp_address
   FROM   fnd_lookups
   WHERE  lookup_type = 'YES_NO'
   AND    lookup_code = P_ADDR_OPTION;

   C_NLS_ADDR_OPTION := l_nls_display_supp_address;

   BEGIN
   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;

   c_nls_no_data_exists := 'No Data Found';

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;

   c_nls_end_of_report := 'End of Report';


   EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
   END;
   BEGIN
      SELECT '*  '||description
      INTO   l_nls_void_payment_not_incl
      FROM   ap_lookup_codes
      WHERE  lookup_type = 'NLS REPORT PARAMETER'
        AND  lookup_code = 'VOID PAYMENT NOT INCLUDED';

      c_nls_void_payment_not_incl := l_nls_void_payment_not_incl;
   EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
   END;
   RETURN (TRUE);


END;

function  get_currency    (currency_code_1 in varchar2, pay_currency_code in varchar2) return boolean is
   l_currency       VARCHAR2(3);
   l_currency_name  VARCHAR2(25);
   l_pay_currency_name  VARCHAR2(27);

BEGIN
   SELECT c1.currency_code, c1.name, c2.name
   INTO   l_currency, l_currency_name,
          l_pay_currency_name
   FROM   fnd_currencies_vl c1, fnd_currencies_vl c2
   WHERE  c1.currency_code = currency_code_1
     AND  c2.currency_code = pay_currency_code;

   return (TRUE);
END;

function check_flag(C_CURRENCY_CODE in varchar2, C_PAY_CURRENCY_CODE in varchar2) return varchar2 is
BEGIN
  IF (C_CURRENCY_FLAG = 'NULL') THEN
      C_CURRENCY_FLAG := C_CURRENCY_CODE;
  END IF;
  IF (C_PAY_CURRENCY_FLAG = 'NULL') THEN
      C_PAY_CURRENCY_FLAG := C_PAY_CURRENCY_CODE;
  END IF;

  IF (C_CURRENCY_FLAG <> C_CURRENCY_CODE) THEN
      C_PLACE_FLAG := 'Y';
      RETURN('Y');
  END IF;
  IF (C_PAY_CURRENCY_CODE <> C_PAY_CURRENCY_FLAG)
     THEN
      C_PLACE_FLAG := 'Y';
      RETURN('P');
   END IF;
RETURN NULL; END;

function c_currency_descformula(c_currency_code in varchar2) return varchar2 is
begin

DECLARE
l_currency_desc     fnd_currencies_vl.name%TYPE;
BEGIN
   SELECT c.name
   INTO  l_currency_desc
   FROM fnd_currencies_vl c
   WHERE  c.currency_code = c_currency_code;
   return(l_currency_desc);
EXCEPTION
WHEN OTHERS THEN null;
END;
RETURN NULL; end;

function c_pay_currency_descformula(c_pay_currency_code in varchar2) return varchar2 is
begin

DECLARE
l_currency_desc    fnd_currencies_vl.name%TYPE;
BEGIN
   SELECT c.name
   INTO  l_currency_desc
   FROM fnd_currencies_vl c
   WHERE  c.currency_code = c_pay_currency_code ;
   return(l_currency_desc);
EXCEPTION
WHEN OTHERS THEN null;
END;
RETURN NULL; end;

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
 Function C_NLS_ACTIVE_p return varchar2 is
	Begin
	 return C_NLS_ACTIVE;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_NLS_INACTIVE_p return varchar2 is
	Begin
	 return C_NLS_INACTIVE;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_NLS_VOID_PAYMENT_NOT_INCL_p return varchar2 is
	Begin
	 return C_NLS_VOID_PAYMENT_NOT_INCL;
	 END;
 Function C_CURRENCY_p return varchar2 is
	Begin
	 return C_CURRENCY;
	 END;
 Function C_CURRENCY_FLAG_p return varchar2 is
	Begin
	 return C_CURRENCY_FLAG;
	 END;
 Function C_PAY_CURRENCY_FLAG_p return varchar2 is
	Begin
	 return C_PAY_CURRENCY_FLAG;
	 END;
 Function C_PLACE_FLAG_p return varchar2 is
	Begin
	 return C_PLACE_FLAG;
	 END;
 Function C_VOIDED_FLAG_p return varchar2 is
	Begin
	 return C_VOIDED_FLAG;
	 END;
 Function C_NLS_PAYMENT_TYPE_p return varchar2 is
	Begin
	 return C_NLS_PAYMENT_TYPE;
	 END;
 Function C_NLS_ALL_p return varchar2 is
	Begin
	 return C_NLS_ALL;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_NLS_ADDR_OPTION_p return varchar2 is
	Begin
	 return C_NLS_ADDR_OPTION;
	 END;
 Function C_NLS_NONE_EP_p return varchar2 is
	Begin
	 return C_NLS_NONE_EP;
	 END;
END AP_APXMTDCR_XMLP_PKG ;


/
