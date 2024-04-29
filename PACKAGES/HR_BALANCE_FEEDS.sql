--------------------------------------------------------
--  DDL for Package HR_BALANCE_FEEDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BALANCE_FEEDS" AUTHID CURRENT_USER as
/* $Header: pybalfed.pkh 115.2 2003/04/15 09:26:44 rthirlby ship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    hr_balance_feeds
  Purpose
    Maintains balances feeds. It provides functions and procedures
    to allow the safe creation of manual balance feeds as well as
    procedures to generate automatic balance feeds ie. when adding a
    balance classification, adding a sub classification rule etc ...
  Notes

  History
    01-Mar-94  J.S.Hobbs   40.0         Date created.
    30-JUL-2002 RThirlby  115.1         Bug 2430399 Added p_mode parameter to
                                        ins_bf_bal_class, so can be called from
                                        hr_legislation, and not raise an error
                                        in ins_bal_feed, if the feed already
                                        exists.
    14-APR-2003 RThirlby  115.2         Bug 2888183. Added p_mode parameter to
                                        ins_bf_sub_class_rule and
                                        ins_bf_pay_value, so they can be called
                                        from hr_legislation_elements, and not
                                        raise an error in ins_bal_feed, if the
                                        feed already exists.
 ============================================================================*/
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- bal_classifications_exist                                                --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns TRUE if a balance classification exists.                         --
 ------------------------------------------------------------------------------
--
 function bal_classifications_exist
 (
  p_balance_type_id number
 ) return boolean;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- manual_bal_feeds_exist                                                   --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns TRUE if a manual balance feed exists.                            --
 ------------------------------------------------------------------------------
--
 function manual_bal_feeds_exist
 (
  p_balance_type_id number
 ) return boolean;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- lock_balance_type                                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Takes a row level lock out on a specified balance type.                  --
 ------------------------------------------------------------------------------
--
 procedure lock_balance_type
 (
  p_balance_type_id number
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- bal_feed_end_date                                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns the correct end date for a balance feed. It takes into account   --
 -- the end date of the input value and also any future balance feeds.       --
 ------------------------------------------------------------------------------
--
 function bal_feed_end_date
 (
  p_balance_feed_id       number,
  p_balance_type_id       number,
  p_input_value_id        number,
  p_session_date          date,
  p_validation_start_date date
 ) return date;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- pay_value_name                                                           --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns the translated name for the 'Pay Value'.                         --
 ------------------------------------------------------------------------------
--
 function pay_value_name return varchar2;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- ins_bf_bal_class                                                         --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates balance feeds when a balance classification has been added.      --
 -- Parameter p_mode added, so can be run from hr_legislation, without       --
 -- raising an error when a feed already exists. Valid modes are 'FORM' for  --
 -- original functionality, and 'STARTUP' for hr_legislation functionality.  --
 ------------------------------------------------------------------------------
--
 procedure ins_bf_bal_class
 (
  p_balance_type_id           number,
  p_balance_classification_id number,
  p_mode                      varchar2 default 'FORM'
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- upd_del_bf_bal_class                                                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- When updating or deleting a balance classification cascade to linked     --
 -- balance feeds NB. the parameter p_mode is used to specify which ie.      --
 -- 'UPDATE' or 'DELETE'.                                                    --
 ------------------------------------------------------------------------------
--
 procedure upd_del_bf_bal_class
 (
  p_mode                      varchar2,
  p_balance_classification_id number,
  p_scale                     number
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- ins_bf_pay_value                                                         --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates balance feeds when a pay value is created.                       --
 -- Parameter p_mode added, so can be run from hr_legislation_elements,      --
 -- without raising an error when a feed already exists. Valid modes are     --
 -- 'FORM' for original functionality, and 'STARTUP' for hr_legislation      --
 -- functionality.                                                           --
 ------------------------------------------------------------------------------
--
 procedure ins_bf_pay_value
 (
  p_input_value_id number
 ,p_mode           varchar2 default 'FORM'
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- ins_bf_sub_class_rule                                                    --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates automatic balance feeds when a sub classification rule is added. --
 -- Parameter p_mode added, so can be run from hr_legislation_elements,      --
 -- without raising an error when a feed already exists. Valid modes are     --
 -- 'FORM' for original functionality, and 'STARTUP' for hr_legislation      --
 -- functionality.                                                           --
 ------------------------------------------------------------------------------
--
 procedure ins_bf_sub_class_rule
 (
  p_sub_classification_rule_id number
 ,p_mode                       varchar2 default 'FORM'
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- del_bf_input_value                                                       --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Adjusts or removes balance feeds when an input value is deleted NB.      --
 -- when shortening an input value all related balance feeds are shortened.  --
 -- When extending a balance feed then only automatic balance feeds are      --
 -- extended.                                                                --
 ------------------------------------------------------------------------------
--
 procedure del_bf_input_value
 (
  p_input_value_id        number,
  p_dt_mode               varchar2,
  p_validation_start_date date,
  p_validation_end_date   date
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- del_bf_sub_class_rule                                                    --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Adjusts or removes balance feeds when a sub classification rule is       --
 -- deleted NB. this only affects automatic balance feeds.                   --
 ------------------------------------------------------------------------------
--
 procedure del_bf_sub_class_rule
 (
  p_sub_classification_rule_id number,
  p_dt_mode                    varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- chk_proc_run_results                                                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Detects if a change in a balance feed could result in a change of a      --
 -- balance value ie. the period over which the balance feed changes         --
 -- overlaps with a processed run result NB. the change in balance feed      --
 -- couold be caused by a manual change, removing a sub classification etc.. --
 ------------------------------------------------------------------------------
--
 function bf_chk_proc_run_results
 (
  p_mode                       varchar2,
  p_dml_mode                   varchar2,
  p_balance_type_id            number,
  p_classification_id          number,
  p_balance_classification_id  number,
  p_balance_feed_id            number,
  p_sub_classification_rule_id number,
  p_input_value_id             number,
  p_validation_start_date      date,
  p_validation_end_date        date
 ) return boolean;
--
end HR_BALANCE_FEEDS;

 

/
