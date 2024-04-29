--------------------------------------------------------
--  DDL for Package Body FA_FAS460_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS460_XMLP_PKG" AS
/* $Header: FAS460B.pls 120.0.12010000.1 2008/07/28 13:14:54 appldev ship $ */
function BeforeReport return boolean is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
END;  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
RETURN(TRUE);  return (TRUE);
end;
function BOOKFormula return VARCHAR2 is
begin
DECLARE
         l_book     VARCHAR2(15);
         l_accounting_flex_structure  number(15);
         l_currency_code  VARCHAR2(15);
         l_precision      number(15);
	 l_per_ctr		number(15);
BEGIN
         select bc.book_type_code,
                bc.accounting_flex_structure,
                sob.currency_code,
                cur.precision,
		dp.period_counter
         into   l_book,
                l_accounting_flex_structure,
                l_currency_code,
                l_precision,
		l_per_ctr
         from fa_book_controls bc,
              gl_sets_of_books sob,
              fnd_currencies cur,
		fa_deprn_periods dp
         where bc.book_type_code = P_BOOK
         and   bc.date_ineffective is null
         and   sob.set_of_books_id = bc.set_of_books_id
         and   sob.currency_code = cur.currency_code
	and 	dp.book_type_code = P_BOOK
	and	P_END_DATE_ACQ between
 	  dp.period_open_date and 				 nvl(dp.period_close_date, P_END_DATE_ACQ+1);
         Currency_Code := l_currency_code;
         Accounting_flex_structure := l_accounting_flex_structure;
         Precision := l_precision;
	 P_Per_Ctr := l_per_ctr;
         return(l_book);
EXCEPTION
  when no_data_found then
    Currency_Code := null;
    Accounting_flex_structure := null;
    Precision := null;
    P_Per_Ctr := null;
END;
RETURN NULL; end;
function report_nameformula(Company_Name in varchar2, ACCT_BAL_LPROMPT in varchar2) return varchar2 is
begin
DECLARE
        l_report_name  VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
        RP_Company_Name := Company_Name;
        RP_BAL_LPROMPT := ACCT_BAL_LPROMPT;
  SELECT cr.concurrent_program_id
  INTO l_conc_program_id
  FROM FND_CONCURRENT_REQUESTS cr
  WHERE cr.program_application_id = 140
  AND   cr.request_id = P_CONC_REQUEST_ID;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp
  WHERE
      cp.concurrent_program_id= l_conc_program_id
  and cp.application_id = 140;
l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
        RP_Report_Name := l_report_name;
        RETURN(l_report_name);
EXCEPTION
        WHEN OTHERS THEN
         RP_REPORT_NAME := ':Property Tax Report:';
         RETURN(RP_REPORT_NAME);
END;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function CURRENCY_CODE_p return varchar2 is
	Begin
	 return CURRENCY_CODE;
	 END;
 Function ACCOUNTING_FLEX_STRUCTURE_p return number is
	Begin
	 return ACCOUNTING_FLEX_STRUCTURE;
	 END;
 Function PRECISION_p return number is
	Begin
	 return PRECISION;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
	 --modified
 Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2 is
	Begin
	 RP_BAL_LPROMPT := ACCT_BAL_LPROMPT;
	 return RP_BAL_LPROMPT;
	 END;
END FA_FAS460_XMLP_PKG ;


/
