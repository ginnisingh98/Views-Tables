--------------------------------------------------------
--  DDL for Package Body HRBALDTM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRBALDTM" as
/* $Header: pybaldtm.pkb 115.0 99/07/17 05:44:24 porting ship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pybaldtm.pkb           - Payroll Balance for DaTe Mode
--
   DESCRIPTION
      This procedure is called from the Balance user exit 'C' code. Its
      purpose is to insert an assignment action for the given assignment id on
      the given date.  This assignment action id is then passed back to the
      user exit to calculate the balance.  The user exit is expected to
      perform the savepoint and rollback to remove the assignment
      action. The procedure first creates a payroll action which is used
      to insert the assignment action on the effective date.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   19-JAN-1995 - Temp. insert into pay_payroll_actions now also
                              populates date_earned with the virtual date
                              value.
     mwcallag   10-JAN-1995 - New mandatory column 'object_version_number'
                              added to insert of pay_payroll_actions.
     mwcallag   01-OCT-1993 - created.
*/
procedure get_bal_ass_action
(
    p_business_group_id     in  number,
    p_assignment_id         in  number,
    p_date                  in  date,
    p_ass_action_id         out number
)is
l_payroll_id     per_assignments_f.payroll_id%type;
l_consol_set_id  pay_payrolls_f.payroll_id%type;
l_ass_action_id  pay_assignment_actions.assignment_action_id%type;
l_pay_action_id  pay_payroll_actions.payroll_action_id%type;
begin
    --
    -- get the payroll id and the consolidation set id
    --
    hr_utility.set_location ('hrbaldtm.get_bal_ass_action', 1);
    select ASSIGN.payroll_id,
           PAYROLL.consolidation_set_id
    into   l_payroll_id,
           l_consol_set_id
    from   per_assignments_f       ASSIGN,
           pay_payrolls_f          PAYROLL
    where  ASSIGN.assignment_id  = p_assignment_id
    and    p_date          between ASSIGN.effective_start_date
                               and ASSIGN.effective_end_date
    and    PAYROLL.payroll_id    = ASSIGN.payroll_id
    and    p_date          between PAYROLL.effective_start_date
                               and PAYROLL.effective_end_date;
    --
    -- get the next value for payroll action id
    --
    hr_utility.set_location ('hrbaldtm.get_bal_ass_action', 2);
    select pay_payroll_actions_s.nextval
    into   l_pay_action_id
    from   dual;
    --
    -- insert a temporary row into pay_payroll_actions
    --
    hr_utility.set_location ('hrbaldtm.get_bal_ass_action', 3);
    insert into pay_payroll_actions
    (payroll_action_id,
     action_type,
     business_group_id,
     consolidation_set_id,
     payroll_id,
     action_population_status,
     action_status,
     effective_date,
     date_earned,
     object_version_number)
    values
    (l_pay_action_id,
     'N',                           -- not tracked action type
     p_business_group_id,
     l_consol_set_id,
     l_payroll_id,
     'U',
     'U',
     p_date,
     p_date,
     1);
    --
    -- now insert the assigment action:
    --
    hr_utility.set_location ('hrbaldtm.get_bal_ass_action', 4);
    hrassact.inassact (l_pay_action_id, p_assignment_id);
    --
    -- retrieve the assignment action id:
    --
    hr_utility.set_location ('hrbaldtm.get_bal_ass_action', 5);
    select assignment_action_id
    into   l_ass_action_id
    from   pay_assignment_actions
    where  payroll_action_id = l_pay_action_id;
    --
    hr_utility.trace ('Assignment action id = ' || to_char (l_ass_action_id));
    p_ass_action_id := l_ass_action_id;
end;
end hrbaldtm;

/
