--------------------------------------------------------
--  DDL for Package Body AR_ARXAPRRM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXAPRRM_XMLP_PKG" AS
/* $Header: ARXAPRRMB.pls 120.0 2007/12/27 13:32:21 abraghun noship $ */
function report_nameformula(Company_Name in varchar2, functional_currency in varchar2) return varchar2 is
begin
DECLARE
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;
    RP_FUNCTIONAL_CURRENCY := functional_currency;
    SELECT substr(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;
l_report_name:= substr(l_report_name,1,instr(l_report_name,' (XML)'));
    RP_Report_Name := l_report_name;
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Receipts Awaiting Remittance Report';
         RETURN('Receipts Awaiting Remittance Report');
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
begin
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
function COUNTERFormula return Number is
begin
RETURN(1);
end;
function AfterPForm return boolean is
 l_remit_amount_low   NUMBER;
 l_remit_amount_high  NUMBER;
begin
   P_MATURITY_DATE_LOW1 := to_char(P_MATURITY_DATE_LOW,'DD-MON-YY');
   P_MATURITY_DATE_HIGH1 := to_char(P_MATURITY_DATE_HIGH,'DD-MON-YY');
  IF P_SUMMARIZE = 'Y' THEN
    RP_SUMMARIZE := 'YES';
  ELSE
    RP_SUMMARIZE := 'NO';
  END IF;
IF RP_SUMMARIZE = 'YES' THEN
  RP_SUM_COL_AMOUNT  := ' sum(cr.amount) ';
  RP_SUM_COL_CHARGES := ' sum(cr.factor_discount_amount) ';
  RP_GROUP_BY :=
' group by cr.currency_code, status_lc.meaning, decode(:P_SORT_BY, ''MATURITY DATE'', ps.due_date, null),
           decode(:P_SORT_BY, ''RECEIPT NUMBER'', cr.receipt_number, null),
	   decode(:P_SORT_BY, ''REMITTANCE BANK'', cbranch.bank_name, null),
	   cba.bank_account_name,
           decode(:RP_SUMMARIZE, ''YES'', null, cbranch.bank_name),
           decode(:RP_SUMMARIZE, ''YES'', null, cbranch.bank_branch_name),
           ps.due_date, decode(:RP_SUMMARIZE, ''YES'', null, rmethod_lc.meaning),
           rmethod.name, decode(:RP_SUMMARIZE, ''YES'', null, cr.receipt_number) ';
END IF;
IF P_STATUS IS NOT NULL THEN
  LP_STATUS:=' and nvl(batch.batch_applied_status, ''AVAILABLE_FOR_REMITT'') = :P_STATUS';
END IF;
IF P_REMIT_ACCOUNT IS NOT NULL THEN
  LP_REMIT_ACCOUNT := ' and racct.bank_account_name = :P_REMIT_ACCOUNT';
END IF;
IF P_REMIT_METHOD IS NOT NULL THEN
  LP_REMIT_METHOD := ' and rclass.remit_method_code = :P_REMIT_METHOD ';
END IF;
IF P_PMT_METHOD IS NOT NULL THEN
  LP_PMT_METHOD := ' and rmethod.name = :P_PMT_METHOD ';
END IF;
IF P_MATURITY_DATE_LOW IS NOT NULL THEN
  LP_MATURITY_DATE := ' and ps.due_date >= :P_MATURITY_DATE_LOW';
END IF;
IF P_MATURITY_DATE_HIGH IS NOT NULL THEN
  LP_MATURITY_DATE := LP_MATURITY_DATE ||
     ' and ps.due_date <= :P_MATURITY_DATE_HIGH';
END IF;
IF P_REMIT_AMOUNT_LOW IS NOT NULL THEN
   l_remit_amount_low := FND_NUMBER.CANONICAL_TO_NUMBER(P_REMIT_AMOUNT_LOW);
  LP_REMIT_AMOUNT := ' and cr.amount >= '|| l_remit_amount_low;
END IF;
IF P_REMIT_AMOUNT_HIGH IS NOT NULL THEN
    l_remit_amount_high := FND_NUMBER.CANONICAL_TO_NUMBER(P_REMIT_AMOUNT_HIGH);
  LP_REMIT_AMOUNT := LP_REMIT_AMOUNT ||
    ' and cr.amount <= ' || l_remit_amount_high;
END IF;
IF P_CURRENCY IS NOT NULL THEN
  LP_CURRENCY := ' and cr.currency_code = :P_CURRENCY';
END IF;
  return (TRUE);
end;
function RP_DISP_SUMMARIZEFormula return VARCHAR2 is
begin
DECLARE
  l_meaning varchar(30);
BEGIN
  SELECT meaning
  INTO   l_meaning
  FROM   FND_LOOKUPS
  WHERE  LOOKUP_TYPE = 'YES_NO'
  AND    LOOKUP_CODE = P_SUMMARIZE;
  RETURN(l_meaning);
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;
function RP_DISP_SORT_BYFormula return VARCHAR2 is
begin
DECLARE
  l_sort_by varchar(30);
BEGIN
  SELECT meaning
  INTO   l_sort_by
  FROM   AR_LOOKUPS
  WHERE  lookup_type = 'SORT_BY_ARXAPRRM'
  AND    lookup_code = P_SORT_BY;
  RETURN(l_sort_by);
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;
function RP_DISP_STATUSFormula return VARCHAR2 is
begin
DECLARE
  l_status varchar(30);
BEGIN
  SELECT meaning
  INTO   l_status
  FROM   AR_LOOKUPS
  WHERE  lookup_type = 'ARXAPRRM_BATCH_APPLIED_STATUS'
  AND    lookup_code = P_STATUS;
  RETURN(l_status);
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;
function RP_DISP_REMIT_METHODFormula return VARCHAR2 is
begin
DECLARE
  l_rmethod varchar(30);
BEGIN
  SELECT meaning
  INTO   l_rmethod
  FROM   AR_LOOKUPS
  WHERE  lookup_type = 'REMITTANCE_METHOD'
  AND    lookup_code = P_REMIT_METHOD;
  RETURN(l_rmethod);
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;
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
 Function RP_FUNCTIONAL_CURRENCY_p return varchar2 is
	Begin
	 return RP_FUNCTIONAL_CURRENCY;
	 END;
 function D_SUM_AMOUNT_CURRFormula return VARCHAR2 is
	begin
	RP_DATA_FOUND := 1;
	return NULL;
	end;
END AR_ARXAPRRM_XMLP_PKG ;


/
