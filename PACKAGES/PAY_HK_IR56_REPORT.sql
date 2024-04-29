--------------------------------------------------------
--  DDL for Package PAY_HK_IR56_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_IR56_REPORT" AUTHID CURRENT_USER as
/* $Header: pyhk56rp.pkh 115.4 2002/12/02 09:20:43 srrajago ship $ */
-----------------------------------------------------------------------------
-- Program:     pay_hk_ir56_report (Package Specification)
--
-- Description: Various procedures/functions to submit the HK IR56B Year
--              End Report.
--
-- Change History
-- Date       Changed By  Version  Description of Change
-- ---------  ----------  -------  ------------------------------------------
-- 05 Jul 01  S. Russell  115.0    Initial Version
-- 08 Aug 01  S. Russell  115.1    Put change history in package.
-- 12 Nov 01  J. Lin      115.2    Removed global variable g_error,
--                                 bug 2087384
--                                 Added dbdrv line
-- 02 Dec 02  srrajago    115.3    Included 'nocopy' option for the 'OUT'
--                                 parameter of the procedure 'range_code'.
--                                 Included dbdrv,checkfile commands too.
-----------------------------------------------------------------------------

-- Global variable.

  level_cnt  number;

  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the report process.
  -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the PAR process knows what code to execute for each step of
  -- the report.
  --------------------------------------------------------------------
  procedure range_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_sql               out nocopy varchar2);

  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number);

  procedure submit_report;

  function get_archive_value
    (p_archive_name          in ff_user_entities.user_entity_name%type,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type)
   return ff_archive_items.value%type;

end pay_hk_ir56_report;

 

/
