--------------------------------------------------------
--  DDL for Package Body AR_ARXAPRMB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXAPRMB_XMLP_PKG" AS
/* $Header: ARXAPRMBB.pls 120.0 2007/12/27 13:31:19 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(240);
BEGIN
    RP_Company_Name := Company_Name;

    SELECT substr(cp.user_concurrent_program_name,1,80)
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
    THEN RP_REPORT_NAME := 'Remittance Batch Management Report';
         RETURN('Remittance Batch Management Report');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
	/*SRW.USER_EXIT('FND SRWINIT');*/null;
P_SORT_BY_T := nvl(P_SORT_BY,'REMITTANCE ACCOUNT');

P_REM_DATE_FROM_T := to_char(P_REM_DATE_FROM,'DD-MON-YY');
P_REM_DATE_TO_T := to_char(P_REM_DATE_TO,'DD-MON-YY');

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

IF P_STATUS IS NOT NULL THEN
  LP_STATUS := ' and batch.batch_applied_status = :P_STATUS ';
END IF;  return (TRUE);
end;

function RP_DSP_SORT_BYFormula return VARCHAR2 is
begin

DECLARE
  l_sort_by varchar(40);
BEGIN
  SELECT meaning
  INTO   l_sort_by
  FROM   AR_LOOKUPS
  WHERE  lookup_type = 'SORT_BY_ARXAPRMB'
  AND    lookup_code = P_SORT_BY;

  RETURN(l_sort_by);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;

function RP_DSP_STATUSFormula return VARCHAR2 is
begin

DECLARE
  l_status varchar(50);
BEGIN
  SELECT meaning
  INTO   l_status
  FROM   AR_LOOKUPS
  WHERE  lookup_type = 'BATCH_APPLIED_STATUS'
  AND    lookup_code = P_STATUS;

  RETURN(l_status);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;

function amountformula(status_code in varchar2, p_batch_id in number) return number is
begin

DECLARE
  l_amount NUMBER;
BEGIN
  IF ((status_code = 'STARTED_CREATION') OR
      (status_code = 'COMPLETED_CREATION') OR
      (status_code = 'STARTED_APPROVAL')) THEN

      SELECT sum(nvl(cr.amount,0)+nvl(cr.factor_discount_amount,0))
      INTO   l_amount
      FROM   ar_cash_receipts cr
      WHERE  cr.selected_remittance_batch_id = p_batch_id;

      return(l_amount);

   ELSE

      SELECT sum(nvl(crh.amount,0)+nvl(crh.factor_discount_amount,0))
      INTO   l_amount
      FROM   ar_cash_receipt_history crh,
             ar_cash_receipt_history crhprv
      WHERE  crh.batch_id = p_batch_id
      AND    crh.cash_receipt_history_id =
               crhprv.reversal_cash_receipt_hist_id
      AND    crhprv.status = 'CONFIRMED'
      AND    crh.status    = 'REMITTED';

      return(l_amount);
   END IF;
  return(l_amount);
END;
RETURN NULL; end;

function DISP_REMIT_METHODFormula return VARCHAR2 is
begin

DECLARE
  l_rem_met varchar(40);
BEGIN
  SELECT meaning
  INTO   l_rem_met
  FROM   AR_LOOKUPS
WHERE LOOKUP_TYPE = 'REMITTANCE_METHOD'
 AND   ENABLED_FLAG = 'Y'
AND LOOKUP_CODE = P_REMITTANCE_METHOD;

 RETURN(l_rem_met);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

RETURN NULL; end;

function DISP_REMIT_ACCOUNTFormula return VARCHAR2 is
begin

DECLARE
  l_rem_acc varchar(40);
BEGIN
  SELECT BANK_ACCOUNT_NAME
  INTO   l_rem_acc
  FROM   CE_BANK_ACCOUNTS  cba,
         ce_bank_acct_uses  ba
WHERE BANK_ACCT_USE_ID =P_REMIT_BANK_ACCOUNT
AND     cba.bank_account_id = ba.bank_account_id;

 RETURN(l_rem_acc);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

RETURN NULL; end;

function DISP_INC_FORMATTEDFormula return VARCHAR2 is
begin

DECLARE
  l_inc_form varchar(40);
BEGIN
  SELECT meaning
  INTO   l_inc_form
  FROM   FND_LOOKUPS
WHERE LOOKUP_TYPE = 'YES_NO'
 AND   ENABLED_FLAG = 'Y'
AND LOOKUP_CODE = P_INCLUDE_FORMATTED;

 RETURN(l_inc_form);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

RETURN NULL; end;

function DISP_SUM_OR_DETFormula return VARCHAR2 is
begin

DECLARE
  l_sum_or_det varchar(80);
BEGIN
  SELECT meaning
  INTO   l_sum_or_det
  FROM   AR_LOOKUPS
WHERE LOOKUP_TYPE = 'ARXAPRMB_SD'
 AND   ENABLED_FLAG = 'Y'
AND LOOKUP_CODE = P_SUMMARY_OR_DETAILED;

 RETURN(l_sum_or_det);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

RETURN NULL; end;

function det_batch_statusformula(batch_status in varchar2) return varchar2 is
begin

if p_summary_or_detailed = 'DETAILED'
then return(batch_status);
end if;
RETURN NULL; end;

--Functions to refer Oracle report placeholders--

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
END AR_ARXAPRMB_XMLP_PKG ;


/
