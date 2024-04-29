--------------------------------------------------------
--  DDL for Package Body AR_ARXCTA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCTA_XMLP_PKG" AS
/* $Header: ARXCTAB.pls 120.0 2007/12/27 13:44:18 abraghun noship $ */

function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;


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
    l_gl_date_low  VARCHAR2 (11);
    l_gl_date_high VARCHAR2 (11);

BEGIN
RP_Company_Name := Company_Name;
if p_gl_date_low is NULL then
  l_gl_date_low := '   ';
else
  l_gl_date_low := TO_CHAR(p_gl_date_low, 'DD-MON-YYYY') ;
end if ;
if p_gl_date_high is NULL then
  l_gl_date_high := '   ';
else
  l_gl_date_high := TO_CHAR(p_gl_date_high, 'DD-MON-YYYY');
end if ;

rp_gl_date := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_GL_DATE_FROM_TO',
               'FROM_DATE', l_gl_date_low,
               'TO_DATE',l_gl_date_high);

rp_sum     := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_SUM');
rp_sumfor  := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_SUM_FOR');
rp_total   := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_TOTAL');
rp_func    := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_FUNC');
rp_grand   := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_GRAND');

   SELECT  substr(cp.user_concurrent_program_name,1, 80)
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
    THEN RP_REPORT_NAME := 'Adjustment Approval Report';
         RETURN('REPORT TITLE');

END;

RETURN NULL; end;

function AfterPForm return boolean is
begin

BEGIN

if p_customer_name_low is NOT NULL then
  lp_customer_name_low := 'and party.party_name >= :p_customer_name_low ' ;
end if ;

if p_customer_name_high is NOT NULL then
  lp_customer_name_high := 'and party.party_name <= :p_customer_name_high ' ;
end if ;

if p_customer_number_low is NOT NULL then
  lp_customer_number_low := 'and cust.account_number >= :p_customer_number_low ' ;
end if ;

if p_customer_number_high is NOT NULL then
  lp_customer_number_high := 'and cust.account_number <= :p_customer_number_high ' ;
end if ;

if p_adjustment_name_low is NOT  NULL then
  lp_adjustment_name_low := 'and rcvbl_trx.name >= :p_adjustment_name_low ' ;
end if ;

if p_adjustment_name_high is NOT  NULL then
  lp_adjustment_name_high := 'and rcvbl_trx.name <= :p_adjustment_name_high ' ;
end if ;


if p_invoice_low is NOT NULL then
  lp_invoice_low := ' and trx.trx_number >= :p_invoice_low ' ;
end if ;

if p_invoice_high is NOT NULL then
  lp_invoice_high := ' and trx.trx_number <= :p_invoice_high ' ;
end if ;

if p_invoice_type_low is NOT  NULL then
  lp_invoice_type_low := ' and ra_cust_trx_types.name  >= :p_invoice_type_low ';
end if ;

if p_invoice_type_high is NOT  NULL then
  lp_invoice_type_high := ' and ra_cust_trx_types.name  <= :p_invoice_type_high ';
end if ;

if p_gl_date_low is NOT NULL then
  lp_gl_date_low := ' and adj.gl_date  >= :p_gl_date_low ' ;
end if ;

if p_gl_date_high is NOT NULL then
  lp_gl_date_high := ' and adj.gl_date  <= :p_gl_date_high ' ;
end if ;

if p_status_low is NOT NULL then
  lp_status_low := ' and l2.meaning >= :p_status_low ';
end if ;

if p_status_high is NOT NULL then
  lp_status_high := ' and l2.meaning <= :p_status_high ';
end if ;

if p_created_by_low is NOT NULL then
  lp_created_by_low :=' and fndc.user_name  >= :p_created_by_low' ;
end if ;

if p_created_by_high is NOT NULL then
  lp_created_by_high :=' and fndc.user_name  <= :p_created_by_high' ;
end if ;


if (initcap(p_order_by) like  'Cr%') then
lp_order_by := 'order by  ps.invoice_currency_code,'||''||
	        'fndc.user_name, party.party_name, trx.trx_number,'||''||
	        'ps.due_date, adj.gl_date desc, rcvbl_trx.name, ra_cust_trx_types.name'
                ;
elsif (initcap(p_order_by) like  'Cu%') then
lp_order_by := 'order by  ps.invoice_currency_code, party.party_name,'||''||
	        'trx.trx_number, ps.due_date, adj.gl_date desc, '||''||
                'rcvbl_trx.name, ra_cust_trx_types.name'
                ;
elsif (p_order_by ='Adjustment Status') then
lp_order_by := 'order by ps.invoice_currency_code, l2.meaning,'||''||
                ' party.party_name, trx.trx_number, ps.due_date,'||''||
	        'adj.gl_date desc, rcvbl_trx.name, ra_cust_trx_types.name'
                ;
elsif  (p_order_by ='Adjustment Name') then
lp_order_by := ' order by  ps.invoice_currency_code, rcvbl_trx.name,'||''||
	       'party.party_name, trx.trx_number, ps.due_date, adj.gl_date desc,'||''||
	       'ra_cust_trx_types.name' ;

end if ;

END ;
  return (TRUE);
end;

function c_status_summary_labelformula(Currency_Code in varchar2, Status_1 in varchar2) return varchar2 is
BEGIN
   DECLARE
     l_temp VARCHAR2 (2000);
   BEGIN
     l_temp := Currency_Code||' ' || rp_sumfor || ' '||Status_1 ;

     if p_curr_code is null then
        l_temp := l_temp || ' ' || rp_func;
     end if;

     return (l_temp);
   END;
RETURN NULL; END;

function c_name_summary_labelformula(Currency_Code in varchar2, Name_1 in varchar2) return varchar2 is
begin

   DECLARE
      l_temp  VARCHAR2 (2000);
   BEGIN

      l_temp := Currency_Code||' ' || rp_sumfor || ' '||Name_1 ;

      if p_curr_code is null then
         l_temp := l_temp || ' ' || rp_func;
      end if;

   return (l_temp);

   END;
RETURN NULL; end;

function c_creator_labelformula(Currency_Code in varchar2, Created_by in varchar2) return varchar2 is
begin

   DECLARE
     l_temp  VARCHAR2 (2000);
   BEGIN
     l_temp := Currency_Code|| ' '  || rp_sumfor || ' '||Created_by ;

     if p_curr_code is null then
        l_temp := l_temp || ' ' || rp_func;
     end if;

     return (l_temp);
   END ;
RETURN NULL; end;

function c_currency_summary_labelformul(currency_Code in varchar2) return varchar2 is
begin

DECLARE

l_temp VARCHAR2 (2000);

BEGIN

l_temp := rp_total||' '||currency_Code;

if p_curr_code is null then
   l_temp := l_temp || ' ' || rp_func;
end if;

return (l_temp);

END ;
RETURN NULL; end;

function C_ORDER_BYFormula return VARCHAR2 is
begin

DECLARE
   a  VARCHAR2(2000);
   b  VARCHAR2(80);
BEGIN
   a := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_ORDER_BY');
   select meaning
   into b
   from ar_lookups
   where lookup_type = 'SORT_BY_ARXCTA'
   and upper(lookup_code) = upper(p_order_by);

   p_meaning := b;

   rp_order_by := rtrim(a) || ' : ' || rtrim(b);
END ;

RETURN NULL; end;

function c_data_not_foundformula(Currency_Code in varchar2) return varchar2 is
begin

rp_data_found := Currency_Code ;
return (0);
end;

function C_GRAND_TOTAL_LABELFormula return VARCHAR2 is
l_temp varchar2(5000);

begin
   if p_curr_code is null then
      l_temp := rp_grand || ' ' || rp_func;
   else
      l_temp := rp_grand || ' ' ||
                p_curr_code || ' ' || rp_func;
   end if;
   return(l_temp);
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
	 return substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_GL_DATE_p return varchar2 is
	Begin
	 return RP_GL_DATE;
	 END;
 Function RP_ORDER_BY_p return varchar2 is
	Begin
	 return RP_ORDER_BY;
	 END;
 Function RP_FUNC_CURRENCY_p return varchar2 is
	Begin
	 return RP_FUNC_CURRENCY;
	 END;
 Function P_MEANING_p return varchar2 is
	Begin
	 return P_MEANING;
	 END;
 Function RP_TOTAL_p return varchar2 is
	Begin
	 return RP_TOTAL;
	 END;
 Function RP_SUM_p return varchar2 is
	Begin
	 return RP_SUM;
	 END;
 Function RP_FUNC_p return varchar2 is
	Begin
	 return RP_FUNC;
	 END;
 Function RP_SUMFOR_p return varchar2 is
	Begin
	 return RP_SUMFOR;
	 END;
 Function RP_GRAND_p return varchar2 is
	Begin
	 return RP_GRAND;
	 END;
END AR_ARXCTA_XMLP_PKG ;


/
