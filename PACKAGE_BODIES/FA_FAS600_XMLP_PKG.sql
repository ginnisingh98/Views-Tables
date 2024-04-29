--------------------------------------------------------
--  DDL for Package Body FA_FAS600_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS600_XMLP_PKG" AS
/* $Header: FAS600B.pls 120.0.12010000.1 2008/07/28 13:15:13 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_book_class VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_distribution_source_book VARCHAR2(15);
  l_precision NUMBER(15);
  l_current_fiscal_year NUMBER(15);
BEGIN
  SELECT bc.book_type_code,
         bc.book_class,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         sob.currency_code,
         cur.precision,
         bc.current_fiscal_year
  INTO   l_book,
         l_book_class,
         l_accounting_flex_Structure,
         l_distribution_source_book,
         l_currency_code,
         l_precision,
         l_current_fiscal_year
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
  Book_Class := l_book_class;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_SOurce_Book :=l_distribution_source_book;
  Currency_Code := l_currency_code;
  P_Min_Precision := l_precision;
  Current_Fiscal_Year := l_current_fiscal_year;
  return(l_book);
END;
RETURN NULL; end;
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
BEGIN
--Added during DT Fix
  P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp,
         FND_CONCURRENT_REQUESTS cr
  WHERE  cr.request_id = P_CONC_REQUEST_ID
  AND    cp.application_id = cr.program_application_id
  AND    cp.concurrent_program_id=cr.concurrent_program_id;
  l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
  RP_Report_Name := l_report_name;
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := ':Asset Register Report:';
    RETURN(RP_Report_Name);
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
 Function Current_Fiscal_Year_p return number is
	Begin
	 return Current_Fiscal_Year;
	 END;
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_APROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_APROMPT;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function Book_Class_p return varchar2 is
	Begin
	 return Book_Class;
	 END;
 Function Distribution_Source_Book_p return varchar2 is
	Begin
	 return Distribution_Source_Book;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_MAJ_LPROMPT_p return varchar2 is
	Begin
	 return RP_MAJ_LPROMPT;
	 END;
END FA_FAS600_XMLP_PKG ;


/
