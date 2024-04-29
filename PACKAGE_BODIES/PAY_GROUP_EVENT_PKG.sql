--------------------------------------------------------
--  DDL for Package Body PAY_GROUP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GROUP_EVENT_PKG" 
/* $Header: pygrpevn.pkb 120.0.12000000.1 2007/04/10 09:57:07 ckesanap noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_group_event_pkg

    Description : Delivery of event qulaifier for group level events
		          criteria , for retro notification.
                  This package must be customized by the customer to
                  enable the event qualifier for FF_GLOBALS_F and
                  PAY_USER_COLUMN_INSTANCES_F.
                  There are few examples given for the customer to
                  base their code on.
    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    09-APR-2007 SuSivasu 120.0   5562866 Created.

  *******************************************************************/
AS
--
-- *******************************************************************
-- Function to check the global is attached ot the given assignment.
--
-- Parameters:
--    p_assignment_id : Assignment Id in question.
--    p_surrogate_key : Global_id in question.
-- *******************************************************************
function ff_global_check(p_assignment_id in number,
                         p_surrogate_key in number)  return  varchar2
is
--
--
begin
--
  --
  -- Place your code here to check whether the given global impacts
  -- the given assignment. If so then return 'Y'.
  --
  return 'N';
--
end;
--
-- *******************************************************************
-- Function to check whether the event is attached to the given entry.
-- *******************************************************************
function ff_global_qualifier  return  varchar2
is
--
begin
--
  --
  -- Place your code here to check whether the given global (i.e.
  -- pay_interpreter_pkg.g_object_key) impacts the given element entry
  -- (i.e. pay_interpreter_pkg.g_ee_id). If so then return 'Y'.
  --
  return 'N';
--
end;
--
-- *******************************************************************
-- Function to check the global is attached ot the given assignment.
--
-- Parameters:
--    p_assignment_id : Assignment Id in question.
--    p_surrogate_key : Global_id in question.
-- *******************************************************************
function pay_user_table_check(p_assignment_id in number,
                              p_surrogate_key in number)  return  varchar2
is
--
begin
--
  --
  -- Place your code here to check whether the given user column
  -- instance impacts the given assignment. If so then return 'Y'.
  --
  return 'N';
--
end;
--
-- *******************************************************************
-- Function to check whether the event is attached to the given entry.
-- *******************************************************************
function pay_user_table_qualifier  return  varchar2
is
--
begin
--
  --
  -- Place your code here to check whether the given user column instance (i.e.
  -- pay_interpreter_pkg.g_object_key) impacts the given element entry
  -- (i.e. pay_interpreter_pkg.g_ee_id). If so then return 'Y'.
  --
  return 'N';
--
end;
--
/*
--
--
-- *******************************************************************
-- EXAMPLE 1: FF_GLOBALS_F
-- This takes the following path, which can casue performance issue:
--
--   Global > Formula > Formula Processing Rule > Formula Result Rule
--   > Element > Entry > Assignment
--
-- *******************************************************************
--
-- Function to check whether the event is in fact tied to the
-- assignment in question.
--
function ff_global_check(p_assignment_id in number,
                         p_surrogate_key in number)  return  varchar2
is
--
cursor validate_event(p_assignment_id in number,
                      p_surrogate_key in number)
is
  select '' chk
  from dual
  where exists (
  select pee.assignment_id
  from  ff_fdi_usages_f fdi
  ,     ff_globals_f glb
  ,     ff_formulas_f ff
  ,     PAY_STATUS_PROCESSING_RULES_F psp
  ,     PAY_FORMULA_RESULT_RULES_F pfr
  ,     pay_element_entries_f pee
  where glb.global_id = p_surrogate_key
  and   pee.assignment_id = p_assignment_id
  and   fdi.item_name = glb.global_name
  and   ff.formula_id = fdi.formula_id
  and   ((glb.legislation_code is null and glb.business_group_id is null) or
        (glb.legislation_code = ff.legislation_code) or
        (glb.business_group_id = ff.business_group_id) or
        (glb.legislation_code =
         (select bg.legislation_code
          from   per_business_groups_perf bg
          where bg.business_group_id = ff.business_group_id))
       )
  and   psp.formula_id = ff.formula_id
  and   pfr.STATUS_PROCESSING_RULE_ID = psp.STATUS_PROCESSING_RULE_ID
  );
--
  l_valid_event VARCHAR2(1);
--
begin
      l_valid_event := 'N';
--
      for grrec in validate_event(p_assignment_id,p_surrogate_key) loop
         l_valid_event := 'Y';
      end loop;
--
      return l_valid_event;
--
end;
--
--
-- Function used by the qualifier.
--
function ff_global_qualifier  return  varchar2
is
--
cursor global_affected is
select '' chk
from dual
where exists (
select pee.assignment_id
from  ff_fdi_usages_f fdi
,     ff_globals_f glb
,     ff_formulas_f ff
,     PAY_STATUS_PROCESSING_RULES_F psp
,     PAY_FORMULA_RESULT_RULES_F pfr
,     pay_element_entries_f pee
where glb.global_id = pay_interpreter_pkg.g_object_key
and   pee.element_entry_id = pay_interpreter_pkg.g_ee_id
and   pee.effective_end_date >= fdi.effective_start_date
and   pee.effective_start_date <= fdi.effective_end_date
and   fdi.item_name = glb.global_name
and   ff.formula_id = fdi.formula_id
and   ff.effective_start_date = fdi.effective_start_date
and   ff.effective_end_date = fdi.effective_end_date
and   ((glb.legislation_code is null and glb.business_group_id is null) or
      (glb.legislation_code = ff.legislation_code) or
      (glb.business_group_id = ff.business_group_id) or
      (glb.legislation_code =
       (select bg.legislation_code
        from   per_business_groups_perf bg
        where bg.business_group_id = ff.business_group_id))
     )
and   psp.formula_id = ff.formula_id
and   pee.effective_end_date >= psp.effective_start_date
and   pee.effective_start_date <= psp.effective_end_date
and   pfr.STATUS_PROCESSING_RULE_ID = psp.STATUS_PROCESSING_RULE_ID
and   pee.effective_end_date >= pfr.effective_start_date
and   pee.effective_start_date <= pfr.effective_end_date
);
--
l_exists varchar2(1);
--
begin
--
  open global_effected;
  fetch global_effected into l_exists;
--
  if global_effected%notfound then
   close global_effected;
   return 'N';
  else
   close global_effected;
   return 'Y';
  end if;
--
end;
--
--
-- *******************************************************************
-- END OF EXAMPLE 1
-- *******************************************************************
--
-- *******************************************************************
-- EXAMPLE 2: FF_GLOBALS_F
--
-- This assumes the global which the customer wants to track are
-- "STANDARD_RATE" and "OVERTIME_RATE", where by these will be used by
-- elements "Time Card" and "Overtime".
--
-- *******************************************************************
--
-- Function to check whether the event is in fact tied to the
-- assignment in question.
--
function ff_global_check(p_assignment_id in number,
                         p_surrogate_key in number)  return  varchar2
is
--
cursor validate_event(p_assignment_id in number,
                      p_surrogate_key in number)
is
  select '' chk
  from dual
  where exists (
  select pee.assignment_id
  from  ff_globals_f glb
  ,     pay_element_entries_f pee
  ,     pay_element_types_f pet
  where glb.global_id = p_surrogate_key
  and   pee.assignment_id = p_assignment_id
  and   glb.global_name in ('STANDARD_RATE','OVERTIME_RATE')
  and   pee.element_type_id = pet.element_type_id
  and   pet.element_name in ('Time Card','Overtime')
  );
--
  l_valid_event VARCHAR2(1);
--
begin
      l_valid_event := 'N';
--
      for grrec in validate_event(p_assignment_id,p_surrogate_key) loop
         l_valid_event := 'Y';
      end loop;
--
      return l_valid_event;
--
end;
--
--
-- Function used by the qualifier.
--
function ff_global_qualifier  return  varchar2
is
--
cursor global_affected is
select '' chk
from dual
where exists (
  select pee.assignment_id
  from  ff_globals_f glb
  ,     pay_element_entries_f pee
  ,     pay_element_types_f pet
  where glb.global_id = p_surrogate_key
  and   pee.assignment_id = p_assignment_id
  and   glb.global_name in ('STANDARD_RATE','OVERTIME_RATE')
  and   pee.element_type_id = pet.element_type_id
  and   pet.element_name in ('Time Card','Overtime')
  and   pee.effective_end_date >= pet.effective_start_date
  and   pee.effective_start_date <= pet.effective_end_date
);
--
l_exists varchar2(1);
--
begin
--
  open global_effected;
  fetch global_effected into l_exists;
--
  if global_effected%notfound then
   close global_effected;
   return 'N';
  else
   close global_effected;
   return 'Y';
  end if;
--
end;
--
-- *******************************************************************
-- END OF EXAMPLE 2
-- *******************************************************************
*/

end pay_group_event_pkg;

/
