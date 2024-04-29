--------------------------------------------------------
--  DDL for Package Body AR_ARXCHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCHR_XMLP_PKG" AS
/* $Header: ARXCHRB.pls 120.0 2007/12/27 13:39:55 abraghun noship $ */

function BeforeReport return boolean is

l_ld_sp varchar2(1);
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;


rp_message:=null;
IF to_number(p_reporting_level) = 1000 THEN
l_ld_sp:= mo_utils.check_ledger_in_sp(TO_NUMBER(p_reporting_entity_id));

IF l_ld_sp = 'N' THEN
     FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
     RP_MESSAGE := FND_MESSAGE.get;

END IF;
END IF;


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
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;

function AfterPForm return boolean is
begin
XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

p_org_where_ps  := XLA_MO_REPORTING_API.Get_Predicate('ps', null);
/*srw.message(100,'done with get_predicate ps');*/null;


p_org_where_site:= XLA_MO_REPORTING_API.Get_Predicate('site', null);
/*srw.message(101,'done with get_predicate aite');*/null;


p_org_where_addr := XLA_MO_REPORTING_API.Get_Predicate('acct_site', null);
/*srw.message(101,'done with get_predicate addr');*/null;


if p_reporting_entity_id  is NOT NULL then
   p_reporting_entity_name := XLA_MO_REPORTING_API.get_reporting_entity_name ;
end if;
/*srw.message(101,'done with get_reporting_entity_name');*/null;


p_reporting_level_name :=  XLA_MO_REPORTING_API.get_reporting_level_name;
/*srw.message(101,'done with get_reporting_level_name');*/null;


/*srw.message( 102,' p_org_where_ps    '|| p_org_where_ps);*/null;

/*srw.message( 102,' p_org_where_site  '|| p_org_where_site);*/null;

/*srw.message( 102,' p_org_where_addr  '|| p_org_where_addr);*/null;



BEGIN

if p_status_low is NOT NULL then
  lp_status_low := 'and status.meaning >= :p_status_low';
end if ;

if p_status_high is NOT NULL then
  lp_status_high := 'and status.meaning <= :p_status_high';
end if ;

if p_customer_name_low is NOT NULL then
  lp_customer_name_low := 'and party.party_name >= :p_customer_name_low' ;
end if ;
if p_customer_name_high is NOT NULL then
  lp_customer_name_high := 'and party.party_name <= :p_customer_name_high' ;
end if ;

if p_customer_number_low is NOT NULL then
  lp_customer_number_low := 'and cust.account_number >= :p_customer_number_low' ;
end if ;
if p_customer_number_high is NOT NULL then
  lp_customer_number_high := 'and cust.account_number <= :p_customer_number_high' ;
end if ;

if p_collector_low is NOT NULL then
  lp_collector_low := 'and collect.name >= :p_collector_low' ;
end if ;
if p_collector_high is NOT NULL then
  lp_collector_high := 'and collect.name <= :p_collector_high' ;
end if ;

if p_currency_code is NOT NULL then
  lp_currency_code := 'and ps.invoice_currency_code = :p_currency_code' ;
end if ;

END ;
  return (TRUE);
end;

function c_get_phone_numberformula(address_id in number, customer_id in number) return number is
begin

DECLARE

l_phone_number     VARCHAR2 (100);

cursor Getphone IS
select
	decode(cont_point.phone_area_code,
               null, null,
               '(' || cont_point.phone_area_code || ')' ) ||
		decode(cont_point.contact_point_type,'TLX',
                       cont_point.telex_number, cont_point.phone_number)
from
	hz_contact_points cont_point,
        hz_cust_account_roles car
where
       car.party_id = cont_point.owner_table_id
    and cont_point.owner_table_name = 'HZ_PARTIES'
    and cont_point.contact_point_type not in ('EDI','EMAIL','WEB')
    and car.cust_acct_site_id	= address_id
    and (   car.cust_account_role_id	= c_contact_id
	 OR not exists ( select 'x'
			     from hz_cust_account_roles p2
			     where p2.cust_acct_site_id = car.cust_acct_site_id
			       and p2.cust_account_role_id = car.cust_account_role_id
                       )
        )
         and rownum = 1
Union
select
	decode(cont_point.phone_area_code,
               null, null,
               '(' || cont_point.phone_area_code || ')' ) ||
		decode(cont_point.contact_point_type,'TLX',
                       cont_point.telex_number, cont_point.phone_number)
from
	hz_contact_points cont_point,
        hz_cust_account_roles car
where
       car.party_id = cont_point.owner_table_id
    and cont_point.owner_table_name = 'HZ_PARTIES'
    and cont_point.contact_point_type not in ('EDI','EMAIL','WEB')
    and car.cust_account_id	= customer_id
    and not exists (
		select 'x'
		from hz_cust_account_roles p2
		where p2.cust_acct_site_id = car.cust_acct_site_id)
    and rownum = 1
 ;

BEGIN

/*SRW.REFERENCE (address_id );*/null;

/*SRW.REFERENCE (c_contact_id );*/null;

/*SRW.REFERENCE (customer_id );*/null;


c_phone_number := '' ;

OPEN GetPhone;
Fetch Getphone INTO l_phone_number;

c_phone_number := l_phone_number ;
return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  c_phone_number := '' ;
   return (0);
END ;

RETURN NULL; end;

function C_PRIMARY_CONTACTFormula(p_address_id varchar2) return Number is
begin

DECLARE
l_contact_id      NUMBER (12);
l_contact_name    VARCHAR2   (60);

BEGIN

/*SRW.REFERENCE (address_id );*/null;


c_contact_name := '' ;
c_contact_id   := 0 ;

select
	substr(party.person_first_name,1,1) || ' ' ||
               substrb(party.person_last_name,1,50),
	acct_role.cust_account_role_id
into
	l_contact_name,
	l_contact_id
from
	hz_cust_account_roles acct_role,
        hz_parties party,
        hz_relationships rel,
	hz_role_responsibility role_res
where
	acct_role.cust_account_role_id		= role_res.cust_account_role_id
    and acct_role.party_id = rel.party_id
    and acct_role.role_type = 'CONTACT'
    and rel.subject_id = party.party_id
    and rel.subject_table_name = 'HZ_PARTIES'
    and rel.object_table_name = 'HZ_PARTIES'
    and rel.directional_flag = 'F'
    and	role_res.responsibility_type	= 'BILL_TO'
    and	acct_role.cust_acct_site_id		= p_address_id
    and	rownum			= 1
;

c_contact_id   := l_contact_id ;
c_contact_name := l_contact_name ;

return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN

c_contact_id   := 0;
c_contact_name := '' ;
return (0);
END ;

RETURN NULL; end;

function c_no_data_foundformula(Currency_Main in varchar2) return number is
begin

rp_data_found := nvl(Currency_Main,'***') ;
return (0);

end;

--Functions to refer Oracle report placeholders--

 Function c_phone_number_p return varchar2 is
	Begin
	 return c_phone_number;
	 END;
 Function c_contact_id_p return number is
	Begin
	 return c_contact_id;
	 END;
 Function c_contact_name_p return varchar2 is
	Begin
	 return c_contact_name;
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
 Function RP_DATE_RANGE_p return varchar2 is
	Begin
	 return RP_DATE_RANGE;
	 END;
 Function RP_message_p return varchar2 is
	Begin
	 return RP_message;
	 END;
END AR_ARXCHR_XMLP_PKG ;


/
