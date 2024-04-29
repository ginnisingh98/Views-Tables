--------------------------------------------------------
--  DDL for Package Body FA_FAS410_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS410_XMLP_PKG" AS
/* $Header: FAS410B.pls 120.0.12010000.1 2008/07/28 13:14:18 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_book_class VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_distribution_source_book VARCHAR2(15);
  l_precision NUMBER(15);
BEGIN
  SELECT bc.book_type_code,
         bc.book_class,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         sob.currency_code,
         cur.precision
  INTO   l_book,
         l_book_class,
         l_accounting_flex_Structure,
         l_distribution_source_book,
         l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code   = cur.currency_code;
  Book_Class := l_book_class;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_SOurce_Book :=l_distribution_source_book;
  Currency_Code := l_currency_code;
  return(l_book);
END;
RETURN NULL; end;
function Report_NameFormula return VARCHAR2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
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
    RETURN(':Asset Inventory Report:');
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
function cur_periodformula(Book in varchar2) return varchar2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_PC   NUMBER(15);
  l_flag 	NUMBER(15); BEGIN
  l_flag := 0;
  SELECT period_name,
         period_counter
  INTO   l_period_name,
         l_period_PC
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = Book
  AND    period_close_date IS NULL;
 select count(*) into l_flag from fa_deprn_summary
		 where book_type_code = Book and
		 period_counter = l_period_PC;
if l_flag = 0 then
  Cur_Period_PC := l_period_PC;
else
  Cur_Period_PC := l_period_PC + 1;
end if;
  RETURN(l_period_name);
EXCEPTION when no_data_found then null;  END;
RETURN NULL; end;
function as_nbvformula(as_cost in number, as_reserve in number) return number is
begin
return(as_cost - as_reserve);
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
 Function Book_Class_p return varchar2 is
	Begin
	 return Book_Class;
	 END;
 Function Distribution_Source_Book_p return varchar2 is
	Begin
	 return Distribution_Source_Book;
	 END;
 Function Cur_Period_PC_p return number is
	Begin
	 return Cur_Period_PC;
	 END;
END FA_FAS410_XMLP_PKG ;


/
