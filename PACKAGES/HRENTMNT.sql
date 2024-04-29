--------------------------------------------------------
--  DDL for Package HRENTMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRENTMNT" AUTHID CURRENT_USER as
/* $Header: pyentmnt.pkh 120.2.12010000.1 2008/07/27 22:32:04 appldev ship $ */
--
 type t_date_table is table of date
                      index by binary_integer;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hrentmnt.check_payroll_changes_asg                                       --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Makes sure that payroll exists for the lifetime of the assignment that   --
 -- uses it and also makes sure that no assignment actions are orphaned by a --
 -- change in payroll.                                                       --
 ------------------------------------------------------------------------------
--
 procedure check_payroll_changes_asg
 (
  p_assignment_id         number,
  p_payroll_id            number,
  p_dt_mode               varchar2,
  p_validation_start_date date,
  p_validation_end_date   date
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hrentmnt.maintain_entries_el                                             --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates element entries on creation of a standard element link.          --
 ------------------------------------------------------------------------------
--
 procedure maintain_entries_el
 (
  p_business_group_id         number,
  p_element_link_id           number,
  p_element_type_id           number,
  p_effective_start_date      date,
  p_effective_end_date        date,
  p_payroll_id                number,
  p_link_to_all_payrolls_flag varchar2,
  p_job_id                    number,
  p_grade_id                  number,
  p_position_id               number,
  p_organization_id           number,
  p_location_id               number,
  p_pay_basis_id              number,
  p_employment_category       varchar2,
  p_people_group_id           number,
  p_assignment_id             number default null
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hrentmnt.maintain_entries_asg                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- This forms the interface into the procedures that maintain element       --
 -- entries when affected by various events ie.                              --
 --                                                                          --
 -- CHANGE_PQC   : changes in personal qualifying conditions.                --
 -- CNCL_TERM    : a termination is cancelled.                               --
 -- CNCL_HIRE    : the hiring of a person is cancelled.                      --
 -- ASG_CRITERIA : assignment criteria has chnaged.                          --
 ------------------------------------------------------------------------------
--
 procedure maintain_entries_asg
 (
  p_assignment_id         number,
  p_old_payroll_id        number,
  p_new_payroll_id        number,
  p_business_group_id     number,
  p_operation             varchar2,
  p_actual_term_date      date,
  p_last_standard_date    date,
  p_final_process_date    date,
  p_dt_mode               varchar2,
  p_validation_start_date date,
  p_validation_end_date   date,
  p_entries_changed       in out nocopy varchar2,
  p_old_hire_date         date default null,
  p_old_people_group_id   number default null,
  p_new_people_group_id   number default null
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hrentmnt.maintain_entries_asg                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Overloaded version to allow backward compatibility.                      --
 ------------------------------------------------------------------------------
--
 procedure maintain_entries_asg
 (
  p_assignment_id         number,
  p_business_group_id     number,
  p_operation             varchar2,
  p_actual_term_date      date,
  p_last_standard_date    date,
  p_final_process_date    date,
  p_dt_mode               varchar2,
  p_validation_start_date date,
  p_validation_end_date   date
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hrentmnt.check_opmu                                                      --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Ensures that on transfer of Payroll (on the Assignment) or when a change --
 -- causes the Payroll to change in the future that Personal Payment Methods --
 -- have corresponding Org Pay Methods that are used by the new Payroll.     --
 -- i.e. that Personal Payment Methods are not invalidated.                  --
 ------------------------------------------------------------------------------
--
 procedure check_opmu
 (
  p_assignment_id         number,
  p_payroll_id            number,
  p_dt_mode               varchar2,
  p_validation_start_date date,
  p_validation_end_date   date
 );
--

--
------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.move_fpd_entries                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- This procedure should be called from HR code to carry out entry changes  --
 -- when final process date is changed.                                      --
 --                                                                          --
 -- PARAMETERS                                                               --
 -- p_assignment_id          - Assignemnt for which the entry changes are to --
 --                            be done.                                      --
 -- p_period_of_service_id   - period_of_service_id of the assignment.       --
 -- p_new_final_process_date - New final process date.                       --
 -- p_old_final_process_date - Old final process date.
 ------------------------------------------------------------------------------
procedure move_fpd_entries
(
 p_assignment_id           in number
,p_period_of_service_id    in number
,p_new_final_process_date  in date
,p_old_final_process_date  in date
);
--
end hrentmnt;

/
