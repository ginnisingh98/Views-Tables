--------------------------------------------------------
--  DDL for Package Body FA_FAS402_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS402_XMLP_PKG" AS
/* $Header: FAS402B.pls 120.0.12010000.1 2008/07/28 13:14:13 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_precision NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT bc.book_type_code,
         bc.accounting_flex_structure,
         sob.currency_code,
         cur.precision
  INTO   l_book,
         l_accounting_flex_Structure,
         l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS_MRC_V bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
ELSE
  SELECT bc.book_type_code,
         bc.accounting_flex_structure,
         sob.currency_code,
         cur.precision
  INTO   l_book,
         l_accounting_flex_Structure,
         l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
END IF;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Currency_Code := l_currency_code;
  P_Min_Precision := l_precision;
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
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
    l_conc_program_id NUMBER;
BEGIN
--Added during DT Fixes
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fixes
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
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := ':Fully Reserved Assets Report:';
    RETURN(RP_Report_Name);
END;
RETURN NULL; end;
function Period2Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_PC   NUMBER(15);
BEGIN
  /*SRW.REFERENCE(PERIOD1_PC);*/null;
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT period_name,
         period_counter
  INTO   l_period_name,
         l_period_PC
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
ELSE
  SELECT period_name,
         period_counter
  INTO   l_period_name,
         l_period_PC
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
END IF;
  Period2_PC := l_period_PC;
  return(l_period_name);
EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
       PERIOD2_PC := PERIOD1_PC;
        RETURN(P_PERIOD2);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
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
function d_lifeformula(LIFE in number, ADJ_RATE in number, BONUS_RATE in number, PROD in number) return varchar2 is
begin
RETURN(FADOLIF(LIFE, ADJ_RATE, BONUS_RATE, PROD));
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
  lp_fa_deprn_summary := 'FA_DEPRN_SUMMARY_MRC_V';
  lp_fa_deprn_detail  := 'FA_DEPRN_DETAIL_MRC_V';
  lp_fa_books         := 'FA_BOOKS_MRC_V';
  lp_fa_book_controls := 'FA_BOOK_CONTROLS_MRC_V';
  lp_fa_deprn_periods := 'FA_DEPRN_PERIODS_MRC_V';
ELSE
  lp_fa_deprn_summary := 'FA_DEPRN_SUMMARY';
  lp_fa_deprn_detail  := 'FA_DEPRN_DETAIL';
  lp_fa_books         := 'FA_BOOKS';
  lp_fa_book_controls := 'FA_BOOK_CONTROLS';
  lp_fa_deprn_periods := 'FA_DEPRN_PERIODS';
END IF;
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
 Function Period1_PC_p return number is
	Begin
	 return Period1_PC;
	 END;
 Function Period2_PC_p return number is
	Begin
	 return Period2_PC;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_BAL_LPROMPT;
	 END;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR IS
   retval CHAR(7);
   num_chars NUMBER;
   temp_retval number;
BEGIN
   IF life IS NOT NULL
   THEN
      -- Fix for bug 601202 -- added substrb after lpad.  changed '90' to '999'
      temp_retval := fnd_number.canonical_to_number((LPAD(SUBSTR(TO_CHAR(TRUNC(life/12, 0), '999'), 2, 3),3,' ') || '.' ||
		SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) );
      retval := to_char(temp_retval,'999D99');
   ELSIF adj_rate IS NOT NULL
   THEN
      /* Bug 1744591
         Changed 90D99 to 990D99 */
           retval := SUBSTR(TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100, 2), '990.99'),2,6) || '%';
   ELSIF prod IS NOT NULL
   THEN
	--test for length of production_capacity; if it's longer
	--than 7 characters, then display in exponential notation
      --IF prod <= 9999999
      --THEN
      --   retval := TO_CHAR(prod);
      --ELSE
      --   retval := SUBSTR(LTRIM(TO_CHAR(prod, '9.9EEEE')), 1, 7);
      --END IF;
	--display nothing for UOP assets
	retval := '';
   ELSE
	--should not occur
      retval := ' ';
   END IF;
   return(retval);
END;
END FA_FAS402_XMLP_PKG ;


/
