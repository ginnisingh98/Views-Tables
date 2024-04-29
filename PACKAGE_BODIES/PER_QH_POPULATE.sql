--------------------------------------------------------
--  DDL for Package Body PER_QH_POPULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_POPULATE" as
/* $Header: peqhpopl.pkb 120.3 2006/09/29 12:46:30 rvarshne noship $ */
--
-- Package Variables
--
  g_package varchar2(33):='per_qh_populate.';
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_location >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_location
  (p_location_id number) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_location';
  l_location_name hr_locations.location_code%type;
  --
  cursor csr_location is
  /*select location_code
  from hr_locations
  where location_id=p_location_id;*/
  --Modified as per bug 5504410
  --
  SELECT lot.location_code
  from hr_locations_all hrl, hr_locations_all_tl lot
  where hrl.location_id = lot.location_id
  and lot.language = userenv('LANG')
  and hrl.location_id=p_location_id;

  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_location;
  fetch csr_location into l_location_name;
  close csr_location;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_location_name;
end get_location;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_organization >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_organization
  (p_organization_id number) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_organization';
  l_organization_name hr_all_organization_units.name%type;
  --
  cursor csr_organization is
  select hotl.name
  from hr_all_organization_units ho
  ,    hr_all_organization_units_tl hotl
  where ho.organization_id=p_organization_id
  and hotl.organization_id=ho.organization_id
  and hotl.language=userenv('LANG');
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  if p_organization_id is not null then
    open csr_organization;
    fetch csr_organization into l_organization_name;
    close csr_organization;
  else
    l_organization_name:=null;
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_organization_name;
end get_organization;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_job >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_job
  (p_job_id number) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_job';
  l_job_name per_jobs.name%type;
  --
  cursor csr_job is
  select name
  from per_jobs_vl
  where job_id=p_job_id;
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  if p_job_id is not null then
    open csr_job;
    fetch csr_job into l_job_name;
    close csr_job;
  else
    l_job_name:=null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,20);
  return l_job_name;
end get_job;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_position >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_position
  (p_position_id number
  ,p_effective_date date) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_position';
  l_position_name hr_all_positions.name%type;
  --
  -- PMFLETCH - MLS enabled name
  --
  cursor csr_position is
  select name
  from hr_all_positions_f_tl
  where position_id=p_position_id
    and language = userenv('LANG');
  -- PMFLETCH - Effective date no longer used, MLS name is always eot value
  --and p_effective_date between effective_start_date and effective_end_date;
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  if p_position_id is not null then
    open csr_position;
    fetch csr_position into l_position_name;
    close csr_position;
  else
    l_position_name:=null;
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_position_name;
end get_position;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_salary_basis >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_salary_basis
  (p_pay_basis_id   IN     number
  ,p_pay_basis         OUT NOCOPY varchar2
  ,p_pay_basis_meaning OUT NOCOPY VARCHAR2
  ,p_salary_basis      OUT NOCOPY VARCHAR2) is
  --
  l_proc varchar2(72) :=g_package||'get_salary_basis';
  l_salary_basis_name per_pay_bases.name%type;
  --
  cursor csr_salary_basis is
  select ppb.name
  ,      ppb.pay_basis
  from   per_pay_bases ppb
  where  ppb.pay_basis_id=p_pay_basis_id;
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_salary_basis;
  fetch csr_salary_basis into p_salary_basis,p_pay_basis;
  close csr_salary_basis;
  p_pay_basis_meaning:=hr_reports.get_lookup_meaning('PAY_BASIS',p_pay_basis);
  hr_utility.set_location('Leaving: '||l_proc,20);
end get_salary_basis;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_payroll >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_payroll
  (p_payroll_id number
  ,p_effective_date date) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_payroll';
  l_payroll_name pay_all_payrolls_f.payroll_name%type;
  --
  cursor csr_payroll is
  select payroll_name
  from pay_all_payrolls_f
  where payroll_id=p_payroll_id
  and p_effective_date between effective_start_date and effective_end_date;
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_payroll;
  fetch csr_payroll into l_payroll_name;
  close csr_payroll;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_payroll_name;
end get_payroll;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_full_name >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_full_name
  (p_person_id number
  ,p_effective_date date) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_full_name';
  l_full_name per_all_people_f.full_name%type;
  --
  cursor csr_full_name is
  select full_name
  from per_all_people_f
  where person_id=p_person_id
  and p_effective_date between effective_start_date and effective_end_date;
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_full_name;
  fetch csr_full_name into l_full_name;
  close csr_full_name;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_full_name;
end get_full_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_supervisor_assgn_number >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_supervisor_assgn_number
  (p_supervisor_assgn_id   number
  ,p_business_group_id     number) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_supervisor_assgn_number';
  l_super_assgn_num    per_assignments_v.supervisor_assignment_number%type;
  --
  cursor csr_super_assgn_num is
  select supervisor_assignment_number
  from per_assignments_v
  where supervisor_assignment_id = p_supervisor_assgn_id
  and business_group_id = p_business_group_id;

  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_super_assgn_num;
  fetch csr_super_assgn_num into l_super_assgn_num;
  close csr_super_assgn_num;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_super_assgn_num;
end get_supervisor_assgn_number;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_grade >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_grade
  (p_grade_id number) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_grade';
  l_grade_name per_grades.name%type;
  --
  cursor csr_grade is
  select name
  from per_grades_vl
  where grade_id=p_grade_id;
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_grade;
  fetch csr_grade into l_grade_name;
  close csr_grade;
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_grade_name;
end get_grade;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_grade_ladder >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_grade_ladder
  (p_grade_ladder_pgm_id number
  ,p_effective_date      date) return varchar2 is
  --
  l_proc varchar2(72) :=g_package||'get_grade_ladder';
  l_grade_ladder_name ben_pgm_f.name%type;
  --
  cursor csr_grade_ladder is
  select name
  from  ben_pgm_f
  where pgm_id = p_grade_ladder_pgm_id
  and   p_effective_date
        between effective_start_date and effective_end_date;
  --
  begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  open csr_grade_ladder;
  fetch csr_grade_ladder into l_grade_ladder_name;
  close csr_grade_ladder;
  hr_utility.trace('l_grade_ladder_name : ' || l_grade_ladder_name);
  hr_utility.set_location('Leaving: '||l_proc,20);
  return l_grade_ladder_name;
end get_grade_ladder;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_bg_defaults >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_bg_defaults
  (p_business_group_id IN     per_business_groups.business_group_id%type
  ,p_defaulting        IN     varchar2
  ,p_time_normal_start    OUT NOCOPY per_all_assignments_f.time_normal_start%type
  ,p_time_normal_finish   OUT NOCOPY per_all_assignments_f.time_normal_finish%type
  ,p_normal_hours         OUT NOCOPY per_all_assignments_f.normal_hours%type
  ,p_frequency         IN OUT NOCOPY per_all_assignments_f.frequency%type
  ,p_frequency_meaning    OUT NOCOPY hr_lookups.meaning%type
  ,p_location_id       IN OUT NOCOPY per_all_assignments_f.location_id%type
  ,p_location             OUT NOCOPY hr_locations.location_code%type
  ,p_gre                  OUT NOCOPY hr_soft_coding_keyflex.segment1%type
  ) is
  --
  l_proc varchar2(72) :=g_package||'get_bg_defaults';
  l_normal_hours varchar2(150);
  l_location_id        per_all_assignments_f.location_id%type;
  --
  cursor get_work_day_information is
  select org_information1
  ,      org_information2
  ,      org_information3
  ,      org_information4
  from   hr_organization_information
  where  organization_id=p_business_group_id
  and    org_information_context='Work Day Information';
  --
  cursor get_gre_information is
  select org_information1
  from   hr_organization_information
  where  organization_id=p_business_group_id
  and    org_information_context='DEFAULT_GRE_INFO';
  --
  cursor get_loc is
  select location_id
  from hr_all_organization_units
  where organization_id=p_business_group_id;
  --
  begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_defaulting in ('C','S') then
    open get_work_day_information;
    fetch get_work_day_information into
     p_time_normal_start
    ,p_time_normal_finish
    ,l_normal_hours
    ,p_frequency;
    if get_work_day_information%found then
      close get_work_day_information;
      p_normal_hours:=fnd_number.canonical_to_number(l_normal_hours);
    else
      close get_work_day_information;
    end if;
    --
    hr_utility.set_location(l_proc,20);
    open get_gre_information;
    fetch get_gre_information into p_gre;
    close get_gre_information;
    --
    hr_utility.set_location(l_proc,30);
    open get_loc;
    fetch get_loc into l_location_id;
    if get_loc%found then
      close get_loc;
      if l_location_id is not null then
        p_location_id:=l_location_id;
      end if;
    else
      close get_loc;
    end if;
  end if;
    --
  p_frequency_meaning:=hr_reports.get_lookup_meaning('FREQUENCY',p_frequency);
  p_location:=get_location(l_location_id);
  hr_utility.set_location('Leaving: '||l_proc,50);
end get_bg_defaults;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_pos_defaults >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_pos_defaults
  (p_position_id        IN     per_all_assignments_f.position_id%type
  ,p_effective_date     IN     date
  ,p_defaulting         IN     varchar2
  ,p_organization_id    IN OUT NOCOPY per_all_assignments_f.organization_id%type
  ,p_organization          OUT NOCOPY hr_organization_units.name%type
  ,p_job_id             IN OUT NOCOPY per_all_assignments_f.job_id%type
  ,p_job                   OUT NOCOPY per_jobs.name%type
  ,p_vacancy_id         IN OUT NOCOPY per_vacancies.vacancy_id%type
  ,p_vacancy            IN OUT NOCOPY per_vacancies.name%type
  ,p_time_normal_start  IN OUT NOCOPY per_all_assignments_f.time_normal_start%type
  ,p_time_normal_finish IN OUT NOCOPY per_all_assignments_f.time_normal_finish%type
  ,p_normal_hours       IN OUT NOCOPY per_all_assignments_f.normal_hours%type
  ,p_frequency          IN OUT NOCOPY per_all_assignments_f.frequency%type
  ,p_frequency_meaning     OUT NOCOPY hr_lookups.meaning%type
  ,p_location_id        IN OUT NOCOPY per_all_assignments_f.location_id%type
  ,p_location              OUT NOCOPY hr_locations.location_code%type
  ,p_probation_period   IN OUT NOCOPY per_all_assignments_f.probation_period%type
  ,p_probation_unit     IN OUT NOCOPY per_all_assignments_f.probation_unit%type
  ,p_probation_unit_meaning OUT NOCOPY hr_lookups.meaning%type
  ,p_pay_basis_id       IN OUT NOCOPY per_all_assignments_f.pay_basis_id%type
  ,p_salary_basis          OUT NOCOPY per_pay_bases.name%type
  ,p_pay_basis             OUT NOCOPY per_pay_bases.pay_basis%type
  ,p_pay_basis_meaning     OUT NOCOPY hr_lookups.meaning%type
  ,p_payroll_id         IN OUT NOCOPY per_all_assignments_f.payroll_id%type
  ,p_payroll               OUT NOCOPY pay_all_payrolls_f.payroll_name%type
  ,p_supervisor_id      IN OUT NOCOPY per_all_assignments_f.supervisor_id%type
  ,p_supervisor            OUT NOCOPY per_all_people_f.full_name%type
  ,p_grade_id           IN OUT NOCOPY per_all_assignments_f.grade_id%type
  ,p_grade                 OUT NOCOPY per_grades.name%type
  ,p_bargaining_unit    IN OUT NOCOPY per_all_assignments_f.bargaining_unit_code%type
  ,p_bargaining_unit_meaning OUT NOCOPY hr_lookups.meaning%type
) is
  --
  l_proc varchar2(72) :=g_package||'get_pos_defaults';
  l_position_id        per_all_assignments_f.position_id%type;
  l_organization_id    per_all_assignments_f.organization_id%type;
  l_old_organization_id per_all_assignments_f.organization_id%type;
  l_job_id             per_all_assignments_f.job_id%type;
  l_time_normal_start  per_all_assignments_f.time_normal_start%type;
  l_time_normal_finish per_all_assignments_f.time_normal_finish%type;
  l_normal_hours       per_all_assignments_f.normal_hours%type;
  l_frequency          per_all_assignments_f.frequency%type;
  l_location_id        per_all_assignments_f.location_id%type;
  l_probation_period   per_all_assignments_f.probation_period%type;
  l_probation_unit     per_all_assignments_f.probation_unit%type;
  l_pay_basis_id       per_all_assignments_f.pay_basis_id%type;
  l_payroll_id         per_all_assignments_f.payroll_id%type;
  l_supervisor_id      per_all_assignments_f.supervisor_id%type;
  l_grade_id           per_all_assignments_f.grade_id%type;
  l_frequency_meaning     hr_lookups.meaning%type;
  l_location              hr_locations.location_code%type;
  l_probation_unit_meaning hr_lookups.meaning%type;
  l_salary_basis          per_pay_bases.name%type;
  l_pay_basis             per_pay_bases.pay_basis%type;
  l_payroll               pay_all_payrolls_f.payroll_name%type;
  l_supervisor            per_all_people_f.full_name%type;
  l_bargaining_unit       hr_all_positions_f.bargaining_unit_cd%type;
  l_dummy                 number;
--
  cursor get_pos_defs is
  select organization_id
  ,      job_id
  ,      time_normal_start
  ,      time_normal_finish
  ,      working_hours
  ,      frequency
  ,      location_id
  ,      probation_period
  ,      probation_period_unit_cd
  ,      pay_basis_id
  ,      pay_freq_payroll_id
  ,      supervisor_id
  ,      entry_grade_id
  ,      bargaining_unit_cd
  from   hr_all_positions_f
  where  position_id=p_position_id
  and    p_effective_date between effective_start_date and effective_end_date;
  --
  cursor get_vac is
  select position_id
  from per_vacancies
  where vacancy_id=p_vacancy_id
  and p_effective_date between date_from and nvl(date_to,p_effective_date);
--
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_vacancy_id is not null then
    open get_vac;
    fetch get_vac into l_position_id;
    close get_vac;
    if l_position_id is not null and p_position_id is not null then
      if l_position_id<>p_position_id then
        p_vacancy_id:=null;
        p_vacancy:=null;
      end if;
    end if;
  end if;
    --
  l_old_organization_id:=p_organization_id;
  --
  if p_defaulting in ('C','S') then
    open get_pos_defs;
    fetch get_pos_defs into
     l_organization_id
    ,l_job_id
    ,l_time_normal_start
    ,l_time_normal_finish
    ,l_normal_hours
    ,l_frequency
    ,l_location_id
    ,l_probation_period
    ,l_probation_unit
    ,l_pay_basis_id
    ,l_payroll_id
    ,l_supervisor_id
    ,l_grade_id
    ,l_bargaining_unit;
    --
    close get_pos_defs;
    hr_utility.set_location(l_pay_basis_id||l_proc,20);
    p_organization_id:=l_organization_id;
    p_job_id:=l_job_id;
    --
    if p_time_normal_start is null then
      p_time_normal_start:=l_time_normal_start;
    end if;
    if p_time_normal_finish is null then
      p_time_normal_finish:=l_time_normal_finish;
    end if;
    if p_frequency is null then
      p_frequency:=l_frequency;
    end if;
    if p_normal_hours is null then
      p_normal_hours:=l_normal_hours;
    end if;
    if p_location_id is null then
      p_location_id:=l_location_id;
    end if;
    if p_probation_period is null then
      p_probation_period:=l_probation_period;
    end if;
    if p_probation_unit is null then
      p_probation_unit:=l_probation_unit;
    end if;
    if p_pay_basis_id is null then
      p_pay_basis_id:=l_pay_basis_id;
    end if;
    if p_payroll_id is null then
      p_payroll_id:=l_payroll_id;
    end if;
    if p_supervisor_id is null then
      p_supervisor_id:=l_supervisor_id;
    end if;
    if p_grade_id is null then
      p_grade_id:=l_grade_id;
    end if;
    if p_bargaining_unit is null then
      p_bargaining_unit:=l_bargaining_unit;
    end if;
    --
    if p_defaulting='C'
    and l_organization_id<>l_old_organization_id then
      --
      get_org_defaults
      (p_organization_id    => l_organization_id
      ,p_defaulting         => p_defaulting
      ,p_effective_date     => p_effective_date
      ,p_vacancy_id         => p_vacancy_id
      ,p_vacancy            => p_vacancy
      ,p_time_normal_start  => l_time_normal_start
      ,p_time_normal_finish => l_time_normal_finish
      ,p_normal_hours       => l_normal_hours
      ,p_frequency          => l_frequency
      ,p_frequency_meaning  => l_frequency_meaning
      ,p_location_id        => l_location_id
      ,p_location           => l_location
      ,p_probation_period   => l_probation_period
      ,p_probation_unit     => l_probation_unit
      ,p_probation_unit_meaning => l_probation_unit_meaning
      ,p_pay_basis_id       => l_pay_basis_id
      ,p_salary_basis       => l_salary_basis
      ,p_pay_basis          => l_pay_basis
      ,p_pay_basis_meaning  => p_pay_basis_meaning
      ,p_payroll_id         => l_payroll_id
      ,p_payroll            => l_payroll
      ,p_supervisor_id      => l_supervisor_id
      ,p_supervisor         => l_supervisor
      ,p_position_id        => l_dummy
      );
       --
      if p_time_normal_start is null then
        p_time_normal_start:=l_time_normal_start;
      end if;
      if p_time_normal_finish is null then
        p_time_normal_finish:=l_time_normal_finish;
      end if;
      if p_frequency is null then
        p_frequency:=l_frequency;
      end if;
      if p_normal_hours is null then
        p_normal_hours:=l_normal_hours;
      end if;
      if p_location_id is null then
        p_location_id:=l_location_id;
      end if;
      if p_probation_period is null then
        p_probation_period:=l_probation_period;
      end if;
      if p_probation_unit is null then
        p_probation_unit:=l_probation_unit;
      end if;
      if p_pay_basis_id is null then
        p_pay_basis_id:=l_pay_basis_id;
      end if;
      if p_payroll_id is null then
        p_payroll_id:=l_payroll_id;
      end if;
      if p_supervisor_id is null then
        p_supervisor_id:=l_supervisor_id;
      end if;
    end if;
  end if;
  p_organization:=get_organization(p_organization_id);
  p_job:=get_job(p_job_id);
  p_frequency_meaning:=hr_reports.get_lookup_meaning('FREQUENCY',p_frequency);
  p_location:=get_location(p_location_id);
  p_probation_unit_meaning:=hr_reports.get_lookup_meaning('QUALIFYING_UNITS',p_probation_unit);
  get_salary_basis(p_pay_basis_id
                  ,p_pay_basis
                  ,p_pay_basis_meaning
                  ,p_salary_basis);
  hr_utility.set_location(p_pay_basis_id||p_salary_basis||l_proc,45);

  p_payroll:=get_payroll(p_payroll_id,p_effective_date);
  p_supervisor:=get_full_name(p_supervisor_id,p_effective_date);
  p_grade:=get_grade(p_grade_id);
  p_bargaining_unit_meaning:=hr_reports.get_lookup_meaning('BARGAINING_UNIT_CODE',p_bargaining_unit);
  hr_utility.set_location('Leaving: '||l_proc,50);
end get_pos_defaults;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_org_defaults >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_org_defaults
  (p_organization_id    IN     per_all_assignments_f.organization_id%type
  ,p_defaulting         IN     varchar2
  ,p_effective_date     IN     date
  ,p_vacancy_id         IN OUT NOCOPY per_vacancies.vacancy_id%type
  ,p_vacancy            IN OUT NOCOPY per_vacancies.name%type
  ,p_time_normal_start  IN OUT NOCOPY per_all_assignments_f.time_normal_start%type
  ,p_time_normal_finish IN OUT NOCOPY per_all_assignments_f.time_normal_finish%type
  ,p_normal_hours       IN OUT NOCOPY per_all_assignments_f.normal_hours%type
  ,p_frequency          IN OUT NOCOPY per_all_assignments_f.frequency%type
  ,p_frequency_meaning     OUT NOCOPY hr_lookups.meaning%type
  ,p_location_id        IN OUT NOCOPY per_all_assignments_f.location_id%type
  ,p_location              OUT NOCOPY hr_locations.location_code%type
  ,p_probation_period   IN OUT NOCOPY per_all_assignments_f.probation_period%type
  ,p_probation_unit     IN OUT NOCOPY per_all_assignments_f.probation_unit%type
  ,p_probation_unit_meaning OUT NOCOPY hr_lookups.meaning%type
  ,p_pay_basis_id       IN OUT NOCOPY per_all_assignments_f.pay_basis_id%type
  ,p_salary_basis          OUT NOCOPY per_pay_bases.name%type
  ,p_pay_basis             OUT NOCOPY per_pay_bases.pay_basis%type
  ,p_pay_basis_meaning     OUT NOCOPY hr_lookups.meaning%type
  ,p_payroll_id         IN OUT NOCOPY per_all_assignments_f.payroll_id%type
  ,p_payroll               OUT NOCOPY pay_all_payrolls_f.payroll_name%type
  ,p_supervisor_id      IN OUT NOCOPY per_all_assignments_f.supervisor_id%type
  ,p_supervisor            OUT NOCOPY per_all_people_f.full_name%type
  ,p_position_id        IN OUT NOCOPY per_all_assignments_f.position_id%type
  ) is
   --
  l_proc varchar2(72) :=g_package||'get_org_defaults';
  l_normal_hours       varchar2(150);
  l_probation_period   varchar2(150);
  l_time_normal_start  per_all_assignments_f.time_normal_start%type;
  l_time_normal_finish per_all_assignments_f.time_normal_finish%type;
  l_frequency          per_all_assignments_f.frequency%type;
  l_location_id        per_all_assignments_f.location_id%type;
  l_probation_unit     per_all_assignments_f.probation_unit%type;
  l_pay_basis_id       per_all_assignments_f.pay_basis_id%type;
  l_payroll_id         per_all_assignments_f.payroll_id%type;
  l_supervisor_id      per_all_assignments_f.supervisor_id%type;
  l_grade_id           per_all_assignments_f.grade_id%type;
  l_organization_id    per_all_assignments_f.organization_id%type;
  l_dummy              number;
--
  cursor get_work_day_information is
  select org_information1
  ,      org_information2
  ,      org_information3
  ,      org_information4
  from   hr_organization_information
  where  organization_id=p_organization_id
  and    org_information_context='Work Day Information';
  --
  cursor get_org_information is
  select org_information1
  ,      org_information2
  ,      org_information3
  ,      org_information4
  ,      org_information5
  from   hr_organization_information
  where  organization_id=p_organization_id
  and    org_information_context='DEFAULT_HR_INFO';
  --
  cursor get_loc is
  select location_id
  from hr_all_organization_units
  where organization_id=p_organization_id;
  --
  --
  cursor get_vac is
  select organization_id
  from per_vacancies
  where vacancy_id=p_vacancy_id
  and p_effective_date between date_from and nvl(date_to,p_effective_date);
  --
  cursor chk_pos_org(ln_position_id number
                    ,ln_organization_id number) is
  select 1
  from hr_positions_f
  where organization_id=ln_organization_id
  and position_id=ln_position_id
  and p_effective_date between effective_start_date
  and effective_end_date;
  --
  --
  begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  open get_vac;
  fetch get_vac into l_organization_id;
  close get_vac;
  if l_organization_id is not null and p_organization_id is not null then
    if l_organization_id<>p_organization_id then
      p_vacancy_id:=null;
      p_vacancy:=null;
    end if;
  end if;
  --
  open chk_pos_org(p_position_id,p_organization_id);
  fetch chk_pos_org into l_dummy;
  if chk_pos_org%notfound then
    close chk_pos_org;
    p_position_id :=null;
  else
    close chk_pos_org;
  end if;

  if p_defaulting in ('C','S') then
    open get_work_day_information;
    fetch get_work_day_information into
     l_time_normal_start
    ,l_time_normal_finish
    ,l_normal_hours
    ,l_frequency;
    if get_work_day_information%found then
      close get_work_day_information;
      -- added the ' or ' conditions for the following if statements bug 4629833
      if p_time_normal_start is null or (p_time_normal_start <> l_time_normal_start) then
        p_time_normal_start:=l_time_normal_start;
      end if;
      if p_time_normal_finish is null or (p_time_normal_finish <>l_time_normal_finish) then
        p_time_normal_finish:=l_time_normal_finish;
      end if;
      --modified if condition as part of bug 4898869
     -- if p_normal_hours is null or (p_normal_hours <> l_normal_hours) then
      if p_normal_hours is null or (p_normal_hours <> fnd_number.canonical_to_number(l_normal_hours)) then
        p_normal_hours:=fnd_number.canonical_to_number(l_normal_hours);
      end if;
      if p_frequency is null or (p_frequency <> l_frequency ) then
        p_frequency:=l_frequency;
      end if;
      -- end of bug 4629833
    else
      close get_work_day_information;
    end if;
    --
    hr_utility.set_location(l_proc,20);
    open get_loc;
    fetch get_loc into l_location_id;
    if get_loc%found then
      close get_loc;
      if p_location_id is null then
        p_location_id:=l_location_id;
      end if;
    else
      close get_loc;
    end if;
    --
    hr_utility.set_location(l_proc,30);
    open get_org_information;
    fetch get_org_information into
     p_payroll_id
    ,l_supervisor_id
    ,l_pay_basis_id
    ,l_probation_period
    ,l_probation_unit;
    if get_org_information%found then
      close get_org_information;
      if p_payroll_id is null then
        p_payroll_id:=l_payroll_id;
      end if;
      if p_supervisor_id is null then
        p_supervisor_id:=l_supervisor_id;
      end if;
      if p_pay_basis_id is null then
        p_pay_basis_id:=l_pay_basis_id;
      end if;
      if p_probation_period is null then
        p_probation_period:=fnd_number.canonical_to_number(l_probation_period);
      end if;
      if p_probation_unit is null then
        p_probation_unit:=l_probation_unit;
      end if;
    else
      close get_org_information;
    end if;
    --
  end if;
  p_frequency_meaning:=hr_reports.get_lookup_meaning('FREQUENCY',p_frequency);
  p_location:=get_location(p_location_id); --Bug 3099072. Passed id in place of location.
  p_probation_unit_meaning:=hr_reports.get_lookup_meaning('QUALIFYING_UNITS',p_probation_unit);
  get_salary_basis(p_pay_basis_id
                  ,p_pay_basis
                  ,p_pay_basis_meaning
                  ,p_salary_basis);
  p_supervisor:=get_full_name(p_supervisor_id,p_effective_date);
  p_payroll:=get_payroll(p_payroll_id,p_effective_date);
  hr_utility.set_location('Leaving: '||l_proc,50);
end get_org_defaults;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_vac_defaults >----------------------------|
-- ----------------------------------------------------------------------------
--
   procedure get_vac_defaults
  (p_vacancy_id         IN     per_all_assignments_f.vacancy_id%type
  ,p_defaulting         IN     varchar2
  ,p_effective_date     IN     date
  ,p_recruiter_id       IN OUT NOCOPY per_all_assignments_f.recruiter_id%type
  ,p_recruiter             OUT NOCOPY per_all_people_f.full_name%type
  ,p_grade_id           IN OUT NOCOPY per_all_assignments_f.grade_id%type
  ,p_grade                 OUT NOCOPY per_grades.name%type
  ,p_position_id        IN OUT NOCOPY per_all_assignments_f.position_id%type
  ,p_position              OUT NOCOPY hr_all_positions_f.name%type
  ,p_job_id             IN OUT NOCOPY per_all_assignments_f.job_id%type
  ,p_job                   OUT NOCOPY per_jobs.name%type
  ,p_location_id        IN OUT NOCOPY per_all_assignments_f.location_id%type
  ,p_location              OUT NOCOPY hr_locations.location_code%type
  ,p_organization_id    IN OUT NOCOPY per_all_assignments_f.organization_id%type
  ,p_organization          OUT NOCOPY hr_organization_units.name%type
  ,p_time_normal_start  IN OUT NOCOPY per_all_assignments_f.time_normal_start%type
  ,p_time_normal_finish IN OUT NOCOPY per_all_assignments_f.time_normal_finish%type
  ,p_normal_hours       IN OUT NOCOPY per_all_assignments_f.normal_hours%type
  ,p_frequency          IN OUT NOCOPY per_all_assignments_f.frequency%type
  ,p_frequency_meaning     OUT NOCOPY hr_lookups.meaning%type
  ,p_probation_period   IN OUT NOCOPY per_all_assignments_f.probation_period%type
  ,p_probation_unit     IN OUT NOCOPY per_all_assignments_f.probation_unit%type
  ,p_probation_unit_meaning OUT NOCOPY hr_lookups.meaning%type
  ,p_pay_basis_id       IN OUT NOCOPY per_all_assignments_f.pay_basis_id%type
  ,p_salary_basis          OUT NOCOPY per_pay_bases.name%type
  ,p_pay_basis             OUT NOCOPY per_pay_bases.pay_basis%type
  ,p_pay_basis_meaning     OUT NOCOPY hr_lookups.meaning%type
  ,p_payroll_id         IN OUT NOCOPY per_all_assignments_f.payroll_id%type
  ,p_payroll               OUT NOCOPY pay_all_payrolls_f.payroll_name%type
  ,p_supervisor_id      IN OUT NOCOPY per_all_assignments_f.supervisor_id%type
  ,p_supervisor            OUT NOCOPY per_all_people_f.full_name%type
  ,p_bargaining_unit    IN OUT NOCOPY per_all_assignments_f.bargaining_unit_code%type
  ,p_bargaining_unit_meaning OUT NOCOPY hr_lookups.meaning%type
  ,p_people_group_id    IN OUT NOCOPY per_all_assignments_f.people_group_id%type
  ,p_pgp_segment1          OUT NOCOPY pay_people_groups.segment1%type
  ,p_pgp_segment2          OUT NOCOPY pay_people_groups.segment2%type
  ,p_pgp_segment3          OUT NOCOPY pay_people_groups.segment3%type
  ,p_pgp_segment4          OUT NOCOPY pay_people_groups.segment4%type
  ,p_pgp_segment5          OUT NOCOPY pay_people_groups.segment5%type
  ,p_pgp_segment6          OUT NOCOPY pay_people_groups.segment6%type
  ,p_pgp_segment7          OUT NOCOPY pay_people_groups.segment7%type
  ,p_pgp_segment8          OUT NOCOPY pay_people_groups.segment8%type
  ,p_pgp_segment9          OUT NOCOPY pay_people_groups.segment9%type
  ,p_pgp_segment10         OUT NOCOPY pay_people_groups.segment10%type
  ,p_pgp_segment11         OUT NOCOPY pay_people_groups.segment11%type
  ,p_pgp_segment12         OUT NOCOPY pay_people_groups.segment12%type
  ,p_pgp_segment13         OUT NOCOPY pay_people_groups.segment13%type
  ,p_pgp_segment14         OUT NOCOPY pay_people_groups.segment14%type
  ,p_pgp_segment15         OUT NOCOPY pay_people_groups.segment15%type
  ,p_pgp_segment16         OUT NOCOPY pay_people_groups.segment16%type
  ,p_pgp_segment17         OUT NOCOPY pay_people_groups.segment17%type
  ,p_pgp_segment18         OUT NOCOPY pay_people_groups.segment18%type
  ,p_pgp_segment19         OUT NOCOPY pay_people_groups.segment19%type
  ,p_pgp_segment20         OUT NOCOPY pay_people_groups.segment20%type
  ,p_pgp_segment21         OUT NOCOPY pay_people_groups.segment21%type
  ,p_pgp_segment22         OUT NOCOPY pay_people_groups.segment22%type
  ,p_pgp_segment23         OUT NOCOPY pay_people_groups.segment23%type
  ,p_pgp_segment24         OUT NOCOPY pay_people_groups.segment24%type
  ,p_pgp_segment25         OUT NOCOPY pay_people_groups.segment25%type
  ,p_pgp_segment26         OUT NOCOPY pay_people_groups.segment26%type
  ,p_pgp_segment27         OUT NOCOPY pay_people_groups.segment27%type
  ,p_pgp_segment28         OUT NOCOPY pay_people_groups.segment28%type
  ,p_pgp_segment29         OUT NOCOPY pay_people_groups.segment29%type
  ,p_pgp_segment30         OUT NOCOPY pay_people_groups.segment30%type
  ) is
   --
  l_proc varchar2(72) :=g_package||'get_vac_defaults';
  l_recruiter_id      per_all_assignments_f.recruiter_id%type;
  l_grade_id          per_all_assignments_f.grade_id%type;
  l_position_id       per_all_assignments_f.position_id%type;
  l_old_position_id   per_all_assignments_f.position_id%type;
  l_job_id            per_all_assignments_f.job_id%type;
  l_location_id       per_all_assignments_f.location_id%type;
  l_organization_id   per_all_assignments_f.organization_id%type;
  l_people_group_id   per_all_assignments_f.people_group_id%type;
  l_pgp_rec           pay_people_groups%rowtype;
  l_vacancy_id        per_vacancies.vacancy_id%type;
  l_vacancy           per_vacancies.name%type;
  l_dummy             number;
 --
  cursor get_vac_details is
  select recruiter_id
  ,      grade_id
  ,      position_id
  ,      job_id
  ,      location_id
  ,      organization_id
  ,      people_group_id
  from   per_vacancies
  where vacancy_id=p_vacancy_id;
  --
  cursor get_pgp(pgp_id number) is
  select *
  from pay_people_groups
  where people_group_id=pgp_id;
  --
  cursor chk_job_pos(ln_job_id number
                    ,ln_position_id number) is
  select 1
  from hr_positions_f
  where job_id=ln_job_id
  and position_id=ln_position_id
  and p_effective_date between effective_start_date
  and effective_end_date;
  --
  cursor chk_pos_org(ln_position_id number
                    ,ln_organization_id number) is
  select 1
  from hr_positions_f
  where organization_id=ln_organization_id
  and position_id=ln_position_id
  and p_effective_date between effective_start_date
  and effective_end_date;
  --
  begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  l_old_position_id:=p_position_id;
  --
  if p_defaulting in ('C','S') then
    open get_vac_details;
    fetch get_vac_details into
     l_recruiter_id
    ,l_grade_id
    ,l_position_id
    ,l_job_id
    ,l_location_id
    ,l_organization_id
    ,l_people_group_id;
    if get_vac_details%found then
      close get_vac_details;
      if l_recruiter_id is not null then
        p_recruiter_id:=l_recruiter_id;
      end if;
      if l_grade_id is not null then
        p_grade_id:=l_grade_id;
      end if;
      if l_location_id is not null then
        p_location_id:=l_location_id;
      end if;
       if l_people_group_id is not null then
        p_people_group_id:=l_people_group_id;
      end if;
      --
      if l_job_id is not null then
        p_job_id:=l_job_id;
      end if;
      --
      if l_position_id is not null then
        p_position_id:=l_position_id;
        if l_job_id is null and p_job_id is not null then
          --
          -- we have set the position, but not the job, so check that
          -- the old job matches.
          --
          open chk_job_pos(p_job_id,p_position_id);
          fetch chk_job_pos into l_dummy;
          if chk_job_pos%notfound then
            close chk_job_pos;
            p_job_id:=null;
          else
            close chk_job_pos;
          end if;
        end if;
      elsif p_position_id is not null and l_job_id is not null then
        --
        -- we have set the job but not the position, so check that
        -- the old position matches
        --
        open chk_job_pos(p_job_id,p_position_id);
        fetch chk_job_pos into l_dummy;
        if chk_job_pos%notfound then
          close chk_job_pos;
          p_position_id:=null;
        else
          close chk_job_pos;
        end if;
      end if;
      --
      if l_organization_id is not null then
        p_organization_id:=l_organization_id;
        if l_position_id is null and p_position_id is not null then
          --
          -- we have set the organization, but not the position, so
          -- check that the old position matches.
          --
          open chk_pos_org(p_position_id,p_organization_id);
          fetch chk_pos_org into l_dummy;
          if chk_pos_org%notfound then
            close chk_pos_org;
            p_position_id :=null;
          else
            close chk_pos_org;
          end if;
        end if;
      elsif p_organization_id is not null and l_position_id is not null then
        --
        -- we have set the position, but not the organization, so
        -- check that the old organization matches.
        --
        open chk_pos_org(p_position_id,p_organization_id);
        fetch chk_pos_org into l_dummy;
        if chk_pos_org%notfound then
          close chk_pos_org;
          p_organization_id :=null;
        else
          close chk_pos_org;
        end if;
      end if;

    else
      close get_vac_details;
    end if;
    hr_utility.set_location(l_proc,20);
    open get_pgp(p_people_group_id);
    fetch get_pgp into l_pgp_rec;
    if get_pgp%found then
      close get_pgp;
      p_pgp_segment1    :=l_pgp_rec.segment1;
      p_pgp_segment2    :=l_pgp_rec.segment2;
      p_pgp_segment3    :=l_pgp_rec.segment3;
      p_pgp_segment4    :=l_pgp_rec.segment4;
      p_pgp_segment5    :=l_pgp_rec.segment5;
      p_pgp_segment6    :=l_pgp_rec.segment6;
      p_pgp_segment7    :=l_pgp_rec.segment7;
      p_pgp_segment8    :=l_pgp_rec.segment8;
      p_pgp_segment9    :=l_pgp_rec.segment9;
      p_pgp_segment10   :=l_pgp_rec.segment10;
      p_pgp_segment11   :=l_pgp_rec.segment11;
      p_pgp_segment12   :=l_pgp_rec.segment12;
      p_pgp_segment13   :=l_pgp_rec.segment13;
      p_pgp_segment14   :=l_pgp_rec.segment14;
      p_pgp_segment15   :=l_pgp_rec.segment15;
      p_pgp_segment16   :=l_pgp_rec.segment16;
      p_pgp_segment17   :=l_pgp_rec.segment17;
      p_pgp_segment18   :=l_pgp_rec.segment18;
      p_pgp_segment19   :=l_pgp_rec.segment19;
      p_pgp_segment20   :=l_pgp_rec.segment20;
      p_pgp_segment21   :=l_pgp_rec.segment21;
      p_pgp_segment22   :=l_pgp_rec.segment22;
      p_pgp_segment23   :=l_pgp_rec.segment23;
      p_pgp_segment24   :=l_pgp_rec.segment24;
      p_pgp_segment25   :=l_pgp_rec.segment25;
      p_pgp_segment26   :=l_pgp_rec.segment26;
      p_pgp_segment27   :=l_pgp_rec.segment27;
      p_pgp_segment28   :=l_pgp_rec.segment28;
      p_pgp_segment29   :=l_pgp_rec.segment29;
      p_pgp_segment30   :=l_pgp_rec.segment30;
    else
      close get_pgp;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  if p_defaulting='C'
    and l_position_id is not null
    and l_position_id <> nvl(l_old_position_id,hr_api.g_number) then
    get_pos_defaults
    (p_position_id        => l_position_id
    ,p_effective_date     => p_effective_date
    ,p_defaulting         => p_defaulting
    ,p_organization_id    => p_organization_id
    ,p_organization       => p_organization
    ,p_job_id             => p_job_id
    ,p_job                => p_job
    ,p_vacancy_id         => l_vacancy_id
    ,p_vacancy            => l_vacancy
    ,p_time_normal_start  => p_time_normal_start
    ,p_time_normal_finish => p_time_normal_finish
    ,p_normal_hours       => p_normal_hours
    ,p_frequency          => p_frequency
    ,p_frequency_meaning  => p_frequency_meaning
    ,p_location_id        => p_location_id
    ,p_location           => p_location
    ,p_probation_period   => p_probation_period
    ,p_probation_unit     => p_probation_unit
    ,p_probation_unit_meaning => p_probation_unit_meaning
    ,p_pay_basis_id       => p_pay_basis_id
    ,p_salary_basis       => p_salary_basis
    ,p_pay_basis          => p_pay_basis
    ,p_pay_basis_meaning  => p_pay_basis_meaning
    ,p_payroll_id         => p_payroll_id
    ,p_payroll            => p_payroll
    ,p_supervisor_id      => p_supervisor_id
    ,p_supervisor         => p_supervisor
    ,p_grade_id           => p_grade_id
    ,p_grade              => p_grade
    ,p_bargaining_unit    => p_bargaining_unit
    ,p_bargaining_unit_meaning => p_bargaining_unit_meaning
);
  end if;
  p_recruiter:=get_full_name(p_recruiter_id,p_effective_date);
  p_grade:=get_grade(p_grade_id);
  p_position:=get_position(p_position_id,p_effective_date);
  p_job:=get_job(p_job_id);
  p_location:=get_location(p_location_id);
  p_organization:=get_organization(p_organization_id);
  p_frequency_meaning:=hr_reports.get_lookup_meaning('FREQUENCY',p_frequency);
  p_probation_unit_meaning:=hr_reports.get_lookup_meaning('QUALIFYING_UNITS',p_probation_unit);
  get_salary_basis(p_pay_basis_id
                  ,p_pay_basis
                  ,p_pay_basis_meaning
                  ,p_salary_basis);
  p_supervisor:=get_full_name(p_supervisor_id,p_effective_date);
  p_payroll:=get_payroll(p_payroll_id,p_effective_date);
  hr_utility.set_location('Leaving: '||l_proc,50);
  end get_vac_defaults;

end per_qh_populate;

/
