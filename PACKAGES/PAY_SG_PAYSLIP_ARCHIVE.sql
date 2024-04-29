--------------------------------------------------------
--  DDL for Package PAY_SG_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pysgparc.pkh 120.0.12000000.1 2007/01/18 01:34:45 appldev noship $ */

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


END pay_sg_payslip_archive;

 

/
