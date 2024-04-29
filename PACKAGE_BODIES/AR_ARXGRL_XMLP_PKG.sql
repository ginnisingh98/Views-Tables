--------------------------------------------------------
--  DDL for Package Body AR_ARXGRL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXGRL_XMLP_PKG" AS
/* $Header: ARXGRLB.pls 120.0 2007/12/27 13:52:08 abraghun noship $ */

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
    THEN RP_REPORT_NAME := 'Ordering And Grouping Rules Listing';
         RETURN('Ordering And Grouping Rules Listing');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

begin

	/*SRW.USER_EXIT('FND SRWINIT');*/null;






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

function org_idFormula return VARCHAR2 is
l_org_id varchar2(10);
begin

     /*srw.message ('100', 'Org_IdFormula');*/null;




     oe_profile.get('SO_ORGANIZATION_ID', l_org_id );

     /*srw.message ('100', 'Org_IdFormula:  Organization Id:  ' || l_org_id );*/null;


    RETURN(l_org_id);


RETURN NULL; EXCEPTION
     WHEN NO_DATA_FOUND THEN
          /*srw.message ('101', 'Org_IdFormula:  Get Organization Id:  No Data Found.');*/null;

          RAISE;
     WHEN OTHERS THEN
          /*srw.message ('101', 'Org_IdFormula:  Get Organization Id:  Failed.');*/null;

          RAISE;

end;

function tax_acct_seg_numformula(location_structure_id in number) return number is
begin

declare
  segment_num number;

begin


select max( segment.segment_num)
into   segment_num
from fnd_flex_value_sets vs,
     fnd_id_flex_segments segment,
     fnd_flex_validation_tables tab,
     fnd_segment_attribute_values qual
where segment.application_id = 222
and   segment.id_flex_code = 'RLOC'
and   segment.id_flex_num = location_structure_id
and   tab.flex_value_set_id = vs.flex_value_set_id
and   tab.application_table_name = 'AR_LOCATION_VALUES'
and   segment.application_id = qual.application_id
and   segment.id_flex_code = qual.id_flex_code
and   segment.id_flex_num  = qual.id_flex_num
and   segment.application_column_name = qual.application_column_name
and   segment.enabled_flag = 'Y'
and   qual.attribute_value = 'Y'
and   qual.segment_attribute_type = 'TAX_ACCOUNT';

return(segment_num);

end;



RETURN NULL; end;

function AfterPForm return boolean is
begin

if (p_ordering_name_low is not null)
then  lp_ordering_low := 'and lor.name >= :p_ordering_name_low';
end if;

if (p_ordering_name_high is not null)
then  lp_ordering_high := 'and lor.name <= :p_ordering_name_high';
end if;

if (p_grouping_name_low is not null)
then  lp_grouping_low := 'and gr1.name >= :p_grouping_name_low';
end if;

if (p_grouping_name_high is not null)
then  lp_grouping_high := 'and gr1.name <= :p_grouping_name_high';
end if;

select substrb(meaning ,1,50)
into  p_run_ordering_meaning
from  ar_lookups
where lookup_type = 'YES/NO'
and   lookup_code = p_run_ordering;


select substrb(meaning ,1,50)
into  p_run_grouping_meaning
from  ar_lookups
where lookup_type = 'YES/NO'
and   lookup_code = p_run_grouping;

return (TRUE);

end;

--Functions to refer Oracle report placeholders--

 Function Acct_Bal_Aprompt_p return varchar2 is
	Begin
	 return Acct_Bal_Aprompt;
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
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
END AR_ARXGRL_XMLP_PKG ;



/
