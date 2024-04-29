--------------------------------------------------------
--  DDL for Package Body FA_FASCC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASCC_XMLP_PKG" AS
/* $Header: FASCCB.pls 120.0.12010000.1 2008/07/28 13:16:29 appldev ship $ */

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
  Precision := l_precision;

  return(l_book);
END;

RETURN NULL; end;

function Period1Formula return VARCHAR2 is
begin

DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT period_name,
         period_counter,
         period_open_date,
         nvl(period_close_date, sysdate)
  INTO   l_period_name,
         l_period_PC,
         l_period_POD,
         l_period_PCD
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
ELSE
  SELECT period_name,
         period_counter,
         period_open_date,
         nvl(period_close_date, sysdate)
  INTO   l_period_name,
         l_period_PC,
         l_period_POD,
         l_period_PCD
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
END IF;

  Period1_PC := l_period_PC;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  return(l_period_name);
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

 l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));

  RP_Report_Name := l_report_name;
  RETURN(l_report_name);

EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := 'Cost Clearing Reconciliation Report';
    RETURN('Cost Clearing Reconciliation Report');
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
  lp_fa_book_controls := 'FA_BOOK_CONTROLS_MRC_V';
  lp_fa_asset_invoices := 'FA_ASSET_INVOICES_MRC_V';
  lp_fa_books := 'FA_BOOKS_MRC_V';
  lp_fa_books_bas := 'FA_BOOKS_BAS';
  lp_fa_asset_invoices_bas := 'FA_ASSET_INVOICES_BAS';
ELSE
  lp_fa_book_controls := 'FA_BOOK_CONTROLS';
  lp_fa_asset_invoices := 'FA_ASSET_INVOICES';
  lp_fa_books := 'FA_BOOKS';
  lp_fa_books_bas := 'FA_BOOKS';
  lp_fa_asset_invoices_bas := 'FA_ASSET_INVOICES';
END IF;

  return (TRUE);
end;

function lp_fa_asset_invoicesValidTrigg return boolean is
begin

  return (TRUE);
end;

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
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
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
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
END FA_FASCC_XMLP_PKG ;


/
