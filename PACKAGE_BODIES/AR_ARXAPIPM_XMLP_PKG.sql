--------------------------------------------------------
--  DDL for Package Body AR_ARXAPIPM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXAPIPM_XMLP_PKG" AS
/* $Header: ARXAPIPMB.pls 120.0 2007/12/27 13:26:56 abraghun noship $ */

function report_nameformula(Company_Name in varchar2, functional_currency in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;
    RP_Functional_Currency := functional_currency;
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
    THEN RP_REPORT_NAME := 'Transactions Awaiting Consolidation';
         RETURN('Transactions Awaiting Consolidation');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
	/*SRW.USER_EXIT('FND SRWINIT');*/null;
	--ADDED AS FIX
	P_INV_DATE_LOW_T :=to_char(P_INV_DATE_LOW,'DD-MON-YY');
	P_INV_DATE_HIGH_T :=to_char(P_INV_DATE_HIGH,'DD-MON-YY');
	P_DUE_DATE_LOW_T :=to_char(P_DUE_DATE_LOW,'DD-MON-YY');
	P_DUE_DATE_HIGH_T :=to_char(P_DUE_DATE_HIGH,'DD-MON-YY');



end;
  return (TRUE);
end;

function Sub_TitleFormula return VARCHAR2 is
begin

IF P_INV_DATE_LOW IS NOT NULL THEN
 RP_SUB_TITLE1 := fnd_date.date_to_chardate(P_INV_DATE_LOW)||' - '|| fnd_date.date_to_chardate(P_INV_DATE_HIGH);
END IF;
IF P_DUE_DATE_LOW IS NOT NULL THEN
 RP_SUB_TITLE2 := fnd_date.date_to_chardate(P_DUE_DATE_LOW)||' - '|| fnd_date.date_to_chardate(P_DUE_DATE_HIGH);
END IF;

RETURN NULL; end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function AfterPForm return boolean is
begin



LP_SUM_COLUMN := 'decode(decode(min(lc.lookup_code),
                                 ''AVAILABLE_FOR_RECEIPT'', ''PS'',
                                 ''STARTED_CREATION'', ''PS'',
                                 ''COMPLETED_CREATION'', ''PS'',
                                 ''STARTED_APPROVAL'', ''PS'',
                                 ''APPL''),
                                 ''PS'', sum(pays.amount_due_remaining) ,
                                 sum(decode(ra.confirmed_flag,''Y'', 0, ra.amount_applied)))';

LP_GROUP_BY := ' group by decode (:P_SORT_BY, ''DUE DATE'', null, ''INVOICE NUMBER'', trx.trx_number, null),
decode(:P_SORT_BY,''DUE DATE'', pays.due_date, ''INVOICE NUMBER'', pays.due_date, null),
decode(:P_SORT_BY,''DUE DATE'',  decode(:RP_SUMMARIZE, ''YES'',null, trx.trx_number), null ),
trx.invoice_currency_code, lc.meaning, lc.lookup_code, pmt.name, decode(:RP_SUMMARIZE, ''YES'', null, SUBSTRB(PARTY.PARTY_NAME,1,50)), decode(:RP_SUMMARIZE, ''YES'', null, cust.ACCOUNT_NUMBER),
decode(:RP_SUMMARIZE, ''YES'', null, su.location),
decode(:RP_SUMMARIZE, ''YES'', null, trx.trx_number), decode(:RP_SUMMARIZE, ''YES'', null, trxtype.name), decode(:RP_SUMMARIZE, ''YES'', null, trx.trx_date),
decode(:RP_SUMMARIZE, ''YES'', null, batch.name), pays.due_date ';

IF P_SORT_BY = 'DUE DATE' THEN
 IF P_SUMMARIZE = 'Y' THEN
  RP_SUMMARIZE := 'YES';
 ELSE
  RP_SUMMARIZE := 'NO';
 END IF;
ELSE
 RP_SUMMARIZE := 'NO';
END IF;





IF P_STATUS IS NOT NULL THEN
   IF P_STATUS = 'AVAILABLE_FOR_RECEIPT' THEN

     LP_STATUS :=
      ' and nvl(batch.batch_applied_status,
        ''AVAILABLE_FOR_RECEIPT'') =     :P_STATUS  ';
    ELSE

      LP_STATUS :=
       ' and nvl(batch.batch_applied_status,
        ''AVAILABLE_FOR_RECEIPT'') =     :P_STATUS and crh.prv_stat_cash_receipt_hist_id IS NULL';
    END IF;
END IF;

IF P_INV_DATE_LOW IS NOT NULL THEN
 LP_INV_DATE :=
 ' and trx.trx_date >= :p_inv_date_low';
END IF;
IF P_INV_DATE_HIGH IS NOT NULL THEN
 LP_INV_DATE := LP_INV_DATE ||
 ' and trx.trx_date <= :p_inv_date_high';
END IF;

IF P_INV_NUM_LOW IS NOT NULL THEN
 LP_INV_NUM :=
 ' and trx.trx_number >= :p_inv_num_low';
END IF;
IF P_INV_NUM_HIGH IS NOT NULL THEN
 LP_INV_NUM := LP_INV_NUM ||
 ' and trx.trx_number <= :p_inv_num_high';
END IF;

IF P_DUE_DATE_LOW IS NOT NULL THEN
 LP_DUE_DATE :=
 ' and pays.due_date >= :p_due_date_low';
END IF;
IF P_DUE_DATE_HIGH IS NOT NULL THEN
 LP_DUE_DATE := LP_DUE_DATE ||
 ' and pays.due_date <= :p_due_date_high';
END IF;

IF P_PMT_MTD IS NOT NULL THEN
 LP_PMT_METHOD :=
 ' and pmt.name = :p_pmt_mtd';
END IF;

IF P_CUST_NAME IS NOT NULL THEN
 LP_CUST_NAME :=
 ' and PARTY.PARTY_NAME = :p_cust_name';
END IF;


IF P_CUST_NUMBER IS NOT NULL THEN
 LP_CUST_NUM :=
 ' and cust.ACCOUNT_NUMBER = :p_cust_number';
END IF;

IF P_INV_NUM_LOW IS NOT NULL THEN
 LP_INV_NUM :=
 ' and trx.trx_number >= :p_inv_num_low';
END IF;
IF P_INV_NUM_HIGH IS NOT NULL THEN
 LP_INV_NUM := LP_INV_NUM ||
 ' and trx.trx_number <= :p_inv_num_high';
END IF;


IF P_INV_TYPE IS NOT NULL THEN
 LP_INV_TYPE :=
 ' and trxtype.name = :p_inv_type';
END IF;

IF P_CURRENCY IS NOT NULL THEN
 LP_CURRENCY :=
 ' and trx.invoice_currency_code = :p_currency';
END IF;  return (TRUE);
end;

function RP_DSP_SORT_BYFormula return VARCHAR2 is
begin

DECLARE
  l_sort_by varchar(50);
BEGIN
  SELECT meaning
  INTO   l_sort_by
  FROM   AR_LOOKUPS
  WHERE  lookup_code = P_SORT_BY
  AND    lookup_type = 'SORT_BY_ARXAPIPM';

  RETURN(l_sort_by);

EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;

function RP_DSP_SUMMARIZEFormula return VARCHAR2 is
begin

DECLARE
  l_summarize varchar(50);
BEGIN
  SELECT meaning
  INTO   l_summarize
  FROM   FND_LOOKUPS
  WHERE  lookup_code = P_SUMMARIZE
  AND    lookup_type = 'YES_NO';

  RETURN(l_summarize);

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
 WHERE  lookup_code = P_STATUS
 AND    lookup_type = 'ARXAPIPM_BATCH_APPLIED_STATUS';

 RETURN(l_status);

EXCEPTION
 WHEN OTHERS THEN RETURN NULL;
END;
RETURN NULL; end;

function CF_report_dateFormula return Char is
begin
  return(fnd_date.date_to_chardt(SYSDATE));
end;

--Functions to refer Oracle report placeholders--

 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_SUB_TITLE1_p return varchar2 is
	Begin
	 return RP_SUB_TITLE1;
	 END;
 Function RP_SUB_TITLE2_p return varchar2 is
	Begin
	 return RP_SUB_TITLE2;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_FUNCTIONAL_CURRENCY_p return varchar2 is
	Begin
	 return RP_FUNCTIONAL_CURRENCY;
	 END;
 Function D_SUM_AMOUNT_DUE_CURRFormula return VARCHAR2 is
	begin
	RP_DATA_FOUND := '1';
	return null;
	end;
END AR_ARXAPIPM_XMLP_PKG ;



/
