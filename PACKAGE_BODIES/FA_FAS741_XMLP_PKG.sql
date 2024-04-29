--------------------------------------------------------
--  DDL for Package Body FA_FAS741_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS741_XMLP_PKG" AS
/* $Header: FAS741B.pls 120.0.12010000.1 2008/07/28 13:15:24 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_distribution_source_book VARCHAR2(15);
  l_precision NUMBER(15);
BEGIN
  SELECT bc.book_type_code,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         sob.currency_code,
         cur.precision
  INTO   l_book,
         l_accounting_flex_Structure,
         l_distribution_source_book,
         l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_SOurce_Book :=l_distribution_source_book;
  Currency_Code := l_currency_code;
  return(l_book);
END;
RETURN NULL; end;
function Period1Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  DATE;
BEGIN
  SELECT period_name,
         period_open_date
  INTO   l_period_name,
         l_period_POD
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
  Period1_POD := l_period_POD;
  return(l_period_name);
END;
RETURN NULL; end;
function Report_NameFormula return VARCHAR2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
--Added during DT Fixes
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fixes
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
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RETURN(':Asset Reclassification Reconciliation Report:');
END;
RETURN NULL; end;
function Period2Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_PCD  DATE;
BEGIN
  SELECT period_name,
         nvl(period_close_date, sysdate)
  INTO   l_period_name,
         l_period_PCD
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
  Period2_PCD := l_period_PCD;
  return(l_period_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        PERIOD2_PCD := sysdate;
        RETURN(P_PERIOD2);
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
function MEANING_CIPFormula return VARCHAR2 is
begin
DECLARE
         l_meaning VARCHAR2(80);
BEGIN
          select meaning
          into   l_meaning
          from fa_lookups
          where lookup_type = 'ASSET TYPE'
          and   lookup_code = 'CIP';
RETURN(l_meaning);
END;
RETURN NULL; end;
function MEANING_CAPFormula return VARCHAR2 is
begin
DECLARE
        l_meaning VARCHAR2(80);
BEGIN
      select meaning
      into   l_meaning
      from   fa_lookups
      where  lookup_type = 'ASSET TYPE'
      and    lookup_code = 'CAPITALIZED';
      return(l_meaning);
END;
RETURN NULL; end;
function MEANING_EXPFormula return VARCHAR2 is
begin
DECLARE
        l_meaning   VARCHAR2(80);
BEGIN
        select meaning
        into   l_meaning
        from   FA_LOOKUPS
        where  lookup_type = 'ASSET TYPE'
        and    lookup_code = 'EXPENSED';
return(l_meaning);
END;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function ACCT_CC_LPROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_LPROMPT;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function Distribution_Source_Book_p return varchar2 is
	Begin
	 return Distribution_Source_Book;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
END FA_FAS741_XMLP_PKG ;


/
