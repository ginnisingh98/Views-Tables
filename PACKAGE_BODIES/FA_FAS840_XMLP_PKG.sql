--------------------------------------------------------
--  DDL for Package Body FA_FAS840_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS840_XMLP_PKG" AS
/* $Header: FAS840B.pls 120.0.12010000.1 2008/07/28 13:15:57 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_distribution_source_book VARCHAR2(15);
  l_precision  NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
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
  FROM   FA_BOOK_CONTROLS_MRC_V bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    cur.currency_code = sob.currency_code;
ELSE
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
  AND    cur.currency_code = sob.currency_code;
END IF;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_SOurce_Book :=l_distribution_source_book;
  Currency_Code := l_currency_code;
  Precision := l_precision;
  return(l_book);
END;
RETURN NULL; end;
function Period1Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_PC   NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
 SELECT period_name,
         period_counter
  INTO   l_period_name,
         l_period_PC
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
ELSE
 SELECT period_name,
         period_counter
  INTO   l_period_name,
         l_period_PC
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
END IF;
  Period1_PC := l_period_PC;
  return(l_period_name);
END;
RETURN NULL; end;
function Report_NameFormula return VARCHAR2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
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
    RP_Report_Name := ':Cost Adjustment Report:';
    RETURN(RP_Report_Name);
END;
RETURN NULL; end;
function Period2Formula return VARCHAR2 is
begin
DECLARE
  l_period_name  VARCHAR2(15);
  l_period_PC    NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
      select period_name,
             period_counter
      into   l_period_name,
             l_period_PC
      from   fa_deprn_periods_mrc_v
      where  book_type_code = P_BOOK
      and    period_name = P_PERIOD2;
ELSE
      select period_name,
             period_counter
      into   l_period_name,
             l_period_PC
      from   fa_deprn_periods
      where  book_type_code = P_BOOK
      and    period_name = P_PERIOD2;
END IF;
      PERIOD2_PC := l_period_pc;
      return(l_period_name);
EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RETURN(NULL);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
IF upper(p_mrcsobtype) = 'R'
THEN
  fnd_client_info.set_currency_context(p_ca_set_of_books_id);
END IF;
return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function AfterPForm return boolean is
begin
IF p_ca_set_of_books_id <> -1999
THEN
  BEGIN
   select mrc_sob_type_code, currency_code
   into p_mrcsobtype, lp_currency_code
   from gl_sets_of_books
   where set_of_books_id = p_ca_set_of_books_id;
  EXCEPTION
    WHEN OTHERS THEN
     p_mrcsobtype := 'P';
  END;
ELSE
   p_mrcsobtype := 'P';
END IF;
IF upper(p_mrcsobtype) = 'R'
THEN
  lp_fa_books := 'FA_BOOKS_MRC_V';
  lp_fa_deprn_periods := 'FA_DEPRN_PERIODS_MRC_V';
ELSE
  lp_fa_books := 'FA_BOOKS';
  lp_fa_deprn_periods := 'FA_DEPRN_PERIODS';
END IF;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function PRECISION_p return number is
	Begin
	 return PRECISION;
	 END;
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function Distribution_Source_Book_p return varchar2 is
	Begin
	 return Distribution_Source_Book;
	 END;
 Function Period1_PC_p return number is
	Begin
	 return Period1_PC;
	 END;
 Function Period2_PC_p return number is
	Begin
	 return Period2_PC;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
END FA_FAS840_XMLP_PKG ;


/
