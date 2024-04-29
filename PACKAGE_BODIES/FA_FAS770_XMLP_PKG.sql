--------------------------------------------------------
--  DDL for Package Body FA_FAS770_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS770_XMLP_PKG" AS /* $Header: FAS770B.pls 120.0.12010000.1 2008/07/28 13:15:29 appldev ship $ */
/* $Header: FAS770B.pls 120.0.12010000.1 2008/07/28 13:15:29 appldev ship $ */

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
  AND    sob.currency_code    = cur.currency_code;

  Book_Class := l_book_class;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_SOurce_Book :=l_distribution_source_book;
  Currency_Code := l_currency_code;
  P_Min_Precision := l_precision;
  return(l_book);
END;
RETURN NULL; end;

function report_nameformula(Company_Name in varchar2, ACCT_BAL_LPROMPT in varchar2) return varchar2 is
begin

DECLARE
  l_report_name VARCHAR2(80);
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;
   /*SRW.REFERENCE(ACCT_BAL_LPROMPT);*/null;

   C_BAL_LPROMPT := ACCT_BAL_LPROMPT;
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
    RP_Report_Name := 'REPORT TITLE';
    RETURN('REPORT TITLE');
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

function report_period_close_dateformul(end_period_counter in number) return varchar2 is
begin

declare
end_date date;
end_date1 varchar2(20);
begin
select nvl(PERIOD_CLOSE_DATE,sysdate)
into end_date
FROM FA_DEPRN_PERIODS
WHERE BOOK_TYPE_CODE = P_BOOK
and period_counter = end_period_counter;
end_date1:=to_char(end_date,'DD-MON-YYYY');
return(end_date1);
end;
RETURN NULL; end;

function d_lifeformula(life_in_months in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2 is
begin

begin
	return(fadolif(life_in_months, adj_rate,
bonus_rate,
			prod));
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
 Function C_BAL_LPROMPT_p return varchar2 is
	Begin
	 return C_BAL_LPROMPT;
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
END FA_FAS770_XMLP_PKG ;


/
