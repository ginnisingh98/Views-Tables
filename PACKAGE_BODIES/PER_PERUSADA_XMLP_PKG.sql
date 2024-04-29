--------------------------------------------------------
--  DDL for Package Body PER_PERUSADA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSADA_XMLP_PKG" AS
/* $Header: PERUSADAB.pls 120.0 2007/12/28 06:54:19 srikrish noship $ */

function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
--hr_standard.event('BEFORE REPORT');
p_org_structure_version_id_1:= p_org_structure_version_id;
insert into fnd_sessions (session_id, effective_date)
       select userenv('sessionid'), trunc(sysdate)
       from dual
       where not exists
             (select 1
              from fnd_sessions fs
              where fs.session_id = userenv('sessionid'));
c_business_group_name := hr_reports.get_business_group(p_business_group_id);
c_organization := hr_us_reports.get_org_name(p_organization_id, p_business_group_id);
IF P_ORG_STRUCTURE_VERSION_ID_1 is null then
  P_ORG_STRUCTURE_VERSION_ID_1 := -1;
  c_organization_hierarchy := null;
ELSE c_organization_hierarchy := hr_us_reports.get_org_hierarchy_name(P_ORG_STRUCTURE_VERSION_ID_1);
END IF;
select to_number(rule_mode)
into   c_disability_id_flex_num
from   pay_legislation_rules
where  legislation_code = 'US'
and    rule_type = 'ADA_DIS';
select to_number(rule_mode)
into   c_disability_acc_id_flex_num
from   pay_legislation_rules
where  legislation_code = 'US'
and    rule_type = 'ADA_DIS_ACC';
IF p_person is not null THEN
     c_lex_assign_where := c_lex_assign_where ||
	' and peo.person_id = '|| to_char(p_person);
     c_full_name := hr_reports.get_person_name(p_session_date, p_person);
END IF;
IF p_employee_number is not null THEN
     c_lex_assign_where := c_lex_assign_where ||
        ' and peo.person_id = '|| to_char(p_employee_number);
     select employee_number
     into   c_employee_number
     from   per_all_people_f
     where  person_id = p_employee_number;
END IF;
IF nvl(p_registered_disabled, 'N') in ('Y','P','F') THEN
     c_lex_assign_where := c_lex_assign_where ||
        ' and peo.registered_disabled_flag in (''Y'',''P'',''F'')';
END IF;
IF p_job_id is not null THEN
     c_lex_assign_where := c_lex_assign_where ||
        ' and job.job_id = '|| to_char(p_job_id);
     select name
     into   c_job_name
     from   per_jobs_vl
     where  job_id = p_job_id;
END IF;
IF p_position_name is not null THEN
     c_lex_assign_where := c_lex_assign_where ||
        ' and (hr_general.decode_position_latest_name(ass.position_id)) = '''||p_position_name||'''';
END IF;
IF p_location is not null THEN
     c_lex_assign_where := c_lex_assign_where ||
        ' and loc.location_id = '|| to_char(p_location);
     select location_code
     into   c_location_code
     from   hr_locations
     where  location_id = p_location;
END IF;
/*srw.message(5, 'Additional restrictions IF nvl(:p_sort, 'Employee') = 'Employee' THEN
     :c_lex_assign_order := '  initcap(peo.full_name) ';*/null;
IF nvl(p_sort, 'Employee') = 'Employee' THEN
     --:c_lex_assign_order := '  initcap(peo.full_name) ';
     c_lex_assign_order := '  initcap(peo.full_name) ';
ELSE
/*     :c_lex_assign_order := ' job.name,loc.location_code,gdt.name,
           (hr_general.decode_position_latest_name(ass.position_id)),initcap(peo.full_name)';*/
c_lex_assign_order := ' job.name,loc.location_code,gdt.name,
           (hr_general.decode_position_latest_name(ass.position_id)),initcap(peo.full_name)';
END IF;

--Added during DT Fix
if c_lex_assign_where is null then
        c_lex_assign_where := ' ';
end if;
--End of DT Fix
  return (TRUE);
end;

function g_1groupfilter(establishment_id1 in number) return boolean is
begin

/*srw.message('001', 'Tax Unit ID  '||to_char(tax_unit_id));*/null;

/*srw.message('002', 'Estab. ID    '||to_char(establishment_id1));*/null;

if establishment_id1 is null and P_ORG_STRUCTURE_VERSION_ID_1 = -1 then
  /*srw.message(3, 'The GRE is not an establishment.  Please enter a hierarchy.');*/null;

end if;  return (TRUE);
end;

function G_DisabilitiesGroupFilter return boolean is
begin

/*srw.message (4, 'person id '||to_char(person_id));*/null;
  return (TRUE);
end;

function G_2GroupFilter return boolean is
begin

/*srw.message(6, 'est '||d_cmpy_name);*/null;

/*srw.message(6, 'est id '||to_char(establishment_id));*/null;
  return (TRUE);
end;

function AfterPForm return boolean is
begin

  if P_ORG_STRUCTURE_VERSION_ID is not null then
    return (TRUE);
  else
        /*srw.message(7,'Please enter a hierarchy');*/null;

    return(FALSE);
  end if;
RETURN NULL; end;

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
 Function C_REPORT_TYPE_p return varchar2 is
	Begin
	 return C_REPORT_TYPE;
	 END;
 Function C_ORGANIZATION_HIERARCHY_p return varchar2 is
	Begin
	 return C_ORGANIZATION_HIERARCHY;
	 END;
 Function C_ORGANIZATION_p return varchar2 is
	Begin
	 return C_ORGANIZATION;
	 END;
 Function C_DISABILITY_ID_FLEX_NUM_p return number is
	Begin
	 return C_DISABILITY_ID_FLEX_NUM;
	 END;
 Function C_DISABILITY_ACC_ID_FLEX_NUM_p return number is
	Begin
	 return C_DISABILITY_ACC_ID_FLEX_NUM;
	 END;
 Function C_lex_assign_where_p return varchar2 is
	Begin
	 return C_lex_assign_where;
	 END;
 Function C_lex_assign_order_p return varchar2 is
	Begin
	 return C_lex_assign_order;
	 END;
 Function C_full_name_p return varchar2 is
	Begin
	 return C_full_name;
	 END;
 Function C_employee_number_p return varchar2 is
	Begin
	 return C_employee_number;
	 END;
 Function C_job_name_p return varchar2 is
	Begin
	 return C_job_name;
	 END;
 Function C_location_code_p return varchar2 is
	Begin
	 return C_location_code;
	 END;
END PER_PERUSADA_XMLP_PKG ;

/
