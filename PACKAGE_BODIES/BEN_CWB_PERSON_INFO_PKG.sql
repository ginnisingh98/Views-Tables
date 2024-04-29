--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PERSON_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PERSON_INFO_PKG" as
/* $Header: bencwbpi.pkb 120.13.12010000.10 2010/05/11 09:24:22 sgnanama ship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_person_info_pkg.'; --Global package name
g_debug boolean := hr_utility.debug_enabled;
g_fte_factor VARCHAR2(240) := fnd_profile.VALUE('BEN_CWB_FTE_FACTOR');
g_salary_survey_id number := null; --Change to right value when implementing.
--
 cursor c_sal_info(v_assignment_id number,
                   v_effective_date date) is
  select ppp.assignment_id   assignment_id
        ,ppp.proposed_salary_n    salary
        ,ppb.pay_basis            salary_frequency
        ,get_salary_currency(ppb.input_value_id
                             ,ppp.change_date) salary_currency
        ,nvl(ppb.pay_annualization_factor,1)  salary_ann_fctr
        ,get_fte_factor(v_assignment_id
                       ,v_effective_date) fte_factor
  from  per_all_assignments_f       paf
       ,per_pay_proposals           ppp
       ,per_pay_bases               ppb
  where ppp.assignment_id = v_assignment_id
   and  ppp.approved = 'Y'
   and  ppp.change_date =
          (select max(ppp1.change_date)
            from per_pay_proposals ppp1
           where ppp1.assignment_id = v_assignment_id
             and ppp1.change_date <= v_effective_date
             and ppp1.approved = 'Y')
   and  paf.assignment_id = ppp.assignment_id
   and  ppp.change_date between
        paf.effective_start_date and paf.effective_end_date
   and  paf.pay_basis_id = ppb.pay_basis_id;

  cursor c_survey_info(v_job_id number,
                       v_effective_date date) is
   SELECT pss_mappings.parent_id  parent_id
         ,pss.salary_survey_id    survey_id
         ,pss_lines.currency_code currency
        ----- vkodedal 8869036 - survey type
         ,pss.survey_type_code    frequency
         ,decode(pss.survey_type_code,
            'MONTHLY', 12,
            'HOURLY', 2080, 1)       annualization_factor
         ,pss_lines.minimum_pay   min_salary
         ,NVL(pss_lines.twenty_fifth_percentile
                 ,pss_lines.minimum_pay+
                 (pss_lines.maximum_pay-pss_lines.minimum_pay)*0.25)
                                          pct25_salary
         ,NVL(pss_lines.mean_pay
                ,(pss_lines.minimum_pay+pss_lines.maximum_pay)/2)
                                          mid_salary
         ,NVL(pss_lines.seventy_fifth_percentile
                ,pss_lines.minimum_pay+
                (pss_lines.maximum_pay-pss_lines.minimum_pay)*0.75)
                                          pct75_salary
         ,pss_lines.maximum_pay   max_salary
   FROM  per_salary_surveys         pss
        ,per_salary_survey_lines    pss_lines
        ,per_salary_survey_mappings pss_mappings
   WHERE pss.salary_survey_id = g_salary_survey_id
   AND   pss_lines.salary_survey_id = pss.salary_survey_id
   AND   v_effective_date BETWEEN pss_lines.start_date
   AND   NVL(pss_lines.end_date, to_date('4712/12/31', 'yyyy/mm/dd'))
   AND   pss_lines.salary_survey_line_id = pss_mappings.salary_survey_line_id
   AND   pss_mappings.parent_table_name = 'PER_JOBS'
   and   pss_mappings.parent_id = v_job_id;
-- --------------------------------------------------------------------------
-- |----------------------------< get_salary_info >--------------------------|
-- --------------------------------------------------------------------------
-- This function derives the salary information.
function get_salary_info(p_assignment_id  in number
                        ,p_effective_date in date)

return c_sal_info%rowtype is
--
   l_sal_info c_sal_info%rowtype;
--
   l_proc     varchar2(72) := g_package||'get_salary_info';
--

begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   open  c_sal_info(p_assignment_id, p_effective_date);
   fetch c_sal_info into l_sal_info;
   close c_sal_info;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_sal_info;
end get_salary_info;
--
-- --------------------------------------------------------------------------
-- |----------------------------< get_survey_info >--------------------------|
-- --------------------------------------------------------------------------
-- This function derives the survey information.
function get_survey_info(p_job_id  in number
                        ,p_effective_date in date)
return c_survey_info%rowtype is
--
   l_survey_info c_survey_info%rowtype;
--
   l_proc     varchar2(72) := g_package||'get_survey_info';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   open  c_survey_info(p_job_id, p_effective_date);
   fetch c_survey_info into l_survey_info;
   close c_survey_info;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_survey_info;
end get_survey_info;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_years_in_job >--------------------------|
-- --------------------------------------------------------------------------
--
function get_years_in_job(p_assignment_id  in number
                         ,p_job_id         in number
                         ,p_effective_date in date
                         ,p_asg_effective_start_date in date)
return number is
--
   l_years_in_job number;
--
   l_proc     varchar2(72) := g_package||'get_years_in_job';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select trunc(sum(months_between(
               decode(asgjob.effective_end_date,
                      to_date('4712/12/31', 'yyyy/mm/dd'),p_effective_date,
                      least(asgjob.effective_end_date+1,p_effective_date)),
               asgjob.effective_start_date))/12,1)
   into l_years_in_job
   from per_all_assignments_f asgjob
   where asgjob.assignment_id=p_assignment_id
   and   asgjob.job_id = p_job_id
   and   asgjob.effective_start_date <= p_asg_effective_start_date;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_years_in_job;
end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_years_in_position >-----------------------|
-- --------------------------------------------------------------------------
--
function get_years_in_position(p_assignment_id  in number
                              ,p_position_id    in number
                              ,p_effective_date in date
                              ,p_asg_effective_start_date in date)
return number is
--
   l_years_in_position number;
--
   l_proc     varchar2(72) := g_package||'get_years_in_position';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select trunc(sum(months_between(
               decode(asgpos.effective_end_date,
                      to_date('4712/12/31', 'yyyy/mm/dd'),p_effective_date,
                      least(asgpos.effective_end_date+1,p_effective_date)),
               asgpos.effective_start_date))/12,1)
   into l_years_in_position
   from per_all_assignments_f asgpos
   where asgpos.assignment_id=p_assignment_id
   and   asgpos.position_id = p_position_id
   and   asgpos.effective_start_date <= p_asg_effective_start_date;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_years_in_position;
end;
--
-- --------------------------------------------------------------------------
-- |--------------------------< get_years_in_grade >-------------------------|
-- --------------------------------------------------------------------------
--
function get_years_in_grade(p_assignment_id  in number
                           ,p_grade_id    in number
                           ,p_effective_date in date
                           ,p_asg_effective_start_date in date)
return number is
--
   l_years_in_grade number;
--
   l_proc     varchar2(72) := g_package||'get_years_in_grade';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select trunc(sum(months_between(
               decode(asggrd.effective_end_date,
                      to_date('4712/12/31', 'yyyy/mm/dd'),p_effective_date,
                      least(asggrd.effective_end_date+1,p_effective_date)),
               asggrd.effective_start_date))/12,1)
   into l_years_in_grade
   from per_all_assignments_f asggrd
   where asggrd.assignment_id=p_assignment_id
   and   asggrd.grade_id = p_grade_id
   and   asggrd.effective_start_date <= p_asg_effective_start_date
   and   asggrd.assignment_type <> 'A';   --9060804
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_years_in_grade;
end; -- get_years_in_grade
-- --------------------------------------------------------------------------
-- |----------------------------< get_grd_min_val >--------------------------|
-- --------------------------------------------------------------------------
-- This function computes the years in grade
function get_grd_min_val(p_grade_id  in number
                        ,p_rate_id   in number
                        ,p_effective_date in date)
return number is
--
   l_grd_min_val number;
--
   l_proc     varchar2(72) := g_package||'get_grd_min_val';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select fnd_number.canonical_to_number(minimum) into l_grd_min_val
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and   p_effective_date between grdrule.effective_start_date
                  and grdrule.effective_end_date;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_grd_min_val;
end; -- get_grd_min_val
--
-- --------------------------------------------------------------------------
-- |----------------------------< get_grd_max_val >--------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in grade
function get_grd_max_val(p_grade_id  in number
                        ,p_rate_id   in number
                        ,p_effective_date in date)
return number is
--
   l_grd_max_val number;
--
   l_proc     varchar2(72) := g_package||'get_grd_max_val';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select fnd_number.canonical_to_number(maximum) into l_grd_max_val
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and p_effective_date between grdrule.effective_start_date
                  and grdrule.effective_end_date;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_grd_max_val;
end; -- get_grd_max_val
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_mid_point >-------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in grade
function get_grd_mid_point(p_grade_id  in number
                          ,p_rate_id   in number
                          ,p_effective_date in date)
return number is
--
   l_grd_mid_point number;
--
   l_proc     varchar2(72) := g_package||'get_grd_mid_point';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select fnd_number.canonical_to_number(mid_value) into l_grd_mid_point
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and   p_effective_date between grdrule.effective_start_date
                and grdrule.effective_end_date;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 99);
   end if;
   --
   return l_grd_mid_point;
end; -- get_grd_mid_point
--
-- --------------------------------------------------------------------------
-- |-------------------------< refresh_person_info >-------------------------|
-- --------------------------------------------------------------------------
--
procedure refresh_person_info(p_group_per_in_ler_id  in number
                             ,p_effective_date       in date
                             ,p_called_from_benmngle in boolean default false)
is

  l_performance_rating_type ben_cwb_person_info.performance_rating_type%type;

--vkodedal cursor to fetch survey_id from eit setup.
cursor c_survey_id(l_group_pl_id in number) is
select PLI_INFORMATION2 from ben_pl_extra_info
where INFORMATION_TYPE='CWB_CUSTOM_DOWNLOAD'
and pl_id=l_group_pl_id;
--
-- cursor to fetch the person information
cursor csr_person_info(p_group_per_in_ler_id number
                      ,p_effective_date date
                      ,p_from_benmngle varchar2
		      ,p_appraisal_n_days number) is
--
select p_group_per_in_ler_id     group_per_in_ler_id
         ,pil.assignment_id      assignment_id
         ,decode(p_from_benmngle,'Y',-1,ppf.person_id)
                                 person_id
         ,paf.supervisor_id      supervisor_id
         ,p_effective_date       effective_date
         ,ppf.full_name          full_name
         ,trim(ppf.first_name ||' '||ppf.last_name||' '||ppf.suffix)  brief_name
         ,nvl(ben_cwb_custom_person_pkg.get_custom_name(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date),
               ppf.full_name)    custom_name
         ,supv.full_name         supervisor_full_name
         ,trim(supv.first_name||' '||supv.last_name||' '||supv.suffix)
                  supervisor_brief_name
         ,nvl(ben_cwb_custom_person_pkg.get_custom_name(supv.person_id
                                                   ,supv_asg.assignment_id
                                                   ,supv_bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date),
              supv.full_name)    supervisor_custom_name
         ,bg.org_information9    legislation_code
         ,trunc(months_between(p_effective_date,
               nvl(service_period.adjusted_svc_date,
               nvl(service_period.date_start,
                   ppf.start_date)))/12,1)    years_employed
         ,get_years_in_job(paf.assignment_id
                          ,paf.job_id
                          ,p_effective_date
                          ,paf.effective_start_date) years_in_job
         ,get_years_in_position(paf.assignment_id
                               ,paf.position_id
                               ,p_effective_date
                               ,paf.effective_start_date) years_in_position
         ,get_years_in_grade(paf.assignment_id
                            ,paf.grade_id
                            ,p_effective_date
                            ,paf.effective_start_date) years_in_grade
         ,ppf.employee_number    employee_number
         ,nvl(service_period.date_start,ppf.start_date)    start_date
         ,ppf.original_date_of_hire  original_start_date
         ,service_period.adjusted_svc_date   adjusted_svc_date
         ,ppp.proposed_salary_n  base_salary
         ,ppp.change_date        base_salary_change_date
         ,pay.payroll_name       payroll_name
         ,perf.performance_rating    performance_rating
         ,perf.review_date       performance_rating_date
         ,paf.business_group_id  business_group_id
         ,paf.organization_id    organization_id
         ,paf.job_id             job_id
         ,paf.grade_id           grade_id
         ,paf.position_id        position_id
         ,paf.people_group_id    people_group_id
         ,paf.soft_coding_keyflex_id   soft_coding_keyflex_id
         ,paf.location_id        location_id
         ,ppb.rate_id            pay_rate_id
         ,paf.assignment_status_type_id assignment_status_type_id
         ,paf.frequency         frequency
         ,nvl(ppb.grade_annualization_factor,1) grade_annualization_factor
         ,nvl(ppb.pay_annualization_factor,1)   pay_annualization_factor
         ,get_grd_min_val(paf.grade_id
                         ,ppb.rate_id
                         ,p_effective_date) grd_min_val
                         ,get_grd_max_val(paf.grade_id
                         ,ppb.rate_id
                         ,p_effective_date) grd_max_val
         ,get_grd_mid_point(paf.grade_id
                           ,ppb.rate_id
                           ,p_effective_date) grd_mid_point
         ,paf.employment_category   emp_category
         ,paf.change_reason      change_reason
         ,paf.normal_hours       normal_hours
         ,ppf.email_address      email_address
         ,ppb.pay_basis          base_salary_frequency
	     ,ppb.rate_basis	 grade_rate_frequency
         ,ben_cwb_custom_person_pkg.get_custom_segment1(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment1
         ,ben_cwb_custom_person_pkg.get_custom_segment2(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment2
         ,ben_cwb_custom_person_pkg.get_custom_segment3(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment3
         ,ben_cwb_custom_person_pkg.get_custom_segment4(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment4
         ,ben_cwb_custom_person_pkg.get_custom_segment5(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment5
         ,ben_cwb_custom_person_pkg.get_custom_segment6(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment6
         ,ben_cwb_custom_person_pkg.get_custom_segment7(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment7
         ,ben_cwb_custom_person_pkg.get_custom_segment8(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment8
         ,ben_cwb_custom_person_pkg.get_custom_segment9(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment9
         ,ben_cwb_custom_person_pkg.get_custom_segment10(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment10
         ,ben_cwb_custom_person_pkg.get_custom_segment11(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment11
         ,ben_cwb_custom_person_pkg.get_custom_segment12(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment12
         ,ben_cwb_custom_person_pkg.get_custom_segment13(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment13
         ,ben_cwb_custom_person_pkg.get_custom_segment14(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment14
         ,ben_cwb_custom_person_pkg.get_custom_segment15(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment15
          ,ben_cwb_custom_person_pkg.get_custom_segment16(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment16
         ,ben_cwb_custom_person_pkg.get_custom_segment17(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment17
         ,ben_cwb_custom_person_pkg.get_custom_segment18(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment18
         ,ben_cwb_custom_person_pkg.get_custom_segment19(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment19
         ,ben_cwb_custom_person_pkg.get_custom_segment20(ppf.person_id
                                                   ,pil.assignment_id
                                                   ,bg.org_information9
                                                   ,pil.group_pl_id
                                                   ,pil.lf_evt_ocrd_dt
                                                   ,p_effective_date)
                                 custom_segment20
        ,paf.ass_attribute_category   ass_attribute_category
         ,paf.ass_attribute1     ass_attribute1
         ,paf.ass_attribute2     ass_attribute2
         ,paf.ass_attribute3     ass_attribute3
         ,paf.ass_attribute4     ass_attribute4
         ,paf.ass_attribute5     ass_attribute5
         ,paf.ass_attribute6     ass_attribute6
         ,paf.ass_attribute7     ass_attribute7
         ,paf.ass_attribute8     ass_attribute8
         ,paf.ass_attribute9     ass_attribute9
         ,paf.ass_attribute10    ass_attribute10
         ,paf.ass_attribute11    ass_attribute11
         ,paf.ass_attribute12    ass_attribute12
         ,paf.ass_attribute13    ass_attribute13
         ,paf.ass_attribute14    ass_attribute14
         ,paf.ass_attribute15    ass_attribute15
         ,paf.ass_attribute16    ass_attribute16
         ,paf.ass_attribute17    ass_attribute17
         ,paf.ass_attribute18    ass_attribute18
         ,paf.ass_attribute19    ass_attribute19
         ,paf.ass_attribute20    ass_attribute20
         ,paf.ass_attribute21    ass_attribute21
         ,paf.ass_attribute22    ass_attribute22
         ,paf.ass_attribute23    ass_attribute23
         ,paf.ass_attribute24    ass_attribute24
         ,paf.ass_attribute25    ass_attribute25
         ,paf.ass_attribute26    ass_attribute26
         ,paf.ass_attribute27    ass_attribute27
         ,paf.ass_attribute28    ass_attribute28
         ,paf.ass_attribute29    ass_attribute29
         ,paf.ass_attribute30    ass_attribute30
         ,grp.group_name   people_group_name
         ,grp.segment1     people_group_segment1
         ,grp.segment2     people_group_segment2
         ,grp.segment3     people_group_segment3
         ,grp.segment4     people_group_segment4
         ,grp.segment5     people_group_segment5
         ,grp.segment6     people_group_segment6
         ,grp.segment7     people_group_segment7
         ,grp.segment8     people_group_segment8
         ,grp.segment9     people_group_segment9
         ,grp.segment10       people_group_segment10
         ,grp.segment11       people_group_segment11
	 ,get_salary_currency(ppb.input_value_id
	                     ,p_effective_date) base_salary_currency
	 ,pil.group_pl_id			group_pl_id
         ,pil.lf_evt_ocrd_dt			lf_evt_ocrd_dt
	 ,ppp_prev.proposed_salary_n		prev_sal
	 ,ppb_prev.pay_basis			prev_sal_frequency
	 ,get_salary_currency(ppb_prev.input_value_id
			     ,ppp_prev.change_date) prev_sal_currency
	 ,nvl(ppb_prev.pay_annualization_factor,1)  prev_sal_ann_fctr
	 ,ppp.change_date			prev_sal_chg_date
	 ,ppp.proposal_reason			prev_sal_chg_rsn
	 ,get_fte_factor(paf.assignment_id
	                ,p_effective_date) fte_factor
	 ,get_fte_factor(paf.assignment_id
	                ,ppp_prev.change_date) prev_fte_factor
      ,ppp.pay_proposal_id			current_pay_proposal_id
      , (CASE
          WHEN perf.event_id IS NULL THEN
              NULL
          WHEN perf.event_id IS NOT NULL THEN
            (SELECT appraisal_id
             FROM   per_appraisals
             WHERE  appraisee_person_id = ppf.person_id
             AND    event_id = perf.event_id)
          END ) appraisal_id
from  per_all_people_f           ppf
         ,per_all_assignments_f  paf
         ,ben_per_in_ler         pil
         ,per_all_people_f       supv
         ,per_all_assignments_f  supv_asg
         ,hr_organization_information    bg
         ,hr_organization_information    supv_bg
         ,per_periods_of_service service_period
         ,per_pay_proposals      ppp
         ,pay_all_payrolls_f     pay
         ,(select rtg1.review_date review_date
                 ,rtg1.performance_rating performance_rating
                 ,rtg1.person_id person_id
		 ,evt1.event_id
          from per_performance_reviews rtg1
              ,per_events evt1
          where rtg1.event_id = evt1.event_id (+)
          --and   rtg1.review_date <= p_effective_date
	  --ER:8369634
	  and ((p_appraisal_n_days is not null and rtg1.review_date between (p_effective_date - p_appraisal_n_days) and p_effective_date)
		or (p_appraisal_n_days is null and rtg1.review_date <= p_effective_date))
          and   nvl(evt1.type, '-X-X-X-') = nvl(l_performance_rating_type, '-X-X-X-')
	  ) perf
         ,per_pay_bases          ppb
         ,pay_people_groups   grp
         ,per_all_assignments_f       paf_prev
	 ,per_pay_proposals		ppp_prev
	 ,per_pay_bases		ppb_prev
where  pil.per_in_ler_id = p_group_per_in_ler_id
   and   paf.assignment_id  = pil.assignment_id
   and   p_effective_date between paf.effective_start_date and
            paf.effective_end_date
   and   paf.person_id = ppf.person_id
   and   p_effective_date between ppf.effective_start_date and
            ppf.effective_end_date
   and   paf.supervisor_id = supv.person_id (+)
   and   p_effective_date between supv.effective_start_date (+) and
            supv.effective_end_date (+)
   and   supv.person_id = supv_asg.person_id (+)
   and   p_effective_date between supv_asg.effective_start_date (+) and
            supv_asg.effective_end_date (+)
   and   supv_asg.primary_flag (+) = 'Y'
   and   bg.organization_id = paf.business_group_id
   and   bg.org_information_context = 'Business Group Information'
   and   supv_bg.organization_id (+) = supv_asg.business_group_id
   and   supv_bg.org_information_context (+) = 'Business Group Information'
   and   paf.period_of_service_id = service_period.period_of_service_id (+)
   and   paf.assignment_id = ppp.assignment_id (+)
   and   ppp.approved (+) = 'Y'
   and   ppp.change_date (+) <= p_effective_date
   and   nvl(ppp.change_date,to_date('4712/12/31', 'yyyy/mm/dd')) =
            (select nvl(max(ppp1.change_date), to_date('4712/12/31',
                        'yyyy/mm/dd'))
             from per_pay_proposals ppp1
             where ppp1.assignment_id = ppp.assignment_id
             and ppp1.change_date <= p_effective_date
             and ppp1.approved = 'Y')
   and   paf.payroll_id = pay.payroll_id (+)
   and   p_effective_date between pay.effective_start_date (+) and
            pay.effective_end_date (+)
   and   ppf.person_id = perf.person_id (+)
   and   nvl(perf.review_date, to_date('4712/12/31', 'yyyy/mm/dd')) =
            (select nvl(max(rtg2.review_date),to_date('4712/12/31',
                     'yyyy/mm/dd'))
             from   per_performance_reviews rtg2
                   ,per_events evt2
             where  rtg2.person_id = ppf.person_id
             -- and    rtg2.review_date <= p_effective_date
             --ER:8369634
	     and ((p_appraisal_n_days is not null and rtg2.review_date between (p_effective_date - p_appraisal_n_days) and p_effective_date)
		or (p_appraisal_n_days is null and rtg2.review_date <= p_effective_date))
             and    rtg2.event_id = evt2.event_id (+)
             and    nvl(evt2.type, '-X-X-X-') = nvl(l_performance_rating_type, '-X-X-X-') )
   and paf.pay_basis_id = ppb.pay_basis_id (+)
   and grp.people_group_id (+) = paf.people_group_id
   and ppp_prev.assignment_id (+) = ppp.assignment_id
   and ppp_prev.approved (+) = 'Y'
   and ppp_prev.change_date (+) < ppp.change_date
   and nvl(ppp_prev.change_date, to_date('4712/12/31', 'yyyy/mm/dd')) =
           (select nvl(max(ppp1.change_date), to_date('4712/12/31',
                      'yyyy/mm/dd'))
              from per_pay_proposals ppp1
             where ppp1.assignment_id = ppp.assignment_id
               and ppp1.change_date < ppp.change_date
               and ppp1.approved = 'Y')
   and paf_prev.assignment_id (+) = ppp_prev.assignment_id
   and ppp_prev.change_date between paf_prev.effective_start_date (+) and
                                    paf_prev.effective_end_date (+)
   and paf_prev.pay_basis_id = ppb_prev.pay_basis_id (+);
--
    cursor c_person_info is
       select cpi.effective_date
       from   ben_cwb_person_info cpi
       where  cpi.group_per_in_ler_id = p_group_per_in_ler_id;

  --ER:8369634
    cursor csr_grp_plan_extra_info(p_group_pl_id number)
    is
    select PLI_INFORMATION4 show_appraisals_n_days
    from ben_pl_extra_info
    where INFORMATION_TYPE='CWB_CUSTOM_DOWNLOAD'
    and pl_id = p_group_pl_id;

--

  l_data_freeze_date date;
  l_effective_date date;
  l_lf_evt_ocrd_dt date;
  l_from_benmngle varchar2(1);
  l_cpi_effective_date date;
  l_assignment_id      number;
  l_group_pl_id        number;
  l_rec_modified       boolean := false;
  l_pay_annualization_factor number;
  l_fte_annual_salary number;
  l_annual_grd_min_val number;
  l_annual_grd_mid_point number;
  l_annual_grd_max_val number;
  l_salary_1_year_ago c_sal_info%rowtype;
  l_salary_2_year_ago c_sal_info%rowtype;
  l_salary_3_year_ago c_sal_info%rowtype;
  l_salary_4_year_ago c_sal_info%rowtype;
  l_salary_5_year_ago c_sal_info%rowtype;
  l_survey_info       c_survey_info%rowtype;
  l_appraisal_n_days  number := null;
--
   l_proc     varchar2(72) := g_package||'refresh_person_info';
--
begin
   --
   ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'refresh_person_info';
   ben_manage_cwb_life_events.g_error_log_rec.step_number := 211;
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- get the performance_rating_type from pl_dsgn. This value is same
   -- for all plans and oipls in a group plan.

   select pldsgn.emp_interview_typ_cd, pldsgn.data_freeze_date,
          pil.lf_evt_ocrd_dt, pil.group_pl_id, pil.assignment_id
   into l_performance_rating_type, l_data_freeze_date,
        l_lf_evt_ocrd_dt, l_group_pl_id, l_assignment_id
   from ben_cwb_pl_dsgn pldsgn
       ,ben_per_in_ler pil
   where pil.per_in_ler_id = p_group_per_in_ler_id
   and   pil.group_pl_id   = pldsgn.pl_id
   and   pil.lf_evt_ocrd_dt = pldsgn.lf_evt_ocrd_dt
   and   pldsgn.oipl_id = -1 ;
   --
   open  c_person_info;
   fetch c_person_info into l_cpi_effective_date;
   close c_person_info;
   --
   -- the effective_date for fetching date track tables is
   -- 1. p_effective_date,
   -- 2. effective_date on person_info rec,
   -- 3. data_freeze_date from pl_dsgn table,
   -- 4. lf_evt_ocrd_dt
   if p_effective_date is not null then
     l_effective_date := p_effective_date;
   elsif l_cpi_effective_date is not null then
     l_effective_date := l_cpi_effective_date;
   elsif l_data_freeze_date is not null then
     l_effective_date := l_data_freeze_date;
   else
     l_effective_date := l_lf_evt_ocrd_dt;
   end if;
   --
   if (p_called_from_benmngle) then
      l_from_benmngle := 'Y';
   else
      l_from_benmngle := 'N';
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
     --vkodedal get the salary suvey id from EIT setup

   open c_survey_id(l_group_pl_id);
   fetch c_survey_id into g_salary_survey_id;
   close c_survey_id;
   --
    if g_debug then
      hr_utility.set_location('c_survey_id:'|| g_salary_survey_id, 15);
   end if;
   --
   --ER:8369634
   for l_grp_plan_extra_info in csr_grp_plan_extra_info(l_group_pl_id) loop
	l_appraisal_n_days := to_number(l_grp_plan_extra_info.show_appraisals_n_days);
   end loop;
   if g_debug then
      hr_utility.set_location('show_appraisals_n_days:'|| l_appraisal_n_days, 15);
   end if;

   -- Open the cursor and update the details in ben_cwb_person_info
   -- It always should return only one row, but using the for to avoid
   -- the declaration of too many local variables.

   for perinfo_rec in csr_person_info(
            p_group_per_in_ler_id => p_group_per_in_ler_id
           ,p_effective_date      => l_effective_date
           ,p_from_benmngle       => l_from_benmngle
	   ,p_appraisal_n_days    => l_appraisal_n_days) loop
     --
     ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'refresh_person_info';
     ben_manage_cwb_life_events.g_error_log_rec.step_number := 212;
     --
     l_salary_1_year_ago := get_salary_info(perinfo_rec.assignment_id,
                                            add_months(l_effective_date,-12));
     if l_salary_1_year_ago.assignment_id is not null then
       l_salary_2_year_ago := get_salary_info(perinfo_rec.assignment_id,
                                            add_months(l_effective_date,-24));
     end if;
     if l_salary_2_year_ago.assignment_id is not null then
       l_salary_3_year_ago := get_salary_info(perinfo_rec.assignment_id,
                                            add_months(l_effective_date,-36));
     end if;
     if l_salary_3_year_ago.assignment_id is not null then
       l_salary_4_year_ago := get_salary_info(perinfo_rec.assignment_id,
                                            add_months(l_effective_date,-48));
     end if;
     if l_salary_4_year_ago.assignment_id is not null then
       l_salary_5_year_ago := get_salary_info(perinfo_rec.assignment_id,
                                            add_months(l_effective_date,-60));
     end if;
     --
     if g_salary_survey_id is not null and
        perinfo_rec.job_id is not null then
       l_survey_info := get_survey_info(perinfo_rec.job_id, l_effective_date);
     end if;
     --
     l_rec_modified := true;
     --
     -- If a person has hourly salary, then adjust the pay annualization factor
     -- to reflect his part time pay, for calculations.
     -- Calculate fte annual salary, grd vals as per the annualization factor.
     --
     if('HOURLY' = perinfo_rec.base_salary_frequency) then
         l_pay_annualization_factor := perinfo_rec.pay_annualization_factor * perinfo_rec.fte_factor;
     else
         l_pay_annualization_factor := perinfo_rec.pay_annualization_factor;
     end if;
     --
     l_fte_annual_salary := perinfo_rec.base_salary * l_pay_annualization_factor / perinfo_rec.fte_factor;
     l_annual_grd_min_val   := perinfo_rec.grd_min_val * perinfo_rec.grade_annualization_factor;
     l_annual_grd_mid_point := perinfo_rec.grd_mid_point * perinfo_rec.grade_annualization_factor;
     l_annual_grd_max_val   := perinfo_rec.grd_max_val * perinfo_rec.grade_annualization_factor;
     --
     if l_cpi_effective_date is not null then
      update ben_cwb_person_info
      set  person_id                 = perinfo_rec.person_id
          ,supervisor_id             = perinfo_rec.supervisor_id
          ,assignment_id             = perinfo_rec.assignment_id
          ,effective_date            = perinfo_rec.effective_date
          ,full_name                 = perinfo_rec.full_name
          ,brief_name                = perinfo_rec.brief_name
          ,custom_name               = perinfo_rec.custom_name
          ,supervisor_full_name      = perinfo_rec.supervisor_full_name
          ,supervisor_brief_name     = perinfo_rec.supervisor_brief_name
          ,supervisor_custom_name    = perinfo_rec.supervisor_custom_name
          ,legislation_code          = perinfo_rec.legislation_code
          ,years_employed            = perinfo_rec.years_employed
          ,years_in_job              = perinfo_rec.years_in_job
          ,years_in_position         = perinfo_rec.years_in_position
          ,years_in_grade            = perinfo_rec.years_in_grade
          ,employee_number           = perinfo_rec.employee_number
          ,start_date                = perinfo_rec.start_date
          ,original_start_date       = perinfo_rec.original_start_date
          ,adjusted_svc_date         = perinfo_rec.adjusted_svc_date
          ,base_salary               = perinfo_rec.base_salary
          ,base_salary_change_date   = perinfo_rec.base_salary_change_date
          ,payroll_name              = perinfo_rec.payroll_name
          ,performance_rating        = perinfo_rec.performance_rating
          ,performance_rating_type   = l_performance_rating_type
          ,performance_rating_date   = perinfo_rec.performance_rating_date
          ,business_group_id         = perinfo_rec.business_group_id
          ,organization_id           = perinfo_rec.organization_id
          ,job_id                    = perinfo_rec.job_id
          ,grade_id                  = perinfo_rec.grade_id
          ,position_id               = perinfo_rec.position_id
          ,people_group_id           = perinfo_rec.people_group_id
          ,soft_coding_keyflex_id    = perinfo_rec.soft_coding_keyflex_id
          ,location_id               = perinfo_rec.location_id
          ,pay_rate_id               = perinfo_rec.pay_rate_id
          ,grade_annulization_factor = perinfo_rec.grade_annualization_factor
          ,pay_annulization_factor   = perinfo_rec.pay_annualization_factor
          ,grd_min_val               = perinfo_rec.grd_min_val
          ,grd_max_val               = perinfo_rec.grd_max_val
          ,grd_mid_point             = perinfo_rec.grd_mid_point
          ,emp_category              = perinfo_rec.emp_category
          ,change_reason             = perinfo_rec.change_reason
          ,normal_hours              = perinfo_rec.normal_hours
          ,email_address             = perinfo_rec.email_address
          ,base_salary_frequency     = perinfo_rec.base_salary_frequency
          ,assignment_status_type_id = perinfo_rec.assignment_status_type_id
          ,frequency                 = perinfo_rec.frequency
          ,grd_quartile              = get_grd_quartile
                                       (l_fte_annual_salary
                                       ,l_annual_grd_min_val
                                       ,l_annual_grd_max_val
                                       ,l_annual_grd_mid_point)
          ,grd_comparatio            = get_grd_comparatio
                                       (l_fte_annual_salary
                                       ,l_annual_grd_mid_point)
          ,custom_segment1           = perinfo_rec.custom_segment1
          ,custom_segment2           = perinfo_rec.custom_segment2
          ,custom_segment3           = perinfo_rec.custom_segment3
          ,custom_segment4           = perinfo_rec.custom_segment4
          ,custom_segment5           = perinfo_rec.custom_segment5
          ,custom_segment6           = perinfo_rec.custom_segment6
          ,custom_segment7           = perinfo_rec.custom_segment7
          ,custom_segment8           = perinfo_rec.custom_segment8
          ,custom_segment9           = perinfo_rec.custom_segment9
          ,custom_segment10          = perinfo_rec.custom_segment10
          ,custom_segment11          = perinfo_rec.custom_segment11
          ,custom_segment12          = perinfo_rec.custom_segment12
          ,custom_segment13          = perinfo_rec.custom_segment13
          ,custom_segment14          = perinfo_rec.custom_segment14
          ,custom_segment15          = perinfo_rec.custom_segment15
          ,custom_segment16          = perinfo_rec.custom_segment16
          ,custom_segment17          = perinfo_rec.custom_segment17
          ,custom_segment18          = perinfo_rec.custom_segment18
          ,custom_segment19          = perinfo_rec.custom_segment19
          ,custom_segment20          = perinfo_rec.custom_segment20
          ,ass_attribute_category    = perinfo_rec.ass_attribute_category
          ,ass_attribute1            = perinfo_rec.ass_attribute1
          ,ass_attribute2            = perinfo_rec.ass_attribute2
          ,ass_attribute3            = perinfo_rec.ass_attribute3
          ,ass_attribute4            = perinfo_rec.ass_attribute4
          ,ass_attribute5            = perinfo_rec.ass_attribute5
          ,ass_attribute6            = perinfo_rec.ass_attribute6
          ,ass_attribute7            = perinfo_rec.ass_attribute7
          ,ass_attribute8            = perinfo_rec.ass_attribute8
          ,ass_attribute9            = perinfo_rec.ass_attribute9
          ,ass_attribute10           = perinfo_rec.ass_attribute10
          ,ass_attribute11           = perinfo_rec.ass_attribute11
          ,ass_attribute12           = perinfo_rec.ass_attribute12
          ,ass_attribute13           = perinfo_rec.ass_attribute13
          ,ass_attribute14           = perinfo_rec.ass_attribute14
          ,ass_attribute15           = perinfo_rec.ass_attribute15
          ,ass_attribute16           = perinfo_rec.ass_attribute16
          ,ass_attribute17           = perinfo_rec.ass_attribute17
          ,ass_attribute18           = perinfo_rec.ass_attribute18
          ,ass_attribute19           = perinfo_rec.ass_attribute19
          ,ass_attribute20           = perinfo_rec.ass_attribute20
          ,ass_attribute21           = perinfo_rec.ass_attribute21
          ,ass_attribute22           = perinfo_rec.ass_attribute22
          ,ass_attribute23           = perinfo_rec.ass_attribute23
          ,ass_attribute24           = perinfo_rec.ass_attribute24
          ,ass_attribute25           = perinfo_rec.ass_attribute25
          ,ass_attribute26           = perinfo_rec.ass_attribute26
          ,ass_attribute27           = perinfo_rec.ass_attribute27
          ,ass_attribute28           = perinfo_rec.ass_attribute28
          ,ass_attribute29           = perinfo_rec.ass_attribute29
          ,ass_attribute30           = perinfo_rec.ass_attribute30
          ,people_group_name         = perinfo_rec.people_group_name
          ,people_group_segment1     = perinfo_rec.people_group_segment1
          ,people_group_segment2     = perinfo_rec.people_group_segment2
          ,people_group_segment3     = perinfo_rec.people_group_segment3
          ,people_group_segment4     = perinfo_rec.people_group_segment4
          ,people_group_segment5     = perinfo_rec.people_group_segment5
          ,people_group_segment6     = perinfo_rec.people_group_segment6
          ,people_group_segment7     = perinfo_rec.people_group_segment7
          ,people_group_segment8     = perinfo_rec.people_group_segment8
          ,people_group_segment9     = perinfo_rec.people_group_segment9
          ,people_group_segment10    = perinfo_rec.people_group_segment10
          ,people_group_segment11    = perinfo_rec.people_group_segment11
          ,group_pl_id                  = perinfo_rec.group_pl_id
          ,lf_evt_ocrd_dt               = perinfo_rec.lf_evt_ocrd_dt
          ,fte_factor                   = perinfo_rec.fte_factor
          ,grd_quintile                 = get_grd_quintile
                                       (l_fte_annual_salary
                                       ,l_annual_grd_min_val
                                       ,l_annual_grd_max_val)
          ,grd_decile                   = get_grd_decile
                                       (l_fte_annual_salary
                                       ,l_annual_grd_min_val
                                       ,l_annual_grd_max_val)
          ,grd_pct_in_range             = get_grd_pct_in_range
                                        (l_fte_annual_salary
                                        ,l_annual_grd_min_val
                                        ,l_annual_grd_max_val)
          ,grade_rate_frequency         = perinfo_rec.grade_rate_frequency
          ,base_salary_currency         = perinfo_rec.base_salary_currency
          ,salary_1_year_ago            = l_salary_1_year_ago.salary
          ,salary_1_year_ago_frequency  = l_salary_1_year_ago.salary_frequency
          ,salary_1_year_ago_currency   = l_salary_1_year_ago.salary_currency
          ,salary_1_year_ago_ann_fctr   = decode(l_salary_1_year_ago.salary_frequency
                                                ,'HOURLY',l_salary_1_year_ago.salary_ann_fctr * l_salary_1_year_ago.fte_factor
                                                ,l_salary_1_year_ago.salary_ann_fctr)
          ,salary_2_year_ago            = l_salary_2_year_ago.salary
          ,salary_2_year_ago_frequency  = l_salary_2_year_ago.salary_frequency
          ,salary_2_year_ago_currency   = l_salary_2_year_ago.salary_currency
          ,salary_2_year_ago_ann_fctr   = decode(l_salary_2_year_ago.salary_frequency
                                                ,'HOURLY',l_salary_2_year_ago.salary_ann_fctr * l_salary_2_year_ago.fte_factor
                                                ,l_salary_2_year_ago.salary_ann_fctr)
          ,salary_3_year_ago            = l_salary_3_year_ago.salary
          ,salary_3_year_ago_frequency  = l_salary_3_year_ago.salary_frequency
          ,salary_3_year_ago_currency   = l_salary_3_year_ago.salary_currency
          ,salary_3_year_ago_ann_fctr   = decode(l_salary_3_year_ago.salary_frequency
                                                ,'HOURLY',l_salary_3_year_ago.salary_ann_fctr * l_salary_3_year_ago.fte_factor
                                                ,l_salary_3_year_ago.salary_ann_fctr)
          ,salary_4_year_ago            = l_salary_4_year_ago.salary
          ,salary_4_year_ago_frequency  = l_salary_4_year_ago.salary_frequency
          ,salary_4_year_ago_currency   = l_salary_4_year_ago.salary_currency
          ,salary_4_year_ago_ann_fctr   = decode(l_salary_4_year_ago.salary_frequency
                                                ,'HOURLY',l_salary_4_year_ago.salary_ann_fctr * l_salary_4_year_ago.fte_factor
                                                ,l_salary_4_year_ago.salary_ann_fctr)
          ,salary_5_year_ago            = l_salary_5_year_ago.salary
          ,salary_5_year_ago_frequency  = l_salary_5_year_ago.salary_frequency
          ,salary_5_year_ago_currency   = l_salary_5_year_ago.salary_currency
          ,salary_5_year_ago_ann_fctr   = decode(l_salary_5_year_ago.salary_frequency
                                                ,'HOURLY',l_salary_5_year_ago.salary_ann_fctr * l_salary_5_year_ago.fte_factor
                                                ,l_salary_5_year_ago.salary_ann_fctr)
          ,prev_sal                     = perinfo_rec.prev_sal
          ,prev_sal_frequency           = perinfo_rec.prev_sal_frequency
          ,prev_sal_currency            = perinfo_rec.prev_sal_currency
          ,prev_sal_ann_fctr            = decode(perinfo_rec.prev_sal_frequency
                                                ,'HOURLY',perinfo_rec.prev_sal_ann_fctr * perinfo_rec.prev_fte_factor
                                                ,perinfo_rec.prev_sal_ann_fctr)
          ,prev_sal_chg_date            = perinfo_rec.prev_sal_chg_date
          ,prev_sal_chg_rsn             = perinfo_rec.prev_sal_chg_rsn
          ,mkt_currency                 = l_survey_info.currency
          ,mkt_frequency                = l_survey_info.frequency
          ,mkt_annualization_factor     = l_survey_info.annualization_factor
          ,mkt_min_salary               = l_survey_info.min_salary
          ,mkt_25pct_salary             = l_survey_info.pct25_salary
          ,mkt_mid_salary               = l_survey_info.mid_salary
          ,mkt_75pct_salary             = l_survey_info.pct75_salary
          ,mkt_max_salary               = l_survey_info.max_salary
          ,mkt_emp_quartile             =  null
          ,mkt_emp_pct_in_range         =  null
          ,mkt_emp_comparatio           =  null
          ,mkt_survey_id                = l_survey_info.survey_id
          ,current_pay_proposal_id      = perinfo_rec.current_pay_proposal_id
	  ,appraisal_id                 = perinfo_rec.appraisal_id
      where  group_per_in_ler_id = perinfo_rec.group_per_in_ler_id;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
     else
      -- The record does not exist. So insert the new record
      --
      insert into ben_cwb_person_info
                 (group_per_in_ler_id
                 ,person_id
                 ,supervisor_id
                 ,assignment_id
                 ,effective_date
                 ,full_name
                 ,brief_name
                 ,custom_name
                 ,supervisor_full_name
                 ,supervisor_brief_name
                 ,supervisor_custom_name
                 ,legislation_code
                 ,years_employed
                 ,years_in_job
                 ,years_in_position
                 ,years_in_grade
                 ,employee_number
                 ,start_date
                 ,original_start_date
                 ,adjusted_svc_date
                 ,base_salary
                 ,base_salary_change_date
                 ,payroll_name
                 ,performance_rating
                 ,performance_rating_type
                 ,performance_rating_date
                 ,business_group_id
                 ,organization_id
                 ,job_id
                 ,grade_id
                 ,position_id
                 ,people_group_id
                 ,soft_coding_keyflex_id
                 ,location_id
                 ,pay_rate_id
                 ,assignment_status_type_id
                 ,frequency
                 ,grade_annulization_factor
                 ,pay_annulization_factor
                 ,grd_min_val
                 ,grd_max_val
                 ,grd_mid_point
                 ,grd_quartile
                 ,grd_comparatio
                 ,emp_category
                 ,change_reason
                 ,normal_hours
                 ,email_address
                 ,base_salary_frequency
                 ,custom_segment1
                 ,custom_segment2
                 ,custom_segment3
                 ,custom_segment4
                 ,custom_segment5
                 ,custom_segment6
                 ,custom_segment7
                 ,custom_segment8
                 ,custom_segment9
                 ,custom_segment10
                 ,custom_segment11
                 ,custom_segment12
                 ,custom_segment13
                 ,custom_segment14
                 ,custom_segment15
                 ,custom_segment16
                 ,custom_segment17
                 ,custom_segment18
                 ,custom_segment19
                 ,custom_segment20
                 ,ass_attribute_category
                 ,ass_attribute1
                 ,ass_attribute2
                 ,ass_attribute3
                 ,ass_attribute4
                 ,ass_attribute5
                 ,ass_attribute6
                 ,ass_attribute7
                 ,ass_attribute8
                 ,ass_attribute9
                 ,ass_attribute10
                 ,ass_attribute11
                 ,ass_attribute12
                 ,ass_attribute13
                 ,ass_attribute14
                 ,ass_attribute15
                 ,ass_attribute16
                 ,ass_attribute17
                 ,ass_attribute18
                 ,ass_attribute19
                 ,ass_attribute20
                 ,ass_attribute21
                 ,ass_attribute22
                 ,ass_attribute23
                 ,ass_attribute24
                 ,ass_attribute25
                 ,ass_attribute26
                 ,ass_attribute27
                 ,ass_attribute28
                 ,ass_attribute29
                 ,ass_attribute30
                 ,people_group_name
                 ,people_group_segment1
                 ,people_group_segment2
                 ,people_group_segment3
                 ,people_group_segment4
                 ,people_group_segment5
                 ,people_group_segment6
                 ,people_group_segment7
                 ,people_group_segment8
                 ,people_group_segment9
                 ,people_group_segment10
                 ,people_group_segment11
                 ,object_version_number
		 ,group_pl_id
		 ,lf_evt_ocrd_dt
		 ,fte_factor
		 ,grd_quintile
		 ,grd_decile
		 ,grd_pct_in_range
		 ,grade_rate_frequency
		 ,base_salary_currency
		 ,salary_1_year_ago
		 ,salary_1_year_ago_frequency
		 ,salary_1_year_ago_currency
		 ,salary_1_year_ago_ann_fctr
		 ,salary_2_year_ago
		 ,salary_2_year_ago_frequency
		 ,salary_2_year_ago_currency
		 ,salary_2_year_ago_ann_fctr
		 ,salary_3_year_ago
		 ,salary_3_year_ago_frequency
		 ,salary_3_year_ago_currency
		 ,salary_3_year_ago_ann_fctr
		 ,salary_4_year_ago
		 ,salary_4_year_ago_frequency
		 ,salary_4_year_ago_currency
		 ,salary_4_year_ago_ann_fctr
		 ,salary_5_year_ago
		 ,salary_5_year_ago_frequency
		 ,salary_5_year_ago_currency
		 ,salary_5_year_ago_ann_fctr
		 ,prev_sal
		 ,prev_sal_frequency
		 ,prev_sal_currency
		 ,prev_sal_ann_fctr
		 ,prev_sal_chg_date
		 ,prev_sal_chg_rsn
		 ,mkt_currency
		 ,mkt_frequency
		 ,mkt_annualization_factor
		 ,mkt_min_salary
		 ,mkt_25pct_salary
		 ,mkt_mid_salary
		 ,mkt_75pct_salary
		 ,mkt_max_salary
		 ,mkt_emp_quartile
		 ,mkt_emp_pct_in_range
		 ,mkt_emp_comparatio
		 ,mkt_survey_id
		 ,current_pay_proposal_id
		 ,appraisal_id)
      values     (p_group_per_in_ler_id
                 ,perinfo_rec.person_id
                 ,perinfo_rec.supervisor_id
                 ,perinfo_rec.assignment_id
                 ,perinfo_rec.effective_date
                 ,perinfo_rec.full_name
                 ,perinfo_rec.brief_name
                 ,perinfo_rec.custom_name
                 ,perinfo_rec.supervisor_full_name
                 ,perinfo_rec.supervisor_brief_name
                 ,perinfo_rec.supervisor_custom_name
                 ,perinfo_rec.legislation_code
                 ,perinfo_rec.years_employed
                 ,perinfo_rec.years_in_job
                 ,perinfo_rec.years_in_position
                 ,perinfo_rec.years_in_grade
                 ,perinfo_rec.employee_number
                 ,perinfo_rec.start_date
                 ,perinfo_rec.original_start_date
                 ,perinfo_rec.adjusted_svc_date
                 ,perinfo_rec.base_salary
                 ,perinfo_rec.base_salary_change_date
                 ,perinfo_rec.payroll_name
                 ,perinfo_rec.performance_rating
                 ,l_performance_rating_type
                 ,perinfo_rec.performance_rating_date
                 ,perinfo_rec.business_group_id
                 ,perinfo_rec.organization_id
                 ,perinfo_rec.job_id
                 ,perinfo_rec.grade_id
                 ,perinfo_rec.position_id
                 ,perinfo_rec.people_group_id
                 ,perinfo_rec.soft_coding_keyflex_id
                 ,perinfo_rec.location_id
                 ,perinfo_rec.pay_rate_id
                 ,perinfo_rec.assignment_status_type_id
                 ,perinfo_rec.frequency
                 ,perinfo_rec.grade_annualization_factor
                 ,perinfo_rec.pay_annualization_factor
                 ,perinfo_rec.grd_min_val
                 ,perinfo_rec.grd_max_val
                 ,perinfo_rec.grd_mid_point
                 ,get_grd_quartile
                    (l_fte_annual_salary
                    ,l_annual_grd_min_val
                    ,l_annual_grd_max_val
                    ,l_annual_grd_mid_point)
                 ,get_grd_comparatio
                    (l_fte_annual_salary
                    ,l_annual_grd_mid_point)
                 ,perinfo_rec.emp_category
                 ,perinfo_rec.change_reason
                 ,perinfo_rec.normal_hours
                 ,perinfo_rec.email_address
                 ,perinfo_rec.base_salary_frequency
                 ,perinfo_rec.custom_segment1
                 ,perinfo_rec.custom_segment2
                 ,perinfo_rec.custom_segment3
                 ,perinfo_rec.custom_segment4
                 ,perinfo_rec.custom_segment5
                 ,perinfo_rec.custom_segment6
                 ,perinfo_rec.custom_segment7
                 ,perinfo_rec.custom_segment8
                 ,perinfo_rec.custom_segment9
                 ,perinfo_rec.custom_segment10
                 ,perinfo_rec.custom_segment11
                 ,perinfo_rec.custom_segment12
                 ,perinfo_rec.custom_segment13
                 ,perinfo_rec.custom_segment14
                 ,perinfo_rec.custom_segment15
                 ,perinfo_rec.custom_segment16
                 ,perinfo_rec.custom_segment17
                 ,perinfo_rec.custom_segment18
                 ,perinfo_rec.custom_segment19
                 ,perinfo_rec.custom_segment20
                 ,perinfo_rec.ass_attribute_category
                 ,perinfo_rec.ass_attribute1
                 ,perinfo_rec.ass_attribute2
                 ,perinfo_rec.ass_attribute3
                 ,perinfo_rec.ass_attribute4
                 ,perinfo_rec.ass_attribute5
                 ,perinfo_rec.ass_attribute6
                 ,perinfo_rec.ass_attribute7
                 ,perinfo_rec.ass_attribute8
                 ,perinfo_rec.ass_attribute9
                 ,perinfo_rec.ass_attribute10
                 ,perinfo_rec.ass_attribute11
                 ,perinfo_rec.ass_attribute12
                 ,perinfo_rec.ass_attribute13
                 ,perinfo_rec.ass_attribute14
                 ,perinfo_rec.ass_attribute15
                 ,perinfo_rec.ass_attribute16
                 ,perinfo_rec.ass_attribute17
                 ,perinfo_rec.ass_attribute18
                 ,perinfo_rec.ass_attribute19
                 ,perinfo_rec.ass_attribute20
                 ,perinfo_rec.ass_attribute21
                 ,perinfo_rec.ass_attribute22
                 ,perinfo_rec.ass_attribute23
                 ,perinfo_rec.ass_attribute24
                 ,perinfo_rec.ass_attribute25
                 ,perinfo_rec.ass_attribute26
                 ,perinfo_rec.ass_attribute27
                 ,perinfo_rec.ass_attribute28
                 ,perinfo_rec.ass_attribute29
                 ,perinfo_rec.ass_attribute30
                 ,perinfo_rec.people_group_name
                 ,perinfo_rec.people_group_segment1
                 ,perinfo_rec.people_group_segment2
                 ,perinfo_rec.people_group_segment3
                 ,perinfo_rec.people_group_segment4
                 ,perinfo_rec.people_group_segment5
                 ,perinfo_rec.people_group_segment6
                 ,perinfo_rec.people_group_segment7
                 ,perinfo_rec.people_group_segment8
                 ,perinfo_rec.people_group_segment9
                 ,perinfo_rec.people_group_segment10
                 ,perinfo_rec.people_group_segment11
                 ,1	-- insert 1 as the ovn
		 ,perinfo_rec.group_pl_id
		 ,perinfo_rec.lf_evt_ocrd_dt
		 ,perinfo_rec.fte_factor
		 ,get_grd_quintile
          (l_fte_annual_salary
          ,l_annual_grd_min_val
          ,l_annual_grd_max_val)
         ,get_grd_decile
          (l_fte_annual_salary
          ,l_annual_grd_min_val
          ,l_annual_grd_max_val)
		 ,get_grd_pct_in_range
          (l_fte_annual_salary
          ,l_annual_grd_min_val
          ,l_annual_grd_max_val)
	 ,perinfo_rec.grade_rate_frequency
	 ,perinfo_rec.base_salary_currency
	 ,l_salary_1_year_ago.salary
	 ,l_salary_1_year_ago.salary_frequency
	 ,l_salary_1_year_ago.salary_currency
	 ,decode(l_salary_1_year_ago.salary_frequency
          ,'HOURLY',l_salary_1_year_ago.salary_ann_fctr * l_salary_1_year_ago.fte_factor
            ,l_salary_1_year_ago.salary_ann_fctr)
         ,l_salary_2_year_ago.salary
         ,l_salary_2_year_ago.salary_frequency
         ,l_salary_2_year_ago.salary_currency
         ,decode(l_salary_2_year_ago.salary_frequency
          ,'HOURLY',l_salary_2_year_ago.salary_ann_fctr * l_salary_2_year_ago.fte_factor
            ,l_salary_2_year_ago.salary_ann_fctr)
         ,l_salary_3_year_ago.salary
         ,l_salary_3_year_ago.salary_frequency
         ,l_salary_3_year_ago.salary_currency
         ,decode(l_salary_3_year_ago.salary_frequency
          ,'HOURLY',l_salary_3_year_ago.salary_ann_fctr * l_salary_3_year_ago.fte_factor
            ,l_salary_3_year_ago.salary_ann_fctr)
         ,l_salary_4_year_ago.salary
         ,l_salary_4_year_ago.salary_frequency
         ,l_salary_4_year_ago.salary_currency
         ,decode(l_salary_4_year_ago.salary_frequency
          ,'HOURLY',l_salary_4_year_ago.salary_ann_fctr * l_salary_4_year_ago.fte_factor
            ,l_salary_4_year_ago.salary_ann_fctr)
         ,l_salary_5_year_ago.salary
         ,l_salary_5_year_ago.salary_frequency
         ,l_salary_5_year_ago.salary_currency
         ,decode(l_salary_5_year_ago.salary_frequency
          ,'HOURLY',l_salary_5_year_ago.salary_ann_fctr * l_salary_5_year_ago.fte_factor
            ,l_salary_5_year_ago.salary_ann_fctr)
		 ,perinfo_rec.prev_sal
		 ,perinfo_rec.prev_sal_frequency
		 ,perinfo_rec.prev_sal_currency
		 ,decode(perinfo_rec.prev_sal_frequency
                ,'HOURLY',perinfo_rec.prev_sal_ann_fctr * perinfo_rec.prev_fte_factor
                ,perinfo_rec.prev_sal_ann_fctr)
		 ,perinfo_rec.prev_sal_chg_date
		 ,perinfo_rec.prev_sal_chg_rsn
		 ,l_survey_info.currency
		 ,l_survey_info.frequency
		 ,l_survey_info.annualization_factor
		 ,l_survey_info.min_salary
		 ,l_survey_info.pct25_salary
		 ,l_survey_info.mid_salary
		 ,l_survey_info.pct75_salary
		 ,l_survey_info.max_salary
		 , null
		 , null
		 , null
		 ,l_survey_info.survey_id
		 ,perinfo_rec.current_pay_proposal_id
		 ,perinfo_rec.appraisal_id
       );
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      -- ************ audit changes ****************** --
      ben_cwb_audit_api.create_per_record
      (p_per_in_ler_id => p_group_per_in_ler_id);
      -- ********************************************* --

    end if;
    --
    -- If not called from benmngle, run dynamic calculations.
    --
    if perinfo_rec.person_id <> -1 then
      ben_cwb_dyn_calc_pkg.run_dynamic_calculations(
            p_group_per_in_ler_id => p_group_per_in_ler_id
           ,p_group_pl_id         => perinfo_rec.group_pl_id
           ,p_lf_evt_ocrd_dt      => perinfo_rec.lf_evt_ocrd_dt);
    end if;
    -- Only one record, so exit.
    exit;
    --
   end loop; -- of for
   --
   -- Create a dummy record if called from benmngle and the person does
   -- not exist as of the freeze date (effective_date).
   --
   if p_called_from_benmngle and not(l_rec_modified) and
      l_cpi_effective_date is null then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      if l_assignment_id is not null then
        insert into ben_cwb_person_info
              (group_per_in_ler_id
              ,person_id
              ,assignment_id
              ,effective_date
              ,full_name
              ,object_version_number
              ,group_pl_id
              ,lf_evt_ocrd_dt)
        values
             (p_group_per_in_ler_id
             ,-1
             ,l_assignment_id
             ,l_effective_date
             ,'Person Data does not exist as of freeze date for assignment: '||
              l_assignment_id ||'. Request your administrator to refresh person.'
             ,1
             ,l_group_pl_id
             ,l_lf_evt_ocrd_dt);
        -- ************ audit changes ****************** --
        ben_cwb_audit_api.create_per_record
        (p_per_in_ler_id => p_group_per_in_ler_id);
        -- ********************************************* --
        if g_debug then
          hr_utility.set_location(l_proc, 60);
        end if;
        --
      end if;
      --
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- of refresh_person_info
--
-- --------------------------------------------------------------------------
-- |--------------------< refresh_person_info_group_pl >---------------------|
-- --------------------------------------------------------------------------
procedure refresh_person_info_group_pl(p_group_pl_id    in number
                                      ,p_lf_evt_ocrd_dt in date
                                      ,p_effective_date in date) is

cursor csr_pil is
select pil.per_in_ler_id
from ben_per_in_ler pil
where pil.group_pl_id = p_group_pl_id
and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
and pil.assignment_id is not null
and pil.per_in_ler_stat_cd in ('STRTD','PROCD');
--
   l_count number := 0;
   l_proc     varchar2(72) := g_package||'refresh_person_info_group_pl';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- for each record in csr_pil
   for pil in csr_pil loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      refresh_person_info(p_group_per_in_ler_id => pil.per_in_ler_id
                         ,p_effective_date      => p_effective_date);
      --
      l_count := l_count + 1;
      if l_count = 10 then
        commit;
        l_count := 0;
      end if;
      --
   end loop;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_quartile >--------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This function is referred by refresh_person_info
function get_grd_quartile(p_salary in number
                         ,p_min    in number
                         ,p_max    in number
                         ,p_mid    in number)
return varchar2 is
--
   l_return_value varchar2(30) := null;
--
   l_proc     varchar2(72) := g_package||'get_grd_quartile';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if p_salary is not null then
      if p_salary < p_min then
         l_return_value := 'BLW';
      elsif p_salary > p_max then
         l_return_value := 'ABV';
      elsif p_salary < (p_mid + p_min)/2 then
         l_return_value := '1';
      elsif p_salary < p_mid then
         l_return_value := '2';
      elsif p_salary >= (p_mid+p_max)/2 then
         l_return_value := '4';
      elsif p_salary >= p_mid then
         l_return_value := '3';
      end if;
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
   return l_return_value;
   --
end; -- end of get_grd_quartile
--
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_quintile >--------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This function is referred by refresh_person_info
function get_grd_quintile(p_salary in number
                         ,p_min    in number
                         ,p_max    in number)
return varchar2 is
--
   l_return_value varchar2(30) := null;
--
   l_proc     varchar2(72) := g_package||'get_grd_quintile';
   l_step     NUMBER       := (p_max-p_min)/5;
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if p_salary is not null and l_step is not null then
      if p_salary < p_min then
         l_return_value := 'BLW';
      elsif p_salary > p_max then
         l_return_value := 'ABV';
      elsif p_salary < (p_min + l_step) then
         l_return_value := '1';
      elsif p_salary < (p_min + l_step*2) then
         l_return_value := '2';
      elsif p_salary < (p_min + l_step*3) then
         l_return_value := '3';
      elsif p_salary < (p_min + l_step*4) then
         l_return_value := '4';
      elsif p_salary <= p_max THEN
         l_return_value := '5';
      end if;
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
   return l_return_value;
   --
end; -- end of get_grd_quintile
--
--
-- --------------------------------------------------------------------------
-- |----------------------------< get_grd_decile >---------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This function is referred by refresh_person_info
function get_grd_decile(p_salary in number
                       ,p_min    in number
                       ,p_max    in number)
return varchar2 is
--
   l_return_value varchar2(30) := null;
--
   l_proc     varchar2(72) := g_package||'get_grd_decile';
   l_step     NUMBER       := (p_max-p_min)/10;
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if p_salary is not null and l_step is not null then
      if p_salary < p_min then
         l_return_value := 'BLW';
      elsif p_salary > p_max then
         l_return_value := 'ABV';
      elsif p_salary < (p_min + l_step) then
         l_return_value := '1';
      elsif p_salary < (p_min + l_step*2) then
         l_return_value := '2';
      elsif p_salary < (p_min + l_step*3) then
         l_return_value := '3';
      elsif p_salary < (p_min + l_step*4) then
         l_return_value := '4';
      elsif p_salary < (p_min + l_step*5) then
         l_return_value := '5';
      elsif p_salary < (p_min + l_step*6) then
         l_return_value := '6';
      elsif p_salary < (p_min + l_step*7) then
         l_return_value := '7';
      elsif p_salary < (p_min + l_step*8) then
         l_return_value := '8';
      elsif p_salary < (p_min + l_step*9) then
         l_return_value := '9';
      elsif p_salary <= p_max THEN
         l_return_value := '10';
      end if;
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
   return l_return_value;
   --
end; -- end of get_grd_decile
--
--
--
-- --------------------------------------------------------------------------
-- |------------------------< get_grd_pct_in_range >------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This function is referred by refresh_person_info
function get_grd_pct_in_range(p_salary in number
                             ,p_min    in number
                             ,p_max    in number)
return number is
--
   l_return_value varchar2(30) := null;
--
   l_proc       varchar2(72) := g_package||'get_grd_pct_in_range';
   l_range      NUMBER       := (p_max-p_min);
   l_min_to_sal NUMBER       := (p_salary-p_min);
   l_return_val NUMBER       := NULL;
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if l_range = 0 then
      return l_return_val;
   end if;
   --
   l_return_val := round((l_min_to_sal / l_range * 100),1);
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
   return l_return_val;
   --
end; -- end of get_grd_pct_in_range
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_grd_comparatio >-------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This function is referred by refresh_person_info
function get_grd_comparatio(p_salary in number
                           ,p_mid    in number)
return number is
--
   l_proc     varchar2(72) := g_package||'get_grd_comparatio';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if p_salary is null or p_mid  is null or p_mid <= 0 then
      return null;
   else
      return round(p_salary/p_mid*100,3);
   end if;
end; -- end of get_grd_comparatio
--
-- --------------------------------------------------------------------------
-- |--------------------------< refresh_from_master >-----------------------|
-- --------------------------------------------------------------------------
-- Description
--      This procedure is used only by the admin page to refresh the person
-- info. This procedure checks if th effective_date column in ben_cwb_pl_dsgn
-- is null. If it is, the p_effective_date will be passed to
-- refresh_person_info. Otherwise null will be passed to refresh_person_info
-- so that it will use effective_date column in pl_dsgn.
procedure refresh_from_master(p_group_per_in_ler_id in number
                             ,p_effective_date in date) is
--
   l_effective_date date;
--
   l_proc     varchar2(72) := g_package||'refresh_from_master';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select pl.effective_date into l_effective_date
   from ben_cwb_pl_dsgn pl
       ,ben_per_in_ler pil
   where pil.per_in_ler_id = p_group_per_in_ler_id
   and   pl.pl_id = pil.group_pl_id
   and   pl.lf_evt_ocrd_dt = pil.lf_evt_ocrd_dt
   and   pl.group_oipl_id = -1;

   if l_effective_date is null then
      -- data_freeze_date is null. So refresh shoule be based on
      -- user provided effective_date
      l_effective_date := p_effective_date;
   else
      -- data_freeze_date is not null. So refresh should not use
      -- user provided effective_date. Pass null.
      l_effective_date := null;
   end if;
   --
   if g_debug then
     hr_utility.set_location(l_proc, 30);
   end if;
   --
   -- call refresh_person_info
   refresh_person_info(p_group_per_in_ler_id => p_group_per_in_ler_id
                      ,p_effective_date      => l_effective_date);
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end;
--
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_salary_currency >------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This function is referred by refresh_person_info
function get_salary_currency(p_input_value_id in number
			    ,p_effective_date in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_salary_currency';
   l_currency varchar2(15);
--
   cursor csr_currency
   is
   select pet.input_currency_code
     from pay_input_values_f piv,
	  pay_element_types_f pet
    where piv.input_value_id = p_input_value_id
      and p_effective_date between piv.effective_start_date and piv.effective_end_date
      and piv.element_type_id = pet.element_type_id
      and p_effective_date between pet.effective_start_date and pet.effective_end_date;
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
      open  csr_currency;
      fetch csr_currency into l_currency;
      close csr_currency;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
   return l_currency;
end;
--
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_fte_factor >---------------------------|
-- --------------------------------------------------------------------------
FUNCTION get_fte_factor(p_assignment_id IN NUMBER
                       ,p_effective_date IN DATE)
return NUMBER IS

/*
CURSOR csr_fte_fctr
IS
SELECT
decode(g_fte_factor,
       'NHBGWH',(select normal_hours /decode(fnd_number.canonical_to_number(working_hours), 0, to_number(NULL)
                                            ,fnd_number.canonical_to_number(working_hours))
                  from per_all_assignments_f asg,
                       per_business_groups bg
                 where asg.assignment_id = p_assignment_id
                   and asg.business_group_id = bg.business_group_id
                   and p_effective_date BETWEEN effective_start_date AND effective_end_date),
        'BFTE',  (select value
                    from per_assignment_budget_values_f
                   where assignment_id   = p_assignment_id
                     and unit = 'FTE'
                     and p_effective_date BETWEEN effective_start_date AND effective_end_date),
        'BPFT',  (select value
                    from per_assignment_budget_values_f
                   where assignment_id    = p_assignment_id
                     and unit = 'PFT'
                     and p_effective_date BETWEEN effective_start_date AND effective_end_date),
        'NC', 1, 1)
FROM
DUAL;

l_fte_factor NUMBER := null;
*/

BEGIN
--
/*
OPEN csr_fte_fctr;
FETCH csr_fte_fctr INTO l_fte_factor;
CLOSE csr_fte_fctr;
--
-- fte_factor should always be between 0 and 1.
-- if null, >1 or <0(improbable, still),  return 1.
--
if l_fte_factor is null OR l_fte_factor > 1 OR l_fte_factor < 0 then
 l_fte_factor := 1;
end if;
--
RETURN l_fte_factor;
*/

RETURN per_saladmin_utility.get_fte_factor(p_assignment_id
                                          ,p_effective_date);
--
END;
--
end BEN_CWB_PERSON_INFO_PKG;
--

/
