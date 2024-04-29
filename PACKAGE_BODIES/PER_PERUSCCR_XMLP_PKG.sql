--------------------------------------------------------
--  DDL for Package Body PER_PERUSCCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSCCR_XMLP_PKG" AS
/* $Header: PERUSCCRB.pls 120.2 2008/04/02 08:18:36 amakrish noship $ */

function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
P_QL_DATE_FROM1:=TO_CHAR(P_QL_DATE_FROM,'DD-MON-YYYY');
P_QL_DATE_TO1:=TO_CHAR(P_QL_DATE_TO,'DD-MON-YYYY');
P_COV_START_FROM1:=TO_CHAR(P_COV_START_FROM,'DD-MON-YYYY');
P_COV_START_TO1:=TO_CHAR(P_COV_START_TO,'DD-MON-YYYY');
P_COV_END_FROM1:=TO_CHAR(P_COV_END_FROM,'DD-MON-YYYY');
P_COV_END_TO1:=TO_CHAR(P_COVERAGE_END_TO,'DD-MON-YYYY');
declare
        v_organization_name varchar2(240);
        v_organization_type varchar2(80);
        v_org_structure_name varchar2(30);
        v_org_version number;
        v_version_start_date date;
        v_version_end_date date;
begin

--hr_standard.event('BEFORE REPORT');

c_end_of_time := hr_general.end_of_time;
 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);
   v_organization_name := c_business_group_name;

IF p_parent_organization_id IS NOT NULL
THEN
hr_reports.get_organization(p_parent_organization_id,v_organization_name,v_organization_type);
  c_parent_organization_name := v_organization_name;
ELSE
  c_parent_organization_name := '';
END IF;

IF p_org_structure_version_id is NOT NULL then
hr_reports.get_organization_hierarchy(NULL,
p_org_structure_version_id
,v_org_structure_name
,v_org_version
,v_version_start_date
,v_version_end_date);
 c_org_structure_name := v_org_structure_name;
else c_org_structure_name := '';
END IF;

IF ( p_ben_plan_type_id IS NOT NULL )
THEN
 c_benefit_plan_name := hr_reports.get_element_name( p_session_date, p_ben_plan_type_id );
ELSE
 c_benefit_plan_name := '';
END IF;

IF ( p_qualifying_event IS NOT NULL )
THEN
 c_qualifying_event := hr_us_reports.get_cobra_qualifying_event( p_qualifying_event );
ELSE
 c_qualifying_event := '';
END IF;

IF ( p_cobra_status IS NOT NULL )
THEN
 c_cobra_status := hr_us_reports.get_cobra_status( p_cobra_status );
ELSE
 c_cobra_status := '';
END IF;


end;  return (TRUE);
end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_qualifying_event_p return varchar2 is
	Begin
	 return C_qualifying_event;
	 END;
 Function C_COBRA_STATUS_p return varchar2 is
	Begin
	 return C_COBRA_STATUS;
	 END;
 Function C_PARENT_ORGANIZATION_NAME_p return varchar2 is
	Begin
	 return C_PARENT_ORGANIZATION_NAME;
	 END;
 Function C_ORG_STRUCTURE_NAME_p return varchar2 is
	Begin
	 return C_ORG_STRUCTURE_NAME;
	 END;
 Function C_BENEFIT_PLAN_NAME_p return varchar2 is
	Begin
	 return C_BENEFIT_PLAN_NAME;
	 END;
 Function C_END_OF_TIME_p return date is
	Begin
	 return C_END_OF_TIME;
	 END;
END PER_PERUSCCR_XMLP_PKG ;

/
