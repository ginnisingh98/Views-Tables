--------------------------------------------------------
--  DDL for Package Body FA_FASRCOST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASRCOST_XMLP_PKG" AS
/* $Header: FASRCOSTB.pls 120.0.12010000.1 2008/07/28 13:17:21 appldev ship $ */

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
    RP_Report_Name := ':Recoverable Cost Report:';
    RETURN(RP_REPORT_NAME);
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
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;

  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;

--function corp_period_pcformula(book_type_code in varchar2, distribution_source_book in varchar2) return number is
function corp_period_pcformula(chg_book_type_code in varchar2, chg_distribution_source_book in varchar2) return number is
begin

DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);

  tax_calendar  VARCHAR2(15);
  corp_calendar VARCHAR2(15);
slask 	varchar2(30);
BEGIN

  Select deprn_calendar
  into   tax_calendar
  from fa_book_controls
--  where book_type_code = book_type_code;
  where book_type_code = chg_book_type_code;

  select deprn_calendar
  into corp_calendar
  from fa_book_controls
  --where book_type_code = distribution_source_book;
  where book_type_code = chg_distribution_source_book;


  if tax_calendar = corp_calendar then
         SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate)
     INTO   l_period_PC,
         l_period_POD,
         l_period_PCD
     FROM   FA_DEPRN_PERIODS
     --WHERE  book_type_code = Distribution_Source_Book
     WHERE  book_type_code = chg_distribution_source_book
     AND    period_name    = P_PERIOD1;


  else

     SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate)
     INTO   l_period_PC,
         l_period_POD,
         l_period_PCD
     FROM   FA_DEPRN_PERIODS
     --WHERE  book_type_code = Distribution_Source_Book
     WHERE  book_type_code = chg_distribution_source_book
     AND    Period1_PCD BETWEEN PERIOD_OPEN_DATE AND
	NVL(PERIOD_CLOSE_DATE, Period1_PCD);

  end if;

  Corp_Period_POD := l_period_POD;
  Corp_Period_PCD := l_period_PCD;
  return(l_period_PC);
END;
RETURN NULL; end;

--Functions to refer Oracle report placeholders--

 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
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
 Function Corp_Period_POD_p return date is
	Begin
	 return Corp_Period_POD;
	 END;
 Function Corp_Period_PCD_p return date is
	Begin
	 return Corp_Period_PCD;
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
END FA_FASRCOST_XMLP_PKG ;


/
