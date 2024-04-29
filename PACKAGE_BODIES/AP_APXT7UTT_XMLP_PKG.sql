--------------------------------------------------------
--  DDL for Package Body AP_APXT7UTT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXT7UTT_XMLP_PKG" AS
/* $Header: APXT7UTTB.pls 120.0 2007/12/27 08:37:51 vjaganat noship $ */

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';

  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit,
          c.description
  INTO    base_curr,
          prec,
          min_au,
          descr
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;

  C_BASE_CURRENCY_CODE  := base_curr;
  C_BASE_PRECISION      := prec;
  C_BASE_MIN_ACCT_UNIT  := min_au;
  C_BASE_DESCRIPTION    := descr;

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


C_NLS_NO_DATA_EXISTS := 'No Data Found';
C_NLS_END_OF_REPORT  := 'End of Report';

RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function BeforeReport return boolean is
begin

LP_start_date := to_char(P_start_date, 'DD-MON-YY');
LP_end_date := to_char(P_end_date, 'DD-MON-YY');

DECLARE

  init_failure    EXCEPTION;

BEGIN


  C_REPORT_START_DATE := sysdate;




  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

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























   IF(custom_init() <> TRUE) THEN
     RAISE init_failure;
   END IF;
   IF (p_debug_switch in ('y','Y')) THEN
      /*SRW.MESSAGE('13','After Custom_Init');*/null;

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

function afterreport(C_tot_vendor in number, C_tot_vendor_R in number) return boolean is
begin

DECLARE
  closing_failure    EXCEPTION;
BEGIN
   IF C_tot_vendor = 0 AND C_tot_vendor_R = 0 THEN
      /*SRW.MESSAGE('16','No information found - check parameters.');*/null;

   ELSIF C_tot_vendor = 0 THEN
      /*SRW.MESSAGE('17','No mis-matched distributions found');*/null;

   ELSIF C_tot_vendor_R = 0 THEN
      /*SRW.MESSAGE('18','No distributions found for 1099 Vendors');*/null;

   ELSE
      /*SRW.MESSAGE('19','*********** Report completed ***********');*/null;

   END IF;
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
  l_curdate               varchar2(15);
BEGIN

  if P_SET_OF_BOOKS_ID is not null then
     l_sob_id := p_set_of_books_id;
     SELECT  name, to_char(sysdate,'DD-MON-RR HH24:MI'),
             chart_of_accounts_id
     INTO    l_name, l_curdate,
             l_chart_of_accounts_id
     FROM    gl_sets_of_books
     WHERE   set_of_books_id = l_sob_id;

     c_company_name     := l_name;
     c_chart_of_accounts_id    := l_chart_of_accounts_id;
     c_curdate                 := l_curdate;

  end if;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

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

function c_update_miscsformula(type_1099 in varchar2, vendor_id in number) return varchar2 is
begin

BEGIN
 IF P_update_misc = 'UPDATE' THEN
   UPDATE ap_invoice_distributions id
   SET    type_1099 = type_1099
   WHERE  nvl(type_1099,1) <> nvl(type_1099,1)
   AND    invoice_id in (SELECT i.invoice_id
                         FROM   AP_Invoices i, AP_Invoice_Payments ip
                         WHERE  i.vendor_id = vendor_id
                         AND   i.invoice_id = ip.invoice_id
                         AND   nvl(ip.accounting_date,sysdate) between
                                  P_start_date and
                                  P_end_date )
   AND    id.line_type_lookup_code  <> 'AWT';     return ('Y');
 ELSE
   return ('N');
 END IF;
EXCEPTION
 WHEN OTHERS THEN
   return ('N');
END;
RETURN NULL; end;

function c_update_regionsformula(region_R in varchar2, vendor_id_R in number, site_id_R in number) return varchar2 is
begin

DECLARE
 l_region   varchar2(25);
BEGIN
 IF P_update_region = 'UPDATE' THEN
   IF P_region_code='VENDOR SITE' THEN
      l_region := region_R;
   ELSE
      l_region := P_region_code;
   END IF;

   IF P_region_code <> 'INCOME TAX REPORTING SITE' then
     UPDATE ap_invoice_distributions id
     SET    income_tax_region = l_region
     WHERE  ( (P_region_code <>'VENDOR SITE'
               AND NVL(id.income_tax_region, 'DuMmY') <> P_region_code)
             OR (P_region_code = 'VENDOR SITE'
                 AND NVL(id.income_tax_region, 'DuMmY') <> l_region))
            AND id.invoice_id in (SELECT i.invoice_id
                                  FROM   AP_Invoices i, AP_Invoice_Payments ip
                                  WHERE  i.vendor_id = vendor_id_R
                                  AND    i.vendor_site_id = site_id_R
                                  AND    i.invoice_id = ip.invoice_id
                                  AND    nvl(ip.accounting_date,sysdate) between
                                         P_start_date and
                                         P_end_date );
   ELSE
     UPDATE ap_invoice_distributions id
     SET    income_tax_region = (select pvs.state
                                from po_vendor_sites pvs
                                where pvs.tax_reporting_site_flag= 'Y'
                                and pvs.vendor_id=vendor_id_R)
     WHERE  id.invoice_id in (SELECT i.invoice_id
                              FROM   AP_Invoices i, AP_Invoice_Payments ip
                              WHERE  i.vendor_id = vendor_id_R
                              AND    i.vendor_site_id = site_id_R
                              AND    i.invoice_id = ip.invoice_id
                              AND    nvl(ip.accounting_date,sysdate) between
                                     P_start_date and P_end_date )
     AND nvl(id.income_tax_region,'DuMmY')  <>
                                    (select pvs2.state                                                from po_vendor_sites pvs2
                                     where pvs2.tax_reporting_site_flag= 'Y'
                                     and pvs2.vendor_id=vendor_id_R);




   END IF;



 END IF;
EXCEPTION
 WHEN OTHERS THEN
   return ('N');
END;
RETURN NULL; end;

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
 --Commented By Raj
 /*Function Applications Template Report_p return varchar2 is
	Begin
	 return Applications Template Report;
	 END;*/
 Function Applications_Template_Report_p return varchar2 is
	Begin
	 return Applications_Template_Report;
	 END;
 Function C_COMPANY_NAME_p return varchar2 is
	Begin
	 return C_COMPANY_NAME;
	 END;
 Function C_curdate_p return varchar2 is
	Begin
	 return C_curdate;
	 END;
END AP_APXT7UTT_XMLP_PKG ;


/
