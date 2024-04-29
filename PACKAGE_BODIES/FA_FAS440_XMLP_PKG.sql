--------------------------------------------------------
--  DDL for Package Body FA_FAS440_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS440_XMLP_PKG" AS
/* $Header: FAS440B.pls 120.0.12010000.1 2008/07/28 13:14:31 appldev ship $ */
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
    RP_Report_Name := ':Asset Retirements Report:';
    RETURN('REPORT TITLE');
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
function Period1_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
ELSE
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
END IF;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function Period2_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
ELSE
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
END IF;
  Period2_POD := l_period_POD;
  Period2_PCD := l_period_PCD;
  Period2_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function gain_lossformula(nbv in number, proceeds in number, removal in number, reval_rsv_ret in number) return number is
begin
return (-nbv + proceeds - removal + reval_rsv_ret);
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
  lp_fa_books         := 'FA_BOOKS_MRC_V';
  lp_fa_adjustments   := 'FA_ADJUSTMENTS_MRC_V';
  lp_fa_retirements   := 'FA_RETIREMENTS_MRC_V';
ELSE
  lp_fa_book_controls := 'FA_BOOK_CONTROLS';
  lp_fa_books         := 'FA_BOOKS';
  lp_fa_adjustments   := 'FA_ADJUSTMENTS';
  lp_fa_retirements   := 'FA_RETIREMENTS';
END IF;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_RPROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_RPROMPT;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function Period2_POD_p return date is
	Begin
	 return Period2_POD;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
 Function Period2_FY_p return number is
	Begin
	 return Period2_FY;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function PERIOD_FROM_p return varchar2 is
	Begin
	 return PERIOD_FROM;
	 END;
 Function PERIOD_TO_p return varchar2 is
	Begin
	 return PERIOD_TO;
	 END;
END FA_FAS440_XMLP_PKG ;


/
