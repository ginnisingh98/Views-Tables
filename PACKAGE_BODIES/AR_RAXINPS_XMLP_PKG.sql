--------------------------------------------------------
--  DDL for Package Body AR_RAXINPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXINPS_XMLP_PKG" AS
/* $Header: RAXINPSB.pls 120.0 2007/12/27 14:25:05 abraghun noship $ */

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;
--ADDED AS FIX
P_GL_START_DATE_T:= to_char(P_GL_START_DATE,'DD-MON-YY');
P_GL_END_DATE_T :=to_char(P_GL_END_DATE,'DD-MON-YY');
P_TRX_END_DATE_T := to_char(P_TRX_END_DATE,'DD-MON-YY');
P_TRX_START_DATE_T := to_char(P_TRX_START_DATE,'DD-MON-YY');
--FIX ENDS
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
    l_report_name         VARCHAR2(80);
    l_gl_start_date       VARCHAR2 (11);
    l_gl_end_date         VARCHAR2 (11);
    l_trx_start_date      VARCHAR2 (11);
    l_trx_end_date       VARCHAR2 (11);

BEGIN

if p_gl_start_date is NULL then
  l_gl_start_date := '   ';
else
  l_gl_start_date := TO_CHAR(p_gl_start_date, 'DD-MON-YYYY') ;
end if ;
if p_gl_end_date is NULL then
  l_gl_end_date := '   ';
else
  l_gl_end_date := TO_CHAR(p_gl_end_date, 'DD-MON-YYYY');
end if ;

rp_gl_date_range  := 'GL Date From '||l_gl_start_date||' To '||l_gl_end_date ;


if p_trx_start_date is NULL then
  l_trx_start_date := '   ';
else
  l_trx_start_date := TO_CHAR(p_trx_start_date, 'DD-MON-YYYY') ;
end if ;
if p_trx_end_date is NULL then
  l_trx_end_date := '   ';
else
  l_trx_end_date := TO_CHAR(p_trx_end_date, 'DD-MON-YYYY');
end if ;

rp_trx_date_range  := 'Invoice Date From '||l_trx_start_date||' To '||l_trx_end_date ;

    RP_Company_Name := Company_Name;
    SELECT substr(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Invoice Posted to Suspense';
         RETURN('REPORT TITLE');
END;

RETURN NULL; end;

function AfterPForm return boolean is
begin

BEGIN

if p_gl_start_date is NOT NULL then
  lp_gl_start_date := 'and suspdist.gl_date >=:p_gl_start_date' ;
end if ;

if p_gl_end_date is NOT NULL then
  lp_gl_end_date := 'and suspdist.gl_date <= :p_gl_end_date' ;
end if ;

if p_trx_start_date is NOT NULL then
  lp_trx_start_date := 'and trx.trx_date >= :p_trx_start_date' ;
end if ;

if p_trx_end_date is NOT NULL then
  lp_trx_end_date := 'and trx.trx_date <= :p_trx_end_date' ;
end if ;

if p_type_low is NOT NULL then
  lp_type_low := 'and type.name >= :p_type_low' ;
end if ;

if p_type_high is NOT NULL then
  lp_type_high := 'and type.name <= :p_type_high' ;
end if ;

if p_start_currency_code is NOT NULL then
  lp_start_currency_code := 'and trx.invoice_currency_code >= :p_start_currency_code ';
end if ;

if p_end_currency_code is NOT NULL then
  lp_end_currency_code := 'and trx.invoice_currency_code <= :p_end_currency_code ';
end if ;
  DECLARE
  l_yes    VARCHAR2 (80);

  BEGIN
    select  meaning
      into l_yes
    from ar_lookups
    where lookup_code = 'Y'
    and  lookup_type = 'YES/NO'
    ;
  --p_yes := l_yes ;
  p_yes := ''''||l_yes||'''' ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_yes := '' ;
  END ;

  DECLARE
  l_no    VARCHAR2 (80);

  BEGIN
    select  meaning
      into l_no
    from ar_lookups
    where lookup_code = 'N'
    and  lookup_type = 'YES/NO'
    ;
  --p_no  := l_no ;
  p_no  := ''''||l_no||'''' ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_no := '' ;
  END ;

END ;
  return (TRUE);
end;

function c_class_labelformula(class in varchar2) return varchar2 is
begin

return ('Sum for '||class||' Class');
end;

function c_company_labelformula(D_company in varchar2) return varchar2 is
begin

return ('Sum for '||D_company||' Company');
end;

function c_post_labelformula(postable in varchar2) return varchar2 is
begin

return ('Sum for '||postable||' Postable');
end;

function c_currency_labelformula(currency_A in varchar2) return varchar2 is
begin

return ('Sum for '||currency_A||' Currency');
end;

function c_data_not_foundformula(company in varchar2) return number is
begin

rp_data_found := company ;
return (0);
end;

function cf_acc_messageformula(org_id in number) return number is
begin
  IF arp_util.open_period_exists('3000',org_id,p_gl_start_date,p_gl_end_date) THEN

      FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
      cp_acc_message := FND_MESSAGE.get;

  ELSE
      cp_acc_message := NULL;
  END IF;
return 0;
end;

--Functions to refer Oracle report placeholders--

 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
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
 Function RP_GL_DATE_RANGE_p return varchar2 is
	Begin
	 return RP_GL_DATE_RANGE;
	 END;
 Function RP_TRX_DATE_RANGE_p return varchar2 is
	Begin
	 return RP_TRX_DATE_RANGE;
	 END;
 Function RPD_REPORT_SUMMARY_p return varchar2 is
	Begin
	 return RPD_REPORT_SUMMARY;
	 END;
 Function RP_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_BAL_LPROMPT;
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
Function p_yes_p return varchar2 is
	Begin
	 return p_yes;
	 END;
Function p_no_p return varchar2 is
	Begin
	 return p_no;
	 END;
END AR_RAXINPS_XMLP_PKG ;


/
