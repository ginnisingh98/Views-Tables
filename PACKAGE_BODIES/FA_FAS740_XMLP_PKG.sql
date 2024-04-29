--------------------------------------------------------
--  DDL for Package Body FA_FAS740_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS740_XMLP_PKG" AS
/* $Header: FAS740B.pls 120.0.12010000.1 2008/07/28 13:15:22 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_precision NUMBER(15);
  l_dist_source_book VARCHAR2(15);
BEGIN
  SELECT bc.book_type_code,
	 distribution_source_book,
         bc.accounting_flex_structure,
         sob.currency_code,
         cur.precision
  INTO   l_book,
	 l_dist_source_book,
         l_accounting_flex_Structure,
         l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Currency_Code := l_currency_code;
  P_Min_Precision := l_precision;
  dist_source_book := l_dist_source_book;
  return(l_book);
END;
RETURN NULL; end;
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;
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
  Period_From := P_PERIOD1;
  Period_To := P_PERIOD2;
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := 'Asset Reclassification Report';
    Period_From := P_PERIOD1;
    Period_To :=  P_PERIOD2;
    RETURN('Asset Reclassification Report');
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function DIST_SOURCE_BOOK_p return varchar2 is
	Begin
	 return DIST_SOURCE_BOOK;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function PERIOD_FROM_p return varchar2 is
	Begin
	 return PERIOD_FROM;
	 END;
 Function PERIOD_TO_p return varchar2 is
	Begin
	 return PERIOD_TO;
	 END;
END FA_FAS740_XMLP_PKG ;


/
