--------------------------------------------------------
--  DDL for Package Body FA_FASAAMTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASAAMTS_XMLP_PKG" AS
/* $Header: FASAAMTSB.pls 120.0.12010000.1 2008/07/28 13:16:15 appldev ship $ */
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
	IF (P_ADJUSTED = 'TRUE') THEN
	RP_Report_Name := ':Adjusted Form 4626 - AMT Summary Report:';
	ELSE
	RP_Report_Name := ':Form 4626 - AMT Summary Report:';
	END IF;
    RETURN(RP_REPORT_NAME);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
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
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_FED_BOOK
  AND    period_name    = P_PERIOD1;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function FED_START_PERIOD_PCFormula return Number is
begin
DECLARE
  l_fed_start_period_PC	NUMBER(15);
  l_fed_end_period_PC	NUMBER(15);
  l_amt_start_period_PC	NUMBER(15);
  l_amt_end_period_PC	NUMBER(15);
BEGIN
select
	min(dp_fed.period_counter),
	max(dp_fed.period_counter),
	min(dp_amt.period_counter),
	max(dp_amt.period_counter)
into
	l_fed_start_period_pc,
	l_fed_end_period_pc,
	l_amt_start_period_pc,
	l_amt_end_period_pc
from
	fa_deprn_periods dp_amt,
	fa_deprn_periods dp_fed
where
	dp_fed.book_type_code = P_FED_BOOK	and
	dp_fed.fiscal_year = Period1_FY	and
	dp_amt.book_type_code = P_AMT_BOOK	and
	dp_amt.fiscal_year = Period1_FY;
  FED_END_PERIOD_PC := l_fed_end_period_pc;
  AMT_START_PERIOD_PC := l_amt_start_period_pc;
  AMT_END_PERIOD_PC := l_amt_end_period_pc;
  return(l_fed_start_period_pc);
END;
RETURN NULL; end;
function diff_deprnformula(FED_DEPRN in number, AMT_DEPRN in number) return number is
begin
RETURN (FED_DEPRN - AMT_DEPRN);
end;
function amt_deprnformula(AMT_DD in number, AMT_ADJUST in number) return number is
begin
RETURN(AMT_DD + AMT_ADJUST);
end;
function fed_deprnformula(FED_DD in number, FED_ADJUST in number) return number is
begin
RETURN(FED_DD + FED_ADJUST);
end;
--Functions to refer Oracle report placeholders--
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
 Function FED_END_PERIOD_PC_p return number is
	Begin
	 return FED_END_PERIOD_PC;
	 END;
 Function AMT_START_PERIOD_PC_p return number is
	Begin
	 return AMT_START_PERIOD_PC;
	 END;
 Function AMT_END_PERIOD_PC_p return number is
	Begin
	 return AMT_END_PERIOD_PC;
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
END FA_FASAAMTS_XMLP_PKG ;


/
