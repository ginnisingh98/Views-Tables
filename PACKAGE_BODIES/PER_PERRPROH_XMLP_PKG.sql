--------------------------------------------------------
--  DDL for Package Body PER_PERRPROH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPROH_XMLP_PKG" AS
/* $Header: PERRPROHB.pls 120.1 2007/12/06 11:33:03 amakrish noship $ */
function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
declare

  CURSOR csr_org_structure_version
    (p_org_structure_version_id IN NUMBER)
  IS
    SELECT business_group_id
      FROM per_org_structure_versions
     WHERE org_structure_version_id = p_org_structure_version_id;

 v_org_structure_name varchar2(30);
 v_org_version        number;
 v_version_start_date date;
 v_version_end_date   date;
 v_parent_org_name    varchar2(240);
 v_parent_org_type    varchar2(90);
begin


--hr_standard.event('BEFORE REPORT');


    OPEN csr_org_structure_version(p_org_structure_version_id);
  FETCH csr_org_structure_version INTO p_business_group_id;
  CLOSE csr_org_structure_version;
    IF (p_business_group_id IS NOT NULL) THEN
    c_business_group_name := hr_reports.get_business_group(p_business_group_id);
  ELSE
    c_business_group_name := c_global_hierarchy;
  END IF;


 hr_reports.get_organization_hierarchy(null,
                                       p_org_structure_version_id,
                                       v_org_structure_name,
                                       v_org_version,
                                       v_version_start_date,
                                       v_version_end_date);

 c_org_hierarchy_name := v_org_structure_name;
 c_version := v_org_version;
 c_version_start_date := v_version_start_date;
 c_version_end_date := v_version_end_date;

 hr_reports.get_organization(p_parent_organization_id,
                             v_parent_org_name,
                             v_parent_org_type);

 c_parent_org_name := v_parent_org_name;

 if p_session_date >= c_version_start_date and
    p_session_date <= nvl(c_version_end_date,
                       to_date('31/12/4712','DD/MM/YYYY')) then
   c_session_date := p_session_date;
 else
   c_session_date := c_version_start_date;
 end if;

 c_managers_shown :=
   hr_reports.get_lookup_meaning('YES_NO',
                                 p_manager_flag);

end;  return (TRUE);
end;

function c_nameformula(organization_id_parent in number) return varchar2 is
begin

declare
 v_org_name varchar2(240);
 v_org_type varchar2(90);
begin

 hr_reports.get_organization(organization_id_parent,
                             v_org_name,
                             v_org_type);
 c_type := v_org_type;

 return v_org_name;

end;
RETURN NULL; end;

function c_count_org_subords2formula(organization_id_child in number) return number is
begin

return(hr_reports.count_org_subordinates(p_org_structure_version_id,organization_id_child));

end;

--function c_count_child_orgs1formula(organization_id_parent in number) return number is
function c_count_child_orgs1formula(arg_organization_id_parent in number) return number is
begin

declare
 v_count_child_orgs number;
begin

 begin
  select count(*)
  into v_count_child_orgs
  from per_org_structure_elements ose
  where ose.org_structure_version_id = p_org_structure_version_id
    --and ose.organization_id_parent = organization_id_parent;
      and ose.organization_id_parent = arg_organization_id_parent;
 exception
  when no_data_found then null;
 end;

 return v_count_child_orgs;

end;
RETURN NULL; end;

function c_count_managersformula(organization_id_parent in number) return varchar2 is
begin

declare

  v_count_managers number;

begin

  select count(*)
  into   v_count_managers
  from   per_people_f peo,
         per_assignments_f asg
  where  peo.person_id = asg.person_id
    and  asg.assignment_type in ('E','C')      and  asg.manager_flag = 'Y'
    and  asg.organization_id = organization_id_parent
    and  c_session_date between asg.effective_start_date
                             and asg.effective_end_date
    and  c_session_date between peo.effective_start_date
                             and peo.effective_end_date;

  return v_count_managers;

end;
RETURN NULL; end;

function c_count_managers1formula(organization_id_child in number) return number is
begin

declare

  v_count_managers number;

begin

  select count(*)
  into   v_count_managers
  from   per_people_f peo,
         per_assignments_f asg
  where  peo.person_id = asg.person_id
    and  asg.assignment_type in ('E','C')      and  asg.manager_flag = 'Y'
    and  asg.organization_id = organization_id_child
    and  c_session_date between asg.effective_start_date
                             and asg.effective_end_date
    and  c_session_date between peo.effective_start_date
                             and peo.effective_end_date;

  return v_count_managers;

end;
RETURN NULL; end;

function c_count_org_subordsformula(organization_id_parent in number) return number is
begin


   return (hr_reports.count_org_subordinates(p_org_structure_version_id,
                                     organization_id_parent));


end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_type_p return varchar2 is
	Begin
	 return C_type;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_ORG_HIERARCHY_NAME_p return varchar2 is
	Begin
	 return C_ORG_HIERARCHY_NAME;
	 END;
 Function C_VERSION_p return number is
	Begin
	 return C_VERSION;
	 END;
 Function C_VERSION_START_DATE_p return date is
	Begin
	 return C_VERSION_START_DATE;
	 END;
 Function C_VERSION_END_DATE_p return date is
	Begin
	 return C_VERSION_END_DATE;
	 END;
 Function C_PARENT_ORG_NAME_p return varchar2 is
	Begin
	 return C_PARENT_ORG_NAME;
	 END;
 Function C_SESSION_DATE_p return varchar2 is
	Begin
	 return C_SESSION_DATE;
	 END;
 Function C_MANAGERS_SHOWN_p return varchar2 is
	Begin
	 return C_MANAGERS_SHOWN;
	 END;
 Function C_GLOBAL_HIERARCHY_p return varchar2 is
	Begin
	 return C_GLOBAL_HIERARCHY;
	 END;
END PER_PERRPROH_XMLP_PKG ;

/
