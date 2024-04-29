--------------------------------------------------------
--  DDL for Package Body FA_FASCAPSP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASCAPSP_XMLP_PKG" AS
/* $Header: FASCAPSPB.pls 120.0.12010000.1 2008/07/28 13:16:24 appldev ship $ */

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
    RP_Report_Name := ':Capital Spending Report:';
    RETURN(RP_REPORT_NAME);
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

T_DPIS := to_char(P_DPIS,'DD-Mon-YYYY');
/*T_END_DATE := to_char(END_DATE,'DD-MON-YYYY');*/


/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function PERIOD_NUMFormula return Number is
begin

DECLARE
  L_PERIOD_NUM  NUMBER;
  L_FISCAL_YEAR   NUMBER(15);
  L_END_DATE	DATE;
BEGIN
  SELECT
        FY_TAX.FISCAL_YEAR,
	FY_TAX.END_DATE
  INTO
        L_FISCAL_YEAR,
	L_END_DATE
  FROM  FA_FISCAL_YEAR FY_TAX,
	FA_BOOK_CONTROLS BC_TAX
  WHERE BC_TAX.BOOK_TYPE_CODE = P_TAX_BOOK AND
	BC_TAX.FISCAL_YEAR_NAME = FY_TAX.FISCAL_YEAR_NAME
  AND	P_DPIS BETWEEN FY_TAX.START_DATE AND FY_TAX.END_DATE;

  SELECT
	DP_BUD.PERIOD_NUM
  INTO
	L_PERIOD_NUM
  FROM  FA_DEPRN_PERIODS DP_BUD,
	FA_FISCAL_YEAR FY_BUD,
	FA_BOOK_CONTROLS BC_BUD
  WHERE BC_BUD.BOOK_TYPE_CODE = P_BUDGET_BOOK	AND
	P_DPIS BETWEEN FY_BUD.START_DATE AND FY_BUD.END_DATE
  AND	FY_BUD.FISCAL_YEAR_NAME = BC_BUD.FISCAL_YEAR_NAME
  AND	DP_BUD.BOOK_TYPE_CODE = P_BUDGET_BOOK AND
	DP_BUD.FISCAL_YEAR = FY_BUD.FISCAL_YEAR AND
	DP_BUD.PERIOD_CLOSE_DATE IS NULL;

  END_DATE := L_END_DATE;
  FISCAL_YEAR := L_FISCAL_YEAR;
  RETURN(L_PERIOD_NUM);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     END_DATE := L_END_DATE;
     FISCAL_YEAR := L_FISCAL_YEAR;
     RETURN(0);
END;
RETURN NULL; end;

function per_add_beforeformula(ADD_COST in number, ADDB_COST in number) return varchar2 is
begin

IF (ADD_COST = 0) THEN RETURN(TO_CHAR(100, '990D00'));
ELSE RETURN(TO_CHAR((ADDB_COST / ADD_COST) * 100, '990D00'));
END IF;
RETURN NULL; end;

function per_bud_beforeformula(BUD_COST_SUM in number, BUDB_COST_SUM in number) return varchar2 is
begin

IF (BUD_COST_SUM = 0) THEN
   RETURN ('N/A');
ELSE
   RETURN(TO_CHAR((BUDB_COST_SUM / BUD_COST_SUM) * 100, '990D00'));
END IF;
RETURN NULL; end;

function per_add_budformula(BUD_COST_SUM in number, ADD_COST in number) return varchar2 is
begin

IF (BUD_COST_SUM = 0) THEN
   RETURN('N/A');
ELSE
  RETURN( TO_CHAR((ADD_COST / BUD_COST_SUM) * 100, '9999990D00'));
END IF;
RETURN NULL; end;

function meth_per_add_beforeformula(METH_ADD_COST in number, METH_ADDB_COST in number) return varchar2 is
begin

IF (METH_ADD_COST = 0) THEN RETURN (TO_CHAR(100, '990D00'));
ELSE RETURN(TO_CHAR((METH_ADDB_COST / METH_ADD_COST) * 100, '990D00'));
END IF;
RETURN NULL; end;

function meth_per_bud_beforeformula(METH_BUD_COST in number, METH_BUDB_COST in number) return varchar2 is
begin

IF (METH_BUD_COST = 0) THEN
   RETURN ('N/A');
ELSE
   RETURN(TO_CHAR((METH_BUDB_COST / METH_BUD_COST) * 100, '990D00'));
END IF;
RETURN NULL; end;

function meth_per_add_budformula(METH_BUD_COST in number, METH_ADD_COST in number) return varchar2 is
begin

IF (METH_BUD_COST = 0) THEN
   RETURN('N/A');
ELSE

  RETURN( TO_CHAR((METH_ADD_COST / METH_BUD_COST) * 100, '9999990D00'));
END IF;
RETURN NULL; end;

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
 Function END_DATE_p return date is
	Begin
	 return END_DATE;
	 END;
 Function FISCAL_YEAR_p return number is
	Begin
	 return FISCAL_YEAR;
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
/*
Function DATEFORMAT(OrigDate in date) return varchar2 is
	Begin
	return UPPER(to_char(OrigDate,'DD-MON-YYYY'));
	End;
*/

END FA_FASCAPSP_XMLP_PKG ;


/
