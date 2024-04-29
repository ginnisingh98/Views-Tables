--------------------------------------------------------
--  DDL for Package Body AR_RAXCUS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXCUS_XMLP_PKG" AS
/* $Header: RAXCUSB.pls 120.0 2007/12/27 14:17:16 abraghun noship $ */

function BeforeReport return boolean is
begin

	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
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
BEGIN
    RP_Company_Name := Company_Name;
    SELECT substrb(cp.user_concurrent_program_name,1,80)
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
    THEN RP_REPORT_NAME := 'Customer Listing - Summary';
         RETURN('REPORT TITLE');
END;
RETURN NULL; end;

function AfterPForm return boolean is
begin

DECLARE

l_status_low                   VARCHAR2 (80);
l_status_high                  VARCHAR2 (80);
l_customer_name_low            VARCHAR2 (50);
l_customer_name_high           VARCHAR2 (50);
l_customer_number_low          VARCHAR2 (30);
l_customer_number_high         VARCHAR2 (30);

BEGIN

         	/*SRW.USER_EXIT('FND SRWINIT');*/null;


select  decode(upper(p_status_low),  NULL, min(look.lookup_code),
					   p_status_low),
	decode(upper(p_status_high), NULL, max(look.lookup_code),
					   p_status_high),
	decode(upper(p_customer_name_low),    NULL, min(substrb(party.party_name,1,50)),
				    	   p_customer_name_low),
	decode(upper(p_customer_name_high),   NULL, max(substrb(party.party_name,1,50)),
				    	   p_customer_name_high),
	decode(upper(p_customer_number_low), NULL, min(c.account_number),
		     		      	     p_customer_number_low),
	decode(upper(p_customer_number_high),NULL, max(c.account_number),
				      	     p_customer_number_high)
into 	l_status_low,
	l_status_high,
	l_customer_name_low,
	l_customer_name_high,
	l_customer_number_low,
	l_customer_number_high
from 	hz_cust_accounts c,
	hz_parties party,
	ar_lookups look
where	c.status = look.lookup_code
   and  c.party_id = party.party_id
        and    look.lookup_type = 'CODE_STATUS';

pr_customer_name_low      := l_customer_name_low ;
pr_customer_name_high     := l_customer_name_high ;
pr_customer_number_low    := l_customer_number_low ;
pr_customer_number_high   := l_customer_number_high ;
pr_status_low             := l_status_low ;
pr_status_high            := l_status_high ;

if p_city_low is NOT NULL then
  lp_city_low := ' and loc.city >= :p_city_low ';
end if ;
if p_city_high is NOT NULL then
  lp_city_high := ' and loc.city <= :p_city_high ';
end if ;

if p_state_low is NOT NULL then
  lp_state_low := ' and loc.state >= :p_state_low ';
end if ;
if p_state_high is NOT NULL then
  lp_state_high := ' and loc.state <= :p_state_high ';
end if ;

if p_zip_low is NOT NULL then
  lp_zip_low := ' and loc.postal_code >= :p_zip_low ';
end if ;
if p_zip_high is NOT NULL then
  lp_zip_high := ' and loc.postal_code <= :p_zip_high ';
end if ;


if p_site_low is NOT NULL then
  lp_site_low := ' and look.lookup_code >= :p_site_low ';
end if ;
if p_site_high is NOT NULL then
  lp_site_high := ' and look.lookup_code <= :p_site_high ';
end if ;

END ;
  return (TRUE);
end;

function c_data_not_foundformula(Customer_Name in varchar2) return number is
begin

rp_data_found := Customer_Name ;
return (0);
end;

function CF_ORDER_BYFormula return Char is


begin
return(ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORT_BY_RAXCUS',p_order_by));

end ;

--Functions to refer Oracle report placeholders--

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
END AR_RAXCUS_XMLP_PKG ;


/
