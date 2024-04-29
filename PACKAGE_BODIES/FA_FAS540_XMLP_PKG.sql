--------------------------------------------------------
--  DDL for Package Body FA_FAS540_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS540_XMLP_PKG" AS
/* $Header: FAS540B.pls 120.0.12010000.1 2008/07/28 13:15:10 appldev ship $ */
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
  return (TRUE);
end;
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
        l_report_name  VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
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
        RP_Report_Name := ':Tax Additions Report:';
        RETURN(RP_Report_Name);
END;
RETURN NULL; end;
function BOOKFormula return VARCHAR2 is
begin
DECLARE
        l_book         VARCHAR2(15);
        l_accounting_flex_structure number(15);
        l_dist_book    VARCHAR2(15);
        l_fiscal_year_name VARCHAR2(30);
        l_currency_code VARCHAR2(15);
        l_precision    number;
BEGIN
        SELECT bc.book_type_code,
               bc.accounting_flex_structure,
               bc.distribution_source_book,
               bc.fiscal_year_name,
               sob.currency_code,
               cur.precision
        INTO   l_book,
               l_accounting_flex_structure,
               l_dist_book,
               l_fiscal_year_name,
               l_currency_code,
               l_precision
        FROM   fa_book_controls bc,
               gl_sets_of_books sob,
               fnd_currencies cur
        WHERE  bc.book_type_code = P_BOOK
        AND    bc.date_ineffective is null
        AND    bc.set_of_books_id = sob.set_of_books_id
        AND    sob.currency_code = cur.currency_code;
        DIST_BOOK := l_dist_book;
        ACCOUNTING_FLEX_STRUCTURE := l_accounting_flex_structure;
        CURRENCY_CODE := l_currency_code;
        FISCAL_YEAR_NAME := l_fiscal_year_name;
        P_MIN_PRECISION := l_precision;
        RETURN(l_book);
END;
RETURN NULL; end;
function PERIOD1Formula return VARCHAR2 is
begin
DECLARE
         l_period_name   VARCHAR2(15);
         l_period_counter number(15);
BEGIN
         select period_name,
                period_counter
         into l_period_name,
              l_period_counter
         from fa_deprn_periods
         where book_type_code = P_BOOK
         and   period_name = P_PERIOD1;
         PERIOD1_PC := l_period_counter;
         RETURN(l_period_name);
END;
RETURN NULL; end;
function PERIOD2Formula return VARCHAR2 is
begin
DECLARE
        l_period_name VARCHAR2(15);
        l_period_counter number(15);
BEGIN
        select period_name,
               period_counter
        into   l_period_name,
               l_period_counter
        from fa_deprn_periods
        where book_type_code = P_BOOK
        and   period_name = P_PERIOD2;
        PERIOD2_PC := l_period_counter;
        RETURN(l_period_name);
EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
             PERIOD2_PC := PERIOD1_PC;
             RETURN(P_PERIOD1);
END;
RETURN NULL; end;
function d_lifeformula(life in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2 is
begin
begin
	return(fadolif(life, adj_rate, bonus_rate, prod));
end;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function DIST_BOOK_p return varchar2 is
	Begin
	 return DIST_BOOK;
	 END;
 Function CURRENCY_CODE_p return varchar2 is
	Begin
	 return CURRENCY_CODE;
	 END;
 Function FISCAL_YEAR_NAME_p return varchar2 is
	Begin
	 return FISCAL_YEAR_NAME;
	 END;
 Function ACCOUNTING_FLEX_STRUCTURE_p return number is
	Begin
	 return ACCOUNTING_FLEX_STRUCTURE;
	 END;
 Function PERIOD1_PC_p return number is
	Begin
	 return PERIOD1_PC;
	 END;
 Function PERIOD2_PC_p return number is
	Begin
	 return PERIOD2_PC;
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
--ADDED
function ACCT_BAL_LPROMPTFormula(ACCT_BAL_LPROMPT VARCHAR2) return VARCHAR2 is
begin
/*SRW.REFERENCE(:BOOK);
SRW.USER_EXIT('FND FLEXIDVAL
                   CODE="GL#"
                   NUM=":ACCOUNTING_FLEX_STRUCTURE"
                   APPL_SHORT_NAME="SQLGL"
                   DATA="12345678"
                   LPROMPT=":ACCT_BAL_LPROMPT"
                   DISPLAY="GL_BALANCING"'); */
RP_BAL_LPROMPT := ACCT_BAL_LPROMPT;
RETURN(ACCT_BAL_LPROMPT);
end;
END FA_FAS540_XMLP_PKG ;


/
