--------------------------------------------------------
--  DDL for Package Body FA_FASFIADJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASFIADJ_XMLP_PKG" AS
/* $Header: FASFIADJB.pls 120.0.12010000.1 2008/07/28 13:16:41 appldev ship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
  l_report_name VARCHAR2(80);
BEGIN
  RP_Company_Name := Company_Name;
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
    RP_Report_Name := ':Financial Adjustments Report:';
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
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;

  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;

function d_lifeformula(LIFE in number, ADJUSTED_RATE in number, BONUS_RATE in number, PRODUCTION in number) return varchar2 is
begin

/*SRW.REFERENCE(LIFE);*/null;

/*SRW.REFERENCE(ADJUSTED_RATE);*/null;

/*SRW.REFERENCE(BONUS_RATE);*/null;

/*SRW.REFERENCE(PRODUCTION);*/null;

BEGIN
  RETURN(FADOLIF(LIFE, ADJUSTED_RATE, BONUS_RATE, PRODUCTION));
END;
RETURN NULL; end;

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
	 --ADDED AS PART OF PLS FIX--



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
END FA_FASFIADJ_XMLP_PKG ;


/
