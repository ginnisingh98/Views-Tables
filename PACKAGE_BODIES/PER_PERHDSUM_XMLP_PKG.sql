--------------------------------------------------------
--  DDL for Package Body PER_PERHDSUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERHDSUM_XMLP_PKG" AS
/* $Header: PERHDSUMB.pls 120.1 2007/12/06 11:27:19 amakrish noship $ */
function BeforeReport return boolean is
begin

P_REPORT_DATE_FROM_LP := TO_CHAR(P_REPORT_DATE_FROM,'DD-MON-YYYY') ;
P_REPORT_DATE_TO_LP := TO_CHAR(P_REPORT_DATE_TO,'DD-MON-YYYY') ;
--hr_standard.event('BEFORE REPORT');

/*srw.message('000','File = PER_PERHDSUM_XMLP_PKG 115.0');*/null;


insert into fnd_sessions
(session_id,effective_date)
values(userenv('SESSIONID'),sysdate);

/*srw.message('001','Start of Before Report Trigger');*/null;


cp_business_group_name := hr_reports.get_business_group(p_business_group_id);

/*srw.message('002','Business group Name = '||cp_business_group_name);*/null;


cp_top_org_name := hr_person_flex_logic.GetOrgAliasName(
                          p_top_organization_id,sysdate);

/*srw.message('003','Top Organization Name = '||cp_top_org_name);*/null;

/*srw.message('005','viji');*/null;



select  name
into    cp_organization_hierarchy_name
from    per_organization_structures
where   organization_structure_id = P_ORGANIZATION_STRUCTURE_ID;

/*srw.message('004','Organization Hierarchy = '||cp_organization_hierarchy_name);*/null;


hr_head_count_summary.populate_summary_table(
            P_BUSINESS_GROUP_ID,
            P_TOP_ORGANIZATION_ID,
            P_ORGANIZATION_STRUCTURE_ID,
            P_BUDGET,
            P_ROLL_UP,
            P_INCLUDE_TOP_ORG,
            P_REPORT_DATE_FROM,
            P_REPORT_DATE_TO,
            P_REPORT_DATE,
	    P_INCLUDE_ASG_TYPE,
            P_JOB_CATEGORY => 'RG');

/*srw.message('005','End of Before Report Trigger');*/null;


  return (TRUE);
end;

function AfterReport return boolean is
begin

 -- hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP_NAME;
	 END;
 Function CP_ORGANIZATION_NAME_p return varchar2 is
	Begin
	 return CP_ORGANIZATION_NAME;
	 END;
 Function CP_TOP_ORG_NAME_p return varchar2 is
	Begin
	 return CP_TOP_ORG_NAME;
	 END;
 Function CP_ORGANIZATION_HIERARCHY_NAM return varchar2 is
	Begin
	 return CP_ORGANIZATION_HIERARCHY_NAME;
	 END;
END PER_PERHDSUM_XMLP_PKG ;

/
