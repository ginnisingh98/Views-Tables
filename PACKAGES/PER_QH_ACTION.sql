--------------------------------------------------------
--  DDL for Package PER_QH_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_ACTION" AUTHID CURRENT_USER as
/* $Header: peqhactn.pkh 120.0.12010000.1 2008/07/28 05:30:57 appldev ship $ */
procedure quick_hire_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_assignment_id             in      number   default null,
   p_primary_assignment_id     in      number   default null,
   p_overwrite_primary         in      varchar2 default 'N',
   p_person_type_id            in      number   default null,
   p_national_identifier       in      per_all_people_f.national_identifier%type default hr_api.g_varchar2,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_oversubscribed_vacancy_id    out nocopy  number
);
--
procedure send_notification
(p_notification             wf_messages.name%type
,p_wf_name                  wf_item_types.name%type
,p_role                     varchar2 -- wf_roles.name%type Fix for bug 2741492
,p_person_id                per_all_people_f.person_id%type
,p_assignment_id            per_all_assignments_f.assignment_id%type
,p_effective_date           date
,p_hire_date                per_periods_of_service.date_start%type
,p_full_name                per_all_people_f.full_name%type
,p_per_effective_start_date per_all_people_f.effective_start_date%type
,p_title                    per_alL_people_f.title%type
,p_first_name               per_all_people_f.first_name%type
,p_last_name                per_all_people_f.last_name%type
,p_employee_number          per_all_people_f.employee_number%type
,p_applicant_number         per_all_people_f.applicant_number%type
,p_national_identifier      per_all_people_f.national_identifier%type
,p_asg_effective_start_date per_all_assignments_f.effective_start_date%type
,p_organization             hr_all_organization_units.name%type
,p_grade                    per_grades.name%type
,p_job                      per_jobs.name%type
,p_position                 hr_all_positions_f.name%type
,p_payroll                  pay_all_payrolls_f.payroll_name%type
,p_vacancy                  per_vacancies.name%type
,p_supervisor               per_all_people_f.full_name%type
,p_location                 hr_locations.location_code%type
,p_salary                   per_pay_proposals.proposed_salary_n%type
,p_salary_currency          pay_element_types_f.input_currency_code%type
,p_pay_basis                hr_lookups.meaning%type
,p_date_probation_end       per_all_assignments_f.date_probation_end%type
,p_npw_number               per_all_people_f.npw_number%type
,p_vendor                   po_vendors.vendor_name%type
,p_supplier_reference       per_all_assignments_f.vendor_employee_number%type
,p_placement_date_start     per_all_assignments_f.period_of_placement_date_start%type
,p_grade_ladder             ben_pgm_f.name%type
);
--
procedure get_notification_preview
(p_notification             in     wf_messages.name%type
,p_wf_name                  in     wf_item_types.name%type
,p_role                     in     varchar2 -- wf_roles.name%type Fix for bug 2741492
,p_person_id                in     per_all_people_f.person_id%type
,p_assignment_id            in     per_all_assignments_f.assignment_id%type
,p_effective_date           in     date
,p_hire_date                in     per_periods_of_service.date_start%type
,p_full_name                in     per_all_people_f.full_name%type
,p_per_effective_start_date in     per_all_people_f.effective_start_date%type
,p_title                    in     per_alL_people_f.title%type
,p_first_name               in     per_all_people_f.first_name%type
,p_last_name                in     per_all_people_f.last_name%type
,p_employee_number          in     per_all_people_f.employee_number%type
,p_applicant_number         in     per_all_people_f.applicant_number%type
,p_national_identifier      in     per_all_people_f.national_identifier%type
,p_asg_effective_start_date in     per_all_assignments_f.effective_start_date%type
,p_organization             in     hr_all_organization_units.name%type
,p_grade                    in     per_grades.name%type
,p_job                      in     per_jobs.name%type
,p_position                 in     hr_all_positions_f.name%type
,p_payroll                  in     pay_all_payrolls_f.payroll_name%type
,p_vacancy                  in     per_vacancies.name%type
,p_supervisor               in     per_all_people_f.full_name%type
,p_location                 in     hr_locations.location_code%type
,p_salary                   in     per_pay_proposals.proposed_salary_n%type
,p_salary_currency          in     pay_element_types_f.input_currency_code%type
,p_pay_basis                in     hr_lookups.meaning%type
,p_date_probation_end       in     per_all_assignments_f.date_probation_end%type
,p_npw_number               in     per_all_people_f.npw_number%type
,p_vendor                   in     po_vendors.vendor_name%type
,p_supplier_reference       in     per_all_assignments_f.vendor_employee_number%type
,p_placement_date_start     in     per_all_assignments_f.period_of_placement_date_start%type
,p_grade_ladder             in     ben_pgm_f.name%type
,p_subject                     out nocopy varchar2
,p_body                        out nocopy varchar2
);
--
end per_qh_action;

/
