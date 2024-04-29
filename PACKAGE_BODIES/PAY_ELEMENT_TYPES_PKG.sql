--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TYPES_PKG" as
/* $Header: pyelt.pkb 120.6.12010000.2 2008/08/06 07:09:44 ubhat ship $ */
--
--------------------------------------------------------------------------------
-- Declaration of package-wide (global) variables and cursors
--
-- Constant for name of table being manipulated (useful for generic code)
c_base_table    constant varchar2(30)   := 'PAY_ELEMENT_TYPES_F';
--
c_user_id       number;
c_login_id      number;
--
-- Dummy variables for selecting into when not interested in value of result
g_dummy_number          number(30);
g_dummy_char            varchar2(255);
--
g_business_group_id number(15);   -- For validating translation.
g_legislation_code  varchar2(150);-- For validating translation.
--
-- Cursor to select formula result rules of a specified type for a
-- given element within the validation period.
--
cursor g_csr_result_rules (
--
p_element_type_id       number,
p_validation_start_date date,
p_validation_end_date   date,
p_rule_type             varchar2
                                ) is
--
        select  result.status_processing_rule_id
        from    pay_formula_result_rules_f      RESULT,
                pay_input_values_f              INPUT
        where   input.element_type_id           = p_element_type_id
        and     input.input_value_id            = result.input_value_id
        and     result.result_rule_type         = p_rule_type
        and     result.effective_start_date     between p_validation_start_date
                                                and     p_validation_end_date;
--
--
--
--
--
-------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code  := p_legislation_code;
END;
-------------------------------------------------------------------------------
procedure validate_translation(element_type_id IN NUMBER,
                               language        IN VARCHAR2,
                               element_name    IN VARCHAR2,
                               reporting_name  IN VARCHAR2,
                               description     IN VARCHAR2) IS
/*

This procedure fails if a element translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated element names.

*/


--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
       cursor c_translation(p_language IN VARCHAR2,
                            p_element_name IN VARCHAR2,
                            p_element_type_id IN NUMBER)  IS
       SELECT  1
       FROM  pay_element_types_f_tl ettl,
             pay_element_types_f    et
       WHERE upper(translate(ettl.element_name,'x_','x '))
                         = upper(translate(p_element_name,'x_','x '))
       AND   ettl.element_type_id = et.element_type_id
       AND   ettl.language = p_language
       AND   ( et.element_type_id <> p_element_type_id        OR p_element_type_id   is null)
       AND   ( g_business_group_id = et.business_group_id + 0 OR g_business_group_id is null )
       AND   ( g_legislation_code  = et.legislation_code      OR g_legislation_code  is null );

    l_package_name VARCHAR2(80) := 'PAY_ELEMENT_TYPES_PKG.VALIDATE_TRANSLATION';
    l_dummy        varchar2(100);
    l_name         pay_element_types.element_name%type := element_name;

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

    OPEN c_translation(language, element_name,element_type_id);
    hr_utility.set_location (l_package_name,20);
    FETCH c_translation INTO g_dummy_number;

    IF c_translation%NOTFOUND THEN
        hr_utility.set_location (l_package_name,30);
        CLOSE c_translation;
    ELSE
        hr_utility.set_location (l_package_name,40);
        CLOSE c_translation;
        fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
        fnd_message.raise_error;
    END IF;
    hr_utility.set_location ('Leaving: '||l_package_name,80);

END validate_translation;

-------------------------------------------------------------------------------
procedure CHECK_FOR_PAYLINK_BATCHES (
--
        p_element_type_id       number,
        p_element_name          varchar2) is
--
-- Prevents the updating of input value names and display sequences for an
-- element's input values if there are paylink batch lines for the element.
-- Not to do so would mean that the values in the batch line would then be
-- associated with the wrong input values because they rely on the sequence
-- remaining unchanged.
--
-- Bug 2786908 : converted into a union as new version oy paylink
-- always populates element_type_id in pay_batch_lines.  Hence 2nd
-- half of union can be removed at some future stage.
--
cursor csr_paylink is
        select  1
        from    pay_batch_lines
        where   element_type_id = p_element_type_id
        and     element_type_id is not null
        union all
        select  1
        from    pay_batch_lines
        where   element_type_id is null
        and     upper (element_name) = upper (p_element_name);
        --
begin
--
open csr_paylink;
fetch csr_paylink into g_dummy_number;
--
if csr_paylink%found then
  close csr_paylink;
  hr_utility.set_message (801, 'HR_7431_INPVAL_PAYLINK_BATCHES');
  hr_utility.raise_error;
end if;
--
close csr_paylink;
--
end check_for_paylink_batches;
-------------------------------------------------------------------------------
procedure RECREATE_DB_ITEMS (
--
--******************************************************************************
--* Drops DB items for the element and then re-creates them. This is           *
--* necessary if the element name is updated because the DB items use the same *
--* name.                                                                      *
--******************************************************************************
--
-- The parameters to be passed in are:
--
p_element_type_id       number,
p_effective_start_date  date    default to_date ('01/01/0001','DD/MM/YYYY')
                                                        )        is
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.RECREATE_DB_ITEMS',1);
--
-- Drop the DB items
hrdyndbi.delete_element_type_dict(p_element_type_id);
--
-- Re-create the DB items
hrdyndbi.create_element_type_dict(p_element_type_id,
                                  p_effective_start_date);
--
-- Re-create all the input value DB items for the element
pay_input_values_pkg.recreate_db_items (p_element_type_id);
--
end recreate_db_items;
--
--
--
--
--
-----------------------------------------------------------------------------
procedure INSERT_ROW(
--
--******************************************************************************
--* Handles the insertion of rows into the base table for the form which is    *
--* based on a non-updatable view. It also ensures the correct integrity of    *
--* cascading actions is enforced.                                             *
--******************************************************************************
--
-- Parameters to be passed in/out are:
--
        -- The rowid and element type ID are generated by this procedure and
        -- passed back to the form
p_rowid                 in out  nocopy varchar2,
p_element_type_id       in out  nocopy number,
--
-- All the base table fields from the forms block
p_effective_start_date          date,
p_effective_end_date            date,
p_business_group_id             number,
p_legislation_code              varchar2,
p_formula_id                    number  ,
p_input_currency_code           varchar2,
p_output_currency_code          varchar2,
p_classification_id             number,
p_benefit_classification_id     number,
p_additional_entry_allowed      varchar2,
p_adjustment_only_flag          varchar2,
p_closed_for_entry_flag         varchar2,
p_element_name                  varchar2,
-- --
p_base_element_name                  varchar2,
-- --
p_indirect_only_flag            varchar2,
p_multiple_entries_allowed varchar2,
p_multiply_value_flag           varchar2,
p_post_termination_rule         varchar2,
p_process_in_run_flag           varchar2,
p_processing_priority           number,
p_processing_type               varchar2,
p_standard_link_flag            varchar2,
p_comment_id                    number,
p_description                   varchar2,
p_legislation_subgroup          varchar2,
p_qualifying_age                number,
p_qualifying_length_of_service  number,
p_qualifying_units              varchar2,
p_reporting_name                varchar2,
p_attribute_category            varchar2,
p_attribute1                    varchar2,
p_attribute2                    varchar2,
p_attribute3                    varchar2,
p_attribute4                    varchar2,
p_attribute5                    varchar2,
p_attribute6                    varchar2,
p_attribute7                    varchar2,
p_attribute8                    varchar2,
p_attribute9                    varchar2,
p_attribute10                   varchar2,
p_attribute11                   varchar2,
p_attribute12                   varchar2,
p_attribute13                   varchar2,
p_attribute14                   varchar2,
p_attribute15                   varchar2,
p_attribute16                   varchar2,
p_attribute17                   varchar2,
p_attribute18                   varchar2,
p_attribute19                   varchar2,
p_attribute20                   varchar2,
p_element_information_category  varchar2,
p_element_information1          varchar2,
p_element_information2          varchar2,
p_element_information3          varchar2,
p_element_information4          varchar2,
p_element_information5          varchar2,
p_element_information6          varchar2,
p_element_information7          varchar2,
p_element_information8          varchar2,
p_element_information9          varchar2,
p_element_information10         varchar2,
p_element_information11         varchar2,
p_element_information12         varchar2,
p_element_information13         varchar2,
p_element_information14         varchar2,
p_element_information15         varchar2,
p_element_information16         varchar2,
p_element_information17         varchar2,
p_element_information18         varchar2,
p_element_information19         varchar2,
p_element_information20         varchar2,
--
-- The type of element will affect further actions
p_non_payments_flag             varchar2,
--
-- The benefits attributes may be needed for defaulting input values
--
p_default_benefit_uom           varchar2,
p_contributions_used            varchar2,
--
p_third_party_pay_only_flag     varchar2,
p_retro_summ_ele_id		number,
p_iterative_flag                varchar2,
p_iterative_formula_id          number,
p_iterative_priority            number,
p_process_mode                  varchar2,
p_grossup_flag                  varchar2,
p_advance_indicator             varchar2,
p_advance_payable               varchar2,
p_advance_deduction             varchar2,
p_process_advance_entry         varchar2,
p_proration_group_id            number,
--Code added by prsundar for Continous calculation enhancement
p_proration_formula_id		number,
p_recalc_event_group_id		number,
p_once_each_period_flag         varchar2 default null,
-- Added for FLSA Dynamic Period Allocation
p_time_definition_type		varchar2 default null,
p_time_definition_id		varchar2 default null,
-- Added for Advance Pay
p_advance_element_type_id	number default null,
p_deduction_element_type_id	number default null) is
--
cursor csr_new_id is
        select pay_element_types_s.nextval
        from sys.dual;
--
cursor csr_element_rowid is
--
        -- Returns the system-generated columns for return to the
        -- form, and for use in cascading action
--
        select  rowid
        from    pay_element_types_f
        where   element_type_id         = p_element_type_id
        and     effective_start_date    = p_effective_start_date;
--
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.INSERT_ROW',1);
--
open csr_new_id;
fetch csr_new_id into p_element_type_id;
close csr_new_id;
--
insert into pay_element_types_f (       element_type_id,
                                        effective_start_date,
                                        effective_end_date,
                                        business_group_id,
                                        legislation_code,
                                        formula_id,
                                        input_currency_code,
                                        output_currency_code,
                                        classification_id,
                                        benefit_classification_id,
                                        additional_entry_allowed_flag,
                                        adjustment_only_flag,
                                        closed_for_entry_flag,
                                        element_name,
                                        indirect_only_flag,
                                        multiple_entries_allowed_flag,
                                        multiply_value_flag,
                                        post_termination_rule,
                                        process_in_run_flag,
                                        processing_priority,
                                        processing_type,
                                        standard_link_flag,
                                        comment_id,
                                        description,
                                        legislation_subgroup,
                                        qualifying_age,
                                        qualifying_length_of_service,
                                        qualifying_units,
                                        reporting_name,
                                        attribute_category,
                                        attribute1,
                                        attribute2,
                                        attribute3,
                                        attribute4,
                                        attribute5,
                                        attribute6,
                                        attribute7,
                                        attribute8,
                                        attribute9,
                                        attribute10,
                                        attribute11,
                                        attribute12,
                                        attribute13,
                                        attribute14,
                                        attribute15,
                                        attribute16,
                                        attribute17,
                                        attribute18,
                                        attribute19,
                                        attribute20,
                                        element_information_category,
                                        element_information1,
                                        element_information2,
                                        element_information3,
                                        element_information4,
                                        element_information5,
                                        element_information6,
                                        element_information7,
                                        element_information8,
                                        element_information9,
                                        element_information10,
                                        element_information11,
                                        element_information12,
                                        element_information13,
                                        element_information14,
                                        element_information15,
                                        element_information16,
                                        element_information17,
                                        element_information18,
                                        element_information19,
                                        element_information20,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        third_party_pay_only_flag,
                                        retro_summ_ele_id,
                                        iterative_flag,
                                        iterative_formula_id,
                                        iterative_priority,
                                        process_mode,
                                        grossup_flag,
                                        advance_indicator,
                                        advance_payable,
                                        advance_deduction,
                                        process_advance_entry,
                                        proration_group_id,
                                        proration_formula_id,
                                        recalc_event_group_id,
                                        once_each_period_flag,
					time_definition_type,
					time_definition_id,
					advance_element_type_id,
					deduction_element_type_id)
--
values (        p_element_type_id,
                p_effective_start_date,
                p_effective_end_date,
                p_business_group_id,
                p_legislation_code,
                p_formula_id,
                p_input_currency_code,
                p_output_currency_code,
                p_classification_id,
                p_benefit_classification_id,
                p_additional_entry_allowed,
                p_adjustment_only_flag,
                p_closed_for_entry_flag,
--              p_element_name,
-- --
                p_base_element_name,
-- --
                p_indirect_only_flag,
                p_multiple_entries_allowed,
                p_multiply_value_flag,
                p_post_termination_rule,
                p_process_in_run_flag,
                p_processing_priority,
                p_processing_type,
                p_standard_link_flag,
                p_comment_id,
                p_description,
                p_legislation_subgroup,
                p_qualifying_age,
                p_qualifying_length_of_service,
                p_qualifying_units,
                p_reporting_name,
                p_attribute_category,
                p_attribute1,
                p_attribute2,
                p_attribute3,
                p_attribute4,
                p_attribute5,
                p_attribute6,
                p_attribute7,
                p_attribute8,
                p_attribute9,
                p_attribute10,
                p_attribute11,
                p_attribute12,
                p_attribute13,
                p_attribute14,
                p_attribute15,
                p_attribute16,
                p_attribute17,
                p_attribute18,
                p_attribute19,
                p_attribute20,
                p_element_information_category,
                p_element_information1,
                p_element_information2,
                p_element_information3,
                p_element_information4,
                p_element_information5,
                p_element_information6,
                p_element_information7,
                p_element_information8,
                p_element_information9,
                p_element_information10,
                p_element_information11,
                p_element_information12,
                p_element_information13,
                p_element_information14,
                p_element_information15,
                p_element_information16,
                p_element_information17,
                p_element_information18,
                p_element_information19,
                p_element_information20,
                c_user_id,
                sysdate,
                c_user_id,
                sysdate,
                c_login_id,
                p_third_party_pay_only_flag,
                p_retro_summ_ele_id,
                p_iterative_flag,
                p_iterative_formula_id,
                p_iterative_priority,
                p_process_mode,
                p_grossup_flag,
                p_advance_indicator,
                p_advance_payable,
                p_advance_deduction,
                p_process_advance_entry,
                p_proration_group_id,
                p_proration_formula_id,
                p_recalc_event_group_id,
                p_once_each_period_flag,
		p_time_definition_type,
		p_time_definition_id,
		p_advance_element_type_id,
		p_deduction_element_type_id);
--
-- **************************************************************************
--  insert into MLS table (TL)
--
insert into PAY_ELEMENT_TYPES_F_TL (
    ELEMENT_TYPE_ID,
    ELEMENT_NAME,
    REPORTING_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_ELEMENT_TYPE_ID,
    P_ELEMENT_NAME,
    P_REPORTING_NAME,
    P_DESCRIPTION,
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
    from PAY_ELEMENT_TYPES_F_TL T
    where T.ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
--
-- *******************************************************************************
--
-- Return the new rowid, and retrieve the newly generated element type
-- identifier into the forms row to avoid needing to requery
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.INSERT_ROW',2);
--
open csr_element_rowid;
fetch csr_element_rowid into p_rowid;
if (csr_element_rowid%notfound) then
  close csr_element_rowid;
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.INSERT_ROW');
end if;
close csr_element_rowid;
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.INSERT_ROW',3);
--
-- Create element DB items on the entity horizon
hrdyndbi.create_element_type_dict(p_element_type_id,
                                  p_effective_start_date);
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.INSERT_ROW',4);
--
-- Create pay value for payment type elements which will be processed in the
-- payroll run
if (p_process_in_run_flag = 'Y' and p_non_payments_flag = 'N') then
  -- Create pay value
  pay_input_values_pkg.insert_row (
-- change 115.10
        p_base_name             => 'Pay Value',
        p_element_type_id       => p_element_type_id,
        p_effective_start_date  => p_effective_start_date,
        p_effective_end_date    => p_effective_end_date,
        p_legislation_code      => p_legislation_code,
        p_business_group_id     => p_business_group_id,
        p_legislation_subgroup  => p_legislation_subgroup,
        p_input_value_id        => g_dummy_number,
        p_rowid                 => g_dummy_char                 );
--
end if;
--
if p_contributions_used = 'Y' then
--
-- Create default benefit input values for type A benefit plans
--
-- #282294. The value of p_generate_db_items_flag in the three following
-- calls has been temporarily changed from Y to N. This is because the US
-- startup data does not currently create a US_CONTRIBUTION_VALUES route.
-- This value must be reset to Y when the US startup data is fixed. See the
-- three lines below marked ** temp change **.
-- Temp fix removed: values reset back to 'Y'. RMF 03.07.95.
--
  pay_input_values_pkg.insert_row (
  --
        p_element_type_id       => p_element_type_id,
        p_effective_start_date  => p_effective_start_date,
        p_effective_end_date    => p_effective_end_date,
        p_legislation_code      => p_legislation_code,
        p_business_group_id     => p_business_group_id,
        p_legislation_subgroup  => p_legislation_subgroup,
        p_input_value_id        => g_dummy_number,
        p_rowid                 => g_dummy_char,
-- change 115.10
        --p_name                => 'Coverage',
        p_base_name             => 'Coverage',
        p_display_sequence      => 1,
        p_hot_default_flag      => 'N',
        p_mandatory_flag        => 'Y',
        p_lookup_type           => 'US_BENEFIT_COVERAGE',
        p_generate_db_items_flag=> 'Y',
        p_uom                   => 'C'  );
        --
  pay_input_values_pkg.insert_row (
  --
        p_element_type_id       => p_element_type_id,
        p_effective_start_date  => p_effective_start_date,
        p_effective_end_date    => p_effective_end_date,
        p_legislation_code      => p_legislation_code,
        p_business_group_id     => p_business_group_id,
        p_legislation_subgroup  => p_legislation_subgroup,
        p_input_value_id        => g_dummy_number,
        p_rowid                 => g_dummy_char,
-- change 115.10
        --p_name                => 'ER Contr',
        p_base_name             => 'ER Contr',
        p_display_sequence      => 2,
        p_hot_default_flag      => 'N',
        p_mandatory_flag        => 'N',
        p_generate_db_items_flag=> 'Y',
        p_uom                   => p_default_benefit_uom);
        --
  pay_input_values_pkg.insert_row (
  --
        p_element_type_id       => p_element_type_id,
        p_effective_start_date  => p_effective_start_date,
        p_effective_end_date    => p_effective_end_date,
        p_legislation_code      => p_legislation_code,
        p_business_group_id     => p_business_group_id,
        p_legislation_subgroup  => p_legislation_subgroup,
        p_input_value_id        => g_dummy_number,
        p_rowid                 => g_dummy_char,
-- change 115.10
        --p_name                => 'EE Contr',
        p_base_name             => 'EE Contr',
        p_display_sequence      => 3,
        p_hot_default_flag      => 'N',
        p_mandatory_flag        => 'N',
        p_generate_db_items_flag=> 'Y',
        p_uom                   => p_default_benefit_uom);
        --
end if;
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.INSERT_ROW',5);
--
pay_sub_class_rules_pkg.insert_defaults (
--
        p_element_type_id,
        p_classification_id,
        p_effective_start_date,
        p_effective_end_date,
        p_business_group_id,
        p_legislation_code);
--
-- Populate the retro component usages for the element type.
--
  pay_retro_comp_usage_internal.populate_retro_comp_usages
    (p_effective_date                => p_effective_start_date
    ,p_element_type_id               => p_element_type_id
    );
--
end insert_row;
--
--
--
--
--
--------------------------------------------------------------------------------
procedure UPDATE_ROW(
--
--******************************************************************************
--* Handles the updating of the base table for the form which is based on a    *
--* non-updatable view. It also ensures the integrity of data is maintained    *
--* according to the business rules.                                           *
--******************************************************************************
--
-- Parameters to be passed in are:
--
        -- All base table column values
        p_rowid                                 varchar2,
        p_element_type_id                       number,
        p_effective_start_date                  date,
        p_effective_end_date                    date,
        p_business_group_id                     number,
        p_legislation_code                      varchar2,
        p_formula_id                            number,
        p_input_currency_code                   varchar2,
        p_output_currency_code                  varchar2,
        p_classification_id                     number,
        p_benefit_classification_id             number,
        p_additional_entry_allowed              varchar2,
        p_adjustment_only_flag                  varchar2,
        p_closed_for_entry_flag                 varchar2,
        p_element_name                          varchar2,
        p_indirect_only_flag                    varchar2,
        p_multiple_entries_allowed              varchar2,
        p_multiply_value_flag                   varchar2,
        p_post_termination_rule                 varchar2,
        p_process_in_run_flag                   varchar2,
        p_processing_priority                   number,
        p_processing_type                       varchar2,
        p_standard_link_flag                    varchar2,
        p_comment_id                            number,
        p_description                           varchar2,
        p_legislation_subgroup                  varchar2,
        p_qualifying_age                        number,
        p_qualifying_length_of_service          number,
        p_qualifying_units                      varchar2,
        p_reporting_name                        varchar2,
        p_attribute_category                    varchar2,
        p_attribute1                            varchar2,
        p_attribute2                            varchar2,
        p_attribute3                            varchar2,
        p_attribute4                            varchar2,
        p_attribute5                            varchar2,
        p_attribute6                            varchar2,
        p_attribute7                            varchar2,
        p_attribute8                            varchar2,
        p_attribute9                            varchar2,
        p_attribute10                           varchar2,
        p_attribute11                           varchar2,
        p_attribute12                           varchar2,
        p_attribute13                           varchar2,
        p_attribute14                           varchar2,
        p_attribute15                           varchar2,
        p_attribute16                           varchar2,
        p_attribute17                           varchar2,
        p_attribute18                           varchar2,
        p_attribute19                           varchar2,
        p_attribute20                           varchar2,
        p_element_information_category          varchar2,
        p_element_information1                  varchar2,
        p_element_information2                  varchar2,
        p_element_information3                  varchar2,
        p_element_information4                  varchar2,
        p_element_information5                  varchar2,
        p_element_information6                  varchar2,
        p_element_information7                  varchar2,
        p_element_information8                  varchar2,
        p_element_information9                  varchar2,
        p_element_information10                 varchar2,
        p_element_information11                 varchar2,
        p_element_information12                 varchar2,
        p_element_information13                 varchar2,
        p_element_information14                 varchar2,
        p_element_information15                 varchar2,
        p_element_information16                 varchar2,
        p_element_information17                 varchar2,
        p_element_information18                 varchar2,
        p_element_information19                 varchar2,
        p_element_information20                 varchar2,
        p_third_party_pay_only_flag             varchar2,
	p_retro_summ_ele_id			number,
        p_iterative_flag                        varchar2,
        p_iterative_formula_id                  number,
        p_iterative_priority                    number,
        p_process_mode                          varchar2,
        p_grossup_flag                          varchar2,
        p_advance_indicator                     varchar2,
        p_advance_payable                       varchar2,
        p_advance_deduction                     varchar2,
        p_process_advance_entry                 varchar2,
        p_proration_group_id                    number,
        p_base_element_name                     varchar2,
        p_proration_formula_id			number,
        p_recalc_event_group_id			number,
        p_once_each_period_flag                 varchar2 default null,
	-- Added for FLSA Dynamic Period Allocation
	p_time_definition_type			varchar2 default null,
	p_time_definition_id			varchar2 default null,
	-- Added for Advance Pay Enhancement
	p_advance_element_type_id		number default null,
	p_deduction_element_type_id		number default null
	)
is
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.UPDATE_ROW',1);
--
update pay_element_types_f
set
element_type_id                = p_element_type_id,
effective_start_date           = p_effective_start_date,
effective_end_date             = p_effective_end_date,
business_group_id              = p_business_group_id,
legislation_code               = p_legislation_code,
formula_id                     = p_formula_id,
input_currency_code            = p_input_currency_code,
output_currency_code           = p_output_currency_code,
classification_id              = p_classification_id,
benefit_classification_id      = p_benefit_classification_id,
additional_entry_allowed_flag  = p_additional_entry_allowed,
adjustment_only_flag           = p_adjustment_only_flag,
closed_for_entry_flag          = p_closed_for_entry_flag,
-- --
element_name                   = p_base_element_name,
-- --
indirect_only_flag             = p_indirect_only_flag,
multiple_entries_allowed_flag  = p_multiple_entries_allowed,
multiply_value_flag            = p_multiply_value_flag,
post_termination_rule          = p_post_termination_rule,
process_in_run_flag            = p_process_in_run_flag,
processing_priority            = p_processing_priority,
processing_type                = p_processing_type,
standard_link_flag             = p_standard_link_flag,
comment_id                     = p_comment_id,
description                    = p_description,
legislation_subgroup           = p_legislation_subgroup,
qualifying_age                 = p_qualifying_age,
qualifying_length_of_service   = p_qualifying_length_of_service,
qualifying_units               = p_qualifying_units,
reporting_name                 = p_reporting_name,
attribute_category             = p_attribute_category,
attribute1                     = p_attribute1,
attribute2                     = p_attribute2,
attribute3                     = p_attribute3,
attribute4                     = p_attribute4,
attribute5                     = p_attribute5,
attribute6                     = p_attribute6,
attribute7                     = p_attribute7,
attribute8                     = p_attribute8,
attribute9                     = p_attribute9,
attribute10                    = p_attribute10,
attribute11                    = p_attribute11,
attribute12                    = p_attribute12,
attribute13                    = p_attribute13,
attribute14                    = p_attribute14,
attribute15                    = p_attribute15,
attribute16                    = p_attribute16,
attribute17                    = p_attribute17,
attribute18                    = p_attribute18,
attribute19                    = p_attribute19,
attribute20                    = p_attribute20,
last_update_date               = sysdate,
last_updated_by                = c_user_id,
last_update_login              = c_login_id,
element_information_category   = p_element_information_category,
element_information1           = p_element_information1,
element_information2           = p_element_information2,
element_information3           = p_element_information3,
element_information4           = p_element_information4,
element_information5           = p_element_information5,
element_information6           = p_element_information6,
element_information7           = p_element_information7,
element_information8           = p_element_information8,
element_information9           = p_element_information9,
element_information10          = p_element_information10,
element_information11          = p_element_information11,
element_information12          = p_element_information12,
element_information13          = p_element_information13,
element_information14          = p_element_information14,
element_information15          = p_element_information15,
element_information16          = p_element_information16,
element_information17          = p_element_information17,
element_information18          = p_element_information18,
element_information19          = p_element_information19,
element_information20          = p_element_information20,
third_party_pay_only_flag       = p_third_party_pay_only_flag,
retro_summ_ele_id       	= p_retro_summ_ele_id,
iterative_flag                 = p_iterative_flag,
iterative_formula_id           = p_iterative_formula_id,
iterative_priority             = p_iterative_priority,
process_mode                   = p_process_mode ,
grossup_flag                   = p_grossup_flag,
advance_indicator              = p_advance_indicator,
advance_payable                = p_advance_payable,
advance_deduction              = p_advance_deduction,
process_advance_entry          = p_process_advance_entry,
proration_group_id             = p_proration_group_id,
proration_formula_id	       = p_proration_formula_id,
recalc_event_group_id	       = p_recalc_event_group_id,
once_each_period_flag          = p_once_each_period_flag,
time_definition_type	       = p_time_definition_type,
time_definition_id	       = p_time_definition_id,
advance_element_type_id		= p_advance_element_type_id,
deduction_element_type_id	= p_deduction_element_type_id
where rowid = p_rowid;
--
if (sql%notfound) then  -- trap system errors during update
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.UPDATE_ROW');
end if;
--
--
-- ****************************************************************************************
--
--  update MLS table (TL)
--
update PAY_ELEMENT_TYPES_F_TL
set
ELEMENT_NAME                   = P_ELEMENT_NAME,
REPORTING_NAME                 = P_REPORTING_NAME,
DESCRIPTION                    = P_DESCRIPTION,
last_update_date               = sysdate,
last_updated_by                = c_user_id,
last_update_login              = c_login_id,
SOURCE_LANG                    = userenv('LANG')
where ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--
--
if (sql%notfound) then  -- trap system errors during update
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.UPDATE_TL_ROW');
end if;
--
-- ***************************************************************************************
--
end update_row;
--
--
--
--
--
--------------------------------------------------------------------------------
procedure DELETE_ROW (
--
--*********************************************************
--* Performs deletion of an element type and its children *
--*********************************************************
--
-- Parameters are:
--
        p_element_type_id       number,
        p_rowid                 varchar2,
--
        -- The priority of the element for integrity checks
        p_processing_priority   number,
--
        -- The type of deletion action being performed (Date Track)
        p_delete_mode           varchar2        default 'DELETE',
--
        -- The effective date
        p_session_date          date            default trunc (sysdate),
--
        -- The validation period for integrity checks
        p_validation_start_date date
                                default to_date ('01/01/0001','DD/MM/YYYY'),
        p_validation_end_date   date
                                default to_date ('31/12/4712','DD/MM/YYYY')
--
--
                                                        ) is
--
begin
--
if deletion_allowed (   p_element_type_id,
                        p_processing_priority,
                        p_validation_start_date,
                        p_validation_end_date,
                        p_delete_mode           ) then
--
  -- Cascade deletion through child entities
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DELETE_ROW',1);
--
  pay_input_values_pkg.parent_deleted (         p_element_type_id,
                                                p_session_date,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_delete_mode           );
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DELETE_ROW',2);
--
  ben_benefit_contributions_pkg.parent_deleted (        p_element_type_id,
                                                        p_delete_mode,
                                                        p_session_date,
                                                        c_base_table    );
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DELETE_ROW',3);
--
  pay_sub_class_rules_pkg.parent_deleted (      p_element_type_id,
                                                p_session_date,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_delete_mode,
                                                c_base_table    );
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DELETE_ROW',4);
--
  pay_status_rules_pkg.parent_deleted ( p_element_type_id,
                                        p_session_date,
                                        p_delete_mode           );
  if p_delete_mode = 'ZAP' then
    -- We need to delete the database items for the deleted element
    hrdyndbi.delete_element_type_dict (p_element_type_id);
    --
    -- We need to delete any payroll frequency rules for the element
    --
    delete from pay_ele_payroll_freq_rules
    where element_type_id = p_element_type_id;
    --
    -- Delete the child retro component usages.
    --
    pay_retro_comp_usage_internal.delete_child_retro_comp_usages
      (p_effective_date                => p_session_date
      ,p_element_type_id               => p_element_type_id
      );

  elsif p_delete_mode = 'DELETE' then
  --
  -- We need to remove any payroll frequency rules starting after the new end
  -- date
  --
  delete from pay_ele_payroll_freq_rules
  where element_type_id = p_element_type_id
  and start_date > p_session_date;
  --
  end if;
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DELETE_ROW',5);
--
  -- Delete the element itself
  delete
  from  pay_element_types_f
  where rowid   = p_rowid;
--
  if sql%notfound then -- trap system errors during deletion
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.DELETE_ROW');
  end if;
--
-- ****************************************************************************
--
-- bugfix 1229606
-- only delete data from the translated tables if the date track mode is ZAP,
-- for all other date track modes the data should remain untouched
--
if p_delete_mode = 'ZAP' then
--
-- delete from MLS table (TL)
--
  delete from PAY_ELEMENT_TYPES_F_TL
  where ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID;
--
  if sql%notfound then -- trap system errors during deletion
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.DELETE_TL_ROW');
  end if;

end if;
--
-- ****************************************************************************
--
end if;
--
end delete_row;
--
--
--
--
--
--------------------------------------------------------------------------------
procedure LOCK_ROW(
--
--******************************************************************************
--* Handles row-locking on the base table for the form which is based on a view*
--******************************************************************************
--
-- Parameters are:
        -- All base table columns
        p_rowid varchar2,
        p_element_type_id                       number,
        p_effective_start_date                  date,
        p_effective_end_date                    date,
        p_business_group_id                     number,
        p_legislation_code                      varchar2,
        p_formula_id                            number,
        p_input_currency_code                   varchar2,
        p_output_currency_code                  varchar2,
        p_classification_id                     number,
        p_benefit_classification_id             number,
        p_additional_entry_allowed              varchar2,
        p_adjustment_only_flag                  varchar2,
        p_closed_for_entry_flag                 varchar2,
--      p_element_name                          varchar2,
        p_base_element_name                          varchar2,
        p_indirect_only_flag                    varchar2,
        p_multiple_entries_allowed              varchar2,
        p_multiply_value_flag                   varchar2,
        p_post_termination_rule                 varchar2,
        p_process_in_run_flag                   varchar2,
        p_processing_priority                   number,
        p_processing_type                       varchar2,
        p_standard_link_flag                    varchar2,
        p_comment_id                            number,
        p_description                           varchar2,
        p_legislation_subgroup                  varchar2,
        p_qualifying_age                        number,
        p_qualifying_length_of_service          number,
        p_qualifying_units                      varchar2,
        p_reporting_name                        varchar2,
        p_attribute_category                    varchar2,
        p_attribute1                            varchar2,
        p_attribute2                            varchar2,
        p_attribute3                            varchar2,
        p_attribute4                            varchar2,
        p_attribute5                            varchar2,
        p_attribute6                            varchar2,
        p_attribute7                            varchar2,
        p_attribute8                            varchar2,
        p_attribute9                            varchar2,
        p_attribute10                           varchar2,
        p_attribute11                           varchar2,
        p_attribute12                           varchar2,
        p_attribute13                           varchar2,
        p_attribute14                           varchar2,
        p_attribute15                           varchar2,
        p_attribute16                           varchar2,
        p_attribute17                           varchar2,
        p_attribute18                           varchar2,
        p_attribute19                           varchar2,
        p_attribute20                           varchar2,
        p_element_information_category          varchar2,
        p_element_information1                  varchar2,
        p_element_information2                  varchar2,
        p_element_information3                  varchar2,
        p_element_information4                  varchar2,
        p_element_information5                  varchar2,
        p_element_information6                  varchar2,
        p_element_information7                  varchar2,
        p_element_information8                  varchar2,
        p_element_information9                  varchar2,
        p_element_information10                 varchar2,
        p_element_information11                 varchar2,
        p_element_information12                 varchar2,
        p_element_information13                 varchar2,
        p_element_information14                 varchar2,
        p_element_information15                 varchar2,
        p_element_information16                 varchar2,
        p_element_information17                 varchar2,
        p_element_information18                 varchar2,
        p_element_information19                 varchar2,
        p_element_information20                 varchar2,
        p_third_party_pay_only_flag             varchar2,
        p_retro_summ_ele_id             	number,
        p_iterative_flag                        varchar2,
        p_iterative_formula_id                  number,
        p_iterative_priority                    number,
        p_process_mode                          varchar2,
        p_grossup_flag                          varchar2,
        p_advance_indicator                     varchar2,
        p_advance_payable                       varchar2,
        p_advance_deduction                     varchar2,
        p_process_advance_entry                 varchar2,
        p_proration_group_id                    number,
        p_proration_formula_id			number,
        p_recalc_event_group_id			number,
        p_once_each_period_flag                 varchar2 default null,
	-- Added for FLSA Dynamic Period Allocation
	p_time_definition_type			varchar2 default null,
	p_time_definition_id			varchar2 default null,
	-- Added for Advance Pay Enhancement
	p_advance_element_type_id		number default null,
	p_deduction_element_type_id		number default null
	) is
--
cursor csr_element_type is
        select *
        from pay_element_types_f
        where rowid = p_rowid
        for update of element_type_id nowait;
--
element_record csr_element_type%rowtype;
--
-- ***************************************************************************
-- cursor for MLS
--
cursor csr_element_type_tl is
    select ELEMENT_NAME,
           REPORTING_NAME,
           DESCRIPTION,
           decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PAY_ELEMENT_TYPES_F_TL
    where ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ELEMENT_TYPE_ID nowait;
--
-- ***************************************************************************
--
-- Counter to check for locked MLS rows
--
l_count NUMBER := 0;
--
-- Bug 6411503. l_time_definition_type added.  If it is N then it will be changed to NULL
l_time_definition_type pay_element_types_f.time_definition_type%type;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.LOCK_ROW',10);
--
-- Fetching the row effectively locks it because of the 'for update' clause
open csr_element_type;
fetch csr_element_type into element_record;
--
if (csr_element_type%notfound) then -- Trap system errors
  close csr_element_type;
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.LOCK_ROW');
end if;
--
close csr_element_type;
--
/** sbilling **/
-- removed explicit lock of _TL table,
-- the MLS strategy requires that the base table is locked before update of the
-- _TL table can take place,
-- which implies it is not necessary to lock both tables.
--
-- ***************************************************************************
-- code for MLS
--
--for tlinfo in csr_element_type_tl LOOP
--   l_count := l_count+1;
--   hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.LOCK_ROW:'||to_char(l_count),15);
--    if (tlinfo.BASELANG = 'Y') then
--      if (    (tlinfo.ELEMENT_NAME = P_ELEMENT_NAME)
--          AND ((tlinfo.REPORTING_NAME = P_REPORTING_NAME)
--               OR ((tlinfo.REPORTING_NAME is null) AND (P_REPORTING_NAME is null)))
--          AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
--               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))
--      ) then
--        null;
--      else
--        hr_utility.set_message('fnd', 'form_record_changed');
--        hr_utility.raise_error;
--      end if;
--    end if;
--end loop;
--IF(l_count=0) THEN  -- We have data missing from the _TL table.
--   hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
--  hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_TYPES_PKG.LOCK_ROW');
--end if;
--
-- ***************************************************************************
--
/** sbilling **/
-- combined if statements,
-- causes locking error,
-- ie. if first set of items match then a 'return' is issued
--
        --      The following two IF statements are logically a single
        --      statement split into two parts because its length exceeds
        --      parser stack limitations. It checks to see if any column
        --      showing in the form has been changed by another user prior
        --      to this user changing it and since the row was queried
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.LOCK_ROW',20);
--

-- Bug 6411503. Checking for time_definition_type
select DECODE(element_record.time_definition_type, 'N', NULL, element_record.TIME_DEFINITION_TYPE)
  into l_time_definition_type
  from dual;

if
--
((element_record.additional_entry_allowed_flag  = p_additional_entry_allowed)
 or (element_record.additional_entry_allowed_flag is null and p_additional_entry_allowed is null))
--
and ((element_record.third_party_pay_only_flag = p_third_party_pay_only_flag) or (element_record.third_party_pay_only_flag is null and p_third_party_pay_only_flag is null))
--
and ((element_record.retro_summ_ele_id = p_retro_summ_ele_id) or (element_record.retro_summ_ele_id is null and p_retro_summ_ele_id is null))
--
and ((element_record.adjustment_only_flag = p_adjustment_only_flag) or (element_record.adjustment_only_flag is null and p_adjustment_only_flag is null))
--
and ((element_record.attribute1 = p_attribute1) or (element_record.attribute1 is null and p_attribute1 is null))
--
and ((element_record.attribute10 = p_attribute10) or (element_record.attribute10 is null and p_attribute10 is null))
--
and ((element_record.attribute11 = p_attribute11) or (element_record.attribute11 is null and p_attribute11 is null))
--
and ((element_record.attribute12 = p_attribute12) or (element_record.attribute12 is null and p_attribute12 is null))
--
and ((element_record.attribute13 = p_attribute13) or (element_record.attribute13 is null and p_attribute13 is null))
--
and ((element_record.attribute14 = p_attribute14) or (element_record.attribute14 is null and p_attribute14 is null))
--
and ((element_record.attribute15 = p_attribute15) or (element_record.attribute15 is null and p_attribute15 is null))
--
and ((element_record.attribute16 = p_attribute16) or (element_record.attribute16 is null and p_attribute16 is null))
--
and ((element_record.attribute17 = p_attribute17) or (element_record.attribute17 is null and p_attribute17 is null))
--
and ((element_record.attribute18 = p_attribute18) or (element_record.attribute18 is null and p_attribute18 is null))
--
and ((element_record.attribute19 = p_attribute19) or (element_record.attribute19 is null and p_attribute19 is null))
--
and ((element_record.attribute2 = p_attribute2) or (element_record.attribute2 is null and p_attribute2 is null))
--
and ((element_record.attribute20 = p_attribute20) or (element_record.attribute20 is null and p_attribute20 is null))
--
and ((element_record.attribute3 = p_attribute3) or (element_record.attribute3 is null and p_attribute3 is null))
--
and ((element_record.attribute4 = p_attribute4) or (element_record.attribute4 is null and p_attribute4 is null))
--
and ((element_record.attribute5 = p_attribute5) or (element_record.attribute5 is null and p_attribute5 is null))
--
and ((element_record.attribute6 = p_attribute6) or (element_record.attribute6 is null and p_attribute6 is null))
--
and ((element_record.attribute7 = p_attribute7) or (element_record.attribute7 is null and p_attribute7 is null))
--
and ((element_record.attribute8 = p_attribute8) or (element_record.attribute8 is null and p_attribute8 is null))
--
and ((element_record.attribute9 = p_attribute9) or (element_record.attribute9 is null and p_attribute9 is null))
--
and ((element_record.attribute_category = p_attribute_category) or (element_record.attribute_category is null and p_attribute_category is null))
--
and ((element_record.benefit_classification_id = p_benefit_classification_id) or (element_record.benefit_classification_id is null and p_benefit_classification_id is null))
--
and ((element_record.business_group_id = p_business_group_id) or (element_record.business_group_id is null and p_business_group_id is null))
--
and ((element_record.classification_id = p_classification_id) or (element_record.classification_id is null and p_classification_id is null))
--
and ((element_record.closed_for_entry_flag = p_closed_for_entry_flag) or (element_record.closed_for_entry_flag is null and p_closed_for_entry_flag is null))
--
and ((element_record.comment_id = p_comment_id) or (element_record.comment_id is null and p_comment_id is null))
--
and ((element_record.effective_end_date = p_effective_end_date) or (element_record.effective_end_date is null and p_effective_end_date is null))
--
and ((element_record.effective_start_date = p_effective_start_date) or (element_record.effective_start_date is null and p_effective_start_date is null))
--
and ((element_record.element_information1 = p_element_information1) or (element_record.element_information1 is null and p_element_information1 is null))
--
and ((element_record.element_information10 = p_element_information10) or (element_record.element_information10 is null and p_element_information10 is null))
--
and ((element_record.element_information11 = p_element_information11) or (element_record.element_information11 is null and p_element_information11 is null))
--
and ((element_record.element_information12 = p_element_information12) or (element_record.element_information12 is null and p_element_information12 is null))
--
and ((element_record.element_information13 = p_element_information13) or (element_record.element_information13 is null and p_element_information13 is null))
--
and ((element_record.element_information14 = p_element_information14) or (element_record.element_information14 is null and p_element_information14 is null))
--
and ((element_record.element_information15 = p_element_information15) or (element_record.element_information15 is null and p_element_information15 is null))
--
and ((element_record.element_information16 = p_element_information16) or (element_record.element_information16 is null and p_element_information16 is null))
--
and ((element_record.element_information17 = p_element_information17) or (element_record.element_information17 is null and p_element_information17 is null))
--
and ((element_record.element_information18 = p_element_information18) or (element_record.element_information18 is null and p_element_information18 is null))
--
and ((element_record.element_information19 = p_element_information19) or (element_record.element_information19 is null and p_element_information19 is null))
--
and ((element_record.element_information2 = p_element_information2) or (element_record.element_information2 is null and p_element_information2 is null))
--
--then
--         return;
--       else
--         hr_utility.set_message('fnd', 'form_record_changed');
--         hr_utility.raise_error;
--end if;
--
--hr_utility.set_location ('pay_element_types_pkg.lock_row',30);
--
--if
--
--((element_record.element_information20 = p_element_information20)
and ((element_record.element_information20 = p_element_information20)
 or (element_record.element_information20 is null and p_element_information20 is null))
--
and ((element_record.element_information3 = p_element_information3) or (element_record.element_information3 is null and p_element_information3 is null))
--
and ((element_record.element_information4 = p_element_information4) or (element_record.element_information4 is null and p_element_information4 is null))
--
and ((element_record.element_information5 = p_element_information5) or (element_record.element_information5 is null and p_element_information5 is null))
--
and ((element_record.element_information6 = p_element_information6) or (element_record.element_information6 is null and p_element_information6 is null))
--
and ((element_record.element_information7 = p_element_information7) or (element_record.element_information7 is null and p_element_information7 is null))
--
and ((element_record.element_information8 = p_element_information8)
 or (element_record.element_information8 is null and p_element_information8 is null))
--
and ((element_record.element_information9 = p_element_information9) or (element_record.element_information9 is null and p_element_information9 is null))
--
and ((element_record.element_information_category = p_element_information_category) or (element_record.element_information_category is null and p_element_information_category is null))
--and ((element_record.element_name = p_element_name) or (element_record.element_name is null and p_element_name is null))
-- --
and ((element_record.element_name = p_base_element_name) or (element_record.element_name is null and p_base_element_name is null))
-- --
and ((element_record.element_type_id = p_element_type_id) or (element_record.element_type_id is null and p_element_type_id is null))
--
and ((element_record.formula_id = p_formula_id) or (element_record.formula_id is null and p_formula_id is null))
--
and ((element_record.indirect_only_flag = p_indirect_only_flag) or (element_record.indirect_only_flag is null and p_indirect_only_flag is null))
--
and ((element_record.input_currency_code = p_input_currency_code) or (element_record.input_currency_code is null and p_input_currency_code is null))
--
and ((element_record.legislation_code = p_legislation_code) or (element_record.legislation_code is null and p_legislation_code is null))
--
and ((element_record.legislation_subgroup = p_legislation_subgroup) or (element_record.legislation_subgroup is null and p_legislation_subgroup is null))
--
and ((element_record.multiple_entries_allowed_flag = p_multiple_entries_allowed) or (element_record.multiple_entries_allowed_flag is null and p_multiple_entries_allowed is null))
--
and ((element_record.multiply_value_flag = p_multiply_value_flag) or (element_record.multiply_value_flag is null and p_multiply_value_flag is null))
--
and ((element_record.output_currency_code = p_output_currency_code) or (element_record.output_currency_code is null and p_output_currency_code is null))
--
and ((element_record.post_termination_rule = p_post_termination_rule) or (element_record.post_termination_rule is null and p_post_termination_rule is null))
--
and ((element_record.processing_priority = p_processing_priority) or (element_record.processing_priority is null and p_processing_priority is null))
--
and ((element_record.processing_type = p_processing_type) or (element_record.processing_type is null and p_processing_type is null))
--
and ((element_record.process_in_run_flag = p_process_in_run_flag) or (element_record.process_in_run_flag is null and p_process_in_run_flag is null))
--
and ((element_record.qualifying_age = p_qualifying_age) or (element_record.qualifying_age is null and p_qualifying_age is null))
--
and ((element_record.qualifying_length_of_service = p_qualifying_length_of_service) or (element_record.qualifying_length_of_service is null and p_qualifying_length_of_service is null))
--
and ((element_record.qualifying_units = p_qualifying_units) or (element_record.qualifying_units is null and p_qualifying_units is null))
--
and ((element_record.iterative_flag = p_iterative_flag) or (element_record.iterative_flag is null and p_iterative_flag is null))
--
and ((element_record.iterative_formula_id = p_iterative_formula_id) or (element_record.iterative_formula_id is null and p_iterative_formula_id is null))
--
and ((element_record.iterative_priority = p_iterative_priority) or (element_record.iterative_priority is null and p_iterative_priority is null))
--
and ((element_record.process_mode = p_process_mode) or (element_record.process_mode is null and p_process_mode is null))
--
and ((element_record.grossup_flag = p_grossup_flag) or (element_record.grossup_flag is null and p_grossup_flag is null))
--
and ((element_record.standard_link_flag = p_standard_link_flag) or (element_record.standard_link_flag is null and p_standard_link_flag is null))
--
and ((element_record.advance_indicator = p_advance_indicator) or (element_record.advance_indicator is null and p_advance_indicator is null))
--
and ((element_record.advance_payable = p_advance_payable) or (element_record.advance_payable is null and p_advance_payable is null))
--
and ((element_record.advance_deduction = p_advance_deduction) or (element_record.advance_deduction is null and p_advance_deduction is null))
--
and ((element_record.process_advance_entry = p_process_advance_entry) or (element_record.process_advance_entry is null and p_process_advance_entry is null))
--
and ((element_record.proration_group_id = p_proration_group_id) or (element_record.proration_group_id is null and p_proration_group_id is null))
--
and ((element_record.once_each_period_flag = p_once_each_period_flag) or (element_record.once_each_period_flag is null and p_once_each_period_flag is null))
--
and ((l_time_definition_type= p_time_definition_type) or (l_time_definition_type is null and p_time_definition_type is null))   -- Bug 6411503
--
and ((element_record.time_definition_id = p_time_definition_id) or (element_record.time_definition_id is null and p_time_definition_id is null))
--
and ((element_record.advance_element_type_id = p_advance_element_type_id) or (element_record.advance_element_type_id is null and p_advance_element_type_id is null))
--
and ((element_record.deduction_element_type_id = p_deduction_element_type_id) or (element_record.deduction_element_type_id is null and p_deduction_element_type_id is null))
--
then
         return;
       else
         hr_utility.set_message(0, 'FORM_RECORD_CHANGED');
         hr_utility.raise_error;
end if;
--
end lock_row;
-----------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
--
--******************************************************************************
--* Returns TRUE if more than one row exists with the parameter element type ID*
--******************************************************************************
--
-- parameters are:
--
p_element_type_id       number,
p_rowid                 varchar2,
p_error_if_true         boolean default FALSE
--
                                ) return boolean is
--
v_dated_updates boolean         := FALSE;
--
cursor csr_dated_updates is
        select 1
        from pay_element_types_f
        where element_type_id = p_element_type_id
        and rowid <> p_rowid;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DATE_EFFECTIVELY_UPDATED',1);
--
open csr_dated_updates;
fetch csr_dated_updates into g_dummy_number;
v_dated_updates := csr_dated_updates%found;
close csr_dated_updates;
--
if v_dated_updates and p_error_if_true then
  hr_utility.set_message (801,'PAY_6460_ELEMENT_NO_PROC_CORR');
  hr_utility.raise_error;
end if;
--
return v_dated_updates;
--
end date_effectively_updated;
-----------------------------------------------------------------------
function STOP_ENTRY_RULES_EXIST (
--
--*****************************************************************************
--* Returns TRUE if there are existing formula result rules for the parameter *
--* element type, whose type is stop-entry, and which are not targetting the  *
--* source element type
--*****************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_validation_start_date date    default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date    default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
--
                                        ) return boolean is
--
v_stop_entry_rules      boolean;
--
cursor csr_stop_entry_rules is
        select  null
        from    pay_formula_result_rules_f      FRR,
                pay_status_processing_rules_f   SPR
        where   p_element_type_id       = frr.element_type_id
        and     frr.result_rule_type    = 'S'
        and     spr.STATUS_PROCESSING_RULE_ID = frr.STATUS_PROCESSING_RULE_ID
        and     spr.element_type_id <> p_element_type_id
        and     spr.effective_start_date between p_validation_start_date
                                        and p_validation_end_date
        and     frr.effective_start_date between p_validation_start_date
                                        and p_validation_end_date;
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.STOP_ENTRY_RULES_EXIST',1);
--
open csr_stop_entry_rules;
fetch csr_stop_entry_rules into g_dummy_number;
v_stop_entry_rules := csr_stop_entry_rules%found;
close csr_stop_entry_rules;
--
if v_stop_entry_rules and p_error_if_true then
  hr_utility.set_message (801,'PAY_6157_ELEMENT_NO_DEL_FRR');
  hr_utility.raise_error;
end if;
--
return v_stop_entry_rules;
--
end stop_entry_rules_exist;
-----------------------------------------------------------------------
function RUN_RESULTS_EXIST (
--
--************************************************************************
--* Returns TRUE if run results exist for the parameter element type, in *
--* payroll actions during the validation period                         *
--* The driving cursors have been rewritten to allow for the removal of  *
--* the element_type_id index on pay_run_results.  The function now      *
--* relies on their being run result values present for any input value  *
--* if the element would have run results.  The only current exception   *
--* to this would be for elements with no input values.  This is handled *
--* in a different, less performant cursor.                              *
--************************************************************************
--
-- Parameters are:
--
p_element_type_id          number,
p_validation_start_date    date         default to_date ('01/01/0001',
                                                                'DD/MM/YYYY'),
p_validation_end_date      date         default to_date ('31/12/4712',
                                                                'DD/MM/YYYY'),
p_DML_action_being_checked varchar2     default 'UPDATE',
p_error_if_true            boolean      default FALSE
--
                                ) return boolean is
--
v_run_results_exist     boolean;
v_input_values_exist    boolean;
v_input_value_id        pay_input_values_f.input_value_id%type;
--
cursor csr_input_values is
  select iv.input_value_id
  from   pay_input_values_f iv
  where  iv.element_type_id = p_element_type_id;

cursor csr_run_result_values (p_input_value_id NUMBER) is
  select  1
  from    dual
  where  exists
       (select /*+ ORDERED INDEX(RESULT PAY_RUN_RESULTS_PK)
                   USE_NL(RESULT ASSIGN PAYROLL) */ 1
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

cursor csr_run_results is
  select 1
  from   dual
  where  exists
       (select /*+ INDEX(PAYROLL PAY_PAYROLL_ACTIONS_PK)
                   INDEX(ASSIGN  PAY_ASSIGNMENT_ACTIONS_PK) */ 1
        from    pay_run_results RUN,
                pay_payroll_actions PAYROLL,
                pay_assignment_actions ASSIGN
        where   run.element_type_id = p_element_type_id
        and     assign.assignment_action_id = run.assignment_action_id
        and     assign.payroll_action_id = payroll.payroll_action_id
        and     payroll.effective_date between p_validation_start_date
                                           and     p_validation_end_date);
--
begin
  hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.RUN_RESULTS_EXIST',1);
  /* Check if the element type has any input values */

  open csr_input_values;
  fetch csr_input_values into v_input_value_id;
  v_input_values_exist := csr_input_values%found;
  close csr_input_values;

  /* If input values exist use the input value to check if run result
     values exists. */

  hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.RUN_RESULTS_EXIST',5);

  if v_input_values_exist then
    hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.RUN_RESULTS_EXIST',10);
    open csr_run_result_values(v_input_value_id);
    fetch csr_run_result_values into g_dummy_number;
    v_run_results_exist := csr_run_result_values%found;
    close csr_run_result_values;
  else
    hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.RUN_RESULTS_EXIST',15);
    open csr_run_results;
    fetch csr_run_results into g_dummy_number;
    v_run_results_exist := csr_run_results%found;
    close csr_run_results;
  end if;

  hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.RUN_RESULTS_EXIST',20);
  if v_run_results_exist and p_error_if_true then
--
    if p_DML_action_being_checked = 'UPDATE' then
      hr_utility.set_message (801,'PAY_6909_ELEMENT_NO_UPD_RR');
--
    elsif p_DML_action_being_checked = 'DELETE' then
      hr_utility.set_message (801,'PAY_6242_ELEMENTS_NO_DEL_RR');
--
    end if;
--
    hr_utility.raise_error;
--
  end if;
--
return v_run_results_exist;
--
end run_results_exist;
-----------------------------------------------------------------------
function FED_BY_INDIRECT_RESULTS (
--
--*****************************************************************************
--* Returns TRUE if the parameter element type has input values which are fed *
--* by results from other element types' input values                         *
--*****************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_validation_start_date date    default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date    default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
                                                ) return boolean is
--
v_fed_by_indirect_results       boolean;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.FED_BY_INDIRECT_RESULTS',1);
--
-- Find formula result rules of type Indirect ('I')
open g_csr_result_rules (       p_element_type_id,
                                p_validation_start_date,
                                p_validation_end_date,
                                'I'                     );
--
fetch g_csr_result_rules into g_dummy_number;
v_fed_by_indirect_results := g_csr_result_rules%found;
close g_csr_result_rules;
--
-- bug 374841.Invalid message number 69012 changed to 6912.19-JUN-1996 mlisieck
if v_fed_by_indirect_results and p_error_if_true then
  hr_utility.set_message (801,'PAY_6912_ELEMENT_NO_FRR_UPD');
  hr_utility.raise_error;
end if;
--
return v_fed_by_indirect_results;
--
end fed_by_indirect_results;
-----------------------------------------------------------------------
function UPDATE_RECURRING_RULES_EXIST (
--
--**************************************************************************
--* Returns TRUE if the parameter element type has input values which are  *
--* subject to result rules of type update-recurring during the validation *
--* period, and the source element is different from the target element.   *
--**************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_validation_start_date date,
p_validation_end_date   date,
p_error_if_true         boolean default FALSE
--
                                ) return boolean is
--
v_update_recurring              boolean := FALSE;
v_status_processing_rule_id     number;
v_element_type_id               number;
--
cursor csr_source_element is
        select  element_type_id
        from    pay_status_processing_rules_f
        where   element_type_id                 = v_element_type_id
        and     status_processing_rule_id       = v_status_processing_rule_id;
        --
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.UPDATE_RECURRING_RULES_EXIST',1);
--
-- Find formula result rules of type Update Recurring ('U')
open g_csr_result_rules (       p_element_type_id,
                                p_validation_start_date,
                                p_validation_end_date,
                                p_rule_type => 'U'                      );
--
fetch g_csr_result_rules into v_status_processing_rule_id;
--
if g_csr_result_rules%found then
  --
  open csr_source_element;
  fetch csr_source_element into v_element_type_id;
  v_update_recurring := (csr_source_element%found
                        and v_element_type_id <> p_element_type_id);
  close csr_source_element;
  --
end if;
--
close g_csr_result_rules;
--
if v_update_recurring and p_error_if_true then
  hr_utility.set_message (801,'HR_6954_PAY_ELE_NO_UPD_REC');
  hr_utility.raise_error;
end if;
--
return v_update_recurring;
--
end update_recurring_rules_exist;
--
--
--
--
--
-----------------------------------------------------------------------------
function ELEMENT_USED_AS_PAY_BASIS (
--
p_element_type_id       number,
p_error_if_true         boolean default FALSE) return boolean is
--
--*************************************************************************
--* Returns TRUE if the element has an input value which is used as a pay
--* basis.
--*************************************************************************
--
v_pay_basis_element     boolean := FALSE;
--
cursor csr_pay_basis is
        select  1
        from    per_pay_bases           BASIS,
                pay_input_values_f      IV
        where   iv.input_value_id = basis.input_value_id
        and     iv.element_type_id = p_element_type_id;
        --
begin
--
open csr_pay_basis;
fetch csr_pay_basis into g_dummy_number;
v_pay_basis_element := csr_pay_basis%found;
close csr_pay_basis;
--
if v_pay_basis_element and p_error_if_true then
  --
  hr_utility.set_message (801, 'PAY_6965_INPVAL_NO_DEL_SB');
  hr_utility.raise_error;
  --
end if;
--
return v_pay_basis_element;
--
end element_used_as_pay_basis;
-----------------------------------------------------------------------------
procedure CHECK_RELATIONSHIPS (
--
--*************************************************************************
--* Checks all relationships required to establish various forms item     *
--* properties. This simply saves FORMS from having to call each of this  *
--* procedure's called functions separately and thus cuts down on network *
--* traffic                                                               *
--*************************************************************************
--
-- Parameters are:
--
        p_element_type_id       number,
        p_rowid                 varchar2,
--
        -- Validation period
        p_validation_start_date date
                                default to_date ('01/01/0001','DD/MM/YYYY'),
        p_validation_end_date   date
                                default to_date ('31/12/4712','DD/MM/YYYY'),
--
        -- The results of the relationship checks must be passed back
        p_run_results                   out     nocopy boolean,
        p_element_links                 out     nocopy boolean,
        p_indirect_results              out     nocopy boolean,
        p_dated_updates                 out     nocopy boolean,
        p_update_recurring              out     nocopy boolean,
        p_pay_basis                     out     nocopy boolean,
        p_stop_entry_rules              out     nocopy boolean) is
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',1);
--
-- Perform individual checks and place results directly in the OUT parameters
--
p_run_results           := run_results_exist (  p_element_type_id,
                                                p_validation_start_date,
                                                p_validation_end_date);
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',2);
--
p_element_links         := links_exist (        p_element_type_id,
                                                p_validation_start_date,
                                                p_validation_end_date   );

--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',3);
--
p_indirect_results      := fed_by_indirect_results (    p_element_type_id,
                                                        p_validation_start_date,
                                                        p_validation_end_date);
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',4);
--
p_dated_updates         := date_effectively_updated (   p_element_type_id,
                                                        p_rowid);
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',5);
--
p_stop_entry_rules      := stop_entry_rules_exist (     p_element_type_id,
                                                        p_validation_start_date,
                                                        p_validation_end_date);
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',6);
--
p_update_recurring      := update_recurring_rules_exist (p_element_type_id,
                                                        p_validation_start_date,
                                                        p_validation_end_date);
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.CHECK_RELATIONSHIPS',6);
--
p_pay_basis     := element_used_as_pay_basis (p_element_type_id);
--
end check_relationships;
--
--
--
--
--
-----------------------------------------------------------------------------
function ELEMENT_IS_IN_AN_ELEMENT_SET (
--
--**************************************************************
--* Returns TRUE if the parameter element is in an element set *
--**************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_error_if_true         boolean default FALSE
                                                ) return boolean is
--
v_in_set        boolean := FALSE;
--
cursor csr_element_set is
        select  null
        from    pay_element_type_rules
        where   element_type_id = p_element_type_id;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.ELEMENT_IS_IN_AN_ELEMENT_SET',1);
--
open csr_element_set;
fetch csr_element_set into g_dummy_number;
v_in_set := csr_element_set%found;
close csr_element_set;
--
if v_in_set and p_error_if_true then
  hr_utility.set_message (801,'PAY_6713_ELEMENT_NO_DEL_RULE');
  hr_utility.raise_error;
end if;
--
return v_in_set;
--
end element_is_in_an_element_set;
--
--
--
--
--
-----------------------------------------------------------------------------
function LINKS_EXIST (
--
--***************************************************************************
--* Returns TRUE if the parameter element type has element links during the *
--* validation period                                                       *
--***************************************************************************
--
-- Parameters are:
--
p_element_type_id               number,
p_validation_start_date         date            default to_date ('01/01/0001',
                                                                'DD/MM/YYYY'),
p_validation_end_date           date            default to_date ('31/12/4712',
                                                                'DD/MM/YYYY'),
p_DML_action_being_checked      varchar2        default 'UPDATE',
p_error_if_true                 boolean         default FALSE
--
                                ) return boolean is
--
v_links_exist   boolean;
--
cursor csr_links is
        select  1
        from    pay_element_links_f
        where   element_type_id         = p_element_type_id
        and     effective_end_date      >= p_validation_start_date
        and     effective_start_date    <= p_validation_end_date;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.LINKS_EXIST',1);
--
open csr_links;
fetch csr_links into g_dummy_number;
v_links_exist := csr_links%found;
close csr_links;
--
if v_links_exist and p_error_if_true then
  if p_DML_action_being_checked = 'UPDATE' then
    hr_utility.set_message (801,'PAY_6147_ELEMENT_LINK_UPDATE');
--
  elsif p_DML_action_being_checked = 'DELETE' then
    hr_utility.set_message (801,'PAY_6155_ELEMENT_NO_DEL_LINK');
--
  end if;
  hr_utility.raise_error;
end if;
--
return v_links_exist;
--
end links_exist;
--
--
--
--
--
-----------------------------------------------------------------------------
function ACCRUAL_PLAN_EXISTS (
--
--***************************************************************************
--* Returns TRUE if there are accrual plans for the parameter element type
--***************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_error_if_true         boolean default FALSE) return boolean is
--
v_accrual_exists        boolean := FALSE;
--
cursor csr_accrual is
        select  null
        from    pay_accrual_plans
        where   accrual_plan_element_type_id = p_element_type_id;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.ACCRUAL_PLAN_EXISTS',1);
--
open csr_accrual;
fetch csr_accrual into g_dummy_number;
v_accrual_exists := csr_accrual%found;
close csr_accrual;
--
if v_accrual_exists and p_error_if_true then
  hr_utility.set_message (801,'PAY_35560_ELT_NO_DEL_ACCRUAL');
  hr_utility.raise_error;
end if;
--
return v_accrual_exists;
--
end accrual_plan_exists;
--
--
--
--
--
-----------------------------------------------------------------------------
function COBRA_BENEFITS_EXIST (
--
--***************************************************************************
--* Returns TRUE if there are COBRA benefits for the parameter element type *
--* within the validation period                                            *
--***************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_validation_start_date date    default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date    default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
                                                ) return boolean is
--
v_cobra_exists  boolean := FALSE;
--
cursor csr_cobra is
        select  null
        from    per_cobra_coverage_benefits_f
        where   element_type_id          = p_element_type_id
        and     effective_start_date    <= p_validation_end_date
        and     effective_end_date      >= p_validation_start_date;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.COBRA_BENEFITS_EXIST',1);
--
open csr_cobra;
fetch csr_cobra into g_dummy_number;
v_cobra_exists := csr_cobra%found;
close csr_cobra;
--
if v_cobra_exists and p_error_if_true then
  hr_utility.set_message (801,'PAY_COBRA_BENS_NO_DEL');
  hr_utility.raise_error;
end if;
--
return v_cobra_exists;
--
end cobra_benefits_exist;
--
--
--
--
--
-----------------------------------------------------------------------------
function benefit_contributions_exist (
--
--*****************************************************************************
--* Returns TRUE if there are benefit contributions which refer to the
--* specified element.
--*****************************************************************************
--
p_element_type_id       number,
p_validation_start_date date,
p_validation_end_date   date,
p_error_if_true         boolean default FALSE) return boolean is
--
v_contribution_exists   boolean := FALSE;
--
cursor csr_contribution is
        select  1
        from    ben_benefit_contributions_f
        where   element_type_id = p_element_type_id
        and     effective_start_date    <= p_validation_end_date
        and     effective_end_date      >= p_validation_start_date;
        --
begin
--
hr_utility.set_location
('PAY_ELEMENT_TYPES_PKG.benefit_contributions_exist',1);
--
open csr_contribution;
fetch csr_contribution into g_dummy_number;
v_contribution_exists := csr_contribution%found;
close csr_contribution;
--
if v_contribution_exists and p_error_if_true then
  hr_utility.set_message (801,'');
  hr_utility.raise_error;
end if;
--
return v_contribution_exists;
--
end benefit_contributions_exist;
-----------------------------------------------------------------------------
function DELETION_ALLOWED (
--
--*****************************************************************************
--* Returns TRUE if all the business rules relating to deletion of an element *
--* type are complied with for the parameter element or else returns an error *
--*****************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_processing_priority   number,
p_validation_start_date date    default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date    default to_date ('31/12/4712','DD/MM/YYYY'),
p_delete_mode           varchar2 default 'ZAP'
                                                ) return boolean is
--
v_deletion_allowed      boolean := TRUE;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.DELETION_ALLOWED',1);
--
-- Check business rules relating to deletion of element type
--
if (p_delete_mode = 'DELETE_NEXT_CHANGE'
  and priority_result_rule_violated (   p_element_type_id,
                                        p_processing_priority,
                                        p_validation_start_date,
                                        p_validation_end_date,
                                        p_error_if_true => TRUE))
--
or (p_delete_mode <> 'DELETE_NEXT_CHANGE'
--
  and (links_exist (    p_element_type_id,
                        p_validation_start_date,
                        p_validation_end_date,
                        p_DML_action_being_checked => 'DELETE',
                        p_error_if_true => TRUE)
-- Bug # 4991482 : Added to raise an error message if any run results exists.
	or run_results_exist (  p_element_type_id,
                          p_validation_start_date,
                          p_validation_end_date,
			  p_DML_action_being_checked => 'DELETE',
                          p_error_if_true => TRUE)
--
	or cobra_benefits_exist (p_element_type_id,
                                p_validation_start_date,
                                p_validation_end_date,
                                p_error_if_true => TRUE)
--
	or (p_delete_mode = 'ZAP'
--
	    and (element_is_in_an_element_set ( p_element_type_id,
                                        p_error_if_true => TRUE)
                                        --
		or element_used_as_pay_basis (p_element_type_id,
                                        p_error_if_true => TRUE)
        --
		or benefit_contributions_exist (p_element_type_id,
                                        p_validation_start_date,
                                        p_validation_end_date,
                                        p_error_if_true => TRUE)
                                        --
		or accrual_plan_exists (        p_element_type_id,
                                        p_error_if_true => TRUE)
                                        --
		or stop_entry_rules_exist (      p_element_type_id,
                                        p_error_if_true => TRUE)
                )
	    )
	or pay_input_values_pkg.cant_delete_all_input_values (
                                        --
                                        p_element_type_id,
                                        p_delete_mode,
                                        p_validation_start_date,
                                        p_validation_end_date,
                                        p_error_if_true => TRUE)
	)
   )
or dt_api.rows_exist(
     p_base_table_name => 'ben_acty_base_rt_f',
     p_base_key_column => 'element_type_id',
     p_base_key_value  => p_element_type_id,
     p_from_date       => p_validation_start_date,
     p_to_date         => p_validation_end_date
   )
THEN
  v_deletion_allowed := FALSE;
--
END IF;
--

return v_deletion_allowed;
--
end deletion_allowed;
--
--
--
--
--
-----------------------------------------------------------------------------
function ELEMENT_PRIORITY_TOO_HIGH (
--
--****************************************************************************
--* Returns TRUE if an element has a priority higher than an element it feeds*
--****************************************************************************
--
-- Parameters are:
--
        p_element_type_id       number,
--
        -- The priority of the element being checked
        p_processing_priority   number,
--
        -- The validation period
        p_validation_start_date date
                                default to_date ('01/01/0001','DD/MM/YYYY'),
        p_validation_end_date   date
                                default to_date ('31/12/4712','DD/MM/YYYY')
--
                                ) return boolean is
--
v_priority_too_high     boolean := FALSE;
--
cursor csr_elements_fed_by_this_one is
--
        /*      Returns a row if there are any elements whose input
                values rely on the output from the parameter element,
                and which have a lower priority than the parameter
                priority (not allowed)                                  */
--
select  1
from    pay_status_processing_rules_f   STATUS,
        pay_formula_result_rules_f      RESULT,
        pay_input_values_f              INPUT,
        pay_element_types_f             ELEMENT
where   status.status_processing_rule_id = result.status_processing_rule_id
and     result.input_value_id                   =  input.input_value_id
and     input.element_type_id                   =  element.element_type_id
and     result.result_rule_type                 =  'I'
and     status.element_type_id                  =  p_element_type_id
and     element.element_type_id                 <> p_element_type_id
and     element.processing_priority             <  p_processing_priority
and     (status.effective_end_date              >= p_validation_start_date
        and status.effective_start_date         <= p_validation_end_date)
and     (result.effective_end_date              >= p_validation_start_date
        and result.effective_start_date         <= p_validation_end_date);
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.ELEMENT_PRIORITY_TOO_HIGH',1);
--
open csr_elements_fed_by_this_one;
fetch csr_elements_fed_by_this_one into g_dummy_number;
v_priority_too_high := csr_elements_fed_by_this_one%found;
close csr_elements_fed_by_this_one;
--
return v_priority_too_high;
--
end element_priority_too_high;
--
--
--
--
--
-------------------------------------------------------------------------------
function ELEMENT_PRIORITY_TOO_LOW (
--
--***************************************************************************
--* Returns TRUE if the parameter element has a priority lower than that of *
--* an element whose input value results feed it                            *
--***************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_processing_priority   number,
p_validation_start_date date    default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date    default to_date ('31/12/4712','DD/MM/YYYY')
--
                                                ) return boolean is
--
v_priority_too_low      boolean := FALSE;
--
cursor csr_elements_feeding_this_one is
--
        /*      Returns a row if there are elements whose output feed
                input values of the parameter element and which have a
                priority higher than the parameter priority
                (not allowed)                                           */
--
  select 1
  from  pay_status_processing_rules_f   STATUS,
        pay_formula_result_rules_f      RESULT,
        pay_input_values_f              INPUT,
        pay_element_types_f             ELEMENT
  where result.input_value_id           =  input.input_value_id
  and   status.element_type_id          =  element.element_type_id
  and   result.status_processing_rule_id=  status.status_processing_rule_id
  and   result.result_rule_type         = 'I'
  and   input.element_type_id           =  p_element_type_id
  and   element.element_type_id         <> p_element_type_id
  and   element.processing_priority     >  p_processing_priority
  and   (status.effective_end_date      >= p_validation_start_date
        and status.effective_start_date <= p_validation_end_date)
  and   (result.effective_end_date      >= p_validation_start_date
         and result.effective_start_date<= p_validation_end_date);
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.ELEMENT_PRIORITY_TOO_LOW',1);
--
open csr_elements_feeding_this_one;
fetch csr_elements_feeding_this_one into g_dummy_number;
v_priority_too_low := csr_elements_feeding_this_one%found;
close csr_elements_feeding_this_one;
--
return v_priority_too_low;
--
end element_priority_too_low;
--
--
--
--
--
---------------------------------------------------------------------------
function PRIORITY_RESULT_RULE_VIOLATED (
--
--*****************************************************************************
--* Returns TRUE if either                                                    *
--* 1.  The element will be processed in a payroll run before an element whose*
--*     results are needed to process it                                      *
--* or                                                                        *
--* 2.  The element will be processed in a run after an element which needs   *
--*     the results produced                                                  *
--*****************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_processing_priority   number,
p_validation_start_date date    default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date   date    default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true         boolean default FALSE
--
                                ) return boolean is
--
v_priority_rule_violated        boolean := FALSE;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.PRIORITY_RESULT_RULE_VIOLATED',1);
--
if element_priority_too_high    (       p_element_type_id,
                                        p_processing_priority,
                                        p_validation_start_date,
                                        p_validation_end_date   )
--
or element_priority_too_low     (       p_element_type_id,
                                        p_processing_priority,
                                        p_validation_start_date,
                                        p_validation_end_date   ) then
--
  v_priority_rule_violated := TRUE;
--
  if v_priority_rule_violated and p_error_if_true then
    hr_utility.set_message (801,'PAY_6149_ELEMENT_PRIORITY_UPD');
    hr_utility.raise_error;
  end if;
--
end if;
--
return v_priority_rule_violated;
--
end priority_result_rule_violated;
--
--
--
--
--
-------------------------------------------------------------------------------
function NAME_IS_NOT_UNIQUE (
--
--******************************************************************************
--* Returns TRUE if the element name has been duplicated within business group *
--* and legislation code. If the name is the only parameter, then the check    *
--* will return TRUE if the name is not unique within the generic data set.    *
--******************************************************************************
--
-- Parameters are:
--
p_element_name          varchar2,
p_element_type_id       number          default null,
p_business_group_id     number          default null,
p_legislation_code      varchar2        default null,
p_error_if_true         boolean         default FALSE
--
                                ) return boolean is
--
v_name_duplicated       boolean := FALSE;
--
cursor csr_duplicate is
        select  null
        from    pay_element_types_f et,
                pay_element_types_f_tl et_tl
        where   upper(translate(p_element_name,'x_','x '))
                                 = upper(translate(et_tl.element_name,'x_','x '))
        and     (et.element_type_id <> p_element_type_id
                or p_element_type_id is null)
        and     (       p_business_group_id = et.business_group_id + 0
                or  (   et.business_group_id is null
                        and p_legislation_code = et.legislation_code ))
        and     et_tl.element_type_id = et.element_type_id
        and     et_tl.language        = userenv('LANG');
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.NAME_IS_NOT_UNIQUE',1);
--
open csr_duplicate;
fetch csr_duplicate into g_dummy_number;
v_name_duplicated := csr_duplicate%found;
close csr_duplicate;
--
if v_name_duplicated and p_error_if_true then
  hr_utility.set_message (801,'PAY_6137_ELEMENT_DUP_NAME');
  hr_utility.raise_error;
end if;
--
return v_name_duplicated;
--
end name_is_not_unique;
--
--
--
--
--
-----------------------------------------------------------------------------
function ELEMENT_START_DATE (p_element_type_id number) return date is
--
--******************************************************************************
--* Returns the minimum start date for a given element                         *
--******************************************************************************
--
cursor csr_date is
        select  min (effective_start_date)
        from    pay_element_types_f
        where   element_type_id = p_element_type_id;
--
v_start_date    date;
--
begin
--
open csr_date;
fetch csr_date into v_start_date;
close csr_date;
--
return v_start_date;
--
end element_start_date;
--------------------------------------------------------------------------------
function ELEMENT_END_DATE (p_element_type_id number) return date is
--
--******************************************************************************
--* Returns the maximum end date for a given element                           *
--******************************************************************************
--
cursor csr_end_date is
        select  max (effective_end_date)
        from    pay_element_types_f
        where   element_type_id = p_element_type_id;
--
v_end_date      date;
--
begin
--
open csr_end_date;
fetch csr_end_date into v_end_date;
close csr_end_date;
--
return v_end_date;
--
end element_end_date;
-----------------------------------------------------------------------------
function ELEMENT_ENTRIES_EXIST (p_element_type_id       number,
                                p_error_if_true         boolean default FALSE)
return boolean is
--
--******************************************************************************
--* Returns TRUE if there are element entries which use the link belonging to  *
--* the parameter element type.                                                *
--******************************************************************************
--
v_entries_exist boolean :=FALSE;
--
cursor csr_entries is
        select  null
        from    pay_element_entries_f   ENTRY,
                pay_element_links_f     LINK
        where   link.element_link_id    = entry.element_link_id
        and     link.element_type_id    = p_element_type_id;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_TYPES_PKG.ELEMENT_ENTRIES_EXIST',1);
--
open csr_entries;
fetch csr_entries into g_dummy_number;
v_entries_exist := csr_entries%found;
close csr_entries;
--
if v_entries_exist and p_error_if_true then
  hr_utility.set_message (801,'PAY_6197_INPVAL_NO_ENTRY');
  hr_utility.raise_error;
end if;
--
return v_entries_exist;
--
end element_entries_exist;
--
--
--
--
--
-----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_ELEMENT_TYPES_F_TL T
  where not exists
    (select NULL
    from PAY_ELEMENT_TYPES_F B
    where B.ELEMENT_TYPE_ID = T.ELEMENT_TYPE_ID
    );

  update PAY_ELEMENT_TYPES_F_TL T set (
      ELEMENT_NAME,
      REPORTING_NAME,
      DESCRIPTION
    ) = (select
      B.ELEMENT_NAME,
      B.REPORTING_NAME,
      B.DESCRIPTION
    from PAY_ELEMENT_TYPES_F_TL B
    where B.ELEMENT_TYPE_ID = T.ELEMENT_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ELEMENT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ELEMENT_TYPE_ID,
      SUBT.LANGUAGE
    from PAY_ELEMENT_TYPES_F_TL SUBB, PAY_ELEMENT_TYPES_F_TL SUBT
    where SUBB.ELEMENT_TYPE_ID = SUBT.ELEMENT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ELEMENT_NAME <> SUBT.ELEMENT_NAME
      or SUBB.REPORTING_NAME <> SUBT.REPORTING_NAME
      or (SUBB.REPORTING_NAME is null and SUBT.REPORTING_NAME is not null)
      or (SUBB.REPORTING_NAME is not null and SUBT.REPORTING_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PAY_ELEMENT_TYPES_F_TL (
    ELEMENT_TYPE_ID,
    ELEMENT_NAME,
    REPORTING_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ELEMENT_TYPE_ID,
    B.ELEMENT_NAME,
    B.REPORTING_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_ELEMENT_TYPES_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_ELEMENT_TYPES_F_TL T
    where T.ELEMENT_TYPE_ID = B.ELEMENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-----------------------------------------------------------------------------
procedure unique_chk(X_E_ELEMENT_NAME in VARCHAR2,X_E_LEGISLATION_CODE in VARCHAR2,
                     X_E_EFFECTIVE_START_DATE in date, X_E_EFFECTIVE_END_DATE in date)
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM pay_element_types_f
  WHERE nvl(ELEMENT_NAME,'~null~') = nvl(X_E_ELEMENT_NAME,'~null~')
    and nvl(LEGISLATION_CODE,'~null~') = nvl(X_E_LEGISLATION_CODE,'~null~')
    and EFFECTIVE_START_DATE = X_E_EFFECTIVE_START_DATE
    and EFFECTIVE_end_DATE = X_E_EFFECTIVE_END_DATE
    and X_E_EFFECTIVE_START_DATE is not NULL
    and X_E_EFFECTIVE_END_DATE is not NULL
    and BUSINESS_GROUP_ID is NULL;
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_ELEMENT_TYPES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_ELEMENT_TYPES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
end unique_chk;
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_E_ELEMENT_NAME in varchar2,
   X_E_LEGISLATION_CODE in varchar2,
   X_E_EFFECTIVE_START_DATE in date,
   X_E_EFFECTIVE_END_DATE in date,
   X_ELEMENT_NAME in varchar2,
   X_REPORTING_NAME in varchar2,
   X_DESCRIPTION in varchar2,
   X_OWNER in varchar2 ) is
--
-- Fetch the element_type_id. This used to be a sub-query in the update
-- statement.
--
cursor csr_ele_id is
select element_type_id
from   pay_element_types_f
where  nvl(ELEMENT_NAME,'~null~') = nvl(X_E_ELEMENT_NAME,'~null~')
and    nvl(LEGISLATION_CODE,'~null~') = nvl(X_E_LEGISLATION_CODE,'~null~')
and    EFFECTIVE_START_DATE = X_E_EFFECTIVE_START_DATE
and    EFFECTIVE_end_DATE = X_E_EFFECTIVE_END_DATE
and    X_E_EFFECTIVE_START_DATE is not NULL
and    X_E_EFFECTIVE_END_DATE is not NULL
and    BUSINESS_GROUP_ID is NULL
;
--
-- Fetch information for the _TL rows that will be affected by the update.
--
cursor csr_tl_info
(p_element_type_id in number
,p_language        in varchar2
) is
select element_name
,      language
from   pay_element_types_f_tl
where  element_type_id = p_element_type_id
and    p_language in (language, source_lang)
;
--
l_element_type_id number;
l_found           boolean;
i                 binary_integer := 1;
l_langs           dbms_sql.varchar2s;
l_lang            varchar2(100);
begin
  --
  -- Fetch the element_type_id.
  --
  open  csr_ele_id;
  fetch csr_ele_id
  into  l_element_type_id
  ;
  l_found := csr_ele_id%found;
  close csr_ele_id;

  l_lang := userenv('LANG');

  if l_found then
    --
    -- Check if database item translations are supported.
    --
    if ff_dbi_utils_pkg.translations_supported
       (p_legislation_code => x_e_legislation_code
       ) then
      for crec in  csr_tl_info
                   (p_element_type_id => l_element_type_id
                   ,p_language        => l_lang
                   ) loop
        if upper(crec.element_name) <> upper(x_element_name) then
          l_langs(i) := crec.language;
          i := i + 1;
        end if;
      end loop;
    end if;

    UPDATE pay_element_types_f_tl
    SET    element_name = nvl(x_element_name,element_name),
           reporting_name = nvl(x_reporting_name,reporting_name),
           description = nvl(x_description,description),
           last_update_date = SYSDATE,
           last_updated_by = decode(x_owner,'SEED',1,0),
           last_update_login = 0,
           source_lang = l_lang
    WHERE  l_lang IN (language,source_lang)
    AND    element_type_id  = l_element_type_id
    ;

    --
    -- Write any changes to PAY_DYNDBI_CHANGES.
    --
    if l_langs.count <> 0 then
      pay_dyndbi_changes_pkg.element_type_change
      (p_element_type_id => l_element_type_id
      ,p_languages       => l_langs
      );
    end if;
  end if;
end TRANSLATE_ROW;
--------------------------------------------------------------------------------
begin

c_user_id := fnd_global.user_id;
c_login_id := fnd_global.login_id;

end PAY_ELEMENT_TYPES_PKG;

/
