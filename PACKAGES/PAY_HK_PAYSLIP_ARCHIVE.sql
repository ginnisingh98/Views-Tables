--------------------------------------------------------
--  DDL for Package PAY_HK_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyhkparc.pkh 120.1.12000000.1 2007/01/17 20:40:06 appldev noship $ */


  --------------------------------------------------------------------
  -- Bug 3134158 - public variables
  --------------------------------------------------------------------
  g_sn_populated boolean := FALSE;

  type r_scheme_name_store is record
    (scheme_name hr_organization_information.org_information2%TYPE);

  type t_scheme_name_tab is table of r_scheme_name_store
    index by binary_integer;

  g_scheme_name_table t_scheme_name_tab;

  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the Archive process.
  -- There names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------

  --------------------------------------------------------------------
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --------------------------------------------------------------------

  procedure range_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_sql                out nocopy varchar2);



  --------------------------------------------------------------------
  -- This procedure is used to set global contexts
  -- Here It is used to archive the data at payroll action level.
  --------------------------------------------------------------------

  procedure initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);


  --------------------------------------------------------------------
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  --------------------------------------------------------------------

  procedure assignment_action_code
    (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
     p_start_person        in per_all_people_f.person_id%type,
     p_end_person          in per_all_people_f.person_id%type,
     p_chunk               in number);


  --------------------------------------------------------------------
  -- This procedure is actually used to archive data . It
  -- internally calls private procedures to archive balances ,
  -- employee details, employer details ,elements,absences and accruals etc.
  --------------------------------------------------------------------

  procedure archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date);


  --------------------------------------------------------------------
  -- This function returns the valid scheme names and is used by the
  -- view pay_hk_asg_element_payments_v - Bug 3134158
  --------------------------------------------------------------------
  function get_scheme_name
     (p_run_result_id in pay_run_results.run_result_id%TYPE,
      p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
      p_business_group_id in hr_organization_units.business_group_id%TYPE)
  return varchar2;

  --------------------------------------------------------------------
  -- This function returns the assessed ri and is used by the
  -- view pay_hk_asg_mpf_data_v - Bug 4260143
  --------------------------------------------------------------------

  function get_assessed_ri
     (p_run_result_id in pay_run_results.run_result_id%TYPE)
  return VARCHAR2;
  --------------------------------------------------------------------


END pay_hk_payslip_archive;

 

/
