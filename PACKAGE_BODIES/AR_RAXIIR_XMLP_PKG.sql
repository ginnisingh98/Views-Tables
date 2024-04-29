--------------------------------------------------------
--  DDL for Package Body AR_RAXIIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXIIR_XMLP_PKG" AS
/* $Header: RAXIIRB.pls 120.1 2008/01/07 14:53:15 abraghun noship $ */

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
    THEN RP_REPORT_NAME := 'Incomplete Invoice Report';
         RETURN('REPORT TITLE');
END;
RETURN NULL; end;

function c_data_not_foundformula(Number_A in varchar2) return number is
begin

rp_data_found := Number_A ;
return (0);
end;

function AfterPForm return boolean is
begin

DECLARE

l_min_customer_number     VARCHAR2 (50);

BEGIN


pd_min_customer_name := '-19B23' ;

select min(account_number)
into l_min_customer_number
from hz_cust_accounts;

pd_min_customer_number := l_min_customer_number ;

if p_invoice_num_low is NOT NULL then
  lp_item_number_low := 'and ct.trx_number >= :p_invoice_num_low' ;
end if ;
if p_invoice_num_high is NOT NULL then
  lp_item_number_high := 'and ct.trx_number <= :p_invoice_num_high' ;
end if ;

if p_customer_number_low is NOT NULL then
   lp_customer_number_low := 'and nvl(cust.account_number,:pd_min_customer_number) >= :p_customer_number_low' ;
end if ;
if p_customer_number_high is NOT NULL then
   lp_customer_number_high := 'and nvl(cust.account_number,:pd_min_customer_number) <= :p_customer_number_high' ;
end if ;

if p_customer_name_low is NOT NULL then
   lp_customer_name_low := 'and nvl(party.party_name,:pd_min_customer_name) >= :p_customer_name_low' ;
end if ;
if p_customer_name_high is NOT NULL then
   lp_customer_name_high := 'and nvl(party.party_name,:pd_min_customer_name) <= :p_customer_name_high' ;
end if ;

END ;
  return (TRUE);
end;

function CF_ORDER_BYFormula return Char is

   order_meaning AR_LOOKUPS.MEANING%TYPE;
begin

  SELECT
    MEANING
  INTO order_meaning
  FROM AR_LOOKUPS
  WHERE LOOKUP_TYPE = 'SORT_BY_RAXIIR'
        AND UPPER(LOOKUP_CODE) = UPPER(P_ORDER_BY);

  RETURN (ORDER_MEANING);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(P_ORDER_BY);

end;

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
END AR_RAXIIR_XMLP_PKG ;


/
