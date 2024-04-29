--------------------------------------------------------
--  DDL for Package Body AR_ARXAPRCL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXAPRCL_XMLP_PKG" AS
/* $Header: ARXAPRCLB.pls 120.0 2007/12/27 13:29:33 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;
    SELECT substr(cp.user_concurrent_program_name, 1, 80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RP_Report_Name := substr(RP_Report_Name,1,instr(RP_Report_Name,' (XML)'));
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Receipts Awaiting Bank Clearance Report';
         RETURN('Receipts Awaiting Bank Clearance Report');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

begin
	P_MATURITY_DATE_LOW_T:= to_char(P_MATURITY_DATE_LOW,'DD-MON-YY');
P_MATURITY_DATE_HIGH_T := to_char(P_MATURITY_DATE_HIGH,'DD-MON-YY');
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
	/*SRW.USER_EXIT('FND SRWINIT');*/null;




end;
  return (TRUE);
end;

function Sub_TitleFormula return VARCHAR2 is
begin

begin
RP_SUB_TITLE := ' ';
return(' ');
end;

RETURN NULL; end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function AfterPForm return boolean is
begin

IF P_REMIT_ACCOUNT IS NOT NULL THEN
  LP_REMIT_ACCOUNT := ' and racct.bank_acct_use_id = :P_REMIT_ACCOUNT ';
END IF;

IF P_REMIT_METHOD IS NOT NULL THEN
  LP_REMIT_METHOD := ' and batch.remit_method_code = :P_REMIT_METHOD';
END IF;

IF P_PMT_METHOD IS NOT NULL THEN
   LP_PMT_METHOD := ' and rmethod.name = :P_PMT_METHOD';
END IF;

IF P_MATURITY_DATE_LOW IS NOT NULL THEN
  LP_MATURITY_DATE := ' and ps.due_date >= :P_MATURITY_DATE_LOW';
END IF;

IF P_MATURITY_DATE_HIGH IS NOT NULL THEN
  LP_MATURITY_DATE := LP_MATURITY_DATE || ' and ps.due_date <= :P_MATURITY_DATE_HIGH';
END IF;

IF P_REMIT_AMOUNT_LOW IS NOT NULL THEN
  LP_REMIT_AMOUNT := ' and cr.amount >= :P_REMIT_AMOUNT_LOW ';
END IF;

IF P_REMIT_AMOUNT_HIGH IS NOT NULL THEN
  LP_REMIT_AMOUNT := LP_REMIT_AMOUNT || ' and cr.amount <= :P_REMIT_AMOUNT_HIGH ';
END IF;

IF P_CURRENCY IS NOT NULL THEN
  LP_CURRENCY := ' and cr.currency_code = :P_CURRENCY';
END IF;
  return (TRUE);
end;

function RP_DISP_SORT_BYFormula return VARCHAR2 is
begin

DECLARE
 l_sort_by varchar(50);
BEGIN
 SELECT lc.meaning
 INTO   l_sort_by
 FROM   AR_LOOKUPS lc
 WHERE  lc.lookup_type = 'SORT_BY_ARXAPRCL'
 AND    lc.lookup_code = P_SORT_BY;

 RETURN(l_sort_by);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;

function RP_DISP_REMIT_METHODFormula return VARCHAR2 is
begin

DECLARE
 l_remit_method varchar(40);
BEGIN
 SELECT meaning
 INTO   l_remit_method
 FROM   AR_LOOKUPS
 WHERE  lookup_type = 'REMITTANCE_METHOD'
 AND    lookup_code = P_REMIT_METHOD;

 RETURN(l_remit_method);

EXCEPTION
 WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;

function RP_ACCOUNT_NAMEFormula return Char is
begin
  DECLARE
 l_account_name varchar(80);
BEGIN
 SELECT CBA.BANK_ACCOUNT_NAME,
        BB.BANK_NAME
 INTO   l_account_name,RP_BANK_NAME
 FROM   CE_BANK_ACCOUNTS CBA,
        CE_BANK_ACCT_USES BA,
        CE_BANK_BRANCHES_V BB
 WHERE  BA.BANK_ACCT_USE_ID = P_REMIT_ACCOUNT
 AND    CBA.BANK_ACCOUNT_ID = BA.BANK_ACCOUNT_ID
 AND    CBA.BANK_BRANCH_ID = BB.BRANCH_PARTY_ID;

 RETURN(l_account_name);

EXCEPTION
 WHEN OTHERS THEN RETURN NULL;
END;

end;

--Functions to refer Oracle report placeholders--

 Function COUNTER_p return number is
	Begin
	 return COUNTER;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_BANK_NAME_p return varchar2 is
	Begin
	 return RP_BANK_NAME;
	 END;
 function D_SUM_AMOUNT_CURRFormula return VARCHAR2 is
	begin
	RP_DATA_FOUND := 1;
	return null;
	end;
END AR_ARXAPRCL_XMLP_PKG ;


/
