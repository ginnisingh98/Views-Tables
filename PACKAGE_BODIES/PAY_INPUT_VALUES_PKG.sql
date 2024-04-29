--------------------------------------------------------
--  DDL for Package Body PAY_INPUT_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_INPUT_VALUES_PKG" as
/* $Header: pyipv.pkb 120.5.12010000.5 2009/11/06 11:02:28 asnell ship $ */
-- Declare global variables and cursors

-- Dummy variable for selecting into when not interested in value of result
g_dummy number(30);
--
g_element_type_id number(15);   -- For validating translation.
--
-- The end of time for date effective records
c_end_of_time   constant date   := to_date ('31/12/4712','DD/MM/YYYY');
c_user_id       number;
c_login_id      number;

-------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_element_type_id IN NUMBER) IS
BEGIN
   g_element_type_id := p_element_type_id;
END;
-------------------------------------------------------------------------------
procedure validate_translation(input_value_id IN NUMBER,
                               language IN VARCHAR2,
                               input_name IN VARCHAR2) IS
/*

This procedure fails if a input value translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated input value names.

*/

--
-- This cursor implements the validation we require,
-- but this will only work if the record exists in the db already,
-- and we have a primary key id.  Note: The legislation code column
-- can be null, hence use a decode and NVL - this also applies to the
-- business group column.
--
     cursor c_translation(p_language IN VARCHAR2,
                             p_input_name IN VARCHAR2,
                             p_input_value_id IN NUMBER)  IS
        SELECT  1
         FROM  pay_input_values_f_tl inptl,
               pay_input_values_f inp
         WHERE upper(inptl.name)     = upper(p_input_name)
         AND   inptl.input_value_id = inp.input_value_id
         AND   inptl.language = p_language
         AND   (inp.input_value_id <> p_input_value_id OR p_input_value_id IS NULL)
     AND   inp.element_type_id = g_element_type_id;

    l_package_name VARCHAR2(80) := 'PAY_INPUT_VALUES_PKG.VALIDATE_TRANSLATION';
    l_name  pay_balance_types.balance_name%type := input_name;
    l_dummy varchar2(100);

BEGIN

    hr_utility.set_location (l_package_name,1);

    BEGIN
        hr_chkfmt.checkformat (l_name,
                               'PAY_NAME',
                               l_dummy, null, null, 'N', l_dummy, null);
        hr_utility.set_location (l_package_name,2);

    EXCEPTION
        when app_exception.application_exception then
            hr_utility.set_location (l_package_name,3);
            fnd_message.set_name ('PAY','PAY_6365_ELEMENT_NO_DB_NAME'); -- checkformat failure
            fnd_message.raise_error;
    END;

    hr_utility.set_location (l_package_name,10);
    OPEN c_translation(language, input_name, input_value_id);
    hr_utility.set_location (l_package_name,20);
    FETCH c_translation INTO g_dummy;

    IF c_translation%NOTFOUND THEN
        hr_utility.set_location (l_package_name,30);
        CLOSE c_translation;
    ELSE
        hr_utility.set_location (l_package_name,40);
        CLOSE c_translation;
        fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
        fnd_message.raise_error;
    END IF;
    hr_utility.set_location ('Leaving: '||l_package_name,60);

END validate_translation;


--------------------------------------------------------------------------------
function NO_DEFAULT_AT_LINK (

--******************************************************************************
--* Returns TRUE if there is no default value specified at the link.           *
--* This will affect whether or not the default at the type may be deleted for *
--* hot-defaulted standard entries.                                            *
--******************************************************************************

-- Parameters are:

        p_input_value_id        number,
        p_effective_start_date  date,
        p_effective_end_date    date,
        p_error_if_true         boolean := FALSE        ) return boolean is

cursor csr_link is
        select  1
        from    pay_link_input_values_f
        where   input_value_id          = p_input_value_id
        and     default_value is null
        and     effective_start_date    <=p_effective_end_date
        and     effective_end_date      >=p_effective_start_date;

v_no_default    boolean := FALSE;

begin
open csr_link;
fetch csr_link into g_dummy;
v_no_default := csr_link%found;
close csr_link;

if p_error_if_true and v_no_default then
  hr_utility.set_message (801, 'PAY_INPVAL_MUST_HAVE_DEFAULT');
  hr_utility.raise_error;
end if;

return v_no_default;

end no_default_at_link;
--------------------------------------------------------------------------------
function ELEMENT_ENTRY_NEEDS_DEFAULT (

--******************************************************************************
--* Returns TRUE if an entry value uses the input_value's hot default          *
--******************************************************************************
--
-- Parameters are:
--
        p_input_value_id        number,
        p_effective_start_date  date,
        p_effective_end_date    date,
        p_error_if_true         boolean := FALSE        ) return boolean is
--
cursor csr_hot_defaulted_entry is
        select  1
        from    pay_element_entry_values_f      ENTRY,
                pay_link_input_values_f         LINK
        where   link.input_value_id     = p_input_value_id
        and     link.input_value_id     = entry.input_value_id
        and     link.default_value is null
        and     entry.screen_entry_value is null
        and     entry.effective_start_date      <= p_effective_end_date
        and     entry.effective_end_date        >= p_effective_start_date
        and     link.effective_start_date       <= p_effective_end_date
        and     link.effective_end_date        >= p_effective_start_date;
--
v_hot_default_required  boolean := FALSE;
--
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.ELEMENT_ENTRY_NEEDS_DEFAULT',1);
--
open csr_hot_defaulted_entry;
fetch csr_hot_defaulted_entry into g_dummy;
v_hot_default_required := csr_hot_defaulted_entry%found;
close csr_hot_defaulted_entry;
--
if p_error_if_true and v_hot_default_required then
  hr_utility.set_message (801,'PAY_6191_INPVAL_NO_ENTRY_DEFS');
  hr_utility.raise_error;
end if;
--
return v_hot_default_required;
--
end ELEMENT_ENTRY_NEEDS_DEFAULT;
--------------------------------------------------------------------------------
function CANT_DELETE_ALL_INPUT_VALUES (
--
--******************************************************************************
--* Returns TRUE if any input value for a given element may not be deleted     *
--******************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_delete_mode           varchar2,
p_validation_start_date date,
p_validation_end_date   date,
p_error_if_true         boolean default FALSE
--
                                                ) return boolean is
--
cursor csr_input_values is
        select  *
        from    pay_input_values_f
        where   element_type_id          = p_element_type_id
        and     effective_start_date    <= p_validation_end_date
        and     effective_end_date      >= p_validation_start_date;
--
v_protected_row_exists  boolean := FALSE;
--
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.cant_delete_all_input_values',1);
--
<<CHECK_EACH_INPUT_VALUE>>
for fetched_input_value in csr_input_values LOOP
--
  if  NOT deletion_allowed (    fetched_input_value.input_value_id,
                                p_delete_mode,
                                p_validation_start_date,
                                p_validation_end_date,
                                p_error_if_true                 ) then
--
    v_protected_row_exists := TRUE;
--
  end if;
--
  exit when v_protected_row_exists;
--
end loop check_each_input_value;
--
return v_protected_row_exists;
--
end cant_delete_all_input_values;
--------------------------------------------------------------------------------
function RUN_RESULT_VALUE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any run result values for the input value        *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_validation_start_date date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE) return boolean is
--
v_value_exists  boolean := FALSE;
--
cursor csr_value is
      select  1
      from    dual
      where  exists
       (select /*+ INDEX(RESULT PAY_RUN_RESULTS_PK) */ 1
        from   pay_run_result_values   VALUE,
               pay_run_results         RESULT,
               pay_assignment_actions  ASSIGN,
               pay_payroll_actions     PAYROLL
        where  value.run_result_id             = result.run_result_id
        and    assign.assignment_action_id     = result.assignment_action_id
        and    assign.payroll_action_id        = payroll.payroll_action_id
        and    value.input_value_id            = p_input_value_id
        and    payroll.effective_date  between   p_validation_start_date
                                       and       p_validation_end_date);
--
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.RUN_RESULT_VALUE_EXISTS',1);
open csr_value;
fetch csr_value into g_dummy;
v_value_exists := csr_value%found;
close csr_value;
--
if v_value_exists and p_error_if_true then
  hr_utility.set_message (801,'PAY_6212_INPVAL_NO_RR_DEL');
  hr_utility.raise_error;
end if;
--
return v_value_exists;
--
end run_result_value_exists;
--------------------------------------------------------------------------------
function BACKPAY_RULE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any backpay rules applying to this input value   *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_error_if_true         boolean default FALSE) return boolean is
--
v_backpay_rules_exist   boolean := FALSE;
--
cursor csr_backpay_rules is
        select  1
        from    pay_backpay_rules
        where   input_value_id  = p_input_value_id;
--
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.BACKPAY_RULE_EXISTS',1);
open csr_backpay_rules;
fetch csr_backpay_rules into g_dummy;
v_backpay_rules_exist := csr_backpay_rules%found;
close csr_backpay_rules;
--
if v_backpay_rules_exist and p_error_if_true then
  hr_utility.set_message (801,'PAY_6215_INPVAL_NO_DEL_BP');
  hr_utility.raise_error;
end if;
--
return v_backpay_rules_exist;
--
end backpay_rule_exists;
--------------------------------------------------------------------------------
function ABSENCE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any absence records applying to an input value   *
--* after the date of its date-effective deletion                              *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_validation_start_date date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
--
                                ) return boolean is
--
v_orphans_exist boolean := FALSE;
--
cursor csr_orphans is
        select  1
        from    per_absence_attendance_types
        where   input_value_id  = p_input_value_id
        and     date_effective  between p_validation_start_date
                                and     p_validation_end_date;
--
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.ABSENCE_EXISTS',1);
open csr_orphans;
fetch csr_orphans into g_dummy;
v_orphans_exist := csr_orphans%found;
close csr_orphans;
--
if v_orphans_exist and p_error_if_true then
  hr_utility.set_message (801,'PAY_6214_INPVAL_NO_ABS_DEL');
  hr_utility.raise_error;
end if;
--
return v_orphans_exist;
--
end absence_exists;
--------------------------------------------------------------------------------
function ELEMENT_ENTRY_VALUE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any element entry values for the input value     *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_validation_start_date date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
--
                                ) return boolean is
--
v_entries_exist boolean := FALSE;
--
cursor csr_entries is
        select  1
        from    pay_element_entry_values_f
        where   input_value_id           = p_input_value_id
        and     effective_start_date    <= p_validation_end_date
        and     effective_end_date      >= p_validation_start_date;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.ELEMENT_ENTRY_VALUE_EXISTS',1);
hr_utility.trace ('p_input_value_id = '||to_char(p_input_value_id));
hr_utility.trace ('p_val_start = '||p_validation_start_date);
hr_utility.trace ('p_val_end = '||p_validation_end_date);
--
open csr_entries;
fetch csr_entries into g_dummy;
v_entries_exist := csr_entries%found;
close csr_entries;
--
if v_entries_exist and p_error_if_true then
  hr_utility.set_message (801,'PAY_6211_INPVAL_NO_DEL_ENTRY');
  hr_utility.raise_error;
end if;
--
return v_entries_exist;
--
end element_entry_value_exists;
--------------------------------------------------------------------------------
function RESULT_RULE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any formula result rules applying to an input    *
--* value after the date of its date-effective deletion                        *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_validation_start_date date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
--
                                ) return boolean is
--
v_orphans_exist boolean := FALSE;
--
cursor csr_orphans is
        select  1
        from    pay_formula_result_rules_f
        where   input_value_id           = p_input_value_id
        and     effective_start_date    <= p_validation_end_date
        and     effective_end_date      >= p_validation_start_date;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.RESULT_RULE_EXISTS',1);
--
open csr_orphans;
fetch csr_orphans into g_dummy;
v_orphans_exist := csr_orphans%found;
close csr_orphans;
--
if v_orphans_exist and p_error_if_true then
  hr_utility.set_message (801,'PAY_6213_INPVAL_NO_FRR_DEL');
  hr_utility.raise_error;
end if;
--
return v_orphans_exist;
--
end result_rule_exists;
--------------------------------------------------------------------------------
function INPUT_VALUE_USED_AS_PAY_BASIS (
--
p_input_value_id    number,
p_error_if_true     boolean default FALSE) return boolean IS
--
--******************************************************************************
--* Returns TRUE if the input value is used as a pay basis                     *
--******************************************************************************
--
v_pay_basis_input_value   boolean := FALSE;
v_dummy_number            number(1);
--
cursor csr_pay_basis is
        select  1
        from    per_pay_bases
        where   input_value_id = p_input_value_id;
        --
begin
--
open csr_pay_basis;
fetch csr_pay_basis into v_dummy_number;
v_pay_basis_input_value := csr_pay_basis%found;
close csr_pay_basis;
--
if v_pay_basis_input_value and p_error_if_true then
  --
  hr_utility.set_message(801,'PAY_6965_INPVAL_NO_DEL_SB');
  hr_utility.raise_error;
  --
end if;
--
return v_pay_basis_input_value;
--
end input_value_used_as_pay_basis;
--------------------------------------------------------------------------------
function DISTRIBUTED_COST_LINK_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any element links for the input value's element  *
--* which have a costable type of Distributed, and the input value is a Pay    *
--* Value                                                                      *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_error_if_true         boolean default FALSE) return boolean is
--
v_links_exist           boolean         := FALSE;
--
-- Find local name for pay values
v_pay_value_name        hr_lookups.meaning%type := hr_general.pay_value;
--
cursor csr_links is
        select  1
        from    pay_element_links_f             LINK,
                pay_input_values_f              INPUT
        where   input.input_value_id            =  p_input_value_id
        and     input.name                      =  'Pay Value'
        and     link.element_type_id            =  input.element_type_id
        and     link.costable_type              =  'D';
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.DISTRIBUTED_COST_LINK_EXISTS',1);
--
open csr_links;
fetch csr_links into g_dummy;
v_links_exist := csr_links%found;
close csr_links;
--
if v_links_exist and p_error_if_true then
  hr_utility.set_message (801,'PAY_6210_INPVAL_NO_LINKS_DEL');
  hr_utility.raise_error;
end if;
--
return v_links_exist;
--
end distributed_cost_link_exists;
--------------------------------------------------------------------------------
function ASSIGNED_SALARY_BASE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any salary bases for the input value which are   *
--* tied to assignments                                                        *
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_validation_start_date date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE) return boolean is
--
v_base_exists   boolean := FALSE;
--
cursor csr_salary_base is
    select  1
    from    per_pay_bases BASE
    where   base.input_value_id = p_input_value_id;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.ASSIGNED_SALARY_BASE_EXISTS',1);
--
open csr_salary_base;
fetch csr_salary_base into g_dummy;
v_base_exists := csr_salary_base%found;
close csr_salary_base;
--
if v_base_exists and p_error_if_true then
  hr_utility.set_message (801,'PAY_6965_INPVAL_NO_DEL_SB');
  hr_utility.raise_error;
end if;
--
return v_base_exists;
--
end assigned_salary_base_exists;
--------------------------------------------------------------------------------
function NET_CALCULATION_RULE_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are net calculation rules which make use of the
--* specified input value id.
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_error_if_true         boolean default false) return boolean is
--
v_calculation_exists    boolean := FALSE;
--
cursor csr_calc_rule is
        select  1
        from    pay_net_calculation_rules
        where   input_value_id = p_input_value_id;
        --
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.NET_CALCULATION_RULES_EXIST',1);
--
open csr_calc_rule;
fetch csr_calc_rule into g_dummy;
v_calculation_exists := csr_calc_rule%found;
close csr_calc_rule;
--
if v_calculation_exists and p_error_if_true then
  hr_utility.set_message (801, 'PAY_35559_INPVAL_NO_DEL_CALC');
  hr_utility.raise_error;
end if;
--
return v_calculation_exists;
--
end net_calculation_rule_exists;
--------------------------------------------------------------------------------
function ACCRUAL_PLAN_EXISTS (
--
--******************************************************************************
--* Returns TRUE if there are any accrual plans which make use of the specified
--* input_value_id.
--******************************************************************************
--
-- Parameters are:
--
p_input_value_id        number,
p_error_if_true         boolean default FALSE) return boolean is
--
v_accrual_plan_exists   boolean := FALSE;
--
cursor csr_accrual_plan is
        select  1
        from    pay_accrual_plans
        where   p_input_value_id in (   pto_input_value_id,
                                        co_input_value_id,
                                        residual_input_value_id );
--
begin
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.ACCRUAL_PLAN_EXISTS',1);
--
open csr_accrual_plan;
fetch csr_accrual_plan into g_dummy;
v_accrual_plan_exists := csr_accrual_plan%found;
close csr_accrual_plan;
--
if v_accrual_plan_exists and p_error_if_true then
  hr_utility.set_message (801,'PAY_35558_INPVAL_NO_DEL_ACCRUA');
  hr_utility.raise_error;
end if;
--
return v_accrual_plan_exists;
--
end accrual_plan_exists;
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
--
--******************************************************************************
--* Handles the case when the element type is deleted.                         *
--******************************************************************************
--
-- Parameters are:
--
        -- Identifier of the element
        p_element_type_id       number,
--
        -- The effective date
        p_session_date          date            default trunc(sysdate),
--
        -- The validation period
        p_validation_start_date date,
        p_validation_end_date   date,
--
        -- The type of Date Track deletion
        p_delete_mode           varchar2        default 'DELETE'
--
                                ) is
--
cursor csr_all_inputs_for_element is
        select  rowid,pay_input_values_f.*
        from    pay_input_values_f
        where   element_type_id         =  p_element_type_id
        for update;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.PARENT_DELETED',1);
--
<<REMOVE_ORPHANED_ROWS>>
FOR fetched_input_value in csr_all_inputs_for_element LOOP
--
    hr_balance_feeds.del_bf_input_value (       fetched_input_value.input_value_id,
                                                p_delete_mode,
                                                p_validation_start_date,
                                                p_validation_end_date           );
--
-- Delete input value if in ZAP mode
-- Delete input value if it is in the future and in DELETE mode
--
 if p_delete_mode = 'ZAP'
    or (p_delete_mode = 'DELETE'
        and fetched_input_value.effective_start_date > p_session_date ) then
--
    delete_row (        fetched_input_value.rowid,
                        fetched_input_value.input_value_id,
                        p_delete_mode,
                        p_session_date,
                        p_validation_start_date,
                        p_validation_end_date           );
--
    delete from hr_application_ownerships
    where key_name = 'INPUT_VALUE_ID'
    and key_value = fetched_input_value.input_value_id;
--
  -- For date effective deletes, shut down the input value by ensuring its end
  -- date matches that of its closed parent
--
  elsif p_delete_mode = 'DELETE'
    and p_session_date  between fetched_input_value.effective_start_date
                        and     fetched_input_value.effective_end_date then
--
    update pay_input_values_f
    set effective_end_date = p_session_date
    where current of csr_all_inputs_for_element;
--
  -- For delete next changes when there are no future rows for the element,
  -- extend the input value's end date to the end of time to match the action
  -- which will be performed on the parent
--
  elsif p_delete_mode = 'DELETE_NEXT_CHANGE'
    and p_validation_end_date = c_end_of_time then
--
-- bugfix 1507600
-- only update peices date effective as of session date
--
hr_utility.trace ('***** in DELETE_NEXT_CHANGE');
hr_utility.trace ('*****   ESD>' ||
                        fetched_input_value.effective_start_date || '<');
hr_utility.trace ('*****   EED>' ||
                        fetched_input_value.effective_end_date || '<');

--    if p_session_date >= fetched_input_value.effective_start_date and
--       p_session_date <= fetched_input_value.effective_end_date then
hr_utility.trace ('***** peice within ESD and EED');
hr_utility.trace ('*****   ESD>' ||
                        fetched_input_value.effective_start_date || '<');
hr_utility.trace ('*****   EED>' ||
                        fetched_input_value.effective_end_date || '<');
--
    update pay_input_values_f
    set effective_end_date = c_end_of_time
    where --current of csr_all_inputs_for_element
      rowid = fetched_input_value.rowid
      and not exists
          (select null
             from pay_input_values_f pipv
            where pipv.element_type_id = fetched_input_value.element_type_id
              and pipv.input_value_id = fetched_input_value.input_value_id
              and pipv.effective_start_date > fetched_input_value.effective_start_date);
--    end if;
--
  end if;
  --
end loop remove_orphaned_rows;
--
end parent_deleted;
-------------------------------------------------------------------------------
procedure RECREATE_DB_ITEMS (
--
--******************************************************************************
--* Drops and then creates new DB items for all input values belonging to an   *
--* element.                                                                   *
--******************************************************************************
--
-- Parameters are:
--
        p_element_type_id       number) is
--
cursor csr_input_values is
        select  *
        from    pay_input_values_f
        where   element_type_id = p_element_type_id
	  and   generate_db_items_flag = 'Y';            -- Bug 6432304
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.RECREATE_DB_ITEMS',1);
--
FOR fetched_input_value in csr_input_values LOOP
--
  hrdyndbi.delete_input_value_dict (fetched_input_value.input_value_id);
--
  hrdyndbi.create_input_value_dict (fetched_input_value.input_value_id,
                                    fetched_input_value.effective_start_date);
--
end loop;
--
end recreate_db_items;
-------------------------------------------------------------------------------
function DELETION_ALLOWED (

--******************************************************************************
--* Returns TRUE if no business rules will be broken by deletion of the input  *
--* value                                                                      *
--******************************************************************************

-- Parameters are:

p_input_value_id        number,
p_delete_mode           varchar2,
p_validation_start_date date,
p_validation_end_date   date,
p_error_if_true         boolean default FALSE

                                ) return boolean is

v_deletion_allowed      boolean := TRUE;

begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.DELETION_ALLOWED',1);

if (p_delete_mode = 'ZAP'

        and (element_entry_value_exists (       p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true )

                or accrual_plan_exists (        p_input_value_id,
                                                p_error_if_true)

                or net_calculation_rule_exists (p_input_value_id,
                                                p_error_if_true)

                or assigned_salary_base_exists (p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true)

                or run_result_value_exists (    p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true )

                or result_rule_exists (         p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true         )

                or absence_exists (             p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true         )

                or backpay_rule_exists (        p_input_value_id,
                                                p_error_if_true )

                or distributed_cost_link_exists (       p_input_value_id,
                                                        p_error_if_true)
                                                                        )
                or input_value_used_as_pay_basis(       p_input_value_id,
                                                        p_error_if_true))

or (p_delete_mode = 'DELETE'

        and (result_rule_exists (               p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true )

                or absence_exists (             p_input_value_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_error_if_true )

                                                                        ))
or dt_api.rows_exist(
     p_base_table_name => 'ben_acty_base_rt_f',
     p_base_key_column => 'input_value_id',
     p_base_key_value  => p_input_value_id,
     p_from_date       => p_validation_start_date,
     p_to_date         => p_validation_end_date
   )
then
  v_deletion_allowed := FALSE;

end if;

return v_deletion_allowed;

end deletion_allowed;
-----------------------------------------------------------------------------
function NO_OF_INPUT_VALUES (p_element_type_id  number) return number is
--
--******************************************************************************
--* Returns the number of input values on the database for a given element     *
--******************************************************************************
--
v_no_of_input_values    number(30);
--
cursor csr_count_input_values is
        select  count(distinct input_value_id)
        from    pay_input_values_f
        where   element_type_id = p_element_type_id;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.NO_OF_INPUT_VALUES',1);
--
open csr_count_input_values;
fetch csr_count_input_values into v_no_of_input_values;
close csr_count_input_values;
--
return v_no_of_input_values;
--
end no_of_input_values;
--------------------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
--
--******************************************************************************
--* Returns TRUE if there is more than one date effective row for the input    *
--* value                                                                      *
--******************************************************************************
--
-- Parameters are:
--
        -- Identifier of the input value and its particular instance
        p_input_value_id                        number,
        p_rowid                                 varchar2) return boolean is
--
cursor csr_dated_updates is
        select  1
        from    pay_input_values_f
        where   input_value_id   = p_input_value_id
        and     rowid           <> p_rowid;
--
v_date_effectively_updated      boolean := FALSE;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.DATE_EFFECTIVELY_UPDATED',1);
--
open csr_dated_updates;
fetch csr_dated_updates into g_dummy;
v_date_effectively_updated := csr_dated_updates%found;
close csr_dated_updates;
--
return v_date_effectively_updated;
--
end date_effectively_updated;
--------------------------------------------------------------------------------
function NAME_NOT_UNIQUE (
--
--******************************************************************************
--* Returns TRUE if the input value name is NOT unique within the element type *
--******************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_rowid                 varchar2        default null,
p_name                  varchar2,
p_error_if_true         boolean default FALSE) return boolean is
--
l_ivid pay_input_values_f.input_value_id%type;
v_duplicate     boolean := FALSE;
--
cursor csr_duplicate_name (p_ivid number) is
        select  1
        from    pay_input_values_f_tl iv_tl,
                pay_input_values_f iv
        where   iv.element_type_id    = p_element_type_id
        and     (iv.rowid             <> p_rowid or p_rowid is null)
        and     iv_tl.input_value_id  = iv.input_value_id
        and     iv_tl.language        = userenv('LANG')
        and     upper(iv_tl.name)     = upper(p_name);
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.NAME_NOT_UNIQUE',1);
--
if p_rowid is not null then
  select input_value_id
  into l_ivid
  from pay_input_values_f
  where rowid = p_rowid;
else
  l_ivid := null;
end if;
--
open csr_duplicate_name(l_ivid);
fetch csr_duplicate_name into g_dummy;
v_duplicate := csr_duplicate_name%found;
close csr_duplicate_name;
--
if v_duplicate and p_error_if_true then
  hr_utility.set_message (801,'PAY_6168_INPVAL_DUP_NAME');
  hr_utility.raise_error;
end if;
--
return v_duplicate;
--
end name_not_unique;
--------------------------------------------------------------------------------
function MANDATORY_IN_FUTURE (
--
--******************************************************************************
--* Returns TRUE if the input value is mandatory in any future date effective
--* row.                                                                       *
--******************************************************************************
--
-- Parameters are:
--
        p_input_value_id        number,
        p_session_date          date    default trunc(sysdate),
        p_error_if_true         boolean default FALSE)
--
return boolean is
--
v_mandatory_in_future boolean;
--
cursor csr_mandatory_flag is
        select  1
        from    pay_input_values_f
        where   input_value_id          = p_input_value_id
        and     mandatory_flag          = 'Y'
        and     effective_start_date    > p_session_date;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.MANDATORY_IN_FUTURE',1);
open csr_mandatory_flag;
fetch csr_mandatory_flag into g_dummy;
v_mandatory_in_future := csr_mandatory_flag%found;
close csr_mandatory_flag;
--
if p_error_if_true and v_mandatory_in_future then
  hr_utility.set_message(801,'PAY_6179_INPVAL_MAND_NO_CHANGE');
  hr_utility.raise_error;
end if;
--
return v_mandatory_in_future;
--
end mandatory_in_future;
--------------------------------------------------------------------------------
procedure INSERT_ROW (
--
--******************************************************************************
--* Handles the insertion of an input value into the base table and ensures    *
--* that any cascaded actions are carried out
--******************************************************************************
--
-- Parameters are:
--
        -- All base table columns
        p_effective_start_date          date            default trunc (sysdate),
        p_effective_end_date            date default to_date ('31/12/4712',
                                                                'DD/MM/YYYY'),
        p_element_type_id               number,
        p_lookup_type                   varchar2        default null,
        p_business_group_id             number          default null,
        p_legislation_code              varchar2        default null,
        p_formula_id                    number          default null,
        p_display_sequence              number          default 1,
        p_generate_db_items_flag        varchar2        default 'Y',
        p_hot_default_flag              varchar2        default 'N',
        p_mandatory_flag                varchar2        default 'N',

-- change 115.12 - make p_name default to null
        --p_name                        varchar2        default 'Pay Value',
        p_name                          varchar2        default null,
-- change 115.12 - make p_base_name a mandatory parameter
        --p_base_name                   varchar2        default 'Pay Value',
        p_base_name                     varchar2,

        p_uom                           varchar2        default 'M',
        p_default_value                 varchar2        default null,
        p_legislation_subgroup          varchar2        default null,
        p_max_value                     varchar2        default null,
        p_min_value                     varchar2        default null,
        p_warning_or_error              varchar2        default null,
--
        -- Attributes of the parent element type which will affect
        -- subsequent actions
        p_classification_id             number          default null,
--
-- Enhancement 2793978
        p_value_set_id                  number          default null,
--
        -- The identifiers generated by the system for return to the form
        p_input_value_id        in out  nocopy number,
        p_rowid                 in out  nocopy varchar2
--
                                                ) is
--
cursor csr_next_id is
        select pay_input_values_s.nextval
        from sys.dual;
--
cursor csr_input_value_rowid is
--
        /*      We need to know the value of the newly created
                rowid so that forms does not have to re-query   */
--
        select  rowid
        from    pay_input_values_f
        where   input_value_id          = p_input_value_id
        and     effective_start_date    = p_effective_start_date
        and     effective_end_date      = p_effective_end_date;
--
cursor c_language (c_input_value_id number) is
       select L.LANGUAGE_CODE
       from   FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
       and not exists
         (select NULL
         from PAY_INPUT_VALUES_F_TL T
         where T.INPUT_VALUE_ID = c_input_value_id
         and T.LANGUAGE = L.LANGUAGE_CODE);

--
-- Each system may have a different name for a pay value
v_pay_value_name        varchar2(255)   := hr_general.pay_value;
-- change 115.12
l_name                  varchar2(80);
--
l_tl_name               varchar2(255);
--
l_check_latest_balances boolean;
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.insert_row',1);
--

-- change 115.12 - if p_name has not been specified then default it to
--                 p_base_name
l_name := p_name;
if l_name is null then
	l_name := p_base_name;
end if;

open csr_next_id;
fetch csr_next_id into p_input_value_id;
close csr_next_id;
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.insert_row',2);
--
if no_of_input_values (p_element_type_id) >= 15 then

  hr_utility.set_location ('PAY_INPUT_VALUES_PKG.insert_row',3);

  hr_utility.set_message (801, 'HR_7124_INPVAL_MAX_ENTRIES');
  hr_utility.raise_error;

end if;

insert into pay_input_values_f (
--
                                INPUT_VALUE_ID,
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
                                -- Enhancement 2793978
                                VALUE_SET_ID,
                                --
                                last_update_date,
                                last_updated_by,
                                last_update_login,
                                creation_date,
                                created_by)
--
values (
--
        p_input_value_id,
        p_effective_start_date,
        p_effective_end_date,
        p_element_type_id,
        p_lookup_type,
        p_business_group_id,
        p_legislation_code,
        p_formula_id,
        p_display_sequence,
        p_generate_db_items_flag,
        p_hot_default_flag,
        p_mandatory_flag,
        -- If the input value is a pay value, translate it to local language
--      DECODE(UPPER(p_name),
--               'PAY VALUE', v_pay_value_name,
--               p_name
--            ),
-- --
        -- only insert the base value into the _F table
        p_base_name,
-- --
        p_uom,
        p_default_value,
        p_legislation_subgroup,
        p_max_value,
        p_min_value,
        p_warning_or_error,
        -- Enhancement 2793978
        p_value_set_id,
        --
        sysdate,
        c_user_id,
        c_login_id,
        sysdate,
        c_user_id);
--
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.insert_row',4);
--
-- ***********************************************************************
-- Insert into MLS table (TL)
--
--  bug 8797632
    for c_lang_rec in c_language(P_INPUT_VALUE_ID) loop
                    if (upper(l_name) = 'PAY VALUE') then
          begin
             select meaning
             into l_tl_name
             from fnd_lookup_values
             where lookup_type = 'NAME_TRANSLATIONS'
             and   lookup_code = 'PAY VALUE'
             and   language    = c_lang_rec.language_code;
          exception
             when no_data_found then
                l_tl_name := l_name;
          end;
                                else
          -- some lookups have _ so use like
          -- meanings are unique so where already used use description
          begin
             select nvl(description,meaning)
             into l_tl_name
             from fnd_lookup_values
             where lookup_type = 'NAME_TRANSLATIONS'
             and   upper(l_name) like lookup_code
             and   language    = c_lang_rec.language_code
             and   rownum = 1;
          exception
             when no_data_found then
                l_tl_name := l_name;
          end;
                                end if;

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
               P_INPUT_VALUE_ID,
               l_tl_name,
               sysdate,
               c_user_id,
               c_user_id,
               c_login_id,
               sysdate,
               c_lang_rec.language_code,
               userenv('LANG')
              from dual;

        end loop;

--
-- ***********************************************************************
--
    hr_utility.set_location ('PAY_INPUT_VALUES_PKG.insert_row',5);
--
open csr_input_value_rowid;
fetch csr_input_value_rowid into p_rowid;
--
if csr_input_value_rowid%notfound then
  close csr_input_value_rowid;
  raise no_data_found;
else
--
  -- Create link input values for existing links
--
  pay_link_input_values_pkg.create_link_input_value (

        p_input_value_id,
        p_element_type_id,
        p_effective_start_date,
        p_effective_end_date,
-- change 115.12
        l_name,
        p_hot_default_flag,
        p_default_value,
        p_min_value,
        p_max_value,
        p_warning_or_error);

  -- Create balance feeds for pay values
--
-- change 115.12
  if (l_name = 'Pay Value'      -- the default
        or upper (l_name) = upper (v_pay_value_name)) then
    l_check_latest_balances := HRASSACT.CHECK_LATEST_BALANCES;
    HRASSACT.CHECK_LATEST_BALANCES := FALSE;
    hr_balance_feeds.ins_bf_pay_value ( p_input_value_id        );
    HRASSACT.CHECK_LATEST_BALANCES := l_check_latest_balances;
  end if;
--
  -- Create DB item for the input value
  if p_generate_db_items_flag = 'Y' then
    hrdyndbi.create_input_value_dict   (        p_input_value_id,
                                                p_effective_start_date  );
  end if;
--
  -- Create application ownership for startup pay value
  if upper (l_name) = upper (v_pay_value_name)
  and p_legislation_code is not null then
    --
    -- The 'not exists' clause is used to ensure that duplicate rows are not
    -- entered. This could arise because the forms startup code also handles
    -- application ownerships where a user enters a pay value on the form, but
    -- this code is intended to handle third party insertion from the element
    --
    insert into hr_application_ownerships
        (key_name,
         key_value,
         product_name)
        select  'INPUT_VALUE_ID',
                p_input_value_id,
                ao.product_name
        from    hr_application_ownerships ao
        where   ao.key_name = 'ELEMENT_TYPE_ID'
        and     ao.key_value = p_element_type_id
        and not exists (select  'INPUT_VALUE_ID',
                                p_input_value_id,
                                ao.product_name
                        from    hr_application_ownerships ao
                        where   ao.key_name = 'ELEMENT_TYPE_ID'
                        and     ao.key_value = p_element_type_id);
  --
  end if;
--
end if;
close csr_input_value_rowid;
--
--
end insert_row;
---------------------------------------------------------------------------
procedure UPDATE_ROW(
--
--******************************************************************************
--* Handles the updating of the base table for the form which is based on a    *
--* non-updatable view                                                         *
--******************************************************************************
--
-- Parameters are:
--
        -- All base table columns
        p_ROWID                                         VARCHAR2,
        p_INPUT_VALUE_ID                                NUMBER,
        p_EFFECTIVE_START_DATE                          DATE,
        p_EFFECTIVE_END_DATE                            DATE,
        p_ELEMENT_TYPE_ID                               NUMBER,
        p_LOOKUP_TYPE                                   VARCHAR2,
        p_BUSINESS_GROUP_ID                             NUMBER,
        p_LEGISLATION_CODE                              VARCHAR2,
        p_FORMULA_ID                                    NUMBER,
        p_DISPLAY_SEQUENCE                              NUMBER,
        p_GENERATE_DB_ITEMS_FLAG                        VARCHAR2,
        p_HOT_DEFAULT_FLAG                              VARCHAR2,
        p_MANDATORY_FLAG                                VARCHAR2,
        p_NAME                                          VARCHAR2,
        p_UOM                                           VARCHAR2,
        p_DEFAULT_VALUE                                 VARCHAR2,
        p_LEGISLATION_SUBGROUP                          VARCHAR2,
        p_MAX_VALUE                                     VARCHAR2,
        p_MIN_VALUE                                     VARCHAR2,
        p_WARNING_OR_ERROR                              VARCHAR2,
-- Enhancement 2793978
        p_value_set_id                                  number default null,
--
        p_recreate_db_items                             varchar2,
        p_base_name                                     varchar2
--
                                                ) is
l_tl_name               varchar2(255);
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.update_row',1);
--
update pay_input_values_f
set     INPUT_VALUE_ID                  = p_INPUT_VALUE_ID,
        EFFECTIVE_START_DATE            = p_EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE              = p_EFFECTIVE_END_DATE,
        ELEMENT_TYPE_ID                 = p_ELEMENT_TYPE_ID,
        LOOKUP_TYPE                     = p_LOOKUP_TYPE,
        BUSINESS_GROUP_ID               = p_BUSINESS_GROUP_ID,
        LEGISLATION_CODE                = p_LEGISLATION_CODE,
        FORMULA_ID                      = p_FORMULA_ID,
        DISPLAY_SEQUENCE                = p_DISPLAY_SEQUENCE,
        GENERATE_DB_ITEMS_FLAG          = p_GENERATE_DB_ITEMS_FLAG,
        HOT_DEFAULT_FLAG                = p_HOT_DEFAULT_FLAG,
        MANDATORY_FLAG                  = p_MANDATORY_FLAG,
-- --
        NAME                            = p_base_NAME,
-- --
        UOM                             = p_UOM,
        DEFAULT_VALUE                   = p_DEFAULT_VALUE,
        LEGISLATION_SUBGROUP            = p_LEGISLATION_SUBGROUP,
        MAX_VALUE                       = p_MAX_VALUE,
        MIN_VALUE                       = p_MIN_VALUE,
        WARNING_OR_ERROR                = p_WARNING_OR_ERROR,
        -- Enhancement 2793978
        VALUE_SET_ID                    = p_VALUE_SET_ID,
        --
        last_update_date                = sysdate,
        last_updated_by                 = c_user_id,
        last_update_login               = c_login_id
where   rowid   = p_rowid;
--
if sql%notfound then
  raise no_data_found;
end if;
--
--
-- ************************************************************************
-- update MLS table (TL)
--
          l_tl_name := P_NAME;
                    if (upper(P_NAME) = 'PAY VALUE') then
                       begin
                           select meaning
                           into l_tl_name
                           from fnd_lookup_values
                           where lookup_type = 'NAME_TRANSLATIONS'
                           and   lookup_code = 'PAY VALUE'
                           and   language    = userenv('LANG');
                        exception
                           when no_data_found then
                              l_tl_name := P_NAME;
                        end;
                     end if;

update PAY_INPUT_VALUES_F_TL
set
    NAME                        = l_tl_name,
    last_update_date            = sysdate,
    last_updated_by             = c_user_id,
    last_update_login           = c_login_id,
    SOURCE_LANG = userenv('LANG')
  where INPUT_VALUE_ID = P_INPUT_VALUE_ID
  and userenv('LANG') = LANGUAGE ;  -- bug 6125295
--
  if sql%notfound then    -- trap system errors during update
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_INPUT_VALUES_PKG.UPDATE_TL_ROW');
    hr_utility.raise_error;
  end if;
--
-- ************************************************************************
--
if p_recreate_db_items = 'Y' then
--
  -- Recreate DB items
  hrdyndbi.delete_input_value_dict (p_input_value_id);
  hrdyndbi.create_input_value_dict (p_input_value_id,p_effective_start_date);
--
end if;
--
end update_row;
---------------------------------------------------------------------------
procedure DELETE_ROW (
--
--******************************************************************************
--* Handles deletion from the base table for the form which is based on a      *
--* non-updatable view, and maintains data integrity                           *
--******************************************************************************
--
-- Parameters are:
--
        -- Identifier of the row to be deleted
        p_rowid                 varchar2,
        p_input_value_id        number,
--
        -- Date Track delete mode
        p_delete_mode   varchar2,
--
        -- Validation period
        p_session_date  date,
        p_validation_start_date date
                                default to_date ('01/01/0001','DD/MM/YYYY'),
        p_validation_end_date   date
                                default to_date ('31/12/4712','DD/MM/YYYY')
                                        ) is
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.DELETE_ROW',1);
--
if deletion_allowed (   p_input_value_id,
                        p_delete_mode,
                        p_validation_start_date,
                        p_validation_end_date   ) then
  --
  hr_balance_feeds.del_bf_input_value ( p_input_value_id,
                                        p_delete_mode,
                                        p_validation_start_date,
                                        p_validation_end_date   );
  --
  hr_utility.set_location ('PAY_INPUT_VALUES_PKG.DELETE_ROW',2);
  --
  -- delete DB items
  hrdyndbi.delete_input_value_dict (p_input_value_id);
  --
  delete from pay_input_values_f
  where rowid   = p_rowid;
  --
  if sql%notfound then
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_INPUT_VALUES_PKG.DELETE_ROW');
    hr_utility.raise_error;
  end if;
  --
--
-- ****************************************************************************
-- delete from MLS table (TL)
--

--
-- bugfix 1229606
-- only delete data from the translated tables if the date track mode is ZAP,
-- for all other date track modes the data should remain untouched
--
if p_delete_mode = 'ZAP' then

  delete from PAY_INPUT_VALUES_F_TL
  where INPUT_VALUE_ID = P_INPUT_VALUE_ID;
--
  if sql%notfound then      -- trap system errors during deletion
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_INPUT_VALUES_PKG.DELETE_TL_ROW');
    hr_utility.raise_error;
  end if;

end if;
--
-- ******************************************************************************
--
end if;
--
end delete_row;
---------------------------------------------------------------------------
procedure LOCK_ROW (
        p_rowid                                         VARCHAR2,
        p_INPUT_VALUE_ID                                NUMBER,
        p_EFFECTIVE_START_DATE                          DATE,
        p_EFFECTIVE_END_DATE                            DATE,
        p_ELEMENT_TYPE_ID                               NUMBER,
        p_LOOKUP_TYPE                                   VARCHAR2,
        p_BUSINESS_GROUP_ID                             NUMBER,
        p_LEGISLATION_CODE                              VARCHAR2,
        p_FORMULA_ID                                    NUMBER,
        p_DISPLAY_SEQUENCE                              NUMBER,
        p_GENERATE_DB_ITEMS_FLAG                        VARCHAR2,
        p_HOT_DEFAULT_FLAG                              VARCHAR2,
        p_MANDATORY_FLAG                                VARCHAR2,
--      p_NAME                                          VARCHAR2,
-- --
        p_BASE_NAME                                     VARCHAR2,
-- --
        p_UOM                                           VARCHAR2,
        p_DEFAULT_VALUE                                 VARCHAR2,
        p_LEGISLATION_SUBGROUP                          VARCHAR2,
        p_MAX_VALUE                                     VARCHAR2,
        p_MIN_VALUE                                     VARCHAR2,
        p_WARNING_OR_ERROR                              VARCHAR2,
-- Enhancement 2793978
        p_value_set_id                                  NUMBER default null
--
        ) is
--
cursor csr_lock_input_value is
        select  *
        from    pay_input_values_f
        where   rowid   = p_rowid
        for update of input_value_id nowait;
--
        v_locked_row    csr_lock_input_value%rowtype;
-- MLS Row counter
        v_mls_count     NUMBER:=0;
--
-- *****************************************************************
-- cursor for MLS
--
cursor csr_lock_input_value_tl is
    select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PAY_INPUT_VALUES_F_TL
    where INPUT_VALUE_ID = P_INPUT_VALUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INPUT_VALUE_ID nowait;
--
-- ****************************************************************
--
begin
hr_utility.set_location ('PAY_INPUT_VALUES_PKG.lock_row',1);
--
open csr_lock_input_value;
fetch csr_lock_input_value into v_locked_row;
if csr_lock_input_value%notfound then
  close csr_lock_input_value;
  raise no_data_found;
end if;
close csr_lock_input_value;
--
/** sbilling **/
-- removed explicit lock of _TL table,
-- the MLS strategy requires that the base table is locked before update of the
-- _TL table can take place,
-- which implies it is not necessary to lock both tables.
--
-- ************************************************************************
-- code for MLS
--
-- for tlinfo in csr_lock_input_value_tl LOOP
--   v_mls_count := v_mls_count+1;
--    if (tlinfo.BASELANG = 'Y') then
--      if (    (tlinfo.NAME = P_NAME)
--      ) then
--        null;
--      else
--        hr_utility.set_message ('FND','FORM_RECORD_CHANGED');
--        hr_utility.raise_error;
--      end if;
--    end if;
--  end loop;
--
--
-- if (v_mls_count=0) then -- Trap system errors
--  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
--  hr_utility.set_message_token ('PROCEDURE','PAY_INPUT_VALUES_PKG.LOCK_TL_ROW');
-- end if;
--
-- ************************************************************************
--
--
if ((V_LOCKED_ROW.INPUT_VALUE_ID = p_INPUT_VALUE_ID) OR (V_LOCKED_ROW.INPUT_VALUE_ID is null and p_INPUT_VALUE_ID is null))
and ((V_LOCKED_ROW.EFFECTIVE_START_DATE = p_EFFECTIVE_START_DATE) OR (V_LOCKED_ROW.EFFECTIVE_START_DATE is null and p_EFFECTIVE_START_DATE is null))
and ((V_LOCKED_ROW.EFFECTIVE_END_DATE = p_EFFECTIVE_END_DATE) OR (V_LOCKED_ROW.EFFECTIVE_END_DATE is null and p_EFFECTIVE_END_DATE is null))
and ((V_LOCKED_ROW.ELEMENT_TYPE_ID = p_ELEMENT_TYPE_ID) OR (V_LOCKED_ROW.ELEMENT_TYPE_ID is null and p_ELEMENT_TYPE_ID is null))
and ((V_LOCKED_ROW.LOOKUP_TYPE = p_LOOKUP_TYPE) OR (V_LOCKED_ROW.LOOKUP_TYPE is null and p_LOOKUP_TYPE is null))
and ((V_LOCKED_ROW.BUSINESS_GROUP_ID = p_BUSINESS_GROUP_ID) OR (V_LOCKED_ROW.BUSINESS_GROUP_ID is null and p_BUSINESS_GROUP_ID is null))
and ((V_LOCKED_ROW.LEGISLATION_CODE = p_LEGISLATION_CODE) OR (V_LOCKED_ROW.LEGISLATION_CODE is null and p_LEGISLATION_CODE is null))
and ((V_LOCKED_ROW.FORMULA_ID = p_FORMULA_ID) OR (V_LOCKED_ROW.FORMULA_ID is null and p_FORMULA_ID is null))
and ((V_LOCKED_ROW.DISPLAY_SEQUENCE = p_DISPLAY_SEQUENCE) OR (V_LOCKED_ROW.DISPLAY_SEQUENCE is null and p_DISPLAY_SEQUENCE is null))
and ((V_LOCKED_ROW.GENERATE_DB_ITEMS_FLAG= p_GENERATE_DB_ITEMS_FLAG) OR (V_LOCKED_ROW.GENERATE_DB_ITEMS_FLAG is null and p_GENERATE_DB_ITEMS_FLAG is null))
and ((V_LOCKED_ROW.HOT_DEFAULT_FLAG = p_HOT_DEFAULT_FLAG) OR (V_LOCKED_ROW.HOT_DEFAULT_FLAG is null and p_HOT_DEFAULT_FLAG is null))
and ((V_LOCKED_ROW.MANDATORY_FLAG = p_MANDATORY_FLAG) OR (V_LOCKED_ROW.MANDATORY_FLAG is null and p_MANDATORY_FLAG is null))
--and ((V_LOCKED_ROW.NAME = p_NAME) OR (V_LOCKED_ROW.NAME is null and p_NAME is null))
-- --
and ((V_LOCKED_ROW.NAME = p_BASE_NAME) OR (V_LOCKED_ROW.NAME is null and p_BASE_NAME is null))
-- --
and ((V_LOCKED_ROW.UOM = p_UOM) OR (V_LOCKED_ROW.UOM is null and p_UOM is null))
and ((V_LOCKED_ROW.DEFAULT_VALUE = p_DEFAULT_VALUE) OR (V_LOCKED_ROW.DEFAULT_VALUE is null and p_DEFAULT_VALUE is null))
and ((V_LOCKED_ROW.LEGISLATION_SUBGROUP = p_LEGISLATION_SUBGROUP) OR (V_LOCKED_ROW.LEGISLATION_SUBGROUP is null and p_LEGISLATION_SUBGROUP is null))
and ((V_LOCKED_ROW.MAX_VALUE = p_MAX_VALUE) OR (V_LOCKED_ROW.MAX_VALUE is null and p_MAX_VALUE is null))
and ((V_LOCKED_ROW.MIN_VALUE = p_MIN_VALUE) OR (V_LOCKED_ROW.MIN_VALUE is null and p_MIN_VALUE is null))
and ((V_LOCKED_ROW.WARNING_OR_ERROR = p_WARNING_OR_ERROR) OR (V_LOCKED_ROW.WARNING_OR_ERROR is null and p_WARNING_OR_ERROR is null)) then
 return;
else
  hr_utility.set_message ('FND','FORM_RECORD_CHANGED');
  hr_utility.raise_error;
end if;
--
end lock_row;
---------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_INPUT_VALUES_F_TL T
  where not exists
    (select NULL
    from PAY_INPUT_VALUES_F B
    where B.INPUT_VALUE_ID = T.INPUT_VALUE_ID
    );

  update PAY_INPUT_VALUES_F_TL T set (
      NAME
    ) = (select
      B.NAME
    from PAY_INPUT_VALUES_F_TL B
    where B.INPUT_VALUE_ID = T.INPUT_VALUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INPUT_VALUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INPUT_VALUE_ID,
      SUBT.LANGUAGE
    from PAY_INPUT_VALUES_F_TL SUBB, PAY_INPUT_VALUES_F_TL SUBT
    where SUBB.INPUT_VALUE_ID = SUBT.INPUT_VALUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

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
    B.INPUT_VALUE_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_INPUT_VALUES_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_INPUT_VALUES_F_TL T
    where T.INPUT_VALUE_ID = B.INPUT_VALUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-----------------------------------------------------------
procedure unique_chk(
   X_I_NAME in varchar2,
   X_I_LEGISLATION_CODE in varchar2,
   X_I_EFFECTIVE_START_DATE in date,
   X_I_EFFECTIVE_END_DATE in date,
   X_I_E_ELEMENT_NAME in varchar2,
   X_I_E_LEGISLATION_CODE in varchar2,
   X_I_E_EFFECTIVE_START_DATE in date,
   X_I_E_EFFECTIVE_END_DATE in date )
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM pay_element_types_f E, pay_input_values_F I
  WHERE I.ELEMENT_TYPE_ID = E.ELEMENT_TYPE_ID
    and nvl(E.ELEMENT_NAME,'~null~') = nvl(X_I_E_ELEMENT_NAME,'~null~')
    and nvl(E.LEGISLATION_CODE,'~null~') = nvl(X_I_E_LEGISLATION_CODE,'~null~')
    and E.EFFECTIVE_START_DATE = X_I_E_EFFECTIVE_START_DATE
    and E.EFFECTIVE_end_DATE = X_I_E_EFFECTIVE_END_DATE
    and X_I_E_EFFECTIVE_START_DATE is not NULL
    and X_I_E_EFFECTIVE_END_DATE is not NULL
    and E.BUSINESS_GROUP_ID is NULL
    and nvl(I.NAME,'~null~') = nvl(X_I_NAME,'~null~')
    and nvl(I.LEGISLATION_CODE,'~null~') = nvl(X_I_LEGISLATION_CODE,'~null~')
    and I.EFFECTIVE_START_DATE = X_I_EFFECTIVE_START_DATE
    and I.EFFECTIVE_end_DATE = X_I_EFFECTIVE_END_DATE
    and X_I_EFFECTIVE_START_DATE is not NULL
    and X_I_EFFECTIVE_END_DATE is not NULL
    and I.BUSINESS_GROUP_ID is NULL;
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_INPUT_VALUES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_INPUT_VALUES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
end unique_chk;
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_I_NAME in varchar2,
   X_I_LEGISLATION_CODE in varchar2,
   X_I_EFFECTIVE_START_DATE in date,
   X_I_EFFECTIVE_END_DATE in date,
   X_I_E_ELEMENT_NAME in varchar2,
   X_I_E_LEGISLATION_CODE in varchar2,
   X_I_E_EFFECTIVE_START_DATE in date,
   X_I_E_EFFECTIVE_END_DATE in date,
   X_NAME in varchar2,
   X_OWNER in varchar2 ) is
--
-- Fetch the input_value_id. This used to be a sub-query in the update
-- statement.
--
cursor csr_ipv_id is
select i.input_value_id
from   pay_element_types_f e
,      pay_input_values_f i
WHERE  i.element_type_id = e.element_type_id
and    nvl(e.element_name,'~null~') = nvl(x_i_e_element_name,'~null~')
and    nvl(e.legislation_code,'~null~') = nvl(x_i_e_legislation_code,'~null~')
and    e.effective_start_date = x_i_e_effective_start_date
and    e.effective_END_date = x_i_e_effective_end_date
and    x_i_e_effective_start_date is not null
and    x_i_e_effective_end_date is not null
and    e.business_group_id is null
and    nvl(i.name,'~null~') = nvl(x_i_name,'~null~')
and    nvl(i.legislation_code,'~null~') = nvl(x_i_legislation_code,'~null~')
and    i.effective_start_date = x_i_effective_start_date
and    i.effective_end_date = x_i_effective_end_date
and    x_i_effective_start_date is not null
and    x_i_effective_end_date is not null
and    i.business_group_id is null
;
--
-- Fetch information for the _TL rows that will be affected by the update.
--
cursor csr_tl_info
(p_input_value_id in number
,p_language        in varchar2
) is
select name
,      language
from   pay_input_values_f_tl
where  input_value_id = p_input_value_id
and    p_language in (language, source_lang)
;
--
l_input_value_id number;
l_found          boolean;
i                binary_integer := 1;
l_langs          dbms_sql.varchar2s;
l_lang           varchar2(100);
begin
  --
  -- Fetch the input_value_id.
  --
  open  csr_ipv_id;
  fetch csr_ipv_id
  into  l_input_value_id
  ;
  l_found := csr_ipv_id%found;
  close csr_ipv_id;


  l_lang := userenv('LANG');

  if l_found then
    --
    -- Check if database item translations are supported.
    --
    if ff_dbi_utils_pkg.translations_supported
       (p_legislation_code => x_i_legislation_code
       ) then
      for crec in  csr_tl_info
                   (p_input_value_id => l_input_value_id
                   ,p_language       => l_lang
                   ) loop
        if upper(crec.name) <> upper(x_name) then
          l_langs(i) := crec.language;
          i := i + 1;
        end if;
      end loop;
    end if;

    UPDATE pay_input_values_f_tl
    SET    name = nvl(x_name,name),
           last_update_date = sysdate,
           last_updated_by = decode(x_owner,'SEED',1,0),
           last_update_login = 0,
           source_lang = userenv('LANG')
    WHERE  userenv('LANG') IN (language,source_lang)
    AND    input_value_id  = l_input_value_id
    ;

    --
    -- Write any changes to PAY_DYNDBI_CHANGES.
    --
    if l_langs.count <> 0 then
      pay_dyndbi_changes_pkg.input_value_change
      (p_input_value_id => l_input_value_id
      ,p_languages      => l_langs
      );
    end if;
  end if;
end TRANSLATE_ROW;
--------------------------------------------------------------------------------
procedure init_where_clause (
   p_vset_defn in out nocopy fnd_vset.valueset_r
 )
is
  --
  c_prof constant  varchar2(20) := ':$PROFILES$.';
  --
  l_where_clause   varchar2(32000);
  l_replace_string varchar2(200);
  l_src            varchar2(100);
  l_value          varchar2(240);
  l_default_value  varchar2(240);
  l_idx            number;
  l_ch             varchar2(10);
  l_prof_len       number;
  l_prof_found     boolean;
  --
begin
    --
    if p_vset_defn.validation_type <> 'F' or
      p_vset_defn.table_info.where_clause is null then
      --
      -- no where clause to initialize
      --
      return;
      --
    end if;
    --
    l_prof_len := length(c_prof);
    l_where_clause := p_vset_defn.table_info.where_clause;
    --
    loop
      --
      l_src := null;
      --
      -- find the position of ':$PROFILES$.' in the where clause
      --
      l_idx := instr(upper(l_where_clause),c_prof);
      --
      exit when l_idx = 0;
      --
      -- the where clause contains :$PROFILES$ references, the profile option
      -- needs to be resolved
      --
      l_prof_found := true;
      l_replace_string := substr(l_where_clause,l_idx,l_prof_len);
      l_idx := l_idx + l_prof_len;
      --
      -- loop to determine profile option name
      --
      loop
        --
	-- build up the profile option name 1 character at a time
	--
	l_ch := substr(l_where_clause,l_idx,1);
	--
	-- the profile option name can only contain alphanumeric characters and
	-- underscores so exit when l_ch is not one of these
        --
	exit when l_ch is null or
	  not (upper(l_ch) between 'A' and 'Z' or l_ch between '0' and '9' or l_ch = '_');
	--
	l_src := l_src || l_ch;
	l_idx := l_idx + 1;
	--
      end loop;
      --
      l_default_value := null;
      --
      if l_ch = ':' then
        --
	-- a default value has been specified
	--
	l_idx := l_idx + 1;
	--
	-- loop to determine default value
	--
	loop
	  --
	  -- build up the default value 1 character at a time
	  --
	  l_ch := substr(l_where_clause,l_idx,1);
  	  --
	  -- the default value can only contain alphanumeric characters and
	  -- underscores so exit when l_ch is not one of these
	  --
	  exit when l_ch is null or
	    not (upper(l_ch) between 'A' and 'Z' or l_ch between '0' and '9' or l_ch = '_');
	  l_default_value := l_default_value || l_ch;
	  l_idx := l_idx + 1;
	  --
	end loop;
	--
      end if;
      --
      -- l_src now contains the profile option name, so append this to
      -- l_replace_string
      --
      l_replace_string := l_replace_string || l_src;
      --
      if l_default_value is not null then
        --
	-- l_default_value is not null so this also needs to be appended to
	-- l_replace_string
	--
	l_replace_string := l_replace_string ||':'||l_default_value;
	--
      end if;
      --
      -- now resolve the profile option value
      --
      l_value := null;
      fnd_profile.get(upper(l_src),l_value);
      --
      if l_value is null then
        --
	-- use the default value, or 'NULL' if the default is null
	--
	l_value := nvl(l_default_value,'NULL');
	--
      end if;
      --
      -- replace all occurrences of l_replace_string in l_where_clause with
      -- l_value (in single quotes)
      --
      l_where_clause := replace(l_where_clause,l_replace_string,''''||l_value||'''');
      --
    end loop;
    --
    -- all :$PROFILES$ references have been resolved, replace the where clause in
    -- p_vset_defn
    --
    if l_prof_found then
      --
      p_vset_defn.table_info.where_clause := l_where_clause;
      --
    end if;
    --
end init_where_clause;
--------------------------------------------------------------------------------
-- Enhancement 2793978
function decode_vset_value (
   p_value_set_id in number
 , p_value_set_value in varchar2
 )
return varchar2 is
  --
  -- Returns the corresponding meaning from a value set for a given value.
  -- Returns meaning if hasmeaning() is true, returns value otherwise.
  --
  l_value_set_meaning varchar2(240);
  l_vset_defn fnd_vset.valueset_r;
  l_vset_fmt fnd_vset.valueset_dr;
  l_vset_value fnd_vset.value_dr;
  l_vset_row_count number;
  l_vset_value_found boolean;
  l_match_found boolean;
  --
begin
  --
  fnd_vset.get_valueset(p_value_set_id,l_vset_defn,l_vset_fmt);
  init_where_clause(l_vset_defn);
  fnd_vset.get_value_init(l_vset_defn, true);
  fnd_vset.get_value(l_vset_defn,l_vset_row_count,l_vset_value_found,l_vset_value);
  --
  while l_vset_value_found loop
    --
    if l_vset_fmt.has_id and l_vset_value.id = p_value_set_value then
      l_match_found := true;
    elsif l_vset_value.value = p_value_set_value then
      l_match_found := true;
    else
      l_match_found := false;
    end if;
    --
    if l_match_found and l_vset_fmt.has_meaning then
      l_value_set_meaning := l_vset_value.meaning;
      exit;
    elsif l_match_found then
      l_value_set_meaning := l_vset_value.value;
      exit;
    end if;
    --
    fnd_vset.get_value(l_vset_defn,l_vset_row_count,l_vset_value_found,l_vset_value);
    --
  end loop;
  --
  fnd_vset.get_value_end(l_vset_defn);
  if l_match_found then
    return l_value_set_meaning;
  else
    return null;
  end if;
  --
exception
  --
  when others then
    return null;
  --
end decode_vset_value;
--------------------------------------------------------------------------------
-- Enhancement 2793978
function decode_vset_meaning (
   p_value_set_id in number
 , p_value_set_meaning in varchar2
 )
return varchar2 is
  --
  -- Returns the corresponding value from a value set for a given meaning.
  -- Returns id if hasid() is true, returns value otherwise.
  --
  l_value_set_value varchar2(150);
  l_vset_defn fnd_vset.valueset_r;
  l_vset_fmt fnd_vset.valueset_dr;
  l_vset_value fnd_vset.value_dr;
  l_vset_row_count number;
  l_vset_value_found boolean;
  l_match_found boolean;
  --
begin
  --
  fnd_vset.get_valueset(p_value_set_id,l_vset_defn,l_vset_fmt);
  init_where_clause(l_vset_defn);
  fnd_vset.get_value_init(l_vset_defn, true);
  fnd_vset.get_value(l_vset_defn,l_vset_row_count,l_vset_value_found,l_vset_value);
  --
  while l_vset_value_found loop
    --
    if l_vset_fmt.has_meaning and l_vset_value.meaning = p_value_set_meaning then
      l_match_found := true;
    elsif l_vset_value.value = p_value_set_meaning then
      l_match_found := true;
    else
      l_match_found := false;
    end if;
    --
    if l_match_found and l_vset_fmt.has_id then
      l_value_set_value := l_vset_value.id;
      exit;
    elsif l_match_found then
      l_value_set_value := l_vset_value.value;
      exit;
    end if;
    --
    fnd_vset.get_value(l_vset_defn,l_vset_row_count,l_vset_value_found,l_vset_value);
    --
  end loop;
  --
  fnd_vset.get_value_end(l_vset_defn);
  if l_match_found and length(l_value_set_value) <= 60 then
    return l_value_set_value;
  else
    return null;
  end if;
  --
exception
  --
  when others then
    return null;
  --
end decode_vset_meaning;
--------------------------------------------------------------------------------
begin
--
c_user_id := fnd_global.user_id;
c_login_id := fnd_global.login_id;
--
end     PAY_INPUT_VALUES_PKG;

/
