--------------------------------------------------------
--  DDL for Package PAY_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_PKG" AUTHID CURRENT_USER as
/* $Header: pybaluex.pkh 120.4.12010000.1 2008/07/27 22:08:22 appldev ship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1995 All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
NAME
    pybaluex.pkh   - PL/SQL Balance User Exit
--
DESCRIPTION
    Procedure and Function headers for retrieving balance and database item
    values using dynamic pl/sql
--
MODIFIED (DD-MON-YYYY)
    nbristow  16-JAN-2006  - Added maintain_balances_for_action.
    RThirlby  20-NOV-2006  - 5619425 - Altered following procedures to take
                             p_eff_date and p_delta parameters to enable
                             Generate Run Balances in DELTA mode to use balance
                             attributes, and thus process more quickly:
                               create_asg_balance, create_all_asg_balances
                               create_group_balance, create_all_group_balances
    RThirlby  24-OCT-2006  - Altered code so that Generate Run Balances
                             SINGLE mode will utilise balance_attributes
                             to improve performance. Added new paramter
                             p_bal_att to create_asg_balance, and
                             create_group_balance.
    nbristow  06-JUN-2005  - Added new contexts.
    RThirlby  06-MAY-2005  - Added Original Entry Id to get value call.
    nbristow  04-MAY-2005  - Added Payroll ID to get_value call.
    nbristow  03-MAY-2005  - Added Time Definition ID and Balance Date
                             for generate Run Balances.
    nbristow  15-JUN-2004  - Made the set run balance functions
                             visable.
    thabara   30-MAR-2004  - Added create_rr_asg_balances.
    ALogue    22-MAR-2004  - Added set_check_latest_balances and
                             unset_check_latest_balances procedures.
                             Also removed last change.
    ALogue    19-MAR-2004  - Added CHECK_RUN_BALANCES global.
    nbristow  09-DEC-2003  - Added get_context_internal.
    nbristow  01-DEC-2003  - Changes to improve the performance of
                             the assignment level balance creation.
    ALogue    05-JUN-2003  - Bug 2960902 - Added new overloaded procedure
                             invalidate_run_balances passed only balance_type_id
                             and trash_date.
    RThirlby  20-May-2003  - Removed defaults of 'FALSE' on parameters
                             p_get_rr_route and p_get_rb_route in get_value.
    RThirlby  19-MAY-2003  - Bug 2898484 - 2 new parameters, p_source_text2
                             and p_source_number added to get_value with null
                             defaults. Also defaults of FALSE added to
                             parameters p_get_rr_route and p_get_rb_route.
    RThirlby  15-MAY-2003  - Bug 2959584 - New procedure initialise_run_balance,
                             will be called from insert trigger for
                             pay_defined_balances.
    SuSivasu  11-APR-2003  - Overloading of get_value to include the
                             ORIGINAL_ENTRY_ID context.
    nbristow  21-FEB-2003  - Added new PAYMENT period type.
    nbristow  07-FEB-2003  - Added new set_contexts
    nbristow  05-FEB-2003  - Added new contexts.
    nbristow  05-DEC-2002  - Performance changes for run balances.
    nbristow  16-OCT-2002  - Added get_period_type_start procedure.
    nbristow  10-OCT-2002  - Changes for Run Balances phase 2, including
                             batch balance retrieval.
    RThirlby  03-OCT-2002  - Bug 2552864 - Added new parameter to
                              invalidate_run_balances.
    RThirlby  02-MAY-2002  - Added following procedures and supporting functions
                             for maintaining assignment and group level run
                             balances - used in reversal and balance
                             adjustments:
                               create_asg_balance
                               create_all_asg_balances
                               create_group_balance
                               create_all_group_balances
                               find_context
                               split_jurisdiction
                               ins_run_balance
                             Added support for rollback of run balances, with
                             new procedure remove_balance_contribs.
    RThirlby   07-MAR-2002 - Added procedure remove_asg_contribs_from_grp_bals.
    RThirlby   01-MAR-2002 - 2 more overloaded versions of get_value to use run
                             balance architecture. 2 overloaded versions of
                             get_run_balance (the run balance equivalent of
                             get_db_item).
                             Also added procedure invalidate_run_balances -
                             which is called from the balance_feeds triggers.
    SuSivasu   28-Feb-2002 - Added chk_contex function.
    RThirlby   06-APR-2001 - Overloaded version of run_db_item, for performance
                             improvements.
    SuSivasu   06-APR-2001 - Overloading of get_value to include the
                             SOURCE_TEXT context.
    nbristow   14-SEP-2000 - Changes for the new expiry checking
                             types for complex balances.
    nbristow   30-JUN-2000 - Added p_tax_group to get_value call.
    nbristow   31-MAY-2000 - Added new get_value that supplies context values.
    dzshanno   30-JUN-1998 - add function get_context, called by core archiver
    nbristow   18-DEC-1996 - Fixed previous change by reverting the get_value
                             call to its original format and adding a new
                             function get_value_lock.
    nbristow   20-NOV-1996 - Changed get_value (date mode) to be called
                             with a flag indicating whether the assignment
                             rows are to be locked.
    mwcallag   20-FEB-1995 - Overloading of get_value rather than using a
                             default parameter added since currently calls
                             from forms do not support default parameters.
    mwcallag   08-FEB-1995 - Support for latest balances added.
    mwcallag   18-JAN-1995 - Created.
*/
--
-- Setup the types
--
type t_balance_value_rec is record
(defined_balance_id pay_defined_balances.defined_balance_id%type,
 balance_value      number
);
type t_balance_value_tab is table of t_balance_value_rec
  index by binary_integer;
--
type t_detailed_bal_out_rec is record
(defined_balance_id pay_defined_balances.defined_balance_id%type,
 tax_unit_id        pay_assignment_actions.tax_unit_id%type,
 jurisdiction_code  pay_run_results.jurisdiction_code%type,
 source_id          pay_run_result_values.result_value%type,
 source_text        pay_run_result_values.result_value%type,
 source_number      pay_run_result_values.result_value%type,
 source_text2       pay_run_result_values.result_value%type,
 time_def_id        pay_run_results.time_definition_id%type,
 balance_date       pay_run_results.end_date%type,
 local_unit_id      pay_run_results.local_unit_id%type,
 source_number2     pay_run_result_values.result_value%type,
 organization_id    pay_run_result_values.result_value%type,
 balance_value      number,
--
 /* These are internal values set by the procedures */
 balance_found      boolean,
 jurisdiction_lvl   pay_balance_types.jurisdiction_level%type
);
type t_detailed_bal_out_tab is table of t_detailed_bal_out_rec
  index by binary_integer;
--
-- Context combination cache.
--
type t_context_rec is record
(
 tax_unit_id      pay_assignment_actions.tax_unit_id%type,
 jurisdiction_code pay_run_results.jurisdiction_code%type,
 source_id         number,
 source_text       pay_run_result_values.result_value%type,
 source_number     number,
 source_text2      pay_run_result_values.result_value%type,
 time_def_id        pay_run_results.time_definition_id%type,
 balance_date       pay_run_results.end_date%type,
 local_unit_id      pay_run_results.local_unit_id%type,
 source_number2     number,
 organization_id    number
);
--
type t_context_tab is table of t_context_rec index by binary_integer;
--
-- balance expiry checking constants
--
BALANCE_NOT_EXPIRED  constant number := 0 ;
BALANCE_EXPIRED      constant number := 1 ;
--
--------------------------- get_period_type_start -------------------------------
 /* Name    : get_period_type_start
  Purpose   : This returns the start date of a period type given an
              effective_date.
  Arguments :
       p_period_type is mandatory
       p_effective_date is mandatory
       p_start_date_code is only required for period_type DYNAMIC
       p_payroll_id is only required for period_type PERIOD
       p_bus_grp is only needed for period_type TYEAR, TQUARTER, FYEAR and
                 FQUARTER
       p_action_type is only needed for period_type PAYMENT
       p_asg_action is only needed for period_type PAYMENT

  Notes     :
 */
procedure get_period_type_start(p_period_type    in            varchar2,
                               p_effective_date  in            date,
                               p_start_date         out nocopy date,
                               p_start_date_code in            varchar2 default null,
                               p_payroll_id      in            number   default null,
                               p_bus_grp         in            number   default null,
                               p_action_type     in            varchar2 default null,
                               p_asg_action      in            number   default null);
--
------------------------------- chk_context -------------------------------
--
function chk_context
(
    p_context_id           in number,
    p_route_id             in number
) return varchar2;
--
------------------------------- get_context -------------------------------
--
function get_context
(
    p_context_name    in varchar2
) return varchar2;
function get_context_internal
(
    p_context_name    in varchar2
) return varchar2;
--
------------------------------- set_context -------------------------------
--
procedure set_context
(
    p_context_name   in varchar2,
    p_context_value  in varchar2
);
--
procedure set_context
(
    p_legislation_code in varchar2,
    p_context_name     in varchar2,
    p_context_value    in varchar2
);
--
------------------------------- run_db_item -------------------------------
--
function run_db_item
(
    p_database_name    in  varchar2,
    p_bus_group_id     in  number,
    p_legislation_code in  varchar2
) return varchar2;
--
------------------------------- run_db_item -------------------------------
--
function run_db_item
(p_def_bal_id in number) return varchar2;
--
-------------------------- get_run_balance -------------------------------
--
--function get_run_balance
--(p_def_bal_id in number
--,p_priority   in number
--,p_route_type in varchar2) return varchar2;
--
------------------------- get_run_balance --------------------------------
--
--function get_run_balance
--(p_user_name         in varchar2
--,p_business_group_id in number
--,p_legislation_code  in varchar2
--,p_route_type        in varchar2
--) return varchar2;
------------------------- check_bal_expiry -------------------------------
--
function check_bal_expiry
(
   p_bal_owner_asg_action       in     number,    -- assact created balance.
   p_assignment_action_id       in     number,    -- current assact..
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_checking_level      in     varchar2,
   p_expiry_checking_code       in     varchar2,
   p_bal_context_str            in     varchar2   -- list of context values.
) return boolean;
--
------------------------------- get_value -------------------------------
--
--                  ---- Assignment action mode -----
--
procedure get_value (p_assignment_action_id in            number,
                     p_defined_balance_lst  in            t_balance_value_tab,
                     p_context_lst          in            t_context_tab,
                     p_get_rr_route         in            boolean default FALSE,
                     p_get_rb_route         in            boolean default FALSE,
                     p_output_table            out nocopy t_detailed_bal_out_tab);
procedure get_value (p_assignment_action_id in            number,
                     p_defined_balance_lst  in out nocopy t_balance_value_tab,
                     p_get_rr_route         in            boolean default FALSE,
                     p_get_rb_route         in            boolean default FALSE);
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_tax_unit_id          in number,
    p_jurisdiction_code    in varchar2,
    p_source_id            in number,
    p_tax_group            in varchar2,
    p_date_earned          in date
) return number;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number
) return number;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_always_get_db_item   in boolean
) return number;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_tax_unit_id          in number,
    p_jurisdiction_code    in varchar2,
    p_source_id            in number,
    p_source_text          in varchar2,
    p_tax_group            in varchar2,
    p_date_earned          in date
) return number;
--
-- Added to support original_entry_id.
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_tax_unit_id          in number,
    p_jurisdiction_code    in varchar2,
    p_source_id            in number,
    p_source_text          in varchar2,
    p_tax_group            in varchar2,
    p_original_entry_id    in number,
    p_date_earned          in date
) return number;
--
function get_value
(p_defined_balance_id   in number
,p_assignment_action_id in number
,p_tax_unit_id          in number
,p_jurisdiction_code    in varchar2
,p_source_id            in number
,p_source_text          in varchar2
,p_tax_group            in varchar2
,p_date_earned          in date
,p_get_rr_route         in varchar2
,p_get_rb_route         in varchar2
,p_source_text2         in varchar2 default null
,p_source_number        in number   default null
,p_time_def_id          in number   default null
,p_balance_date         in date     default null
,p_payroll_id           in number   default null
,p_original_entry_id    in number   default null
,p_local_unit_id        in number   default null
,p_source_number2       in number   default null
,p_organization_id      in number   default null
) return number;
--
function get_value
(   p_defined_balance_id   in number
,   p_assignment_action_id in number
,   p_get_rr_route         in boolean
,   p_get_rb_route         in boolean
) return number;
--
------------------------------- get_value -------------------------------
--
--                         ---- Date mode ----
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date
) return number;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_always_get_db_item   in boolean
) return number;
--
function get_value_lock
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_asg_lock             in varchar2
) return number;
--
function get_value_lock
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_always_get_db_item   in boolean,
    p_asg_lock             in varchar2
) return number;
--------------------------------------------------------------------------
-- procedure invalidate_run_balances
--------------------------------------------------------------------------
procedure invalidate_run_balances(p_balance_type_id in number,
                                  p_input_value_id  in number,
                                  p_invalid_date    in date);
--
--------------------------------------------------------------------------
-- procedure invalidate_run_balances
--------------------------------------------------------------------------
procedure invalidate_run_balances(p_balance_type_id in number,
                                  p_invalid_date    in date);
--
--------------------------------------------------------------------------
-- function find_context
--------------------------------------------------------------------------
function find_context(p_context_name in varchar2,
                      p_context_id   in number) return varchar2;
--------------------------------------------------------------------------
-- remove_asg_contribs
-- Description: Removes assignment contributions to a run balance group balance
--              from the run balance group balance, i.e. when an assignment is
--              rolled back, the group balance needs to redueced by the
--              amount contributed by that assignment.
--
--------------------------------------------------------------------------
procedure remove_asg_contribs
(p_payroll_action_id   in number
,p_assignment_action_id in number
,p_multi_thread in boolean default false
);
--------------------------------------------------------------------------
-- procedure create_asg_balance
--------------------------------------------------------------------------
procedure create_asg_balance(p_def_bal_id in number,
                             p_asgact_id  in number,
                             p_load_type  in varchar2 default 'NORMAL'
                            ,p_bal_att    in varchar2 default NULL
                            ,p_eff_date   in date     default NULL
                            ,p_delta      in varchar2 default NULL);
--------------------------------------------------------------------------
-- procedure create_rr_asg_balances
--------------------------------------------------------------------------
-- Description: This procedure creates assignment level run balances
--              based on the specified run result id.
--
procedure create_rr_asg_balances
  (p_run_result_id    in number
  );
--------------------------------------------------------------------------
-- procedure create_set_asg_balance
--------------------------------------------------------------------------
procedure create_set_asg_balance(
       p_defined_balance_lst  in out nocopy t_balance_value_tab,
       p_asgact_id            in            number,
       p_load_type            in            varchar2 default 'NORMAL');
--------------------------------------------------------------------------
-- procedure create_all_asg_balances
--------------------------------------------------------------------------
procedure create_all_asg_balances(p_asgact_id  in number
                                 ,p_bal_list   in varchar2 default 'ALL'
                                 ,p_load_type  in varchar2 default 'NORMAL'
                                 ,p_eff_date   in date     default null
                                 ,p_delta      in varchar2 default null);
--------------------------------------------------------------------------
-- procedure create_group_balance
--------------------------------------------------------------------------
procedure create_group_balance(p_def_bal_id in number
                              ,p_pact_id    in number
                              ,p_load_type  in varchar2 default 'NORMAL'
                              ,p_bal_att    in varchar2 default NULL
                              ,p_eff_date   in date     default NULL
                              ,p_delta      in varchar2 default null);
--------------------------------------------------------------------------
-- procedure create_set_group_balance
--------------------------------------------------------------------------
procedure create_set_group_balance(
         p_defined_balance_lst  in out nocopy t_balance_value_tab,
         p_pact_id              in            number,
         p_load_type            in            varchar2 default 'NORMAL');
--------------------------------------------------------------------------
-- procedure create_all_group_balances
--------------------------------------------------------------------------
procedure create_all_group_balances(p_pact_id    in number
                                   ,p_bal_list   in varchar2 default 'ALL'
                                   ,p_load_type  in varchar2 default 'NORMAL'
                                   ,p_eff_date   in date     default NULL
                                   ,p_delta      in varchar2 default NULL);
--------------------------------------------------------------------------
procedure initialise_run_balance(p_defbal_id         in number
                                ,p_baldim_id         in number
                                ,p_bal_type_id       in number
                                ,p_legislation_code  in varchar2
                                ,p_business_group_id in number);
--------------------------------------------------------------------------
-- procedure set_check_latest_balances
--------------------------------------------------------------------------
procedure set_check_latest_balances;
--------------------------------------------------------------------------
-- procedure unset_check_latest_balances
--------------------------------------------------------------------------
procedure unset_check_latest_balances;
--------------------------------------------------------------------------
procedure maintain_balances_for_action(p_asg_action in number
                                      );
end pay_balance_pkg;

/
