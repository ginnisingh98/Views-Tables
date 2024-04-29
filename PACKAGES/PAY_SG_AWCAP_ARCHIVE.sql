--------------------------------------------------------
--  DDL for Package PAY_SG_AWCAP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_AWCAP_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pysgawcp.pkh 120.0.12010000.1 2008/07/27 23:40:26 appldev ship $ */
       --------------------------------------------------------------------
       -- These are PUBLIC procedures are required by the Archive process.
       -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
       -- the archive process knows what code to execute for each step of
       -- the archive.
       -------------------------------------------------------------------
       procedure range_code
           ( p_payroll_action_id  in   pay_payroll_actions.payroll_action_id%type,
             p_sql                out  nocopy varchar2);
       --
       procedure assignment_action_code
           ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
             p_start_person_id    in per_all_people_f.person_id%type,
             p_end_person_id      in per_all_people_f.person_id%type,
             p_chunk              in number );
       --
       procedure initialization_code
           ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);
       --
       procedure archive_code
           ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
             p_effective_date        in date);
       --
       procedure deinit_code
           ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type ) ;
       --
       ----------------------------------------------------------------------------------
       --Function calculates current year Ordinary Earnings with monthly ceiling of 5,500
       ---------------------------------------------------------------------------------
       function get_cur_year_ord_ytd (p_person_id in per_all_people_f.person_id%type,
                                      p_assignment_id  in per_all_assignments_f.assignment_id%type,
                                      p_date_earned in date) return number  ;
       --
  end pay_sg_awcap_archive;

/
