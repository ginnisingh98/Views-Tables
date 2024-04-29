--------------------------------------------------------
--  DDL for Package Body PER_QH_FIND_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_FIND_QUERY" as
/* $Header: peqhfndq.pkb 120.1.12010000.2 2009/07/07 09:28:15 varanjan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) :='  per_qh_find_query.';
--
g_quote    varchar2(1)  := '''';

procedure findquery(resultset IN OUT NOCOPY findtab
,p_effective_date              date
,business_group_id             per_all_people_f.business_group_id%type
,business_group_name           per_business_groups.name%type default null
,person_id                     per_all_people_f.person_id%type default null
,person_type                   per_person_types.user_person_type%type default null
,system_person_type            per_person_types.system_person_type%type  default null
,person_type_id                per_all_people_f.person_type_id%type default null
,last_name                     per_all_people_f.last_name%type default null
,start_date                    per_all_people_f.start_date%type default null
,hire_date                     per_periods_of_service.date_start%type default null
,applicant_number              per_all_people_f.applicant_number%type default null
,date_of_birth                 per_all_people_f.date_of_birth%type default null
,email_address                 per_all_people_f.email_address%type default null
,employee_number               per_all_people_f.employee_number%type default null
--CWK
,npw_number                    per_all_people_f.npw_number%type default null
,project_title                 per_all_assignments_f.project_title%type default null
,vendor_id                     per_all_assignments_f.vendor_id%type default null
,vendor_name                   po_vendors.vendor_name%type default null
,vendor_employee_number        per_all_assignments_f.vendor_employee_number%type default null
,vendor_assignment_number      per_all_assignments_f.vendor_assignment_number%type default null
,vendor_site_code              po_vendor_sites_all.vendor_site_code%TYPE default null
,vendor_site_id                po_vendor_sites_all.vendor_site_id%TYPE default null
,po_header_num                 po_headers_all.segment1%TYPE default null
,po_header_id                  po_headers_all.po_header_id%TYPE default null
,po_line_num                   po_lines_all.line_num%TYPE default null
,po_line_id                    po_lines_all.po_line_id%TYPE default null
--
,first_name                    per_all_people_f.first_name%type default null
,full_name                     per_all_people_f.full_name%type default null
,title                         per_all_people_f.title%type
,middle_names                  per_all_people_f.middle_names%type
,nationality_meaning           hr_lookups.meaning%type default null
,nationality                   per_all_people_f.nationality%type default null
,national_identifier           per_all_people_f.national_identifier%type default null
-- Bug 3037019
,registered_disabled_flag      hr_lookups.meaning%type default null
,registered_disabled           per_all_people_f.registered_disabled_flag%type default null
,sex_meaning                   hr_lookups.meaning%type default null
,sex                           per_all_people_f.sex%type default null
,benefit_group                 ben_benfts_grp.name%type default null
,benefit_group_id              per_all_people_f.benefit_group_id%type default null
,grade                         per_grades.name%type default null
,grade_id                      per_all_assignments_f.grade_id%type default null
,grade_ladder                  ben_pgm_f.name%type default null
,grade_ladder_pgm_id           per_all_assignments_f.grade_ladder_pgm_id%type default null
,position                      hr_all_positions_f.name%type default null
,position_id                   per_all_assignments_f.position_id%type default null
,job                           per_jobs.name%type default null
,job_id                        per_all_assignments_f.job_id%type default null
,assignment_status_type        per_assignment_status_types.user_status%type default null
,assignment_status_type_id     per_all_assignments_f.assignment_status_type_id%type default null
,payroll                       pay_all_payrolls_f.payroll_name%type default null
,payroll_id                    per_all_assignments_f.payroll_id%type default null
,location                      hr_locations.location_code%type default null
,location_id                   per_all_assignments_f.location_id%type default null
,supervisor                    per_all_people_f.full_name%type default null
,supervisor_id                 per_all_assignments_f.supervisor_id%type default null
,supervisor_assignment_number  per_assignments_v.supervisor_assignment_number%type default null
,supervisor_assignment_id      per_all_assignments_f.supervisor_assignment_id%type default null
,recruitment_activity          per_recruitment_activities.name%type default null
,recruitment_activity_id       per_all_assignments_f.recruitment_activity_id%type default null
,organization                  hr_all_organization_units.name%type default null
,organization_id               per_all_assignments_f.organization_id%type default null
,people_group                  pay_people_groups.group_name%type default null
,people_group_id               per_all_assignments_f.people_group_id%type default null
,vacancy                       per_vacancies.name%type default null
,vacancy_id                    per_all_assignments_f.vacancy_id%type default null
,requisition                   per_requisitions.name%type default null
,requisition_id                per_requisitions.requisition_id%type default null
,salary_basis                  per_pay_bases.name%type default null
,pay_basis_id                  per_all_assignments_f.pay_basis_id%type default null
,bargaining_unit_code_meaning  hr_lookups.meaning%type default null
,bargaining_unit_code          per_all_assignments_f.bargaining_unit_code%type default null
,employment_category_meaning   hr_lookups.meaning%type default null
,employment_category           per_all_assignments_f.employment_category%type default null
-- BUG 3002915 starts here. modified type.
,establishment                 hr_leg_establishments_v.name%type default null
,establishment_id              hr_leg_establishments_v.organization_id%type default null
-- BUG 3002915 ends here.
,projected_hire_date           per_applications.projected_hire_date%type default null
,secure                        varchar2 default null
,field1_name                   varchar2 default null
,field1_condition_code         varchar2 default null
,field1_value                  varchar2 default null
,field2_name                   varchar2 default null
,field2_condition_code         varchar2 default null
,field2_value                  varchar2 default null
,field3_name                   varchar2 default null
,field3_condition_code         varchar2 default null
,field3_value                  varchar2 default null
,field4_name                   varchar2 default null
,field4_condition_code         varchar2 default null
,field4_value                  varchar2 default null
,field5_name                   varchar2 default null
,field5_condition_code         varchar2 default null
,field5_value                  varchar2 default null
,p_fetch_details               boolean  default true
,p_customized_restriction_id   number   default null
,p_employees_allowed           boolean  default false
,p_applicants_allowed          boolean  default false
,p_cwk_allowed                 boolean  default false
,select_stmt               out nocopy varchar2) is
  type EmpCurTyp is ref cursor;
  emp_cv EmpCurTyp;
--
num_row number:=0;
out_rec findrec;
--
l_person_id per_all_people_f.person_id%TYPE;
l_assignment_id per_all_assignments_f.assignment_id%type;
l_num_asgs NUMBER;

l_select_stmt_per VARCHAR2(20000);
l_select_stmt_per2 VARCHAR2(20000);
l_select_stmt_asg VARCHAR2(20000);
--
l_full_name per_all_people_f.full_name%type;
--
l_from_clause VARCHAR2(20000);
l_where_clause VARCHAR2(20000);
l_effective_date_clause VARCHAR2(20000);
l_proc varchar2(72):=g_package||'findquery';
l_effective_date varchar2(35);
l_asg boolean default FALSE;
l_other varchar2(30);
--
--Modified for PMxbg
cursor csr_bg_name
      (p_business_group_id number) is
select x.name
from per_business_groups x
where x.business_group_id = p_business_group_id;
--
cursor csr_person_details
      (p_person_id number
      ,p_effective_date date) is

select *
from per_all_people_f
where person_id=p_person_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_lang
      (p_lang_code VARCHAR2) is
select description
from fnd_languages_vl
where language_code=p_lang_code;
--
cursor csr_benfts_grp
      (p_benfts_grp_id NUMBER) is
select name
from  ben_benfts_grp
where benfts_grp_id=p_benfts_grp_id;
--
per_rec per_all_people_f%rowtype;
cursor csr_assignment_details
       (p_assignment_id number
       ,p_effective_date date) is
select *
from per_all_assignments_f
where assignment_id=p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor count_asgs(p_person_id number) is
select count(*)
from per_all_assignments_f per_asg
where per_asg.person_id=p_person_id
and p_effective_date between per_asg.effective_start_date and per_asg.effective_end_date
and per_asg.assignment_type <> 'B' ; -- Added for fix of #3286659
--
cursor csr_full_name
      (p_person_id number
      ,p_effective_date date) is

select full_name
from per_all_people_f
where person_id=p_person_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_supervisor_assgt_number
      (p_supervisor_assignment_id number
      ,p_effective_date date) is

select assignment_number
from per_all_assignments_f
where assignment_id = p_supervisor_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_pds(p_person_id number,p_effective_date date) is
select date_start
from per_periods_of_service
where person_id=p_person_id
and p_effective_date between date_start and nvl(final_process_date,p_effective_date);
--
cursor csr_app(p_person_id number,p_effective_date date) is
select projected_hire_date
from per_applications
where person_id=p_person_id
and p_effective_date between date_received and nvl(date_end,p_effective_date);
--
cursor csr_grade
      (p_grade_id number) is
select name
from per_grades_vl
where grade_id=p_grade_id;
--
cursor csr_grade_ladder
      (p_grade_ladder_pgm_id number
      ,p_effective_date      date) is
select name
from   ben_pgm_f
where  pgm_id = p_grade_ladder_pgm_id
and    p_effective_date between effective_start_date and effective_end_date;

--
-- PMFLETCH - MLS: Always select eot record from tl table
--
cursor csr_position
      (p_position_id number
      ,p_effective_date date) is
select name
from hr_all_positions_f_tl
where position_id=p_position_id
and language = userenv('LANG');
--PMFLETCH - No effective date in tl table
--and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_job
       (p_job_id number) is
select name
from per_jobs_vl
where job_id=p_job_id;
--
--Modified for PMxbg
cursor csr_asg_status
       (p_assignment_status_type_id number) is
SELECT
  nvl(atl.user_status     ,stl.user_status),
  nvl(a.per_system_status ,s.per_system_status)
FROM
  per_ass_status_type_amends_tl atl,
  per_ass_status_type_amends a,
  per_assignment_status_types_tl stl,
  per_assignment_status_types s
WHERE
  s.assignment_status_type_id=p_assignment_status_type_id and
  a.assignment_status_type_id (+)=s.assignment_status_type_id and
  a.business_group_id (+) = s.business_group_id and
  nvl(a.active_flag, s.active_flag)='Y' and
  a.ass_status_type_amend_id=atl.ass_status_type_amend_id (+) and
  decode(atl.language,null,'1',atl.language)=decode(atl.language,null,'1',userenv('LANG')) and
  s.assignment_status_type_id=stl.assignment_status_type_id and
  stl.language=userenv('LANG');
--
cursor csr_payroll
      (p_payroll_id number
      ,p_effective_date date) is
select payroll_name
from pay_all_payrolls_f
where payroll_id=p_payroll_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_location
      (p_location_id number) is
select location_code
from hr_locations
where location_id=p_location_id;
--
cursor csr_rec_activity
      (p_recruitment_activity_id number) is
select name
from per_recruitment_activities
where recruitment_activity_id=p_recruitment_activity_id;
--
cursor csr_organization
      (p_organization_id number) is
select name
from hr_organization_units
where organization_id=p_organization_id;
--
cursor csr_pgp_rec
      (p_people_group_id number) is
select * from pay_people_groups
where people_group_id=p_people_group_id;
--
cursor csr_scl_rec
      (p_soft_coding_keyflex_id number) is
select * from hr_soft_coding_keyflex
where soft_coding_keyflex_id=p_soft_coding_keyflex_id;
--
cursor csr_vacancy
      (p_vacancy_id number) is
select vac.name
,      rec.name
from per_vacancies vac
,    per_requisitions rec
where vac.vacancy_id=p_vacancy_id
and   vac.requisition_id=rec.requisition_id;
--
cursor csr_pay_basis
      (p_pay_basis number) is
select ppb.name
,      ppb.pay_basis
from   per_pay_bases ppb
where  ppb.pay_basis_id=p_pay_basis;
--
cursor csr_ceiling_step
      (p_special_ceiling_step_id number
      ,p_effective_date date) is
  select psp.spinal_point spinal_point
  , count(*) step
  from per_spinal_points psp
  , per_spinal_points psp2
  , per_spinal_point_steps_f psps
  , per_spinal_point_steps_f psps2
  where psp.spinal_point_id=psps.spinal_point_id
  and psps.grade_spine_id=psps2.grade_spine_id
  and psp2.spinal_point_id=psps2.spinal_point_id
  and psps.step_id=p_special_ceiling_step_id
  and psp.sequence >=psp2.sequence
  and p_effective_date between psps.effective_start_date
      and psps.effective_end_date
  and p_effective_date between psps2.effective_start_date
      and psps2.effective_end_date
  group by psp.spinal_point
  , psps.step_id
  , psps.sequence
  , psps.effective_start_date
  , psps.effective_end_date
  order by 2;
--
cursor csr_reference
      (p_contract_id number
      ,p_effective_date date) is
select reference
from per_contracts_f
where contract_id=p_contract_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_collective_agr
      (p_collective_agreement_id number) is
select name
from per_collective_agreements
where collective_agreement_id=p_collective_agreement_id;
--
cursor csr_cagr_flex_num
      (p_id_flex_num number) is
select id_flex_structure_name
from fnd_id_flex_structures_vl
where id_flex_code='CAGR'
and   application_id=800
and   id_flex_num=p_id_flex_num;
--
asg_rec per_all_assignments_f%rowtype;
pgp_rec pay_people_groups%rowtype;
scl_rec hr_soft_coding_keyflex%rowtype;
--
cursor csr_vendor(p_vendor_id in number) is
select vendor_name
from po_vendors pov
where pov.vendor_id = p_vendor_id;
--
cursor csr_vendor_site(p_vendor_site_id in number) is
select vendor_site_code
from po_vendor_sites
where vendor_site_id=p_vendor_site_id;
--
cursor csr_po_header(p_po_header_id in number) is
select segment1
from po_headers_all
where po_header_id = p_po_header_id;
--
cursor csr_po_line(p_po_line_id in number) is
select line_num
from po_lines_all
where po_line_id = p_po_line_id;
--Bug 4060365. Changed the size of the variable l_where from 400 to 2000
  function build_varchar2_where
          (p_parent_column varchar2
          ,p_condition     varchar2
          ,p_value         varchar2
          ,p_child_table   varchar2 default null
          ,p_child_column  varchar2 default null
          ,p_child_meaning varchar2 default null
          ,p_inner_where   varchar2 default null)
          return varchar2 is
  l_where varchar2(2000);
  begin
    if p_child_table is null then
      l_where:=p_parent_column;
      if p_condition='IS' then
        l_where:='upper('||l_where||')='''||upper(p_value)||'''';
      elsif p_condition='IS_NOT' then
        l_where:='upper('||l_where||')<>'''||upper(p_value)||'''';
      elsif p_condition='CONTAINS' then
        l_where:='upper('||l_where||') like(''%'||upper(p_value)||'%'')';
      elsif p_condition='STARTS' then
        l_where:='upper('||l_where||') like('''||upper(p_value)||'%'')';
      elsif p_condition='ENDS' then
        l_where:='upper('||l_where||') like(''%'||upper(p_value)||''')';
      elsif p_condition='NOT_CONTAINS' then
        l_where:='upper('||l_where||') not like(''%'||upper(p_value)||'%'')';
      elsif p_condition='NULL' then
        l_where:=l_where||' is null';
      elsif p_condition='NOT_NULL' then
        l_where:=l_where||' is not null';
      end if;
    else
       l_where:=p_parent_column;
       if p_condition in ('IS','CONTAINS','STARTS','ENDS','NULL','NOT_NULL') then
         l_where:=l_where||' in ';
       elsif p_condition in ('IS_NOT','NOT_CONTAINS') then
         l_where:=l_where||' not in ';
       end if;
       l_where:=l_where||'(select '||p_child_column||' from '||
       p_child_table||' where upper('||p_child_meaning||')';
       if p_condition in ('IS','IS_NOT') then
         l_where:=l_where||'='''||upper(p_value)||'''';
       elsif p_condition in ('CONTAINS','STARTS','ENDS','NOT_CONTAINS') then
         l_where:=l_where||' like (''';
       end if;
       if p_condition in ('CONTAINS','NOT_CONTAINS') then
         l_where:=l_where||'%'||upper(p_value)||'%'')';
       elsif p_condition='STARTS' then
         l_where:=l_where||upper(p_value)||'%'')';
       elsif p_condition='ENDS' then
         l_where:=l_where||'%'||upper(p_value)||''')';
       elsif p_condition='NULL' then
--Bug 4060365. Removed the extra paranthesis after is Null and is not Null
         l_where:=l_where||' is null';
       elsif p_condition='NOT_NULL' then
         l_where:=l_where||' is not null';
--Bug 4060365. End of Fix
       end if;
       if p_inner_where is not null then
         l_where:=l_where||p_inner_where;
       end if;
       if p_condition in ('IS_NOT','NOT_CONTAINS') then
         l_where:='(('||l_where||') or ('||p_parent_column||' is null))';
       end if;
       l_where:=l_where||')';
    end if;
    l_where:=' and '||l_where;
    return l_where;
  end build_varchar2_where;
  --
  function build_number_where
          (p_parent_column varchar2
          ,p_condition     varchar2
          ,p_value         varchar2)
          return varchar2 is
  l_where varchar2(200);
  begin
      l_where:=p_parent_column;
      if p_condition='IS' then
        l_where:=l_where||'='||p_value;
      elsif p_condition='IS_NOT' then
        l_where:=l_where||'<>'||p_value;
      elsif p_condition='IS_LESS' then
        l_where:=l_where||'<='||p_value;
      elsif p_condition='IS_GREATER' then
        l_where:=l_where||'>='||p_value;
      elsif p_condition='NULL' then
        l_where:=l_where||' is null';
      elsif p_condition='NOT_NULL' then
        l_where:=l_where||' is not null';
      end if;
    l_where:=' and '||l_where;
    return l_where;
  end build_number_where;
  --
  function build_date_where
          (p_parent_column varchar2
          ,p_condition     varchar2
          ,p_value         varchar2
          ,p_child_table   varchar2 default null
          ,p_child_column  varchar2 default null
          ,p_child_meaning varchar2 default null
          ,p_inner_where   varchar2 default null)
          return varchar2 is
  l_where varchar2(200);
  l_value varchar2(2000) := 'fnd_date.canonical_to_date('''||p_value||''')';
  begin
    if p_child_table is null then
      l_where:=p_parent_column;
      if p_condition='IS' then
        l_where:=l_where||'='||l_value;
      elsif p_condition='IS_NOT' then
        l_where:=l_where||'<>'||l_value;
      elsif p_condition='IS_LESS' then
        l_where:=l_where||'<='||l_value;
      elsif p_condition='IS_GREATER' then
        l_where:=l_where||'>='||l_value;
      elsif p_condition='NULL' then
        l_where:=l_where||' is null';
      elsif p_condition='NOT_NULL' then
        l_where:=l_where||' is not null';
      end if;
    else
       l_where:=p_parent_column;
       if p_condition IN ('IS','IS_LESS','IS_GREATER','NULL','NOT_NULL') then
         l_where:=l_where||' in ';
       elsif p_condition='IS_NOT' then
         l_where:=l_where||' not in ';
       end if;
       l_where:=l_where||'(select '||p_child_column||' from '||
       p_child_table||' where '||p_child_meaning;
       if p_condition in ('IS','IS_NOT') then
         l_where:=l_where||'='||l_value||')';
       elsif p_condition='IS_LESS' then
         l_where:=l_where||' <='||l_value||')';
       elsif p_condition='IS_GREATER' then
         l_where:=l_where||' >='||l_value||')';
       elsif p_condition='NULL' then
         l_where:=l_where||' is null)';
       elsif p_condition='NOT_NULL' then
         l_where:=l_where||' is not null)';
       end if;
       if p_inner_where is not null then
         l_where:=l_where||p_inner_where;
       end if;
       if p_condition='IS_NOT' then
         l_where:='(('||l_where||') or ('||p_parent_column||' is null))';
       end if;
    end if;
    l_where:=' and '||l_where;
    return l_where;
  end build_date_where;
  --
  function build_grade_where
          (p_condition     varchar2
          ,p_value         varchar2)
          return varchar2 is
  l_where varchar2(200);
  begin
    if p_condition in ('IS','IS_NOT','CONTAINS','STARTS','ENDS','NOT_CONTAINS','NULL','NOT_NULL') then
      l_where:=build_varchar2_where('per_asg.grade_id',p_condition,p_value
     ,'per_grades_vl grd_a','grd_a.grade_id','grd_a.name');
    elsif p_condition in ('IS_LESS','IS_GREATER') then
      l_where:='and per_asg.grade_id in (select grd_a.grade_id from per_grades_vl grd_a where grd_a.sequence';
      if p_condition='IS_LESS' then
        l_where:=l_where||' <=';
      else
        l_where:=l_where||' >=';
      end if;
      l_where:=l_where||'(select grd_a2.sequence from per_grades_vl grd_a2 where grd_a2.name like ('''
      ||p_value||''') ) )';
    end if;
    return l_where;
  end build_grade_where;
  --
--Bug 4060365. Changed the size of the variable l_a_where_clause from 2000 to 4000
  function advanced_where(p_field_name     varchar2
                         ,p_condition      varchar2
                         ,p_value          varchar2)
                         return varchar2 is
  l_a_where_clause varchar2(4000);
  l_parent_column varchar2(50);
  l_child_table  varchar2(50);
  l_child_column varchar2(50);
  l_child_meaning varchar2(50);
  --
  begin

    if p_field_name='FULL_NAME' then
      l_a_where_clause:=build_varchar2_where('per.full_name',p_condition,p_value);
    elsif p_field_name='LAST_NAME' then
      l_a_where_clause:=build_varchar2_where('per.last_name',p_condition,p_value);
    elsif p_field_name='FIRST_NAME' then
      l_a_where_clause:=build_varchar2_where('per.first_name',p_condition,p_value);
    elsif p_field_name='NATIONAL_IDENTIFIER' then
      l_a_where_clause:=build_varchar2_where('per.national_identifier',p_condition,p_value);
    elsif p_field_name='APPLICANT_NUMBER' then
      l_a_where_clause:=build_varchar2_where('per.applicant_number',p_condition,p_value);
    elsif p_field_name='EMPLOYEE_NUMBER' then
      l_a_where_clause:=build_varchar2_where('per.employee_number',p_condition,p_value);
    elsif p_field_name='DATE_OF_BIRTH' then
      l_a_where_clause:=build_date_where('per.date_of_birth',p_condition,p_value);
    elsif p_field_name='NATIONALITY' then
      l_a_where_clause:=build_varchar2_where('per.nationality',p_condition,p_value
     ,'hr_lookups hlna_a','hlna_a.lookup_code','hlna_a.meaning',' and hlna_a.lookup_type=''NATIONALITY''');
    elsif p_field_name='SEX' then
      l_a_where_clause:=build_varchar2_where('per.sex',p_condition,p_value
     ,'hr_lookups hlse_a','hlse_a.lookup_code','hlse_a.meaning',' and hlse_a.lookup_type=''SEX''');
    elsif p_field_name='ESTABLISHMENT' then
      -- bug 3002915 starts here.
      -- commented existing one added new.
      --
      --  l_a_where_clause:=build_varchar2_where('per.person_id',p_condition,p_value
      --,'per_establishment_attendances peat_a, per_establishments pest_a ','peat_a.person_id','pest_a.name'
      --,'pest_a.establishment_id=peat_a.establishment_id');
      --
      l_a_where_clause:=build_varchar2_where('per_asg.establishment_id',p_condition,p_value,
                                           'hr_leg_establishments_v hle','hle.organization_id','hle.name');
      l_asg:=TRUE;
      -- bug 3002915 ends here.
    elsif p_field_name='USER_PERSON_TYPE' then
      l_a_where_clause:=build_varchar2_where
        ('per.person_id'
        ,p_condition
        ,p_value
        ,'per_person_type_usages_f ptua, per_person_types_tl ppttla'
        ,'ptua.person_id'
        ,'ppttla.user_person_type'
        ,' AND ptua.person_type_id = ppttla.person_type_id'
       ||' AND ppttla.language=userenv(''LANG'')'
       ||' AND ' ||l_effective_date_clause
       ||      ' BETWEEN ptua.effective_start_date'
       ||      ' AND ptua.effective_end_date'
        );

-- Bug 3037019 Start Here
    elsif p_field_name='REGISTERED_DISABLED' then
      l_a_where_clause:=build_varchar2_where('per.registered_disabled_flag',p_condition,p_value
     ,'hr_lookups hlrd_a','hlrd_a.lookup_code','hlrd_a.meaning',' and hlrd_a.lookup_type=''REGISTERED_DISABLED''');
-- Bug 3037019 End Here

    elsif p_field_name='EMPLOYMENT_CATEGORY' then
      l_a_where_clause:=build_varchar2_where('per_asg.employment_category',p_condition,p_value
     ,'hr_lookups hlec_a','hlec_a.lookup_code','hlec_a.meaning',' and hlec_a.lookup_type=''EMP_CAT''');
      l_asg:=TRUE;
    elsif p_field_name='BENEFITS_GROUP' then
-- Bug 4060365 Changed the parameter from per.benefit_group to per.benefit_group_id and
-- ben_a.benefit_group_id to ben_a.benfts_grp_id
      l_a_where_clause:=build_varchar2_where('per.benefit_group_id',p_condition,p_value
     ,'ben_benfts_grp  ben_a','ben_a.benfts_grp_id','ben_a.name');
    elsif p_field_name='VACANCY' then
      l_a_where_clause:=build_varchar2_where('per_asg.vacancy_id',p_condition,p_value
     ,'per_all_vacancies vac_a','vac_a.vacancy_id','vac_a.name');
      l_asg:=TRUE;
    elsif p_field_name='REQUISITION' then
      l_a_where_clause:=build_varchar2_where('per_asg.vacancy_id',p_condition,p_value
     ,'per_all_vacancies vac_a2,per_requisitions rec_a','vac_a2.vacancy_id','rec_a.name'
     ,' and vac_a2.requisition_id=rec_a.requisition_id');
      l_asg:=TRUE;
    elsif p_field_name='JOB' then
      l_a_where_clause:=build_varchar2_where('per_asg.job_id',p_condition,p_value
     ,'per_jobs_v job_a','job_a.job_id','job_a.name');
      l_asg:=TRUE;
    elsif p_field_name='POSITION' then
      -- PMFLETCH - Now using VL translation table
      l_a_where_clause:=build_varchar2_where('per_asg.position_id',p_condition,p_value
     ,'hr_all_positions_f_vl pos_a','pos_a.position_id','pos_a.name');  -- Bug 3891920
      l_asg:=TRUE;
    elsif p_field_name='GRADE' then
      l_a_where_clause:=build_grade_where(p_condition,p_value);
      l_asg:=TRUE;
    elsif p_field_name='GRADE_LADDER' then
      l_a_where_clause:=build_varchar2_where('per_asg.grade_ladder_pgm_id',p_condition,p_value
     ,'ben_pgm_f pgm','pgm.pgm_id','pgm.name');
      l_asg:=TRUE;
    elsif p_field_name='PEOPLE_GROUP' then
      l_a_where_clause:=build_varchar2_where('per_asg.people_group_id',p_condition,p_value
     ,'pay_people_groups pgp_a','pgp_a.people_group_id','pgp_a.group_name');
      l_asg:=TRUE;
    elsif p_field_name='SUPERVISOR' then
      l_a_where_clause:=build_varchar2_where('per_asg.supervisor_id',p_condition,p_value
     ,'per_all_people_f sup_a','sup_a.person_id','sup_a.full_name');
      l_asg:=TRUE;
    elsif p_field_name='SUPERVISOR_ASSIGNMENT_NUMBER' then
      l_a_where_clause:=build_varchar2_where('per_asg.supervisor_assignment_id',p_condition,p_value
     ,'per_all_assignments_f supan_a','supan_a.assignment_id','supan_a.assignment_number');
      l_asg:=TRUE;
    elsif p_field_name='ORGANIZATION' then
      l_a_where_clause:=build_varchar2_where('per_asg.organization_id',p_condition,p_value
     ,'hr_all_organization_units org_a','org_a.organization_id','org_a.name');
      l_asg:=TRUE;
    elsif p_field_name='LOCATION' then
      l_a_where_clause:=build_varchar2_where('per_asg.location_id',p_condition,p_value
     ,'hr_locations loc_a','loc_a.location_id','loc_a.location_code');
      l_asg:=TRUE;
    elsif p_field_name='PAYROLL' then
      l_a_where_clause:=build_varchar2_where('per_asg.payroll_id',p_condition,p_value
     ,'pay_all_payrolls pay_a','pay_a.payroll_id','pay_a.payroll_name');
      --*** Changed pay_a.name to pay_a.payroll_name. Bug2830622
      l_asg:=TRUE;
    elsif p_field_name='PROJECTED_HIRE_DATE' then
      l_a_where_clause:=build_date_where('per.person_id',p_condition,p_value
     ,'per_applications pap_a ','pap_a.person_id','pap_a.projected_hire_date');
    elsif p_field_name='HIRE_DATE' then
      l_a_where_clause:=build_date_where('per.person_id',p_condition,p_value
     ,'per_periods_of_service pds_a ','pds_a.person_id','pds_a.date_start');
    elsif p_field_name='ASSIGNMENT_STATUS' then
-- Bug 4060365 Removed the first comma placed before table s_a in the 4th parameter
--Modified for PMxbg
      l_a_where_clause:=build_varchar2_where('per_asg.assignment_status_type_id'
      ,p_condition
      ,p_value
     ,'per_assignment_status_types s_a,per_assignment_status_types_tl stl_a,per_ass_status_type_amends a_a,per_ass_status_type_amends_tl atl_a'
     ,'s_a.assignment_status_type_id'
     ,'nvl(atl_a.user_status,stl_a.user_status)'
     ,' and a_a.assignment_status_type_id (+)=s_a.assignment_status_type_id'
     ||' and s_a.assignment_status_type_id=stl_a.assignment_status_type_id'
     ||' and a_a.ass_status_type_amend_id=atl_a.ass_status_type_amend_id(+)'
     ||' and a_a.business_group_id (+) = s_a.business_group_id'
     ||' and nvl(a_a.active_flag, s_a.active_flag)=''Y''
       and decode(atl_a.language,null,''1'',atl_a.language)=decode(atl_a.language,null,''1'',userenv(''LANG''))
       and stl_a.language=userenv(''LANG'')');
      l_asg:=TRUE;
    elsif p_field_name='START_DATE' then
      l_a_where_clause:=build_date_where('per.start_date',p_condition,p_value);
    elsif p_field_name='BACKGROUND_DATE_CHECK' then
      l_a_where_clause:=build_date_where('per.background_date_check',p_condition,p_value);
    elsif p_field_name='DATE_EMPLOYEE_DATA_VERIFIED' then
      l_a_where_clause:=build_date_where('per.date_employee_data_verified',p_condition,p_value);
    elsif p_field_name='EMAIL_ADDRESS' then
      l_a_where_clause:=build_varchar2_where('per.email_address',p_condition,p_value);
    elsif p_field_name='FTE_CAPACITY' then
      l_a_where_clause:=build_number_where('per.fte_capacity',p_condition,p_value);
    elsif p_field_name='HOLD_APPLICANT_DATE_UNTIL' then
      l_a_where_clause:=build_date_where('per.hold_applicant_date_until',p_condition,p_value);
    elsif p_field_name='HONORS' then
      l_a_where_clause:=build_varchar2_where('per.honors',p_condition,p_value);
    elsif p_field_name='INTERNAL_LOCATION' then
      l_a_where_clause:=build_varchar2_where('per.internal_location',p_condition,p_value);
    elsif p_field_name='KNOWN_AS' then
      l_a_where_clause:=build_varchar2_where('per.known_as',p_condition,p_value);
    elsif p_field_name='LAST_MEDICAL_TEST_BY' then
      l_a_where_clause:=build_varchar2_where('per.last_medical_test_by',p_condition,p_value);
    elsif p_field_name='LAST_MEDICAL_TEST_DATE' then
      l_a_where_clause:=build_date_where('per.last_medical_test_date',p_condition,p_value);
    elsif p_field_name='MAILSTOP' then
      l_a_where_clause:=build_varchar2_where('per.mailstop',p_condition,p_value);
    elsif p_field_name='MIDDLE_NAMES' then
      l_a_where_clause:=build_varchar2_where('per.middle_names',p_condition,p_value);
    elsif p_field_name='OFFICE_NUMBER' then
      l_a_where_clause:=build_varchar2_where('per.office_number',p_condition,p_value);
    elsif p_field_name='PREVIOUS_LAST_NAME' then
      l_a_where_clause:=build_varchar2_where('per.previous_last_name',p_condition,p_value);
    elsif p_field_name='REHIRE_AUTHORIZOR' then
      l_a_where_clause:=build_varchar2_where('per.rehire_authorizor',p_condition,p_value);
    elsif p_field_name='REHIRE_REASON' then
      l_a_where_clause:=build_varchar2_where('per.rehire_reason',p_condition,p_value);
    elsif p_field_name='RESUME_LAST_UPDATED' then
      l_a_where_clause:=build_date_where('per.resume_last_updated',p_condition,p_value);
    elsif p_field_name='SUFFIX' then
      l_a_where_clause:=build_varchar2_where('per.suffix',p_condition,p_value);
    elsif p_field_name='PREFIX' then
-- Bug 4060365 Changed the parameter from per.prefix to per.pre_name_adjunct
      l_a_where_clause:=build_varchar2_where('per.pre_name_adjunct',p_condition,p_value);
    elsif p_field_name='SALARY_BASIS' then
      l_a_where_clause:=build_varchar2_where('per_asg.pay_basis_id',p_condition,p_value
     ,'per_pay_bases ppb_a','ppb_a.pay_basis_id','ppb_a.name');
      l_asg:=TRUE;
    elsif p_field_name='BARGAINING_UNIT' then
-- Bug 4060365 Changed the parameter from per.barganing_unit_code to per.bargaining_unit_code
      l_a_where_clause:=build_varchar2_where('per_asg.bargaining_unit_code',p_condition,p_value
     ,'hr_lookups hlbu_a','hlbu_a.lookup_code','hlbu_a.meaning',' and hlbu_a.lookup_type=''BARGAINING_UNIT_CODE''');
      l_asg:=TRUE;
    elsif p_field_name='COORD_BEN_MED_PLN_NO' then
      l_a_where_clause:=build_varchar2_where('per.coord_ben_med_pln_no',p_condition,p_value);
    elsif p_field_name='DPDNT_ADOPTION_DATE' then
      l_a_where_clause:=build_date_where('per.dpdnt_adoption_date',p_condition,p_value);
    elsif p_field_name='CHANGE_REASON' then
      l_a_where_clause:=build_varchar2_where('per_asg.change_reason',p_condition,p_value
     ,'hr_lookups hlcr_a','hlcr_a.lookup_code','hlcr_a.meaning',' and hlcr_a.lookup_type=''APL_ASSIGN_REASON''');
      l_asg:=TRUE;
    elsif p_field_name='DATE_PROBATION_END' then
      l_a_where_clause:=build_date_where('per_asg.date_probation_end',p_condition,p_value);
      l_asg:=TRUE;
    elsif p_field_name='INTERNAL_ADDRESS_LINE' then
      l_a_where_clause:=build_varchar2_where('per_asg.internal_address_line',p_condition,p_value);
      l_asg:=TRUE;
    elsif p_field_name='NORMAL_HOURS' then
      l_a_where_clause:=build_number_where('per_asg.normal_hours',p_condition,p_value);
      l_asg:=TRUE;
    elsif p_field_name='TIME_NORMAL_FINISH' then
      l_a_where_clause:=build_varchar2_where('per_asg.time_normal_finish',p_condition,p_value);
      l_asg:=TRUE;
    elsif p_field_name='TIME_NORMAL_START' then
      l_a_where_clause:=build_varchar2_where('per_asg.time_normal_start',p_condition,p_value);
      l_asg:=TRUE;
    end if;
    return l_a_where_clause;
  end advanced_where;
begin
--
  hr_utility.set_location('Entering: '||l_proc,10);
  l_effective_date:='to_date('''||to_char(p_effective_date,'DDMMYYYY')||''',''DDMMYYYY'')';
--
--for bug 2632619 conditionally switch the from clause
  if secure='Y' then
     l_from_clause:=' from per_people_f per';
  else
     l_from_clause:=' from per_all_people_f per';
  end if;

--Modified for PMxbg

  l_where_clause:=' where '||l_effective_date||' between per.effective_start_date and per.effective_end_date';
  --commented for PMP and modified upper line
  --'and' ||'per.business_group_id+0=nvl('||business_group_id||',per.business_group_id)';
--
  l_effective_date_clause :=
 'to_date('''||to_char(p_effective_date,'DDMMYYYY')||''',''DDMMYYYY'')';
--Modified for PMxbg

--commmented for PMP
--  if business_group_name is not null then
        l_from_clause:=l_from_clause||',per_business_groups b';
        l_where_clause:=l_where_clause||' and per.business_group_id=b.business_group_id'
                                      ||' and (upper(b.name) like ('''||upper(replace(business_group_name,g_quote,g_quote||g_quote))||''') or '''
				      ||(replace(business_group_name,g_quote,g_quote||g_quote))||''' is null)'; --fix for bug 8648029
--commmented for PMP
--   end if;
--
--Modified for PMxbg

  if person_id is not null then
    l_where_clause:=l_where_clause||' and per.person_id='||person_id;
  end if;
--
  if person_type_id is not null then
    l_where_clause:=l_where_clause
     ||' AND per.person_id IN'
     || ' (SELECT ptu.person_id'
     ||   ' FROM per_person_type_usages_f ptu'
     ||   ' WHERE ptu.person_type_id = '||person_type_id
     ||   ' AND ' ||l_effective_date_clause
     ||   ' BETWEEN ptu.effective_start_date'
     ||   ' AND ptu.effective_end_date)';
  else
    if person_type is not null then
      l_where_clause:=l_where_clause
       ||' AND per.person_id IN'
       ||  ' (SELECT ptu.person_id'
       ||  ' FROM per_person_type_usages_f ptu'
       ||  ' ,per_person_types_tl ppttl'
       ||  ' WHERE ptu.person_type_id = ppttl.person_type_id'
       ||  ' AND UPPER(ppttl.user_person_type)'
       ||     ' LIKE '''||upper(replace(person_type,g_quote,g_quote||g_quote))||''''
       ||  ' AND ppttl.language = userenv(''LANG'')'
       ||  ' AND '||l_effective_date_clause
       ||     ' BETWEEN ptu.effective_start_date'
       ||     ' AND ptu.effective_end_date)';
    end if;
    if system_person_type is not null then
      l_where_clause:=l_where_clause
       ||' AND per.person_id IN'
       ||   ' (SELECT ptu.person_id'
       ||   ' FROM per_person_type_usages_f ptu'
       ||   ' ,per_person_types ppt'
       ||   ' WHERE ptu.person_type_id = ppt.person_type_id'
       ||   ' AND ppt.system_person_type ='''||system_person_type||''''
       ||   ' AND '||l_effective_date_clause
       ||      ' BETWEEN ptu.effective_start_date'
       ||      ' AND ptu.effective_end_date)';
    end if;
  end if;
--
--Modified for PMxbg

  if last_name is not null then
    l_where_clause:=l_where_clause||' and upper(per.last_name) like ('''||upper(replace(last_name,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if start_date is not null then
    l_where_clause:=l_where_clause||' and per.start_date=to_date('''||to_char(start_date,'DD/MM/YYYY')
    ||''',''DD/MM/YYYY'')';
  end if;
--
  if hire_date is not null then
    l_from_clause:=l_from_clause||',per_periods_of_service pds';
    l_where_clause:=l_where_clause||' and pds.person_id=per.person_id'
    ||' and pds.date_start=to_date('''||to_char(hire_date,'DD/MM/YYYY')
    ||''',''DD/MM/YYYY'')';
  end if;
--
  if applicant_number is not null then
    l_where_clause:=l_where_clause||' and upper(per.applicant_number) like ('''||upper(replace(applicant_number,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if date_of_birth is not null then
    l_where_clause:=l_where_clause||' and per.date_of_birth=to_date('''||to_char(date_of_birth,'DD/MM/YYYY')
    ||''',''DD/MM/YYYY'')';
  end if;
--
  if email_address is not null then
    l_where_clause:=l_where_clause||' and upper(per.email_address) like ('''||upper(replace(email_address,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if employee_number is not null then
    l_where_clause:=l_where_clause||' and upper(per.employee_number) like ('''||upper(replace(employee_number,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if npw_number is not null then
    l_where_clause:=l_where_clause||' and upper(per.npw_number) like ('''||upper(replace(npw_number,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if first_name is not null then
    l_where_clause:=l_where_clause||' and upper(per.first_name) like ('''||upper(replace(first_name,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if full_name is not null then
    l_where_clause:=l_where_clause||' and upper(per.full_name) like ('''||upper(replace(full_name,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if title is not null then
    l_where_clause:=l_where_clause||' and per.title = '''||replace(title,g_quote,g_quote||g_quote)||'''';
  end if;
--
  if middle_names is not null then
    l_where_clause:=l_where_clause||' and upper(per.middle_names) like ('''||upper(replace(middle_names,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if nationality is not null then
    l_where_clause:=l_where_clause||' and per.nationality='''||nationality||'''';
  elsif nationality_meaning is not null then
    l_from_clause:=l_from_clause||',hr_lookups hlnat';
    l_where_clause:=l_where_clause||' and per.nationality=hlnat.lookup_code'
                                  ||' and hlnat.lookup_type=''NATIONALITY'''
                                  ||' and upper(hlnat.meaning) like ('''||upper(replace(nationality_meaning,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if national_identifier is not null then
    l_where_clause:=l_where_clause||' and upper(per.national_identifier) like ('''||upper(replace(national_identifier,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if registered_disabled is not null then
    l_where_clause:=l_where_clause||' and per.registered_disabled_flag='''||registered_disabled||'''';

-- Bug 3037019 Start Here
  elsif registered_disabled_flag is not null then
    l_from_clause:=l_from_clause||',hr_lookups hlnat';
    l_where_clause:=l_where_clause||' and per.registered_disabled_flag=hlnat.lookup_code'
                                  ||' and hlnat.lookup_type=''REGISTERED_DISABLED'''
                                  ||' and upper(hlnat.meaning) like ('''||upper(replace(registered_disabled_flag,g_quote,g_quote||g_quote))||''')';
-- Bug 3037019 Ends Here

  end if;
--
  if sex is not null then
    l_where_clause:=l_where_clause||' and per.sex='''||sex||'''';
  elsif sex_meaning is not null then
    l_from_clause:=l_from_clause||',hr_lookups hlsex';
    l_where_clause:=l_where_clause||' and per.sex=hlsex.lookup_code'
                                  ||' and hlsex.lookup_type=''SEX'''
                                  ||' and upper(hlsex.meaning) like ('''||upper(replace(sex_meaning,g_quote,g_quote||g_quote))||''')';
  end if;
--
  if benefit_group_id is not null then
    l_where_clause:=l_where_clause||' and per.benefit_group_id='||benefit_group_id;
  elsif benefit_group is not null then
    l_from_clause:=l_from_clause||',ben_benfts_grp per_ben';
    l_where_clause:=l_where_clause||' and per.benefit_group_id=per_ben.benefit_group_id'
                                  ||' and upper(per_ben.name) like ('''||upper(replace(benefit_group,g_quote,g_quote||g_quote))||''')';
  end if;
--
--CWK
--
  if project_title is not null then
    l_where_clause:=l_where_clause||' and per_asg.project_title='''||replace(project_title,g_quote,g_quote||g_quote)||'''';
    l_asg:=TRUE;
  end if;
--
  if vendor_employee_number is not null then
    l_where_clause:=l_where_clause||' and per_asg.vendor_employee_number='''||replace(vendor_employee_number,g_quote,g_quote||g_quote)||'''';
    l_asg:=TRUE;
  end if;
--
  if vendor_assignment_number is not null then
    l_where_clause:=l_where_clause||' and per_asg.vendor_assignment_number='''||replace(vendor_assignment_number,g_quote,g_quote||g_quote)||'''';
    l_asg:=TRUE;
  end if;
--
  if vendor_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.vendor_id='||vendor_id;
    l_asg:=TRUE;
  elsif vendor_name is not null then
    l_from_clause:=l_from_clause||',po_vendors pov';
    l_where_clause:=l_where_clause||' and per_asg.vendor_id=pov.vendor_id'
                                  ||' and upper(pov.vendor_name) like ('''||upper(replace(vendor_name,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--
  if vendor_site_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.vendor_site_id='||vendor_site_id;
    l_asg:=TRUE;
  elsif vendor_site_code is not null then
    l_from_clause:=l_from_clause||',po_vendor_sites povs';
    l_where_clause:=l_where_clause||' and per_asg.vendor_site_id=povs.vendor_site_id'
                                  ||' and upper(povs.vendor_site_code) like ('''||upper(replace(vendor_site_code,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--
  if po_header_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.po_header_id='||po_header_id;
    l_asg:=TRUE;
  elsif po_header_num is not null then
    l_from_clause:=l_from_clause||',po_headers_all poh';
    l_where_clause:=l_where_clause||' and per_asg.po_header_id=poh.po_header_id'
                                  ||' and upper(poh.segment1) like ('''||upper(replace(po_header_num,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--
  if po_line_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.po_line_id='||po_line_id;
    l_asg:=TRUE;
  elsif po_line_num is not null then
    l_from_clause:=l_from_clause||',po_lines_all pol';
    l_where_clause:=l_where_clause||' and per_asg.po_line_id=pol.po_line_id'
                                  ||' and upper(pol.line_num) like ('''||upper(replace(po_line_num,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg
  if grade_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.grade_id='||grade_id;
    l_asg:=TRUE;
  elsif grade is not null then
    l_from_clause:=l_from_clause||',per_grades_vl grd';
    l_where_clause:=l_where_clause||' and per_asg.grade_id=grd.grade_id'
                                  ||' and upper(grd.name) like ('''||upper(replace(grade,g_quote,g_quote||g_quote))||''')'
                                  ||' and grd.business_group_id=per.business_group_id';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg

  if grade_ladder_pgm_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.grade_ladder_pgm_id='||grade_ladder_pgm_id;
    l_asg:=TRUE;
  elsif grade_ladder is not null then
    l_from_clause:=l_from_clause||',ben_pgm_f pgm';
    l_where_clause:=l_where_clause||' and per_asg.grade_ladder_pgm_id=pgm.pgm_id'
                                  ||' and upper(pgm.name) like ('''||upper(replace(grade_ladder,g_quote,g_quote||g_quote))||''')'
                             --Modified for PMxbg
			          ||' and gpm.business_group_id+0=nvl('||business_group_id||',gpm.business_group_id)'
                                  ||' and '||l_effective_date||' between pgm.effective_start_date'
                                  ||' and pgm.effective_end_date';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg
  if position_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.position_id='||position_id;
    l_asg:=TRUE;
  elsif position is not null then
  -- PMFLETCH - Now using VL translation table
    l_from_clause:=l_from_clause||',hr_all_positions_f_vl per_pos'; -- Bug 3891920
    l_where_clause:=l_where_clause||' and per_asg.position_id=per_pos.position_id'
                                  ||' and upper(per_pos.name) like ('''||upper(replace(position,g_quote,g_quote||g_quote))||''')'
                                  ||' and per_pos.business_group_id=per.business_group_id';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg

  if job_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.job_id='||job_id;
    l_asg:=TRUE;
  elsif job is not null then
    l_from_clause:=l_from_clause||',per_jobs_v job';
    l_where_clause:=l_where_clause||' and per_asg.job_id=job.job_id'
                                  ||' and upper(job.name) like ('''||upper(replace(job,g_quote,g_quote||g_quote))||''')'
                                  ||' and job.business_group_id = per.business_group_id';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg

  if assignment_status_type_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.assignment_status_type_id='||assignment_status_type_id;
    l_asg:=TRUE;
  elsif assignment_status_type is not null then
    l_from_clause:=l_from_clause||',per_assignment_status_types s,per_assignment_status_types_tl stl';
    l_from_clause:=l_from_clause||',per_ass_status_type_amends a,per_ass_status_type_amends_tl atl';
    l_where_clause:=l_where_clause||' and upper(nvl(atl.user_status,stl.user_status))'
    ||' like ('''||upper(replace(assignment_status_type,g_quote,g_quote||g_quote))||''')'
    ||' and s.assignment_status_type_id=per_asg.assignment_status_type_id'
    ||' and a.assignment_status_type_id (+)=s.assignment_status_type_id'
    ||' and s.assignment_status_type_id =stl.assignment_status_type_id'
    ||' and a.ass_status_type_amend_id=atl.ass_status_type_amend_id(+)'
    ||' and a.business_group_id (+)= s.business_group_id'
    ||' and nvl(a.active_flag, s.active_flag)=''Y'''
    ||' and decode(atl.language,null,''1'',atl.language)=decode(atl.language,null,''1'',userenv(''LANG''))'
    ||' and stl.language=userenv(''LANG'')';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg

  if payroll_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.payroll_id='||payroll_id;
    l_asg:=TRUE;
  elsif payroll is not null then
    l_from_clause:=l_from_clause||',pay_all_payrolls_f pay';
    l_where_clause:=l_where_clause||' and per_asg.payroll_id=pay.payroll_id'
                                  ||' and upper(pay.payroll_name) like ('''||upper(replace(payroll,g_quote,g_quote||g_quote))||''')'
                                  ||' and pay.business_group_id = per.business_group_id'
                                  ||' and '||l_effective_date||' between pay.effective_start_date'
                                  ||' and pay.effective_end_date';
    l_asg:=TRUE;
  end if;
--
  if location_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.location_id='||location_id;
    l_asg:=TRUE;
  elsif location is not null then
    l_from_clause:=l_from_clause||',hr_locations loc';
    l_where_clause:=l_where_clause||' and per_asg.location_id=loc.location_id'
                                  ||' and upper(loc.location_code) like ('''||upper(replace(location,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg
  if supervisor_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.supervisor_id='||supervisor_id;
    l_asg:=TRUE;
  elsif supervisor is not null then
    l_from_clause:=l_from_clause||',per_all_people_f sup';
    l_where_clause:=l_where_clause||' and per_asg.supervisor_id=sup.person_id'
    ||' and upper(sup.full_name) like ('''||upper(replace(supervisor,g_quote,g_quote||g_quote))||''')'
    ||' and '||l_effective_date||' between sup.effective_start_date and sup.effective_end_date'
    ||' and sup.business_group_id=per.business_group_id';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg
  if supervisor_assignment_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.supervisor_assignment_id='||supervisor_assignment_id;
    l_asg:=TRUE;
  elsif supervisor_assignment_number is not null then
    l_from_clause:=l_from_clause||',per_all_assignments_f supan';
    l_where_clause:=l_where_clause||' and per_asg.supervisor_assignment_id=supan.assignment_id'
    ||' and upper(supan.assignment_number)
          like ('''||upper(replace(supervisor_assignment_number,g_quote,g_quote||g_quote))||''')'
    ||' and '||l_effective_date||' between supan.effective_start_date and supan.effective_end_date'
    ||' and supan.business_group_id = per.business_group_id';
    l_asg:=TRUE;
  end if;
--
  if recruitment_activity_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.recruitment_activity_id='||recruitment_activity_id;
    l_asg:=TRUE;
  elsif recruitment_activity is not null then
    l_from_clause:=l_from_clause||',per_recruitment_activities ract';
    l_where_clause:=l_where_clause||' and per_asg.recruitment_activity_id = ract.recruitment_activity_id'
    ||' and upper(ract.name) like ('''||upper(replace(recruitment_activity,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg

  if organization_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.organization_id='||organization_id;
    l_asg:=TRUE;
  elsif organization is not null then
    l_from_clause:=l_from_clause||',hr_all_organization_units_tl houtl,hr_all_organization_units hou';
    l_where_clause:=l_where_clause||' and per_asg.organization_id=hou.organization_id'
    ||' and hou.organization_id=houtl.organization_id'
    ||' and upper(houtl.name) like ('''||upper(replace(organization,g_quote,g_quote||g_quote))||''')'
    ||' and hou.internal_external_flag=''INT'''
    ||' and houtl.language=userenv(''LANG'')'
    ||' and hou.business_group_id=per.business_group_id';
    l_asg:=TRUE;
  end if;
--
  if people_group_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.people_group_id='||people_group_id;
    l_asg:=TRUE;
  elsif people_group is not null then
    l_from_clause:=l_from_clause||',pay_people_groups ppg';
    l_where_clause:=l_where_clause||' and per_asg.people_group_id=ppg.people_group_id'
    ||' and upper(ppg.group_name) like ('''||upper(replace(people_group,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg
  if vacancy_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.vacancy_id='||vacancy_id;
    l_asg:=TRUE;
  elsif vacancy is not null then
    l_from_clause:=l_from_clause||',per_all_vacancies vac';
    l_where_clause:=l_where_clause||' and per_asg.vacancy_id=vac.vacancy_id'
    ||' and upper(vac.name) like ('''||upper(replace(vacancy,g_quote,g_quote||g_quote))||''')'
    ||' and vac.business_group_id = per.business_group_id';
    l_asg:=TRUE;
  end if;
--Modified for PMxbg
  if requisition_id is not null then
    if vacancy_id is null then
      if vacancy is null then
        l_from_clause:=l_from_clause||',per_all_vacancies vac';
        l_where_clause:=l_where_clause||' and per_asg.vacancy_id=vac.vacancy_id'
        ||' and vac.business_group_id = per.business_group_id';
      end if;
      l_where_clause:=l_where_clause||' and vac.requisition_id='||requisition_id;
    else
      l_from_clause:=l_from_clause||',per_all_vacancies vac';
      l_where_clause:=l_where_clause||' and vac.requisition_id='||requisition_id
      ||' and vac.vacancy_id=per_asg.vacancy_id';
    end if;
    l_asg:=TRUE;
  elsif requisition is not null then
    if vacancy_id is null then
      if vacancy is null then
        l_from_clause:=l_from_clause||',per_all_vacancies vac';
        l_where_clause:=l_where_clause||' and per_asg.vacancy_id=vac.vacancy_id'
        ||' and vac.business_group_id = per.business_group_id';
      end if;
      l_from_clause:=l_from_clause||',per_requisitions rec';
      l_where_clause:=l_where_clause||' and vac.requisition_id=rec.requisition_id'
      ||' and upper(rec.name) like ('''||upper(replace(requisition,g_quote,g_quote||g_quote))||''')';
    else
      l_from_clause:=l_from_clause||',per_all_vacancies vac, per_requisitions rec';
      l_where_clause:=l_where_clause||' and vac.requisition_id,rec.requisition_id'
      ||' and vac.requisition_id=rec.requisition_id'
      ||' and vac.vacancy_id=per_asg.vacancy_id'
      ||' and upper(rec.name) like ('''||upper(replace(requisition,g_quote,g_quote||g_quote))||''')';
    end if;
    l_asg:=TRUE;
  end if;
-- Modified for PMxbg
  if pay_basis_id is not null then
    l_where_clause:=l_where_clause||' and per_asg.pay_basis_id='||pay_basis_id;
    l_asg:=TRUE;
  elsif salary_basis is not null then
    l_from_clause:=l_from_clause||',per_pay_bases ppb';
    l_where_clause:=l_where_clause||' and per_asg.pay_basis_id=ppb.pay_basis_id'
    ||' and upper(ppb.name) like ('''||upper(replace(salary_basis,g_quote,g_quote||g_quote))||''')'
    ||' and ppb.business_group_id = per.business_group_id';
    l_asg:=TRUE;
  end if;
--
  if bargaining_unit_code is not null then
    l_where_clause:=l_where_clause||' and per_asg.bargaining_unit_code='''||bargaining_unit_code||'''';
    l_asg:=TRUE;
  elsif bargaining_unit_code_meaning is not null then
    l_from_clause:=l_from_clause||',hr_lookups buc';
    l_where_clause:=l_where_clause||' and per_asg.bargaining_unit_code=buc.lookup_code'
    ||' and buc.lookup_type=''BARGAINING_UNIT_CODE'''
    ||' and upper(buc.meaning) like ('''||upper(replace(bargaining_unit_code_meaning,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--
  if employment_category is not null then
    l_where_clause:=l_where_clause||' and per_asg.employment_category='''||employment_category||'''';
    l_asg:=TRUE;
  elsif employment_category_meaning is not null then
    l_from_clause:=l_from_clause||',hr_lookups empc';
    l_where_clause:=l_where_clause||' and per_asg.employment_category=empc.lookup_code
    and empc.lookup_type=''EMP_CAT''
    and upper(empc.meaning) like ('''||upper(replace(employment_category_meaning,g_quote,g_quote||g_quote))||''')';
    l_asg:=TRUE;
  end if;
--
  if establishment_id is not null then
   --bug 3002915 starts here.
   --added new code replacing old.
   --
    --l_where_clause:=l_where_clause||' and exists'
    --||' (select 1'
    --||' from per_establishment_attendances eta'
    --||' where eta.establishment_id='||establishment_id
    --||' and eta.person_id=per.person_id)';
    --
    l_where_clause:=l_where_clause||' and per_asg.establishment_id ='||establishment_id;
    l_asg:=TRUE;
    -- bug 3002915 ends here.
  elsif establishment is not null then
    l_where_clause:=l_where_clause||' and exists'
    ||' (select 1'
    ||' from hr_leg_establishments_v hle'
    ||' where hle.organization_id = per_asg.establishment_id and upper(hle.name) like('''||upper(establishment)||'''))';

    l_asg:=TRUE;
    --bug 3002915.
   -- ||' from per_establishment_attendances eta'
   -- ||',per_establishments est'
   -- ||' where eta.establishment_id=est.establishment_id'
   -- ||' and eta.person_id=per.person_id'
   -- ||' and upper(est.name) like('''||upper(replace(establishment,g_quote,g_quote||g_quote))||'''))';
  end if;
--
  if projected_hire_date is not null then
    l_from_clause:=l_from_clause||',per_applications appl';
    l_where_clause:=l_where_clause||' and appl.projected_hire_date=to_date('''||
    to_char(projected_hire_date,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'
    ||' and per.person_id=appl.person_id';
  end if;
--
--removed for bug 2632619, replaced by conditional change of l_from_clause
--  if secure='Y' then
--    l_where_clause:=l_where_clause||' and (hr_security.view_all=''Y'''
--    ||' or hr_security.show_record(''PER_ALL_PEOPLE_F'''
--    ||',per.person_id,per.person_type_id,per.employee_number,per.applicant_number)=''TRUE'')';
--  end if;
--
  if field1_name is not null and field1_condition_code is not null then
    l_where_clause:=l_where_clause||advanced_where
                                   (p_field_name=> field1_name
                                   ,p_condition => field1_condition_code
                                   ,p_value     => replace(field1_value,g_quote,g_quote||g_quote));
  end if;
--
  if field2_name is not null and field2_condition_code is not null then
    l_where_clause:=l_where_clause||advanced_where
                                   (p_field_name=> field2_name
                                   ,p_condition => field2_condition_code
                                   ,p_value     => replace(field2_value,g_quote,g_quote||g_quote));
  end if;
--
  if field3_name is not null and field3_condition_code is not null then
    l_where_clause:=l_where_clause||advanced_where
                                   (p_field_name=> field3_name
                                   ,p_condition => field3_condition_code
                                   ,p_value     => replace(field3_value,g_quote,g_quote||g_quote));
  end if;
--
  if field4_name is not null and field4_condition_code is not null then
    l_where_clause:=l_where_clause||advanced_where
                                   (p_field_name=> field4_name
                                   ,p_condition => field4_condition_code
                                   ,p_value     => replace(field4_value,g_quote,g_quote||g_quote));
  end if;
--
  if field5_name is not null and field5_condition_code is not null then
    l_where_clause:=l_where_clause||advanced_where
                                   (p_field_name=> field5_name
                                   ,p_condition => field5_condition_code
                                   ,p_value     => replace(field5_value,g_quote,g_quote||g_quote));
  end if;
--
  if l_asg then
  --
  --  Bug 4282150
  --  Added if condition to secure on each individual assignment
  --checkpoint for PMP

    if secure='Y' then
      l_from_clause:=l_from_clause||',per_assignments_f2 per_asg';
    else
      l_from_clause:=l_from_clause||',per_all_assignments_f per_asg';
    end if;
  --
    l_where_clause:=l_where_clause||' and per.person_id=per_asg.person_id and '
    ||l_effective_date||
    ' between per_asg.effective_start_date and per_asg.effective_end_date '||
    ' AND per_asg.assignment_type <> ''B'''; -- Bug 3816589
  end if;



  l_select_stmt_per:=
  'select per.person_id,nvl(per.order_name,per.full_name),count(*) '||l_from_clause||l_where_clause;
  if p_customized_restriction_id is not null then
    l_select_stmt_per:=l_select_stmt_per
     ||' AND (( EXISTS'
     ||   ' (SELECT 1'
     ||   ' FROM pay_restriction_values prv'
     ||   ' WHERE prv.customized_restriction_id = '
     ||             p_customized_restriction_id
     ||   ' AND prv.value IN'
     ||     ' (SELECT ptu.person_type_id'
     ||     ' FROM per_person_type_usages ptu'
     ||     ' WHERE ptu.person_id = per.person_id'
     ||     ' AND '||l_effective_date_clause
     ||        ' BETWEEN ptu.effective_start_date'
     ||        ' AND ptu.effective_end_date)'
     ||   ' AND NVL(prv.include_exclude_flag, ''I'') = ''I'' '
     ||   ' AND prv.restriction_code = ''PERSON_TYPE'')'
     || ' OR NOT EXISTS'
     ||   ' (SELECT 1'
     ||   ' FROM pay_restriction_values prv'
     ||   ' WHERE prv.customized_restriction_id ='
     ||             p_customized_restriction_id
     ||   ' AND NVL(prv.include_exclude_flag, ''I'') = ''I'' '
     ||   ' AND prv.restriction_code = ''PERSON_TYPE'') )'
     ||' AND NOT EXISTS '
     ||   ' (SELECT 1'
     ||   ' FROM pay_restriction_values prv2'
     ||   ' WHERE prv2.customized_restriction_id = '
     ||             p_customized_restriction_id
     ||   ' AND prv2.value IN'
     ||     ' (SELECT ptu2.person_type_id'
     ||     ' FROM per_person_type_usages ptu2'
     ||     ' WHERE ptu2.person_id = per.person_id'
     ||     ' AND '||l_effective_date_clause
     ||        ' BETWEEN ptu2.effective_start_date'
     ||        ' AND ptu2.effective_end_date)'
     ||   ' AND NVL(prv2.include_exclude_flag, ''I'') = ''E'' '
     ||   ' AND prv2.restriction_code = ''PERSON_TYPE''))';
     -- Removed the additional brace for fix of #3430507
   end if;

--  if not p_employees_allowed and not p_applicants_allowed then
--    l_select_stmt_per:=l_select_stmt_per||
--    ' and per.current_emp_or_apl_flag is null';
--  end if;
--  if p_employees_allowed and not p_applicants_allowed then
--    l_select_stmt_per:=l_select_stmt_per||
--    ' and (per.current_employee_flag =''Y''
--      or per.current_emp_or_apl_flag is null)';
--  end if;
--  if not p_employees_allowed and p_applicants_allowed then
--    l_select_stmt_per:=l_select_stmt_per||
--    ' and (per.current_applicant_flag =''Y''
--      or per.current_emp_or_apl_flag is null)';
--  end if;
--  if p_cwk_allowed then
--    l_select_stmt_per:=l_select_stmt_per||
--    ' and (per.current_npw_flag = ''Y''
--      or per.current_emp_or_apl_flag is null)';
--  end if;
  --AH bug 2854634:following clause replaces previous. All templates can see people who are
  --not "current" anything, then add conditions to also bring in types allowed by template
  --
  l_select_stmt_per:=l_select_stmt_per||
  ' and ( (per.current_emp_or_apl_flag is null and per.current_npw_flag is null)';
  if p_employees_allowed then
    l_select_stmt_per:=l_select_stmt_per||
    ' OR per.current_employee_flag =''Y'' ';
  end if;
  if p_applicants_allowed then
    l_select_stmt_per:=l_select_stmt_per||
    ' OR per.current_applicant_flag =''Y'' ';
  end if;
  if p_cwk_allowed then
    l_select_stmt_per:=l_select_stmt_per||
    ' OR per.current_npw_flag = ''Y'' ';
  end if;
  l_select_stmt_per:=l_select_stmt_per||')';
  --
  --bug 2854634 end



  l_select_stmt_per:=l_select_stmt_per||' group by per.person_id,nvl(per.order_name,per.full_name) order by nvl(per.order_name,per.full_name)';
hr_utility.set_location('r'||l_select_stmt_per,2001);

  select_stmt:=l_from_clause||l_where_clause;
  l_select_stmt_asg:='select per_asg.assignment_id '||l_from_clause;
  if not l_asg then
    l_select_stmt_asg:=l_select_stmt_asg||',per_all_assignments_f per_asg';
  end if;
  l_select_stmt_asg:=l_select_stmt_asg||l_where_clause;
  if not l_asg then
    l_select_stmt_asg:=l_select_stmt_asg||' and per.person_id=per_asg.person_id and '
    ||l_effective_date||
    ' between per_asg.effective_start_date and per_asg.effective_end_date ';
  end if;
  l_select_stmt_asg:=l_select_stmt_asg||'and per_asg.assignment_type <> ''B''';-- Added for fix of #3286659
  l_select_stmt_asg:=l_select_stmt_asg||' and per.person_id=:1';
l_select_stmt_per2:=l_select_stmt_per;

hr_utility.set_location('r'||l_select_stmt_per,2000);

while length(l_select_stmt_per2)>0 loop

  hr_utility.set_location(substr(l_select_stmt_per2,1,70),1);
  l_select_stmt_per2:=substr(l_select_stmt_per2,71);
end loop;
--

hr_utility.set_location('hidd'||l_select_stmt_per,1000);

open emp_cv for l_select_stmt_per;
loop
  num_row:=num_row+1;
  fetch emp_cv into l_person_id,l_full_name,l_num_asgs;
  exit when emp_cv%notfound;
--
    open csr_person_details(p_person_id     => l_person_id
                           ,p_effective_date=> p_effective_date);
    fetch csr_person_details into per_rec;
    if csr_person_details%notfound then
      close csr_person_details;
      fnd_message.set_name(800,'XXX');
      fnd_message.raise_error;
    else
      close csr_person_details;
    end if;
  --
    -- set the output fields
  --
    out_rec.person_id                     :=per_rec.person_id;
    out_rec.full_name                     :=per_rec.full_name;

    if p_fetch_details then
      out_rec.per_effective_start_date      :=per_rec.effective_start_date;
      out_rec.per_effective_end_date        :=per_rec.effective_end_date;
    --
      out_rec.person_type                   :=hr_person_type_usage_info.get_user_person_type
                                              (p_effective_date => p_effective_date
                                              ,p_person_id      => per_rec.person_id);
      --
      out_rec.last_name                     :=per_rec.last_name;
      out_rec.start_date                    :=per_rec.start_date;
      out_rec.applicant_number              :=per_rec.applicant_number;
      out_rec.background_chk_stat_meaning   :=hr_reports.get_lookup_meaning('YES_NO',per_rec.background_check_status);
      out_rec.background_date_check         :=per_rec.background_date_check;
      out_rec.blood_type_meaning            :=hr_reports.get_lookup_meaning('BLOOD_TYPE',per_rec.blood_type);

  --Modified for PMxbg
        if per_rec.person_id is not null then
            open csr_bg_name(per_rec.business_group_id);
            fetch csr_bg_name into out_rec.business_group_name;
            close csr_bg_name;
          else
            out_rec.business_group_name:=null;
          end if;
    --
      if per_rec.correspondence_language is not null then
        open csr_lang(per_rec.correspondence_language);
        fetch csr_lang into out_rec.corr_lang_meaning;
        close csr_lang;
      else
        out_rec.corr_lang_meaning:=null;
      end if;
  --
      out_rec.date_employee_data_verified   :=per_rec.date_employee_data_verified;
      out_rec.date_of_birth                 :=per_rec.date_of_birth;
      out_rec.email_address                 :=per_rec.email_address;
      out_rec.employee_number               :=per_rec.employee_number;
      out_rec.expnse_chk_send_addr_meaning  :=hr_reports.get_lookup_meaning('HOME_OFFICE',per_rec.expense_check_send_to_address);
      out_rec.npw_number                    :=per_rec.npw_number;
      out_rec.first_name                    :=per_rec.first_name;
      out_rec.per_fte_capacity              :=per_rec.fte_capacity;
      out_rec.full_name                     :=per_rec.full_name;
      out_rec.hold_applicant_date_until     :=per_rec.hold_applicant_date_until;
      out_rec.honors                        :=per_rec.honors;
      out_rec.internal_location             :=per_rec.internal_location;
      out_rec.known_as                      :=per_rec.known_as;
      out_rec.last_medical_test_by          :=per_rec.last_medical_test_by;
      out_rec.last_medical_test_date        :=per_rec.last_medical_test_date;
      out_rec.mailstop                      :=per_rec.mailstop;
      out_rec.marital_status_meaning        :=hr_reports.get_lookup_meaning('MAR_STATUS',per_rec.marital_status);
      out_rec.middle_names                  :=per_rec.middle_names;
      out_rec.nationality_meaning           :=hr_reports.get_lookup_meaning('NATIONALITY',per_rec.nationality);
      out_rec.national_identifier           :=per_rec.national_identifier;
      out_rec.office_number                 :=per_rec.office_number;
      out_rec.on_military_service_meaning   :=hr_reports.get_lookup_meaning('YES_NO',per_rec.on_military_service);
      out_rec.pre_name_adjunct              :=per_rec.pre_name_adjunct;
      out_rec.previous_last_name            :=per_rec.previous_last_name;
      out_rec.rehire_recommendation         :=per_rec.rehire_recommendation;
      out_rec.resume_exists_meaning         :=hr_reports.get_lookup_meaning('YES_NO',per_rec.resume_exists);
      out_rec.resume_last_updated           :=per_rec.resume_last_updated;
-- Bug 3037019
      out_rec.registered_disabled_flag      :=hr_reports.get_lookup_meaning('REGISTERED_DISABLED',per_rec.registered_disabled_flag);
      out_rec.secnd_passport_exsts_meaning  :=hr_reports.get_lookup_meaning('YES_NO',per_rec.second_passport_exists);
      out_rec.sex_meaning                   :=hr_reports.get_lookup_meaning('SEX',per_rec.sex);
      out_rec.student_status_meaning        :=hr_reports.get_lookup_meaning('STUDENT_STATUS',per_rec.student_status);
      out_rec.suffix                        :=per_rec.suffix;
      out_rec.title_meaning                 :=hr_reports.get_lookup_meaning('TITLE',per_rec.title);
      out_rec.work_schedule_meaning         :=hr_reports.get_lookup_meaning('WORK_SCHEDULE',per_rec.work_schedule);
      out_rec.coord_ben_med_pln_no          :=per_rec.coord_ben_med_pln_no;
      out_rec.cord_ben_no_cvg_flag_meaning  :=hr_reports.get_lookup_meaning('YES_NO',per_rec.coord_ben_no_cvg_flag);
      out_rec.dpdnt_adoption_date           :=per_rec.dpdnt_adoption_date;
      out_rec.dpdnt_vlntry_svc_flg_meaning  :=hr_reports.get_lookup_meaning('YES_NO',per_rec.dpdnt_vlntry_svce_flag);
      out_rec.receipt_of_death_cert_date    :=per_rec.receipt_of_death_cert_date;
      out_rec.uses_tobacco_meaning          :=hr_reports.get_lookup_meaning('YES_NO',per_rec.uses_tobacco_flag);
    --
      if per_rec.benefit_group_id is not null then
        open csr_benfts_grp(per_rec.benefit_group_id);
        fetch csr_benfts_grp into out_rec.benefit_group;
        close csr_benfts_grp;
      else
        out_rec.benefit_group:=null;
      end if;
    --
/*    These fields are no longer used because they may change
      context on a row by row basis, making them meaningless in a table

      out_rec.attribute_category            :=per_rec.attribute_category;
      out_rec.attribute1                    :=per_rec.attribute1;
      out_rec.attribute2                    :=per_rec.attribute2;
      out_rec.attribute3                    :=per_rec.attribute3;
      out_rec.attribute4                    :=per_rec.attribute4;
      out_rec.attribute5                    :=per_rec.attribute5;
      out_rec.attribute6                    :=per_rec.attribute6;
      out_rec.attribute7                    :=per_rec.attribute7;
      out_rec.attribute8                    :=per_rec.attribute8;
      out_rec.attribute9                    :=per_rec.attribute9;
      out_rec.attribute10                   :=per_rec.attribute10;
      out_rec.attribute11                   :=per_rec.attribute11;
      out_rec.attribute12                   :=per_rec.attribute12;
      out_rec.attribute13                   :=per_rec.attribute13;
      out_rec.attribute14                   :=per_rec.attribute14;
      out_rec.attribute15                   :=per_rec.attribute15;
      out_rec.attribute16                   :=per_rec.attribute16;
      out_rec.attribute17                   :=per_rec.attribute17;
      out_rec.attribute18                   :=per_rec.attribute18;
      out_rec.attribute19                   :=per_rec.attribute19;
      out_rec.attribute20                   :=per_rec.attribute20;
      out_rec.attribute21                   :=per_rec.attribute21;
      out_rec.attribute22                   :=per_rec.attribute22;
      out_rec.attribute23                   :=per_rec.attribute23;
      out_rec.attribute24                   :=per_rec.attribute24;
      out_rec.attribute25                   :=per_rec.attribute25;
      out_rec.attribute26                   :=per_rec.attribute26;
      out_rec.attribute27                   :=per_rec.attribute27;
      out_rec.attribute28                   :=per_rec.attribute28;
      out_rec.attribute29                   :=per_rec.attribute29;
      out_rec.attribute30                   :=per_rec.attribute30;
*/

      out_rec.per_information_category      :=per_rec.per_information_category;
      out_rec.per_information1              :=per_rec.per_information1;
      out_rec.per_information2              :=per_rec.per_information2;
      out_rec.per_information3              :=per_rec.per_information3;
      out_rec.per_information4              :=per_rec.per_information4;
      out_rec.per_information5              :=per_rec.per_information5;
      out_rec.per_information6              :=per_rec.per_information6;
      out_rec.per_information7              :=per_rec.per_information7;
      out_rec.per_information8              :=per_rec.per_information8;
      out_rec.per_information9              :=per_rec.per_information9;
      out_rec.per_information10             :=per_rec.per_information10;
      out_rec.per_information11             :=per_rec.per_information11;
      out_rec.per_information12             :=per_rec.per_information12;
      out_rec.per_information13             :=per_rec.per_information13;
      out_rec.per_information14             :=per_rec.per_information14;
      out_rec.per_information15             :=per_rec.per_information15;
      out_rec.per_information16             :=per_rec.per_information16;
      out_rec.per_information17             :=per_rec.per_information17;
      out_rec.per_information18             :=per_rec.per_information18;
      out_rec.per_information19             :=per_rec.per_information19;
      out_rec.per_information20             :=per_rec.per_information20;
      out_rec.per_information21             :=per_rec.per_information21;
      out_rec.per_information22             :=per_rec.per_information22;
      out_rec.per_information23             :=per_rec.per_information23;
      out_rec.per_information24             :=per_rec.per_information24;
      out_rec.per_information25             :=per_rec.per_information25;
      out_rec.per_information26             :=per_rec.per_information26;
      out_rec.per_information27             :=per_rec.per_information27;
      out_rec.per_information28             :=per_rec.per_information28;
      out_rec.per_information29             :=per_rec.per_information29;
      out_rec.per_information30             :=per_rec.per_information30;
      out_rec.date_of_death                 :=per_rec.date_of_death;
  --
    if per_rec.current_employee_flag='Y' then
      open csr_pds(per_rec.person_id,per_rec.effective_start_date);
      fetch csr_pds into out_rec.hire_date;
      close csr_pds;
    else
      out_rec.hire_date:=null;
    end if;
  --
    if per_rec.current_applicant_flag='Y' then
      open csr_app(per_rec.person_id,per_rec.effective_start_date);
      fetch csr_app into out_rec.projected_hire_date;
      close csr_app;
    else
      out_rec.projected_hire_date:=null;
    end if;
  --
    if not l_asg then
      open count_asgs(per_rec.person_id);
      fetch count_asgs into l_num_asgs;
      close count_asgs;
    end if;
  --
    if(l_num_asgs=1) then
      execute immediate l_select_stmt_asg into l_assignment_id using per_rec.person_id;
      open csr_assignment_details(l_assignment_id,p_effective_date);
      fetch csr_assignment_details into asg_rec;
      close csr_assignment_details;
  --
      out_rec.assignment_id                 :=asg_rec.assignment_id;
      out_rec.asg_effective_start_date      :=asg_rec.effective_start_date;
      out_rec.asg_effective_end_date        :=asg_rec.effective_end_date;
  --
      if asg_rec.recruiter_id is not null then
        open csr_full_name(asg_rec.recruiter_id,p_effective_date);
        fetch csr_full_name into out_rec.recruiter;
        close csr_full_name;
      else
        out_rec.recruiter:=null;
      end if;
  --
      if asg_rec.grade_id is not null then
        open csr_grade(asg_rec.grade_id);
        fetch csr_grade into out_rec.grade;
        close csr_grade;
      else
        out_rec.grade:=null;
      end if;
  --
      if asg_rec.grade_ladder_pgm_id is not null then
        open csr_grade_ladder(asg_rec.grade_ladder_pgm_id,p_effective_date);
        fetch csr_grade_ladder into out_rec.grade_ladder;
        close csr_grade_ladder;
      else
        out_rec.grade_ladder:=null;
      end if;
  --
      if asg_rec.position_id is not null then
        open csr_position(asg_rec.position_id,p_effective_date);
        fetch csr_position into out_rec.position;
        close csr_position;
      else
        out_rec.position:=null;
      end if;
  --
      if asg_rec.job_id is not null then
        open csr_job(asg_rec.job_id);
        fetch csr_job into out_rec.job;
        close  csr_job;
      else
        out_rec.job:=null;
      end if;
  --
      open csr_asg_status(asg_rec.assignment_status_type_id);
      fetch csr_asg_status into out_rec.assignment_status_type,out_rec.system_status;
      close csr_asg_status;
  --
      if asg_rec.payroll_id is not null then
        open csr_payroll(asg_rec.payroll_id,p_effective_date);
        fetch csr_payroll into out_rec.payroll;
        close csr_payroll;
      else
        out_rec.payroll:=null;
      end if;
  --
      if asg_rec.location_id is not null then
        open csr_location(asg_rec.location_id);
        fetch csr_location into out_rec.location;
        close csr_location;
      else
        out_rec.location:=null;
      end if;
  --
      if asg_rec.person_referred_by_id is not null then
        open csr_full_name(asg_rec.person_referred_by_id,p_effective_date);
        fetch csr_full_name into out_rec.person_referred_by;
        close csr_full_name;
      else
        out_rec.person_referred_by:=null;
      end if;
  --
      if asg_rec.supervisor_id is not null then
        open csr_full_name(asg_rec.supervisor_id,p_effective_date);
        fetch csr_full_name into out_rec.supervisor;
        close csr_full_name;
      else
        out_rec.supervisor:=null;
      end if;
  --
      if asg_rec.supervisor_assignment_id is not null then

hr_utility.set_location('super_assgt_id is not null',990);
hr_utility.set_location('super assgt id is ' || to_char(asg_rec.supervisor_assignment_id),990);
        open csr_supervisor_assgt_number(asg_rec.supervisor_assignment_id,p_effective_date);
        fetch csr_supervisor_assgt_number into out_rec.supervisor_assignment_number;
hr_utility.set_location('super_assgt_number is '|| out_rec.supervisor_assignment_number,991);
        close csr_supervisor_assgt_number;
      else
        out_rec.supervisor_assignment_number:=null;
hr_utility.set_location('set super_assgt_id to null',992);
      end if;
  --
      if asg_rec.recruitment_activity_id is not null then
        open csr_rec_activity(asg_rec.recruitment_activity_id);
        fetch csr_rec_activity into out_rec.recruitment_activity;
        close csr_rec_activity;
      else
        out_rec.recruitment_activity:=null;
      end if;
  --
      if asg_rec.source_organization_id is not null then
        open csr_organization(asg_rec.source_organization_id);
        fetch csr_organization into out_rec.source_organization;
        close csr_organization;
      else
        out_rec.source_organization:=null;
      end if;
  --
      open csr_organization(asg_rec.organization_id);
      fetch csr_organization into out_rec.organization;
      close csr_organization;
  --
      if asg_rec.people_group_id is not null then
        open csr_pgp_rec(asg_rec.people_group_id);
        fetch csr_pgp_rec into pgp_rec;
        close csr_pgp_rec;
  --
        out_rec.pgp_segment1                :=pgp_rec.segment1;
        out_rec.pgp_segment2                :=pgp_rec.segment2;
        out_rec.pgp_segment3                :=pgp_rec.segment3;
        out_rec.pgp_segment4                :=pgp_rec.segment4;
        out_rec.pgp_segment5                :=pgp_rec.segment5;
        out_rec.pgp_segment6                :=pgp_rec.segment6;
        out_rec.pgp_segment7                :=pgp_rec.segment7;
        out_rec.pgp_segment8                :=pgp_rec.segment9;
        out_rec.pgp_segment9                :=pgp_rec.segment9;
        out_rec.pgp_segment10               :=pgp_rec.segment10;
        out_rec.pgp_segment11               :=pgp_rec.segment11;
        out_rec.pgp_segment12               :=pgp_rec.segment12;
        out_rec.pgp_segment13               :=pgp_rec.segment13;
        out_rec.pgp_segment14               :=pgp_rec.segment14;
        out_rec.pgp_segment15               :=pgp_rec.segment15;
        out_rec.pgp_segment16               :=pgp_rec.segment16;
        out_rec.pgp_segment17               :=pgp_rec.segment17;
        out_rec.pgp_segment18               :=pgp_rec.segment18;
        out_rec.pgp_segment19               :=pgp_rec.segment19;
        out_rec.pgp_segment20               :=pgp_rec.segment20;
        out_rec.pgp_segment21               :=pgp_rec.segment21;
        out_rec.pgp_segment22               :=pgp_rec.segment22;
        out_rec.pgp_segment23               :=pgp_rec.segment23;
        out_rec.pgp_segment24               :=pgp_rec.segment24;
        out_rec.pgp_segment25               :=pgp_rec.segment25;
        out_rec.pgp_segment26               :=pgp_rec.segment26;
        out_rec.pgp_segment27               :=pgp_rec.segment27;
        out_rec.pgp_segment28               :=pgp_rec.segment28;
        out_rec.pgp_segment29               :=pgp_rec.segment29;
        out_rec.pgp_segment30               :=pgp_rec.segment30;
      end if;
  --
      if asg_rec.soft_coding_keyflex_id is not null then
        open csr_scl_rec(asg_rec.soft_coding_keyflex_id);
        fetch csr_scl_rec into scl_rec;
        close csr_scl_rec;

        out_rec.scl_segment1                :=scl_rec.segment1;
        out_rec.scl_segment2                :=scl_rec.segment2;
        out_rec.scl_segment3                :=scl_rec.segment3;
        out_rec.scl_segment4                :=scl_rec.segment4;
        out_rec.scl_segment5                :=scl_rec.segment5;
        out_rec.scl_segment6                :=scl_rec.segment6;
        out_rec.scl_segment7                :=scl_rec.segment7;
        out_rec.scl_segment8                :=scl_rec.segment8;
        out_rec.scl_segment9                :=scl_rec.segment9;
        out_rec.scl_segment10               :=scl_rec.segment10;
        out_rec.scl_segment11               :=scl_rec.segment11;
        out_rec.scl_segment12               :=scl_rec.segment12;
        out_rec.scl_segment13               :=scl_rec.segment13;
        out_rec.scl_segment14               :=scl_rec.segment14;
        out_rec.scl_segment15               :=scl_rec.segment15;
        out_rec.scl_segment16               :=scl_rec.segment16;
        out_rec.scl_segment17               :=scl_rec.segment17;
        out_rec.scl_segment18               :=scl_rec.segment18;
        out_rec.scl_segment19               :=scl_rec.segment19;
        out_rec.scl_segment20               :=scl_rec.segment20;
        out_rec.scl_segment21               :=scl_rec.segment21;
        out_rec.scl_segment22               :=scl_rec.segment22;
        out_rec.scl_segment23               :=scl_rec.segment23;
        out_rec.scl_segment24               :=scl_rec.segment24;
        out_rec.scl_segment25               :=scl_rec.segment25;
        out_rec.scl_segment26               :=scl_rec.segment26;
        out_rec.scl_segment27               :=scl_rec.segment27;
        out_rec.scl_segment28               :=scl_rec.segment28;
        out_rec.scl_segment29               :=scl_rec.segment29;
        out_rec.scl_segment30               :=scl_rec.segment30;
      end if;
  --
      if asg_rec.vacancy_id is not null then
        open csr_vacancy(asg_rec.vacancy_id);
        fetch csr_vacancy into out_rec.vacancy,out_rec.requisition;
        close csr_vacancy;
      else
        out_rec.vacancy:=null;
        out_rec.requisition:=null;
      end if;
  --

      if asg_rec.pay_basis_id is not null then
        open csr_pay_basis(asg_rec.pay_basis_id);
        fetch csr_pay_basis into out_rec.salary_basis,out_rec.pay_basis;
        close csr_pay_basis;
      else
        out_rec.salary_basis:=null;
        out_rec.pay_basis:=null;
      end if;
  --
      out_rec.assignment_sequence           :=asg_rec.assignment_sequence;
      out_rec.assignment_type               :=asg_rec.assignment_type;
      out_rec.asg_primary_flag              :=asg_rec.primary_flag;
      out_rec.assignment_number             :=asg_rec.assignment_number;
      out_rec.date_probation_end            :=asg_rec.date_probation_end;
      out_rec.default_code_comb_id          :=asg_rec.default_code_comb_id;
      out_rec.employment_category_meaning   :=hr_reports.get_lookup_meaning('EMP_CAT',asg_rec.employment_category);
      out_rec.frequency_meaning             :=hr_reports.get_lookup_meaning('FREQUENCY',asg_rec.frequency);
      out_rec.normal_hours                  :=asg_rec.normal_hours;
      out_rec.probation_period              :=asg_rec.probation_period;
      out_rec.probation_unit_meaning        :=hr_reports.get_lookup_meaning('QUALIFYING_UNITS',asg_rec.probation_unit);
      out_rec.time_normal_finish            :=asg_rec.time_normal_finish;
      out_rec.time_normal_start             :=asg_rec.time_normal_start;
--CWK
      out_rec.project_title                 :=asg_rec.project_title;
      out_rec.vendor_employee_number        :=asg_rec.vendor_employee_number;
      out_rec.vendor_assignment_number      :=asg_rec.vendor_assignment_number;
--
      if asg_rec.vendor_id is not null then
        open csr_vendor(asg_rec.vendor_id);
        fetch csr_vendor into out_rec.vendor_name;
        close csr_vendor;
      else
        out_rec.vendor_name:=null;
      end if;
--
      if asg_rec.vendor_site_id is not null then
        open csr_vendor_site(asg_rec.vendor_id);
        fetch csr_vendor_site into out_rec.vendor_site_code;
        close csr_vendor_site;
      else
        out_rec.vendor_site_code:=null;
      end if;
--
      if asg_rec.po_header_id is not null then
        open csr_po_header(asg_rec.po_header_id);
        fetch csr_po_header into out_rec.po_header_num;
        close csr_po_header;
      else
        out_rec.po_header_num:=null;
      end if;
--
      if asg_rec.po_line_id is not null then
        open csr_po_line(asg_rec.po_line_id);
        fetch csr_po_line into out_rec.po_line_num;
        close csr_po_line;
      else
        out_rec.po_line_num:=null;
      end if;
--
/*    These fields are no longer used because they may change
      context on a row by row basis, making them meaningless in a table

      out_rec.ass_attribute_category        :=asg_rec.ass_attribute_category;
      out_rec.ass_attribute1                :=asg_rec.ass_attribute1;
      out_rec.ass_attribute2                :=asg_rec.ass_attribute2;
      out_rec.ass_attribute3                :=asg_rec.ass_attribute3;
      out_rec.ass_attribute4                :=asg_rec.ass_attribute4;
      out_rec.ass_attribute5                :=asg_rec.ass_attribute5;
      out_rec.ass_attribute6                :=asg_rec.ass_attribute6;
      out_rec.ass_attribute7                :=asg_rec.ass_attribute7;
      out_rec.ass_attribute8                :=asg_rec.ass_attribute8;
      out_rec.ass_attribute9                :=asg_rec.ass_attribute9;
      out_rec.ass_attribute10               :=asg_rec.ass_attribute10;
      out_rec.ass_attribute11               :=asg_rec.ass_attribute11;
      out_rec.ass_attribute12               :=asg_rec.ass_attribute12;
      out_rec.ass_attribute13               :=asg_rec.ass_attribute13;
      out_rec.ass_attribute14               :=asg_rec.ass_attribute14;
      out_rec.ass_attribute15               :=asg_rec.ass_attribute15;
      out_rec.ass_attribute16               :=asg_rec.ass_attribute16;
      out_rec.ass_attribute17               :=asg_rec.ass_attribute17;
      out_rec.ass_attribute18               :=asg_rec.ass_attribute18;
      out_rec.ass_attribute19               :=asg_rec.ass_attribute19;
      out_rec.ass_attribute20               :=asg_rec.ass_attribute20;
      out_rec.ass_attribute21               :=asg_rec.ass_attribute21;
      out_rec.ass_attribute22               :=asg_rec.ass_attribute22;
      out_rec.ass_attribute23               :=asg_rec.ass_attribute23;
      out_rec.ass_attribute24               :=asg_rec.ass_attribute24;
      out_rec.ass_attribute25               :=asg_rec.ass_attribute25;
      out_rec.ass_attribute26               :=asg_rec.ass_attribute26;
      out_rec.ass_attribute27               :=asg_rec.ass_attribute27;
      out_rec.ass_attribute28               :=asg_rec.ass_attribute28;
      out_rec.ass_attribute29               :=asg_rec.ass_attribute29;
      out_rec.ass_attribute30               :=asg_rec.ass_attribute30;
*/

      out_rec.bargaining_unit_code_meaning  :=hr_reports.get_lookup_meaning('BARGAINING_UNIT_CODE',asg_rec.bargaining_unit_code);
      out_rec.labour_union_member_flag      :=asg_rec.labour_union_member_flag;
      out_rec.hourly_salaried_meaning       :=hr_reports.get_lookup_meaning('HOURLY_SALARIED_CODE',asg_rec.hourly_salaried_code);
  --
      if asg_rec.special_ceiling_step_id is not null then
        open csr_ceiling_step(asg_rec.special_ceiling_step_id,p_effective_date);
        fetch csr_ceiling_step into out_rec.special_ceiling_point, out_rec.special_ceiling_step;
        close csr_ceiling_step;
      else
        out_rec.special_ceiling_point:=null;
        out_rec.special_ceiling_step:=null;
      end if;
  --
      out_rec.change_reason_meaning         :=hr_reports.get_lookup_meaning('APL_ASSIGN_REASON',asg_rec.change_reason);
      out_rec.internal_address_line         :=asg_rec.internal_address_line;
      out_rec.manager_flag                  :=asg_rec.manager_flag;
      out_rec.perf_review_period            :=asg_rec.perf_review_period;
      out_rec.perf_rev_period_freq_meaning  :=hr_reports.get_lookup_meaning('FREQUENCY',asg_rec.perf_review_period_frequency);
      out_rec.sal_review_period             :=asg_rec.sal_review_period;
      out_rec.sal_rev_period_freq_meaning   :=hr_reports.get_lookup_meaning('FREQUENCY',asg_rec.sal_review_period_frequency);
      out_rec.source_type_meaning           :=hr_reports.get_lookup_meaning('REC_TYPE',asg_rec.source_type);
  --
      if asg_rec.contract_id is not null then
        open csr_reference(asg_rec.contract_id,p_effective_date);
        fetch csr_reference into out_rec.contract;
        close csr_reference;
      else
        out_rec.contract:=null;
      end if;
  --
      if asg_rec.collective_agreement_id is not null then
        open csr_collective_agr(asg_rec.collective_agreement_id);
        fetch csr_collective_agr into out_rec.collective_agreement;
        close csr_collective_agr;
      else
        out_rec.collective_agreement:=null;
      end if;
  --
      if asg_rec.cagr_id_flex_num is not null then
        open csr_cagr_flex_num(asg_rec.cagr_id_flex_num);
        fetch csr_cagr_flex_num into out_rec.cagr_id_flex_name;
        close csr_cagr_flex_num;
      else
        out_rec.cagr_id_flex_name:=null;
      end if;
  --
      if asg_rec.establishment_id is not null then
        open csr_organization(asg_rec.establishment_id);
        fetch csr_organization into out_rec.establishment;
        close csr_organization;
      else
        out_rec.establishment:=null;
      end if;
    else
      if l_num_asgs=0 then
        l_other:=null;
      else
        l_other:='****';
      end if;
      hr_utility.set_location(l_proc,100);
      out_rec.assignment_id                 :=null;
      out_rec.asg_effective_start_date      :=null;
      out_rec.asg_effective_end_date        :=null;
      out_rec.recruiter                     :=l_other;
      out_rec.grade                         :=l_other;
      out_rec.grade_ladder                  :=l_other;
      out_rec.position                      :=l_other;
      out_rec.job                           :=l_other;
      out_rec.assignment_status_type        :=l_other;
      out_rec.system_status                 :=l_other;
      out_rec.payroll                       :=l_other;
      out_rec.location                      :=l_other;
      out_rec.person_referred_by            :=l_other;
      out_rec.supervisor                    :=l_other;
      out_rec.supervisor_assignment_number  :=l_other;
      out_rec.recruitment_activity          :=l_other;
      out_rec.source_organization           :=l_other;
      out_rec.organization                  :=l_other;
      out_rec.pgp_segment1                  :=l_other;
      out_rec.pgp_segment1_v                :=l_other;
      out_rec.pgp_segment1_m                :=l_other;
      out_rec.pgp_segment2                  :=l_other;
      out_rec.pgp_segment2_v                :=l_other;
      out_rec.pgp_segment2_m                :=l_other;
      out_rec.pgp_segment3                  :=l_other;
      out_rec.pgp_segment3_v                :=l_other;
      out_rec.pgp_segment3_m                :=l_other;
      out_rec.pgp_segment4                  :=l_other;
      out_rec.pgp_segment4_v                :=l_other;
      out_rec.pgp_segment4_m                :=l_other;
      out_rec.pgp_segment5                  :=l_other;
      out_rec.pgp_segment5_v                :=l_other;
      out_rec.pgp_segment5_m                :=l_other;
      out_rec.pgp_segment6                  :=l_other;
      out_rec.pgp_segment6_v                :=l_other;
      out_rec.pgp_segment6_m                :=l_other;
      out_rec.pgp_segment7                  :=l_other;
      out_rec.pgp_segment7_v                :=l_other;
      out_rec.pgp_segment7_m                :=l_other;
      out_rec.pgp_segment8                  :=l_other;
      out_rec.pgp_segment8_v                :=l_other;
      out_rec.pgp_segment8_m                :=l_other;
      out_rec.pgp_segment9                  :=l_other;
      out_rec.pgp_segment9_v                :=l_other;
      out_rec.pgp_segment9_m                :=l_other;
      out_rec.pgp_segment10                 :=l_other;
      out_rec.pgp_segment10_v               :=l_other;
      out_rec.pgp_segment10_m               :=l_other;
      out_rec.pgp_segment11                 :=l_other;
      out_rec.pgp_segment11_v               :=l_other;
      out_rec.pgp_segment11_m               :=l_other;
      out_rec.pgp_segment12                 :=l_other;
      out_rec.pgp_segment12_v               :=l_other;
      out_rec.pgp_segment12_m               :=l_other;
      out_rec.pgp_segment13                 :=l_other;
      out_rec.pgp_segment13_v               :=l_other;
      out_rec.pgp_segment13_m               :=l_other;
      out_rec.pgp_segment14                 :=l_other;
      out_rec.pgp_segment14_v               :=l_other;
      out_rec.pgp_segment14_m               :=l_other;
      out_rec.pgp_segment15                 :=l_other;
      out_rec.pgp_segment15_v               :=l_other;
      out_rec.pgp_segment15_m               :=l_other;
      out_rec.pgp_segment16                 :=l_other;
      out_rec.pgp_segment16_v               :=l_other;
      out_rec.pgp_segment16_m               :=l_other;
      out_rec.pgp_segment17                 :=l_other;
      out_rec.pgp_segment17_v               :=l_other;
      out_rec.pgp_segment17_m               :=l_other;
      out_rec.pgp_segment18                 :=l_other;
      out_rec.pgp_segment18_v               :=l_other;
      out_rec.pgp_segment18_m               :=l_other;
      out_rec.pgp_segment19                 :=l_other;
      out_rec.pgp_segment19_v               :=l_other;
      out_rec.pgp_segment19_m               :=l_other;
      out_rec.pgp_segment20                 :=l_other;
      out_rec.pgp_segment20_v               :=l_other;
      out_rec.pgp_segment20_m               :=l_other;
      out_rec.pgp_segment21                 :=l_other;
      out_rec.pgp_segment21_v               :=l_other;
      out_rec.pgp_segment21_m               :=l_other;
      out_rec.pgp_segment22                 :=l_other;
      out_rec.pgp_segment22_v               :=l_other;
      out_rec.pgp_segment22_m               :=l_other;
      out_rec.pgp_segment23                 :=l_other;
      out_rec.pgp_segment23_v               :=l_other;
      out_rec.pgp_segment23_m               :=l_other;
      out_rec.pgp_segment24                 :=l_other;
      out_rec.pgp_segment24_v               :=l_other;
      out_rec.pgp_segment24_m               :=l_other;
      out_rec.pgp_segment25                 :=l_other;
      out_rec.pgp_segment25_v               :=l_other;
      out_rec.pgp_segment25_m               :=l_other;
      out_rec.pgp_segment26                 :=l_other;
      out_rec.pgp_segment26_v               :=l_other;
      out_rec.pgp_segment26_m               :=l_other;
      out_rec.pgp_segment27                 :=l_other;
      out_rec.pgp_segment27_v               :=l_other;
      out_rec.pgp_segment27_m               :=l_other;
      out_rec.pgp_segment28                 :=l_other;
      out_rec.pgp_segment28_v               :=l_other;
      out_rec.pgp_segment28_m               :=l_other;
      out_rec.pgp_segment29                 :=l_other;
      out_rec.pgp_segment29_v               :=l_other;
      out_rec.pgp_segment29_m               :=l_other;
      out_rec.pgp_segment30                 :=l_other;
      out_rec.pgp_segment30_v               :=l_other;
      out_rec.pgp_segment30_m               :=l_other;
      hr_utility.set_location(l_proc,110);
      out_rec.people_group_id               :=null;
      out_rec.scl_segment1                  :=l_other;
      out_rec.scl_segment1_v                :=l_other;
      out_rec.scl_segment1_m                :=l_other;
      out_rec.scl_segment2                  :=l_other;
      out_rec.scl_segment2_v                :=l_other;
      out_rec.scl_segment2_m                :=l_other;
      out_rec.scl_segment3                  :=l_other;
      out_rec.scl_segment3_v                :=l_other;
      out_rec.scl_segment3_m                :=l_other;
      out_rec.scl_segment4                  :=l_other;
      out_rec.scl_segment4_v                :=l_other;
      out_rec.scl_segment4_m                :=l_other;
      out_rec.scl_segment5                  :=l_other;
      out_rec.scl_segment5_v                :=l_other;
      out_rec.scl_segment5_m                :=l_other;
      out_rec.scl_segment6                  :=l_other;
      out_rec.scl_segment6_v                :=l_other;
      out_rec.scl_segment6_m                :=l_other;
      out_rec.scl_segment7                  :=l_other;
      out_rec.scl_segment7_v                :=l_other;
      out_rec.scl_segment7_m                :=l_other;
      out_rec.scl_segment8                  :=l_other;
      out_rec.scl_segment8_v                :=l_other;
      out_rec.scl_segment8_m                :=l_other;
      out_rec.scl_segment9                  :=l_other;
      out_rec.scl_segment9_v                :=l_other;
      out_rec.scl_segment9_m                :=l_other;
      out_rec.scl_segment10                 :=l_other;
      out_rec.scl_segment10_v               :=l_other;
      out_rec.scl_segment10_m               :=l_other;
      out_rec.scl_segment11                 :=l_other;
      out_rec.scl_segment11_v               :=l_other;
      out_rec.scl_segment11_m               :=l_other;
      out_rec.scl_segment12                 :=l_other;
      out_rec.scl_segment12_v               :=l_other;
      out_rec.scl_segment12_m               :=l_other;
      out_rec.scl_segment13                 :=l_other;
      out_rec.scl_segment13_v               :=l_other;
      out_rec.scl_segment13_m               :=l_other;
      out_rec.scl_segment14                 :=l_other;
      out_rec.scl_segment14_v               :=l_other;
      out_rec.scl_segment14_m               :=l_other;
      out_rec.scl_segment15                 :=l_other;
      out_rec.scl_segment15_v               :=l_other;
      out_rec.scl_segment15_m               :=l_other;
      out_rec.scl_segment16                 :=l_other;
      out_rec.scl_segment16_v               :=l_other;
      out_rec.scl_segment16_m               :=l_other;
      out_rec.scl_segment17                 :=l_other;
      out_rec.scl_segment17_v               :=l_other;
      out_rec.scl_segment17_m               :=l_other;
      out_rec.scl_segment18                 :=l_other;
      out_rec.scl_segment18_v               :=l_other;
      out_rec.scl_segment18_m               :=l_other;
      out_rec.scl_segment19                 :=l_other;
      out_rec.scl_segment19_v               :=l_other;
      out_rec.scl_segment19_m               :=l_other;
      out_rec.scl_segment20                 :=l_other;
      out_rec.scl_segment20_v               :=l_other;
      out_rec.scl_segment20_m               :=l_other;
      out_rec.scl_segment21                 :=l_other;
      out_rec.scl_segment21_v               :=l_other;
      out_rec.scl_segment21_m               :=l_other;
      out_rec.scl_segment22                 :=l_other;
      out_rec.scl_segment22_v               :=l_other;
      out_rec.scl_segment22_m               :=l_other;
      out_rec.scl_segment23                 :=l_other;
      out_rec.scl_segment23_v               :=l_other;
      out_rec.scl_segment23_m               :=l_other;
      out_rec.scl_segment24                 :=l_other;
      out_rec.scl_segment24_v               :=l_other;
      out_rec.scl_segment24_m               :=l_other;
      out_rec.scl_segment25                 :=l_other;
      out_rec.scl_segment25_v               :=l_other;
      out_rec.scl_segment25_m               :=l_other;
      out_rec.scl_segment26                 :=l_other;
      out_rec.scl_segment26_v               :=l_other;
      out_rec.scl_segment26_m               :=l_other;
      out_rec.scl_segment27                 :=l_other;
      out_rec.scl_segment27_v               :=l_other;
      out_rec.scl_segment27_m               :=l_other;
      out_rec.scl_segment28                 :=l_other;
      out_rec.scl_segment28_v               :=l_other;
      out_rec.scl_segment28_m               :=l_other;
      out_rec.scl_segment29                 :=l_other;
      out_rec.scl_segment29_v               :=l_other;
      out_rec.scl_segment29_m               :=l_other;
      out_rec.scl_segment30                 :=l_other;
      out_rec.scl_segment30_v               :=l_other;
      out_rec.scl_segment30_m               :=l_other;
      out_rec.soft_coding_keyflex_id        :=null;
      hr_utility.set_location(l_proc,120);
      out_rec.vacancy                       :=l_other;
      out_rec.requisition                   :=l_other;
      out_rec.salary_basis                  :=l_other;
      out_rec.pay_basis                     :=l_other;
      out_rec.assignment_sequence           :=null;
      out_rec.assignment_type               :=null;
      out_rec.asg_primary_flag              :=l_other;
      out_rec.assignment_number             :=l_other;
      out_rec.date_probation_end            :=null;
      out_rec.default_code_comb_id          :=null;
      out_rec.employment_category_meaning   :=l_other;
      out_rec.frequency_meaning             :=l_other;
      out_rec.normal_hours                  :=null;
      out_rec.probation_period              :=null;
      out_rec.probation_unit_meaning        :=l_other;
      out_rec.time_normal_finish            :=l_other;
      out_rec.time_normal_start             :=l_other;
--CWK
      out_rec.project_title                 :=l_other;
      out_rec.vendor_name                   :=l_other;
      out_rec.vendor_employee_number        :=l_other;
      out_rec.vendor_assignment_number      :=l_other;
      out_rec.vendor_site_code              :=l_other;
      out_rec.po_header_num                 :=l_other;
      out_rec.po_line_num                   :=null;
--
/*    These fields are no longer used because they may change
      context on a row by row basis, making them meaningless in a table

      out_rec.ass_attribute_category        :=l_other;
      out_rec.ass_attribute1                :=l_other;
      out_rec.ass_attribute1_v              :=l_other;
      out_rec.ass_attribute1_m              :=l_other;
      out_rec.ass_attribute2                :=l_other;
      out_rec.ass_attribute2_v              :=l_other;
      out_rec.ass_attribute2_m              :=l_other;
      out_rec.ass_attribute3                :=l_other;
      out_rec.ass_attribute3_v              :=l_other;
      out_rec.ass_attribute3_m              :=l_other;
      out_rec.ass_attribute4                :=l_other;
      out_rec.ass_attribute4_v              :=l_other;
      out_rec.ass_attribute4_m              :=l_other;
      out_rec.ass_attribute5                :=l_other;
      out_rec.ass_attribute5_v              :=l_other;
      out_rec.ass_attribute5_m              :=l_other;
      out_rec.ass_attribute6                :=l_other;
      out_rec.ass_attribute6_v              :=l_other;
      out_rec.ass_attribute6_m              :=l_other;
      out_rec.ass_attribute7                :=l_other;
      out_rec.ass_attribute7_v              :=l_other;
      out_rec.ass_attribute7_m              :=l_other;
      out_rec.ass_attribute8                :=l_other;
      out_rec.ass_attribute8_v              :=l_other;
      out_rec.ass_attribute8_m              :=l_other;
      out_rec.ass_attribute9                :=l_other;
      out_rec.ass_attribute9_v              :=l_other;
      out_rec.ass_attribute9_m              :=l_other;
      out_rec.ass_attribute10               :=l_other;
      out_rec.ass_attribute10_v             :=l_other;
      out_rec.ass_attribute10_m             :=l_other;
      out_rec.ass_attribute11               :=l_other;
      out_rec.ass_attribute11_v             :=l_other;
      out_rec.ass_attribute11_m             :=l_other;
      out_rec.ass_attribute12               :=l_other;
      out_rec.ass_attribute12_v             :=l_other;
      out_rec.ass_attribute12_m             :=l_other;
      out_rec.ass_attribute13               :=l_other;
      out_rec.ass_attribute13_v             :=l_other;
      out_rec.ass_attribute13_m             :=l_other;
      out_rec.ass_attribute14               :=l_other;
      out_rec.ass_attribute14_v             :=l_other;
      out_rec.ass_attribute14_m             :=l_other;
      out_rec.ass_attribute15               :=l_other;
      out_rec.ass_attribute15_v             :=l_other;
      out_rec.ass_attribute15_m             :=l_other;
      out_rec.ass_attribute16               :=l_other;
      out_rec.ass_attribute16_v             :=l_other;
      out_rec.ass_attribute16_m             :=l_other;
      out_rec.ass_attribute17               :=l_other;
      out_rec.ass_attribute17_v             :=l_other;
      out_rec.ass_attribute17_m             :=l_other;
      out_rec.ass_attribute18               :=l_other;
      out_rec.ass_attribute18_v             :=l_other;
      out_rec.ass_attribute18_m             :=l_other;
      out_rec.ass_attribute19               :=l_other;
      out_rec.ass_attribute19_v             :=l_other;
      out_rec.ass_attribute19_m             :=l_other;
      out_rec.ass_attribute20               :=l_other;
      out_rec.ass_attribute20_v             :=l_other;
      out_rec.ass_attribute20_m             :=l_other;
      out_rec.ass_attribute21               :=l_other;
      out_rec.ass_attribute21_v             :=l_other;
      out_rec.ass_attribute21_m             :=l_other;
      out_rec.ass_attribute22               :=l_other;
      out_rec.ass_attribute22_v             :=l_other;
      out_rec.ass_attribute22_m             :=l_other;
      out_rec.ass_attribute23               :=l_other;
      out_rec.ass_attribute23_v             :=l_other;
      out_rec.ass_attribute23_m             :=l_other;
      out_rec.ass_attribute24               :=l_other;
      out_rec.ass_attribute24_v             :=l_other;
      out_rec.ass_attribute24_m             :=l_other;
      out_rec.ass_attribute25               :=l_other;
      out_rec.ass_attribute25_v             :=l_other;
      out_rec.ass_attribute25_m             :=l_other;
      out_rec.ass_attribute26               :=l_other;
      out_rec.ass_attribute26_v             :=l_other;
      out_rec.ass_attribute26_m             :=l_other;
      out_rec.ass_attribute27               :=l_other;
      out_rec.ass_attribute27_v             :=l_other;
      out_rec.ass_attribute27_m             :=l_other;
      out_rec.ass_attribute28               :=l_other;
      out_rec.ass_attribute28_v             :=l_other;
      out_rec.ass_attribute28_m             :=l_other;
      out_rec.ass_attribute29               :=l_other;
      out_rec.ass_attribute29_v             :=l_other;
      out_rec.ass_attribute29_m             :=l_other;
      out_rec.ass_attribute30               :=l_other;
      out_rec.ass_attribute30_v             :=l_other;
      out_rec.ass_attribute30_m             :=l_other;
*/
      hr_utility.set_location(l_proc,130);
      out_rec.bargaining_unit_code_meaning  :=l_other;
      out_rec.labour_union_member_flag      :=l_other;
      out_rec.hourly_salaried_meaning       :=l_other;
      out_rec.special_ceiling_step          :=null;
      out_rec.special_ceiling_point         :=l_other;
      out_rec.change_reason_meaning         :=l_other;
      out_rec.internal_address_line         :=l_other;
      out_rec.manager_flag                  :=l_other;
      out_rec.perf_review_period            :=null;
      out_rec.perf_rev_period_freq_meaning  :=l_other;
      out_rec.sal_review_period             :=null;
      out_rec.sal_rev_period_freq_meaning   :=l_other;
      out_rec.source_type_meaning           :=l_other;
      out_rec.contract                      :=l_other;
      out_rec.collective_agreement          :=l_other;
      out_rec.cagr_id_flex_name             :=l_other;
      out_rec.cagr_grade                    :=null;
      out_rec.establishment                 :=l_other;
      hr_utility.set_location(l_proc,140);
      --
    end if;
  end if;
  resultset(num_row):=out_rec;
end loop;

  hr_utility.set_location('Leaving: '||l_proc||num_row,1000);
close emp_cv;
--
end findquery;
--
--
  procedure insert_varchar2(p_query_id number
                           ,p_field varchar2
                           ,p_value varchar2
                           ) is
  begin
    insert into per_query_criteria
    (query_id
    ,field
    ,field_type
    ,varchar2_value
    ,number_value
    ,date_value
    ,object_version_number)
    values
    (p_query_id
    ,p_field
    ,'V'
    ,replace(p_value,g_quote,g_quote||g_quote)
    ,null
    ,null
    ,1);
  end insert_varchar2;
--
  procedure insert_number  (p_query_id number
                           ,p_field varchar2
                           ,p_value number
                           ) is
  begin
    insert into per_query_criteria
    (query_id
    ,field
    ,field_type
    ,varchar2_value
    ,number_value
    ,date_value
    ,object_version_number)
    values
    (p_query_id
    ,p_field
    ,'N'
    ,null
    ,p_value
    ,null
    ,1);
  end insert_number;
--
  procedure insert_date    (p_query_id number
                           ,p_field varchar2
                           ,p_value date
                           ) is
  begin
    insert into per_query_criteria
    (query_id
    ,field
    ,field_type
    ,varchar2_value
    ,number_value
    ,date_value
    ,object_version_number)
    values
    (p_query_id
    ,p_field
    ,'D'
    ,null
    ,null
    ,p_value
    ,1);
  end insert_date;
--
procedure findsave(
 query_id                      in     number
,business_group_id             in     per_all_people_f.business_group_id%type
,business_group_name           in     per_business_groups.name%type
,person_id                     in     per_all_people_f.person_id%type default null
,person_type                   in     per_person_types.user_person_type%type default null
,system_person_type            in     per_person_types.system_person_type%type  default null
,person_type_id                in     per_all_people_f.person_type_id%type default null
,last_name                     in     per_all_people_f.last_name%type default null
,start_date                    in     per_all_people_f.start_date%type default null
,hire_date                     in     per_periods_of_service.date_start%type default null
,applicant_number              in     per_all_people_f.applicant_number%type default null
,date_of_birth                 in     per_all_people_f.date_of_birth%type default null
,email_address                 in     per_all_people_f.email_address%type default null
,employee_number               in     per_all_people_f.employee_number%type default null
--CWK
,npw_number                    in     per_all_people_f.npw_number%type default null
,project_title                 in     per_all_assignments_f.project_title%type default null
,vendor_id                     in     per_all_assignments_f.vendor_id%type default null
,vendor_name                   in     po_vendors.vendor_name%type default null
,vendor_employee_number        in  per_all_assignments_f.vendor_employee_number%type default null
,vendor_assignment_number      in  per_all_assignments_f.vendor_assignment_number%type default null
,vendor_site_code              in  po_vendor_sites_all.vendor_site_code%TYPE default null
,vendor_site_id                in   po_vendor_sites_all.vendor_site_id%TYPE default null
,po_header_num                 in   po_headers_all.segment1%TYPE default null
,po_header_id                  in   po_headers_all.po_header_id%TYPE default null
,po_line_num                   in   po_lines_all.line_num%TYPE default null
,po_line_id                    in   po_lines_all.po_line_id%TYPE default null
--
,first_name                    in     per_all_people_f.first_name%type default null
,full_name                     in     per_all_people_f.full_name%type default null
,title                         in     per_all_people_f.title%type
,middle_names                  in     per_all_people_f.middle_names%type
,nationality_meaning           in     hr_lookups.meaning%type default null
,nationality                   in     per_all_people_f.nationality%type default null
,national_identifier           in     per_all_people_f.national_identifier%type default null
-- Bug 3037019 Start Here
,registered_disabled_flag      in     hr_lookups.meaning%type default null
,registered_disabled           in     per_all_people_f.registered_disabled_flag%type default null
,sex_meaning                   in     hr_lookups.meaning%type default null
,sex                           in     per_all_people_f.sex%type default null
,benefit_group                 in     ben_benfts_grp.name%type default null
,benefit_group_id              in     per_all_people_f.benefit_group_id%type default null
,grade                         in     per_grades.name%type default null
,grade_id                      in     per_all_assignments_f.grade_id%type default null
,grade_ladder                  in     ben_pgm_f.name%type default null
,grade_ladder_pgm_id           in     per_all_assignments_f.grade_ladder_pgm_id%type default null
,position                      in     hr_all_positions_f.name%type default null
,position_id                   in     per_all_assignments_f.position_id%type default null
,job                           in     per_jobs.name%type default null
,job_id                        in     per_all_assignments_f.job_id%type default null
,assignment_status_type        in     per_assignment_status_types.user_status%type default null
,assignment_status_type_id     in     per_all_assignments_f.assignment_status_type_id%type default null
,payroll                       in     pay_all_payrolls_f.payroll_name%type default null
,payroll_id                    in     per_all_assignments_f.payroll_id%type default null
,location                      in     hr_locations.location_code%type default null
,location_id                   in     per_all_assignments_f.location_id%type default null
,supervisor                    in     per_all_people_f.full_name%type default null
,supervisor_id                 in     per_all_assignments_f.supervisor_id%type default null
,supervisor_assignment_number  in     per_assignments_v.supervisor_assignment_number%type default null
,supervisor_assignment_id      in     per_all_assignments_f.supervisor_assignment_id%type default null
,recruitment_activity          in     per_recruitment_activities.name%type default null
,recruitment_activity_id       in     per_all_assignments_f.recruitment_activity_id%type default null
,organization                  in     hr_all_organization_units.name%type default null
,organization_id               in     per_all_assignments_f.organization_id%type default null
,people_group                  in     pay_people_groups.group_name%type default null
,people_group_id               in     per_all_assignments_f.people_group_id%type default null
,vacancy                       in     per_vacancies.name%type default null
,vacancy_id                    in     per_all_assignments_f.vacancy_id%type default null
,requisition                   in     per_requisitions.name%type default null
,requisition_id                in     per_requisitions.requisition_id%type default null
,salary_basis                  in     per_pay_bases.name%type default null
,pay_basis_id                  in     per_all_assignments_f.pay_basis_id%type default null
,bargaining_unit_code_meaning  in     hr_lookups.meaning%type default null
,bargaining_unit_code          in     per_all_assignments_f.bargaining_unit_code%type default null
,employment_category_meaning   in     hr_lookups.meaning%type default null
,employment_category           in     per_all_assignments_f.employment_category%type default null
--bug 3002915 starts here.  modified the type.
,establishment                 in     hr_leg_establishments_v.name%type default null
,establishment_id              in     hr_leg_establishments_v.organization_id%type default null
--bug 3002915 ends here.
,projected_hire_date           in     per_applications.projected_hire_date%type default null
,secure                        in     varchar2 default null
,field1_name                   in     varchar2 default null
,field1_condition_code         in     varchar2 default null
,field1_value                  in     varchar2 default null
,field2_name                   in     varchar2 default null
,field2_condition_code         in     varchar2 default null
,field2_value                  in     varchar2 default null
,field3_name                   in     varchar2 default null
,field3_condition_code         in     varchar2 default null
,field3_value                  in     varchar2 default null
,field4_name                   in     varchar2 default null
,field4_condition_code         in     varchar2 default null
,field4_value                  in     varchar2 default null
,field5_name                   in     varchar2 default null
,field5_condition_code         in     varchar2 default null
,field5_value                  in     varchar2 default null
) is
pragma autonomous_transaction;
--
  l_query_id number;
  l_proc varchar2(72):=g_package||'findsave';
--
--
begin
  hr_utility.set_location('Entering '||l_proc,10);
   l_query_id:=query_id;
  --
  if business_group_id is not null then
    insert_number(l_query_id,'BUSINESS_GROUP_ID',business_group_id);
  end if;
  --Modified for PMxbg
  if business_group_name is not null  then
        insert_varchar2(l_query_id,'BUSINESS_GROUP_NAME',business_group_name);
  end if;
  if person_id is not null then
    insert_number(l_query_id,'PERSON_ID',person_id);
  end if;
  if person_type is not null then
    insert_varchar2(l_query_id,'PERSON_TYPE',person_type);
  end if;
  if system_person_type is not null then
    insert_varchar2(l_query_id,'SYSTEM_PERSON_TYPE',system_person_type);
  end if;
  if person_type_id  is not null then
    insert_number(l_query_id,'PERSON_TYPE_ID',person_type_id);
  end if;
  if last_name is not null then
    insert_varchar2(l_query_id,'LAST_NAME',last_name);
  end if;
  if start_date is not null then
    insert_date(l_query_id,'START_DATE',start_date);
  end if;
  if hire_date is not null then
    insert_date(l_query_id,'HIRE_DATE',hire_date);
  end if;
  if applicant_number is not null then
    insert_varchar2(l_query_id,'APPLICANT_NUMBER',applicant_number);
  end if;
  if date_of_birth is not null then
    insert_date(l_query_id,'DATE_OF_BIRTH',date_of_birth);
  end if;
  if email_address is not null then
    insert_varchar2(l_query_id,'EMAIL_ADDRESS',email_address);
  end if;
  if employee_number is not null then
    insert_varchar2(l_query_id,'EMPLOYEE_NUMBER',employee_number);
  end if;
--CWK
  if npw_number is not null then
    insert_varchar2(l_query_id,'NPW_NUMBER',npw_number);
  end if;
  if project_title is not null then
    insert_varchar2(l_query_id,'PROJECT_TITLE',project_title);
  end if;
  if vendor_id is not null then
    insert_number(l_query_id,'VENDOR_ID',vendor_id);
  end if;
  if vendor_name is not null then
    insert_varchar2(l_query_id,'VENDOR_NAME',vendor_name);
  end if;
  if vendor_employee_number is not null then
    insert_varchar2(l_query_id,'VENDOR_EMPLOYEE_NUMBER',vendor_employee_number);
  end if;
  if vendor_assignment_number is not null then
    insert_varchar2(l_query_id,'VENDOR_ASSIGNMENT_NUMBER',vendor_assignment_number);
  end if;
  if vendor_site_id is not null then
    insert_number(l_query_id,'VENDOR_SITE_ID',vendor_site_id);
  end if;
  if vendor_site_code is not null then
    insert_varchar2(l_query_id,'VENDOR_SITE_CODE',vendor_site_code);
  end if;
  if po_header_id is not null then
    insert_number(l_query_id,'PO_HEADER_ID',po_header_id);
  end if;
  if po_header_num is not null then
    insert_varchar2(l_query_id,'PO_HEADER_NUM',po_header_num);
  end if;
  if po_line_id is not null then
    insert_number(l_query_id,'PO_LINE_ID',po_line_id);
  end if;
  if po_line_num is not null then
    insert_varchar2(l_query_id,'PO_LINE_NUM',po_line_num);
  end if;
--
  if first_name is not null then
    insert_varchar2(l_query_id,'FIRST_NAME',first_name);
  end if;
  if full_name is not null then
    insert_varchar2(l_query_id,'FULL_NAME',full_name);
  end if;
  if title is not null then
    insert_varchar2(l_query_id,'TITLE',title);
  end if;
  if middle_names is not null then
    insert_varchar2(l_query_id,'MIDDLE_NAMES',middle_names);
  end if;
  if nationality_meaning is not null then
    insert_varchar2(l_query_id,'NATIONALITY_MEANING',nationality_meaning);
  end if;
  if nationality is not null then
    insert_varchar2(l_query_id,'NATIONALITY',nationality);
  end if;
  if national_identifier is not null then
    insert_varchar2(l_query_id,'NATIONAL_IDENTIFIER',national_identifier);
  end if;
-- Bug 3037019 Start here
  if registered_disabled_flag is not null then
    insert_varchar2(l_query_id,'REGISTERED_DISABLED_FLAG',registered_disabled_flag);
  end if;
-- Bug 3037019 End Here
  if registered_disabled is not null then
    insert_varchar2(l_query_id,'REGISTERED_DISABLED',registered_disabled);
  end if;
  if sex_meaning is not null then
    insert_varchar2(l_query_id,'SEX_MEANING',sex_meaning);
  end if;
  if sex is not null then
    insert_varchar2(l_query_id,'SEX',sex);
  end if;
  if benefit_group is not null then
    insert_varchar2(l_query_id,'BENEFIT_GROUP',benefit_group);
  end if;
  if benefit_group_id is not null then
    insert_number(l_query_id,'BENEFIT_GROUP_ID',benefit_group_id);
  end if;
  if grade is not null then
    insert_varchar2(l_query_id,'GRADE',grade);
  end if;
  if grade_id is not null then
    insert_number(l_query_id,'GRADE_ID',grade_id);
  end if;
  if grade_ladder is not null then
    insert_varchar2(l_query_id,'GRADE_LADDER',grade_ladder);
  end if;
  if grade_ladder_pgm_id is not null then
    insert_number(l_query_id,'GRADE_LADDER_PGM_ID',grade_ladder_pgm_id);
  end if;
  if position is not null then
    insert_varchar2(l_query_id,'POSITION',position);
  end if;
  if position_id is not null then
    insert_number(l_query_id,'POSITION_ID',position_id);
  end if;
  if job is not null then
    insert_varchar2(l_query_id,'JOB',job);
  end if;
  if job_id is not null then
    insert_number(l_query_id,'JOB_ID',job_id);
  end if;
  if assignment_status_type is not null then
    insert_varchar2(l_query_id,'ASSIGNMENT_STATUS_TYPE',assignment_status_type);
  end if;
  if assignment_status_type_id is not null then
    insert_number(l_query_id,'ASSIGNMENT_STATUS_TYPE_ID',assignment_status_type_id);
  end if;
  if payroll is not null then
    insert_varchar2(l_query_id,'PAYROLL',payroll);
  end if;
  if payroll_id is not null then
    insert_number(l_query_id,'PAYROLL_ID',payroll_id);
  end if;
  if location is not null then
    insert_varchar2(l_query_id,'LOCATION',location);
  end if;
  if location_id is not null then
    insert_number(l_query_id,'LOCATION_ID',location_id);
  end if;
  if supervisor is not null then
    insert_varchar2(l_query_id,'SUPERVISOR',supervisor);
  end if;
  if supervisor_id is not null then
    insert_number(l_query_id,'SUPERVISOR_ID',supervisor_id);
  end if;
  if supervisor_assignment_number is not null then
    insert_varchar2(l_query_id,'SUPERVISOR_ASSIGNMENT_NUMBER',supervisor_assignment_number);
  end if;
  if supervisor_assignment_id is not null then
    insert_number(l_query_id,'SUPERVISOR_ASSIGNMENT_ID',supervisor_assignment_id);
  end if;
  if recruitment_activity is not null then
    insert_varchar2(l_query_id,'RECRUITMENT_ACTIVITY',recruitment_activity);
  end if;
  if recruitment_activity_id is not null then
    insert_number(l_query_id,'RECRUITMENT_ACTIVITY_ID',recruitment_activity_id);
  end if;
  if organization is not null then
    insert_varchar2(l_query_id,'ORGANIZATION',organization);
  end if;
  if organization_id is not null then
    insert_number(l_query_id,'ORGANIZATION_ID',organization_id);
  end if;
  if people_group is not null then
    insert_varchar2(l_query_id,'PEOPLE_GROUP',people_group);
  end if;
  if people_group_id is not null then
    insert_number(l_query_id,'PEOPLE_GROUP_ID',people_group_id);
  end if;
  if vacancy is not null then
    insert_varchar2(l_query_id,'VACANCY',vacancy);
  end if;
  if vacancy_id is not null then
    insert_number(l_query_id,'VACANCY_ID',vacancy_id);
  end if;
  if requisition is not null then
    insert_varchar2(l_query_id,'REQUISITION',requisition);
  end if;
  if requisition_id is not null then
    insert_number(l_query_id,'REQUISITION_ID',requisition_id);
  end if;
  if salary_basis is not null then
    insert_varchar2(l_query_id,'SALARY_BASIS',salary_basis);
  end if;
  if pay_basis_id is not null then
    insert_number(l_query_id,'PAY_BASIS_ID',pay_basis_id);
  end if;
  if bargaining_unit_code_meaning is not null then
    insert_varchar2(l_query_id,'BARGAINING_UNIT_CODE_MEANING',bargaining_unit_code_meaning);
  end if;
  if bargaining_unit_code is not null then
    insert_varchar2(l_query_id,'BARGAINING_UNIT_CODE',bargaining_unit_code);
  end if;
  if employment_category_meaning is not null then
    insert_varchar2(l_query_id,'EMPLOYMENT_CATEGORY_MEANING',employment_category_meaning);
  end if;
  if employment_category is not null then
    insert_varchar2(l_query_id,'EMPLOYMENT_CATEGORY',employment_category);
  end if;
  if establishment is not null then
    insert_varchar2(l_query_id,'ESTABLISHMENT',establishment);
  end if;
  if establishment_id is not null then
    insert_number(l_query_id,'ESTABLISHMENT_ID',establishment_id);
  end if;
  if projected_hire_date is not null then
    insert_date(l_query_id,'PROJECTED_HIRE_DATE',projected_hire_date);
  end if;
  if secure is not null then
    insert_varchar2(l_query_id,'SECURE',secure);
  end if;
  if field1_name is not null then
    insert_varchar2(l_query_id,'FIELD1_NAME',field1_name);
  end if;
  if field1_condition_code is not null then
    insert_varchar2(l_query_id,'FIELD1_CONDITION_CODE',field1_condition_code);
  end if;
  if field1_value is not null then
    insert_varchar2(l_query_id,'FIELD1_VALUE',field1_value);
  end if;
  if field2_name is not null then
    insert_varchar2(l_query_id,'FIELD2_NAME',field2_name);
  end if;
  if field2_condition_code is not null then
    insert_varchar2(l_query_id,'FIELD2_CONDITION_CODE',field2_condition_code);
  end if;
  if field2_value is not null then
    insert_varchar2(l_query_id,'FIELD2_VALUE',field2_value);
  end if;
  if field3_name is not null then
    insert_varchar2(l_query_id,'FIELD3_NAME',field3_name);
  end if;
  if field3_condition_code is not null then
    insert_varchar2(l_query_id,'FIELD3_CONDITION_CODE',field3_condition_code);
  end if;
  if field3_value is not null then
    insert_varchar2(l_query_id,'FIELD3_VALUE',field3_value);
  end if;
  if field4_name is not null then
    insert_varchar2(l_query_id,'FIELD4_NAME',field4_name);
  end if;
  if field4_condition_code is not null then
    insert_varchar2(l_query_id,'FIELD4_CONDITION_CODE',field4_condition_code);
  end if;
  if field4_value is not null then
    insert_varchar2(l_query_id,'FIELD4_VALUE',field4_value);
  end if;
  if field5_name is not null then
    insert_varchar2(l_query_id,'FIELD5_NAME',field5_name);
  end if;
  if field5_condition_code is not null then
    insert_varchar2(l_query_id,'FIELD5_CONDITION_CODE',field5_condition_code);
  end if;
  if field5_value is not null then
    insert_varchar2(l_query_id,'FIELD5_VALUE',field5_value);
  end if;
  commit;
  hr_utility.set_location('Leaving '||l_proc,100);
end findsave;
--
function get_varchar2(p_query_id number
                     ,p_field varchar2)
return varchar2 is
  l_value varchar2(240);
--
  cursor get_varchar2 is
  select varchar2_value
  from per_query_criteria
  where query_id=p_query_id
  and field=p_field;
begin
  open get_varchar2;
  fetch get_varchar2 into l_value;
  close get_varchar2;
  return l_value;
end get_varchar2;
--
function get_number  (p_query_id number
                     ,p_field varchar2)
return number is
  l_value number;
--
  cursor get_number is
  select number_value
  from per_query_criteria
  where query_id=p_query_id
  and field=p_field;
begin
  open get_number;
  fetch get_number into l_value;
  close get_number;
  return l_value;
end get_number;
--
function get_date  (p_query_id number
                     ,p_field varchar2)
return date is
  l_value date;
--
  cursor get_date is
  select date_value
  from per_query_criteria
  where query_id=p_query_id
  and field=p_field;
begin
  open get_date;
  fetch get_date into l_value;
  close get_date;
  return l_value;
end get_date;

procedure findretrieve
(p_query_id                  in     number
,p_effective_date            in     date
,p_customized_restriction_id in     number   default null
,p_employees_allowed         in     boolean  default false
,p_applicants_allowed        in     boolean  default false
,p_cwk_allowed               in     boolean  default false
,p_people_tab                   out nocopy findtab
) is
--
  l_findtab findtab;
  i number;
  l_select_stmt_per VARCHAR2(20000);
begin
--
findquery(resultset => l_findtab
,p_effective_date => p_effective_date
,business_group_id => get_number(p_query_id,'BUSINESS_GROUP_ID')
,business_group_name => get_varchar2(p_query_id,'BUSINESS_GROUP_NAME')
,person_id => get_number(p_query_id,'PERSON_ID')
,person_type => get_varchar2(p_query_id,'PERSON_TYPE')
,system_person_type => get_varchar2(p_query_id,'SYSTEM_PERSON_TYPE')
,person_type_id => get_number(p_query_id,'PERSON_TYPE_ID')
,last_name => get_varchar2(p_query_id,'LAST_NAME')
,start_date => get_date(p_query_id,'START_DATE')
,hire_date => get_date(p_query_id,'HIRE_DATE')
,applicant_number => get_varchar2(p_query_id,'APPLICANT_NUMBER')
,date_of_birth => get_date(p_query_id,'DATE_OF_BIRTH')
,email_address => get_varchar2(p_query_id,'EMAIL_ADDRESS')
,employee_number => get_varchar2(p_query_id,'EMPLOYEE_NUMBER')
--CWK
,npw_number => get_varchar2(p_query_id,'')
,project_title => get_varchar2(p_query_id,'PROJECT_TITLE')
,vendor_id => get_number(p_query_id,'VENDOR_ID')
,vendor_name => get_varchar2(p_query_id,'VENDOR_NAME')
,vendor_employee_number => get_varchar2(p_query_id,'VENDOR_EMPLOYEE_NUMBER')
,vendor_assignment_number => get_varchar2(p_query_id,'VENDOR_ASSIGNMENT_NUMBER')
,vendor_site_id => get_number(p_query_id,'VENDOR_SITE_ID')
,vendor_site_code => get_varchar2(p_query_id,'VENDOR_SITE_CODE')
,po_header_id => get_number(p_query_id,'PO_HEADER_ID')
,po_header_num => get_varchar2(p_query_id,'PO_HEADER_NUM')
,po_line_id => get_number(p_query_id,'PO_LINE_ID')
,po_line_num => get_varchar2(p_query_id,'PO_LINE_NUM')
--
,first_name => get_varchar2(p_query_id,'FIRST_NAME')
,full_name => get_varchar2(p_query_id,'FULL_NAME')
,title => get_varchar2(p_query_id,'TITLE')
,middle_names => get_varchar2(p_query_id,'MIDDLE_NAMES')
,nationality_meaning => get_varchar2(p_query_id,'NATIONALITY_MEANING')
,nationality => get_varchar2(p_query_id,'NATIONALITY')
,national_identifier => get_varchar2(p_query_id,'NATIONAL_IDENTIFIER')
-- Bug 3037019
,registered_disabled_flag => get_varchar2(p_query_id,'REGISTERED_DISABLED_FLAG')
,registered_disabled => get_varchar2(p_query_id,'REGISTERED_DISABLED')
,sex_meaning => get_varchar2(p_query_id,'SEX_MEANING')
,sex => get_varchar2(p_query_id,'SEX')
,benefit_group => get_varchar2(p_query_id,'BENEFIT_GROUP')
,benefit_group_id => get_number(p_query_id,'BENEFIT_GROUP_ID')
,grade => get_varchar2(p_query_id,'GRADE')
,grade_id => get_number(p_query_id,'GRADE_ID')
,grade_ladder => get_varchar2(p_query_id,'GRADE_LADDER')
,grade_ladder_pgm_id => get_number(p_query_id,'GRADE_LADDER_PGM_ID')
,position => get_varchar2(p_query_id,'POSITION')
,position_id => get_number(p_query_id,'POSITION_ID')
,job => get_varchar2(p_query_id,'JOB')
,job_id => get_number(p_query_id,'JOB_ID')
,assignment_status_type => get_varchar2(p_query_id,'ASSIGNMENT_STATUS_TYPE')
,assignment_status_type_id => get_number(p_query_id,'ASSIGNMENT_STATUS_TYPE_ID')
,payroll => get_varchar2(p_query_id,'PAYROLL')
,payroll_id => get_number(p_query_id,'PAYROLL_ID')
,location => get_varchar2(p_query_id,'LOCATION')
,location_id => get_number(p_query_id,'LOCATION_ID')
,supervisor => get_varchar2(p_query_id,'SUPERVISOR')
,supervisor_id => get_number(p_query_id,'SUPERVISOR_ID')
,supervisor_assignment_number => get_varchar2(p_query_id,'SUPERVISOR_ASSIGNMENT_NUMBER')
,supervisor_assignment_id => get_number(p_query_id,'SUPERVISOR_ASSIGNMENT_ID')
,recruitment_activity => get_varchar2(p_query_id,'RECRUITMENT_ACTIVITY')
,recruitment_activity_id => get_number(p_query_id,'RECRUITMENT_ACTIVITY_ID')
,organization => get_varchar2(p_query_id,'ORGANIZATION')
,organization_id => get_number(p_query_id,'ORGANIZATION_ID')
,people_group => get_varchar2(p_query_id,'PEOPLE_GROUP')
,people_group_id => get_number(p_query_id,'PEOPLE_GROUP_ID')
,vacancy => get_varchar2(p_query_id,'VACANCY')
,vacancy_id => get_number(p_query_id,'VACANCY_ID')
,requisition => get_varchar2(p_query_id,'REQUISITION')
,requisition_id => get_number(p_query_id,'REQUISITION_ID')
,salary_basis => get_varchar2(p_query_id,'SALARY_BASIS')
,pay_basis_id => get_number(p_query_id,'PAY_BASIS_ID')
,bargaining_unit_code_meaning => get_varchar2(p_query_id,'BARGAINING_UNIT_CODE_MEANING')
,bargaining_unit_code => get_varchar2(p_query_id,'BARGAINING_UNIT_CODE')
,employment_category_meaning => get_varchar2(p_query_id,'EMPLOYMENT_CATEGORY_MEANING')
,employment_category => get_varchar2(p_query_id,'EMPLOYMENT_CATEGORY')
,establishment => get_varchar2(p_query_id,'ESTABLISHMENT')
,establishment_id => get_number(p_query_id,'ESTABLISHMENT_ID')
,projected_hire_date => get_date(p_query_id,'PROJECTED_HIRE_DATE')
,secure =>'Y'
,field1_name => get_varchar2(p_query_id,'FIELD1_NAME')
,field1_condition_code => get_varchar2(p_query_id,'FIELD1_CONDITION_CODE')
,field1_value => get_varchar2(p_query_id,'FIELD1_VALUE')
,field2_name => get_varchar2(p_query_id,'FIELD2_NAME')
,field2_condition_code => get_varchar2(p_query_id,'FIELD2_CONDITION_CODE')
,field2_value => get_varchar2(p_query_id,'FIELD2_VALUE')
,field3_name => get_varchar2(p_query_id,'FIELD3_NAME')
,field3_condition_code => get_varchar2(p_query_id,'FIELD3_CONDITION_CODE')
,field3_value => get_varchar2(p_query_id,'FIELD3_VALUE')
,field4_name => get_varchar2(p_query_id,'FIELD4_NAME')
,field4_condition_code => get_varchar2(p_query_id,'FIELD4_CONDITION_CODE')
,field4_value => get_varchar2(p_query_id,'FIELD4_VALUE')
,field5_name => get_varchar2(p_query_id,'FIELD5_NAME')
,field5_condition_code => get_varchar2(p_query_id,'FIELD5_CONDITION_CODE')
,field5_value => get_varchar2(p_query_id,'FIELD5_VALUE')
,p_customized_restriction_id => p_customized_restriction_id
,p_employees_allowed => p_employees_allowed
,p_applicants_allowed => p_applicants_allowed
,p_cwk_allowed => p_cwk_allowed
,p_fetch_details => FALSE
,select_stmt => l_select_stmt_per);

p_people_tab:=l_findtab;

end findretrieve;


end per_qh_find_query;

/
