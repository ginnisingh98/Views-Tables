--------------------------------------------------------
--  DDL for Package HXT_PA_USER_EXITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_PA_USER_EXITS" AUTHID CURRENT_USER AS
/* $Header: hxtpainf.pkh 115.5 2002/11/28 01:38:23 fassadi ship $ */


/****************************************************************************************************
FUNCTION p_a_interface()

The p_a_interface() logic will insert pay data to the PA_Transaction_Interface table.
Details to be inserted will be passed in as parameters to a function called p_a_interface.
Because the interface to Project Accounting will vary on different installations,
the p_a_interface logic will be stored in the HXT_PA_USER_EXITS package.
HXT_PA_USER_EXITS is designed to contain unique code, specific to a customers needs.


Following is a list of parameters to the
p_a_interface function and the source of each argument:

i_hours_worked               --  HXT_det_hours_worked_x.hours
i_rate                       --  per_pay_proposals.proposed_salary
                                     (employees hourly rate)
                               or
                                 hxt_det_hours_worked_x.hourly_rate
                                     (timecard override hourly rate)
                               or
                                 per_pay_proposals.proposed_salary *
                                     (employees hourly rate)
                                 hxt_det_hours_worked_x.rate_multiple
                                     (manually entered multiple from timecard)
                               or
                                 per_pay_proposals.proposed_salary *
                                     (employees hourly rate)
                                 hxt_pay_element_types_f_ddf_v.hxt_premium_amount
                                     (multiple from pay element flex)
                               or
                                 hxt_pay_element_types_f_ddf_v.hxt_premium_amount /
                                     (daily amount from element flex)
                                 hxt_det_hours_worked_x.hours
                                     (hours worked)
                               or
                                 per_pay_proposals.proposed_salary *
                                     (employees hourly rate)
                                 hxt_pay_element_types_f_ddf_v.hxt_premium_amount - 1.0
                                     (non-ot premium multiple from pay element flex minus 1.0)
i_premium_amount             --  hxt_pay_element_types_f_ddf_v.hxt_premium_amount (premium amount element flex)
                                 or
                                 hxt_det_hours_worked_x.amount (timecard override amount)
i_trans_source               --  hxt_pay_element_types_f_ddf_v.hxt_earning_category||hxt_pay_element_types_f_ddf_v.hxt_premium_type
i_period_end                 --  per_time_periods.end_date
i_employee_number            --  per_people_f.employee_number
--SIR162i_employment_cat             --  fnd_common_lookups.meaning (lookup_type = 'EMP_CAT')
--SIR162i_emp_cat_code               --  per_assignments_f.employment_category
i_oganization_name           --  hr_organization_units.name
i_organization_id            --  hr_organization_units.id
i_date_worked                --  hxt_det_hours_worked_x.date_worked
i_effective_start_date       --  hxt_det_hours_worked_x.effective_start_date
i_effective_end_date         --  hxt_det_hours_worked_x.effective_end_date
i_hours_type                 --  hxt_det_hours_worked_x.element_name
i_salary_basis               --  per_pay_proposals_v.pay_basis
i_time_detail_id             --  hxt_det_hours_worked_x.id
i_hxt_earning_category       --  hxt_pay_element_types_f_ddf_v.hxt_earning_category
i_retro_transaction          --  TRUE if  Retro Transaction
                                 FALSE if Normal Transaction
i_standard_rate              --  per_pay_proposals.proposed_salary (employees unmodified base hourly rate)
i_project_id                 --  hxt_det_hours_worked_x.project_id
i_task_id                    --  hxt_det_hours_worked_x.task_id
i_segment1                   --  pa_projects.segment1
i_task_number                --  pa_tasks.task_number
i_project_name               --  pa_projects.name
i_task_name                  --  pa_tasks.task_name
i_assignment_id              --  per_assignments_f.assignment_id
i_cost_allocation_keyflex_id --  pay_cost_allocation_keyflex.cost_allocation_keyflex_id
i_job_definition_id          --  per_job_definitions.job_definition_id

*******************************************************************************************************/

FUNCTION p_a_interface( i_hours_worked IN NUMBER,
                        i_rate IN NUMBER,
                        i_premium_amount IN NUMBER,
                        i_trans_source IN VARCHAR2,
                        i_period_end IN DATE,
                        i_employee_number IN VARCHAR2,
                        i_employment_cat IN VARCHAR2,
                        i_element_type_id IN NUMBER,   --SIR162
--SIR162                        i_emp_cat_code IN VARCHAR2,
                        i_organization_name IN VARCHAR2,
                        i_organization_id IN NUMBER,
                        i_date_worked IN DATE,
                        i_effective_start_date IN DATE,
                        i_effective_end_date IN DATE,
                        i_hours_type IN VARCHAR2,
                        i_salary_basis IN VARCHAR2,
                        i_time_detail_id IN NUMBER,
                        i_hxt_earning_category IN VARCHAR2,
                        i_retro_transaction IN BOOLEAN,
                        i_standard_rate IN NUMBER,
                        i_project_id IN NUMBER,
                        i_task_id IN NUMBER,
                        i_segment1 IN VARCHAR2,
                        i_task_number IN VARCHAR2,
                        i_project_name IN VARCHAR2,
                        i_task_name IN VARCHAR2,
                        i_assignment_id IN NUMBER,
                        i_cost_allocation_keyflex_id IN NUMBER,
                        i_job_definition_id IN NUMBER,
                        o_location OUT NOCOPY VARCHAR2,
                        o_error_text OUT NOCOPY VARCHAR2,
                        o_system_text OUT NOCOPY VARCHAR2) RETURN NUMBER;
END HXT_PA_USER_EXITS;

 

/
