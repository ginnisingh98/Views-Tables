--------------------------------------------------------
--  DDL for Package Body FA_FASUNPLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASUNPLD_XMLP_PKG" AS
/* $Header: FASUNPLDB.pls 120.0.12010000.1 2008/07/28 13:17:48 appldev ship $ */

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';





  SELECT  sob.currency_code,
          c.precision,
          c.minimum_accountable_unit,
          c.description
  INTO    base_curr,
          prec,
          min_au,
          descr
  FROM    fnd_currencies_vl c,
          fa_book_controls bc,
          gl_sets_of_books sob
  WHERE   bc.book_type_code   = P_ASSET_BOOK_TYPE
  AND     sob.set_of_books_id = bc.set_of_books_id
  AND     c.currency_code     = sob.currency_code ;

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
   nls_void      ap_lookup_codes.displayed_field%TYPE;    nls_na        ap_lookup_codes.displayed_field%TYPE;    nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fa_lookups.meaning%TYPE;     nls_no        fa_lookups.meaning%TYPE;
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


   fnd_message.set_name('JE', 'JE_ALL_DATA_NOT_FOUND');
   C_NLS_NO_DATA_EXISTS := substr(fnd_message.get, 1, 50);



   C_NLS_NO_DATA_EXISTS := '*****  '||C_NLS_NO_DATA_EXISTS ||'  *****';


   fnd_message.set_name('JE', 'JE_ALL_END_OF_REPORT');
   C_NLS_NO_DATA_EXISTS := substr(fnd_message.get, 1, 50);


   C_NLS_END_OF_REPORT := '*****  '||C_NLS_END_OF_REPORT||'  *****';

RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function BeforeReport return boolean is
x boolean;
begin
x:= P_DEPRN_TYPEValidTrigger;
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;

DECLARE

  init_failure    EXCEPTION;

BEGIN


SELECT DECODE(NVL(TO_CHAR(period_close_date), 'NULL'), 'NULL', 'Open', 'Closed')
INTO   C_Last_Open
FROM   fa_deprn_periods
WHERE  book_type_code = P_ASSET_BOOK_TYPE
AND    period_name    = P_PERIOD_END_NAME;



  C_REPORT_START_DATE := sysdate;




  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;


  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;


  IF (GET_NLS_STRINGS <> TRUE) THEN      RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;


  IF (get_base_curr_data <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;


  IF (p_debug_switch = 'Y') THEN
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

function P_DEPRN_TYPEValidTrigger return boolean is
begin

if P_DEPRN_TYPE is null
then
   P_DEPRN_TYPE_1 := '''%''';
end if;  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_base_currency_code_p return varchar2 is
	Begin
	 return C_base_currency_code;
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
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
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
 Function C_Last_Open_p return varchar2 is
	Begin
	 return C_Last_Open;
	 END;
END FA_FASUNPLD_XMLP_PKG ;


/
