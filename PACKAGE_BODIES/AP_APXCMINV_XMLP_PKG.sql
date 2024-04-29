--------------------------------------------------------
--  DDL for Package Body AP_APXCMINV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXCMINV_XMLP_PKG" AS
/* $Header: APXCMINVB.pls 120.0 2007/12/27 07:36:29 vjaganat noship $ */

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;

IF (p_debug_switch = 'Y') THEN
   /*SRW.MESSAGE('1','After SRWINIT');*/null;

END IF;


LP_DATE_FROM:=TO_CHAR(P_DATE_FROM,'DD-MON-YY');
LP_DATE_TO:=TO_CHAR(P_DATE_TO,'DD-MON-YY');

select gl.name, gl.set_of_books_id, gl.chart_of_accounts_id
into P_NAME, P_SET_OF_BOOKS_ID, P_CHART_OF_ACCOUNTS_ID
from gl_sets_of_books gl, ap_system_parameters ap
where gl.set_of_books_id = ap.set_of_books_id;

IF (p_debug_switch = 'Y') THEN
   /*SRW.MESSAGE('2','After Ledger id, chart of accounts id');*/
   null;

END IF;



if  P_VENDOR_FROM IS NULL and P_VENDOR_TO IS NULL
  then  C_VENDOR := ' ';
 elsif  P_VENDOR_FROM  IS NOT NULL and P_VENDOR_TO IS NOT NULL


  then  C_VENDOR := 'and upper(po1.vendor_name)  >='
        ||''''||upper(REPLACE(P_VENDOR_FROM,'''',''''''))||''''||'and
         upper(po1.vendor_name) <='||''''||upper(REPLACE(P_VENDOR_TO,'''',''''''))||'''';
/*srw.message(101,C_VENDOR);*/null;

 elsif  P_VENDOR_FROM IS NOT NULL
  then  C_VENDOR := 'and upper(po1.vendor_name) >='
        ||''''||upper(REPLACE(P_VENDOR_FROM,'''',''''''))||'''';
 else  C_VENDOR := 'and upper(po1.vendor_name) <='
       ||''''||upper(REPLACE(P_VENDOR_TO,'''',''''''))||'''';
end if;



if  P_DATE_FROM is Null and P_DATE_TO is Null
then C_DATE := ' ';
elsif P_DATE_FROM is not Null and P_DATE_TO is not Null
then C_DATE := 'and i.invoice_date >=
  '''||to_char(P_DATE_FROM)||''' and i.invoice_date <=
  '''||to_char(P_DATE_TO)||''' ';
elsif P_DATE_FROM is not Null
then
C_DATE := 'and i.invoice_date >='''||to_char(P_DATE_FROM)||''' ';
else
C_DATE := 'and i.invoice_date <='''||to_char(P_DATE_TO)||''' ';
end if;



DECLARE
 init_failure        EXCEPTION;
BEGIN

  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After get_base_curr_data');*/null;

  END IF;

 RETURN (TRUE);

EXCEPTION

WHEN OTHERS THEN
 /* RAISE_application_error(-20101,null);SRW.PROGRAM_ABORT;*/

 null;

END;

  return (TRUE);
end;

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';

  SELECT  p.base_currency_code,
          c.precision,
          nvl(c.minimum_accountable_unit,0),
          c.description
  INTO    base_curr,
          prec,
          min_au,
          descr
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;

  c_base_currency_code  := base_curr;
  c_base_precision      := prec;
  c_base_min_acct_unit  := nvl(min_au,0);
  c_base_description    := descr;

  RETURN (TRUE);


RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function AfterReport return boolean is
begin

BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;

   IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('4','After SRWEXIT');*/null;

   END IF;
EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_VENDOR_p return varchar2 is
	Begin
	 return C_VENDOR;
	 END;
 Function C_DATE_p return varchar2 is
	Begin
	 return C_DATE;
	 END;
 Function C_BASE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return C_BASE_CURRENCY_CODE;
	 END;
 Function C_BASE_MIN_ACCT_UNIT_p return number is
	Begin
	 return C_BASE_MIN_ACCT_UNIT;
	 END;
 Function C_BASE_PRECISION_p return number is
	Begin
	 return C_BASE_PRECISION;
	 END;
 Function C_BASE_DESCRIPTION_p return varchar2 is
	Begin
	 return C_BASE_DESCRIPTION;
	 END;
END AP_APXCMINV_XMLP_PKG ;



/
