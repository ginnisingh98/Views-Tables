--------------------------------------------------------
--  DDL for Package Body AP_APXINDIA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINDIA_XMLP_PKG" AS
/* $Header: APXINDIAB.pls 120.0 2007/12/27 07:49:02 vjaganat noship $ */
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
  --IF (p_debug_switch = 'Y') THEN
  --   /*SRW.MESSAGE('2','After Get_Company_Name');*/null;
  --END IF;
  IF (get_nls_strings() <> TRUE) THEN      RAISE init_failure;
  END IF;
  --IF (p_debug_switch = 'Y') THEN
  --   /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;
  --END IF;
  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  --IF (p_debug_switch = 'Y') THEN
  --   /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;
  --END IF;
  IF (get_header_values() <> TRUE) THEN       RAISE init_failure;
  END IF;
  --IF (p_debug_switch = 'Y') THEN
  --   /*SRW.MESSAGE('5','After Custom_Init');*/null;
  --END IF;
--IF (P_DEBUG_SWITCH = 'Y') THEN
--     /*SRW.BREAK;*/null;
--END IF;
P_DISC_THRU_DATE_p := to_char(P_DISC_THRU_DATE,'DD-MON-YY');
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    --RAISE_APPLICATION_ERROR(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
    --RAISE_APPLICATION_ERROR(-20101,'PROGRAM_ABORT');
    return true;
END;  return (TRUE);
end;
FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_all       ap_lookup_codes.displayed_field%TYPE;
BEGIN
   nls_all     := '';
   SELECT  al.displayed_field
   INTO    nls_all
   FROM    ap_lookup_codes al
   WHERE   al.lookup_type = 'NLS REPORT PARAMETER'
     AND   al.lookup_code = 'ALL';
   c_nls_all := nls_all;
   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;
   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;
   /*c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';*/
   c_nls_no_data_exists := 'No Data Found';
   /*SRW.USER_EXIT('FND MESSAGE_NAME APPl="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;
   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;
   /*c_nls_end_of_report := '*** '||c_nls_end_of_report||' ***';*/
   c_nls_end_of_report := 'End of Report';
RETURN (TRUE);
RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;
FUNCTION  get_base_curr_data  RETURN BOOLEAN IS
  base_curr   VARCHAR2(15);        prec        NUMBER;          min_au      NUMBER;
BEGIN
  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit
  INTO    base_curr,
          prec,
          min_au
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;
  c_base_currency_code  := base_curr;
  c_base_precision      := prec;
  c_base_min_acct_unit  := min_au;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
FUNCTION  get_company_name    RETURN BOOLEAN IS
  c_name      VARCHAR2(30);        test_date   VARCHAR2(9);         l_report_start_date  DATE := sysdate;
BEGIN
  C_REPORT_START_DATE := l_report_start_date;
  SELECT  substr(g.name,1,30), to_char(sysdate-1, 'DD-MON-RR')
  INTO    c_name, test_date
  FROM    gl_sets_of_books g, ap_system_parameters P
  WHERE   g.set_of_books_id   =  P.set_of_books_id;
  c_company_name_header  := c_name;
  c_test_date            := test_date;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function AfterReport return boolean is
begin
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
FUNCTION  custom_init         RETURN BOOLEAN IS
BEGIN
RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
FUNCTION  get_header_values   RETURN BOOLEAN IS
ven_name     po_vendors.vendor_name%TYPE;
ven_id       VARCHAR2(15);
vendor_type  VARCHAR2(25);
pay_group    VARCHAR2(25);
BEGIN
/*commented by raj ven_id      := P_VEN_ID;
vendor_type := P_VENDOR_TYPE;
pay_group   := P_PAY_GROUP;*/
ven_id      := nvl(P_VEN_ID, 'All');
vendor_type := nvl(P_VENDOR_TYPE, 'All');
pay_group   := nvl(P_PAY_GROUP, 'All');
IF (VEN_ID IS NULL OR vendor_type IS NULL or pay_group IS NULL) THEN
/*SRW.MESSAGE('60','NULL value for Vendor Type, Pay Group, or Vendor ID');*/null;
RETURN(FALSE);
END IF;
IF (vendor_type = 'All') THEN
C_VENDOR_TYPE := C_NLS_ALL;
ELSE C_VENDOR_TYPE := vendor_type;
END IF;
IF (pay_group = 'All') THEN
C_PAY_GROUP := C_NLS_ALL;
ELSE C_PAY_GROUP := pay_group;
END IF;
IF (ven_id = 'All') THEN
C_VEN_NAME := C_NLS_ALL;
RETURN(TRUE);
END IF;
SELECT vendor_name
INTO   ven_name
FROM   po_vendors
WHERE  vendor_id = to_number(ven_id);
C_VEN_NAME := ven_name;
RETURN(TRUE);
RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);
END;
--Functions to refer Oracle report placeholders--
 Function C_BASE_MIN_ACCT_UNIT_p return number is
	Begin
	 return C_BASE_MIN_ACCT_UNIT;
	 END;
 Function C_VEN_NAME_p return varchar2 is
	Begin
	 return C_VEN_NAME;
	 END;
 Function C_BASE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return C_BASE_CURRENCY_CODE;
	 END;
 Function C_TEST_DATE_p return varchar2 is
	Begin
	 return C_TEST_DATE;
	 END;
 Function C_BASE_PRECISION_p return number is
	Begin
	 return C_BASE_PRECISION;
	 END;
 Function C_NLS_ALL_p return varchar2 is
	Begin
	 return C_NLS_ALL;
	 END;
 Function C_PAY_GROUP_p return varchar2 is
	Begin
	 return C_PAY_GROUP;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_VENDOR_TYPE_p return varchar2 is
	Begin
	 return C_VENDOR_TYPE;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
	 END;
 Function C_REPORT_RUN_TIME_p return varchar2 is
	Begin
	 return C_REPORT_RUN_TIME;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
END AP_APXINDIA_XMLP_PKG ;


/
