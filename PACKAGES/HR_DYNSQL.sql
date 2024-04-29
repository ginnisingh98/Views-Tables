--------------------------------------------------------
--  DDL for Package HR_DYNSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DYNSQL" AUTHID CURRENT_USER as
/* $Header: pydynsql.pkh 120.2.12010000.1 2008/07/27 22:28:54 appldev ship $ */
--
   ---------------------------------- archive_range ---------------------

   /*
      NAME
         archive_range
      NOTES
         This function prepares dynamical plsql block for calling the
         US Legislative hook for setting US contexts for archiving
         assignment information.
   */

procedure archive_range(pactid in            number,
                        sqlstr in out nocopy varchar2
                       );
   ---------------------------------- update_recurring_ee ---------------------
   /*
      NAME
         update_recurring_ee
      NOTES
         This function performs the actual database work of updating
         a REE's input value as a result of an Update Formula Result Rule.
   */
   procedure update_recurring_ee ( p_element_entry_id     in out nocopy number,
                                   p_error_code           in out nocopy number,
                                   p_assignment_action_id in number,
                                   p_assignment_id        in number,
                                   p_effective_date       in date,
                                   p_element_type_id      in number,
                                   p_input_value_id       in number,
                                   p_updated_value        in varchar2 );
--
   ---------------------------------- stop_recurring_ee ---------------------
   /*
      NAME
         stop_recurring_ee
      NOTES
         This function performs the actual database work of date effectively
         deleting a REE as a result of a Stop Formula Result Rule.
   */
   procedure stop_recurring_ee ( p_element_entry_id     in number,
                                 p_error_code           in out nocopy number,
                                 p_assignment_id        in number,
                                 p_effective_date       in date,
                                 p_element_type_id      in number,
                                 p_assignment_action_id in number,
                                 p_date_earned in date );
--
  ---------------------------------- setinfo --------------------------------
   /*
      NAME
         setinfo - assignment set  SQL.
      DESCRIPTION
      NOTES
         <none>
   */
   procedure setinfo
   (
      asetid   in            number,   -- assignment_set_id.
      everyone in out nocopy boolean,
      include  in out nocopy boolean, -- any specific inclusions.
      exclude  in out nocopy boolean, -- any specific exclusions.
      formula  in out nocopy number,  -- has a formula been specified.
      payroll  in out nocopy boolean  -- has a payroll_id been specified.
   );
--
   --------------------------- person_sequence_locked --------------------------
   /*
      NAME
         person_sequence_locked - Person Sequence Locked
      DESCRIPTION
         This function is used to determine if a person has sequence locks
         given a date.
      NOTES
         <none>
   */
   function person_sequence_locked (p_period_service_id in number,
                                    p_effective_date    in date)
   return varchar2;
   function process_group_seq_locked (p_asg_id in number,
                                      p_effective_date    in date,
                                      p_future_actions    in varchar2 default 'N')
   return varchar2;
--
   --------------------------- bal_person_sequence_locked ----------------------
   /*
      NAME
         bal_person_sequence_locked - Balance Adjustment Person Sequence Locked
      DESCRIPTION
         This function is used to determine if a person has any errored actions.

      NOTES
         <none>
   */
   function bal_person_sequence_locked (p_period_service_id in number,
                                        p_effective_date    in date)
   return varchar2;
--
   --------------------------- ret_person_sequence_locked ----------------------
   /*
      NAME
         ret_person_sequence_locked - Retropay Person Sequence Locked
      DESCRIPTION
         This function is used to determine if a person has sequence locks
         given a date.
      NOTES
         <none>
   */
   function ret_person_sequence_locked (p_period_service_id in number,
                                    p_effective_date    in date)
   return varchar2;
--
   ---------------------------------- rbsql -----------------------------------
   /*
      NAME
         rbsql - RollBack SQL.
      DESCRIPTION
         Has two functions. Firstly, dynamically builds an sql statement
         for rollback by assignment set. Secondly, it passes back info
         about the assignment set that has been specified.
      NOTES
         <none>
   */
   procedure rbsql
   (
      asetid  in            number,   -- assignment_set_id.
      spcinc     out nocopy number,   -- are there specific inclusions?
      spcexc     out nocopy number,   -- are there specific exclusions?
      formula in out nocopy number,   -- what is the formula_id?
      sqlstr  in out nocopy varchar2, -- returned dynamic sql string.
      len        out nocopy number,   -- length of sql string.
      chkno      in         number default null
   );
--
   ---------------------------------- bkpsql ----------------------------------
   /*
      NAME
         bkpsql - build dynamic sql for BackPay.
      DESCRIPTION
         Builds dynamic sql statement for assignment set
         processing.
      NOTES
         <none>
   */
   procedure bkpsql
   (
      asetid in            number,   -- assignment_set_id.
      sqlstr in out nocopy varchar2, -- returned string.
      len       out nocopy number    -- length of returned string.
   );
--
  -------------------------------------cbsql-------------------------------------
   /*
      NAME
         cbsql - build dynamic sql for Create Batches.
      DESCRIPTION
         Builds dynamic sql statement for assignment set
         processing.
      NOTES
         <none>
   */
   procedure cbsql
   (
      asetid  in            number default 0,    -- assignment_set_id.
      elsetid in            number default null, -- element set id.
      spcinc     out nocopy number,   -- are there specific inclusions?
      spcexc     out nocopy number,   -- are there specific exclusions?
      formula in out nocopy number,   -- what is the formula_id?
      sqlstr  in out nocopy varchar2, -- returned dynamic sql string.
      len        out nocopy number    -- length of sql string.
   );
--

   ---------------------------------- qptsql ----------------------------------
   /*
      NAME
         qptsql - build dynamic sql for QuickPaint.
      DESCRIPTION
         Builds dynamic sql strings for QuickPaint.
         It decides which sql is required from
         the assignment_set_id passed in.
      NOTES
         <none>
   */
   procedure qptsql
   (
      asetid in            number,   -- assignment_set_id.
      sqlstr in out nocopy varchar2, -- returned string.
      len       out nocopy number    -- length of returned string.
   );
--
   ------------------------------ get_local_unit -------------------------------
   /*
      NAME
         get_local_unit  - this is used to retrieve the local unit id if valid.
      DESCRIPTION
         This is used to identify the local unit when processing run results.
      NOTES
   */
 function get_local_unit
 (
  p_assignment_id  number
 ,p_effective_date date
 ) return number;
--
   ------------------------------ get_tax_unit -------------------------------
   /*
      NAME
         get_tax_unit  - this is used to retrieve the tax unit id if valid.
      DESCRIPTION
         This is used by the assignment action creation code to find the
         value of the tax unit id.
      NOTES
   */
 function get_tax_unit
 (
  p_assignment_id  number
 ,p_effective_date date
 ) return number;
--
   ---------------------------------- pyrsql ----------------------------------
   /*
      NAME
         pyrsql - build dynamic sql.
      DESCRIPTION
         builds an SQL statement from a 'kit of parts'.
         It concatenates various parts together depending on
         what is required, which is dependent on factors such
         as what sort of statement we require, whether we are
         dealing with time dependent/independent legislation
         and so on.
      NOTES
         <none>
   */
   procedure pyrsql
   (
      sqlid      in            number,
      timedepflg in            varchar2,
      interlock  in            varchar2,
      sqlstr     in out nocopy varchar2,
      len           out nocopy number,
      action     in            varchar2	default 'R',
      pactid     in            number   default null,
      chkno      in     number          default null
   );
--
   ---------------------------- adv_override_check ----------------------------
   /*
      NAME
         adv_override_check
      DESCRIPTION
         Check whether the advance override input value exists
         for the element entry at the given start and end date.
      NOTES
         <none>
   */
  function adv_override_check
  (
   p_eeid number,
   p_start_date date,
   p_end_date date
  ) return varchar2;
end hr_dynsql;

/
