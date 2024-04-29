--------------------------------------------------------
--  DDL for Package HR_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ENTRY" AUTHID CURRENT_USER as
/* $Header: pyeentry.pkh 120.0.12010000.2 2010/02/18 06:37:25 sivanara ship $ */
--
 -- Global TYPE definitions
 type number_table   is table of number not null
                        index by binary_integer;
/*Changed the size from 80-240 for bug 9350651*/
 type varchar2_table is table of varchar2(240)
                        index by binary_integer;
--
-- ----------------- Assignment_eligible_for_link -----------------------------
--
-- NAME
-- hr_entry.Assignment_eligible_for_link
--
-- DESCRIPTION
-- Returns 'Y' if the specified assignment and link match as at the
-- specified date. A match indicates that the assignment is eligible for
-- the link as at that date. This function may be called from within SQL.
-- If no match is found then 'N' will be returned (it never returns NULL).
--
function Assignment_eligible_for_link (
--
p_assignment_id         in natural,
p_element_link_id       in natural,
p_effective_date        in date
) return varchar2;
--
--pragma restrict_references (Assignment_eligible_for_link, WNDS, WNPS);
-- ---------------------------------------------------------------------------
--
-- NAME
-- hr_entry.return_termination_date
--
-- DESCRIPTION
-- Returns the actual_termination_date if an assignment has been
-- terminated.
-- If the assignment has not been terminated then the returned
-- actual_termination_date date will be null.
--
 function return_termination_date(p_assignment_id in number,
                                  p_session_date  in date)
          return date;
--
-- NAME
-- hr_entry.get_nonrecurring_dates
--
-- DESCRIPTION
-- Called when a nonrecurring entry is about to be created. Makes sure that
-- the assignment is to a payroll and also a time period exists. Returns the
-- start and end dates of the nonrecurring entry taking into account
-- changes in payroll.
--
 procedure get_nonrecurring_dates
 (
  p_assignment_id         in            number,
  p_session_date          in            date,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_payroll_id               out nocopy number,
  p_period_start_date        out nocopy date,
  p_period_end_date          out nocopy date
 );
--
--
-- --------------------- return_qualifying_conditions -------------------------
--
-- Name: return_qualifying_conditions
--
-- Description: If the element entry link is discretionary and has
--              qualifying conditions then check the length of
--              service and age conditions.
--
-- Returns: p_los_date --> date at which the los is eligible.
--          p_age_date --> date at which the age is eligible.
--
--          If dates return null then check is not valid.
--
procedure return_qualifying_conditions
(
 p_assignment_id        in        number,
 p_element_link_id      in        number,
 p_session_date         in        date,
 p_los_date            out nocopy date,
 p_age_date            out nocopy date
);
--
 /*
 NAME
 hr_entry.generate_entry_id

 DESCRIPTION
 Generates then next sequence value for inserting an element entry into the
 PAY_ELEMENT_ENTRIES_F base table.
 */
--
 FUNCTION generate_entry_id return number;
--
 /*
 NAME
 hr_entry.generate_run_result_id

 DESCRIPTION
 Generates then next sequence value for inserting a run result into
 PAY_RUN_RESULTS base table.
 */
--
 FUNCTION generate_run_result_id return number;
--
 /*
 NAME
 hr_entry.entry_process_in_run

 DESCRIPTION
 This function return a boolean value for the specified element_type_id
 depending on the process_in_run_flag attribute. The function returns TRUE
 if the process_in_run_flag = 'Y' or FALSE if the process_in_run_flag = 'N'
 */
--
 FUNCTION entry_process_in_run(p_element_type_id in number,
                               p_session_date    in date) return boolean;
--
 /*
 NAME
 hr_entry.get_eligibility_period

 DESCRIPTION
 This procedure selects the minimum or maximum (or both) effective assignment
 dates where the assignment is eligible for a given element link.
 */
 PROCEDURE get_eligibility_period (
    p_assignment_id         in number,
    p_element_link_id       in number,
    p_session_date          in date,
    p_min_eligibility_date in out nocopy date,
    p_max_eligibility_date in out nocopy date
 );
--
 /*
 NAME
 hr_entry.entry_asg_pay_link_dates

 DESCRIPTION
 This procedure returns the min(effective_start/end_date) for a specified
 element link and payroll. Also, if the specified employee assignment has
 been terminated the element termination date as of the termination rule
 is returned.
 */
 PROCEDURE entry_asg_pay_link_dates (p_assignment_id            in number,
              p_element_link_id          in number,
              p_session_date             in date,
              p_element_term_rule_date  out nocopy date,
              p_element_link_start_date out nocopy date,
              p_element_link_end_date   out nocopy date,
              p_payroll_start_date      out nocopy date,
              p_payroll_end_date        out nocopy date,
              p_entry_mode               in boolean default true);
--
 /*
 NAME
 hr_entry.recurring_entry_end_date

 DESCRIPTION
 This function is used to return the valid effective end of a recurring entry.
 */
 function recurring_entry_end_date
 (
  p_assignment_id             in number,
  p_element_link_id           in number,
  p_session_date              in date,
  p_overlap_chk               in varchar2 default 'Y',
  p_mult_entries_allowed_flag in varchar2,
  p_element_entry_id          in number,
  p_original_entry_id         in number
 ) return date;
--
 /*
 NAME
 hr_entry.chk_element_entry_eligbility

 DESCRIPTION
 This procedure is used to check if entries (which are defined below) are
 eligble to be inserted/deleted.
 This procedure is only called when:
 1) Inserting an NONRECURRING element entry
    (which is defined as: Nonrecurring, Additional, Override, Adjustment,
     Balance Adjustment etc).
    e.g. when (p_usage = 'INSERT'         and
             ((p_processing_type  = 'R'   and
               p_entry_type      != 'E')  or
               p_processing_type  = 'N'))

 2) DateTrack deleting (Next/Future Changes) of a RECURRING element entry.
    e.g. (p_dt_delete_mode    = 'DELETE_NEXT_CHANGE' or
          p_dt_delete_mode    = 'FUTURE_CHANGES')
 */
 PROCEDURE chk_element_entry_eligbility (p_assignment_id         in number,
                                         p_element_link_id       in number,
                                         p_session_date          in date,
                                         p_usage                 in varchar2,
                                         p_validation_start_date in date,
                                         p_validation_end_date   in date,
                                         p_min_eligibility_date out nocopy date,
                                         p_max_eligibility_date out nocopy date);
 /*
 NAME
 hr_entry.chk_element_entry_open

 DESCRIPTION
 This procedure does the following checks:
 1) Ensure that the element type is not closed for entry currently
    or in the future by determining the value of the
    CLOSED_FOR_ENTRY_FLAG attribute on PAY_ELEMENT_TYPES_F.
 2) If the employee assignment is to a payroll then ensure that
    the current and future periods as of session date are open.
    If the period is closed, you can only change entries providing
 */
 PROCEDURE chk_element_entry_open (p_element_type_id          in number,
                                   p_session_date             in date,
                                   p_validation_start_date    in date,
                                   p_validation_end_date      in date,
                                   p_assignment_id            in number);
--
 /*
 NAME
 hr_entry.derive_default_value

 DESCRIPTION
 This procedure is used to return default screen and database formatted
 values in either a cold or hot format for the specified link and
 input value. The default value can be for Minimum, Maximum or Default
 values.
 Therefore, it hot defaults are being used the returned database value
 will be null but, the return screen value will be encapsulated in
 */
 PROCEDURE derive_default_value (p_element_link_id         in number,
                                 p_input_value_id          in number,
                                 p_session_date            in date,
                                 p_input_currency_code     in varchar2,
                                 p_min_max_def             in varchar2
                                                              default 'DEF',
                                 v_screen_format_value    out nocopy varchar2,
                                 v_database_format_value  out nocopy varchar2);
--
 /*
 NAME
 hr_entry.chk_mandatory_input_value

 DESCRIPTION
 This procedure produces an error is any input value which is defined as
 having a mandatory value is null.
 */
 PROCEDURE chk_mandatory_input_value (p_input_value_id  in number,
                                      p_entry_value     in varchar2,
                                      p_session_date    in date,
                                      p_element_link_id in number);
--
   /*
   NAME
   hr_entry.chk_element_entry

   DESCRIPTION
   This procedure is a cover to chk_element_entry_main and simply calls
   chk_element_entry_main with a null p_creator_type.
   This change has been made because overloading can't be used because
   chk_element_entry is called from forms.
   */
--
 procedure chk_element_entry
 (
  p_element_entry_id         in number,
  p_original_entry_id        in number,
  p_session_date             in date,
  p_element_link_id          in number,
  p_assignment_id            in number,
  p_entry_type               in varchar2,
  p_effective_start_date in out nocopy date,
  p_effective_end_date   in out nocopy date,
  p_validation_start_date    in date,
  p_validation_end_date      in date,
  p_dt_update_mode           in varchar2,
  p_dt_delete_mode           in varchar2,
  p_usage                    in varchar2,
  p_target_entry_id          in number
 );
--
   /*
   NAME
   hr_entry.chk_element_entry_main

   DESCRIPTION
   This procedure is used for referential/standard checks when inserting/
   updating or deleteing element enries.
   */
--
 procedure chk_element_entry_main
 (
  p_element_entry_id         in number,
  p_original_entry_id        in number,
  p_session_date             in date,
  p_element_link_id          in number,
  p_assignment_id            in number,
  p_entry_type               in varchar2,
  p_effective_start_date in out nocopy date,
  p_effective_end_date   in out nocopy date,
  p_validation_start_date    in date,
  p_validation_end_date      in date,
  p_dt_update_mode           in varchar2,
  p_dt_delete_mode           in varchar2,
  p_usage                    in varchar2,
  p_target_entry_id          in number,
  p_creator_type             in varchar2
 );
--
   /*
   NAME
   hr_entry.del_3p_entry_values

   DESCRIPTION
   This procedure is used for third party deletes from:
   PAY_ELEMENT_ENTRIES_F      (If an abscence etc).
   PAY_ELEMENT_ENTRY_VALUES_F (Entry Values are always deleted).
   PAY_RUN_RESULTS            (If nonrecurring, and exist).
   PAY_RUN_RESULT_VALUES      (If nonrecurring, and exist).
   */
--
 PROCEDURE del_3p_entry_values (p_assignment_id                  in number,
                                p_element_entry_id               in number,
                                p_element_type_id                in number,
                                p_element_link_id                in number,
                                p_entry_type                     in varchar2,
                                p_processing_type                in varchar2,
                                p_creator_type                   in varchar2,
                                p_creator_id                     in varchar2,
                                p_dt_delete_mode                 in varchar2,
                                p_session_date                   in date,
                                p_validation_start_date          in date,
                                p_validation_end_date            in date);
--
--
   /*
   NAME
   hr_entry.trigger_workload_shifting

   DESCRIPTION
   This procedure is used for triggering workload shifting.
   */
--
 PROCEDURE trigger_workload_shifting(p_mode                 varchar2,
                                     p_assignment_id          number,
                                     p_effective_start_date   date,
                                     p_effective_end_date     date);
--
-- NAME
-- hr_entry.check_format
--
-- DESCRIPTION
-- Makes sure that the entry value is correct for the UOM and also convert the
-- screen value into the database value ie. internal format.
--
 procedure check_format
 (
  p_element_link_id     in            number,
  p_input_value_id      in            number,
  p_session_date        in            date,
  p_formatted_value     in out nocopy varchar2,
  p_database_value      in out nocopy varchar2,
  p_nullok              in            varchar2 default 'Y',
  p_min_max_failure     in out nocopy varchar2,
  p_warning_or_error       out nocopy varchar2,
  p_minimum_value          out nocopy varchar2,
  p_maximum_value          out nocopy varchar2
 );
--
-- NAME
-- hr_entry.maintain_cost_keyflex
--
-- DESCRIPTION
--
 function maintain_cost_keyflex(
            p_cost_keyflex_structure     in number,
            p_cost_allocation_keyflex_id in number,
            p_concatenated_segments      in varchar2,
            p_summary_flag               in varchar2,
            p_start_date_active          in date,
            p_end_date_active            in date,
            p_segment1                   in varchar2,
            p_segment2                   in varchar2,
            p_segment3                   in varchar2,
            p_segment4                   in varchar2,
            p_segment5                   in varchar2,
            p_segment6                   in varchar2,
            p_segment7                   in varchar2,
            p_segment8                   in varchar2,
            p_segment9                   in varchar2,
            p_segment10                  in varchar2,
            p_segment11                  in varchar2,
            p_segment12                  in varchar2,
            p_segment13                  in varchar2,
            p_segment14                  in varchar2,
            p_segment15                  in varchar2,
            p_segment16                  in varchar2,
            p_segment17                  in varchar2,
            p_segment18                  in varchar2,
            p_segment19                  in varchar2,
            p_segment20                  in varchar2,
            p_segment21                  in varchar2,
            p_segment22                  in varchar2,
            p_segment23                  in varchar2,
            p_segment24                  in varchar2,
            p_segment25                  in varchar2,
            p_segment26                  in varchar2,
            p_segment27                  in varchar2,
            p_segment28                  in varchar2,
            p_segment29                  in varchar2,
            p_segment30                  in varchar2)
          return number;
--
-- NAME
-- hr_entry.return_entry_display_status
--
-- DESCRIPTION
-- Used by PAYEEMEE/PAYWSMEE to return current entry statuses during a
-- post-query.
--
 procedure return_entry_display_status(p_element_entry_id  in number,
                                       p_element_type_id   in number,
                                       p_element_link_id   in number,
                                       p_assignment_id     in number,
                                       p_entry_type        in varchar2,
                                       p_session_date      in date,
                                       p_additional       out nocopy varchar2,
                                       p_adjustment       out nocopy varchar2,
                                       p_overridden       out nocopy varchar2,
                                       p_processed        out nocopy varchar2);
--
-- NAME
-- hr_entry.Ins_3p_entry_values
--
-- DESCRIPTION
-- This function is used for third party inserts into:
-- PAY_ELEMENT_ENTRIES_F      (If an abscence, or DT functions are being used).
-- PAY_ELEMENT_ENTRY_VALUES_F (Entry Values are always inserted).
-- PAY_RUN_RESULTS            (If nonrecurring).
-- PAY_RUN_RESULT_VBALUES     (If nonrecurring).
--
-- NB. this function is OVERLOADED !
--
 procedure ins_3p_entry_values
 (
  p_element_link_id    number,
  p_element_entry_id   number,
  p_session_date       date,
  p_num_entry_values   number,
  p_input_value_id_tbl hr_entry.number_table,
  p_entry_value_tbl    hr_entry.varchar2_table
 );
--
--
-- NAME
-- hr_entry.ins_3p_entry_values
--
-- DESCRIPTION
-- This function is used for third party inserts into:
-- PAY_ELEMENT_ENTRIES_F      (If an abscence, or DT functions are being used).
-- PAY_ELEMENT_ENTRY_VALUES_F (Entry Values are always inserted).
-- PAY_RUN_RESULTS            (If nonrecurring).
-- PAY_RUN_RESULT_VBALUES     (If nonrecurring).
--
-- NB. this function is OVERLOADED !
--
 procedure ins_3p_entry_values
 (
  p_element_link_id  number,
  p_element_entry_id number,
  p_session_date     date,
/** sbilling **/
  p_creator_type     varchar2,
  p_entry_type       varchar2,
  p_input_value_id1  number,
  p_input_value_id2  number,
  p_input_value_id3  number,
  p_input_value_id4  number,
  p_input_value_id5  number,
  p_input_value_id6  number,
  p_input_value_id7  number,
  p_input_value_id8  number,
  p_input_value_id9  number,
  p_input_value_id10 number,
  p_input_value_id11 number,
  p_input_value_id12 number,
  p_input_value_id13 number,
  p_input_value_id14 number,
  p_input_value_id15 number,
  p_entry_value1     varchar2,
  p_entry_value2     varchar2,
  p_entry_value3     varchar2,
  p_entry_value4     varchar2,
  p_entry_value5     varchar2,
  p_entry_value6     varchar2,
  p_entry_value7     varchar2,
  p_entry_value8     varchar2,
  p_entry_value9     varchar2,
  p_entry_value10    varchar2,
  p_entry_value11    varchar2,
  p_entry_value12    varchar2,
  p_entry_value13    varchar2,
  p_entry_value14    varchar2,
  p_entry_value15    varchar2
 );
--
-- NAME
-- hr_entry.upd_3p_entry_values
--
-- DESCRIPTION
-- This procedure is used for third party updates into:
-- PAY_ELEMENT_ENTRY_VALUES_F
-- PAY_RUN_RESULTS           (If nonrecurring).
-- PAY_RUN_RESULT_VALUES     (If nonrecurring).
--
-- NB. this procedure is OVERLOADED !
--
 procedure upd_3p_entry_values
 (
  p_element_entry_id           number,
  p_element_type_id            number,
  p_element_link_id            number,
  p_cost_allocation_keyflex_id number,
  p_entry_type                 varchar2,
  p_processing_type            varchar2,
  p_creator_type               varchar2,
  p_creator_id                 number,
  p_assignment_id              number,
  p_input_currency_code        varchar2,
  p_output_currency_code       varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date,
  p_session_date               date,
  p_dt_update_mode             varchar2,
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
 );
--
-- NAME
-- hr_entry.upd_3p_entry_values
--
-- DESCRIPTION
-- This procedure is used for third party updates into:
-- PAY_ELEMENT_ENTRY_VALUES_F
-- PAY_RUN_RESULTS           (If nonrecurring).
-- PAY_RUN_RESULT_VALUES     (If nonrecurring).
--
-- NB. this Procedure is OVERLOADED !
--
 procedure upd_3p_entry_values
 (
  p_element_entry_id           number,
  p_element_type_id            number,
  p_element_link_id            number,
  p_cost_allocation_keyflex_id number,
  p_entry_type                 varchar2,
  p_processing_type            varchar2,
  p_creator_type               varchar2,
  p_creator_id                 number,
  p_assignment_id              number,
  p_input_currency_code        varchar2,
  p_output_currency_code       varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date,
  p_session_date               date,
  p_dt_update_mode             varchar2,
  p_input_value_id1            number,
  p_input_value_id2            number,
  p_input_value_id3            number,
  p_input_value_id4            number,
  p_input_value_id5            number,
  p_input_value_id6            number,
  p_input_value_id7            number,
  p_input_value_id8            number,
  p_input_value_id9            number,
  p_input_value_id10           number,
  p_input_value_id11           number,
  p_input_value_id12           number,
  p_input_value_id13           number,
  p_input_value_id14           number,
  p_input_value_id15           number,
  p_entry_value1               varchar2,
  p_entry_value2               varchar2,
  p_entry_value3               varchar2,
  p_entry_value4               varchar2,
  p_entry_value5               varchar2,
  p_entry_value6               varchar2,
  p_entry_value7               varchar2,
  p_entry_value8               varchar2,
  p_entry_value9               varchar2,
  p_entry_value10              varchar2,
  p_entry_value11              varchar2,
  p_entry_value12              varchar2,
  p_entry_value13              varchar2,
  p_entry_value14              varchar2,
  p_entry_value15              varchar2
 );
--
procedure chk_creator_type(p_element_entry_id      in number,
                           p_creator_type          in varchar2,
                           p_quickpay_mode         in varchar2,
                           p_dml_operation         in varchar2,
                           p_dt_update_mode        in varchar2,
                           p_dt_delete_mode        in varchar2,
                           p_validation_start_date in date,
                           p_validation_end_date   in date);
--
--------------------------------------
--
-- NAME hr_entry.delete_covered_dependants
--
-- DESCRIPTION deals with calls to update BEN_COVERED_DPENDENTS for a given
--             element_entry
--
---------------------------------------
procedure delete_covered_dependants(
   p_validation_start_date in date,
   p_element_entry_id      in number,
   p_start_date            in date DEFAULT NULL,
   p_end_date              in date DEFAULT NULL);



------------------------------------------
--
-- NAME hr_entry.delete_beneficiaries
--
-- DESCRIPTION deals with calls to update BEN_BENEFICIARIES for a given
--             element_entry
--
-------------------------------------------
procedure delete_beneficiaries(
   p_validation_start_date in date,
   p_element_entry_id      in number,
   p_start_date            in date DEFAULT NULL,
   p_end_date              in date DEFAULT NULL);

end hr_entry;

/
