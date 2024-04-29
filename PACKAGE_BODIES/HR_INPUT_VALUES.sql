--------------------------------------------------------
--  DDL for Package Body HR_INPUT_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INPUT_VALUES" as
/* $Header: pyinpval.pkb 115.7 2003/03/04 11:56:32 alogue ship $ */
--

 /*
 NAME
 chk_input_value
 DESCRIPTION
  Checks attributes of inserted and update input values for concurrence
  with business rules.
 */
--
 PROCEDURE chk_input_value(p_element_type_id         in number,
                           p_legislation_code        in varchar2,
                           p_val_start_date     in date,
                           p_val_end_date       in date,
                           p_insert_update_flag      in varchar2,
                           p_input_value_id          in number,
                           p_rowid                   in varchar2,
                           p_recurring_flag          in varchar2,
                           p_mandatory_flag          in varchar2,
                           p_hot_default_flag        in varchar2,
                           p_standard_link_flag      in varchar2,
                           p_classification_type     in varchar2,
                           p_name                    in varchar2,
                           p_uom                     in varchar2,
                           p_min_value               in varchar2,
                           p_max_value               in varchar2,
                           p_default_value           in varchar2,
                           p_lookup_type             in varchar2,
                           p_formula_id              in number,
                           p_generate_db_items_flag  in varchar2,
                           p_warning_or_error        in varchar2) is
--
 v_validation_check  varchar2(1);
v_num_input_values  number;
l_pay_value_name        varchar2(80);
--
 begin
        -- get pay value name
        l_pay_value_name := hr_input_values.get_pay_value_name
                                (p_legislation_code);
--
  -- payments type 'Pay Values' must have uom of money
--
  if p_name = l_pay_value_name and
     p_classification_type = 'N' and
     p_uom <> 'M' then
--
        hr_utility.set_message(801,'');
        hr_utility.raise_error;
--
  end if;

  if p_insert_update_flag = 'INSERT' then
  -- Make sure that a maximum of 6 input values can be created
  begin
--
   select count(distinct iv.input_value_id)
   into   v_num_input_values
   from   pay_input_values_f iv
   where  iv.element_type_id = p_element_type_id
   and    p_val_start_date between
        iv.effective_start_date and iv.effective_end_date;
--
  exception
   when NO_DATA_FOUND then NULL;
  end;
  if v_num_input_values >= 6 then
--
   hr_utility.set_message(801,'PAY_6167_INPVAL_ONLY_6');
   hr_utility.raise_error;
--
  end if;
--
  v_validation_check := 'Y';
--
  -- no entries can be in existence
  -- during the validation period
  -- for the other input values.
  -- This check only needs to be done on insert not on updatE
--
        begin
--
        select 'N'
        into v_validation_check
        from sys.dual
        where exists
                (select 1
                from    pay_element_links_f el,
                        pay_element_entries_f ee
                where   p_element_type_id = el.element_type_id
                and     el.element_link_id = ee.element_link_id
                and     ee.effective_end_date >= p_val_start_date
                and     ee.effective_start_date <= p_val_end_date);
--
        exception
         when NO_DATA_FOUND then NULL;
        end;
--
        if v_validation_check = 'N' then
--
         hr_utility.set_message(801,'PAY_6197_INPVAL_NO_ENTRY');
         hr_utility.raise_error;
--
        end if;
--
    end if;-- In INSERT mode
--
  -- Make sure that the input value name is unique within the element
  -- This will ensure also that only one PAY_VALUE can be used.
  begin
        select 'N'
        into v_validation_check
        from sys.dual
        where exists
        (select 1
        from pay_input_values_f_tl ipv_tl,
             pay_input_values_f ipv
        where ipv_tl.input_value_id = ipv.input_value_id
        and userenv('LANG') = ipv_tl.language
        and ipv.element_type_id = p_element_type_id
        and ipv.input_value_id <> p_input_value_id
        and upper(p_name) = upper(ipv_tl.name));
--
  exception
        when NO_DATA_FOUND then NULL;
  end;

  if v_validation_check = 'N' then
--
   hr_utility.set_message(801,'PAY_6168_INPVAL_DUP_NAME');
   hr_utility.raise_error;
--
  end if;
--
  -- Hot defaulted values must be mandatory.
--
  if (p_hot_default_flag = 'Y' and p_mandatory_flag = 'N') then
--
     hr_utility.set_message(801,'PAY_6609_ELEMENT_HOT_DEF_MAN');
     hr_utility.raise_error;
--
  end if;
--
  -- Hot defaulted values must have default, max and min less than 59
  -- characters. This is to allow for the inclusion of quotes around the
  -- values when they are displayed at the lower level
  if (p_hot_default_flag = 'Y') and
     ((length(p_default_value) > 58) or
      (length(p_min_value) > 58) or
      (length(p_max_value) > 58)) then
--
     hr_utility.set_message(801,'PAY_6616_INPVAL_HOT_LESS_58');
     hr_utility.raise_error;
--
  end if;
--
  -- If the element is nonrecurring then do not allow any non-numeric input
  -- values to have create db items set to 'Y' ie. cannot specify Date or
  -- Character. This is so that they can be summed on the entity horizon
  if ((p_recurring_flag = 'N' and
       p_generate_db_items_flag = 'Y') and
       ((p_uom = 'C') or
        (p_uom like 'D%'))) then
--
   hr_utility.set_message(801,'PAY_6169_INPVAL_ONLY_NUM');
   hr_utility.raise_error;
--
  end if;
--
  -- Makes sure that the validation specified for the input value is correct
  -- ie. it can either be formula and default OR
  -- lookup type and default OR default and
  -- min / max
  if p_formula_id is not NULL then
--
   if (p_lookup_type is not NULL or
       p_min_value is not NULL or
       p_max_value is not NULL or
       p_warning_or_error is NULL) then
--
    hr_utility.set_message(801,'PAY_6905_INPVAL_FORMULA_VAL');
    hr_utility.raise_error;
--
   end if;
--
   elsif p_lookup_type is not NULL then
--
    if (p_min_value is not NULL or
        p_max_value is not NULL or
        p_formula_id is not NULL or
        p_warning_or_error is not NULL) then
--
     hr_utility.set_message(801,'PAY_6906_INPVAL_LOOKUP_VAL');
     hr_utility.raise_error;
--
    end if;
--
   elsif (p_min_value is not NULL or p_max_value is not NULL) then
--
    if (p_lookup_type is not NULL or
        p_formula_id is not NULL) then
--
     hr_utility.set_message(801,'PAY_6907_INPVAL_MIN_MAX_VAL');
     hr_utility.raise_error;
--
    elsif (p_warning_or_error is null) then
--
     hr_utility.set_message(801,'PAY_6907_INPVAL_MIN_MAX_VAL');
     hr_utility.raise_error;
--
    end if;

  end if;
--
    if (p_warning_or_error is not null and
    p_min_value is null and
    p_max_value is null and
    p_formula_id is null) then
--
     hr_utility.set_message(801,'PAY_6908_INPVAL_ERROR_VAL');
     hr_utility.raise_error;
--
    end if;
--
  -- Mkae sure that when lookup validation is being used that the default when
  -- specified is valid for the lookup type
--
  if (p_lookup_type is not NULL and p_default_value is not NULL) then
--
   begin
--
    v_validation_check := 'Y';
--
    select 'N'
    into   v_validation_check
    from   sys.dual
    where  not exists(select 1
                      from   hr_lookups
                      where  lookup_type = p_lookup_type
                        and  lookup_code = p_default_value);
--
   exception
    when NO_DATA_FOUND then NULL;
   end;
--
   if v_validation_check = 'N' then
--
    hr_utility.set_message(801,'PAY_6171_INPVAL_NO_LOOKUP');
    hr_utility.raise_error;
--
   end if;
--
  end if;
--
  -- No new input values can be created if there are any run results existing
  -- for this element
        begin
--
        select 'N'
        into v_validation_check
        from sys.dual
        where exists
                (select 1
                from pay_run_results rr
                where rr.element_type_id = p_element_type_id);
--
        exception
                when NO_DATA_FOUND then null;
        end;
--
        if v_validation_check = 'N' then
                hr_utility.set_message(801,'PAY_6913_INPVAL_NO_INS_RUN_RES');
                hr_utility.raise_error;
        end if;

 end chk_input_value;
--
 /*
 NAME
  chk_entry_default
 DESCRIPTION
  This function will check if all entries for an element link and an input
  value have a default value. This is called in situations where we need to
  check for defaults because of hot defaulting. This function will return TRUE
  if any nulls are found in the selected entries. It will also return TRUE if
  there are no entries at all for this link and input value. This allows for
  the fact that entries may be created subsequently with null values.
 */
--
FUNCTION chk_entry_default(f_input_value_id     in number,
                        f_element_link_id       in number,
                        f_val_start_date        in date,
                        f_val_end_date          in date) return BOOLEAN is
--
    null_entries_found  varchar2(1) := 'N';
--
    begin
--

  -- First check to see if there are any entries
--
        begin
--
        select 'Y'
        into null_entries_found
        from sys.dual
        where not exists(
            select 1
            from   pay_element_entries_f ee,
                   pay_element_entry_values_f eev
            where  f_element_link_id = ee.element_link_id
            and    ee.element_entry_id = eev.element_entry_id
            and    eev.input_value_id = f_input_value_id
            and    eev.effective_start_date <= f_val_end_date
            and    eev.effective_end_date >= f_val_start_date);
--
        exception
           when NO_DATA_FOUND then null;
        end;
--
   if (null_entries_found = 'N') then
--
        begin
--
        select  'Y'
        into    null_entries_found
        from sys.dual
        where exists(
            select 1
            from   pay_element_entries_f ee,
                   pay_element_entry_values_f eev
            where  f_element_link_id = ee.element_link_id
            and    ee.element_entry_id = eev.element_entry_id
            and    eev.input_value_id = f_input_value_id
            and    eev.effective_start_date <= f_val_end_date
            and    eev.effective_end_date >= f_val_start_date
            and    eev.screen_entry_value is null);
--
        exception
           when NO_DATA_FOUND then null;
        end;
--
    end if;

        return null_entries_found = 'Y';
--
end chk_entry_default;
--
--
 /*
 NAME
  chk_link_hot_defaults
 DESCRIPTION
  This procedure checks whether all link_input_values and entry values have
  defaults if a hot defaulted default value is made null. It calls the function  chk_entry_default
  */
--
PROCEDURE chk_link_hot_defaults(p_update_mode           in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_input_value_id        in number,
                                p_element_link_id       in number,
                                p_default_delete        in varchar2,
                                p_min_delete            in varchar2,
                                p_max_delete            in varchar2) is
--
--
    null_links_found    varchar2(1);
    l_min_value_missing varchar2(1) := 'N';
    l_max_value_missing varchar2(1) := 'N';
    l_default_value_missing varchar2(1) := 'N';
--
    begin
--
  -- First check that value exists at type level. If this is not the case
  -- then we want to return an error for min and max values and continue
  -- with default to check for all defaults at entry level.
--
  if (p_min_delete = 'Y') then
--
   begin
--
        select 'Y'
        into l_min_value_missing
        from sys.dual
                where exists
                (select 1
                from pay_input_values_f iv
                where p_input_value_id = iv.input_value_id
                and     iv.min_value is null
                and     iv.effective_start_date <= p_val_end_date
                and     iv.effective_end_date >= p_val_start_date);
        exception
           when NO_DATA_FOUND then null;
        end;
--
        if l_min_value_missing = 'Y' then
           hr_utility.set_message(801,'PAY_6192_INPVAL_NO_MIN_DEFS');
           hr_utility.raise_error;
        end if;
 end if;
--
 if (p_max_delete = 'Y') then
--
        begin
--
        select 'Y'
        into l_max_value_missing
        from sys.dual
                where exists
                (select 1
                from pay_input_values_f iv
                where p_input_value_id = iv.input_value_id
                and     iv.max_value is null
                and     iv.effective_start_date <= p_val_end_date
                and     iv.effective_end_date >= p_val_start_date);
        exception
           when NO_DATA_FOUND then null;
        end;
--
        if l_max_value_missing  = 'Y' then
           hr_utility.set_message(801,'PAY_6193_INPVAL_NO_MAX_DEFS');
           hr_utility.raise_error;
        end if;
--
  end if;
--
  -- If the default value is being deleted we need to first check if there
  -- is a default at element type level. If there is not then we need to
  -- check if all the element entries have defaults available.
--
  if (p_default_delete = 'Y') then
--
        begin
--
        select 'Y'
        into l_default_value_missing
        from sys.dual
                where exists
                (select 1
                from pay_input_values_f iv
                where p_input_value_id = iv.input_value_id
                and     iv.default_value is null
                and     iv.effective_start_date <= p_val_end_date
                and     iv.effective_end_date >= p_val_start_date);
        exception
           when NO_DATA_FOUND then null;
        end;
--
        if l_default_value_missing = 'Y' then
--
            if hr_input_values.chk_entry_default
                        (p_input_value_id,
                        p_element_link_id,
                        p_val_start_date,
                        p_val_end_date) then
                   hr_utility.set_message(801,'PAY_6191_INPVAL_NO_ENTRY_DEFS');
                   hr_utility.raise_error;
            end if;
        end if;
--
  end if;
--
end chk_link_hot_defaults;
--
 /*
 NAME
  chk_hot_defaults
 DESCRIPTION
  This procedure checks whether all link_input_values and entry values have
  defaults if a hot defaulted default value is made null. It calls the function  chk_entry_default
  */
--
PROCEDURE chk_hot_defaults(p_update_mode                in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_input_value_id        in number,
                                p_element_type_id       in number,
                                p_default_deleted       in varchar2,
                                p_min_deleted           in varchar2,
                                p_max_deleted           in varchar2) is
--
    null_links_found    varchar2(1);
--
    CURSOR c_chk_link_default(p_val_start_date           date,
                              p_val_end_date             date,
                                p_input_value_id        number) is
                select  element_link_id,
                        effective_start_date,
                        effective_end_date
                from    pay_link_input_values_f
                where   input_value_id = p_input_value_id
                and     default_value is null
                and     effective_end_date >= p_val_start_date
                and     effective_start_date <= p_val_end_date;
--
    begin
--
--
    -- Check if this input value has a null default value
    if p_default_deleted = 'Y' then
--
        -- Go though all the links checking they have defaults.
        -- If any don't then check the element entry value exists.
        -- the function 'chk_entry_default' will return 'TRUE' if any entries
        -- are found without values entered for them.
--
        for chk_default in c_chk_link_default( p_val_start_date,
                                               p_val_end_date,
                                               p_input_value_id) loop
            if hr_input_values.chk_entry_default(p_input_value_id,
                                chk_default.element_link_id,
                                chk_default.effective_start_date,
                                chk_default.effective_end_date) then
                   hr_utility.set_message(801,'PAY_6191_INPVAL_NO_ENTRY_DEFS');
                   hr_utility.raise_error;
            end if;
        end loop;
    end if;
--
    if p_min_deleted = 'Y' then
--
    -- Check that there are no link input values over the validation period
    --  that have a null minimum default.
        begin
--
        select  'Y'
        into    null_links_found
        from    pay_link_input_values_f
        where   input_value_id = p_input_value_id
        and     min_value is null
        and     effective_end_date >= p_val_start_date
        and     effective_start_date <= p_val_end_date;
--
        exception
           when NO_DATA_FOUND then null;
        end;
--
        if null_links_found = 'Y' then
           hr_utility.set_message(801,'PAY_6192_INPVAL_NO_MIN_DEFS');
           hr_utility.raise_error;
        end if;
--
    end if;
--
    if p_max_deleted = 'Y' then
--
    -- Check that there are no link input values over the validation period
    --  that have a null maximum default.
        begin
--
        select  'Y'
        into    null_links_found
        from    pay_link_input_values_f
        where   input_value_id = p_input_value_id
        and     max_value is null
        and     effective_end_date >= p_val_start_date
        and     effective_start_date <= p_val_end_date;
--
        exception
           when NO_DATA_FOUND then null;
        end;
--
        if null_links_found = 'Y' then
           hr_utility.set_message(801,'PAY_6193_INPVAL_NO_MAX_DEFS');
           hr_utility.raise_error;
        end if;
--
    end if; -- of 'if default is null' statement
--
end chk_hot_defaults;
--
--
 /*
 NAME
  chk_del_input_value
 DESCRIPTION
  Checks whether an input value can be deleted. This consists of checking
  if various child records exist for this input value.
 */
--
PROCEDURE chk_del_input_values(p_delete_mode            in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_input_value_id        in number) is
--
    v_links_exist_flag    varchar2(1) := 'N';
    v_db_items_exist_flag varchar2(1) := 'N';
    v_results_exist_flag  varchar2(1) := 'N';
    v_run_results_exist_flag  varchar2(1) := 'N';
    v_entries_exist_flag  varchar2(1) := 'N';
    l_pay_value_name      varchar2(80);
--
 begin
--
  -- Delete future change not allowed for input values
  if p_delete_mode = 'FUTURE_CHANGE' then
        hr_utility.set_message(801,'PAY_6209_ELEMENT_NO_FC_DEL');
        hr_utility.raise_error;
--
  -- the following checks only need to be made for date effective delete or
  -- ZAP delete. Delete next change requires different processing
  elsif p_delete_mode = 'ZAP' then
--
    begin
  -- if 'ZAP' then
  -- test to see if there are any element links during validation period.
  -- and input value is PAY VALUE and the link is distributed
--
        l_pay_value_name := hr_input_values.get_pay_value_name(null);
--
        select 'Y'
        into v_links_exist_flag
        from sys.dual
        where exists
                (select 1
                from pay_element_links_f el,
                     pay_input_values_f_tl ip_tl,
                     pay_input_values_f ip
                where ip_tl.input_value_id = ip.input_value_id
                and   ip.input_value_id = p_input_value_id
                and   userenv('LANG') = ip_tl.language
                and   ip_tl.name = l_pay_value_name
                and   el.element_type_id  = ip.element_type_id
                and   el.costable_type    = 'D'
                and   el.effective_start_date <= p_val_end_date
                and   el.effective_end_date >= p_val_start_date);
--
  exception
        when NO_DATA_FOUND then NULL;
  end;
--
  if v_links_exist_flag = 'Y' then
        hr_utility.set_message(801,'PAY_6210_INPVAL_NO_LINKS_DEL');
        hr_utility.raise_error;
  end if;
--
--
  end if;
--
--
  if p_delete_mode = 'DELETE' or p_delete_mode = 'ZAP' then
--
  begin
  -- Test to see if there are any element entry values during validation period
--
        select 'Y'
        into v_entries_exist_flag
        from sys.dual
        where exists
            (select 1
            from pay_element_entry_values_f
            where input_value_id = p_input_value_id
            and  effective_start_date <= p_val_end_date
            and  effective_end_date >= p_val_start_date);
--
  exception
        when NO_DATA_FOUND then NULL;
  end;
--
  if v_entries_exist_flag = 'Y' then
        hr_utility.set_message(801,'PAY_6211_INPVAL_NO_DEL_ENTRY');
        hr_utility.raise_error;
  end if;
--
  begin
  -- Test to see if any formula result rules target this input value during
  -- the validation period.
--
        select 'Y'
        into v_results_exist_flag
        from sys.dual
        where exists
            (select 1
            from pay_formula_result_rules_f
            where input_value_id = p_input_value_id
            and  effective_start_date <= p_val_end_date
            and  effective_end_date >= p_val_start_date);
--
  exception
        when NO_DATA_FOUND then NULL;
  end;
--
  if v_results_exist_flag = 'Y' then
        hr_utility.set_message(801,'PAY_6213_INPVAL_NO_FRR_DEL');
        hr_utility.raise_error;
  end if;
--
  begin
  -- Test to see if any run_result_values are in existence during the validation
  -- period. The effective date of run result values can be found from the
  -- payroll_actions table
--
        select 'Y'
        into v_run_results_exist_flag
        from sys.dual
        where exists
            (select /*+ INDEX(rr PAY_RUN_RESULTS_PK) */ 1
            from pay_run_result_values rrv,
                 pay_run_results rr,
                 pay_assignment_actions aa,
                 pay_payroll_actions pa
            where p_input_value_id = rrv.input_value_id
            and rrv.run_result_id = rr.run_result_id
            and aa.assignment_action_id = rr.assignment_action_id
            and aa.payroll_action_id = pa.payroll_action_id
            and pa.effective_date between
                p_val_start_date and p_val_end_date);
--
  exception
        when NO_DATA_FOUND then NULL;
  end;
--
  if v_run_results_exist_flag = 'Y' then
        hr_utility.set_message(801,'PAY_6212_INPVAL_NO_RR_DEL');
        hr_utility.raise_error;
  end if;
--
  begin
  -- You cannot delete an input value if any absence_attendance types access
  -- This input value.
--
        select 'Y'
        into v_results_exist_flag
        from sys.dual
        where exists
            (select 1
            from per_absence_attendance_types
            where input_value_id = p_input_value_id
            and date_effective between
                p_val_start_date and p_val_end_date);
--
  exception
        when NO_DATA_FOUND then NULL;
  end;
--
  if v_results_exist_flag = 'Y' then
        hr_utility.set_message(801,'PAY_6214_INPVAL_NO_ABS_DEL');
        hr_utility.raise_error;
  end if;
--
  begin
  -- You cannot delete an input value if any absence_attendance types access
  -- This input value.
--
        select 'Y'
        into v_results_exist_flag
        from sys.dual
        where exists
            (select 1
            from pay_backpay_rules
            where input_value_id = p_input_value_id);
--
  exception
        when NO_DATA_FOUND then NULL;
  end;
--
  if v_results_exist_flag = 'Y' then
        hr_utility.set_message(801,'PAY_6215_INPVAL_NO_DEL_BP');
        hr_utility.raise_error;
  end if;
--
end if; -- of check delete mode condition.
--
end chk_del_input_values;
--
--
 /*
 NAME
  chk_field_update
 DESCRIPTION
  A general function for input values that forces correction for a particular
  field over the lifetime of a complete input value. It should be called after
  the postfield datetrack trigger.
 */
FUNCTION        chk_field_update(
                        p_input_value_id        in number,
                        p_val_start_date        in date,
                        p_val_end_date          in date,
                        p_update_mode           in varchar2) return BOOLEAN is
--
        l_validation_check      varchar2(1) := 'N';
--
begin
--
        if (p_update_mode <> 'CORRECTION') then
--
                return FALSE;
        end if;
--
        begin
--
            select 'Y'
            into l_validation_check
            from sys.dual
            where  p_val_end_date =
                        (select max(iv1.effective_end_date)
                        from pay_input_values iv1
                        where iv1.input_value_id = p_input_value_id)
            and p_val_start_date =
                        (select min(iv2.effective_start_date)
                        from pay_input_values iv2
                        where iv2.input_value_id = p_input_value_id);
--
        exception
            when NO_DATA_FOUND then null;
        end;
--
        return l_validation_check = 'Y';
--
end chk_field_update;
--
 /*
 NAME
  get_pay_value_name
 DESCRIPTION
  gets pay value from translation table.
  */
--
FUNCTION        get_pay_value_name(p_legislation_code   varchar2)
                                        return varchar2 is
        l_pay_value_name        varchar2(80);
begin
--
        begin

                select meaning
                into   l_pay_value_name
                from   hr_lookups
                where  lookup_type   =  'NAME_TRANSLATIONS'
                and    lookup_code   =  'PAY VALUE';
--
        exception
                when NO_DATA_FOUND then
                hr_utility.set_message(801,'PAY_6162_ELEMENT_NO_NAME_TRANS');
                hr_utility.raise_error;
        end;
--
        return(l_pay_value_name);
--
end get_pay_value_name;
 /*
 NAME
  chk_upd_input_value
 DESCRIPTION
  Checks whether an input value can be updated. Some values can be updated
  under any circumstances and others can only be updated if certain conditions
  exist. For instance if there are no links in existence. This procedure calls
  chk_hot_defaults.
 */
--
PROCEDURE chk_upd_input_values(p_update_mode            in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_classification_type   in varchar2,
                                p_old_name              in varchar2,
                                p_name                  in varchar2,
                                p_input_value_id        in number,
                                p_element_type_id       in number,
                                p_old_uom               in varchar2,
                                p_uom                   in varchar2,
                                p_old_db_items_flag     in varchar2,
                                p_db_items_flag         in varchar2,
                                p_old_default_value     in varchar2,
                                p_default_value         in varchar2,
                                p_old_min_value         in varchar2,
                                p_min_value             in varchar2,
                                p_old_max_value         in varchar2,
                                p_max_value             in varchar2,
                                p_old_error_flag        in varchar2,
                                p_error_flag            in varchar2,
                                p_old_mandatory_flag    in varchar2,
                                p_mandatory_flag        in varchar2,
                                p_old_formula_id        in number,
                                p_formula_id            in number,
                                p_old_lookup_type       in varchar2,
                                p_lookup_type           in varchar2,
                                p_business_group_id     in number,
                                p_legislation_code      in varchar2) is
--
    local_warning       exception;
    l_validation_check    varchar2(1) := 'N';
    l_link_inputs_exist   varchar2(1) := 'N';
    v_entries_exist_flag  varchar2(1) := 'N';
    l_pay_value_name      varchar2(80);
    l_record_ok           varchar2(1) := 'N';
--
--
 begin
--
  -- We need to clear the warning flag as this may still be in force from
  -- a previous update
    hr_utility.clear_warning;
--
 -- Do checks if the following fields have been updated.
    if (p_old_uom <> p_uom)
    or (p_old_db_items_flag <> p_db_items_flag)
    or (p_old_mandatory_flag <> p_mandatory_flag)
    or (p_old_name <> p_name)
    or (p_error_flag = 'E' and p_error_flag <> p_old_error_flag) then
--
  -- Obtain Pay value name from translation table.
        l_pay_value_name := hr_input_values.get_pay_value_name
                                        (p_legislation_code);
--
        -- No date effective change of name, Can only be changed if no formulas
        -- access it.

        if (p_old_name <> p_name) and
            ((p_update_mode <> 'CORRECTION') or
            (p_old_name = l_pay_value_name) or
            (p_name = l_pay_value_name) or
            (p_business_group_id is null)) then
                hr_utility.set_message(801,'PAY_6177_INPVAL_NO_NAME_CHANGE');
                hr_utility.raise_error;
        end if;
--
        -- Unit of measure can only be changed if non_payment_flag on
        -- Classification is 'N' or the change keeps within the Unit of measure
        -- type. This can be found by comparing the first two letters.
        if (p_old_uom <> p_uom) and
           (p_classification_type = 'N') and
            (substr(p_old_uom, 1, 2) <> substr(p_uom, 1, 2)) then
                hr_utility.set_message(801,'PAY_6178_INPVAL_NO_UOM_CHANGE');
                hr_utility.raise_error;
        end if;
--
  -- The mandatory flag can only ever be changed from mandatory to non mandatory  -- otherwise the entries might be invalidated.
        if ((p_mandatory_flag = 'Y') and (p_old_mandatory_flag = 'N')) then
--
                hr_utility.set_message(801,'PAY_6179_INPVAL_MAND_NO_CHANGE');
                hr_utility.raise_error;
--
        elsif (p_mandatory_flag <> p_old_mandatory_flag) then
             -- we must also check to see if the mandatory flag will ever
             -- become mandatory in the future.
            begin

            select 'Y'
            into l_validation_check
            from sys.dual
            where exists
                (select 1
                from pay_input_values_f iv
                where iv.input_value_id = p_input_value_id
                and iv.effective_start_date > p_val_start_date
                and iv.mandatory_flag = 'Y');
--
            exception
                when NO_DATA_FOUND then NULL;
            end;
--
            if l_validation_check = 'Y' then
                hr_utility.set_message(801,'PAY_6179_INPVAL_MAND_NO_CHANGE');
                hr_utility.raise_error;
            end if;
--
        end if;
--
        -- Warning or error flag can only be updated if there are no entries
        -- in existence. This will only need to be checked if there are any
        -- links
        if ((p_error_flag = 'E') and (p_error_flag <> p_old_error_flag)) then
--
                begin
--
                select 'Y'
                into v_entries_exist_flag
                from sys.dual
                where exists
                        (select 1
                        from    pay_element_links_f el,
                                pay_element_entries_f ee
                        where   p_element_type_id = el.element_type_id
                        and     el.element_link_id = ee.element_link_id
                        and     el.effective_start_date <= p_val_end_date
                        and     el.effective_end_date >= p_val_start_date
                        and     ee.effective_start_date <= p_val_end_date
                        and     ee.effective_end_date >= p_val_start_date);
--
                exception
                    when NO_DATA_FOUND then NULL;
                end;
--
        if v_entries_exist_flag = 'Y' then
            hr_utility.set_message(801,'PAY_6181_INPVAL_ERR_FLAG_UPD');
            hr_utility.raise_error;
        end if;
    end if; -- error flag checks
--
    if chk_field_update(p_input_value_id,
                        p_val_start_date,
                        p_val_end_date,
                        p_update_mode) = FALSE then
--
        if (p_old_name <> p_name) then
--
            hr_utility.set_message(801,'PAY_6632_INPVAL_NO_NAME_UPD');
            hr_utility.raise_error;
--
        elsif (p_old_db_items_flag <> p_db_items_flag) then
--
            hr_utility.set_message(801,'PAY_6633_INPVAL_NO_DB_UPD');
            hr_utility.raise_error;
--
        elsif (p_uom <> p_old_uom) then
--
            hr_utility.set_message(801,'PAY_6634_INPVAL_NO_UOM_UPD');
            hr_utility.raise_error;
--
        end if;
    end if;
--
end if; -- General Check conditions
--
     if (nvl(p_old_default_value, ' ') <> nvl(p_default_value, ' ')) or
        (nvl(p_old_min_value, ' ') <> nvl(p_min_value, ' ')) or
        (nvl(p_old_max_value, ' ') <> nvl(p_max_value, ' ')) or
        (nvl(p_old_error_flag, ' ') <> nvl(p_error_flag, ' ')) or
        (nvl(p_old_formula_id, ' ') <> nvl(p_formula_id, ' ')) or
        (nvl(p_old_lookup_type, ' ') <> nvl(p_lookup_type, ' ')) then
--
        -- we must check for the existence of link input values and issue
        -- a warning if there are any.
        begin
--
        select 'Y'
        into l_link_inputs_exist
        from sys.dual
        where exists
                (select 1
                from pay_link_input_values_f liv
                where liv.input_value_id = p_input_value_id);
--
        exception
                when NO_DATA_FOUND then NULL;
        end;
--
        if l_link_inputs_exist = 'Y' then
--
                hr_utility.set_message(801, 'PAY_INPVAL_LINK_UPD_WARN');
                hr_utility.set_warning;
--
        end if;
    end if;
--
end chk_upd_input_values;
--
 /*
 NAME
  create_link_input_value
 DESCRIPTION
  This procedure creates links under two circumstances.
  1. When a new link has been created.
  2. When a new input value is created and there are already existing links
  This behaviour is controlled by the p_insert_type parameter which can take
  the  values 'INSERT_LINK' or 'INSERT_INPUT_VALUE'.
  */
--
PROCEDURE
          create_link_input_value(p_insert_type            varchar2,
                                  p_element_link_id        number,
                                  p_input_value_id         number,
                                  p_input_value_name       varchar2,
                                  p_costable_type          varchar2,
                                  p_validation_start_date  date,
                                  p_validation_end_date    date,
                                  p_default_value          varchar2,
                                  p_max_value              varchar2,
                                  p_min_value              varchar2,
                                  p_warning_or_error_flag  varchar2,
                                  p_hot_default_flag       varchar2,
                                  p_legislation_code       varchar2,
                                  p_pay_value_name         varchar2,
                                  p_element_type_id        number) is
--
 v_link_input_value_id    number;
 v_old_input_value_id     number := 0;
--
 -- This selects all input values for an element type
 cursor c_input_value(p_element_type_id  number) is
   select iv.input_value_id input_value_id
   from   pay_input_values_f iv
   where  iv.element_type_id = p_element_type_id
   order by iv.input_value_id
   for update;
--
begin
--
 -- The following code will insert link input values when a link is inserted.
 if p_insert_type = 'INSERT_LINK' then
--
 -- For each input value for the element type NB. this locks all the records
 for iv_rec in c_input_value(p_element_type_id) loop
--
   -- Check to see if this input value has already been processed. If it has
   -- then do not process again
   if iv_rec.input_value_id <> v_old_input_value_id then
--
     -- Get sequence number for link_input_value
     select pay_link_input_values_s.nextval
     into   v_link_input_value_id
     from   sys.dual;
--
     -- Copy the date effective rows from the input value to the link input
     -- value where they overlap
     insert into pay_link_input_values_f
     (LINK_INPUT_VALUE_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      ELEMENT_LINK_ID,
      INPUT_VALUE_ID,
      COSTED_FLAG,
      DEFAULT_VALUE,
      MAX_VALUE,
      MIN_VALUE,
      WARNING_OR_ERROR,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
     select
      v_link_input_value_id,
      greatest(p_validation_start_date,iv.effective_start_date),
      least(p_validation_end_date,iv.effective_end_date),
      p_element_link_id,
      iv.input_value_id,
      decode(p_costable_type,
                'F', decode(iv_tl.name, p_pay_value_name, 'Y','N'),
                'C', decode(iv_tl.name, p_pay_value_name, 'Y','N'),
                'D', decode(iv_tl.name, p_pay_value_name, 'Y','N'),
                'N'),
      decode(iv.hot_default_flag,'Y',NULL,iv.default_value),
      decode(iv.hot_default_flag,'Y',NULL,iv.max_value),
      decode(iv.hot_default_flag,'Y',NULL,iv.min_value),
      decode(iv.hot_default_flag,'Y',NULL,iv.warning_or_error),
      sysdate,
      -1,
      -1,
      -1,
      sysdate
     from  pay_input_values_f_tl iv_tl,
           pay_input_values_f iv
     where iv_tl.input_value_id = iv.input_value_id
       and iv.input_value_id        = iv_rec.input_value_id
       and userenv('LANG')          = iv_tl.language
       and iv.effective_start_date <= p_validation_end_date
       and iv.effective_end_date   >= p_validation_start_date;
--
--
     -- Hold onto the current input_value_id that has been processed for use in
     -- a check to make sure that it is not processed twice
     v_old_input_value_id := iv_rec.input_value_id;
--
   end if;
--
 end loop;
--
  elsif p_insert_type = 'INSERT_INPUT_VALUE' then
--
  -- insert link input values when an new input value has been inserted and
  -- links already exist.
--
     insert into pay_link_input_values_f
     (LINK_INPUT_VALUE_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      ELEMENT_LINK_ID,
      INPUT_VALUE_ID,
      COSTED_FLAG,
      DEFAULT_VALUE,
      MAX_VALUE,
      MIN_VALUE,
      WARNING_OR_ERROR,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
     select
      pay_link_input_values_s.nextval,
      greatest(p_validation_start_date,eL.effective_start_date),
      least(p_validation_end_date,eL.effective_end_date),
      el.element_link_id,
      p_input_value_id,
      decode(el.costable_type,
                'F', decode(P_input_value_name, p_pay_value_name, 'Y','N'),
                'C', decode(p_input_value_name, p_pay_value_name, 'Y','N'),
                'D', decode(p_input_value_name, p_pay_value_name, 'Y','N'),
                'N'),
      decode(p_hot_default_flag,'Y',NULL,p_default_value),
      decode(p_hot_default_flag,'Y',NULL,p_max_value),
      decode(P_hot_default_flag,'Y',NULL,p_min_value),
      decode(p_hot_default_flag,'Y',NULL,p_warning_or_error_flag),
      sysdate,
      -1,
      -1,
      -1,
      sysdate
     from pay_element_links_F el
     where p_element_type_id = el.element_type_id
     and el.effective_start_date <=  p_validation_end_date
     and el.effective_end_date >= p_validation_start_date;

End if; -- decision code for insert type.
--
End create_link_input_value;
--
--
 /*
 NAME
  ins_3p_input_values
 DESCRIPTION
  This procedure controls the third party inserts when an input value is
  created manually. (Rather than being created at the same time as an element
  type.) It calls the procedures create_link_input_value and
  hr_balances.ins_balance_feed.
  */
--
PROCEDURE       ins_3p_input_values(p_val_start_date    in date,
                                p_val_end_date          in date,
                                p_element_type_id       in number,
                                p_primary_classification_id in number,
                                p_input_value_id        in number,
                                p_default_value         in varchar2,
                                p_max_value             in varchar2,
                                p_min_value             in varchar2,
                                p_warning_or_error_flag in varchar2,
                                p_input_value_name      in varchar2,
                                p_db_items_flag         in varchar2,
                                p_costable_type         in varchar2,
                                p_hot_default_flag      in varchar2,
                                p_business_group_id     in number,
                                p_legislation_code      in varchar2,
                                p_startup_mode          in varchar2) is
--
        l_pay_value_name        varchar2(80);
--
--
 begin
--
  -- Obtain Pay value name from translation table.
        l_pay_value_name :=
                hr_input_values.get_pay_value_name(p_legislation_code);
--
  -- Call function to insert new link input value
        hr_input_values.create_link_input_value('INSERT_INPUT_VALUE',
                                  NULL,
                                  p_input_value_id         ,
                                  p_input_value_name       ,
                                  NULL,
                                  p_val_start_date  ,
                                  p_val_end_date    ,
                                  p_default_value          ,
                                  p_max_value              ,
                                  p_min_value              ,
                                  p_warning_or_error_flag  ,
                                  p_hot_default_flag       ,
                                  p_legislation_code       ,
                                  l_pay_value_name         ,
                                  p_element_type_id        );
--
-- A balance feed will be inserted if a new pay value is created.
   if p_input_value_name = l_pay_value_name then
        hr_balances.ins_balance_feed('INS_PER_PAY_VALUE',
                          p_input_value_id,
                          NULL,
                          p_primary_classification_id,
                          NULL,NULL,NULL,NULL,
                          p_val_start_date,
                          p_business_group_id,
                          p_legislation_code,
                          p_startup_mode);
--
    end if;
--
    if p_db_items_flag = 'Y' then
--
  -- Create database items
--
        hrdyndbi.create_input_value_dict(
                        p_input_value_id,
                        p_val_start_date);
--
    end if;

end ins_3p_input_values;
--
 /*
 NAME
  upd_3p_input_values
 DESCRIPTION
  This procedure should be called on post delete. When the name has been
  updated and create database items is set to Yes then the database items
  will be dropped and recreated. This will fail if it is unable to drop the
  database items.
  */
PROCEDURE       upd_3p_input_values(p_input_value_id    in number,
                                    p_val_start_date    in date,
                                    p_old_name          in varchar2,
                                    p_name              in varchar2,
                                    p_db_items_flag     in varchar2,
                                    p_old_db_items_flag in varchar2) is
--
begin
--
        if (p_db_items_flag = 'Y') and (p_old_name <> p_name) then
--
                hrdyndbi.delete_input_value_dict(
                                p_input_value_id);
--
                hrdyndbi.create_input_value_dict(
                                p_input_value_id,
                                p_val_start_date);
--
        elsif (p_db_items_flag = 'Y' and p_old_db_items_flag = 'N') then
--
                hrdyndbi.create_input_value_dict(
                                p_input_value_id,
                                p_val_start_date);
--
        elsif (p_db_items_flag = 'N' and p_old_db_items_flag = 'Y') then
--
                hrdyndbi.delete_input_value_dict(
                                p_input_value_id);
--
        end if;
end upd_3p_input_values;

--
 /*
 NAME
  del_3p_input_values
 DESCRIPTION
  This procedure does the necessary cascade deletes when deleting an input
  value. This only deletes balance feeds. It calls the procedure -
  hr.balances.del_balance_feed.
  */
--
PROCEDURE       del_3p_input_values(p_delete_mode       in varchar2,
                                    p_input_value_id    in number,
                                    p_db_items_flag     in varchar2,
                                    p_val_end_date      in date,
                                    p_session_date      in date,
                                    p_startup_mode      in varchar2) is
--
        l_delete_mode   varchar2(30);
        l_on_final_record      varchar2(1) := 'N';
        v_end_of_time          date;
--
    begin
--
        hr_balances.del_balance_feed
                        ('DEL_INPUT_VALUE',
                         p_delete_mode,
                         NULL,
                         p_input_value_id,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         p_session_date,
                         p_val_end_date,
                         NULL,
                         p_startup_mode);
                         --
--
--  DELETE and DELETE_FUTURE_CHANGE are not allowed on input values.
--
--   Delete link input values
--
     if p_delete_mode = 'ZAP'   then
        delete
        from   pay_link_input_values_f
        where  input_value_id = p_input_value_id;
--
     elsif p_delete_mode = 'DELETE_NEXT_CHANGE' then
--
 -- DELETE_NEXT_CHANGE will only affect the link input value records if we are
 -- on The final record of the input value. In this case the final link input
 -- value records will need to be extended to the end of time.
--
    begin
--
      select 'Y'
      into l_on_final_record
      from pay_input_values_f iv1
      where p_input_value_id  = iv1.input_value_id
      and p_session_date between
        iv1.effective_start_date and iv1.effective_end_date
      and iv1.effective_end_date =
        (select max(iv2.effective_end_date)
            from pay_input_values_f iv2
            where p_input_value_id  = iv2.input_value_id);
--
    exception
       when NO_DATA_FOUND then NULL;
    end;
--
    if l_on_final_record = 'Y' then
--
        v_end_of_time := to_date('31/12/4712', 'DD/MM/YYYY');
--
        update pay_link_input_values_f lv1
        set lv1.effective_end_date = v_end_of_time
        where p_input_value_id  = lv1.input_value_id
        and lv1.effective_end_date =
                (select max(lv2.effective_end_date)
                from pay_link_input_values_f lv2
                where lv2.link_input_value_id = lv1.link_input_value_id
                and   lv2.input_value_id = p_input_value_id);
--
   end if;
--
--
 end if;
        -- Create database items
        if p_db_items_flag = 'Y' then
--
             hrdyndbi.delete_input_value_dict(p_input_value_id);
        end if;
--
end del_3p_input_values;
--
end hr_input_values;

/
