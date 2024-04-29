--------------------------------------------------------
--  DDL for Package Body FA_FAS771_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS771_XMLP_PKG" AS
/* $Header: FAS771B.pls 120.0.12010000.1 2008/07/28 13:15:31 appldev ship $ */
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
  --RP_Report_Name := l_report_name;
  RP_Report_Name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    IF (P_ADJUSTED = 'TRUE') THEN
    	RP_Report_Name := ':Adjusted Form 4562 - Depreciation and Amortization Report:';
    ELSE RP_Report_Name := ':Form 4562 - Depreciation and Amortization Report:';
    END IF;
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
function report_period_close_dateformul(end_period_counter in number) return varchar2 is
begin
declare
end_date date;
begin
select nvl(PERIOD_CLOSE_DATE,sysdate)
into end_date
FROM FA_DEPRN_PERIODS
WHERE BOOK_TYPE_CODE = P_BOOK
and period_counter = end_period_counter;
return(to_char(end_date,'DD-MON-YYYY HH24:MI:SS'));
end;
RETURN NULL; end;
function d_lifeformula(life_in_months in number, adjusted_rate in number, bonus_rate in number, production in number) return varchar2 is
begin
/*srw.reference(life_in_months);*/null;
/*srw.reference(adjusted_rate);*/null;
/*srw.reference(bonus_rate);*/null;
/*srw.reference(production);*/null;
begin
return(fadolif(life_in_months, adjusted_rate, bonus_rate, production));
end;
RETURN NULL; end;
function ytdformula(YTD_ADJ in number, YTD_DEPRN in number) return number is
begin
RETURN(YTD_ADJ + YTD_DEPRN);
end;
function specialformula(asset_id in number, book in varchar2, FISCAL_YEAR_ADDED in varchar2, deprn_method in varchar2, SPECIAL_DEPRN in number, YTD in number) return number is
tmp number:=0;
begin
/*srw.reference(YTD);*/null;
/*SRW.REFERENCE(SPECIAL_DEPRN);*/null;
/*SRW.REFERENCE(SPECIAL);*/null;
/*SRW.REFERENCE(CURRENCY_CODE);*/null;
/*SRW.REFERENCE(YTD);*/null;
/*SRW.REFERENCE(BOOK);*/null;
/*SRW.REFERENCE(ASSET_ID);*/null;
/*SRW.REFERENCE(FISCAL_YEAR_ADDED);*/null;
/*SRW.REFERENCE(P_FISCAL_YEAR);*/null;
/*SRW.REFERENCE(P_SPECIAL_FLAG);*/null;
/*SRW.REFERENCE(DEPRN_METHOD);*/null;
IF IsAmortized(asset_id, book) and
	(FISCAL_YEAR_ADDED = to_char(P_FISCAL_YEAR)
	and ( instr(deprn_method, '30B') > 0  or
              instr(deprn_method, '50B') > 0 ) ) THEN
	P_SPECIAL_FLAG := '#';
	RETURN (0);
ELSIF (ABS(SPECIAL_DEPRN) > ABS(YTD))  and    	(FISCAL_YEAR_ADDED = to_char(P_FISCAL_YEAR)
	and ( instr(deprn_method, '30B') > 0 or
              instr(deprn_method, '50B') > 0 ) ) THEN
	P_SPECIAL_FLAG := '*';
	RETURN (0);
else
	P_SPECIAL_FLAG := '';
	return(round(special_deprn, p_min_precision));
end if;
end;
FUNCTION isAmortized (p_asset_id number, p_book varchar2) RETURN boolean IS
tmp 	Number:=0;
BEGIN
/*SRW.REFERENCE(P_FISCAL_YEAR);*/null;
select count(*)
into tmp
from fa_transaction_headers
where asset_id = p_asset_id
and book_type_code = p_book
and transaction_subtype = 'AMORTIZED'
AND to_char(transaction_date_entered, 'YYYY') = P_FISCAL_YEAR;
if tmp > 0 Then
	return TRUE;
end if;
return FALSE;
END;
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
 Function P_SPECIAL_FLAG_p return varchar2 is
	Begin
	 return P_SPECIAL_FLAG;
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
END FA_FAS771_XMLP_PKG ;


/
