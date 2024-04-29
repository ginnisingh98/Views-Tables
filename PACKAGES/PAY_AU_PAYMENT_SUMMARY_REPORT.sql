--------------------------------------------------------
--  DDL for Package PAY_AU_PAYMENT_SUMMARY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYMENT_SUMMARY_REPORT" AUTHID CURRENT_USER as
/* $Header: pyaupsrp.pkh 120.1.12010000.1 2008/07/27 22:06:16 appldev ship $*/

/*
*** ------------------------------------------------------------------------+
*** Program:     pay_au_payment_summary_reprot (Package Specification)
*** Description: Procedures to assist Processing of Payment Summary
***              Self Printed Report and ETP Payment Summary  Self
***              Printed Report.
*** Change History
***
*** Date       Changed By  Version         Description of Change
*** ---------  ----------  -------         ----------------------------------------+
*** 30 MAR 01  kaverma     1.0             Initial version
*** 28 NOV 01  nnaresh     1.1              Updated for GSCC Standards
*** 03 DEC 02  Ragovind    1.2              Added NOCOPY for the function range_code.
*** 03 Jan 06  abhargav    1.3    4726357   Added function to get the self serivce option.
*** ------------------------------------------------------------------------+

*** R12 VERSIONS Change History
***
*** Date       Changed By  Version  Description of Change
*** ---------  ----------  -------  ----------------------------------------+
*** 24 APR 06  abhargav    12.1     5174524  Copy of Version 115.03. R12 Fix for Bug 4726357
***
*/

 ---------------------------------------------------------------------------
  -- These are PUBLIC procedures and are required by the Payroll Archive
  -- Reeporter process.
  -- There names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that the
  -- Payroll Archive Reeporter process knows what code to execute for each
  --  step of the report.
  --------------------------------------------------------------------------

  --------------------------------------------------------------------------
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archive report process.
  --------------------------------------------------------------------------
  procedure range_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_sql               out NOCOPY varchar2);



 --------------------------------------------------------------------------
  -- This procedure further restricts the assignment_id's
  -- returned by range_code and locks the Assignment Actions for which
  -- a Payment Summry Report has been printed.
  -------------------------------------------------------------------------
  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number);



 ---------------------------------------------------------------------------
  -- This Procedure Actually Calls the Payment Summary Report.
 ---------------------------------------------------------------------------
 procedure spawn_archive_reports;

---
-- Bug 4726357 Added to check whether Self Service Option is enabled for the employee
---
function ss_pref(p_assignemnt_id per_assignments_f.assignment_id%type) return varchar2;

end pay_au_payment_summary_report;

/
