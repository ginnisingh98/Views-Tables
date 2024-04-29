--------------------------------------------------------
--  DDL for Package Body PAY_DB_PAY_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DB_PAY_SETUP" as
/* $Header: pypsetup.pkb 120.0.12010000.4 2009/11/10 14:15:41 asnell ship $ */
   g_debug boolean := hr_utility.debug_enabled;
--
-------------------------------- create element -------------------------------
 /*
 NAME
   create_element
 DESCRIPTION
   This is a function that creates an element type according to the parameters
   passed to it.
 NOTES
   If the element to be created is a payroll element then it will also create a
   default PAY_VALUE and status processing rule. Balance feeds will also be
   created for balance fed by the same classification as that of the element.
 */
--
FUNCTION create_element(p_element_name           varchar2,
                        p_description            varchar2 default NULL,
                        p_reporting_name         varchar2 default NULL,
                        p_classification_name    varchar2,
                        p_input_currency_code    varchar2 default NULL,
                        p_output_currency_code   varchar2 default NULL,
                        p_processing_type        varchar2 default 'R',
                        p_mult_entries_allowed   varchar2 default 'N',
                        p_formula_id             number   default NULL,
                        p_processing_priority    number   default NULL,
                        p_closed_for_entry_flag  varchar2 default 'N',
                        p_standard_link_flag     varchar2 default 'N',
                        p_qual_length_of_service number   default NULL,
                        p_qual_units             varchar2 default NULL,
                        p_qual_age               number   default NULL,
                        p_process_in_run_flag    varchar2 default 'Y',
                        p_post_termination_rule  varchar2,
                        p_indirect_only_flag     varchar2 default 'N',
                        p_adjustment_only_flag   varchar2 default 'N',
                        p_add_entry_allowed_flag varchar2 default 'N',
                        p_multiply_value_flag    varchar2 default 'N',
                        p_effective_start_date   date     default NULL,
                        p_effective_end_date     date     default NULL,
                        p_business_group_name    varchar2 default NULL,
                        p_legislation_code       varchar2 default NULL,
                        p_legislation_subgroup   varchar2 default NULL,
                        p_third_party_pay_only   varchar2 default 'N',
                        p_retro_summ_ele_id             number default null,
                        p_iterative_flag                varchar2 default null,
                        p_iterative_formula_id          number default null,
                        p_iterative_priority            number default null,
                        p_process_mode                  varchar2 default null,
                        p_grossup_flag                  varchar2 default null,
                        p_advance_indicator             varchar2 default null,
                        p_advance_payable               varchar2 default null,
                        p_advance_deduction             varchar2 default null,
                        p_process_advance_entry         varchar2 default null,
                        p_proration_group_id            number default null,
                        p_proration_formula_id          number default null,
                        p_recalc_event_group_id         number default null,
                        p_once_each_period_flag         varchar2 default null
)
                                                              RETURN number is
--..
 -- Constants
 v_end_of_time           constant date := to_date('31/12/4712','DD/MM/YYYY');
 v_todays_date           constant date := trunc(sysdate);
--
 -- Local variables
 v_element_type_id       number;
 v_classification_id     number;
 v_processing_priority   number;
 v_session_date          date;
 v_effective_start_date  date;
 v_effective_end_date    date;
 v_business_group_id     number;
 v_currency_code         varchar2(240);
 v_input_currency_code   varchar2(240);
 v_output_currency_code  varchar2(240);
 v_non_payments_flag     varchar2(240);
 v_legislation_code      varchar2(240);
 v_post_term_rule        varchar2(240);
 v_mode                  varchar2(30);
 v_rowid                 VARCHAR2(240);
 v_termination_rule_code VARCHAR2(240);
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element',1);
 end if;
--
 begin
   -- Get the session date nb. this is defaulted to todays date
   select ss.effective_date
   into   v_session_date
   from   fnd_sessions ss
   where  ss.session_id = userenv('sessionid');
 exception
   when NO_DATA_FOUND then NULL;
 end;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element',3);
 end if;
--
-- Added the OR to the below SQL statement to fix an MLS
-- Problem related to the comparison of the Meaning with the
-- passed in parameter.  The SQL has been altered such that the
-- parameter can be passed in English and then decoded to the appropriate
-- lookup up code.
--
 -- Get the post termination rule
 select hl.lookup_code
 into   v_post_term_rule
 from   hr_lookups hl
 where  hl.lookup_type = 'TERMINATION_RULE'
   and  (upper(hl.meaning) = upper(p_post_termination_rule)
         or
         hl.lookup_code =
         decode(p_post_termination_rule, 'Actual Termination','A',
                                         'Final Close', 'F',
                                         'Last Standard Process','L',
                                          p_post_termination_rule));
--
 -- Default the start date to the session date if no date is supplied
 if p_effective_start_date is not NULL then
   v_effective_start_date := p_effective_start_date;
   v_session_date := p_effective_start_date;
   elsif v_session_date is not NULL then
     v_effective_start_date := v_session_date;
     else
       v_effective_start_date := trunc(sysdate);
       v_session_date := trunc(sysdate);
 end if;
--
 -- Default the end date to the end of time if no date is supplied
 if p_effective_end_date is NULL then
   v_effective_end_date := v_end_of_time;
   else
     v_effective_end_date := p_effective_end_date;
 end if;
--
 -- Find the business_group_id for the business group and get the currency of
 -- business group for potential defaulting of input and output currency
 if p_business_group_name is not NULL then
--
   if g_debug then
      hr_utility.set_location('pay_db_pay_setup.create_element',4);
   end if;
--
   select business_group_id,
          currency_code,
          legislation_code
   into   v_business_group_id,
          v_currency_code,
          v_legislation_code
   from   per_business_groups
   where  name = p_business_group_name;
--
   -- Set startup data mode
   v_mode := 'USER';
--
   -- select the currency for the legislation for potential defaulting
   -- of input and output currency code for startup elements
   elsif p_legislation_code is not NULL then
--
     if g_debug then
        hr_utility.set_location('pay_db_pay_setup.create_element',5);
     end if;
--
     if p_input_currency_code is null or p_output_currency_code is null then
--
       v_currency_code := get_default_currency
                            (p_legislation_code => p_legislation_code);
--
     end if;
--
     v_legislation_code := p_legislation_code;
--
     -- Set startup data mode
     v_mode := 'STARTUP';
--
     else
--
       -- Set startup data mode
       v_mode := 'GENERIC';
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element',6);
 end if;
--
 -- Find the classification for the element
 select ec.classification_id,
        nvl(p_processing_priority, ec.default_priority),
        ec.non_payments_flag
 into   v_classification_id,
        v_processing_priority,
        v_non_payments_flag
 from   pay_element_classifications ec
 where  upper(ec.classification_name) = upper(p_classification_name)
   and  ec.parent_classification_id is NULL
   and  ((ec.legislation_code = v_legislation_code)
     or (ec.legislation_code is null
         and not exists (select ''
                        from pay_element_classifications ec2
                        where  upper(ec2.classification_name) = upper(p_classification_name)
                        and  ec2.parent_classification_id is NULL
                        and  ec2.legislation_code = v_legislation_code)
        ));
--
 -- Default the input currency code if it is not specified
 v_input_currency_code := nvl(p_input_currency_code,v_currency_code);
--
 -- Default the output currency code if it is not specified
 v_output_currency_code := nvl(p_output_currency_code,v_currency_code);
--
 -- Validate element type
 hr_elements.chk_element_type
  (p_element_name           => p_element_name,
   p_element_type_id        => v_element_type_id,
   p_val_start_date         => v_effective_start_date,
   p_val_end_date           => v_effective_end_date,
   p_reporting_name         => p_reporting_name,
   p_rowid                  => NULL,
   p_recurring_flag         => p_processing_type,
   p_standard_flag          => p_standard_link_flag,
   p_scndry_ent_allwd_flag  => p_add_entry_allowed_flag,
   p_process_in_run_flag    => p_process_in_run_flag,
   p_indirect_only_flag     => p_indirect_only_flag,
   p_adjustment_only_flag   => p_adjustment_only_flag,
   p_multiply_value_flag    => p_multiply_value_flag,
   p_classification_type    => v_non_payments_flag,
   p_output_currency_code   => v_output_currency_code,
   p_input_currency_code    => v_input_currency_code,
   p_business_group_id      => v_business_group_id,
   p_legislation_code       => p_legislation_code,
   p_bus_grp_currency_code  => v_currency_code);

--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element',7);
 end if;
--
 -- Create a row in pay_element_types

 pay_element_types_pkg.insert_row(
 p_rowid                        =>v_rowid,
 P_ELEMENT_TYPE_ID              =>v_element_type_id,
 P_EFFECTIVE_START_DATE         =>v_effective_start_date,
 P_EFFECTIVE_END_DATE           =>v_effective_end_date,
 P_BUSINESS_GROUP_ID            =>v_business_group_id,
 P_LEGISLATION_CODE             =>p_legislation_code,
 P_FORMULA_ID                   =>p_formula_id,
 P_INPUT_CURRENCY_CODE          =>v_input_currency_code,
 P_OUTPUT_CURRENCY_CODE         =>v_output_currency_code,
 P_CLASSIFICATION_ID            =>v_classification_id,
 P_BENEFIT_CLASSIFICATION_ID    =>NULL,
 P_ADDITIONAL_ENTRY_ALLOWED     =>p_add_entry_allowed_flag,
 P_ADJUSTMENT_ONLY_FLAG         =>p_adjustment_only_flag,
 P_CLOSED_FOR_ENTRY_FLAG        =>p_closed_for_entry_flag,
 P_ELEMENT_NAME                 =>p_element_name,
 P_BASE_ELEMENT_NAME            =>p_element_name,
 P_INDIRECT_ONLY_FLAG           =>p_indirect_only_flag,
 P_MULTIPLE_ENTRIES_ALLOWED     =>p_mult_entries_allowed,
 P_MULTIPLY_VALUE_FLAG          =>p_multiply_value_flag,
 P_POST_TERMINATION_RULE        =>v_post_term_rule,
 P_PROCESS_IN_RUN_FLAG          =>p_process_in_run_flag,
 P_PROCESSING_PRIORITY          =>v_processing_priority,
 P_PROCESSING_TYPE              =>p_processing_type,
 P_STANDARD_LINK_FLAG           =>p_standard_link_flag,
 P_COMMENT_ID                   =>NULL,
 P_DESCRIPTION                  =>p_description,
 P_LEGISLATION_SUBGROUP         =>p_legislation_subgroup,
 P_QUALIFYING_AGE               =>p_qual_age,
 P_QUALIFYING_LENGTH_OF_SERVICE =>p_qual_length_of_service,
 P_QUALIFYING_UNITS             =>p_qual_units,
 P_REPORTING_NAME               =>p_reporting_name,
 P_ATTRIBUTE_CATEGORY           =>NULL,
 P_ATTRIBUTE1                   =>NULL,
 P_ATTRIBUTE2                   =>NULL,
 P_ATTRIBUTE3                   =>NULL,
 P_ATTRIBUTE4                   =>NULL,
 P_ATTRIBUTE5                   =>NULL,
 P_ATTRIBUTE6                   =>NULL,
 P_ATTRIBUTE7                   =>NULL,
 P_ATTRIBUTE8                   =>NULL,
 P_ATTRIBUTE9                   =>NULL,
 P_ATTRIBUTE10                  =>NULL,
 P_ATTRIBUTE11                  =>NULL,
 P_ATTRIBUTE12                  =>NULL,
 P_ATTRIBUTE13                  =>NULL,
 P_ATTRIBUTE14                  =>NULL,
 P_ATTRIBUTE15                  =>NULL,
 P_ATTRIBUTE16                  =>NULL,
 P_ATTRIBUTE17                  =>NULL,
 P_ATTRIBUTE18                  =>NULL,
 P_ATTRIBUTE19                  =>NULL,
 P_ATTRIBUTE20                  =>NULL,
 P_ELEMENT_INFORMATION_CATEGORY =>NULL,
 P_ELEMENT_INFORMATION1         =>NULL,
 P_ELEMENT_INFORMATION2         =>NULL,
 P_ELEMENT_INFORMATION3         =>NULL,
 P_ELEMENT_INFORMATION4         =>NULL,
 P_ELEMENT_INFORMATION5         =>NULL,
 P_ELEMENT_INFORMATION6         =>NULL,
 P_ELEMENT_INFORMATION7         =>NULL,
 P_ELEMENT_INFORMATION8         =>NULL,
 P_ELEMENT_INFORMATION9         =>NULL,
 P_ELEMENT_INFORMATION10        =>NULL,
 P_ELEMENT_INFORMATION11        =>NULL,
 P_ELEMENT_INFORMATION12        =>NULL,
 P_ELEMENT_INFORMATION13        =>NULL,
 P_ELEMENT_INFORMATION14        =>NULL,
 P_ELEMENT_INFORMATION15        =>NULL,
 P_ELEMENT_INFORMATION16        =>NULL,
 P_ELEMENT_INFORMATION17        =>NULL,
 P_ELEMENT_INFORMATION18        =>NULL,
 P_ELEMENT_INFORMATION19        =>NULL,
 P_ELEMENT_INFORMATION20        =>NULL,
 P_NON_PAYMENTS_FLAG            =>NULL,
 P_DEFAULT_BENEFIT_UOM          =>NULL,
 P_CONTRIBUTIONS_USED           =>NULL,
 P_THIRD_PARTY_PAY_ONLY_FLAG    =>p_third_party_pay_only,
 P_RETRO_SUMM_ELE_ID            =>p_retro_summ_ele_id,
 P_ITERATIVE_FLAG               =>p_iterative_flag,
 P_ITERATIVE_FORMULA_ID         =>p_iterative_formula_id,
 P_ITERATIVE_PRIORITY           =>p_iterative_priority,
 P_PROCESS_MODE                 =>p_process_mode,
 P_GROSSUP_FLAG                 =>p_grossup_flag,
 P_ADVANCE_INDICATOR            =>p_advance_indicator,
 P_ADVANCE_PAYABLE              =>p_advance_payable,
 P_ADVANCE_DEDUCTION            =>p_advance_deduction,
 P_PROCESS_ADVANCE_ENTRY        =>p_process_advance_entry,
 P_PRORATION_GROUP_ID           =>p_proration_group_id,
 P_PRORATION_FORMULA_ID         =>p_proration_formula_id,
 P_RECALC_EVENT_GROUP_ID        =>p_recalc_event_group_id,
 P_ONCE_EACH_PERIOD_FLAG        =>p_once_each_period_flag
);
--
 -- Create the application ownership for the element (in startup mode)
 if v_mode <> 'USER' then
--
   if g_debug then
      hr_utility.set_location('pay_db_pay_setup.create_element',8);
   end if;
--
   insert into hr_application_ownerships
   (KEY_NAME,
    PRODUCT_NAME,
    KEY_VALUE)
   values
   ('ELEMENT_TYPE_ID',
    'PER',
    v_element_type_id);
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element',9);
 end if;
--
 -- Create a PAY_VALUE and status processing rule if it is a payroll element
 hr_elements.ins_3p_element_type(v_element_type_id,
                                 p_process_in_run_flag,
                                 v_legislation_code,
                                 v_business_group_id,
                                 v_classification_id,
                                 v_non_payments_flag,
                                 v_effective_start_date,
                                 v_effective_end_date,
                                 v_mode);
--
 return v_element_type_id;
--
end create_element;
--.
 ---------------------------- create_input_value -----------------------------
 /*
 NAME
   create_input_value
 DESCRIPTION
   This is a function that creates an input value for an element according to
   the parameters passed to it.
 NOTES
   If the input value is a PAY_VALUE then balance feeds fed by the same
   classification as that of the element will be created.
 */
--
FUNCTION create_input_value(p_element_name           varchar2,
                            p_name                   varchar2,
                            p_uom                    varchar2 default null,
                            p_uom_code               varchar2 default null,
                            p_mandatory_flag         varchar2 default 'N',
                            p_generate_db_item_flag  varchar2 default 'N',
                            p_default_value          varchar2 default NULL,
                            p_min_value              varchar2 default NULL,
                            p_max_value              varchar2 default NULL,
                            p_warning_or_error       varchar2 default NULL,
                            p_warn_or_error_code     varchar2 default NULL,
                            p_lookup_type            varchar2 default NULL,
                            p_formula_id             number   default NULL,
                            p_hot_default_flag       varchar2 default 'N',
                            p_display_sequence       number,
                            p_business_group_name    varchar2 default NULL,
                            p_effective_start_date   date     default NULL,
                            p_effective_end_date     date     default NULL,
                            p_legislation_code       varchar2 default NULL)
                                                               RETURN number is
--..
 -- Constants
 v_end_of_time           constant date := to_date('31/12/4712','DD/MM/YYYY');
 v_todays_date           constant date := trunc(sysdate);
--
 -- Local variables
 v_ele_name          VARCHAR2(80);
 v_input_value_id        number;
 v_element_type_id       number;
 v_element_start_date    date;
 v_element_end_date      date;
 v_business_group_id     number;
 v_legislation_code      varchar2(240);
 v_legislation_subgroup  varchar2(240);
 v_session_date          date;
 v_effective_start_date  date;
 v_effective_end_date    date;
 v_uom                   varchar2(240);
 v_jurisdiction          pay_input_values_f.name%TYPE;
 v_warning_or_error      varchar2(240);
 v_rowid                 VARCHAR2(240);
 v_base_language         varchar2(240);
--
 cursor c_installed_language is
   select l.language_code
   from   fnd_languages l
   where  l.installed_flag in ('I', 'B');
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',1);
    hr_utility.trace('p_element_name**********:   '||p_element_name);
    hr_utility.trace('p_name**********:   '||p_name);
 end if;
--
 -- Select the sequence number for input value. This can then be passed back
 -- via the function for later use.
 select pay_input_values_s.nextval
 into   v_input_value_id
 from   dual;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',15);
 end if;
--
 select l.language_code
 into  v_base_language
 from  fnd_languages l
 where l.installed_flag = 'B';
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',2);
 end if;
--
 -- Find the business_group_id for the business group
 -- Also, take opportunity to select legislation code.
 -- Note: Although this procedure allows the business
 -- group to be null when passed in, this does not
 -- really make sense, as we need to be able to use
 -- the business group to evaluate the leg code.
 if p_business_group_name is not NULL then
--
   select bg.business_group_id
   into   v_business_group_id
   from   per_business_groups bg
   where  bg.name = p_business_group_name;
 end if;
--
  -- Ignore the comment above and set the legislation code
  -- independantly.
    v_legislation_code :=  p_legislation_code;
--
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',3);
 end if;
--
 -- Get warning or error flag
 -- Bug 2831667 - either code or meaning must be provided
 --
 if (p_warning_or_error is not null and p_warn_or_error_code is not null) then
   hr_utility.set_message(801, 'HR_BAD_WARN_ERROR_ARGUMENT');
   hr_utility.raise_error;
 end if;
 --
 if p_warning_or_error is not null then
   if g_debug then
     hr_utility.set_location('pay_db_pay_setup.create_input_value',5);
   end if;
--
   select lookup_code
   into   v_warning_or_error
   from   hr_lookups
   where  lookup_type = 'WARNING_ERROR'
     and  upper(meaning) = upper(p_warning_or_error);
   --
 elsif p_warn_or_error_code is not null then
     select lookup_code
     into   v_warning_or_error
     from   hr_lookups
    where   lookup_type = 'WARNING_ERROR'
      and   lookup_code = p_warn_or_error_code;
 end if;
--
 -- Get the uom code: either code or meaning must be provided
 if (p_uom is null and p_uom_code is null)
 or (p_uom is not null and p_uom_code is not null) then
    hr_utility.set_message(801, 'HR_BAD_UOM_ARGUMENT');
    hr_utility.raise_error;
 end if;
--
 if p_uom_code is null then
    if g_debug then
       hr_utility.set_location('pay_db_pay_setup.create_input_value',8);
    end if;
    select lookup_code
    into   v_uom
    from   hr_lookups
    where  lookup_type = 'UNITS'
      and  upper(meaning) = upper(p_uom);
 else
   begin
      select lookup_code
      into   v_uom
      from   hr_lookups
      where  lookup_code = p_uom_code
      and    lookup_type = 'UNITS';
   exception
      when no_data_found then
         hr_utility.set_message(801, 'HR_BAD_UOM_ARGUMENT');
         hr_utility.raise_error;
   end;
 end if;
--
 begin
   -- Get the session date nb. this is defaulted to todays date
   select ss.effective_date
   into   v_session_date
   from   fnd_sessions ss
   where  ss.session_id = userenv('sessionid');
 exception
   when NO_DATA_FOUND then NULL;
 end;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',6);
 end if;
--
 -- Store the dates over which time the element type exists
if v_business_group_id is not NULL then
   select element_name
   into v_ele_name
   from pay_element_types_f
   where element_name = p_element_name
   and (business_group_id = v_business_group_id OR
    (business_group_id is NULL and legislation_code = p_legislation_code))
   and v_session_date between effective_start_date and
                effective_end_date;  /* new bug 1576000 */
else
   select element_name
   into v_ele_name
   from pay_element_types_f
   where element_name = p_element_name
   and   legislation_code = p_legislation_code
   and v_session_date between effective_start_date and
                effective_end_date;  /*  new bug 1576000 */
end if;

 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',65);
    hr_utility.trace('p_element_name*******:  '||p_element_name);
    hr_utility.trace('v_business_group_id*******:  '||v_business_group_id);
    hr_utility.trace('v_legislation_code*******:  '||v_legislation_code);
 end if;

 select min(et.effective_start_date),
        max(et.effective_end_date),
        et.legislation_subgroup,
        et.element_type_id
 into   v_element_start_date,
        v_element_end_date,
        v_legislation_subgroup,
        v_element_type_id
 from   pay_element_types_f et
 where  upper(et.element_name) = upper(p_element_name)
   and  (et.business_group_id + 0 = v_business_group_id
      or  (et.business_group_id is null
        and et.legislation_code = v_legislation_code)
      or  (et.business_group_id is null and et.legislation_code is null))
 group by et.legislation_subgroup, et.element_type_id;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',68);
 end if;
 -- Default the start date to the session date if no date is supplied
 if p_effective_start_date is not NULL then
   v_effective_start_date := p_effective_start_date;
   v_session_date := p_effective_start_date;
   elsif v_session_date is not NULL then
     v_effective_start_date := v_session_date;
     else
       v_effective_start_date := trunc(sysdate);
       v_session_date := trunc(sysdate);
 end if;
--
 -- Default the effective end date to the end of time  if it is not specified
 if p_effective_end_date is NULL then
   v_effective_end_date := v_end_of_time;
   else
     v_effective_end_date := p_effective_end_date;
 end if;
--
 -- If the start date before the start of the element then set the start date
 -- to that of the element
 if v_effective_start_date < v_element_start_date then
   v_effective_start_date := v_element_start_date;
 end if;
--
 -- If the end date is after the end of the element then set the end date to
 -- that of the element
 if v_effective_end_date > v_element_end_date then
   v_effective_end_date := v_element_end_date;
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_input_value',7);
 end if;
--
 -- Create input value
 --
 insert into pay_input_values_f
 (INPUT_VALUE_ID,
  EFFECTIVE_START_DATE,
  EFFECTIVE_END_DATE,
  ELEMENT_TYPE_ID,
  LOOKUP_TYPE,
  BUSINESS_GROUP_ID,
  LEGISLATION_CODE,
  FORMULA_ID,
  DISPLAY_SEQUENCE,
  GENERATE_DB_ITEMS_FLAG,
  HOT_DEFAULT_FLAG,
  MANDATORY_FLAG,
  NAME,
  UOM,
  DEFAULT_VALUE,
  LEGISLATION_SUBGROUP,
  MAX_VALUE,
  MIN_VALUE,
  WARNING_OR_ERROR,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE)
 values
 (v_input_value_id,
  v_effective_start_date,
  v_effective_end_date,
  v_element_type_id,
  p_lookup_type,
  v_business_group_id,
  v_legislation_code,
  p_formula_id,
  p_display_sequence,
  p_generate_db_item_flag,
  p_hot_default_flag,
  p_mandatory_flag,
  p_name,
  v_uom,
  p_default_value,
  v_legislation_subgroup,
  p_max_value,
  p_min_value,
  v_warning_or_error,
  v_todays_date,
  -1,
  -1,
  -1,
  v_todays_date);
--
  for lang_rec in c_installed_language loop
--
    hr_utility.set_location('pay_db_pay_setup.create_input_value',9);
    hr_utility.trace('v_input_value_id**********:   '||v_input_value_id);
    hr_utility.trace('p_name**********:   '||p_name);

                begin
      select nvl(description, meaning)
                                into v_jurisdiction
      from fnd_lookup_values
      where lookup_type = 'NAME_TRANSLATIONS'
      and upper(p_name) like lookup_code
      and language = lang_rec.language_code
      and rownum = 1;

                        hr_utility.trace('v_jurisdiction**********:   '||v_jurisdiction);
                exception
                when others then
                        v_jurisdiction := p_name;
                end;
                        hr_utility.trace('v_jurisdiction@@@@@@@@@@:   '||v_jurisdiction);

--
    insert into pay_input_values_f_tl
    (INPUT_VALUE_ID,
     NAME,
     LANGUAGE,
     SOURCE_LANG,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     CREATED_BY,
     CREATION_DATE)
    values
    (v_input_value_id,
     v_jurisdiction,
     lang_rec.language_code,
     v_base_language,
     v_todays_date,
     -1,
     -1,
     -1,
     v_todays_date);
  end loop;
--
 return v_input_value_id;
--
end create_input_value;
--.
 -------------------------------- create_payroll -----------------------------
 /*
 NAME
   create_payroll
 DESCRIPTION
   This function creates a payroll and passes back the payroll_id for future
   reference.
 NOTES
   On creation it will create a calendar for the payroll.
 */
--
FUNCTION create_payroll(p_payroll_name               varchar2,
                        p_number_of_years            number,
                        p_period_type                varchar2,
                        p_first_period_end_date      date,
                        p_dflt_payment_method        varchar2 default NULL,
                        p_pay_date_offset            number   default 0,
                        p_direct_deposit_date_offset number   default 0,
                        p_pay_advice_date_offset     number   default 0,
                        p_cut_off_date_offset        number   default 0,
                        p_consolidation_set_name     varchar2,
                        p_negative_pay_allowed_flag  varchar2 default 'N',
                        p_organization_name          varchar2 default NULL,
                        p_midpoint_offset            number   default 0,
                        p_workload_shifting_level    varchar2 default 'N',
                        p_cost_all_keyflex_id        number   default NULL,
                        p_gl_set_of_books_id         number   default NULL,
                        p_soft_coding_keyflex_id     number   default NULL,
                        p_effective_start_date       date     default NULL,
                        p_effective_end_date         date     default NULL,
                        p_business_group_name        varchar2)
                                                           RETURN number is
--..
 -- Constants
 v_end_of_time           constant date := to_date('31/12/4712','DD/MM/YYYY');
 v_todays_date           constant date := trunc(sysdate);
--
 -- Local Variables
 v_payroll_id               number;
 v_session_date             date;
 v_business_group_id        number;
 v_legislation_code         varchar2(30);
 v_dflt_payment_method_id   number;
 v_consolidation_set_id     number;
 v_organization_id          number;
 v_effective_start_date     date;
 v_effective_end_date       date;
 v_currency_code            varchar2(30);
 v_org_pay_method_usage     number;
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_payroll',1);
 end if;
--
 -- Select the sequence number for the payroll. This can then be passed back
 -- via the function for later use.
 select pay_payrolls_s.nextval
 into   v_payroll_id
 from   sys.dual;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_payroll',2);
 end if;
--
 begin
   -- Get the session date nb. this is defaulted to todays date
   select ss.effective_date
   into   v_session_date
   from   fnd_sessions ss
   where  ss.session_id = userenv('sessionid');
 exception
   when NO_DATA_FOUND then NULL;
 end;
--
 -- Default the start date to the session date if no date is supplied
 if p_effective_start_date is not NULL then
   v_effective_start_date := p_effective_start_date;
   v_session_date := p_effective_start_date;
   elsif v_session_date is not NULL then
     v_effective_start_date := v_session_date;
     else
       v_effective_start_date := trunc(sysdate);
       v_session_date := trunc(sysdate);
 end if;
--
 -- Default the end date to the end of time if no date is supplied
 if p_effective_end_date is NULL then
   v_effective_end_date := v_end_of_time;
   else
     v_effective_end_date := p_effective_end_date;
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_payroll',3);
 end if;
--
 -- Find the business_group_id for the business group and get the currency of
 -- business group for potential defaulting of input and output currency
 select bg.business_group_id,
        bg.legislation_code,
        bg.currency_code
 into   v_business_group_id,
        v_legislation_code,
        v_currency_code
 from   per_business_groups bg
 where  name = p_business_group_name;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_payroll',4);
 end if;
--
 -- Find the organization_id for the organization. If it is not specified then
 -- default it to the business group
 if p_organization_name is not NULL then
--
   select org.organization_id
   into   v_organization_id
   from   hr_all_organization_units org
   where  upper(org.name) = upper(p_organization_name)
     and  org.business_group_id + 0 = v_business_group_id;
--
   else
--
     v_organization_id := v_business_group_id;
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_payroll',5);
 end if;
--
 -- Get the consolidation_set_id for the specified consolidation set
 select cs.consolidation_set_id
 into   v_consolidation_set_id
 from   pay_consolidation_sets cs
 where  upper(cs.consolidation_set_name) = upper(p_consolidation_set_name)
   and  cs.business_group_id + 0 = v_business_group_id;
--
-- Do not need to specify a default payment method when
-- when the payroll is defined. This we only perform
-- following select if one is specified.
if p_dflt_payment_method is not null then
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_payroll',6);
 end if;
 select opm.org_payment_method_id
 into   v_dflt_payment_method_id
 from   pay_payment_types ppt,
        pay_org_payment_methods_f opm
 where  upper(opm.org_payment_method_name) = upper(p_dflt_payment_method)
 and    opm.business_group_id + 0 = v_business_group_id
 and    opm.payment_type_id = ppt.payment_type_id
 and    ppt.allow_as_default = 'Y'
 and    v_session_date between opm.effective_start_date
                               and opm.effective_end_date;
else
 v_dflt_payment_method_id := null;
end if;
--
 -- Create payroll
 insert into pay_payrolls_f
 (PAYROLL_ID,
  EFFECTIVE_START_DATE,
  EFFECTIVE_END_DATE,
  DEFAULT_PAYMENT_METHOD_ID,
  BUSINESS_GROUP_ID,
  CONSOLIDATION_SET_ID,
  ORGANIZATION_ID,
  COST_ALLOCATION_KEYFLEX_ID,
  GL_SET_OF_BOOKS_ID,
  SOFT_CODING_KEYFLEX_ID,
  PERIOD_TYPE,
  CUT_OFF_DATE_OFFSET,
  DIRECT_DEPOSIT_DATE_OFFSET,
  FIRST_PERIOD_END_DATE,
  MIDPOINT_OFFSET,
  NEGATIVE_PAY_ALLOWED_FLAG,
  NUMBER_OF_YEARS,
  PAY_ADVICE_DATE_OFFSET,
  PAY_DATE_OFFSET,
  PAYROLL_NAME,
  WORKLOAD_SHIFTING_LEVEL,
  COMMENT_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE)
 values
 (v_payroll_id,
  v_effective_start_date,
  v_effective_end_date,
  v_dflt_payment_method_id,
  v_business_group_id,
  v_consolidation_set_id,
  v_organization_id,
  p_cost_all_keyflex_id,
  p_gl_set_of_books_id,
  p_soft_coding_keyflex_id,
  p_period_type,
  p_cut_off_date_offset,
  p_direct_deposit_date_offset,
  p_first_period_end_date,
  p_midpoint_offset,
  p_negative_pay_allowed_flag,
  p_number_of_years,
  p_pay_advice_date_offset,
  p_pay_date_offset,
  p_payroll_name,
  p_workload_shifting_level,
  NULL,                            -- Ignore Comments.
  v_todays_date,
  -1,
  -1,
  -1,
  v_todays_date);
--
 -- CREATE TIME PERIODS
 hr_payrolls.create_payroll_proc_periods(v_payroll_id,
                                         v_todays_date,
                                         -1,
                                         -1,
                                         -1,
                                         v_todays_date);
--
 -- If have specified a default payment method, we need
 -- to create a org payment method usage for it.
 if p_dflt_payment_method is not null then
 --
 -- The payroll has a default method of v_dflt_payment_method.  Now need to
 -- insert an org_pay_method_usage for this payroll and method.
 -- NB Date effective between v_effective_start_date and v_effective_end_date.
 --
 v_org_pay_method_usage := hr_ppvol.ins_pmu(v_effective_start_date,
                                            v_effective_end_date,
                                            v_payroll_id,
                                            v_dflt_payment_method_id);
 end if;
--
 return v_payroll_id;
--
end create_payroll;
--.
 ---------------------------- create_consoldation_set ------------------------
 /*
 NAME
   create_consoldation_set
 DESCRIPTION
   This function creates a consolidation set and passes back the
   consolidation_set_id for future use.
 NOTES
 */
--
FUNCTION create_consolidation_set(p_consolidation_set_name  varchar2,
                                  p_business_group_name     varchar2)
                                                              RETURN number is
--..
 -- Constants
 v_todays_date           constant date := trunc(sysdate);
--
 -- Local Variables
 v_consolidation_set_id    number;
 v_business_group_id       number;
--
begin
--
 -- Select the sequence number for the consolidation set. This can then be
 -- passed back via the function for later use. Get the business_group_id for
 -- the business group.
 select pay_consolidation_sets_s.nextval,
        business_group_id
 into   v_consolidation_set_id,
        v_business_group_id
 from   per_business_groups
 where  name = p_business_group_name;
--
 insert into pay_consolidation_sets
 (CONSOLIDATION_SET_ID,
  BUSINESS_GROUP_ID,
  CONSOLIDATION_SET_NAME,
  COMMENTS,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE)
 values
 (v_consolidation_set_id,
  v_business_group_id,
  p_consolidation_set_name,
  NULL,                           -- Ignore Comments
  v_todays_date,
  -1,
  -1,
  -1,
  v_todays_date);
--
 return v_consolidation_set_id;
--
end create_consolidation_set;
--.
 -------------------------- create_owner_definitions --------------------------
 /*
 NAME
   create_owner_definitions
 DESCRIPTION
   This procedure populates the product name for the current session into the
   owner defintions table. This mis used when creating startup data to
   identify which products the data is for.
 NOTES
 */
--
PROCEDURE create_owner_definitions(p_app_short_name  varchar2) is
--..
begin
--
 -- Create a row for the current session for the product specified. This is
 -- used to populate application ownerships when startup data is created.
 insert into hr_owner_definitions
 (PRODUCT_SHORT_NAME,
  SESSION_ID)
 select
  p_app_short_name,
  userenv('sessionid')
 from  sys.dual
 where not exists (select 1
                   from   hr_owner_definitions od
                   where  od.product_short_name = p_app_short_name
                     and  session_id = userenv('sessionid'));
--
end create_owner_definitions;
--.
 -------------------------- set_session_dates ---------------------------------
 /*
 NAME
   set_session_date
 DESCRIPTION
   Sets the session date for use in creating date tracked information
 NOTES
 */
--
PROCEDURE set_session_date(p_session_date  date) is
--..
begin
--
   delete from fnd_sessions where session_id = userenv('sessionid');
--
   insert into fnd_sessions
   (SESSION_ID,
    EFFECTIVE_DATE)
   values
   (userenv('sessionid'),
    p_session_date);
--
end set_session_date;
--.
 -------------------------- create_element_link -------------------------------
 /*
 NAME
   create_element_link
 DESCRIPTION
   This procedure creates sn element link for an element type.
 NOTES
 */
--
FUNCTION create_element_link(p_payroll_name          varchar2 default NULL,
                             p_job_name              varchar2 default NULL,
                             p_position_name         varchar2 default NULL,
                             p_people_group_name     varchar2 default NULL,
                             p_cost_all_keyflex_id   number   default NULL,
                             p_organization_name     varchar2 default NULL,
                             p_element_name          varchar2,
                             p_location_id           number   default NULL,
                             p_grade_name            varchar2 default NULL,
                             p_balancing_keyflex_id  number   default NULL,
                             p_element_set_id        number   default NULL,
                             p_costable_type         varchar2 default 'N',
                             p_link_to_all_pyrlls_fl varchar2 default 'N',
                             p_multiply_value_flag   varchar2 default 'N',
                             p_standard_link_flag    varchar2 default NULL,
                             p_transfer_to_gl_flag   varchar2 default 'N',
                             p_qual_age              number   default NULL,
                             p_qual_lngth_of_service number   default NULL,
                             p_qual_units            varchar2 default NULL,
                             p_effective_start_date  date     default NULL,
                             p_effective_end_date    date     default NULL,
                             p_business_group_name   varchar2)
                                                            RETURN number is
--..
 -- Constants
 v_start_of_time            constant date := to_date('01/01/0001','DD/MM/YYYY');
 v_end_of_time              constant date := to_date('31/12/4712','DD/MM/YYYY');
 v_todays_date              constant date := trunc(sysdate);
--
 -- Local variables
 v_business_group_id        number;
 v_element_link_id          number;
 v_session_date             date;
 v_effective_start_date     date;
 v_effective_end_date       date;
 v_element_type_id          number;
 v_element_start_date       date;
 v_element_end_date         date;
 v_el_standard_link_flag    varchar2(30);
 v_el_multiply_value_flag   varchar2(30);
 v_el_qual_age              number;
 v_el_qual_lngth_of_service number;
 v_el_qual_units            varchar2(30);
 v_payroll_id               number;
 v_payroll_end_date         date := v_end_of_time;
 v_job_id                   number;
 v_position_id              number;
 v_grade_id                 number;
 v_people_group_id          number;
 v_organization_id          number;
 v_pay_value_name           varchar2(80);
 v_legislation_code         varchar2(30);
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',1);
 end if;
--
 -- Get business group id. Select the sequence number for the element link.
 -- This can then be passed back via the function for later use.
 select pay_element_links_s.nextval,
        bg.business_group_id,
        bg.legislation_code
 into   v_element_link_id,
        v_business_group_id,
        v_legislation_code
 from   per_business_groups bg
 where  name = p_business_group_name;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',2);
 end if;
--
 -- Get look up name for 'PAY VALUE'
 v_pay_value_name := hr_input_values.get_pay_value_name(v_legislation_code);
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',3);
 end if;
--
 begin
   -- Get the session date nb. this is defaulted to todays date
   select ss.effective_date
   into   v_session_date
   from   fnd_sessions ss
   where  ss.session_id = userenv('sessionid');
 exception
   when NO_DATA_FOUND then NULL;
 end;
--
 -- Default the start date to the session date if no date is supplied
 if p_effective_start_date is not NULL then
   v_effective_start_date := p_effective_start_date;
   v_session_date := p_effective_start_date;
   elsif v_session_date is not NULL then
     v_effective_start_date := v_session_date;
     else
       v_effective_start_date := trunc(sysdate);
       v_session_date := trunc(sysdate);
 end if;
--
 -- Default the end date to the end of time if no date is supplied
 if p_effective_end_date is NULL then
   v_effective_end_date := v_end_of_time;
   else
     v_effective_end_date := p_effective_end_date;
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',4);
 end if;
--
 -- Get information from element for defaulting
 select max(et.effective_end_date),
        et.element_type_id,
        et.standard_link_flag,
        et.multiply_value_flag,
        et.qualifying_age,
        et.qualifying_length_of_service,
        et.qualifying_units
 into   v_element_end_date,
        v_element_type_id,
        v_el_standard_link_flag,
        v_el_multiply_value_flag,
        v_el_qual_age,
        v_el_qual_lngth_of_service,
        v_el_qual_units
 from   pay_element_types_f et
 where  upper(et.element_name) = upper(p_element_name)
   and  (et.business_group_id + 0 = v_business_group_id
      or  (et.business_group_id is null
        and et.legislation_code = v_legislation_code)
      or  (et.business_group_id is null and et.legislation_code is null))
 group by et.element_type_id, et.standard_link_flag, et.multiply_value_flag,
          et.qualifying_age, et.qualifying_length_of_service,
          et.qualifying_units;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',5);
 end if;
--
 -- Find Job if it is specified
 if p_job_name is not NULL then
--
   select jb.job_id
   into   v_job_id
   from   per_jobs_vl jb
   where  upper(jb.name) = upper(p_job_name)
     and  jb.business_group_id  = v_business_group_id
     and  v_effective_start_date between jb.date_from
                                     and nvl(jb.date_to,v_end_of_time);
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',6);
 end if;
--
 -- Find Position if it is specified
 if p_position_name is not NULL then
--
   select po.position_id
   into   v_position_id
   from   per_positions po
   where  upper(po.name) = upper(p_position_name)
     and  po.business_group_id + 0 = v_business_group_id
     and  v_effective_start_date between po.date_effective
                                     and nvl(po.date_end,v_end_of_time);
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',7);
 end if;
--
 -- Find Grade if it is specified
 if p_grade_name is not NULL then
--
   select gr.grade_id
   into   v_grade_id
   from   per_grades_vl gr
   where  upper(gr.name) = upper(p_grade_name)
     and  gr.business_group_id + 0 = v_business_group_id
     and  v_effective_start_date between gr.date_from
                                     and nvl(gr.date_to,v_end_of_time);
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',8);
 end if;
--
 -- Find People Group if it is specified
 if p_people_group_name is not NULL then
--
   select pg.people_group_id
   into   v_people_group_id
   from   pay_people_groups pg
   where  upper(pg.group_name) = upper(p_people_group_name)
     and  v_effective_start_date
               between nvl(pg.start_date_active, v_start_of_time)
                   and nvl(pg.end_date_active,v_end_of_time);
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',9);
 end if;
--
 -- Find Organization if it is specified
 if p_organization_name is not NULL then
--
   select org.organization_id
   into   v_organization_id
   from   per_organization_units org
   where  upper(org.name) = upper(p_organization_name)
     and  org.business_group_id + 0 = v_business_group_id
     and  v_effective_start_date between org.date_from
                                     and nvl(org.date_to,v_end_of_time);
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_element_link',10);
 end if;
--
 -- Find Payroll if it is specified
 if p_payroll_name is not NULL then
--
   select pa.payroll_id,
          max(pa.effective_end_date)
   into   v_payroll_id,
          v_payroll_end_date
   from   pay_all_payrolls_f pa
   where  upper(pa.payroll_name) = upper(p_payroll_name)
     and  pa.business_group_id + 0 = v_business_group_id
     and  pa.effective_start_date <= v_effective_end_date
     and  pa.effective_end_date >= v_effective_start_date
   group by payroll_id;
--
 end if;
--
 -- Check for mutual exclusivity
--
 -- Create element link
 insert into pay_element_links_f
 (ELEMENT_LINK_ID,
  EFFECTIVE_START_DATE,
  EFFECTIVE_END_DATE,
  PAYROLL_ID,
  JOB_ID,
  POSITION_ID,
  PEOPLE_GROUP_ID,
  COST_ALLOCATION_KEYFLEX_ID,
  ORGANIZATION_ID,
  ELEMENT_TYPE_ID,
  LOCATION_ID,
  GRADE_ID,
  BALANCING_KEYFLEX_ID,
  BUSINESS_GROUP_ID,
  ELEMENT_SET_ID,
  COSTABLE_TYPE,
  LINK_TO_ALL_PAYROLLS_FLAG,
  MULTIPLY_VALUE_FLAG,
  STANDARD_LINK_FLAG,
  TRANSFER_TO_GL_FLAG,
  COMMENT_ID,
  QUALIFYING_AGE,
  QUALIFYING_LENGTH_OF_SERVICE,
  QUALIFYING_UNITS,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE)
 values
 (v_element_link_id,
  v_effective_start_date,
  least(v_payroll_end_date, v_element_end_date, v_effective_end_date),
  v_payroll_id,
  v_job_id,
  v_position_id,
  v_people_group_id,
  p_cost_all_keyflex_id,
  v_organization_id,
  v_element_type_id,
  p_location_id,
  v_grade_id,
  p_balancing_keyflex_id,
  v_business_group_id,
  NULL,                               -- Do not worry about distribution set
  p_costable_type,
  p_link_to_all_pyrlls_fl,
  nvl(p_multiply_value_flag,v_el_multiply_value_flag),
  nvl(p_standard_link_flag,v_el_standard_link_flag),
  p_transfer_to_gl_flag,
  NULL,                               -- Do not worry about comments
  nvl(p_qual_age,v_el_qual_age),
  nvl(p_qual_lngth_of_service,v_el_qual_lngth_of_service),
  nvl(p_qual_units,v_el_qual_units),
  v_todays_date,
  -1,
  -1,
  -1,
  v_todays_date);
--
 -- CREATE LINK INPUT VALUES
 hr_input_values.create_link_input_value('INSERT_LINK',
                                         v_element_link_id,
                                         NULL,
                                         NULL,
                                         p_costable_type,
                                         v_effective_start_date,
                                         least(v_payroll_end_date,
                                               v_element_end_date,
                                               v_effective_end_date),
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         v_pay_value_name,
                                         v_element_type_id);
--
 return v_element_link_id;
--
end create_element_link;
--
---------------------------------------------------------------------------
-- PROCEDURE insert_primary_balance_feed
---------------------------------------------------------------------------
PROCEDURE insert_primary_balance_feed(p_balance_type_id    number
                                     ,p_primary_bal_iv_id  number
                                     ,p_primary_bal_ele_id number
                                     ,p_business_group_id  number
                                     ,p_legislation_code   varchar2
                                     ,p_effective_date     date
                                     ,p_mode               varchar2)


IS
--
  cursor feed_exists(p_bal_id number
                    ,p_iv_id number
                    ,p_bg_id number
                    ,p_leg   varchar2
                    ,p_eff_date date)
  is
  select null
  from   pay_balance_feeds_f pbf
  where  pbf.balance_type_id = p_bal_id
  and    pbf.input_value_id = p_iv_id
  and    nvl(pbf.business_group_id, -1) = nvl(p_bg_id, -1)
  and    nvl(pbf.legislation_code, 'NULL') = nvl(p_leg, 'NULL')
  and    p_eff_date between pbf.effective_start_date
                        and pbf.effective_end_date;
  l_exists number;
  l_mode varchar2(30);
  BEGIN
    open  feed_exists(p_balance_type_id
                     ,p_primary_bal_iv_id
                     ,p_business_group_id
                     ,p_legislation_code
                     ,p_effective_date);
    fetch feed_exists into l_exists;
    if feed_exists%notfound then
      close feed_exists;
      --
      hr_balances.ins_balance_feed
        (p_option                     => 'INS_PRIMARY_BALANCE_FEED'
        ,p_input_value_id             => p_primary_bal_iv_id
        ,p_element_type_id            => p_primary_bal_ele_id
        ,p_primary_classification_id  => ''
        ,p_sub_classification_id      => ''
        ,p_sub_classification_rule_id => ''
        ,p_balance_type_id            => p_balance_type_id
        ,p_scale                      => 1
        ,p_session_date               => p_effective_date
        ,p_business_group             => p_business_group_id
        ,p_legislation_code           => p_legislation_code
        ,p_mode                       => p_mode
        );
    else
      close feed_exists;
    end if;
  END Insert_primary_balance_feed;
 --------------------------- create_balance_type ------------------------------
 /*
 NAME
   create_balance_type
 DESCRIPTION
   Creates a new balance.
 NOTES
 */
--
FUNCTION create_balance_type(p_balance_name          varchar2,
                             p_uom                   varchar2,
                             p_uom_code              varchar2 default NULL,
                             p_ass_remuneration_flag varchar2 default 'N',
                             p_currency_code         varchar2 default NULL,
                             p_reporting_name        varchar2 default NULL,
                             p_business_group_name   varchar2 default NULL,
                             p_legislation_code      varchar2 default NULL,
                             p_legislation_subgroup  varchar2 default NULL,
                             p_balance_category      varchar2 default null,
                             p_bc_leg_code           varchar2 default null,
                             p_effective_date        date     default null,
                             p_base_balance_name     varchar2 default null,
                             p_primary_element_name  varchar2 default null,
                             p_primary_iv_name       varchar2 default null)
                                                              RETURN number is
--
cursor get_cat_id(p_cat_name varchar2
                 ,p_cat_leg  varchar2
                 ,p_eff_date date
                 )
is
select balance_category_id
,      business_group_id
from   pay_balance_categories_f cat
where  category_name = p_cat_name
and    nvl(legislation_code,'NULL') = nvl(p_cat_leg, 'NULL')
and    p_eff_date between cat.effective_start_date
                      and cat.effective_end_date;
--
cursor get_bg_leg(p_bg_name varchar2)
is
select legislation_code
from   per_business_groups
where  name = p_bg_name;
--
cursor get_base_balance(p_base_bal_name varchar2
                       ,p_ctl_bg        number
                       ,p_ctl_leg       varchar2)
is
select balance_type_id
,      base_balance_type_id
from   pay_balance_types
where  balance_name = p_base_bal_name
and    nvl(business_group_id, nvl(p_ctl_bg, -1)) = nvl(p_ctl_bg, -1)
and    nvl(legislation_code, nvl(p_ctl_leg, ' ')) = nvl(p_ctl_leg, ' ');
--
cursor get_primary_iv(p_prim_ele varchar2
                     ,p_prim_iv  varchar2
                     ,p_eff_date date
                     ,p_bal_uom  varchar2
                     ,p_ctl_bg   number
                     ,p_ctl_leg  varchar2)
is
select piv.input_value_id
,      pet.element_type_id
from   pay_input_values_f piv
,      pay_element_types_f pet
,      pay_input_values_f_tl pivtl
,      pay_element_types_f_tl pettl
where  piv.input_value_id = pivtl.input_value_id
and    pivtl.language = userenv('LANG')
and    pivtl.name = p_prim_iv
and    pet.element_type_id = pettl.element_type_id
and    pettl.language = userenv('LANG')
and    pettl.element_name = p_prim_ele
and    piv.element_type_id = pet.element_type_id
and    p_eff_date between piv.effective_start_date
                      and piv.effective_end_date
and    p_eff_date between pet.effective_start_date
                      and pet.effective_end_date
and    piv.uom = p_bal_uom
and    nvl(pet.business_group_id, nvl(p_ctl_bg, -1)) = nvl(p_ctl_bg, -1)
and    nvl(pet.legislation_code, nvl(p_ctl_leg, ' ')) = nvl(p_ctl_leg, ' ');


--
 -- Constants
 v_todays_date           constant date := trunc(sysdate);
--
 -- Local variables
 v_balance_type_id       number;
 v_business_group_id     number;
 v_currency_code         varchar2(30);
 v_uom                   varchar2(80);
 v_money                 VARCHAR2(80);
 v_rowid                 VARCHAR2(100);
 v_leg_code              varchar2(30);
 l_bal_cat_id pay_balance_categories_f.balance_category_id%type default null;
 l_cat_bg     pay_balance_categories_f.business_group_id%type;
 v_legislation_code      varchar2(30);
 l_ctl_bg     number;
 l_ctl_leg    varchar2(30);
 l_bt_id      pay_balance_types.balance_type_id%type;
 l_bbt_id     pay_balance_types.base_balance_type_id%type;
 l_prim_iv    pay_balance_types.input_value_id%type;
 l_prim_ele   pay_element_types_f.element_type_id%type;
 l_mode       varchar2(30);
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_type',1);
 end if;
--
 -- Find the business_group_id for the business group and get the currency of
 -- business group for potential defaulting of balance currency
 -- RET 07-OCT-2002 - also get the leg for the bg
 if p_business_group_name is not NULL then
--
   if g_debug then
      hr_utility.set_location('pay_db_pay_setup.create_balance_type',2);
   end if;
--
   select business_group_id,
          currency_code,
          legislation_code
   into   v_business_group_id,
          v_currency_code,
          v_legislation_code
   from   per_business_groups
   where  name = p_business_group_name;
--
  --
   -- select the currency for the legislation for potential defaulting
   -- of input and output currency code for startup elements
   elsif p_legislation_code is not NULL then
--
     if g_debug then
        hr_utility.set_location('pay_db_pay_setup.create_balance_type',3);
     end if;
--
     if p_currency_code is null then
--
       v_currency_code := get_default_currency
                            (p_legislation_code => p_legislation_code);
--
     else
--
       v_currency_code := p_currency_code;
--
     end if;
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_type',4);
 end if;
--
 -- Get the uom code
 if p_uom_code is null then
   select lookup_code,decode(lookup_code,'M',v_currency_code,NULL)
   into   v_uom,v_money
   from   hr_lookups
   where  lookup_type = 'UNITS'
   and  upper(meaning) = upper(p_uom);
 else
   v_uom := p_uom_code;
   if v_uom = 'M' then
     v_money := v_currency_code;
   else
     v_money := NULL;
   end if;
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_type',5);
 end if;
--
-- Check the category
--
if p_balance_category is not null then
  if P_effective_date is null then
  --
  -- a date must be passed through if entering a category
  --
    hr_utility.set_message(801, 'PAY_34262_CAT_EFF_DATE_NULL');
    hr_utility.raise_error;
  end if;
  --
  if p_bc_leg_code is not null then
  --
    open get_cat_id(p_balance_category, p_bc_leg_code, p_effective_date);
    fetch get_cat_id into l_bal_cat_id, l_cat_bg;
    if get_cat_id%notfound then
    --
    -- error category does not exist
    --
      close get_cat_id;
      hr_utility.set_message(801,'PAY_34263_CAT_NOT_EXIST');
      hr_utility.raise_error;
    else
      close get_cat_id;
    end if;
  --
  -- check if this cat can be use with this balance type
  --
    if p_business_group_name is not null then
    --
      open  get_bg_leg(p_business_group_name);
      fetch get_bg_leg into v_leg_code;
      if get_bg_leg%notfound then
        --
        close get_bg_leg;
        hr_utility.set_message(801,'PAY_34264_INV_BG_LEG');
        hr_utility.raise_error;
      else
        close get_bg_leg;
      end if;
    else -- p_business_group_id is null
      v_leg_code := p_legislation_code;
    end if;
    --
    if p_bc_leg_code <> v_leg_code then
    --
    -- leg codes not same, cannot be compatible.
    --
      hr_utility.set_message(801,'PAY_34265_INV_LEG');
      hr_utility.raise_error;
    end if;
  else -- p_bc_leg_code is null - unusual to have generic category, but possible
       -- check that not a user category
    open get_cat_id(p_balance_category, p_bc_leg_code, p_effective_date);
    fetch get_cat_id into l_bal_cat_id, l_cat_bg;
    if get_cat_id%notfound then
    --
    -- error category does not exist
    --
      close get_cat_id;
      hr_utility.set_message(801,'PAY_34266_CAT_NOT_EXIST_G');
      hr_utility.raise_error;
    else
      close get_cat_id;
    end if;
    --
    -- Error if the cat bg is not null, as user categories cannot be created, so
    -- this is a hacked category.
    --
    if l_cat_bg is not null then
      hr_utility.set_message(801,'PAY_34267_INV_CAT_LEG ');
      hr_utility.raise_error;
    end if;
  end if;
end if;
--
-- get and check the base_balance_type_id
--
-- l_ctl_bg and l_ctl_leg are the equivalent to the ctl_globals variables in
-- the form. They are set here by basing the current mode on the values for
-- bg and leg code of the balance being inserted. This enables standard startup
-- table validation, e.g. if inserting a startup balance (leg code not null)
-- then user base balances (bg not null) will be invalid.
-- l_mode is used in the creation of primary balance feed.
--
if p_business_group_name is not null and p_legislation_code is null then
  l_ctl_bg  := v_business_group_id;
  l_ctl_leg := v_legislation_code;
  l_mode    := 'USER';
elsif
   p_business_group_name is null and p_legislation_code is not null then
  l_ctl_bg  := '';
  l_ctl_leg := p_legislation_code;
  l_mode    := 'STARTUP';
else
  l_ctl_bg  := '';
  l_ctl_leg := '';
  l_mode    := 'GENERIC';
end if;
--
if p_base_balance_name is not null then
--
  open  get_base_balance(p_base_balance_name
                        ,l_ctl_bg
                        ,l_ctl_leg);
  fetch get_base_balance into l_bt_id, l_bbt_id;
  if get_base_balance%notfound then
  --
    close get_base_balance;
    hr_utility.set_message(801,'PAY_34268_BASE_BAL_NOT_EXIST');
    hr_utility.raise_error;
  else
    close get_base_balance;
    if l_bbt_id is not null then
    --
    -- raise error as this balance has itself a base balance, so cannot be used
    -- as a base balance.
    --
      hr_utility.set_message(801,'PAY_34269_INV_BASE_BAL');
      hr_utility.raise_error;
    end if;
  end if;
end if;
--
-- get and check the primary balance - this will be an input value.
--
if p_primary_iv_name is not null then
--
  if p_effective_date is null then
  --
  -- a date must be passed in if a primary balance is to be inserted.
  --
    hr_utility.set_message(801,'PAY_34270_PRIM_NULL_EFF_DATE');
    hr_utility.raise_error;
  end if;
--
  open  get_primary_iv(p_primary_element_name
                      ,p_primary_iv_name
                      ,p_effective_date
                      ,v_uom
                      ,l_ctl_bg
                      ,l_ctl_leg
                      );
  fetch get_primary_iv into l_prim_iv, l_prim_ele;
  if get_primary_iv%notfound then
  --
    close get_primary_iv;
    hr_utility.set_message(801,'PAY_34271_INV_PRIM_BAL');
    hr_utility.raise_error;
  else
    close get_primary_iv;
  end if;
end if;
 --
 -- Create balance
 --
 pay_balance_types_pkg.insert_row(
 X_ROWID                        =>v_rowid,
 X_BALANCE_TYPE_ID              =>v_balance_type_id,
 X_BUSINESS_GROUP_ID            =>v_business_group_id,
 X_LEGISLATION_CODE             =>p_legislation_code,
 X_CURRENCY_CODE                =>v_money,
 X_ASSIGNMENT_REMUNERATION_FLAG =>p_ass_remuneration_flag,
 X_BALANCE_NAME                 =>p_balance_name,
 X_BASE_BALANCE_NAME            =>p_balance_name,
 X_BALANCE_UOM                  =>v_uom,
 X_COMMENTS                     =>NULL,
 X_LEGISLATION_SUBGROUP         =>p_legislation_subgroup,
 X_REPORTING_NAME               =>p_reporting_name,
 X_ATTRIBUTE_CATEGORY           =>NULL,
 X_ATTRIBUTE1                   =>NULL,
 X_ATTRIBUTE2                   =>NULL,
 X_ATTRIBUTE3                   =>NULL,
 X_ATTRIBUTE4                   =>NULL,
 X_ATTRIBUTE5                   =>NULL,
 X_ATTRIBUTE6                   =>NULL,
 X_ATTRIBUTE7                   =>NULL,
 X_ATTRIBUTE8                   =>NULL,
 X_ATTRIBUTE9                   =>NULL,
 X_ATTRIBUTE10                  =>NULL,
 X_ATTRIBUTE11                  =>NULL,
 X_ATTRIBUTE12                  =>NULL,
 X_ATTRIBUTE13                  =>NULL,
 X_ATTRIBUTE14                  =>NULL,
 X_ATTRIBUTE15                  =>NULL,
 X_ATTRIBUTE16                  =>NULL,
 X_ATTRIBUTE17                  =>NULL,
 X_ATTRIBUTE18                  =>NULL,
 X_ATTRIBUTE19                  =>NULL,
 X_ATTRIBUTE20                  =>NULL,
 x_balance_category_id          =>l_bal_cat_id,
 x_base_balance_type_id         =>l_bt_id,
 x_input_value_id               =>l_prim_iv);
--
-- create primary balance feed if the primary balance is not null
--
 if p_primary_iv_name is not null then
 --
   insert_primary_balance_feed
   (p_balance_type_id    => v_balance_type_id
   ,p_primary_bal_iv_id  => l_prim_iv
   ,p_primary_bal_ele_id => l_prim_ele
   ,p_business_group_id  => v_business_group_id
   ,p_legislation_code   => v_legislation_code
   ,p_effective_date     => p_effective_date
   ,p_mode               => l_mode
   );
   --
 end if;
 --
 return v_balance_type_id;
--
end create_balance_type;
--
 ----------------------- create_balance_classification ------------------------
 /*
 NAME
   create_balance_classification
 DESCRIPTION
   This procedure adds a new classification to the balance.
 NOTES
   Balance feeds will be created for any elements with a PAY VALUE that matches
   the balance.
 */
--
PROCEDURE create_balance_classification
                          (p_balance_name            varchar2,
                           p_balance_classification  varchar2,
                           p_scale                   varchar2,
                           p_business_group_name     varchar2 default NULL,
                           p_legislation_code        varchar2 default NULL) is
--..
 -- Constants
 v_todays_date           constant date := trunc(sysdate);
--
 -- Local variables
 v_classification_id          number;
 v_scale                      number;
 v_business_group_id          number;
 v_legislation_code           varchar2(30);
 v_balance_classification_id  number;
 v_balance_type_id            number;
 v_legislation_subgroup       varchar2(30);
 v_startup_mode               varchar2(30);
 v_session_date               date;
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',1);
 end if;
--
 begin
   -- Get the session date nb. this is defaulted to todays date
   select ss.effective_date
   into   v_session_date
   from   fnd_sessions ss
   where  ss.session_id = userenv('sessionid');
 exception
   when NO_DATA_FOUND then NULL;
 end;
--
 -- Default the start date to the session date if no date is supplied
 if v_session_date is NULL then
   v_session_date := v_todays_date;
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',99);
 end if;
--
 -- Get sequence for
 select pay_balance_classifications_s.nextval
 into   v_balance_classification_id
 from   sys.dual;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',2);
 end if;
--
 -- Get business group id
 if p_business_group_name is not NULL then
--
   select bg.business_group_id,
          bg.legislation_code
   into   v_business_group_id,
          v_legislation_code
   from   per_business_groups bg
   where  bg.name = p_business_group_name;
--
   v_startup_mode := 'USER';
--
   elsif p_legislation_code is not NULL then
--
     v_legislation_code := p_legislation_code;
--
     v_startup_mode := 'STARTUP';
--
     else
--
       v_startup_mode := 'GENERIC';
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',3);
 end if;
--
 -- Convert Add or Subtract to a number
 select fnd_number.canonical_to_number(lookup_code)
 into   v_scale
 from   hr_lookups
 where  lookup_type = 'ADD_SUBTRACT'
   and  upper(meaning) = upper(p_scale);
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',4);
 end if;
--
 -- Get balance information
 select bt.balance_type_id,
        bt.legislation_subgroup
 into   v_balance_type_id,
        v_legislation_subgroup
 from   pay_balance_types bt
 where  upper(bt.balance_name) = upper(p_balance_name)
   and  nvl(bt.business_group_id,nvl(v_business_group_id,-1))
                                       = nvl(v_business_group_id,-1)
   and  nvl(bt.legislation_code,nvl(p_legislation_code,'-1'))
                                       = nvl(p_legislation_code,'-1');
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',5);
 end if;
--
 -- Find the classification for the balance NB. only primary classifications
 -- are allowed
 select cl.classification_id
 into   v_classification_id
 from   pay_element_classifications cl
 where  upper(cl.classification_name) = upper(p_balance_classification)
   and  cl.parent_classification_id is NULL
   and  cl.legislation_code = v_legislation_code;
--
 -- Create balance classification
 insert into pay_balance_classifications
 (BALANCE_CLASSIFICATION_ID,
  BUSINESS_GROUP_ID,
  LEGISLATION_CODE,
  BALANCE_TYPE_ID,
  CLASSIFICATION_ID,
  SCALE,
  LEGISLATION_SUBGROUP,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE)
 values(
  v_balance_classification_id,
  v_business_group_id,
  p_legislation_code,
  v_balance_type_id,
  v_classification_id,
  v_scale,
  v_legislation_subgroup,
  v_todays_date,
  -1,
  -1,
  -1,
  v_todays_date);
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_balance_classification',7);
 end if;
--
 -- CREATE BALANCE FEEDS
 hr_balances.ins_balance_feed('INS_PRIMARY_BAL_CLASS',
                              NULL,
                              NULL,
                              v_classification_id,
                              NULL,
                              NULL,
                              v_balance_type_id,
                              v_scale,
                              v_session_date,
                              v_business_group_id,
                              v_legislation_code,
                              v_startup_mode);
--
end create_balance_classification;
--.
 --------------------------- create_defined_balance ---------------------------
 /*
 NAME
   create_defined_balance
 DESCRIPTION
   Associates a balance with a dimension.
 NOTES
 */
--
PROCEDURE create_defined_balance
                          (p_balance_name            varchar2,
                           p_balance_dimension       varchar2,
                           p_frce_ltst_balance_flag  varchar2 default 'N',
                           p_business_group_name     varchar2 default NULL,
                           p_legislation_code        varchar2 default NULL,
                           p_save_run_bal            varchar2 default null,
                           p_effective_date          date     default null) is
--
--
cursor get_eff_date
is
select effective_date
from   fnd_sessions
where  session_id = userenv('sessionid');
--
cursor get_cat_id(p_bal_type varchar2
                 ,p_bg_id    number
                 ,p_leg_code varchar2
                 )
is
select balance_category_id
from   pay_balance_types
where  balance_name = p_bal_type
and    nvl(legislation_code,'NULL') = nvl(p_leg_code, 'NULL')
and    nvl(business_group_id, -1) = nvl(p_bg_id, -1);
--
--
 -- Constants
 v_todays_date             constant date := trunc(sysdate);
--
 -- Local variables
 v_balance_dimension_id    number;
 v_business_group_id       number;
 v_legislation_code        varchar2(30);
 v_bt_legislation_code     varchar2(30);
 v_bt_business_group_id    number;
 v_bt_balance_type_id      number;
 v_bt_legislation_subgroup varchar2(30);
 v_bt_balance_category_id  number;
 v_def_bal_nextval         number;
 l_bal_cat_id              pay_balance_categories_f.balance_category_id%type;
 l_run_bal_flag            pay_defined_balances.save_run_balance%type;
 l_eff_date                date;
 l_defined_balance_id      pay_defined_balances.defined_balance_id%type;
 v_dfb_legislation_code    pay_defined_balances.legislation_code%type;
 v_dfb_legislation_subgroup pay_defined_balances.legislation_subgroup%type;
 v_dfb_business_group_id   pay_defined_balances.business_group_id%type;
--
begin
 g_debug := hr_utility.debug_enabled;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_defined_balance',1);
 end if;
--
 -- Get business group id
 if p_business_group_name is not NULL then
--
   select business_group_id,
          legislation_code
   into   v_business_group_id,
          v_legislation_code
   from   per_business_groups
   where  name = p_business_group_name;
--
   elsif p_legislation_code is not NULL then
--
     v_legislation_code := p_legislation_code;
--
 end if;
--
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_defined_balance',2);
    hr_utility.trace('p_balance_dimension****: '||p_balance_dimension);
    hr_utility.trace('v_legislation_code****: '||v_legislation_code);
 end if;
--
 -- Get balance dimension making sure that it is for the correct legislation
 select bd.balance_dimension_id
 into   v_balance_dimension_id
 from   pay_balance_dimensions bd
 where  upper(bd.dimension_name) = upper(p_balance_dimension)
   and  bd.legislation_code = v_legislation_code;
--
-- get the category_id, then set the save_run_balance flag.
--
if p_save_run_bal is null then
--
-- attempt to get the default value from category and dimensions
--
if g_debug then
   hr_utility.set_location('pay_db_pay_setup.create_defined_balance',3.5);
end if;
if p_effective_date is null then
  -- default the date from fnd_sessions, as a last resort use sysdate
  --
  open  get_eff_date;
  fetch get_eff_date into l_eff_date;
  if get_eff_date%notfound then
    close get_eff_date;
    l_eff_date := trunc(sysdate);
  end if;
else -- p_effective_date is not null
  l_eff_date := p_effective_date;
end if;
  if p_business_group_name is not null then
    open  get_cat_id(p_balance_name, v_business_group_id, p_legislation_code);
    fetch get_cat_id into l_bal_cat_id;
    if get_cat_id%notfound then
    --
    -- category can be null, so will pass through as null.
    --
      close get_cat_id;
    end if;
  else -- p_business_group is null
    open  get_cat_id(p_balance_name, '', p_legislation_code);
    fetch get_cat_id into l_bal_cat_id;
    if get_cat_id%notfound then
      close get_cat_id;
    end if;
  end if;
  --
  l_run_bal_flag := PAY_DEFINED_BALANCES_PKG.set_save_run_bals_flag
                       (p_balance_category_id  => l_bal_cat_id
                       ,p_effective_date       => l_eff_date
                       ,p_balance_dimension_id => v_balance_dimension_id);
--
else -- p_save_run_bal is not null
  l_run_bal_flag := p_save_run_bal;
end if;
 --
 -- Bug 2646924 - changed p_legislation_code to v_legislation_code in the
 -- where clause, to enabled user defined_balances to be created for
 -- startup balances.
 --
select pay_defined_balances_s.nextval
,      bt.business_group_id
,      bt.legislation_code
,      bt.balance_type_id
,      bt.legislation_subgroup
,      bt.balance_category_id
into   v_def_bal_nextval
,      v_bt_business_group_id
,      v_bt_legislation_code
,      v_bt_balance_type_id
,      v_bt_legislation_subgroup
,      v_bt_balance_category_id
from   pay_balance_types bt
where  upper(bt.balance_name) = upper(p_balance_name)
and    nvl(bt.business_group_id,nvl(v_business_group_id,-1))
                              = nvl(v_business_group_id,-1)
and    nvl(bt.legislation_code,nvl(v_legislation_code,'-1'))
                             = nvl(v_legislation_code,'-1');
--
if p_business_group_name is not null then
--
  if v_bt_legislation_code is not null then
  --
  -- must be trying to insert a user defined balance, with a seeded balance, so
  -- set the v_dfb_legislation_code to be null, and the v_dfb_business_group_id
  -- to be v_business_group_id, otherwise take the values for the balance type.
  --
    v_dfb_legislation_code     := null;
    v_dfb_business_group_id    := v_business_group_id;
    v_dfb_legislation_subgroup := null;
  else
    v_dfb_legislation_code     := v_bt_legislation_code;
    v_dfb_business_group_id    := v_bt_business_group_id;
    v_dfb_legislation_subgroup := v_bt_legislation_subgroup;
  end if;
else
  v_dfb_legislation_code     := v_bt_legislation_code;
  v_dfb_business_group_id    := v_bt_business_group_id;
  v_dfb_legislation_subgroup := v_bt_legislation_subgroup;
end if;
 --
 if g_debug then
    hr_utility.set_location('pay_db_pay_setup.create_defined_balance', 7);
 end if;
 --
 -- A mutating table error will occur on pay_defined_balances if a defined
 -- balance is inserted here, while the old version of trigger
 -- pay_defined_balances_ari (pre pytrdfbl.sql 115.6) exists. The new version
 -- of the trigger prevents this error by setting a global in the trigger
 -- before the call to hrdyndbi.new_defined_balance.
 -- However, when running a patch triggers are pretty much the last things to
 -- be run, so it is possible that defined balances could be inserted using the
 -- new package code, but with the trigger missing. Hence the global will be
 -- set here also.
 -- The global is basically guaranteeing that the save_run_balance flag will
 -- be set when the row is inserted below, if it can be defaulted.
 -- hrdyndbi.new_defined_balance will attempt to update the flag if it is not
 -- set providing the global is false. The update is required for existing
 -- defined balances when default have subsequently been set.
 --
 hrdyndbi.g_trigger_dfb_ari := true;
 --
 -- Create defined balance
 --
 insert into pay_defined_balances
 (DEFINED_BALANCE_ID,
  BUSINESS_GROUP_ID,
  LEGISLATION_CODE,
  BALANCE_TYPE_ID,
  BALANCE_DIMENSION_ID,
  FORCE_LATEST_BALANCE_FLAG,
  LEGISLATION_SUBGROUP,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE,
  save_run_balance)
 values
 (v_def_bal_nextval
 ,v_dfb_business_group_id
 ,v_dfb_legislation_code
 ,v_bt_balance_type_id
 ,v_balance_dimension_id
 ,p_frce_ltst_balance_flag
 ,v_dfb_legislation_subgroup
 ,v_todays_date
 ,-1
 ,-1
 ,-1
 ,v_todays_date
 ,l_run_bal_flag
 );
--
-- we returned the balance_category_id above, if it is null then dont
-- attempt the insert of default attributes, as category is not null on the
-- defaults table.
--
  if v_bt_balance_category_id is not null then
    if g_debug then
       hr_utility.set_location('pay_db_pay_setup.create_defined_balance', 8);
    end if;
  --
  -- get the defined_balance_id just created.
  --
    select defined_balance_id
    into   l_defined_balance_id
    from   pay_defined_balances
    where  balance_type_id      = v_bt_balance_type_id
    and    balance_dimension_id = v_balance_dimension_id
    and    nvl(business_group_id,nvl(v_dfb_business_group_id,-1))
                               = nvl(v_dfb_business_group_id,-1)
    and    nvl(legislation_code,nvl(v_dfb_legislation_code,'-1'))
                              = nvl(v_dfb_legislation_code,'-1');
    --
    if g_debug then
       hr_utility.set_location('pay_db_pay_setup.create_defined_balance', 10);
       hr_utility.trace('l_defined_balance_id: '||to_char(l_defined_balance_id));
    end if;
    --
    -- see if any default attributes can be inserted.
    --
      pay_defined_balances_pkg.insert_default_attrib_wrapper
         (p_balance_dimension_id => v_balance_dimension_id
         ,p_balance_category_id  => v_bt_balance_category_id
         ,p_def_bal_bg_id        => v_dfb_business_group_id
         ,p_def_bal_leg_code     => v_dfb_legislation_code
         ,p_defined_balance_id   => l_defined_balance_id
         ,p_effective_date       => l_eff_date
         );
  end if;
if g_debug then
   hr_utility.set_location('Leaving pay_db_pay_setup.create_defined_balance', 14);
end if;
end create_defined_balance;
--
------------------------ insert_customize_restriction ------------------------
/*
 NAME
   insert_customize_restriction
 DESCRIPTION
   Creates a new customize restriction type.
 NOTES
   This function returns the customized_restriction_id of the row it has
   created and inserted into pay_customized_restrictions.
 */
--
FUNCTION insert_customize_restriction
                     ( p_business_group_id     number default NULL,
                       p_name                  varchar2,
                       p_form_name             varchar2,
                       p_query_form_title      varchar2,
                       p_standard_form_title   varchar2,
                       p_enabled_flag          varchar2 default 'N',
                       p_legislation_subgroup  varchar2 default NULL,
                       p_legislation_code      varchar2 default NULL
                     ) return number is
-- Constants
  v_todays_date           constant date := trunc(sysdate);
--
-- Local variables
  v_customized_restriction_id    number;
  v_application_id               number;
  v_name_already_exists          varchar2(1);
  v_rowid                        rowid;

--
begin
 g_debug := hr_utility.debug_enabled;
--
  if g_debug then
     hr_utility.set_location('insert_customize_restriction',1);
  end if;
--
-- Check that name is not already in use
--
  v_name_already_exists := 'N';
--
  begin
  select 'Y'
    into v_name_already_exists
    from pay_customized_restrictions pcr
   where pcr.form_name = p_form_name;
  exception
    when NO_DATA_FOUND then NULL;
  end;

  if g_debug then
     hr_utility.set_location('insert_customize_restriction',2);
  end if;
--
  if v_name_already_exists = 'Y' then
    hr_utility.set_message(801,'HR_6030_CUST_UNIQUE_NAME');
    hr_utility.raise_error;
  end if;
--
  if g_debug then
     hr_utility.set_location('insert_customize_restriction',3);
  end if;
--

-- Select the application id for the form
--
  select f.application_id
    into v_application_id
    from fnd_form f
   where f.form_name = p_form_name
     and f.application_id between 800 and 899
     and exists
            (select 1
             from   pay_restriction_parameters prp
             where  prp.form_name      = f.form_name
             and    prp.application_id = f.application_id);
--
  if g_debug then
     hr_utility.set_location('insert_customize_restriction',5);
  end if;
--
-- Create a row in pay_customized_restrictions and pay_custom_restrictions_tl
--

 PER_CUSTOMIZED_RESTR_PKG.INSERT_ROW (
  X_ROWID => v_rowid,
  X_CUSTOMIZED_RESTRICTION_ID => v_customized_restriction_id,
  X_BUSINESS_GROUP_ID => p_business_group_id ,
  X_LEGISLATION_CODE  => p_legislation_code,
  X_APPLICATION_ID => v_application_id ,
  X_FORM_NAME => p_form_name,
  X_ENABLED_FLAG => p_enabled_flag,
  X_NAME => p_name,
  X_COMMENTS => null,
  X_LEGISLATION_SUBGROUP => p_legislation_subgroup,
  X_QUERY_FORM_TITLE => p_query_form_title,
  X_STANDARD_FORM_TITLE => p_standard_form_title,
  X_CREATION_DATE => v_todays_date,
  X_CREATED_BY => -1,
  X_LAST_UPDATE_DATE => v_todays_date,
  X_LAST_UPDATED_BY => -1,
  X_LAST_UPDATE_LOGIN => -1
);


--
  if g_debug then
     hr_utility.set_location('insert_customize_restriction',6);
  end if;
--

  return v_customized_restriction_id;
--
end insert_customize_restriction;
--
--
------------------------- insert_restriction_values --------------------------
 /*
 NAME
   insert_restriction_values
 DESCRIPTION
   This procedure adds a new restriction value for the specified customization
   restriction.
 NOTES
 */
PROCEDURE insert_restriction_values
                     ( p_customized_restriction_id number,
                       p_restriction_code          varchar2,
                       p_value                     varchar2
                     ) IS
--
-- Constants
--
  v_todays_date              constant date := trunc(sysdate);
--
begin
--
-- Create restriction value
--
  insert into PAY_RESTRICTION_VALUES
  (CUSTOMIZED_RESTRICTION_ID
  ,RESTRICTION_CODE
  ,VALUE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,CREATED_BY
  ,CREATION_DATE)
  values
  (p_customized_restriction_id  ,p_restriction_code
  ,p_value
  ,v_todays_date
  ,-1
  ,-1
  ,-1
  ,v_todays_date);
--
end insert_restriction_values;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_default_currency >---------------------------|
-- ----------------------------------------------------------------------------
function get_default_currency
  (p_rule_type        in varchar2 default 'DC'
  ,p_legislation_code in varchar2
  ) return varchar2
  is
  --
  l_currency_code        fnd_currencies.currency_code%type;
  --
  cursor csr_leg_rule is
    select rule_mode
      from pay_legislation_rules
     where rule_type = p_rule_type
       and legislation_code = p_legislation_code;
  --
begin
  open csr_leg_rule;
  fetch csr_leg_rule into l_currency_code;
  if csr_leg_rule%notfound then
    close csr_leg_rule;
    --
    begin
      select cu.currency_code
        into l_currency_code
        from fnd_currencies cu
       where cu.issuing_territory_code = p_legislation_code
         and cu.enabled_flag = 'Y';
    exception
      when too_many_rows then
        fnd_message.set_name('PAY','HR_51885_MISSING_DC_RULE');
        fnd_message.raise_error;
      when no_data_found then
	fnd_message.set_name('PAY','HR_7989_HR_DEFAULT_CURRENCY');
	fnd_message.raise_error;
    end;
    --
  else
    close csr_leg_rule;
  end if;
  --
  return l_currency_code;
  --
end get_default_currency;
--
-- Initialisation Section
begin
--
 pay_db_pay_setup.set_session_date(trunc(sysdate));
--
end pay_db_pay_setup;

/
