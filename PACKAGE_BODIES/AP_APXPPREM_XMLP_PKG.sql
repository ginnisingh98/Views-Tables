--------------------------------------------------------
--  DDL for Package Body AP_APXPPREM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXPPREM_XMLP_PKG" AS
/* $Header: APXPPREMB.pls 120.0 2007/12/27 08:24:46 vjaganat noship $ */

DO_SQL_FAILURE EXCEPTION;

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;     date_today  date;

BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';

  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit,
          c.description,
          sysdate
  INTO    base_curr,
          prec,
          min_au,
          descr,
          date_today
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;

  c_base_currency_code  := base_curr;
  c_base_precision      := prec;
  c_base_min_acct_unit  := min_au;
  c_base_description    := descr;
  c_report_start_date   := date_today;
  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function custom_init return boolean is

begin

   if P_VENDOR_ID is not null then
      C_VENDOR_ID_PREDICATE := 'and inv1.vendor_id = '||to_char(P_VENDOR_ID);
      ELSE
      C_VENDOR_ID_PREDICATE := ' ';
   end if;

   if P_INVOICE_ID is not null then
      C_INVOICE_ID_PREDICATE := 'and inv1.invoice_id = '||to_char(P_INVOICE_ID);
      ELSE
      C_INVOICE_ID_PREDICATE := ' ';
   end if;

   if P_PREPAY_ID is not null then
      C_PREPAY_ID_PREDICATE := 'and pp.invoice_id = '||to_char(P_PREPAY_ID);
      ELSE
      C_PREPAY_ID_PREDICATE := ' ';
   end if;




   if P_START_DATE is not null then
      C_START_DATE_PREDICATE := 'and aipp.last_update_date >= '''||to_char(P_START_DATE)||'''';
      ELSE
      C_START_DATE_PREDICATE := ' ';
   end if;

   if P_END_DATE is not null then
      C_END_DATE_PREDICATE := 'and aipp.last_update_date <= '''
		||to_char(P_END_DATE)||'''';
	ELSE
	C_END_DATE_PREDICATE := ' ';
   end if;




   if P_START_DATE is not null then
      C_START_INVOICE_DATE_PREDICATE := 'and inv1.invoice_date >= '''||to_char(P_START_DATE)||'''';
      else
      C_START_INVOICE_DATE_PREDICATE := ' ';
   end if;

   if P_END_DATE is not null then
      C_END_INVOICE_DATE_PREDICATE := 'and inv1.invoice_date <= '''
		||to_char(P_END_DATE)||'''';
	else
	C_END_INVOICE_DATE_PREDICATE := ' ';
   end if;








   return(TRUE);

RETURN NULL; exception
   when OTHERS then
	return(FALSE);


end;

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN

   nls_all     := '';
   nls_yes     := '';
   nls_no      := '';

   SELECT  ly.meaning,
           ln.meaning,
           la.displayed_field
   INTO    nls_yes,  nls_no,  nls_all
   FROM    fnd_lookups ly,  fnd_lookups ln,  ap_lookup_codes la
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   la.lookup_type = 'NLS REPORT PARAMETER'
     AND   la.lookup_code = 'ALL';

   c_nls_yes := nls_yes;
   c_nls_no  := nls_no;
   c_nls_all := nls_all;

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL= "SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;


   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;


   c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';

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




  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;





  IF (get_nls_strings() <> TRUE) THEN      RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;


  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;























     IF(custom_init() <> TRUE) THEN
       RAISE init_failure;
     END IF;
     IF (p_debug_switch = 'Y') THEN
        /*SRW.MESSAGE('7','After Custom_Init');*/null;

     END IF;




  IF (populate_mls_lexicals() = FALSE) THEN
    RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('8','After populate_mls_lexicals');*/null;

  END IF;







  IF (p_debug_switch = 'Y') THEN
     /*SRW.BREAK;*/null;

  END IF;



  RETURN (TRUE);



EXCEPTION

  WHEN   OTHERS  THEN

    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;  return (TRUE);
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

FUNCTION get_flexdata RETURN BOOLEAN IS

BEGIN


 null;
   RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;

FUNCTION calculate_run_time RETURN BOOLEAN IS
end_date   DATE;
start_date DATE;
BEGIN
end_date   := sysdate;
start_date := C_REPORT_START_DATE;
C_REPORT_RUN_TIME := to_char(to_date('01/01/0001','DD/MM/YYYY') + ((end_date - start_date)),'HH24:MI:SS');
RETURN(TRUE);
RETURN NULL; EXCEPTION
WHEN OTHERS THEN
RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;

function C_SENDER_NAMEFormula return VARCHAR2 is
begin

return(nvl(P_NAME_SRS, replace(P_NAME_EXEC, '_', ' ')));
end;

function C_SENDER_TITLEFormula return VARCHAR2 is
begin

return(nvl(P_TITLE_SRS, replace(P_TITLE_EXEC, '_', ' ')));
end;

function C_SENDER_PHONEFormula return VARCHAR2 is
begin

return(nvl(P_PHONE_SRS, replace(P_PHONE_EXEC, '_', ' ')));
end;

function populate_mls_lexicals return boolean is
  session_language    fnd_languages.nls_language%TYPE;
  base_language       fnd_languages.nls_language%TYPE;
begin

  session_language := '';
  base_language    := '';

    select substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1)
  into   session_language
  from   dual;

    select nls_language
  into   base_language
  from   fnd_languages
  where  installed_flag = 'B';

  lp_language_where := ' and nvl(pvs.language,'||''''||base_language||
                        ''')='||''''||session_language||'''';

  return(TRUE);

  RETURN NULL; exception
    when  DO_SQL_FAILURE /*srw.do_sql_failure */then return(TRUE);
    when others then return(FALSE);
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
 Function C_BASE_DESCRIPTION_p return varchar2 is
	Begin
	 return C_BASE_DESCRIPTION;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
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
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_REPORT_RUN_TIME_p return varchar2 is
	Begin
	 return C_REPORT_RUN_TIME;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_VENDOR_ID_PREDICATE_p return varchar2 is
	Begin
	 return C_VENDOR_ID_PREDICATE;
	 END;
 Function C_INVOICE_ID_PREDICATE_p return varchar2 is
	Begin
	 return C_INVOICE_ID_PREDICATE;
	 END;
 Function C_PREPAY_ID_PREDICATE_p return varchar2 is
	Begin
	 return C_PREPAY_ID_PREDICATE;
	 END;
 Function C_START_DATE_PREDICATE_p return varchar2 is
	Begin
	 return C_START_DATE_PREDICATE;
	 END;
 Function C_END_DATE_PREDICATE_p return varchar2 is
	Begin
	 return C_END_DATE_PREDICATE;
	 END;
 Function C_START_INVOICE_DATE_PREDICAT return varchar2 is
	Begin
	 return C_START_INVOICE_DATE_PREDICATE;
	 END;
 Function C_END_INVOICE_DATE_PREDICATE_p return varchar2 is
	Begin
	 return C_END_INVOICE_DATE_PREDICATE;
	 END;
END AP_APXPPREM_XMLP_PKG ;



/
