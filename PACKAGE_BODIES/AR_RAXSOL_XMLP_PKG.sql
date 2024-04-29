--------------------------------------------------------
--  DDL for Package Body AR_RAXSOL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXSOL_XMLP_PKG" AS
/* $Header: RAXSOLB.pls 120.0 2007/12/27 14:34:03 abraghun noship $ */

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;




get_boiler_plates ;

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
    THEN RP_REPORT_NAME := 'Transaction Batch Source Listing';
         RETURN('REPORT TITLE');
END;
RETURN NULL; end;

function C_GET_MEANINGFormula return Number is
begin

BEGIN

  DECLARE
  l_id      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_id
	from ar_lookups
	where lookup_type = 'REFERENCE'
	and   lookup_code = 'Id';

  rp_id  :=  l_id  ;

  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_id := '' ;
  END ;

  DECLARE
  l_none      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_none
	from ar_lookups
	where lookup_type = 'REFERENCE'
	and   lookup_code = 'None';

  rp_none  :=  l_none  ;

  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_none := '' ;
  END ;

  DECLARE
  l_number      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_number
	from ar_lookups
	where lookup_type = 'REFERENCE'
	and   lookup_code = 'Number';

  rp_number  :=  l_number  ;

  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_number := '' ;
  END ;


  DECLARE
  l_segment      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_segment
	from ar_lookups
	where lookup_type = 'REFERENCE'
	and   lookup_code = 'Segment';

  rp_segment  :=  l_segment  ;

  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_segment := '' ;
  END ;


  DECLARE
  l_value      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_value
	from ar_lookups
	where lookup_type = 'REFERENCE'
	and   lookup_code = 'Value';

  rp_value  :=  l_value  ;
  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_value := '' ;
  END ;


  DECLARE
  l_yes      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_yes
	from ar_lookups
	where lookup_type = 'YES/NO'
	and   lookup_code = 'Y';

  rp_yes     :=  l_yes    ;
  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_yes := '' ;
  END ;


  DECLARE
  l_no      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_no
	from ar_lookups
	where lookup_type = 'YES/NO'
	and   lookup_code = 'N';

  rp_no     :=  l_no     ;
  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_no := '' ;
  END ;

  DECLARE
  l_amt      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_amt
	from ar_lookups
	where lookup_type = 'AMT/PER'
	and   lookup_code = 'Amount';

  rp_amt    :=  l_amt   ;
  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_amt := '' ;
  END ;

  DECLARE
  l_per      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_per
	from ar_lookups
	where lookup_type = 'AMT/PER'
	and   lookup_code = 'Percent';

  rp_per    :=  l_per    ;
  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_per := '' ;
  END ;

  DECLARE
  l_code      VARCHAR2 (80);
  BEGIN
  select meaning
	into l_code
	from ar_lookups
	where lookup_type = 'CODE'
	and   lookup_code = 'Code';

  rp_code    :=  l_code    ;
  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   l_code := '' ;
  END ;
return (0);
END ;

RETURN NULL; end;

--function c_last_invoice_numberformula(auto_trx_numbering in varchar2, batch_source_id in number) return char is
function c_last_invoice_numberformula(auto_trx_numbering in varchar2, batch_source_id_t in number) return char is
begin

DECLARE
  l_last_invoice_number varchar2(20) ;

BEGIN


if auto_trx_numbering  <> 'N' then
   SELECT MAX(TRX_NUMBER)
        INTO   l_last_invoice_number
        FROM   RA_CUSTOMER_TRX
        WHERE  BATCH_SOURCE_ID = batch_source_id_t
    ;
end if ;
return (l_last_invoice_number);

END ;
RETURN NULL; end;

function RP_SYSDATEFormula return VARCHAR2 is
begin

DECLARE

  l_date   VARCHAR2 (20);

BEGIN
  SELECT SYSDATE
         INTO l_date
         FROM
         DUAL ;
return (l_date);
END ;

RETURN NULL; end;

function c_data_not_foundformula(Name in varchar2) return number is
begin

rp_data_found := Name ;
return (0);

end;

procedure get_lookup_meaning(p_lookup_type	in VARCHAR2,
			     p_lookup_code	in VARCHAR2,
			     p_lookup_meaning  	in out NOCOPY VARCHAR2)
			    is

w_meaning varchar2(80);

begin

select meaning
  into w_meaning
  from fnd_lookups
 where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code ;

p_lookup_meaning := w_meaning ;

exception
   when no_data_found then
        		p_lookup_meaning := null ;

end ;

procedure get_boiler_plates is

w_industry_code varchar2(20);
w_industry_stat varchar2(20);

begin

if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
   if w_industry_code = 'C' then
      c_salesrep_title    := null ;
      c_salescredit_title := null ;
      c_salester_title    := null ;
   else
      get_lookup_meaning('IND_SALES_REP',
                       	 w_industry_code,
			 c_salesrep_title);
      get_lookup_meaning('IND_SALES_CREDIT',
                       	 w_industry_code,
			 c_salescredit_title);
      get_lookup_meaning('IND_SALES_TERRITORY',
                       	 w_industry_code,
			 c_salester_title);
   end if;
end if;

c_industry_code :=   w_Industry_code ;

end ;

function set_display_for_core(p_field_name in VARCHAR2)
         return boolean is

begin

if c_industry_code = 'C' then
   return(TRUE);
elsif p_field_name = 'SALESREP' then
   if c_salesrep_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
elsif p_field_name = 'SALESCREDIT' then
   if c_salescredit_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
elsif p_field_name = 'SALESTER' then
   if c_salester_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
end if;

RETURN NULL; end;

function set_display_for_gov(p_field_name in VARCHAR2)
         return boolean is

begin


if c_industry_code = 'C' then
   return(FALSE);
elsif p_field_name = 'SALESREP' then
   if c_salesrep_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
elsif p_field_name = 'SALESCREDIT' then
   if c_salescredit_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
elsif p_field_name = 'SALESTER' then
   if c_salester_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
end if;

RETURN NULL; end ;

--Functions to refer Oracle report placeholders--

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
 Function RP_ID_p return varchar2 is
	Begin
	 return RP_ID;
	 END;
 Function RP_NONE_p return varchar2 is
	Begin
	 return RP_NONE;
	 END;
 Function RP_SEGMENT_p return varchar2 is
	Begin
	 return RP_SEGMENT;
	 END;
 Function RP_NUMBER_p return varchar2 is
	Begin
	 return RP_NUMBER;
	 END;
 Function RP_VALUE_p return varchar2 is
	Begin
	 return RP_VALUE;
	 END;
 Function RP_YES_p return varchar2 is
	Begin
	 return RP_YES;
	 END;
 Function RP_AMT_p return varchar2 is
	Begin
	 return RP_AMT;
	 END;
 Function RP_NO_p return varchar2 is
	Begin
	 return RP_NO;
	 END;
 Function RP_PER_p return varchar2 is
	Begin
	 return RP_PER;
	 END;
 Function RP_CODE_p return varchar2 is
	Begin
	 return RP_CODE;
	 END;
 Function c_industry_code_p return varchar2 is
	Begin
	 return c_industry_code;
	 END;
 Function c_salesrep_title_p return varchar2 is
	Begin
	 return c_salesrep_title;
	 END;
 Function c_salescredit_title_p return varchar2 is
	Begin
	 return c_salescredit_title;
	 END;
 Function c_salester_title_p return varchar2 is
	Begin
	 return c_salester_title;
	 END;
END AR_RAXSOL_XMLP_PKG ;



/
