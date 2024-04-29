--------------------------------------------------------
--  DDL for Package Body FA_FAS823_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS823_XMLP_PKG" AS
/* $Header: FAS823B.pls 120.0.12010000.1 2008/07/28 13:15:41 appldev ship $ */
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
    RP_Report_Name := 'Mass Additions Status Report';
    RETURN('Mass Additions Status Report');
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
function new_costformula(sum_units in varchar2, MASS_ADD_ID in number, cost in number, fixed_assets_units in number) return number is
l_sum_units     NUMBER;
l_cost          NUMBER;
l_new_cost      NUMBER;
begin
/*srw.reference(sum_units);*/null;
/*srw.reference(cost);*/null;
/*srw.reference(fixed_assets_units);*/null;
/*srw.reference(mass_add_id);*/null;
        if(sum_units = 'YES') THEN
                select sum(units)
                into l_sum_units
                from fa_massadd_distributions
                where mass_addition_id =  MASS_ADD_ID;
                l_new_cost := cost /l_sum_units;
        else
                l_new_cost := cost/fixed_assets_units;
        end if;
l_new_cost :=round(l_new_cost,2);
return (l_new_cost);
exception
        when others then
        raise;
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
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
--Added during DT Fixes
function D_COSTFormula return VARCHAR2 is
begin
        RP_DATA_FOUND := 'YES';
        return 'YES';
end;
--End of DT Fixes
END FA_FAS823_XMLP_PKG ;


/
