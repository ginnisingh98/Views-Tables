--------------------------------------------------------
--  DDL for Package Body AR_ARXSOC2_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXSOC2_XMLP_PKG" AS
/* $Header: ARXSOC2B.pls 120.1 2008/01/07 14:51:58 abraghun noship $ */
function BeforeReport return boolean is
begin
   return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
    l_report_name  VARCHAR2(80);
    l_date_low  VARCHAR2 (11);
    l_date_high VARCHAR2 (11);
BEGIN
if p_date_low is NULL then
  l_date_low := '   ';
else
  l_date_low := TO_CHAR(p_date_low, 'DD-MON-YYYY') ;
end if ;
if p_date_high is NULL then
  l_date_high := '   ';
else
  l_date_high := TO_CHAR(p_date_high, 'DD-MON-YYYY') ;
end if ;
rp_date_range  := arp_standard.fnd_message('ARXSOC_DEPOSIT_DATE_RANGE',
                                            'FROM_DATE',l_date_low,
                                            'TO_DATE',  l_date_high);
    RP_Company_Name := Company_Name;
    SELECT SUBSTR(cp.user_concurrent_program_name, 1, 80)
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
    THEN RP_REPORT_NAME := null;
         RETURN(null);
END;
RETURN NULL; end;
function c_difference_amountformula(c_rcpt_control_amount in number, c_actual_amount in number) return number is
begin
/*srw.reference (c_rcpt_control_amount);*/null;
/*srw.reference (c_actual_amount);*/null;
return ( nvl(c_rcpt_control_amount,0) -  nvl(c_actual_amount,0) );
end;
function c_summary_labelformula(Currency_A in varchar2) return varchar2 is
begin
return (rtrim(rpad(Currency_A,3)));
end;
function ca_difference_amountformula(c_rcpt_control_amount_B in number, ca_actual_amount in number) return number is
begin
/*srw.reference (c_rcpt_control_amount_B);*/null;
/*srw.reference (ca_actual_amount);*/null;
return ( nvl(c_rcpt_control_amount_B,0) - nvl(ca_actual_amount,0) );
end;
function ca_summary_labelformula(Currency_B in varchar2) return varchar2 is
begin
return (rtrim(rpad(Currency_B,3)) );
end;
function cf_data_not_foundformula(bank_account_name_C in varchar2) return number is
begin
rp_data_found3 := bank_account_name_C ;
return (0);
end;
function cr_data_foundformula(Currency_B in varchar2) return number is
begin
rp_data_found2 := Currency_B ;
return (0);
end;
function cm_data_not_foundformula(Currency_A in varchar2) return number is
begin
rp_data_found1 := Currency_A ;
return (0);
end;
function AfterPForm return boolean is
begin
DECLARE
l_bank_count       NUMBER (10);
begin
P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      P_DATE_LOW1 := to_char(P_DATE_LOW,'DD-MON-YY');
            P_DATE_HIGH1 := to_char(P_DATE_HIGH,'DD-MON-YY');
ph_order_by := p_order_by ;
if  upper ( substr (p_order_by,1,1) ) = 'B' then
  p_order_by_1 := 'Bank';
else
  p_order_by_1 := 'Currency';
end if ;
if p_date_low is NOT NULL then
  lp_date_low := ' and deposit_date >= :p_date_low ' ;
end if ;
if p_date_high is NOT NULL then
  lp_date_high := ' and deposit_date  <= :p_date_high ' ;
end if ;
if p_bank_account_name_low is NOT NULL then
  lp_bank_account_name_low := ' and cba.bank_account_name >= :p_bank_account_name_low ' ;
end if ;
if p_bank_account_name_high is NOT NULL then
  lp_bank_account_name_high := ' and cba.bank_account_name <= :p_bank_account_name_high ' ;
end if ;
select  count (*)
  into l_bank_count
from  ce_bank_accounts cba,
      ce_bank_acct_uses ba,
      ce_bank_branches_v bb
where ba.bank_acct_use_id in
     (select distinct remit_bank_acct_use_id from ar_cash_receipts)
and  cba.bank_branch_id = bb.branch_party_id
and  cba.bank_account_name
    between decode(p_bank_account_name_low,
		   NULL, cba.bank_account_name,
			  p_bank_account_name_low)
    and     decode(p_bank_account_name_high,
		   NULL, cba.bank_account_name,
		   p_bank_account_name_high)
;
p_bank_count :=  l_bank_count ;
end ;
  return (TRUE);
end;
function f_amountsformula(cr_status in varchar2, amount in number, cr_type in varchar2, reversal_category in varchar2, cash_receipt_id in number) return number is
begin
DECLARE
l_actual_amount          NUMBER := 0;
l_unidentified_amount    NUMBER := 0;
l_misc_amount            NUMBER := 0;
l_nsf_amount             NUMBER := 0;
l_on_account_amount      NUMBER := 0;
l_applied_count          NUMBER(10) := 0;
l_unapplied_count        NUMBER(10) := 0;
l_unidentified_count     NUMBER(10) := 0;
l_misc_count             NUMBER(10) := 0;
BEGIN
/*srw.reference (amount);*/null;
/*srw.reference (cr_status);*/null;
/*srw.reference (cr_type);*/null;
/*srw.reference (reversal_category);*/null;
select
  decode(cr_status, 'REV', 0, amount),
  decode(cr_status, 'UNID', amount, 0),
  decode(cr_type,
         'MISC', decode(cr_status,
                        'REV', 0,
                              amount),
                 0),
  decode(cr_status, reversal_category,
         decode(cr_status, 'NSF', amount, 'STOP', amount, 0), 0),
  decode(cr_status, 'APP', 1, 0),
  decode(cr_status, 'UNAPP', 1, 0),
  decode(cr_status, 'UNID', 1, 0),
  decode(cr_type,
         'MISC', decode(cr_status,
                        'REV', 0,
                               1),
                 0)
into
  l_actual_amount,
  l_unidentified_amount,
  l_misc_amount,
  l_nsf_amount,
  l_applied_count,
  l_unapplied_count,
  l_unidentified_count,
  l_misc_count
from dual;
if cr_status = 'APP' then
    select sum(amount_applied)
    into   l_on_account_amount
    from   ar_receivable_applications
    where  cash_receipt_id = cash_receipt_id
    and    status = 'ACC';
    if nvl(l_on_account_amount,0) <> 0 then
       l_unapplied_count := l_unapplied_count + 1;
       l_applied_count   := l_applied_count - 1;
    end if;
end if;
p_actual_amount        := l_actual_amount;
p_unidentified_amount  := l_unidentified_amount;
p_misc_amount          := l_misc_amount;
p_nsf_amount           := l_nsf_amount ;
p_applied_count        := l_applied_count - l_misc_count;
p_unapplied_count      := l_unapplied_count + l_unidentified_count ;
p_misc_count           := l_misc_count;
return(1);
END;
RETURN NULL; end;
function c_unapplied_amountformula(c_unapplied_amount_A in number, c_on_account_amount in number, c_unidentified_amount in number) return number is
begin
/*srw.reference (c_unapplied_amount_A);*/null;
/*srw.reference (c_on_account_amount);*/null;
/*srw.reference (c_unidentified_amount);*/null;
return ( nvl(c_unapplied_amount_A,0) + nvl(c_on_account_amount,0) + nvl(c_unidentified_amount,0) );
end;
function f_all_amountsformula(cr_status_BB in varchar2, amount_B in number, cr_type_B in varchar2, reversal_category_B in varchar2, cash_receipt_id_B in number) return number is
begin
DECLARE
l_actual_amount          NUMBER := 0;
l_unidentified_amount    NUMBER := 0;
l_misc_amount            NUMBER := 0;
l_nsf_amount             NUMBER := 0;
l_on_account_amount      NUMBER := 0;
l_applied_count          NUMBER(10) := 0;
l_unapplied_count        NUMBER(10) := 0;
l_unidentified_count     NUMBER(10) := 0;
l_misc_count             NUMBER (10) := 0;
BEGIN
/*srw.reference (amount_B);*/null;
/*srw.reference (cr_status_BB);*/null;
/*srw.reference (cr_type_B);*/null;
/*srw.reference (reversal_category_B);*/null;
select
  decode(cr_status_BB, 'REV', 0, amount_B),
  decode(cr_status_BB, 'UNID', amount_B, 0),
  decode(cr_type_B,
         'MISC', decode(cr_status_BB,
                        'REV', 0,
                               amount_B),
                 0),
  decode(cr_status_BB, reversal_category_B,
         decode(cr_status_BB, 'NSF', amount_B, 'STOP', amount_B, 0), 0),
  decode(cr_status_BB, 'APP', 1, 0),
  decode(cr_status_BB, 'UNAPP', 1, 0),
  decode(cr_status_BB, 'UNID', 1, 0),
  decode(cr_type_B,
         'MISC', decode(cr_status_BB,
                        'REV', 0,
                               1),
                 0)
into
  l_actual_amount,
  l_unidentified_amount,
  l_misc_amount,
  l_nsf_amount,
  l_applied_count,
  l_unapplied_count,
  l_unidentified_count,
  l_misc_count
from dual;
if cr_status_BB = 'APP' then
    select sum(amount_applied)
    into   l_on_account_amount
    from   ar_receivable_applications
    where  cash_receipt_id = cash_receipt_id_B
    and    status = 'ACC';
    if nvl(l_on_account_amount,0) <> 0 then
       l_unapplied_count := l_unapplied_count + 1;
       l_applied_count   := l_applied_count - 1;
    end if;
end if;
pa_actual_amount        := l_actual_amount;
pa_unidentified_amount  := l_unidentified_amount;
pa_misc_amount          := l_misc_amount;
pa_nsf_amount           := l_nsf_amount ;
pa_applied_count        := l_applied_count - l_misc_count;
pa_unapplied_count      := l_unapplied_count + l_unidentified_count ;
pa_misc_count           := l_misc_count;
return(1);
END;
RETURN NULL; end;
function ca_unapplied_amountformula(ca_unapplied_amount_B in number, ca_on_account_amount in number, ca_unidentified_amount in number) return number is
begin
/*srw.reference (ca_unapplied_amount_B);*/null;
/*srw.reference (ca_on_account_amount);*/null;
/*srw.reference (ca_unidentified_amount);*/null;
return ( nvl(ca_unapplied_amount_B,0) + nvl(ca_on_account_amount,0) + nvl(ca_unidentified_amount,0) );
end;
function Order_By_MeaningFormula return VARCHAR2 is
begin
declare
	l_order_by 	VARCHAR2(80);
begin
	select meaning
	into   l_order_by
	from   ar_lookups
	where  lookup_type = 'SORT_BY_ARXSOC2'
        and    lookup_code = PH_ORDER_BY ;
	rp_order_by := l_order_by ;
	return( l_order_by );
	exception
	  WHEN NO_DATA_FOUND THEN
	     return(' ');
end ;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function p_actual_amount_p return number is
	Begin
	 return p_actual_amount;
	 END;
 Function p_unidentified_amount_p return number is
	Begin
	 return p_unidentified_amount;
	 END;
 Function p_misc_amount_p return number is
	Begin
	 return p_misc_amount;
	 END;
 Function p_nsf_amount_p return number is
	Begin
	 return p_nsf_amount;
	 END;
 Function p_applied_count_p return number is
	Begin
	 return p_applied_count;
	 END;
 Function p_unapplied_count_p return number is
	Begin
	 return p_unapplied_count;
	 END;
 Function p_misc_count_p return number is
	Begin
	 return p_misc_count;
	 END;
 Function pa_actual_amount_p return number is
	Begin
	 return pa_actual_amount;
	 END;
 Function pa_unidentified_amount_p return number is
	Begin
	 return pa_unidentified_amount;
	 END;
 Function pa_misc_amount_p return number is
	Begin
	 return pa_misc_amount;
	 END;
 Function pa_nsf_amount_p return number is
	Begin
	 return pa_nsf_amount;
	 END;
 Function pa_applied_count_p return number is
	Begin
	 return pa_applied_count;
	 END;
 Function pa_unapplied_count_p return number is
	Begin
	 return pa_unapplied_count;
	 END;
 Function pa_misc_count_p return number is
	Begin
	 return pa_misc_count;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND3_p return varchar2 is
	Begin
	 return RP_DATA_FOUND3;
	 END;
 Function RP_DATE_RANGE_p return varchar2 is
	Begin
	 return RP_DATE_RANGE;
	 END;
 Function RP_DATA_FOUND1_p return varchar2 is
	Begin
	 return RP_DATA_FOUND1;
	 END;
 Function RP_DATA_FOUND2_p return varchar2 is
	Begin
	 return RP_DATA_FOUND2;
	 END;
 Function RP_ORDER_BY_p return varchar2 is
	Begin
	 return RP_ORDER_BY;
	 END;
END AR_ARXSOC2_XMLP_PKG ;


/
