--------------------------------------------------------
--  DDL for Package Body HR_LEG_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEG_RULE" as
/* $Header: pylegrle.pkb 115.1 99/07/17 06:15:33 porting ship  $ */
--
   --  these two variables cache the independent_time_periods flag
   last_tested_business_group_id  number;
   last_found_flag                varchar2(240);
--
   function get_independent_periods
      (l_business_group_id in number)
   return varchar2 is
   begin
      /*
         For efficiency (since the value is likely to be the same
         for any given installation) we "cache" the flag's value
         against business_group_id.
      */
      if hr_leg_rule.last_tested_business_group_id is null or
         hr_leg_rule.last_tested_business_group_id <> l_business_group_id then
--
         --  we need to fetch the value
         begin
            select LR.rule_mode
            into   hr_leg_rule.last_found_flag
            from   pay_legislation_rules LR
            where  LR.rule_type = 'I'
            and    LR.legislation_code =
               (select BG.legislation_code
                from   per_business_groups BG
                where  BG.business_group_id = l_business_group_id);
         exception
           --  if there is no rule, we set a default (independent periods).
           when no_data_found then hr_leg_rule.last_found_flag := 'Y';
         end;
--
         hr_leg_rule.last_tested_business_group_id := l_business_group_id;
      end if;
      return hr_leg_rule.last_found_flag;
--
   end get_independent_periods;
--
-- Initialisation Section
-- ----------------------
--
   begin
      hr_leg_rule.last_tested_business_group_id := null;
--
end hr_leg_rule;

/
