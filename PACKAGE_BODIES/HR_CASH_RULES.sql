--------------------------------------------------------
--  DDL for Package Body HR_CASH_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CASH_RULES" as
/* $Header: pycshrle.pkb 115.0 99/07/17 05:55:27 porting ship $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    hr_cash_rules (hrpca.pkb)
  NOTES
     Package available to user for implementation of cash analysis rules.
  USAGE
    The method of calling a cash rule is dependant upon the coder knowing the
    name of the cash rule to be implemented.  The rule should then be trapped
    in an IF statement, and hr_pre_pay.coin_rule called to implement.
    --
    For example suppose it was required to pay at least three five dollar
    bills in a certain pay packet.  This cash organization payment method
    has been set up with the name 'FIVE DOLLAR RULE'.  It would be implemented
    here as follows:
    --
    if cash_rule = 'FIVE DOLLAR RULE' then
      --
      -- Pay three five dollar bills
      --
      hr_pre_pay.coin_rule(3,5);
      --
    end if;
    --
    This is all that is required.  Note that the remainder of the payment will
    be paid automatically using the default rule (ie pay using the highest
    denomination bill possible.
    --
  MODIFIED
    --
    amcinnes    28-JAN-1993  Created
     WMcVeagh   19-mar-98   Change create or replace 'as' not 'is'
  --
*/
--
--------------------------- user_rule -----------------------------------
/*
NAME
  user_rule
DESCRIPTION
  Perform user cash(coinage) analysis.
NOTES
  Uses the input parameter to decide which rule to implement.  Executes
  the required rules using hr_pre_pay.coin_rule and exits.
*/
  procedure user_rule(cash_rule in varchar2) is
  begin
    --
    -- Set up location in case of error
    --
    hr_utility.set_location('HR_CASH_RULES.USER_RULE',1);
    --
    -- INSERT USER RULES HERE
    --
    -- Dummy rule:
    --
    if cash_rule = 'MY RULE' then
      --
      -- call hr_pre_pay.coin_rule(null,number_of_units, value)
      --
      null;
      --
    end if;
    --
  end;
  --
end hr_cash_rules;

/
