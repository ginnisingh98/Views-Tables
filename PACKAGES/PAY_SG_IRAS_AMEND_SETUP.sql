--------------------------------------------------------
--  DDL for Package PAY_SG_IRAS_AMEND_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_IRAS_AMEND_SETUP" AUTHID CURRENT_USER as
/* $Header: pysgiras.pkh 120.0.12010000.1 2009/01/30 03:33:26 jalin noship $ */
  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the Archive process.
  -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------
  procedure range_code
    ( p_payroll_action_id  in   pay_payroll_actions.payroll_action_id%type,
      p_sql                out  nocopy varchar2);
  procedure assignment_action_code
    ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
      p_start_person_id    in per_all_people_f.person_id%type,
      p_end_person_id      in per_all_people_f.person_id%type,
      p_chunk              in number);
  procedure archive_code
    ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
      p_effective_date        in date);
  procedure deinit_code
    ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type );
end pay_sg_iras_amend_setup;

/
