--------------------------------------------------------
--  DDL for Package PER_QH_POPULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_POPULATE" AUTHID CURRENT_USER as
/* $Header: peqhpopl.pkh 115.7 2004/02/26 08:27:51 ptitoren noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< get_location >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_location
  (p_location_id number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_organization >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_organization
  (p_organization_id number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_job >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_job
  (p_job_id number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_position >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_position
  (p_position_id number
  ,p_effective_date date) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_salary_basis >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_salary_basis
  (p_pay_basis_id   IN     number
  ,p_pay_basis         OUT NOCOPY varchar2
  ,p_pay_basis_meaning OUT NOCOPY VARCHAR2
  ,p_salary_basis      OUT NOCOPY VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_payroll >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_payroll
  (p_payroll_id number
  ,p_effective_date date) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_full_name >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_full_name
  (p_person_id number
  ,p_effective_date date) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_supervisor_assgn_number >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_supervisor_assgn_number
  (p_supervisor_assgn_id   number
  ,p_business_group_id     number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_grade >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_grade
  (p_grade_id number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_grade_lddder >---------------------------|
-- ----------------------------------------------------------------------------
--
function get_grade_ladder
  (p_grade_ladder_pgm_id number
  ,p_effective_date      date) return varchar2;
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
  ,p_gre                  OUT NOCOPY hr_soft_coding_keyflex.segment1%type);
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
);
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
  );
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
  );

end per_qh_populate;

 

/
