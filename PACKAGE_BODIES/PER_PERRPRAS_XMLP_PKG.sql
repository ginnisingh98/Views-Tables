--------------------------------------------------------
--  DDL for Package Body PER_PERRPRAS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPRAS_XMLP_PKG" AS
/* $Header: PERRPRASB.pls 120.1 2007/12/06 11:30:58 amakrish noship $ */
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

        l_business_group_id NUMBER;
        l_legislation_code VARCHAR2(2);
        l_primary_flag_desc VARCHAR2(10);
        l_organization_stucture_desc VARCHAR2(80);
        l_org_version_desc NUMBER;
        l_version_start_date DATE;
        l_version_end_date DATE;
        l_organization_desc VARCHAR2(240);
        l_organization_type VARCHAR2(30);
begin


  --hr_standard.event('BEFORE REPORT');


  l_business_group_id := p_business_group_id;
  IF (p_org_structure_version_id IS NOT NULL) THEN
    OPEN csr_org_structure_version(p_org_structure_version_id);
    FETCH csr_org_structure_version INTO l_business_group_id;
    CLOSE csr_org_structure_version;
  END IF;
    IF (l_business_group_id IS NOT NULL) THEN
    c_business_group_name := hr_reports.get_business_group(l_business_group_id);
  ELSE
    c_business_group_name := c_global_hierarchy;
  END IF;


 select legislation_code
 into l_legislation_code
 from per_business_groups
 where business_group_id = p_business_group_id;
 p_legislation_code := l_legislation_code;
if p_org_structure_version_id is not null then
 hr_reports.get_organization_hierarchy
  (null
  ,p_org_structure_version_id
  ,l_organization_stucture_desc
  ,l_org_version_desc
  ,l_version_start_date
  ,l_version_end_date);

  c_org_structure_desc := l_organization_stucture_desc;
  c_org_structure_version_desc := l_org_version_desc;
  c_version_from_desc := l_version_start_date;
  c_version_to_desc := l_version_end_date;
end if;

 if p_org_structure_version_id is null then
    c_session_date := p_session_date ;
 elsif
    p_session_date between c_version_from_desc and
                   nvl(c_version_to_desc,
                          to_date('31/12/4712','DD/MM/YYYY')) then
    c_session_date := p_session_date;
 else
    c_session_date := c_version_from_desc;
 end if;
if p_parent_organization_id is not null then
 hr_reports.get_organization
  (p_parent_organization_id
  ,l_organization_desc
  ,l_organization_type);

 c_organization_desc := l_organization_desc;
end if;

if p_job_id is not null then
 c_job_desc :=
   hr_reports.get_job(p_job_id);
    p_job_matching :=
       'and a.job_id = ' || to_char(p_job_id);
end if;
if p_position_id is not null then
 c_position_desc :=
   hr_reports.get_position(p_position_id);
    p_position_matching :=
     'and a.position_id = '|| to_char(p_position_id);
end if;
if p_grade_id is not null then
 c_grade_desc :=
    hr_reports.get_grade(p_grade_id);
    p_grade_matching :=
    'and a.grade_id = ' || to_char(p_grade_id);
end if;
if p_payroll_id is not null then
 c_payroll_desc :=
   hr_reports.get_payroll_name(p_session_date,p_payroll_id);
    p_payroll_matching :=
    'and a.payroll_id+0 = '|| to_char(p_payroll_id);
end if;
 if p_asg_status_type_id1 is not null then
    c_asg_status_desc1 :=
      hr_reports.get_status(p_business_group_id
                           ,p_asg_status_type_id1
                           ,p_legislation_code);
        p_status_matching_1 :=
     p_status_matching || ',' || to_char(p_asg_status_type_id1) ;
        c_status_list :=
     c_status_list || ',' || c_asg_status_desc1;
end if;
 if p_asg_status_type_id2 is not null then
    c_asg_status_desc2 :=
      hr_reports.get_status(p_business_group_id
                           ,p_asg_status_type_id2
                           ,p_legislation_code);
        p_status_matching_1 :=
     p_status_matching || ',' || to_char(p_asg_status_type_id2);
        c_status_list :=
     c_status_list || ',' || c_asg_status_desc2;
 end if;
 if p_asg_status_type_id3 is not null then
    c_asg_status_desc3 :=
      hr_reports.get_status(p_business_group_id
                           ,p_asg_status_type_id3
                           ,p_legislation_code);
        p_status_matching_1 :=
     p_status_matching || ',' || to_char(p_asg_status_type_id3);
        c_status_list :=
     c_status_list || ',' || c_asg_status_desc3;
 end if;
 if p_asg_status_type_id4 is not null then
    c_asg_status_desc4 :=
      hr_reports.get_status(p_business_group_id
                           ,p_asg_status_type_id4
                           ,p_legislation_code);
        p_status_matching_1 :=
     p_status_matching || ',' || to_char(p_asg_status_type_id4);
        c_status_list :=
     c_status_list || ',' || c_asg_status_desc4;
 end if;
 if p_status_matching is not null then
    p_status_matching_1 :=
       'and a.assignment_status_type_id in (' ||
             substr(p_status_matching,2,
                            NVL(length(p_status_matching), 0) - 1) || ')';
 end if;
 if c_status_list is not null then
    c_status_list :=
       substr(c_status_list,2,NVL(length(c_status_list), 0) - 1);
 end if;
 if p_primary_flag is not null then
    c_primary_flag_desc :=
      hr_reports.get_lookup_meaning('YES_NO',p_primary_flag);
 end if;

  if p_person_type is not null then
     c_person_type_desc :=
        hr_reports.get_lookup_meaning('EMP_OR_APL',p_person_type);
  end if;

 if p_people_group_id is not null then
 HR_REPORTS.gen_partial_matching_lexical
                         (p_people_group_id,
                          p_people_group_flex_id,
                          p_matching_criteria,'GRP');
 end if;

 if P_ORG_STRUCTURE_VERSION_ID is not null
     and P_PARENT_ORGANIZATION_ID is not null
      then
     P_ORG_MATCHING :=
      'and a.organization_id in '||
      '(select organization_id_child '||
      'from per_org_structure_elements '||
      'connect by organization_id_parent = '||
      'prior organization_id_child '||
      'and org_structure_version_id = prior org_structure_version_id '||
      'start with organization_id_parent = '||
         to_char(P_PARENT_ORGANIZATION_ID) ||
      ' and org_structure_version_id = '||
       to_char(P_ORG_STRUCTURE_VERSION_ID) ||
      ' union select ' ||
       to_char(P_PARENT_ORGANIZATION_ID) ||
      ' from sys.dual)';
  elsif
    P_PARENT_ORGANIZATION_ID is not null then
       P_ORG_MATCHING :=
        'and a.organization_id = ' ||
               to_char(P_PARENT_ORGANIZATION_ID);


  else
    P_ORG_MATCHING :=
      'and a.business_group_id = ' ||
        to_char(P_BUSINESS_GROUP_ID);


  end if;
  P_STATUS_MATCHING_1 := 'AND 1=1 ';

end;
  return (TRUE);
end;

function c_status_start_dateformula(p_assignment_id in number, p_assignment_status_type_id in number) return date is
begin

declare l_status_start_date DATE;
begin
  begin
    select max(effective_end_date) + 1
    into l_status_start_date
    from per_assignments_f
    where assignment_id = p_assignment_id
    and   assignment_status_type_id <> p_assignment_status_type_id
    and   effective_end_date < C_SESSION_DATE;
    exception
     when no_data_found then null;
  end;
  if l_status_start_date is null then
    begin
    select min(effective_start_date)
    into l_status_start_date
    from per_assignments_f
    where assignment_id = p_assignment_id
    and assignment_status_type_id = p_assignment_status_type_id
    and effective_start_date <= C_SESSION_DATE;
    exception
    when no_data_found then null;
  end;
    end if;
return l_status_start_date;
end;
RETURN NULL; end;

function c_status_end_dateformula(p_assignment_id in number, p_assignment_status_type_id in number) return date is
begin

declare l_status_end_date DATE;
begin
  begin
    select min(effective_start_date) - 1
    into l_status_end_date
    from per_assignments_f
    where assignment_id = p_assignment_id
    and   assignment_status_type_id <> p_assignment_status_type_id
    and   effective_start_date > C_SESSION_DATE;
    exception
     when no_data_found then null;
  end;
  if l_status_end_date is null then
    begin
    select max(effective_end_date)
    into l_status_end_date
    from per_assignments_f
    where assignment_id = p_assignment_id
    and assignment_status_type_id = p_assignment_status_type_id
    and effective_end_date >= C_SESSION_DATE;
    exception
    when no_data_found then null;
  end;
    end if;
  if l_status_end_date = to_date('31/12/4712','DD/MM/YYYY')
        then l_status_end_date := '';
  end if;
  return l_status_end_date;
end;
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
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_PERSON_TYPE_DESC_p return varchar2 is
	Begin
	 return C_PERSON_TYPE_DESC;
	 END;
 Function C_JOB_DESC_p return varchar2 is
	Begin
	 return C_JOB_DESC;
	 END;
 Function C_POSITION_DESC_p return varchar2 is
	Begin
	 return C_POSITION_DESC;
	 END;
 Function C_GRADE_DESC_p return varchar2 is
	Begin
	 return C_GRADE_DESC;
	 END;
 Function C_PAYROLL_DESC_p return varchar2 is
	Begin
	 return C_PAYROLL_DESC;
	 END;
 Function C_PRIMARY_FLAG_DESC_p return varchar2 is
	Begin
	 return C_PRIMARY_FLAG_DESC;
	 END;
 Function C_ASG_STATUS_DESC1_p return varchar2 is
	Begin
	 return C_ASG_STATUS_DESC1;
	 END;
 Function C_ASG_STATUS_DESC2_p return varchar2 is
	Begin
	 return C_ASG_STATUS_DESC2;
	 END;
 Function C_ASG_STATUS_DESC3_p return varchar2 is
	Begin
	 return C_ASG_STATUS_DESC3;
	 END;
 Function C_ASG_STATUS_DESC4_p return varchar2 is
	Begin
	 return C_ASG_STATUS_DESC4;
	 END;
 Function C_ORG_STRUCTURE_DESC_p return varchar2 is
	Begin
	 return C_ORG_STRUCTURE_DESC;
	 END;
 Function C_ORG_STRUCTURE_VERSION_DESC_p return number is
	Begin
	 return C_ORG_STRUCTURE_VERSION_DESC;
	 END;
 Function C_VERSION_FROM_DESC_p return date is
	Begin
	 return C_VERSION_FROM_DESC;
	 END;
 Function C_VERSION_TO_DESC_p return date is
	Begin
	 return C_VERSION_TO_DESC;
	 END;
 Function C_ORGANIZATION_DESC_p return varchar2 is
	Begin
	 return C_ORGANIZATION_DESC;
	 END;
 Function C_STATUS_LIST_p return varchar2 is
	Begin
	 return C_STATUS_LIST;
	 END;
 Function C_SESSION_DATE_p return date is
	Begin
	 return C_SESSION_DATE;
	 END;
 Function C_GLOBAL_HIERARCHY_p return varchar2 is
	Begin
	 return C_GLOBAL_HIERARCHY;
	 END;
END PER_PERRPRAS_XMLP_PKG ;

/
