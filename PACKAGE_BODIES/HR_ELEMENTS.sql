--------------------------------------------------------
--  DDL for Package Body HR_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ELEMENTS" as
/* $Header: pyelemnt.pkb 120.1.12010000.4 2010/01/06 10:37:22 sivanara ship $ */
g_debug boolean := hr_utility.debug_enabled;
--
 /*
 NAME
 chk_element_name
 DESCRIPTION
   Checks element name for duplication.
 */
--
PROCEDURE       chk_element_name(p_element_name         in varchar2,
                                 p_element_type_id      in number,
                                 p_val_start_date       in date,
                                 p_val_end_date         in date,
                                 p_business_group_id    in number,
                                 p_legislation_code     in varchar2)  is
--
        v_validation_check varchar(2) := 'Y';
begin
  -- if the business group is null then we should make sure that the
  -- element name is checked by legislation code.
--
      begin
--
        select 'N'
        into v_validation_check
        from sys.dual
        where exists (select 1
                from pay_element_types_f
                where upper(p_element_name) = upper(element_name)
                and (p_element_type_id <> element_type_id
                or p_element_type_id is null)
                and (p_business_group_id = business_group_id + 0
                or  (business_group_id is null
                and (p_legislation_code = legislation_code))));
--
      exception
         when NO_DATA_FOUND then NULL;
      end;
--
  if v_validation_check = 'N' then
--
   hr_utility.set_message(801,'PAY_6137_ELEMENT_DUP_NAME');
   hr_utility.raise_error;
--
  end if;
--
end chk_element_name;
--
 /*
 NAME
 chk_reporting_name
 DESCRIPTION
   Checks reporting name for duplication. Will only be called if reporting
   name is not null.
   THIS CHECK IS NO LONGER VALID AS WE NOW SUPPORT DUPLICATE REPORTING NAMES
 */
--
PROCEDURE       chk_reporting_name(p_reporting_name     in varchar2,
                                 p_element_type_id      in number,
                                 p_val_start_date       in date,
                                 p_val_end_date         in date,
                                 p_business_group_id    in number,
                                 p_legislation_code     in varchar2)  is
--
        v_validation_check varchar(2) := 'Y';
begin
  -- if the business group is null then we should make sure that the
  -- reporting name is checked by legislation
  null;
--
--      begin
--
--      select 'N'
--      into v_validation_check
--      from sys.dual
--      where exists (select 1
--              from pay_element_types_f
--              where upper(p_reporting_name) = upper(reporting_name)
--              and (p_element_type_id <> element_type_id
--                   or p_element_type_id is null)
--              and (p_business_group_id = business_group_id + 0
--                   or  (p_business_group_id is null
--              and (p_legislation_code = legislation_code))));
--
--      exception
--         when NO_DATA_FOUND then NULL;
--      end;
--
--   if v_validation_check = 'N' then
--
--     hr_utility.set_message(801,'PAY_6138_ELEMENT_DUP_REP_NAME');
--     hr_utility.raise_error;
--
--   end if;
--
end chk_reporting_name;
--
 /*
 NAME
 chk_element_type
 DESCRIPTION
   Checks attributes of element type according to business rules
 */
--
 PROCEDURE chk_element_type(p_element_name                    in varchar2,
                            p_element_type_id                 in number,
                            p_val_start_date                  in date,
                            p_val_end_date                    in date,
                            p_reporting_name                  in varchar2,
                            p_rowid                           in varchar2,
                            p_recurring_flag                  in varchar2,
                            p_standard_flag                   in varchar2,
                            p_scndry_ent_allwd_flag           in varchar2,
                            p_process_in_run_flag             in varchar2,
                            p_indirect_only_flag              in varchar2,
                            p_adjustment_only_flag            in varchar2,
                            p_multiply_value_flag             in varchar2,
                            p_classification_type             in varchar2,
                            p_output_currency_code            in varchar2,
                            p_input_currency_code            in varchar2,
                            p_business_group_id               in number,
                            p_legislation_code                in varchar2,
                            p_bus_grp_currency_code           in varchar2) is
--
 v_validation_check  varchar2(1);
--
 begin
--
  v_validation_check := 'Y';
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_element_type', 1);
        end if;
  -- Check element name
        hr_elements.chk_element_name(p_element_name,
                                     p_element_type_id,
                                     p_val_start_date,
                                     p_val_end_date,
                                     p_business_group_id,
                                     p_legislation_code);
  --
  -- Make sure that the reporting name is unique when it is specified
--
--  if p_reporting_name is not null then
--    hr_elements.chk_reporting_name(p_reporting_name,
--                                   p_element_type_id,
--                                   p_val_start_date,
--                                   p_val_end_date,
--                                   p_business_group_id,
--                                   p_legislation_code);
--  end if;
  --
--
  -- For a nonrecurring element the Standard Flag and the Secondary Entry Flag
  -- cannot be set to 'Y'
  if p_recurring_flag = 'N' then
--
   if p_standard_flag = 'Y' then
--
    hr_utility.set_message(801,'PAY_6140_ELEMENT_NO_STANDARD');
    hr_utility.raise_error;
--
--  **** 30.49 *****   Column removed from table.
--  elsif p_supplemental_run_flag = 'Y' then
--
--   hr_utility.set_message(801,'PAY_6141_ELEMENT_NO_SUP_RUN');
--   hr_utility.raise_error;
--
    elsif p_scndry_ent_allwd_flag = 'Y' then
--
     hr_utility.set_message(801,'PAY_6142_ELEMENT_NO_ADD_ENTRY');
     hr_utility.raise_error;
--
   end if;
--
  end if;
  -- For recurring elements the indirect results flag and the adjustment
  -- only flag must be 'N'
--
  If p_recurring_flag = 'R' and p_indirect_only_flag = 'Y' then
--
     hr_utility.set_message(801,'PAY_6707_ELEMENT_NO_REC_IND');
     hr_utility.raise_error;
--
  elsif p_recurring_flag = 'R' and p_adjustment_only_flag = 'Y' then
--
     hr_utility.set_message(801,'PAY_6712_ELEMENT_NO_REC_ADJ');
     hr_utility.raise_error;
--
  end if;
--
  -- For a personnel element the Indirect Only Flag and the Adjustment Only
  -- Flag cannot be set to 'Y'.
  if p_process_in_run_flag = 'N' then
--
   if p_indirect_only_flag = 'Y' then
--
    hr_utility.set_message(801,'PAY_6143_ELEMENT_NO_INDIRECT');
    hr_utility.raise_error;
--
    elsif p_adjustment_only_flag = 'Y' then
--
     hr_utility.set_message(801,'PAY_6144_ELEMENT_NO_ADJUST');
     hr_utility.raise_error;
--
   end if;
--
  end if;
--
  -- If the elements classification is of a payments type then the
  -- output currency of the element must match that of the business group
  -- if a payments type is specified then both currencies must be populated
  -- For non payments types both currencies can be null but not just one of
  -- them
 if (p_classification_type = 'N') then
    if (p_bus_grp_currency_code <> p_output_currency_code) then
--
        hr_utility.set_message(801,'PAY_6145_ELEMENT_OUTPUT_CURR');
        hr_utility.raise_error;
--
    elsif (p_input_currency_code is null) then
--
        hr_utility.set_message(801,'PAY_6585_ELEMENT_CURRENCY_MAN');
        hr_utility.raise_error;
--
    end if;
  else -- if the classification is a non payments type
    if (p_input_currency_code is null and p_output_currency_code is not null)
    or (p_output_currency_code is null and p_input_Currency_Code is not null)
        then
--
        hr_utility.set_message(801,'PAY_6585_ELEMENT_CURRENCY_MAN');
        hr_utility.raise_error;
--
    end if;
  end if;
--
  -- If the adjustment only flag is set to 'Y' then the multiply value flag
  -- must be 'N'.
  if p_adjustment_only_flag = 'Y' and p_multiply_value_flag = 'Y' then
--
        hr_utility.set_message(801,'PAY_6904_ELEMENT_NO_AD_AND_MUL');
        hr_utility.raise_error;
--
    end if;
--
 end chk_element_type;
--
 /*
 NAME
 chk_upd_element_type
 DESCRIPTION
   Checks that the attributes of element type are allowed to be updated.
 NOTES
   Does not test for attributes which cannot be updated.
   These are element_name and classification id.
 */
--
 PROCEDURE chk_upd_element_type(p_update_mode                 in varchar2,
                                p_val_start_date              in date,
                                p_val_end_date                in date,
                                p_element_type_id             in number,
                                p_business_group_id           in number,
                                p_old_name                    in varchar2,
                                p_name                        in varchar2,
                                p_old_process_in_run_flag     in varchar2,
                                p_process_in_run_flag         in varchar2,
                                p_old_input_currency          in varchar2,
                                p_input_currency              in varchar2,
                                p_old_output_currency         in varchar2,
                                p_output_currency             in varchar2,
                                p_old_standard_link_flag      in varchar2,
                                p_standard_link_flag          in varchar2,
                                p_old_adjustment_only_flag    in varchar2,
                                p_adjustment_only_flag        in varchar2,
                                p_old_indirect_only_flag      in varchar2,
                                p_indirect_only_flag          in varchar2,
                                p_old_scndry_ent_allwd_flag   in varchar2,
                                p_scndry_ent_allwd_flag       in varchar2,
                                p_old_post_termination_rule   in varchar2,
                                p_post_termination_rule       in varchar2,
                                p_old_processing_priority     in number,
                                p_processing_priority         in number) is
--
 v_validation_check  varchar2(1) := 'Y';
 l_no_process_update    varchar2(1) := 'N';
--
 begin
  g_debug := hr_utility.debug_enabled;
--
  -- Classification, Adjustment only flag, Indirect only flag,
  -- Secondary entries allowed flag and Post termination rule cannot
  -- be changed if there are any element links for the element.
  if (p_old_standard_link_flag <> p_standard_link_flag or
      p_old_adjustment_only_flag <> p_adjustment_only_flag or
      p_old_indirect_only_flag <> p_indirect_only_flag or
      p_old_scndry_ent_allwd_flag <> p_scndry_ent_allwd_flag or
      p_old_post_termination_rule <> p_post_termination_rule or
      p_old_process_in_run_flag <> p_process_in_run_flag) then
--
   -- Check to see if any element links exist over the validation period.
   begin
--
    select 'N'
    into v_validation_check
    from sys.dual
    where exists (select 1
                  from   pay_element_links_f el
                  where  el.element_type_id = p_element_type_id
                  and   el.effective_start_date <= p_val_end_date
                  and   el.effective_end_date >= p_val_start_date);
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_upd_element_type', 1);
        end if;
--
   exception
    when NO_DATA_FOUND then NULL;
   end;
--
   if v_validation_check = 'N' then
--
       hr_utility.set_message(801,'PAY_6147_ELEMENT_LINK_UPDATE');
       hr_utility.raise_error;
--
   end if;
--
  -- The these fields can only be corrected and only if there is
  -- only one record for the element type.
--
   if (p_update_mode <> 'CORRECTION') then
            hr_utility.set_message(801,'PAY_6460_ELEMENT_NO_PROC_CORR');
            hr_utility.raise_error;
   else
  -- We need to check to see if the correction will last for the lifetime
  -- of the element type
--
           begin
--
           select 'Y'
           into l_no_process_update
           from sys.dual
           where p_val_start_date =
                (select min(effective_start_date)
                from pay_element_types_f
                where element_type_id = p_element_type_id)
           and p_val_end_date =
                (select max(effective_end_date)
                from pay_element_types_f
                where element_type_id = p_element_type_id);
--
           exception
                when NO_DATA_FOUND then NULL;
           end;
--
            if (l_no_process_update = 'N') then
                hr_utility.set_message(801,'PAY_6460_ELEMENT_NO_PROC_CORR');
                hr_utility.raise_error;
            end if;
--
   end if;
--
  end if;
--
--
  -- The name can only be corrected and only if there is
  -- only one record for the element type.
--
    if (p_old_name <> p_name ) then
--
  -- The name can only be updated if the record is a user type record
  -- This means that the legislation code is entered and the business group
  -- id is null.
--
        if (p_business_group_id is null) then
--
            hr_utility.set_message(801,'PAY_6624_ELEMENT_NO_NAME_UPD');
            hr_utility.raise_error;
--
        end if;
--
        if (p_update_mode <> 'CORRECTION') then
            hr_utility.set_message(801,'PAY_6727_ELEMENT_NO_UPD_NAME');
            hr_utility.raise_error;
        else
  -- We need to check to see if the correction will last for the lifetime
  -- of the element type
--
           begin
--
           select 'Y'
           into l_no_process_update
           from sys.dual
           where p_val_start_date =
                (select min(effective_start_date)
                from pay_element_types_f
                where element_type_id = p_element_type_id)
           and p_val_end_date =
                (select max(effective_end_date)
                from pay_element_types_f
                where element_type_id = p_element_type_id);
--
           exception
                when NO_DATA_FOUND then NULL;
           end;
--
            if (l_no_process_update = 'N') then
                hr_utility.set_message(801,'PAY_6727_ELEMENT_NO_UPD_NAME');
                hr_utility.raise_error;
            end if;
--
        end if;
    end if;
--
  -- Checks to see if change in processing priority will result in a
  -- formula result rule with an input value that has a higher priority
  -- than the element that feeds it.                                    */
  if p_old_processing_priority <> p_processing_priority and
        hr_elements.element_priority_ok(
                p_element_type_id,
                p_processing_priority,
                 p_val_start_date,
                 p_val_end_date) = FALSE then
--
       hr_utility.set_message(801,'PAY_6149_ELEMENT_PRIORITY_UPD');
       hr_utility.raise_error;
--
  end if;
--
  -- Indirect only, process in run and termination processing rule can
  -- only be updated if there are no run results for the element and
  -- There exist no formula result rules where this element is the subject
  -- of indirect results.
--
      if (p_old_indirect_only_flag <> p_indirect_only_flag or
      p_old_post_termination_rule <> p_post_termination_rule or
      p_old_process_in_run_flag <> p_process_in_run_flag) then

        begin
--
        select 'N'
        into v_validation_check
        from sys.dual
        where exists
                (select 1
                from pay_formula_result_rules_f frr,
                     pay_input_values_f iv
                where p_element_type_id = iv.element_type_id
                and iv.input_value_id = frr.input_value_id
                and frr.effective_start_date <= p_val_end_date
                and frr.effective_end_date >= p_val_start_date);
--
        exception
                when NO_DATA_FOUND then null;
        end;
--
        if v_validation_check = 'N' then
--
            hr_utility.set_message(801,'PAY_6912_ELEMENT_NO_FRR_UPD');
            hr_utility.raise_error;
--
        end if;
--
        begin
--
        select 'N'
        into v_validation_check
        from sys.dual
        where exists
                (select 1
                from    pay_run_results rr,
                        pay_assignment_actions aa,
                        pay_payroll_actions pa
                where   p_element_type_id = rr.element_type_id
                and     aa.assignment_action_id = rr.assignment_action_id
                and     aa.payroll_action_id = pa.payroll_action_id
                and     pa.effective_date between
                        p_val_start_date and p_val_end_date);
--
        exception
                when NO_DATA_FOUND then null;
        end;
--
        if v_validation_check = 'N' then
--
            hr_utility.set_message(801,'PAY_6909_ELEMENT_NO_UPD_RR');
            hr_utility.raise_error;
--
        end if;
--
  end if;
--
 end chk_upd_element_type;
--
 /*
 NAME
 element_priority_ok
 DESCRIPTION
 should be called on any sitation where the processing priority of the element
 can change. This is on update and on next change delete.
 */
--
FUNCTION        element_priority_ok(p_element_type_id   number,
                                    p_processing_priority number,
                                             p_val_start_date   date,
                                             p_val_end_date     date)
                                             return boolean is
--
   v_validation_check   varchar2(1)  := 'Y';
--
begin
   g_debug := hr_utility.debug_enabled;
--
   -- Check from status processing rule end
   begin
--
    select 'N'
    into v_validation_check
    from sys.dual
    where exists (select 1
                  from   pay_status_processing_rules_f spr,
                         pay_formula_result_rules_f fr,
                         pay_input_values_f iv,
                         pay_element_types_f et
                  where  spr.element_type_id = p_element_type_id
                    and  fr.result_rule_type = 'I'
                    and  spr.status_processing_rule_id =
                                               fr.status_processing_rule_id
                    and  fr.input_value_id = iv.input_value_id
                    and  iv.element_type_id = et.element_type_id
                    and  et.processing_priority <= p_processing_priority
                    and  spr.effective_start_date <= p_val_end_date
                    and  spr.effective_end_date >= p_val_start_date
                    and  fr.effective_start_date <= p_val_end_date
                    and  fr.effective_end_date >= p_val_start_date);
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_upd_element_type', 3);
        end if;
--
   exception
    when NO_DATA_FOUND then NULL;
   end;
--
   -- Do not bother with second part of check if first has already failed
   if v_validation_check = 'N' then
--
    -- Checking from formula result end
    begin
--
     select 'N'
     into v_validation_check
     from sys.dual
     where exists(select 1
                  from   pay_status_processing_rules_f spr,
                         pay_formula_result_rules_f fr,
                         pay_input_values_f iv,
                         pay_element_types_f et
                  where  fr.input_value_id = iv.input_value_id
                    and  fr.result_rule_type = 'I'
                    and  iv.element_type_id = p_element_type_id
                    and  fr.status_processing_rule_id =
                                             spr.status_processing_rule_id
                    and  spr.element_type_id = et.element_type_id
                    and  et.processing_priority >= p_processing_priority
                    and  fr.effective_end_date >= p_val_start_date
                    and  fr.effective_start_date <= p_val_end_date
                    and  spr.effective_start_date <= p_val_end_date
                    and  spr.effective_end_date >= p_val_start_date);
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_upd_element_type', 4);
        end if;
--
    exception
     when OTHERS then NULL;
    end;
--
   end if;
--
        return (v_validation_check = 'Y');
--
end element_priority_ok;
--
 /*
 NAME
 chk_del_element_type
 DESCRIPTION
   Checks that the element can be deleted. This is either complete delete or
   Date effective delete.
 NOTES
  This procedure disallows delete for any element with element links.
 */
--
 PROCEDURE chk_del_element_type(p_mode             in varchar2,
                                p_element_type_id  in number,
                                p_processing_priority   in number,
                                p_session_date     in date,
                                p_val_start_date   in date,
                                p_val_end_date     in date) is
--
 l_processing_priority  number;
 v_validation_check  varchar2(1);
 v_run_results_exist varchar2(1) := 'N';
 v_next_record_found varchar2(1) := 'N';
 v_element_rules_exist varchar2(1) := 'N';
--
-- Cursor to select all input values for the element type during the validation
-- period
--
    CURSOR c_find_input_values(p_element_type_id    number,
                                p_val_start_date    date,
                                p_val_end_date      date) is
        select input_value_id
        from   pay_input_values_f
        where  p_element_type_id = element_type_id
        And  effective_end_date >= p_val_start_date
        and  effective_start_date <= p_val_end_date;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   v_validation_check := 'Y';
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_del_element_type', 1);
        end if;
--
   -- Check to see if any element links exist over the validation period
   begin
--
    select 'N'
    into v_validation_check
    from sys.dual
    where exists (select 1
                  from   pay_element_links_f el
                  where  el.element_type_id = p_element_type_id
                  and  el.effective_end_date >= p_val_start_date
                  and  el.effective_start_date <= p_val_end_date);
   exception
    when NO_DATA_FOUND then NULL;
   end;
--
   if v_validation_check = 'N' then
--
    hr_utility.set_message(801,'PAY_6155_ELEMENT_NO_DEL_LINK');
    hr_utility.raise_error;
--
   end if;
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_del_element_type', 2);
        end if;
--
-- We need to check the input values. Input values can be deleted but not
-- if any of the conditions regarding input value deletion are broached
    for iv_rec in c_find_input_values(p_element_type_id,
                                      p_val_start_date,
                                      p_val_end_date) loop
--
        if g_debug then
           hr_utility.trace(to_char(iv_rec.input_value_id));
        end if;
        hr_input_values.chk_del_input_values(p_mode,
                                             p_val_start_date,
                                             p_val_end_date,
                                             iv_rec.input_value_id);
    end loop;
--
-- We cannot delete any element types if there are run results for them.
-- The effective date of run results is found from the payroll actions table.
--
        if g_debug then
           hr_utility.set_location('hr_elements.chk_del_element_type', 3);
        end if;
--
   begin
--
    select 'Y'
    into v_run_results_exist
    from sys.dual
    where exists
        (select 1
         from pay_run_results rr,
              pay_assignment_actions aa,
              pay_payroll_actions pa
         where p_element_type_id = rr.element_type_id
         and aa.assignment_action_id = rr.assignment_action_id
         and pa.payroll_action_id = aa.payroll_action_id
         and pa.effective_date between
                p_val_start_date and p_val_end_date);
--
   exception
    when NO_DATA_FOUND then NULL;
   end;
--
   if v_run_results_exist = 'Y' then
--
    hr_utility.set_message(801,'PAY_6242_ELEMENTS_NO_DEL_RR');
    hr_utility.raise_error;
--
   end if;
--
  -- Check to see if element is being used in an element set. This only need
  -- to be done if the delete mode is Zap as element type rules are not
  -- Date effective
   if p_mode = 'ZAP' then
--
   begin
--
        select 'Y'
        into v_element_rules_exist
        from sys.dual
        where exists
                (select 1
                from pay_element_type_rules
                where element_type_id = p_element_type_id);
--
   exception
        when NO_DATA_FOUND then null;
   end;
--
   if v_element_rules_exist = 'Y' then
--
    hr_utility.set_message(801,'PAY_6713_ELEMENT_NO_DEL_RULE');
    hr_utility.raise_error;
--
   end if;
   end if;
--
  -- If the delete is a next change delete then we need to check whether any
  -- change in priority or extension of the element will result in the element
  -- becoming invalid.
--
  if p_mode = 'DELETE_NEXT_CHANGE' and
     hr_elements.element_priority_ok(p_element_type_id,
                                     p_processing_priority,
                                     p_val_start_date,
                                     p_val_end_date) = FALSE then
--
    hr_utility.set_message(801,'PAY_6914_ELEMENT_PRI_NCD');
    hr_utility.raise_error;
--
   end if;
--
 end chk_del_element_type;
--
 /*
 NAME
ins_input_value
 DESCRIPTION
  inserts a pay value for an element type and a balance feed for the pay value.
  This procedure calls balances.ins_balance_feed.
 NOTES
 */
--
 PROCEDURE ins_input_value(p_element_type_id       in number,
                           p_legislation_code      in varchar2,
                           p_business_group_id     in number,
                           p_classification_id     in number,
                           p_val_start_date        in date,
                           p_val_end_date          in date,
                           p_startup_mode          in varchar2) is

 v_input_value_id  number(15);
 l_pay_value_name  varchar2(80);
 l_business_group_id    number(9);
 c_user_id       number;
 c_login_id      number;
--
 l_check_latest_balances boolean;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.ins_input_value', 1);
        end if;
--
  -- Obtain sequence number for input value
  select pay_input_values_s.nextval
  into   v_input_value_id
  from   sys.dual;
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.ins_input_value', 2);
        end if;
--
  -- Obtain Pay value name from hr_lookups
  l_pay_value_name := hr_input_values.get_pay_value_name
                                (p_legislation_code);
--
  c_user_id := fnd_global.user_id;
  c_login_id := fnd_global.login_id;
--
        if g_debug then
           hr_utility.set_location('hr_elements.ins_input_value', 3);
        end if;
--
  -- Create PAY_VALUE for element type.
  insert into pay_input_values_f
  (input_value_id,
   effective_start_date,
   effective_end_date,
   element_type_id,
   display_sequence,
   generate_db_items_flag,
   hot_default_flag,
   mandatory_flag,
   name,
   uom,
   last_update_date,
   last_updated_by,
   last_update_login,
   created_by,
   creation_date,
   business_group_id,
   legislation_code,
   legislation_subgroup)
  select
   v_input_value_id,
   p_val_start_date,
   p_val_end_date,
   et.element_type_id,
   1,
   'Y',
   'N',
   'N',
   'Pay Value',
   'M',
   et.last_update_date,
   et.last_updated_by,
   et.last_update_login,
   et.created_by,
   et.creation_date,
   et.business_group_id,
   et.legislation_code,
   et.legislation_subgroup
  from  pay_element_types_f et
  where et.element_type_id = p_element_type_id
    and et.effective_start_date = p_val_start_date;
--
    if SQL%NOTFOUND then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','ins_input_value');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    end if;
--
insert into PAY_INPUT_VALUES_F_TL (
    INPUT_VALUE_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    v_input_value_id,
    l_pay_value_name,
    sysdate,
    c_user_id,
    c_user_id,
    c_login_id,
    sysdate,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PAY_INPUT_VALUES_F_TL T
    where T.INPUT_VALUE_ID = v_input_value_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
        if g_debug then
           hr_utility.set_location('hr_elements.ins_input_value', 4);
        end if;
--
-- if this record is in startup or generic mode then insert some ownerships
-- for it
    if p_startup_mode <> 'USER' then
--
        hr_elements.ins_ownerships
                        ('INPUT_VALUE_ID',
                         v_input_value_id,
                         p_element_type_id);
--
    end if;
--
  --
  -- Set global to avoid looking for invalidated latest balances
  -- ie can't be any as no run result values for this new input value
  --
  l_check_latest_balances := HRASSACT.CHECK_LATEST_BALANCES;
  HRASSACT.CHECK_LATEST_BALANCES := FALSE;
  --
  -- Create any balance feeds that may be required ie. for any balances which
  -- are fed by the same classification as the element.
  hr_balances.ins_balance_feed('INS_PAY_PAY_VALUE',
                                v_input_value_id,
                                NULL,
                                p_classification_id,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                p_val_start_date,
                                p_business_group_id,
                                p_legislation_code,
                                p_startup_mode);
  --
  -- Reset global
  --
  HRASSACT.CHECK_LATEST_BALANCES := l_check_latest_balances;
  --
  -- Create any balance feeds that may be required ie. for any balances which
--
  -- The insertion of rows into application ownerships for startup data
  --  is handled by an insert trigger on pay_input_values_f
--
  -- Create database items
--
  hrdyndbi.create_input_value_dict(v_input_value_id,
                                   p_val_start_date);
--
 end ins_input_value;
--
--
 /*
 NAME
  ins_sub_classification_rules
 DESCRIPTION
  This procedure will create a sub_classification_rule for each
  sub_classification that has the create_by_default_flag set to 'Y',,
  It will then call hr_balances.ins_balance_feed to create the balance feeds.
 */
--
 PROCEDURE ins_sub_classification_rules(
                               p_element_type_id       in number,
                               p_legislation_code      in varchar2,
                               p_business_group_id     in number,
                               p_classification_id     in number,
                               p_val_start_date        in date,
                               p_val_end_date          in date,
                               p_startup_mode           in varchar2) is
--
 -- Cursor to get classifications by business_group
--
CURSOR get_sub_classifications(p_classification_id number) IS
  select classification_id
  from   pay_element_classifications
  where  parent_classification_id = p_classification_id
  and    nvl(business_group_id, nvl(p_business_group_id, 0)) = nvl(p_business_group_id, 0)
  and    nvl(legislation_code, nvl(p_legislation_code, ' ')) = nvl(p_legislation_code, ' ')
  and    create_by_default_flag = 'Y'
  for update;
--
 -- Cursor to ensure identical sub classification rule does not already exist
--
CURSOR csr_chk_scr_exists(p_start_date        date,
                          p_end_date          date,
                          p_element_type_id   number,
                          p_classification    number,
                          p_business_group_id number,
                          p_legislation_code  varchar2) IS
  select 'X'
  from   pay_sub_classification_rules_f
  where  effective_start_date = p_start_date
  and    effective_end_date = p_end_date
  and    element_type_id = p_element_type_id
  and    classification_id = p_classification
  and    nvl(business_group_id, nvl(p_business_group_id, 0)) = nvl(p_business_group_id, 0)
  and    nvl(legislation_code, nvl(p_legislation_code, ' ')) = nvl(p_legislation_code, ' ');
--
l_sub_classification_rule_id            number;
l_dummy                                 varchar2(1);
l_legislation_code                      varchar2(30)  := null;
--
begin
   g_debug := hr_utility.debug_enabled;
--
  if g_debug then
     hr_utility.set_location('hr_elements.ins_sub_class_rule', 1);
  end if;
--
  for subcr_rec in get_sub_classifications(p_classification_id) loop
--
  open csr_chk_scr_exists(p_val_start_date
                         ,p_val_end_date
                         ,p_element_type_id
                         ,subcr_rec.classification_id
                         ,p_business_group_id
                         ,p_legislation_code);
  fetch csr_chk_scr_exists into l_dummy;
  if csr_chk_scr_exists%notfound then
    --
    -- Close cursor and continue with insert as no duplicate row exists
    --
    close csr_chk_scr_exists;
    --
    -- Do not insert legislation code for user rows.
    --
    if p_business_group_id is null then
      l_legislation_code := p_legislation_code;
    end if;
    --
    select pay_sub_classification_rules_s.nextval
    into l_sub_classification_rule_id
    from dual;
    --
    -- Insert sub_classification rule.
    --
    insert into pay_sub_classification_rules_f
      (SUB_CLASSIFICATION_RULE_ID
      ,EFFECTIVE_START_DATE
      ,EFFECTIVE_END_DATE
      ,ELEMENT_TYPE_ID
      ,CLASSIFICATION_ID
      ,BUSINESS_GROUP_ID
      ,LEGISLATION_CODE)
    values
      (l_sub_classification_rule_id
      ,p_val_start_date
      ,p_val_end_date
      ,p_element_type_id
      ,subcr_rec.classification_id
      ,p_business_group_id
      ,l_legislation_code);
    --
    if SQL%NOTFOUND then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','ins_sub_classification_rule');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    end if;
    --
    -- if this record is in startup or generic mode then insert some ownerships
    -- for it
    if p_startup_mode <> 'USER' then
    --
      hr_elements.ins_ownerships
        ('SUB_CLASSIFICATION_RULE_ID'
        ,l_sub_classification_rule_id
        ,p_element_type_id);
    --
    end if;
    --
    -- Create balance feeds for this rule
    --
    hr_balances.ins_balance_feed
      ('INS_SUB_CLASS_RULE'
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,l_sub_classification_rule_id
      ,NULL
      ,NULL
      ,p_val_start_date
      ,p_business_group_id
      ,p_legislation_code
      ,p_startup_mode);
--
  else
    close csr_chk_scr_exists;
  end if;
--
  end loop;
--
end ins_sub_classification_rules;
--
--
 /*
 NAME
  ins_3p_element_type
 DESCRIPTION
  Based on the process in run flag this will call the insert input value
  and the insert status processing rules procedures.
 */
--
 PROCEDURE ins_3p_element_type(p_element_type_id       in number,
                               p_process_in_run_flag   in varchar2,
                               p_legislation_code      in varchar2,
                               p_business_group_id     in number,
                               p_classification_id     in number,
                               p_non_payments_flag     in varchar,
                               p_val_start_date        in date,
                               p_val_end_date          in date,
                               p_startup_mode          in varchar2) is
--
 begin
   g_debug := hr_utility.debug_enabled;
--
  -- Only create the default status processing rule and PAY_VALUE if the
  -- element is to be used by the payroll run.
  if p_process_in_run_flag = 'Y' and p_non_payments_flag = 'N' then
--
   -- Create PAY_VALUE
   hr_elements.ins_input_value(p_element_type_id,
                               p_legislation_code,
                               p_business_group_id,
                               p_classification_id,
                               p_val_start_date,
                               p_val_end_date,
                               p_startup_mode);
--
  end if;
   -- Create sub_classification_rules
   hr_elements.ins_sub_classification_rules(
                               p_element_type_id,
                               p_legislation_code,
                               p_business_group_id,
                               p_classification_id,
                               p_val_start_date,
                               p_val_end_date,
                               p_startup_mode);
--
  -- Insert database item
  hrdyndbi.create_element_type_dict(
                                p_element_type_id,
                                p_val_start_date);
--
 end ins_3p_element_type;
--
--
 /*
 NAME
  del_formula_result_rules
 DESCRIPTION
  This procedure deletes any formula result rules in existence for the element.
  It is only called from del_status_processing_rules.
*/
--
PROCEDURE       del_formula_result_rules(
                               p_status_processing_rule_id in number,
                               p_delete_mode            in varchar2,
                               p_val_session_date       in date,
                               p_val_start_date         in date,
                               p_val_end_date           in date,
                               p_startup_mode           in varchar2) is
--
begin
   g_debug := hr_utility.debug_enabled;
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_formula_result_rules', 1);
        end if;
--
 if p_delete_mode = 'ZAP' then
--
        if p_startup_mode <> 'USER' then
--
                delete from hr_application_ownerships ao
                where key_name = 'FORMULA_RESULT_RULE_ID'
                and exists
                        (select 1
                        from pay_formula_result_rules_f frr
                        where frr.status_processing_rule_id =
                                p_status_processing_rule_id
                        and ao.key_value = to_char(frr.formula_result_rule_id));
--
        end if;
--
        delete from pay_formula_result_rules_f
        where status_processing_rule_id = p_status_processing_rule_id;
--
 elsif p_delete_mode = 'DELETE' then
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_formula_result_rules', 2);
        end if;
--
        -- delete all future records
        delete from pay_formula_result_rules_f
        where status_processing_rule_id = p_status_processing_rule_id
        and effective_start_date > p_val_session_date;
--
        -- update current records so that the end date is the session date
        update pay_formula_result_rules_f
        set effective_end_date = p_val_session_date
        where status_processing_rule_id = p_status_processing_rule_id
        and p_val_session_date between
        effective_start_date and effective_end_date;
--
  end if;
  -- DELETE NEXT CHANGE has no effect
  -- FUTURE CHANGE DELETE is not allowed
--
end del_formula_result_rules;
--
 /*
 NAME
  del_status_processing_ruleS
 DESCRIPTION
  This procedure deletes any status processing rules for this element and
  calls a function to delete any formula result rules.
 NOTES
  Element types cannot be subject to a future change delete. They can be subject
  to a next change delete but, in the case of status processing rules, this
  does not cause the records to 'open up' if we are on the final record. A
  warning will appear in the form telling the users that this is the case.
*/
PROCEDURE       del_status_processing_rules(
                               p_element_type_id        in number,
                               p_delete_mode            in varchar2,
                               p_val_session_date       in date,
                               p_val_start_date         in date,
                               p_val_end_date           in date,
                               p_startup_mode           in varchar2) is
--
  -- Cursor select all valid sprs for the element and locks these rows
--
CURSOR get_sprs (p_element_type_id      number,
                 p_val_start_date       date,
                 p_val_end_date         date) is
        select status_processing_rule_id,
                effective_start_date,
                effective_end_date
        from    pay_status_processing_rules_f
        where   p_element_type_id = element_type_id
        and     effective_start_date <= p_val_end_date
        and     effective_end_date >= p_val_start_date
        for update;
--
begin
   g_debug := hr_utility.debug_enabled;
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_status_processing_rules', 1);
        end if;
--
 for spr_rec in get_sprs(p_element_type_id,
                         p_val_start_date,
                         p_val_end_date) loop
--
        del_formula_result_rules(
                        spr_rec.status_processing_rule_id,
                        p_delete_mode,
                        p_val_session_date,
                        spr_rec.effective_start_date,
                        spr_rec.effective_end_date,
                        p_startup_mode);
 end loop;
--
 if p_delete_mode = 'ZAP' then
--
        if p_startup_mode <> 'USER' then
--
                delete from hr_application_ownerships ao
                where ao.key_name = 'STATUS_PROCESSING_RULE_ID'
                and exists
                        (select 1
                        from pay_status_processing_rules_f spr
                        where spr.element_type_id = p_element_type_id
                        and ao.key_value =
                                to_char(spr.status_processing_rule_id));
        end if;
--
        delete from pay_status_processing_rules_f
        where element_type_id = p_element_type_id;
--
 elsif p_delete_mode = 'DELETE' then
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_status_processing_rules', 2);
        end if;
--
        -- delete all future records
        delete from pay_status_processing_rules_f
        where element_type_id = p_element_type_id
        and effective_start_date > p_val_session_date;
--
        -- update current records so that the end date is the session date
        update pay_status_processing_rules_f
        set effective_end_date = p_val_session_date
        where element_type_id = p_element_type_id
        and p_val_session_date between
        effective_start_date and effective_end_date;
--
  end if;
  -- DELETE NEXT CHANGE has no effect
  -- FUTURE CHANGE DELETE is not allowed
--
end del_status_processing_rules;
 /*
 NAME
  del_sub_classification_rules
 DESCRIPTION
  This procedure deletes any existing sub_classification_rules and any
  related balance feeds.
 NOTES
  Element types cannot be subject to a future change delete. They can, however,
  be subject to a next change delete and this is handled in the code. This
  procedure relies on the hr_input_values.del_3p_input_values being called
  in the same commit unit as this will tidy up the balance feeds that may have
  been created by the sub_classification rules.
*/
--
PROCEDURE       del_sub_classification_rules(
                               p_element_type_id        in number,
                               p_delete_mode            in varchar2,
                               p_val_session_date       in date,
                               p_val_start_date         in date,
                               p_val_end_date           in date,
                               p_startup_mode           in varchar2) is
--
        v_end_of_time   date;
begin
   g_debug := hr_utility.debug_enabled;
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_sub_classification_rules', 1);
        end if;
--
  -- Delete the sub_classification_rules. The balance_feeds will have already
  -- been deleted as part of the delete input values procedure
--
 if p_delete_mode = 'ZAP' then
--
        if p_startup_mode <> 'USER' then
--
                delete from hr_application_ownerships ao
                where ao.key_name = 'SUB_CLASSIFICATION_RULE_ID'
                and exists
                        (select 1
                        from pay_sub_classification_rules_f scr
                        where scr.element_type_id = p_element_type_id
                        and ao.key_value =
                        to_char(scr.sub_classification_rule_id));
--
        end if;
--
        delete from pay_sub_classification_rules_f
        where element_type_id = p_element_type_id;
--
 elsif p_delete_mode = 'DELETE' then
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_sub_classification_rules', 2);
        end if;
--
        -- delete all future records
        delete from pay_sub_classification_rules_f
        where element_type_id = p_element_type_id
        and effective_start_date > p_val_session_date;
--
        -- update current records so that the end date is the session date
        update pay_sub_classification_rules_f
        set effective_end_date = p_val_session_date
        where element_type_id = p_element_type_id
        and p_val_session_date between
        effective_start_date and effective_end_date;
--
 -- DELETE_NEXT_CHANGE will not cause the sub_classification rules to extend.
--
  end if;
end del_sub_classification_rules;
--
 /*
 NAME
  upd_3p_element_type
 DESCRIPTION
  This procedure does third party processing necessary on update. Currenctly
  this only consists of deleting and recreating the database items
*/
PROCEDURE       upd_3p_element_type(p_element_type_id in number,
                                    p_val_start_date in date,
                                    p_old_name in varchar2,
                                    p_name in varchar2) is
--
begin
--
   if p_old_name <> p_name then
--
        hrdyndbi.delete_element_type_dict(p_element_type_id);
--
        hrdyndbi.create_element_type_dict(p_element_type_id,
                                          p_val_start_date);
--
   end if;
end upd_3p_element_type;
--
 /*
 NAME
  del_3p_element_type
 DESCRIPTION
  This procedure does the necessary cascade deletes when an element type is
  deleted. This affects the following tables: Input values, status processing
  rules and formula result rules.
 NOTES
  Element types cannot be subject to a future change delete. They can, however,
  be subject to a next change delete and this is handled in the code.
 */
 PROCEDURE del_3p_element_type(p_element_type_id       in number,
                               p_delete_mode           in varchar2,
                               p_val_session_date      in date,
                               p_val_start_date        in date,
                               p_val_end_date          in date,
                                p_startup_mode          in varchar2) is
--
 v_end_of_time          date;
 l_on_final_record      varchar2(1) := 'N';
 l_input_value_id       number;
--
-- Cursor to determine which input value records need to be included for
-- cascade delete.
 cursor c_input_value(p_element_type_id number,
                      p_val_start_date  date,
                      p_val_end_date    date) is
        select iv.input_value_id input_value_id,
                iv.generate_db_items_flag db_items_flag
        from    pay_input_values_f iv
        where   p_element_type_id = iv.element_type_id
        and     iv.effective_start_date <= p_val_end_date
        and     iv.effective_end_date >= p_val_start_date
        for update;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_3p_element_type', 1);
        end if;
--
  -- Select all input values.
  -- Perform all 3p deletes for these input values then delete the input values
        for iv_rec in c_input_value(p_element_type_id,
                                p_val_start_date,
                                p_val_end_date) loop
--
        hr_input_values.del_3p_input_values(p_delete_mode,
                                            iv_rec.input_value_id,
                                            iv_rec.db_items_flag,
                                            p_val_end_date,
                                            p_val_session_date,
                                            p_startup_mode);
--
  end loop;
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_3p_element_type', 2);
        end if;
--
--
 if p_delete_mode = 'ZAP' then
--
        if p_startup_mode <> 'USER' then
--
                delete from hr_application_ownerships ao
                where ao.key_name = 'INPUT_VALUE_ID'
                and exists
                        (select 1
                        from pay_input_values_f iv
                        where iv.element_type_id = p_element_type_id
                        and ao.key_value = to_char(iv.input_value_id));
--
        end if;
--
        delete from pay_input_values_f
        where element_type_id = p_element_type_id;
--
 elsif p_delete_mode = 'DELETE' then
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_3p_element_type', 3);
        end if;
--
        -- delete all future records
        delete from pay_input_values_f
        where element_type_id = p_element_type_id
        and effective_start_date > p_val_session_date;
--
        -- update current records so that the end date is the session date
        update pay_input_values_f
        set effective_end_date = p_val_session_date
        where element_type_id = p_element_type_id
        and p_val_session_date between
        effective_start_date and effective_end_date;
--
 -- DELETE_NEXT_CHANGE will only affect the input value records if we are on
 -- The final record of the element type. In this case the final input value
 -- records will need to be extended to the end of time.
 elsif p_delete_mode = 'DELETE_NEXT_CHANGE' then
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_3p_element_type', 4);
        end if;
--
 begin
--
   select 'Y'
   into l_on_final_record
   from pay_element_types_f et1
   where p_element_type_id = et1.element_type_id
   and p_val_session_date between
        et1.effective_start_date and et1.effective_end_date
   and et1.effective_end_date =
        (select max(et2.effective_end_date)
        from pay_element_types_f et2
        where p_element_type_id = et2.element_type_id);
--
 exception
    when NO_DATA_FOUND then NULL;
 end;
--
    if l_on_final_record = 'Y' then
--
--
        if g_debug then
           hr_utility.set_location('hr_elements.del_3p_element_type', 5);
        end if;
--
        v_end_of_time := to_date('31/12/4712', 'DD/MM/YYYY');
--
        update pay_input_values_f iv1
        set iv1.effective_end_date = v_end_of_time
        where (iv1.input_value_id, iv1.effective_end_date) =
                (select iv2.input_value_id, max(iv2.effective_end_date)
                from pay_input_values_f iv2
                where iv2.element_type_id = p_element_type_id
                group by iv2.input_value_id);
--
   end if;
--
-- No 'FUTURE_CHANGE_DELETE' allowed.
--
 end if;
--
        hr_elements.del_sub_classification_rules(
                               p_element_type_id,
                               p_delete_mode,
                               p_val_session_date,
                               p_val_start_date,
                               p_val_end_date,
                               p_startup_mode);
--
        hr_elements.del_status_processing_rules(
                               p_element_type_id,
                               p_delete_mode,
                               p_val_session_date,
                               p_val_start_date,
                               p_val_end_date,
                               p_startup_mode);
--
        if p_delete_mode = 'ZAP' then
--
        -- We need to clear down the database items
--
        hrdyndbi.delete_element_type_dict(p_element_type_id);
--
        end if;
 end del_3p_element_type;
--
 /*
 NAME
 ins_ownerships
 DESCRIPTION
 This procedure will insert product ownerships for any startup or generic
 record
 */
PROCEDURE       ins_ownerships(p_key_name       varchar2,
                               p_key_value      number,
                               p_element_type_id number) is
--
        l_session_id    number;
--
begin
   g_debug := hr_utility.debug_enabled;
--
        if g_debug then
           hr_utility.set_location('ins_ownerships', 1);
        end if;
--
        insert into hr_application_ownerships
        (key_name,
         key_value,
         product_name)
        select  p_key_name,
                p_key_value,
                ao.product_name
        from    hr_application_ownerships ao
        where   ao.key_name = 'ELEMENT_TYPE_ID'
        and     ao.key_value = p_element_type_id;
--
        if SQL%NOTFOUND then
           hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE', 'ins_ownerships');
           hr_utility.set_message_token('STEP', '1');
           hr_utility.raise_error;
        end if;
--

end ins_ownerships;

PROCEDURE check_element_freq (  p_payroll_id    IN NUMBER,
                                p_bg_id         IN NUMBER,
                                p_pay_action_id IN NUMBER,
                                p_passed_date   IN DATE,
                                p_ele_type_id   IN NUMBER,
                                p_whole_period_only IN VARCHAR2,
                                p_skip_element  OUT NOCOPY VARCHAR2) IS

v_number_per_fy         NUMBER(3);
v_run_number            NUMBER(3);
v_freq_rule_exists      NUMBER(3);
v_period_end_date       DATE;
v_period_start_date     DATE;
v_rule_mode             pay_legislation_rules.rule_mode%type;
v_rule_date_code	VARCHAR2(30);
--
BEGIN
   --
   -- The default value for p_whole_period_only should be 'D'. However if the some
   -- customers wants to use the fixed version then they
   -- can use the whole period by setting the
   -- "FREQ_RULE_WHOLE_PERIOD".
   --
   --
   g_debug := hr_utility.debug_enabled;
   p_skip_element := 'N';
   --
   -- See if freq rule even comes into play here:
   --
   if g_debug then
      hr_utility.set_location('check_element_freq', 45);
   end if;
   SELECT  COUNT(0)
     INTO  v_freq_rule_exists
     FROM  pay_ele_payroll_freq_rules      EPF
    WHERE  element_type_id                 = p_ele_type_id
      AND  payroll_id                      = p_payroll_id
      AND  business_group_id + 0           = p_bg_id;

   IF v_freq_rule_exists = 0 THEN
     p_skip_element:='N';
     RETURN;
   END IF;

   SELECT NVL(rule_date_code,'E')
   INTO   v_rule_date_code
   FROM   pay_ele_payroll_freq_rules
   WHERE  element_type_id    = p_ele_type_id
   AND    payroll_id         = p_payroll_id;

   --
   -- If we're here, then maybe freq rule will affect processing...
   -- Get payroll period type.number per fiscal year.
   --
   SELECT  end_date, start_date
   INTO    v_period_end_date,
           v_period_start_date
   FROM    per_time_periods
   WHERE   p_passed_date BETWEEN start_date AND end_date
   AND     payroll_id      = p_payroll_id;

   SELECT  TPT.number_per_fiscal_year
   INTO    v_number_per_fy
   FROM    per_time_period_types   TPT,
           pay_payrolls_f          PRL
   WHERE   TPT.period_type         = PRL.period_type
   AND     PRL.business_group_id + 0       = p_bg_id
   AND     p_passed_date BETWEEN prl.effective_start_date and prl.effective_end_date
   AND     PRL.payroll_id          = p_payroll_id;
   --
   -- Get period number in Month or Year according to number per fiscal year.
   -- ...into v_run_number...
   -- What we NEED is the actual PERIOD # w/in Month or Year.
      if g_debug then
         hr_utility.trace('v_number_per_fy='||to_char(v_number_per_fy));
      end if;

   IF v_number_per_fy < 12 THEN
      if g_debug then
         hr_utility.set_location('check_element_freq', 20);
         hr_utility.trace('v_period_end_date='||to_char(v_period_end_date,'YYYY/MM/DD'));
         hr_utility.trace('v_period_start_date='||to_char(v_period_start_date,'YYYY/MM/DD'));
         hr_utility.trace('p_passed_date='||to_char(p_passed_date,'YYYY/MM/DD'));
      end if;
--
 --Added for fix 9183831
    IF v_rule_date_code = 'F' THEN
    /*The pay_action_parameter value is mainly used for controlling the effective_date period number calc*/
       if p_whole_period_only in ('D','N','R') then
          SELECT COUNT(0)
          INTO   v_run_number
          FROM   per_time_periods        PTP
          WHERE  to_date(to_char(PTP.end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(v_period_end_date,'YEAR')
                       AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
          AND    PTP.payroll_id                  = p_payroll_id;
       ELSE
        /*If the parameter is set we use the period start date of the passed date_paid date*/
          SELECT COUNT(0)
          INTO   v_run_number
          FROM   per_time_periods        PTP
          WHERE  to_date(to_char(PTP.start_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(v_period_start_date,'YEAR')
                       AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
       end if;
     ELSIF v_rule_date_code = 'E' THEN
     /*The period number will be calculated by taking of the last date of the passed date_earned date*/
      SELECT COUNT(0)
          INTO   v_run_number
          FROM   per_time_periods        PTP
          WHERE  to_date(to_char(PTP.end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(v_period_end_date,'YEAR')
                       AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
          AND    PTP.payroll_id                  = p_payroll_id;
     ELSE
     /*If the rule_date_code is set as date_paid we use payment Date, this is done by adding the look_value to
      PAY_FRULE_DATES orPAY_US_FRULE_DATES, mostly the value will be 'R' */
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.regular_payment_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(p_passed_date,'YEAR')
                       AND     to_date(to_char(p_passed_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
     END IF;
    /* if v_rule_date_code in ('E','F') then
       if p_whole_period_only in ('D','N','R') then
          SELECT COUNT(0)
          INTO   v_run_number
          FROM   per_time_periods        PTP
          WHERE  to_date(to_char(PTP.end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(v_period_end_date,'YEAR')
                       AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
          AND    PTP.payroll_id                  = p_payroll_id;
       else
          SELECT COUNT(0)
          INTO   v_run_number
          FROM   per_time_periods        PTP
          WHERE  to_date(to_char(PTP.start_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(v_period_start_date,'YEAR')
                       AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
       end if;
     else
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.regular_payment_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                       BETWEEN TRUNC(p_passed_date,'YEAR')
                       AND     to_date(to_char(p_passed_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
     end if;*/
--
   ELSIF v_number_per_fy > 13 THEN
      if g_debug then
         hr_utility.set_location('check_element_freq', 30);
         hr_utility.trace('v_period_end_date='||to_char(v_period_end_date,'YYYY/MM/DD'));
         hr_utility.trace('v_period_start_date='||to_char(v_period_start_date,'YYYY/MM/DD'));
         hr_utility.trace('p_passed_date='||to_char(p_passed_date,'YYYY/MM/DD'));
      end if;

     --Added for fix 9183831
     IF v_rule_date_code = 'F' THEN
       IF p_whole_period_only IN ('D','N','R') THEN
          /*The pay_action_parameter value is mainly used for controlling the effective_date period number calc*/
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(v_period_end_date, 'MONTH')
                          AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
       ELSE
        /*If the parameter is set we use the period start date of the passed date_paid date*/
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.start_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(v_period_start_date, 'MONTH')
                          AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
       END IF;
      ELSIF v_rule_date_code = 'E' THEN
          /*The period number will be calculated by taking of the last date of the passed date_earned date*/
       SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(v_period_end_date, 'MONTH')
                          AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
      ELSE

     /*If the rule_date_code is set as date_paid we use payment Date, this is done by adding the look_value to
      PAY_FRULE_DATES orPAY_US_FRULE_DATES, mostly the value will be 'R' */
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.regular_payment_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(p_passed_date, 'MONTH')
                          AND     to_date(to_char(p_passed_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
      END IF;

--
      /*if v_rule_date_code in ('E','F') then
       if p_whole_period_only in ('D','N','R') then
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(v_period_end_date, 'MONTH')
                          AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
       else
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.start_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(v_period_start_date, 'MONTH')
                          AND     to_date(to_char(v_period_end_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
       end if;
      else
         SELECT COUNT(0)
         INTO   v_run_number
         FROM   per_time_periods        PTP
         WHERE  to_date(to_char(PTP.regular_payment_date,'YYYY/MM/DD'),'YYYY/MM/DD')
                          BETWEEN TRUNC(p_passed_date, 'MONTH')
                          AND     to_date(to_char(p_passed_date,'YYYY/MM/DD'),'YYYY/MM/DD')
         AND    PTP.payroll_id                  = p_payroll_id;
      end if;*/
--
ELSIF v_number_per_fy = 12 or v_number_per_fy = 13 THEN
  if g_debug then
     hr_utility.set_location('check_element_freq', 40);
  end if;
  p_skip_element := 'N';
  RETURN ;
END IF;

--
-- Check frequency rule:
-- If none exists, then process!
--
if g_debug then
   hr_utility.trace('v_run_number='||to_char(v_run_number));
   hr_utility.set_location('check_element_freq', 50);
end if;
SELECT  'N'
INTO            p_skip_element
FROM            pay_ele_payroll_freq_rules      EPF,
                pay_freq_rule_periods           FRP
WHERE           FRP.period_no_in_reset_period   = v_run_number
AND             FRP.ele_payroll_freq_rule_id    = EPF.ele_payroll_freq_rule_id
AND             EPF.business_group_id + 0       = p_bg_id
AND             EPF.payroll_id                  = p_payroll_id
AND             EPF.element_type_id             = p_ele_type_id;

RETURN;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    if g_debug then
       hr_utility.set_location('check_element_freq', 60);
    end if;
    p_skip_element      := 'Y';
    RETURN;

END check_element_freq;

PROCEDURE check_element_freq (  p_payroll_id    IN NUMBER,
                                p_bg_id         IN NUMBER,
                                p_pay_action_id IN NUMBER,
                                p_date_earned   IN DATE,
                                p_ele_type_id   IN NUMBER,
                                p_skip_element  OUT NOCOPY VARCHAR2) IS
--
cursor csr_action_parameter is
  select pap.parameter_value
    from pay_action_parameters pap
   where pap.parameter_name = 'FREQ_RULE_WHOLE_PERIOD';
--
  l_whole_period varchar2(1);
--
cursor csr_regular_payment_date is
         select pte.regular_payment_date
             from per_time_periods pte
            where pte.payroll_id = p_payroll_id
              and p_date_earned between
                    pte.start_date and pte.end_date;
--
l_date_earned date;
--
BEGIN
  --
  open csr_action_parameter;
  fetch csr_action_parameter into l_whole_period;
  if (csr_action_parameter%notfound
      or (l_whole_period <> 'Y' and
          l_whole_period <> 'N' and
          l_whole_period <> 'R'))then
     --
     l_whole_period := 'D';
     --
  end if;
  close csr_action_parameter;
  --
  open csr_regular_payment_date;
  fetch csr_regular_payment_date into l_date_earned;
  if csr_regular_payment_date%notfound then
     l_date_earned := p_date_earned;
  end if;
  close csr_regular_payment_date;
  if g_debug then
   hr_utility.trace('l_whole_period='||l_whole_period);
    hr_utility.trace('p_ele_type_id='||p_ele_type_id);
   hr_utility.set_location('check_element_freq', 10);
end if;
  --
  check_element_freq (  p_payroll_id    => p_payroll_id,
                        p_bg_id         => p_bg_id,
                        p_pay_action_id => p_pay_action_id,
                        p_passed_date   => l_date_earned,
                        p_ele_type_id   => p_ele_type_id,
                        p_whole_period_only => l_whole_period,
                        p_skip_element  => p_skip_element);
  --
END check_element_freq;

end hr_elements;

/
