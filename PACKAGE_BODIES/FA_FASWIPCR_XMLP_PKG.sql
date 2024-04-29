--------------------------------------------------------
--  DDL for Package Body FA_FASWIPCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASWIPCR_XMLP_PKG" AS
/* $Header: FASWIPCRB.pls 120.0.12010000.1 2008/07/28 13:17:53 appldev ship $ */

function BookFormula return VARCHAR2 is
begin

DECLARE
  l_book       VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_precision NUMBER(15);
BEGIN
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

  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Currency_Code := l_currency_code;
  Precision := l_precision;

  return(l_book);
END;

RETURN NULL; end;

function Period1Formula return VARCHAR2 is
begin

DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  VARCHAR2(21);
  l_period_PCD  VARCHAR2(21);
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
  SELECT period_name,
         period_counter,
         to_char(period_open_date,'DD-MM-YYYY HH24:MI:SS'),
         to_char(nvl(period_close_date, sysdate),'DD-MM-YYYY HH24:MI:SS'),
         fiscal_year
  INTO   l_period_name,
         l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;

  Period1_PC := l_period_PC;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_name);
END;

RETURN NULL; end;

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin


DECLARE
  l_report_name VARCHAR2(80);
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
    RP_Report_Name := ':Contruction In Process Capitalization Report:';
    RETURN(RP_Report_Name);
END;
RETURN NULL; end;

function Period2Formula return VARCHAR2 is
begin

DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  VARCHAR2(21);
  l_period_PCD  VARCHAR2(21);
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
  SELECT period_name,
         period_counter,
         to_char(period_open_date,'DD-MM-YYYY HH24:MI:SS'),
         to_char(nvl(period_close_date, sysdate),
                          'DD-MM-YYYY HH24:MI:SS'),
         fiscal_year
  INTO   l_period_name,
         l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;

  Period2_PC := l_period_PC;
  Period2_POD := l_period_POD;
  Period2_PCD := l_period_PCD;
  Period2_FY  := l_period_FY;
  return(l_period_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
         Period2_PC := Period1_PC;
         Period2_POD := Period1_POD;
         Period2_PCD := Period1_PCD;
         Period2_FY := Period1_FY;
    return(P_PERIOD1);
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function d_lifeformula(life in number, adj_rate in number, capacity in number) return varchar2 is
begin

begin
	return(fadolif(life, adj_rate, 0, capacity));
end;

RETURN NULL; end;

--Functions to refer Oracle report placeholders--

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
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function Period1_PC_p return number is
	Begin
	 return Period1_PC;
	 END;
 Function Period1_PCD_p return varchar2 is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_POD_p return varchar2 is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function Period2_FY_p return number is
	Begin
	 return Period2_FY;
	 END;
 Function Period2_PCD_p return varchar2 is
	Begin
	 return Period2_PCD;
	 END;
 Function Period2_POD_p return varchar2 is
	Begin
	 return Period2_POD;
	 END;
 Function Period2_PC_p return number is
	Begin
	 return Period2_PC;
	 END;
 Function Precision_p return number is
	Begin
	 return Precision;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
	 --MODIFIED
 Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2 is
	Begin
	RP_BAL_LPROMPT :=ACCT_BAL_LPROMPT;
	 return RP_BAL_LPROMPT;
	 END;
	 --MODIFIED
 Function RP_CC_LPROMPT_p(ACCT_CC_LPROMPT VARCHAR2) return varchar2 is
	Begin
	RP_CC_LPROMPT:=ACCT_CC_LPROMPT;
	 return RP_CC_LPROMPT;
	 END;
	 --added
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
--END OF PLS FIX

END FA_FASWIPCR_XMLP_PKG ;


/
