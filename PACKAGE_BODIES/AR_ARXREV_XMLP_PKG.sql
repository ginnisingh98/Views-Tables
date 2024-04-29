--------------------------------------------------------
--  DDL for Package Body AR_ARXREV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXREV_XMLP_PKG" AS
/* $Header: ARXREVB.pls 120.0 2007/12/27 14:04:57 abraghun noship $ */
function BeforeReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
rp_sum_for := ARP_STANDARD.FND_MESSAGE(
               'AR_REPORTS_SUM_FOR');
rp_none    := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_NONE');
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
if p_rev_gl_start_date is NULL then
  l_date_low := '   ';
else
  l_date_low := p_rev_gl_start_date ;
end if ;
if p_rev_gl_end_date is NULL then
  l_date_high := '   ';
else
  l_date_high := p_rev_gl_end_date;
end if ;
rp_date_range := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_GL_DATE_FROM_TO',
                                           'FROM_DATE', l_date_low,
					   'TO_DATE',l_date_high);
    RP_Company_Name := Company_Name;
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
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;
function AfterPForm return boolean is
begin
DECLARE
l_order_by            VARCHAR2 (100);
BEGIN
P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
P_REV_GL_START_DATE1 := to_char(P_REV_GL_START_DATE,'dd-mon-yy');
P_REV_GL_END_DATE1 := to_char(P_REV_GL_START_DATE,'dd-mon-yy');
if p_bank_account_low is NOT NULL then
  lp_bank_account_low  := ' and bank.bank_account_name >= :p_bank_account_low' ;
end if ;
if p_bank_account_high is NOT NULL then
  lp_bank_account_high  := ' and bank.bank_account_name <= :p_bank_account_high' ;
end if ;
if p_curr_low is NOT NULL then
  lp_curr_low := 'and cr.currency_code >= :p_curr_low ' ;
end if ;
if p_curr_high is NOT NULL then
  lp_curr_high := 'and cr.currency_code <= :p_curr_high ' ;
end if ;
if p_rev_gl_start_date is NOT NULL then
  lp_rev_gl_start_date    := 'and     crh2.gl_date >= :p_rev_gl_start_date';
  lp_rev_gl_start_date_dm := 'and     ps.gl_date   >= :p_rev_gl_start_date';
end if ;
if p_rev_gl_end_date is NOT NULL then
  lp_rev_gl_end_date    := 'and     crh2.gl_date <= :p_rev_gl_end_date';
  lp_rev_gl_end_date_dm := 'and     ps.gl_date   <= :p_rev_gl_end_date';
end if ;
if p_cust_low is NOT NULL then
   lp_customer_low      := 'and cust.ACCOUNT_NUMBER >= :p_cust_low';
end if;
if p_cust_high is NOT NULL then
   lp_customer_high      := 'and cust.ACCOUNT_NUMBER <= :p_cust_high';
end if;
if  p_reason is NOT NULL then
     lp_reason 	  :=  'and cr.reversal_reason_code = :p_reason';
end if;
END ;  return (TRUE);
end;
function c_calc_amountformula(r_type in varchar2, amount in number, functional_amount in number, reversal_category in varchar2) return number is
begin
BEGIN
/*srw.reference (r_type);*/null;
/*srw.reference (reversal_category);*/null;
/*srw.reference (amount);*/null;
/*srw.reference (functional_amount);*/null;
c_stop_amt      := 0 ;
c_rev_amt       := 0 ;
c_nsf_amt       := 0 ;
c_misc_amt      := 0 ;
c_cash_amt      := 0 ;
c_stop_amt_func := 0 ;
c_rev_amt_func  := 0 ;
c_nsf_amt_func  := 0 ;
c_misc_amt_func := 0 ;
c_cash_amt_func := 0 ;
if r_type = 'Misc' then
  c_misc_amt      := amount ;
  c_misc_amt_func := functional_amount ;
elsif  r_type = 'Cash' then
  c_cash_amt      := amount ;
  c_cash_amt_func := functional_amount ;
end if ;
if  reversal_category = 'NSF' then
  c_nsf_amt      := amount ;
  c_nsf_amt_func := functional_amount ;
elsif  reversal_category = 'REV' then
  c_rev_amt      := amount ;
  c_rev_amt_func := functional_amount ;
elsif  reversal_category = 'STOP' then
  c_stop_amt      := amount ;
  c_stop_amt_func := functional_amount ;
elsif  reversal_category = 'CCRREV' then
  c_stop_amt      := amount ;
  c_stop_amt_func := functional_amount ;
end if ;
return (0);
END ;
RETURN NULL; end;
function c_summary_label_bankformula(bank_name in varchar2) return varchar2 is
begin
RP_DATA_FOUND := 'YES';
/*srw.reference (bank_name);*/null;
return (rp_sum_for || ' ' || bank_name);
end;
function c_dm_calc_amountformula(rev_type in varchar2, Amount_B in number, functional_Amount_B in number, Reversal_category_B in varchar2) return number is
begin
BEGIN
/*srw.reference (rev_type);*/null;
/*srw.reference (Reversal_category_B);*/null;
/*srw.reference (Amount_B);*/null;
/*srw.reference (functional_Amount_B);*/null;
c_stop_dm_amt      := 0 ;
c_rev_dm_amt       := 0 ;
c_nsf_dm_amt       := 0 ;
c_misc_dm_amt      := 0 ;
c_cash_dm_amt      := 0 ;
c_stop_dm_amt_func := 0 ;
c_rev_dm_amt_func  := 0 ;
c_nsf_dm_amt_func  := 0 ;
c_misc_dm_amt_func := 0 ;
c_cash_dm_amt_func := 0 ;
if rev_type = 'Misc' then
  c_misc_dm_amt      := Amount_B ;
  c_misc_dm_amt_func := functional_Amount_B ;
elsif  rev_type = 'Cash' then
  c_cash_dm_amt      := Amount_B ;
  c_cash_dm_amt_func := functional_Amount_B ;
end if ;
if  Reversal_category_B = 'NSF' then
  c_nsf_dm_amt      := Amount_B ;
  c_nsf_dm_amt_func := functional_Amount_B ;
elsif  Reversal_category_B = 'REV' then
  c_rev_dm_amt      := Amount_B ;
  c_rev_dm_amt_func := functional_Amount_B ;
elsif  Reversal_category_B = 'STOP' then
  c_stop_dm_amt      := Amount_B ;
  c_stop_dm_amt_func := functional_Amount_B ;
end if ;
return (0);
END ;
RETURN NULL; end;
function c_summary_label_bank_dmformula(Bank_name_b in varchar2) return varchar2 is
begin
RP_DATA_FOUND_DM := 'YES';
/*srw.reference (Bank_name_b);*/null;
return (rp_sum_for || ' ' || Bank_name_b);
end;
function c_qcd_summary_label_custformul(QCD_DUMMY_NAME in varchar2) return varchar2 is
begin
RP_CUST_DATA_FOUND_DM := 'YES';
/*srw.reference (QCD_DUMMY_NAME);*/null;
return (rp_sum_for || ' ' || QCD_DUMMY_NAME);
end;
function c_qcr_summary_label_custformul(QCR_DUMMY_NAME in varchar2) return varchar2 is
begin
/*srw.reference (QCR_DUMMY_NAME);*/null;
RP_CUST_DATA_FOUND := 'YES';
return(rp_sum_for || ' ' || QCR_DUMMY_NAME);
end;
--Functions to refer Oracle report placeholders--
 Function c_cash_amt_func_p return number is
	Begin
	 return c_cash_amt_func;
	 END;
 Function c_cash_amt_p return number is
	Begin
	 return c_cash_amt;
	 END;
 Function c_misc_amt_func_p return number is
	Begin
	 return c_misc_amt_func;
	 END;
 Function c_misc_amt_p return number is
	Begin
	 return c_misc_amt;
	 END;
 Function c_nsf_amt_func_p return number is
	Begin
	 return c_nsf_amt_func;
	 END;
 Function c_nsf_amt_p return number is
	Begin
	 return c_nsf_amt;
	 END;
 Function c_rev_amt_func_p return number is
	Begin
	 return c_rev_amt_func;
	 END;
 Function c_rev_amt_p return number is
	Begin
	 return c_rev_amt;
	 END;
 Function c_stop_amt_func_p return number is
	Begin
	 return c_stop_amt_func;
	 END;
 Function c_stop_amt_p return number is
	Begin
	 return c_stop_amt;
	 END;
 Function c_cash_dm_amt_func_p return number is
	Begin
	 return c_cash_dm_amt_func;
	 END;
 Function c_misc_dm_amt_func_p return number is
	Begin
	 return c_misc_dm_amt_func;
	 END;
 Function c_nsf_dm_amt_func_p return number is
	Begin
	 return c_nsf_dm_amt_func;
	 END;
 Function c_rev_dm_amt_func_p return number is
	Begin
	 return c_rev_dm_amt_func;
	 END;
 Function c_stop_dm_amt_func_p return number is
	Begin
	 return c_stop_dm_amt_func;
	 END;
 Function c_cash_dm_amt_p return number is
	Begin
	 return c_cash_dm_amt;
	 END;
 Function c_misc_dm_amt_p return number is
	Begin
	 return c_misc_dm_amt;
	 END;
 Function c_nsf_dm_amt_p return number is
	Begin
	 return c_nsf_dm_amt;
	 END;
 Function c_rev_dm_amt_p return number is
	Begin
	 return c_rev_dm_amt;
	 END;
 Function c_stop_dm_amt_p return number is
	Begin
	 return c_stop_dm_amt;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_DATE_RANGE_p return varchar2 is
	Begin
	 return RP_DATE_RANGE;
	 END;
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 Function RP_DATA_FOUND_DM_p return varchar2 is
	Begin
	 return RP_DATA_FOUND_DM;
	 END;
 Function RP_CUST_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_CUST_DATA_FOUND;
	 END;
 Function RP_CUST_DATA_FOUND_DM_p return varchar2 is
	Begin
	 return RP_CUST_DATA_FOUND_DM;
	 END;
 Function RPD_FUNC_AMT_p return varchar2 is
	Begin
	 return RPD_FUNC_AMT;
	 END;
 Function RPD_CASH_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_CASH_AMT_FUNC;
	 END;
 Function RPD_MISC_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_MISC_AMT_FUNC;
	 END;
 Function RPD_NSF_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_NSF_AMT_FUNC;
	 END;
 Function RPD_REV_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_REV_AMT_FUNC;
	 END;
 Function RPD_STOP_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_STOP_AMT_FUNC;
	 END;
 Function RPD_FUNC_DM_AMT_p return varchar2 is
	Begin
	 return RPD_FUNC_DM_AMT;
	 END;
 Function RPD_CASH_DM_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_CASH_DM_AMT_FUNC;
	 END;
 Function RPD_MISC_DM_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_MISC_DM_AMT_FUNC;
	 END;
 Function RPD_NSF_DM_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_NSF_DM_AMT_FUNC;
	 END;
 Function RPD_REV_DM_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_REV_DM_AMT_FUNC;
	 END;
 Function RPD_STOP_DM_AMT_FUNC_p return varchar2 is
	Begin
	 return RPD_STOP_DM_AMT_FUNC;
	 END;
 Function RPD_CUST_FUNC_p return varchar2 is
	Begin
	 return RPD_CUST_FUNC;
	 END;
 Function RPD_DM_CUST_FUNC_p return varchar2 is
	Begin
	 return RPD_DM_CUST_FUNC;
	 END;
 Function rp_none_p return varchar2 is
	Begin
	 return rp_none;
	 END;
 Function rp_sum_for_p return varchar2 is
	Begin
	 return rp_sum_for;
	 END;
END AR_ARXREV_XMLP_PKG ;


/
