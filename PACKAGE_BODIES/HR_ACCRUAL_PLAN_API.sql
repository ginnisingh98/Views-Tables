--------------------------------------------------------
--  DDL for Package Body HR_ACCRUAL_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ACCRUAL_PLAN_API" as
/* $Header: hrpapapi.pkb 120.1.12010000.1 2008/07/28 03:37:25 appldev ship $ */
--
-- Package Variables
--
g_package  CONSTANT varchar2(33) := 'hr_accrual_plan_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element >------------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        create_element
--
--    DESCRIPTION calls the function PAY_DB_PAY_SETUP.CREATE_ELEMENT,The sole
--                reason for this is to cut down on space and reduce the margin
--                for errors in the call, passing only the things that change.
--
--    NOTES       anticipate the only use for this is to be called from the
--                pre_insert routine.
--
FUNCTION create_element(p_element_name          IN varchar2,
                        p_element_description   IN varchar2,
                        p_processing_type       IN varchar2,
                        p_bg_name               IN varchar2,
                        p_classification_name   IN varchar2,
                        p_legislation_code      IN varchar2,
                        p_currency_code         IN varchar2,
                        p_post_termination_rule IN varchar2,
			p_mult_entries_allowed  IN varchar2,
                        p_indirect_only_flag    IN varchar2,
                        p_formula_id            IN number,
                        p_processing_priority   IN number) return number is
--
  l_effective_start_date date;
  l_effective_end_date   date;
  l_element_type_id      number;
  l_proc                 varchar2(72);
--
Begin
--
  l_proc := g_package||'create_element';
  hr_utility.set_location('Entering:'||l_proc, 5);

  l_effective_start_date := hr_general.start_of_time;
  l_effective_end_date   := hr_general.end_of_time;
--
  l_element_type_id := PAY_DB_PAY_SETUP.create_element
      (p_element_name           => p_element_name,
       p_description            => p_element_description,
       p_reporting_name         => '',
       p_classification_name    => p_classification_name,
       p_input_currency_code    => p_currency_code,
       p_output_currency_code   => p_currency_code,
       p_processing_type        => p_processing_type,
       p_mult_entries_allowed   => p_mult_entries_allowed,
       p_formula_id             => p_formula_id,
       p_processing_priority    => p_processing_priority,
       p_closed_for_entry_flag  => 'N',
       p_standard_link_flag     => 'N',
       p_qual_length_of_service => '',
       p_qual_units             => '',
       p_qual_age               => '',
       p_process_in_run_flag    => 'Y',
       p_post_termination_rule  => p_post_termination_rule,
       p_indirect_only_flag     => p_indirect_only_flag,
       p_adjustment_only_flag   => 'N',
       p_add_entry_allowed_flag => 'N',
       p_multiply_value_flag    => 'N',
       p_effective_start_date   => l_effective_start_date,
       p_effective_end_date     => l_effective_end_date,
       p_business_group_name    => p_bg_name,
       p_legislation_code       => p_legislation_code,
       p_legislation_subgroup   => '');
--
  hr_utility.set_location('Leaving:'||l_proc, 10);

  return l_element_type_id;
--
end create_element;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_input_value >-------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME
--      Create_input_value
--
--    DESCRIPTION
--      Performs all that is required to create an input value -
--
--                *  create the input value
--
--                *  validate the values
--
--                *  create the DBI'd, balance feeds, etc
--
--    NOTES
--      Anticipate the only use for this is to be called from the
--      pre_insert_actions routine in this package.
--
FUNCTION create_input_value(p_element_name              IN varchar2,
                            p_input_value_name          IN varchar2,
                            p_uom_code                  IN varchar2,
                            p_bg_name                   IN varchar2,
                            p_element_type_id           IN number,
                            p_primary_classification_id IN number,
                            p_business_group_id         IN number,
                            p_recurring_flag            IN varchar2,
                            p_legislation_code          IN varchar2,
                            p_classification_type       IN varchar2,
			    p_mandatory_flag            IN varchar2)
   RETURN number IS
--
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_input_value_id        number;
  l_generate_db_item_flag varchar2(5);
  l_proc                  varchar2(72);
--
Begin
--
  l_generate_db_item_flag := 'Y';
  l_proc                  := g_package||'create_input_value';
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  select least(effective_start_date),
         greatest(effective_end_date)
  into l_effective_start_date,
       l_effective_end_date
  from pay_element_types_f
  where element_type_id = p_element_type_id;

  if p_recurring_flag = 'N' and
     (p_uom_code like 'D%' or p_uom_code = 'C') then
  --
    l_generate_db_item_flag := 'N';
  --
  end if;
--
l_input_value_id := pay_db_pay_setup.create_input_value(
      p_element_name              => p_element_name,
      p_name                      => p_input_value_name,
      p_uom                       => '',
      p_uom_code                  => p_uom_code,
      p_mandatory_flag            => p_mandatory_flag,
      p_generate_db_item_flag     => l_generate_db_item_flag,
      p_default_value             => '',
      p_min_value                 => '',
      p_max_value                 => '',
      p_warning_or_error          => '',
      p_lookup_type               => '',
      p_formula_id                => '',
      p_hot_default_flag          => 'N',
      p_display_sequence          => 1,
      p_business_group_name       => p_bg_name,
      p_effective_start_date      => l_effective_start_date,
      p_effective_end_date        => l_effective_end_date);
  --
  hr_input_values.chk_input_value(
      p_element_type_id           => p_element_type_id,
      p_legislation_code          => p_legislation_code,
      p_val_start_date            => l_effective_start_date,
      p_val_end_date              => l_effective_end_date,
      p_insert_update_flag        => 'INSERT',
      p_input_value_id            => l_input_value_id,
      p_rowid                     => '',
      p_recurring_flag            => p_recurring_flag,
      p_mandatory_flag            => 'N',
      p_hot_default_flag          => 'N',
      p_standard_link_flag        => 'N',
      p_classification_type       => p_classification_type,
      p_name                      => p_input_value_name,
      p_uom                       => p_uom_code,
      p_min_value                 => '',
      p_max_value                 => '',
      p_default_value             => '',
      p_lookup_type               => '',
      p_formula_id                => '',
      p_generate_db_items_flag    => l_generate_db_item_flag,
      p_warning_or_error          => '');
  --
 hr_input_values.ins_3p_input_values(
      p_val_start_date            => l_effective_start_date,
      p_val_end_date              => l_effective_end_date,
      p_element_type_id           => p_element_type_id,
      p_primary_classification_id => p_primary_classification_id,
      p_input_value_id            => l_input_value_id,
      p_default_value             => '',
      p_max_value                 => '',
      p_min_value                 => '',
      p_warning_or_error_flag     => '',
      p_input_value_name          => p_input_value_name,
      p_db_items_flag             => 'Y',
      p_costable_type             => '',
      p_hot_default_flag          => 'N',
      p_business_group_id         => p_business_group_id,
      p_legislation_code          => p_legislation_code,
      p_startup_mode               => '');
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  return l_input_value_id;
--
end create_input_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_element_link >------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME
--      create_element_link
--
--    DESCRIPTION
--      Creates a default link for a given element, based on the link for a
--      plan's absence element.
--
--    NOTES
--      none
--
PROCEDURE create_element_link(p_element_type_id  IN number,
			      p_absence_link_rec IN pay_element_links_f%rowtype,
			      p_legislation_code IN varchar2) is
--
  l_proc             varchar2(72);
  l_max_end_date     date;
  l_dummy1           varchar2(100);
  l_dummy2           number;
--
Begin
--
  l_proc  := g_package||'create_element_link';
  hr_utility.set_location('Entering:'||l_proc, 5);

  l_max_end_date := pay_element_links_pkg.max_end_date (
                   p_element_type_id => p_element_type_id,
                   p_element_link_id => null,
                   p_validation_start_date => p_absence_link_rec.effective_start_date,
                   p_validation_end_date => p_absence_link_rec.effective_end_date,
                   p_organization_id => p_absence_link_rec.organization_id,
                   p_people_group_id => p_absence_link_rec.people_group_id,
                   p_job_id => p_absence_link_rec.job_id,
                   p_position_id => p_absence_link_rec.position_id,
                   p_grade_id => p_absence_link_rec.grade_id,
                   p_location_id => p_absence_link_rec.location_id,
                   p_link_to_all_payrolls_flag => p_absence_link_rec.link_to_all_payrolls_flag,
                   p_payroll_id => p_absence_link_rec.payroll_id,
                   p_employment_category => p_absence_link_rec.employment_category,
                   p_pay_basis_id => p_absence_link_rec.pay_basis_id,
                   p_business_group_id => p_absence_link_rec.business_group_id
                   );
  -- #2848964
  l_max_end_date := least(l_max_end_date,p_absence_link_rec.effective_end_date);

  pay_element_links_pkg.insert_row (
          p_rowid => l_dummy1,
          p_element_link_id => l_dummy2,
          p_effective_start_date => p_absence_link_rec.effective_start_date,
          p_effective_end_date => l_max_end_date,
          p_payroll_id => p_absence_link_rec.payroll_id,
          p_job_id => p_absence_link_rec.job_id,
          p_position_id => p_absence_link_rec.position_id,
          p_people_group_id => p_absence_link_rec.people_group_id,
          p_cost_allocation_keyflex_id => p_absence_link_rec.cost_allocation_keyflex_id,
          p_organization_id => p_absence_link_rec.organization_id,
          p_element_type_id => p_element_type_id,
          p_location_id => p_absence_link_rec.location_id,
          p_grade_id => p_absence_link_rec.grade_id,
          p_balancing_keyflex_id => p_absence_link_rec.balancing_keyflex_id,
          p_business_group_id => p_absence_link_rec.business_group_id,
          p_legislation_code => p_legislation_code,
          p_element_set_id => p_absence_link_rec.element_set_id,
          p_pay_basis_id => p_absence_link_rec.pay_basis_id,
          p_costable_type => p_absence_link_rec.costable_type,
          p_link_to_all_payrolls_flag => p_absence_link_rec.link_to_all_payrolls_flag,
          p_multiply_value_flag => p_absence_link_rec.multiply_value_flag,
          p_standard_link_flag => p_absence_link_rec.standard_link_flag,
          p_transfer_to_gl_flag => p_absence_link_rec.transfer_to_gl_flag,
          p_comment_id => p_absence_link_rec.comment_id,
          p_employment_category => p_absence_link_rec.employment_category,
          p_qualifying_age => p_absence_link_rec.qualifying_age,
          p_qualifying_length_of_service => p_absence_link_rec.qualifying_length_of_service,
          p_qualifying_units => p_absence_link_rec.qualifying_units,
          p_attribute_category => p_absence_link_rec.attribute_category,
          p_attribute1 => p_absence_link_rec.attribute1,
          p_attribute2 => p_absence_link_rec.attribute2,
          p_attribute3 => p_absence_link_rec.attribute3,
          p_attribute4 => p_absence_link_rec.attribute4,
          p_attribute5 => p_absence_link_rec.attribute5,
          p_attribute6 => p_absence_link_rec.attribute6,
          p_attribute7 => p_absence_link_rec.attribute7,
          p_attribute8 => p_absence_link_rec.attribute8,
          p_attribute9 => p_absence_link_rec.attribute9,
          p_attribute10 => p_absence_link_rec.attribute10,
          p_attribute11 => p_absence_link_rec.attribute11,
          p_attribute12 => p_absence_link_rec.attribute12,
          p_attribute13 => p_absence_link_rec.attribute13,
          p_attribute14 => p_absence_link_rec.attribute14,
          p_attribute15 => p_absence_link_rec.attribute15,
          p_attribute16 => p_absence_link_rec.attribute16,
          p_attribute17 => p_absence_link_rec.attribute17,
          p_attribute18 => p_absence_link_rec.attribute18,
          p_attribute19 => p_absence_link_rec.attribute19,
          p_attribute20 => p_absence_link_rec.attribute20
          );

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
--
End create_element_link;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_payroll_formula >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_payroll_formula(
   p_formula_id           out nocopy number,
   p_effective_start_date in date,
   p_effective_end_date   in date,
   p_accrual_plan_name    in varchar2,
   p_defined_balance_id   in number,
   p_business_group_id    in number,
   p_legislation_code     in varchar2
  ) is

  l_rowid           varchar2(80);
  l_formula_id      number;
  l_formula_type_id number;
  l_formula_name    varchar2(80);
  l_formula_text    long;
  l_dbi_name        varchar2(80);
  l_balance_type    varchar2(30);
  l_update_date     date;
  l_leg_code        varchar2(30);

  cursor c_get_dbi is
  select distinct dbi.user_name
  from ff_database_items dbi,
       ff_user_entities ue,
       pay_balance_dimensions pbd,
       pay_defined_balances dfb,
       pay_balance_types pbt
  where dfb.balance_dimension_id = pbd.balance_dimension_id
  and pbd.route_id = ue.route_id
  and ue.user_entity_id = dbi.user_entity_id
  and pbt.balance_type_id = dfb.balance_type_id
  and dfb.defined_balance_id = p_defined_balance_id
  and dbi.user_name = upper(replace(pbt.balance_name, ' ', '_')||
                            pbd.database_item_suffix);

  cursor get_bg_balance_type is
  select org_information1
  from hr_organization_information
  where organization_id = p_business_group_id
  and org_information_context = 'PTO Balance Type';

  cursor get_leg_balance_type is
  select rule_mode
  from pay_legislation_rules
  where rule_type = 'PTO_BALANCE_TYPE'
  and legislation_code = l_leg_code;

begin
  l_update_date := sysdate;

  select formula_type_id
  into l_formula_type_id
  from ff_formula_types
  where formula_type_name = 'Oracle Payroll';

  l_formula_name := upper(substr(replace(p_accrual_plan_name, ' ', '_')||
                                 '_Oracle_Payroll',
                                 1, 80));

  ff_formulas_f_pkg.insert_row(
    X_Rowid                => l_rowid,
    X_Formula_Id           => l_formula_id,
    X_Effective_Start_Date => p_effective_start_date,
    X_Effective_End_Date   => p_effective_end_date,
    X_Business_Group_Id    => p_business_group_id,
    X_Legislation_Code     => p_legislation_code,
    X_Formula_Type_Id      => l_formula_type_id,
    X_Formula_Name         => l_formula_name,
    X_Description          => null,
    X_Formula_Text         => null,
    X_Sticky_Flag          => 'N',
    X_Last_Update_Date     => l_update_date
  );

  l_formula_text := '
/* -------------------------------------------------------
    This formula is a top level formula called during the payroll
    run to calculate accrued time for the payroll period.
    It derives the necessary values, and then runs the appropriate
    pto formulae.
    It also contains an example (commented out) of one method
    of calculating the change in employer liability for PTO.
    Please see the on-line user documentation for more
    information.
   ---------------------------------------------------------*/

DEFAULT FOR PTO_ACCRUAL_PLAN_ID is 0
DEFAULT FOR YYYYYYYYYY is ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ZZZZZZZZZZ is ''4712/12/31 00:00:00'' (date)
DEFAULT FOR XXXXXXXXXX is 0

/* The below are EXAMPLES of liability defaults. */
/*
DEFAULT FOR Hourly_Rate                      IS 0
DEFAULT FOR Current_Liability_Increment      IS 0
DEFAULT FOR PTO_LIABILITY_BALANCE_ASG_YTD    IS 0
*/
/* The method of calculating the Hourly_Rate will vary depending
   on the legislation.  This is a US-specific example. */
/*
ALIAS SCL_ASG_US_WORK_SCHEDULE               AS Work_Schedule
DEFAULT FOR Work_Schedule                    IS ''NOT ENTERED''
DEFAULT FOR ASG_HOURS                        IS 0
DEFAULT FOR ASG_SALARY                       IS 0
DEFAULT FOR ASG_SALARY_BASIS                 IS ''NOT ENTERED''
DEFAULT FOR PAY_EARNED_START_DATE            IS ''0001/01/01 00:00:00'' (date)
DEFAULT FOR PAY_EARNED_END_DATE              is ''0001/01/02 00:00:00'' (date)
DEFAULT FOR ASG_FREQ                         IS ''NOT ENTERED''
*/

/**************************************************************
   START OF PTO CALCULATIONS.
***************************************************************/

Total_Accrued_PTO = get_net_accrual(
                    ZZZZZZZZZZ,
                    PTO_ACCRUAL_PLAN_ID,
                    YYYYYYYYYY,
                    XXXXXXXXXX )

Dummy = get_element_entry()

/**************************************************************
   START OF LIABILITY CALCULATIONS.
***************************************************************/

/* Calculate the Hourly_Rate.  This is a US specific example. */
/*
Hourly_Rate = Convert_Period_Type (Work_Schedule,
                                   ASG_HOURS,
                                   ASG_SALARY,
                                   ASG_SALARY_BASIS,
                                   ''HOURLY'',
                                   PAY_EARNED_START_DATE,
                                   PAY_EARNED_END_DATE,
                                   ASG_FREQ,
                                   ''FIXED'')
*/

/* Calculate the current liability */
/*
Current_Liability_Increment =
((PTO_PLAN_BALANCE_ASG_PTO_DE_YTD + Total_Accrued_PTO)
 * hourly_rate) - PTO_LIABILITY_BALANCE_ASG_YTD
*/

/* If calculating liabilities, the return statement should
   include an additional parameter:

   RETURN Total_Accrued_PTO, Dummy, Current_Liability_Increment
*/
/**************************************************************
   END OF MAIN BODY.
***************************************************************/

RETURN Total_Accrued_PTO, Dummy
';

  open c_get_dbi;
  fetch c_get_dbi into l_dbi_name;

  if c_get_dbi%found then
  --
    l_formula_text := replace(l_formula_text,
                              'XXXXXXXXXX',
                              l_dbi_name);
  --
  end if;

  close c_get_dbi;

  open get_bg_balance_type;
  fetch get_bg_balance_type into l_balance_type;
  close get_bg_balance_type;

  if l_balance_type is null then
  --
    begin
    --
      select legislation_code
      into l_leg_code
      from per_business_groups
      where business_group_id = p_business_group_id;
    --
    exception
    when no_data_found then
    --
      l_leg_code := null;
    --
    end;

    open get_leg_balance_type;
    fetch get_leg_balance_type into l_balance_type;
    close get_leg_balance_type;
  --
  end if;

  if l_balance_type = 'DE' then
  --
    l_formula_text := replace(l_formula_text,
                              'YYYYYYYYYY',
                              'PTO_DATE_EARNED_START_DATE');

    l_formula_text := replace(l_formula_text,
                              'ZZZZZZZZZZ',
                              'PTO_DATE_EARNED_CALCULATION_DATE');
  --
  else
  --
    l_formula_text := replace(l_formula_text,
                              'YYYYYYYYYY',
                              'PTO_DATE_PAID_START_DATE');

    l_formula_text := replace(l_formula_text,
                              'ZZZZZZZZZZ',
                              'PTO_DATE_PAID_CALCULATION_DATE');
  --
  end if;

  update ff_formulas_f
  set formula_text = l_formula_text
  where formula_id = l_formula_id;

  p_formula_id := l_formula_id;

end create_payroll_formula;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_balance_dimension_id >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_balance_dimension_id
  (p_balance_dimension_id IN NUMBER
  ,p_business_group_id    IN NUMBER)
IS

  l_proc             VARCHAR2(80);
  l_legislation_code per_business_groups.legislation_code%TYPE;
  l_dummy            NUMBER;

  --
  -- Gets the legislation code.
  --
  CURSOR csr_get_leg_code IS
  SELECT pbg.legislation_code
  FROM   per_business_groups pbg
  WHERE  pbg.business_group_id = p_business_group_id;

  --
  -- Validates the balance dimension.
  --
  CURSOR csr_chk_bal_dim IS
  SELECT NULL
  FROM   pay_balance_dimensions pbd
  WHERE  pbd.balance_dimension_id = p_balance_dimension_id
  AND    NVL(pbd.business_group_id, p_business_group_id) = p_business_group_id
  AND    NVL(pbd.legislation_code, NVL(l_legislation_code, hr_api.g_varchar2))
         = NVL(l_legislation_code, hr_api.g_varchar2)
  AND EXISTS     (SELECT NULL
                  FROM   ff_routes fr
                        ,ff_contexts fc
                        ,ff_route_context_usages frcu
                  WHERE  fr.route_id = pbd.route_id
                  AND    fc.context_name IN ('ASSIGNMENT_ACTION_ID'
                                            ,'DATE_EARNED'
                                            ,'TAX_UNIT_ID')
                  AND    frcu.route_id = fr.route_id
                  AND    frcu.context_id = fc.context_id)
  AND NOT EXISTS (SELECT NULL
                  FROM   ff_routes fr
                        ,ff_contexts fc
                        ,ff_route_context_usages frcu
                  WHERE  fr.route_id = pbd.route_id
                  AND    fc.context_name NOT IN ('ASSIGNMENT_ACTION_ID'
                                                ,'DATE_EARNED'
                                                ,'TAX_UNIT_ID')
                  AND    frcu.route_id = fr.route_id
                  AND    frcu.context_id = fc.context_id)
  UNION ALL
  SELECT NULL
  FROM   pay_balance_dimensions pbd
  WHERE  pbd.balance_dimension_id = p_balance_dimension_id
  AND    NVL(pbd.business_group_id, p_business_group_id) = p_business_group_id
  AND    NVL(pbd.legislation_code, NVL(l_legislation_code, hr_api.g_varchar2))
         = NVL(l_legislation_code, hr_api.g_varchar2)
  AND EXISTS     (SELECT NULL
                  FROM   ff_routes fr
                        ,ff_contexts fc
                        ,ff_route_context_usages frcu
                  WHERE  fr.route_id = pbd.route_id
                  AND    fc.context_name = 'JURISDICTION_CODE'
                  AND    frcu.route_id = fr.route_id
                  AND    frcu.context_id = fc.context_id);

BEGIN
  l_proc := g_package||'chk_balance_dimension_id';
  hr_utility.set_location('Entering: '||l_proc, 10);

  OPEN  csr_get_leg_code;
  FETCH csr_get_leg_code INTO l_legislation_code;
  CLOSE csr_get_leg_code;

  hr_utility.set_location('l_legislation_code: '||l_legislation_code, 20);

  OPEN  csr_chk_bal_dim;
  FETCH csr_chk_bal_dim INTO l_dummy;

  IF csr_chk_bal_dim%NOTFOUND THEN
    --
    -- The balance dimension fails validation so error.
    --
    hr_utility.set_location(l_proc, 30);
    CLOSE csr_chk_bal_dim;
    fnd_message.set_name('PER','HR_289824_PAP_BAL_DIM_INVALID');
    fnd_message.raise_error;

  END IF;

  CLOSE csr_chk_bal_dim;

  hr_utility.set_location('Leaving: '||l_proc, 40);

END chk_balance_dimension_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_accrual_plan >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_accrual_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_accrual_formula_id            in     number
  ,p_co_formula_id                 in     number
  ,p_pto_input_value_id            in     number
  ,p_accrual_plan_name             in     varchar2
  ,p_accrual_units_of_measure      in     varchar2
  ,p_accrual_category              in     varchar2
  ,p_accrual_start                 in     varchar2 default null
  ,p_ineligible_period_length      in     number   default null
  ,p_ineligible_period_type        in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_ineligibility_formula_id      in     number   default null
  ,p_balance_dimension_id          in     number   default null
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_information21                 in     varchar2 default null
  ,p_information22                 in     varchar2 default null
  ,p_information23                 in     varchar2 default null
  ,p_information24                 in     varchar2 default null
  ,p_information25                 in     varchar2 default null
  ,p_information26                 in     varchar2 default null
  ,p_information27                 in     varchar2 default null
  ,p_information28                 in     varchar2 default null
  ,p_information29                 in     varchar2 default null
  ,p_information30                 in     varchar2 default null
  ,p_accrual_plan_id               out nocopy    number
  ,p_accrual_plan_element_type_id  out nocopy    number
  ,p_co_element_type_id            out nocopy    number
  ,p_co_input_value_id             out nocopy    number
  ,p_co_date_input_value_id        out nocopy    number
  ,p_co_exp_date_input_value_id    out nocopy    number
  ,p_residual_element_type_id      out nocopy    number
  ,p_residual_input_value_id       out nocopy    number
  ,p_residual_date_input_value_id  out nocopy    number
  ,p_payroll_formula_id            out nocopy    number
  ,p_defined_balance_id            out nocopy    number
  ,p_balance_element_type_id       out nocopy    number
  ,p_tagging_element_type_id       out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_no_link_message               out nocopy    boolean
  ,p_check_accrual_ff              out nocopy    boolean
  ) is

  --
  -- Declare cursors and local variables
  --

  --
  -- cursor to get a primary classification (i.e. one where the
  -- parent_classification_id is null) for the legislation or business
  -- group. Get the 'Information' classification if there is one,
  -- failing that get a non-payments one, otherwise just get the
  -- first one retrieved.
  --
  cursor   class_name(p_legislation_code varchar2) is
  select   classification_name,
           classification_id
  from     pay_element_classifications
  where    (business_group_id = p_business_group_id or
            legislation_code = p_legislation_code)
  and      parent_classification_id is null
  order by decode (classification_name, 'Information', 1, 2),
           nvl (non_payments_flag, 'X') desc,
	   classification_name;

  cursor c_class_id(p_classification_name varchar2,
                    p_legislation_code    varchar2) is
  select classification_id
  from   pay_element_classifications
  where  classification_name = p_classification_name
  and    (business_group_id = p_business_group_id or
          legislation_code = p_legislation_code);

  --
  -- Cursor to get translated values for element and input value names
  --
  cursor c_get_lookups(p_lookup_code varchar2) is
  select meaning
  from hr_lookups
  where lookup_type = 'NAME_TRANSLATIONS'
  and lookup_code = p_lookup_code;

  --
  -- Cursor to retrieve details of absence element link, to be
  -- copied into links for other elements.
  --
  cursor c_absence_element_link_id is
  select *
  from   pay_element_links_f
  where  element_link_id in ( select pel.element_link_id
                             from   pay_element_links_f pel,
                                    pay_input_values_f piv
                             where  pel.element_type_id = piv.element_type_id
                             and    piv.input_value_id = p_pto_input_value_id
                             and    p_effective_date between pel.effective_start_date
                                                     and     pel.effective_end_date
                             and    p_effective_date between piv.effective_start_date
                                                     and     piv.effective_end_date );

  --
  -- Cursor to get the PTO skip rule formula ID.
  --
  cursor c_get_skip_rule (p_formula_name in varchar2) is
  select ff.formula_id
  from   ff_formulas_f ff,
         ff_formula_types ft
  where  ff.formula_type_id = ft.formula_type_id
  and    ft.formula_type_name = 'Element Skip'
  and    ff.formula_name = p_formula_name
  and    p_effective_date between ff.effective_start_date
                          and     ff.effective_end_date;

  --
  -- Cursors to get balance category id - first check for
  --   legislative specific entry, then look for global entry
  --
  cursor c_get_leg_bal_cat_id(p_leg_code varchar2) is
  select balance_category_id
  from   pay_balance_categories_f
  where  category_name = 'PTO Accruals'
  and    legislation_code = p_leg_code;

  cursor c_get_gbl_bal_cat_id is
  select balance_category_id
  from   pay_balance_categories_f
  where  category_name = 'PTO Accruals'
  and    legislation_code is null;

  l_proc                         varchar2(72);
  l_accrual_plan_id              number;
  l_accrual_plan_element_type_id number;
  l_input_value_id               number;
  l_co_input_value_id            number;
  l_co_date_input_value_id       number;
  l_co_exp_date_input_value_id   number;
  l_residual_input_value_id      number;
  l_residual_date_input_value_id number;
  l_balance_input_value_id       number;
  l_balance_element_type_id      number;
  l_tagging_element_type_id      number;
  l_tagging_input_value_id       number;
  l_input_value_name             varchar2(80);
  l_date_input_value_name        varchar2(80);
  l_exp_date_input_value_name    varchar2(80);
  l_element_name                 varchar2(80);
  l_element_description          varchar2(240);
  l_classification_name          varchar2(240);
  l_post_termination_rule        varchar2(240);
  l_uom_code                     varchar2(80);
  l_uom_code1                    varchar2(80);
  l_primary_classification_id    number;
  l_classification_type          varchar2(2);
  l_bg_name                      varchar2(80);
  l_leg_code                     varchar2(150);
  l_curr_code                    varchar2(150);
  l_date_uom_code                varchar2(80);
  l_co_element_type_id           number;
  l_residual_element_type_id     number;
  l_net_calc_rule_id             number;
  l_object_version_number        number;
  l_no_link_message              boolean;
  l_effective_start_date         date;
  l_effective_end_date           date;
  l_user                         varchar2(80);
  l_rowid                        varchar2(80);
  l_status_processing_rule_id    number;
  l_formula_result_rule_id       number;
  l_priority                     number;
  l_balance_category_id          number;
  l_balance_type_id              number;
  l_defined_balance_id           number;
  l_balance_feed_id              number;
  l_payroll_formula_id           number;
  l_tagging_formula_id           number;
  l_balance_name                 varchar2(80);
  l_skip_rule_formula_id         number;
  l_skip_rule_formula_name       varchar2(30);
  l_dummy_string                 varchar2(80);
  l_dummy_number                 number;
  l_count                        number := 0;

BEGIN
  l_proc  := g_package||'create_accrual_plan';
  l_skip_rule_formula_name := 'PTO_ORACLE_SKIP_RULE';
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Pipe the main IN / IN OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN / IN OUT NOCOPY PARAMETER           '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  IF p_validate THEN
    hr_utility.trace('  p_validate                       '||
                        'TRUE');
  ELSE
    hr_utility.trace('  p_validate                       '||
                        'FALSE');
  END IF;
  hr_utility.trace('  p_effective_date                 '||
                      to_char(p_effective_date));
  hr_utility.trace('  p_business_group_id              '||
                      to_char(p_business_group_id));
  hr_utility.trace('  p_accrual_formula_id             '||
                      to_char(p_accrual_formula_id));
  hr_utility.trace('  p_co_formula_id                  '||
                      to_char(p_co_formula_id));
  hr_utility.trace('  p_pto_input_value_id             '||
                      to_char(p_pto_input_value_id));
  hr_utility.trace('  p_accrual_plan_name              '||
                      p_accrual_plan_name);
  hr_utility.trace('  p_accrual_units_of_measure       '||
                      p_accrual_units_of_measure);
  hr_utility.trace('  p_accrual_category               '||
                      p_accrual_category);
  hr_utility.trace('  p_accrual_start                  '||
                      p_accrual_start);
  hr_utility.trace('  p_ineligible_period_length       '||
                      to_char(p_ineligible_period_length));
  hr_utility.trace('  p_ineligible_period_type         '||
                      p_ineligible_period_type);
  hr_utility.trace('  p_description                    '||
                      p_description);
  hr_utility.trace('  p_ineligibility_formula_id       '||
                      to_char(p_ineligibility_formula_id));
  hr_utility.trace('  p_balance_dimension_id           '||
                      to_char(p_balance_dimension_id));
  hr_utility.trace('  p_information_category           '||
                      p_information_category);
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  --
  -- Issue a savepoint
  --
  savepoint create_accrual_plan;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_accrual_plan_bk1.create_accrual_plan_b
      (p_effective_date               => p_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_accrual_formula_id           => p_accrual_formula_id
      ,p_co_formula_id                => p_co_formula_id
      ,p_pto_input_value_id           => p_pto_input_value_id
      ,p_accrual_plan_name            => p_accrual_plan_name
      ,p_accrual_units_of_measure     => p_accrual_units_of_measure
      ,p_accrual_category             => p_accrual_category
      ,p_accrual_start                => p_accrual_start
      ,p_ineligible_period_length     => p_ineligible_period_length
      ,p_ineligible_period_type       => p_ineligible_period_type
      ,p_description                  => p_description
      ,p_ineligibility_formula_id     => p_ineligibility_formula_id
      ,p_balance_dimension_id         => p_balance_dimension_id
      ,p_information1                 => p_information1
      ,p_information2                 => p_information2
      ,p_information3                 => p_information3
      ,p_information4                 => p_information4
      ,p_information5                 => p_information5
      ,p_information6                 => p_information6
      ,p_information7                 => p_information7
      ,p_information8                 => p_information8
      ,p_information9                 => p_information9
      ,p_information10                => p_information10
      ,p_information11                => p_information11
      ,p_information12                => p_information12
      ,p_information13                => p_information13
      ,p_information14                => p_information14
      ,p_information15                => p_information15
      ,p_information16                => p_information16
      ,p_information17                => p_information17
      ,p_information18                => p_information18
      ,p_information19                => p_information19
      ,p_information20                => p_information20
      ,p_information21                => p_information21
      ,p_information22                => p_information22
      ,p_information23                => p_information23
      ,p_information24                => p_information24
      ,p_information25                => p_information25
      ,p_information26                => p_information26
      ,p_information27                => p_information27
      ,p_information28                => p_information28
      ,p_information29                => p_information29
      ,p_information30                => p_information30

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_accrual_plan'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  --
  -- The items returned by this select are used in setting up
  -- the elements with the correct leg code and currency code.
  --

  select name, legislation_code, currency_code
  into   l_bg_name, l_leg_code, l_curr_code
  from   per_business_groups
  where  business_group_id = p_business_group_id;

  hr_utility.set_location(l_proc, 40);
  hr_utility.trace('l_bg_name: '||l_bg_name);
  hr_utility.trace('l_leg_code: '||l_leg_code);
  hr_utility.trace('l_curr_code: '||l_curr_code);
  --
  -- If this is a US legislation, use the classification name
  -- 'PTO Accruals'. Otherwise, pick any classification, preferably a
  -- non-payments one.
  --
  if l_leg_code = 'US' then
  --
    l_classification_name   := 'PTO Accruals';

    open c_class_id('PTO Accruals', l_leg_code);
    fetch c_class_id into l_primary_classification_id;
    close c_class_id;
    hr_utility.trace('l_primary_classification_id: '
                     ||to_char(l_primary_classification_id));
  --
  else
  --
    open  class_name(l_leg_code);
    fetch class_name into l_classification_name,
                          l_primary_classification_id;
    close class_name;
    hr_utility.trace('l_classification_name: '||l_classification_name);
    hr_utility.trace('l_primary_classification_id: '
                     ||to_char(l_primary_classification_id));

  end if;

  begin

    hr_utility.set_location(l_proc, 50);
    select ec.default_priority + 1
    into l_priority
    from   pay_element_classifications ec
    where  upper(ec.classification_name) = upper(l_classification_name)
    and  ec.parent_classification_id is NULL
    and  ((ec.legislation_code = l_leg_code) or
          (ec.legislation_code is null and
           ec.business_group_id is not null and
           ec.business_group_id = p_business_group_id
          and not exists (select ''
                          from pay_element_classifications ec2
                          where  upper(ec2.classification_name) = upper(l_classification_name)
                          and  ec2.parent_classification_id is NULL
                          and  ec2.legislation_code = l_leg_code)
        ));
  --
  exception
  when no_data_found then
    l_priority := 1500;
  --
  end;

  hr_utility.trace('l_priority: '||to_char(l_priority));
  l_leg_code := null;

  --
  -- Get the termination rule
  --
  begin
  --
    select hl.meaning
    into l_post_termination_rule
    from hr_lookups hl
    where hl.lookup_type='TERMINATION_RULE'
    and hl.lookup_code='F';    -- Final Close
  --
  exception
  --
    when no_data_found then
    hr_utility.set_message(801,'HR_NO_F_TERM_RULE');
    hr_utility.raise_error;
  --
  end;

  hr_utility.trace('l_post_termination_rule: '||l_post_termination_rule);
  --
  -- Get the Skip Rule formula ID.
  -- No longer needed. See bug 2620850.
  --
  l_skip_rule_formula_id := null;
  --
  --open  c_get_skip_rule (l_skip_rule_formula_name);
  --fetch c_get_skip_rule into l_skip_rule_formula_id;
  --
  --  if c_get_skip_rule%notfound then
      --
      -- The Skip Rule formula cannot be found. Raise an error.
      --
  --    fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
  --    fnd_message.set_token('1',l_skip_rule_formula_name);
  --    fnd_message.raise_error;
  --  end if;
  --
  --close c_get_skip_rule;

  --
  -- create the accrual plan element type and input value...
  --
  l_element_name              := p_accrual_plan_name;
  l_element_description       := p_accrual_plan_name;
  l_classification_type       := 'N';

  hr_utility.set_location(l_proc, 50);

  l_accrual_plan_element_type_id := create_element(
                             l_element_name,
                             l_element_description,
                             'R',
                             l_bg_name,
                             l_classification_name,
                             l_leg_code,
                             l_curr_code,
                             l_post_termination_rule,
			     'N',
                             'N',
                             l_skip_rule_formula_id,
                             null
                             );
  --
  hr_utility.set_location(l_proc, 60);
  hr_utility.trace('l_accrual_plan_element_type_id: '
                   ||to_char(l_accrual_plan_element_type_id));

  l_input_value_name := 'Continuous Service Date';
  l_date_uom_code := 'D';
  --
  l_input_value_id := create_input_value(
              l_element_name,
              l_input_value_name,
              l_date_uom_code,
              l_bg_name,
              l_accrual_plan_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'R',
              l_leg_code,
              l_classification_type,
	      'N'
              );

  hr_utility.set_location(l_proc, 70);
  hr_utility.trace('l_input_value_id: '||to_char(l_input_value_id));
  --
  -- set up input value names and units of measure
  -- for carry over and residual element input values
  --
  if p_accrual_units_of_measure = 'D' then
  --
    open c_get_lookups('PTO_DAYS');
    l_uom_code := 'ND';
  --
  else
  --
    open c_get_lookups('PTO_HOURS');
    l_uom_code := 'H_DECIMAL3';
  --
  end if;

  fetch c_get_lookups into l_input_value_name;
  close c_get_lookups;

  open c_get_lookups('PTO_EFFECTIVE_DATE');
  fetch c_get_lookups into l_date_input_value_name;
  close c_get_lookups;

  open c_get_lookups('PTO_EXPIRY_DATE');
  fetch c_get_lookups into l_exp_date_input_value_name;
  close c_get_lookups;

  hr_utility.set_location(l_proc, 80);
  hr_utility.trace('l_input_value_name: '||l_input_value_name);
  hr_utility.trace('l_date_input_value_name: '||l_date_input_value_name);
  hr_utility.trace('l_exp_date_input_value_name: '||l_exp_date_input_value_name);
  --
  -- now create the carried-over element type and input values...
  --
  open c_get_lookups('PTO_CO');
  fetch c_get_lookups into l_dummy_string;
  close c_get_lookups;

  l_element_name        := substr(p_accrual_plan_name||' '||l_dummy_string, 1, 80);

  open c_get_lookups('PTO_CO_ELEMENT_DESC');
  fetch c_get_lookups into l_element_description;
  close c_get_lookups;

  hr_utility.trace('l_element_name: '||l_element_name);
  hr_utility.trace('l_element_description: '||l_element_description);
  --
  -- If this is a US legislation, use the classification name
  -- 'Information'. Otherwise, stick with the classification retrieved
  -- above.
  --

  if l_leg_code = 'US' then
  --
    l_classification_name   := 'Information';

    open c_class_id('Information', l_leg_code);
    fetch c_class_id into l_primary_classification_id;
    close c_class_id;
  --
  end if;

  --
  l_classification_type       := 'Y';

  hr_utility.trace('l_classification_type: '||l_classification_type);

  l_co_element_type_id := create_element(
              l_element_name,
              l_element_description,
              'N',
              l_bg_name,
              l_classification_name,
              l_leg_code,
              l_curr_code,
              l_post_termination_rule,
	      'Y',
              'N',
              l_skip_rule_formula_id,
              null
              );

  hr_utility.trace('l_co_element_type_id: '||to_char(l_co_element_type_id));

  l_co_input_value_id := create_input_value(
              l_element_name,
              l_input_value_name,
              l_uom_code,
              l_bg_name,
              l_co_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
	      'N'
              );

  hr_utility.trace('l_co_input_value_id: '||to_char(l_co_input_value_id));

  l_co_date_input_value_id := create_input_value(
              l_element_name,
              l_date_input_value_name,
              l_date_uom_code,
              l_bg_name,
              l_co_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
	      'Y'
              );

  hr_utility.trace('l_co_date_input_value_id: '||to_char(l_co_date_input_value_id));

  l_co_exp_date_input_value_id := create_input_value(
              l_element_name,
              l_exp_date_input_value_name,
              l_date_uom_code,
              l_bg_name,
              l_co_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
              'Y'
              );

  hr_utility.trace('l_co_exp_date_input_value_id: '
                    ||to_char(l_co_exp_date_input_value_id));

  --
  -- and finally the residual element type and input value.
  --

  open c_get_lookups('PTO_RESIDUAL');
  fetch c_get_lookups into l_dummy_string;
  close c_get_lookups;

  l_element_name := substr(p_accrual_plan_name||' '||l_dummy_string, 1, 80);

  open c_get_lookups('PTO_RES_ELEMENT_DESC');
  fetch c_get_lookups into l_element_description;
  close c_get_lookups;

  hr_utility.trace('l_element_name: '||l_element_name);
  hr_utility.trace('l_element_description: '||l_element_description);

  l_residual_element_type_id := create_element(
              l_element_name,
              l_element_description,
              'N',
              l_bg_name,
              l_classification_name,
              l_leg_code,
              l_curr_code,
              l_post_termination_rule,
	      'Y',
              'N',
              l_skip_rule_formula_id,
              null
              );

  hr_utility.trace('l_residual_element_type_id: '||to_char(l_residual_element_type_id));

  l_residual_input_value_id := create_input_value(
              l_element_name,
              l_input_value_name,
              l_uom_code,
              l_bg_name,
              l_residual_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
	      'N'
              );

  hr_utility.trace('l_residual_input_value_id: '||to_char(l_residual_input_value_id));

  l_residual_date_input_value_id := create_input_value(
              l_element_name,
              l_date_input_value_name,
              l_date_uom_code,
              l_bg_name,
              l_residual_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
	      'Y'
              );

  hr_utility.trace('l_residual_date_input_value_id: '
                   ||to_char(l_residual_date_input_value_id));

  l_element_name := substr(p_accrual_plan_name||' Payroll Balance', 1, 80);

  hr_utility.trace('l_element_name: '||l_element_name);

  l_balance_element_type_id := create_element(
              l_element_name,
              l_element_description,
              'N',
              l_bg_name,
              l_classification_name,
              l_leg_code,
              l_curr_code,
              l_post_termination_rule,
              'Y',
              'Y',
              null,
              l_priority
              );

  hr_utility.trace('l_balance_element_type_id: '||to_char(l_balance_element_type_id));

  l_balance_input_value_id := create_input_value(
              l_element_name,
              l_input_value_name,
              l_uom_code,
              l_bg_name,
              l_balance_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
              'N'
              );

  hr_utility.trace('l_balance_input_value_id: '||to_char(l_balance_input_value_id));
  --
  -- Create element type for tagging retrospecive absences
  --

  select processing_priority
  into l_priority
  from pay_element_types_f
  where element_type_id = l_accrual_plan_element_type_id;

  hr_utility.trace('l_priority: '||to_char(l_priority));

  l_element_name := substr(p_accrual_plan_name||' Tagging', 1, 80);

  l_tagging_element_type_id := create_element(
              l_element_name,
              l_element_description,
              'N',
              l_bg_name,
              l_classification_name,
              l_leg_code,
              l_curr_code,
              l_post_termination_rule,
              'Y',
              'Y',
              null,
              l_priority
              );

  hr_utility.trace('l_tagging_element_type_id: '||to_char(l_tagging_element_type_id));
  --
  l_uom_code1 := 'N';
  l_input_value_name := 'Element Entry ID';

  l_tagging_input_value_id := create_input_value(
              l_element_name,
              l_input_value_name,
              l_uom_code1,
              l_bg_name,
              l_tagging_element_type_id,
              l_primary_classification_id,
              p_business_group_id,
              'N',
              l_leg_code,
              l_classification_type,
              'N'
              );

  hr_utility.trace('l_tagging_input_value_id: '||to_char(l_tagging_input_value_id));

  --
  -- See if a link has been defined for the plan's absence element
  --

  for l_element_link_rec in c_absence_element_link_id loop
  --
    l_count := l_count + 1;
    --
    -- Create element links for new accrual plan elements,
    -- beginning with the plan element itself.
    --
    hr_utility.set_location(l_proc, 90);

    create_element_link(p_element_type_id  => l_accrual_plan_element_type_id,
                        p_absence_link_rec => l_element_link_rec,
			p_legislation_code => l_leg_code);

    --
    -- Next, a link for the carry over element
    --
    hr_utility.set_location(l_proc, 100);

    create_element_link(p_element_type_id  => l_co_element_type_id,
                        p_absence_link_rec => l_element_link_rec,
			p_legislation_code => l_leg_code);

    --
    -- Next, a link for the residual element
    --
    hr_utility.set_location(l_proc, 110);

    create_element_link(p_element_type_id  => l_residual_element_type_id,
                        p_absence_link_rec => l_element_link_rec,
			p_legislation_code => l_leg_code);

    --
    -- A link for the balance element
    --
    hr_utility.set_location(l_proc, 120);

    create_element_link(p_element_type_id  => l_balance_element_type_id,
                        p_absence_link_rec => l_element_link_rec,
                        p_legislation_code => l_leg_code);

    --
    -- Finally, a link for the tagging element
    --
    hr_utility.set_location(l_proc, 130);

    create_element_link(p_element_type_id  => l_tagging_element_type_id,
                        p_absence_link_rec => l_element_link_rec,
                        p_legislation_code => l_leg_code);

  --
  end loop;

  if l_count > 0 then
  --
    hr_utility.set_location(l_proc, 140);
    l_no_link_message := false;
  --
  else
  --
    --
    -- If no link was found, we will need to inform the user at
    -- a later stage
    --
    hr_utility.set_location(l_proc, 150);
    l_no_link_message := true;
  --
  end if;

  if p_balance_dimension_id is not null then

    hr_utility.set_location(l_proc, 160);
    --
    -- Ideally the balance_dimension_id should be validated in the
    -- row-handler but the defined_balance_id is required before
    -- calling the row-handler and so the validation must be
    -- performed here.
    --
    chk_balance_dimension_id
      (p_balance_dimension_id => p_balance_dimension_id
      ,p_business_group_id    => p_business_group_id);

    hr_utility.set_location(l_proc, 170);

    l_user := fnd_profile.value('USER');
    l_effective_start_date := hr_general.start_of_time;
    l_effective_end_date := hr_general.end_of_time;

    --
    -- Now set up the balance information. This requires rows to be inserted in
    -- pay_balance_feeds, pay_balace_types, and pay_defined_balances. We will
    -- make use of the seeded balance dimension, route etc.
    --

    open c_get_leg_bal_cat_id(l_leg_code);
    fetch c_get_leg_bal_cat_id into l_balance_category_id;
    if c_get_leg_bal_cat_id%notfound then
      open c_get_gbl_bal_cat_id;
      fetch c_get_gbl_bal_cat_id into l_balance_category_id;
      if c_get_gbl_bal_cat_id%notfound then
        l_balance_category_id := null;
      end if;
      close c_get_gbl_bal_cat_id;
    end if;
    close c_get_leg_bal_cat_id;

    l_balance_name := substr(p_accrual_plan_name||' Balance', 1, 80);

    pay_balance_types_pkg.Insert_Row(
                      X_Rowid                        => l_rowid,
                      X_Balance_Type_Id              => l_balance_type_id,
                      X_Business_Group_Id            => p_business_group_id,
                      X_Legislation_Code             => l_leg_code,
                      X_Currency_Code                => null,
                      X_Assignment_Remuneration_Flag => 'N',
                      X_Balance_Name                 => l_balance_name,
                      X_Base_Balance_Name            => l_balance_name,
                      X_Balance_Uom                  => l_uom_code,
                      X_Comments                     => null,
                      X_Legislation_Subgroup         => null,
                      X_Reporting_Name               => substr(l_balance_name, 1, 30),
                      X_Attribute_Category           => null,
                      X_Attribute1                   => null,
                      X_Attribute2                   => null,
                      X_Attribute3                   => null,
                      X_Attribute4                   => null,
                      X_Attribute5                   => null,
                      X_Attribute6                   => null,
                      X_Attribute7                   => null,
                      X_Attribute8                   => null,
                      X_Attribute9                   => null,
                      X_Attribute10                  => null,
                      X_Attribute11                  => null,
                      X_Attribute12                  => null,
                      X_Attribute13                  => null,
                      X_Attribute14                  => null,
                      X_Attribute15                  => null,
                      X_Attribute16                  => null,
                      X_Attribute17                  => null,
                      X_Attribute18                  => null,
                      X_Attribute19                  => null,
                      X_Attribute20                  => null,
                      X_Balance_Category_Id          => l_balance_category_id
                      );

    hr_utility.set_location(l_proc, 180);

    pay_balance_feeds_f_pkg.Insert_Row(
                      X_Rowid                => l_rowid,
                      X_Balance_Feed_Id      => l_balance_feed_id,
                      X_Effective_Start_Date => hr_general.start_of_time,
                      X_Effective_End_Date   => hr_general.end_of_time,
                      X_Business_Group_Id    => p_business_group_id,
                      X_Legislation_Code     => l_leg_code,
                      X_Balance_Type_Id      => l_balance_type_id,
                      X_Input_Value_Id       => l_balance_input_value_id,
                      X_Scale                => 1,
                      X_Legislation_Subgroup => null
                      );

    hr_utility.set_location(l_proc, 190);

    pay_defined_balances_pkg.Insert_Row(
        X_Rowid                => l_rowid,
        X_Defined_Balance_Id   => l_defined_balance_id,
        X_Business_Group_Id    => p_business_group_id,
        X_Legislation_Code     => l_leg_code,
        X_Balance_Type_Id      => l_balance_type_id,
        X_Balance_Dimension_Id => p_balance_dimension_id,
        X_Force_Latest_Balance_Flag=> 'N',
        X_Legislation_Subgroup => null
        );

    --
    -- Call procedure to create new Oracle Payroll fomrula.
    --

    hr_utility.set_location(l_proc, 200);

    create_payroll_formula(
       p_formula_id           => l_payroll_formula_id,
       p_effective_start_date => l_effective_start_date,
       p_effective_end_date   => l_effective_end_date,
       p_accrual_plan_name    => p_accrual_plan_name,
       p_defined_balance_id   => l_defined_balance_id,
       p_business_group_id    => p_business_group_id,
       p_legislation_code     => l_leg_code
      );

    hr_utility.set_location(l_proc, 210);
    --
    -- Set up the status processing rules and formula result rules for the
    -- recurring accrual plan element.
    --
    pay_status_rules_pkg.insert_row (
                     X_Rowid                     => l_rowid,
                     X_Status_Processing_Rule_Id => l_status_processing_rule_id,
                     X_Effective_Start_Date      => l_effective_start_date,
                     X_Effective_End_Date        => l_effective_end_date,
                     X_Business_Group_Id         => p_business_group_id,
                     X_Legislation_Code          => l_leg_code,
                     X_Element_Type_Id           => l_accrual_plan_element_type_id,
                     X_Assignment_Status_Type_Id => null,
                     X_Formula_Id                => l_payroll_formula_id,
                     X_Processing_Rule           => 'P',
                     X_Comment_Id                => null,
                     X_Legislation_Subgroup      => null,
                     X_Last_Update_Date          => sysdate,
                     X_Last_Updated_By           => l_user,
                     X_Last_Update_Login         => l_user,
                     X_Created_By                => l_user,
                     X_Creation_Date             => sysdate
                     );

    hr_utility.set_location(l_proc, 220);

    pay_formula_result_rules_pkg.insert_row(
                     p_Rowid                     => l_rowid,
                     p_Formula_Result_Rule_Id    => l_formula_result_rule_id,
                     p_Effective_Start_Date      => l_effective_start_date,
                     p_Effective_End_Date        => l_effective_end_date,
                     p_Business_Group_Id         => p_business_group_id,
                     p_Legislation_Code          => l_leg_code,
                     p_Element_Type_Id           => l_balance_element_type_id,
                     p_Status_Processing_Rule_Id => l_status_processing_rule_id,
                     p_Result_Name               => 'TOTAL_ACCRUED_PTO',
                     p_Result_Rule_Type          => 'I',
                     p_Legislation_Subgroup      => null,
                     p_Severity_Level            => 'I',
                     p_Input_Value_Id            => l_balance_input_value_id,
                     p_Created_By                => l_user,
                     p_session_date              => sysdate
                     );

    l_formula_result_rule_id := null;
    hr_utility.set_location(l_proc, 230);

    pay_formula_result_rules_pkg.insert_row(
                     p_Rowid                     => l_rowid,
                     p_Formula_Result_Rule_Id    => l_formula_result_rule_id,
                     p_Effective_Start_Date      => l_effective_start_date,
                     p_Effective_End_Date        => l_effective_end_date,
                     p_Business_Group_Id         => p_business_group_id,
                     p_Legislation_Code          => l_leg_code,
                     p_Element_Type_Id           => l_tagging_element_type_id,
                     p_Status_Processing_Rule_Id => l_status_processing_rule_id,
                     p_Result_Name               => 'DUMMY',
                     p_Result_Rule_Type          => 'I',
                     p_Legislation_Subgroup      => null,
                     p_Severity_Level            => 'I',
                     p_Input_Value_Id            => l_tagging_input_value_id,
                     p_Created_By                => l_user,
                     p_session_date              => sysdate
                     );

    hr_utility.set_location(l_proc, 240);
    --
    -- Set up the status processing rules and formula result rules for the
    -- tagging element.
    --

    select formula_id
    into l_tagging_formula_id
    from ff_formulas_f ff,
         ff_formula_types ft
    where ff.formula_type_id = ft.formula_type_id
    and ft.formula_type_name = 'Oracle Payroll'
    and ff.formula_name = 'PTO_TAGGING_FORMULA';

    l_status_processing_rule_id := null;
    l_formula_result_rule_id := null;

    hr_utility.trace('l_tagging_formula_id: '||to_char(l_tagging_formula_id));

    pay_status_rules_pkg.insert_row (
                     X_Rowid                     => l_rowid,
                     X_Status_Processing_Rule_Id => l_status_processing_rule_id,
                     X_Effective_Start_Date      => l_effective_start_date,
                     X_Effective_End_Date        => l_effective_end_date,
                     X_Business_Group_Id         => p_business_group_id,
                     X_Legislation_Code          => l_leg_code,
                     X_Element_Type_Id           => l_tagging_element_type_id,
                     X_Assignment_Status_Type_Id => null,
                     X_Formula_Id                => l_tagging_formula_id,
                     X_Processing_Rule           => 'P',
                     X_Comment_Id                => null,
                     X_Legislation_Subgroup      => null,
                     X_Last_Update_Date          => sysdate,
                     X_Last_Updated_By           => l_user,
                     X_Last_Update_Login         => l_user,
                     X_Created_By                => l_user,
                     X_Creation_Date             => sysdate
                     );

    hr_utility.set_location(l_proc, 250);

    pay_formula_result_rules_pkg.insert_row(
                     p_Rowid                     => l_rowid,
                     p_Formula_Result_Rule_Id    => l_formula_result_rule_id,
                     p_Effective_Start_Date      => l_effective_start_date,
                     p_Effective_End_Date        => l_effective_end_date,
                     p_Business_Group_Id         => p_business_group_id,
                     p_Legislation_Code          => l_leg_code,
                     p_Element_Type_Id           => l_tagging_element_type_id,
                     p_Status_Processing_Rule_Id => l_status_processing_rule_id,
                     p_Result_Name               => 'RETRO_ELEMENT_ENTRY_ID',
                     p_Result_Rule_Type          => 'I',
                     p_Legislation_Subgroup      => null,
                     p_Severity_Level            => 'I',
                     p_Input_Value_Id            => l_tagging_input_value_id,
                     p_Created_By                => l_user,
                     p_session_date              => sysdate
                     );

    hr_utility.set_location(l_proc, 260);

  end if;

  hr_utility.set_location(l_proc, 270);
  --
  -- Now call the insert row handler for pay accrual plans
  --
  pay_pap_ins.ins
    (p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_accrual_plan_element_type_id => l_accrual_plan_element_type_id
    ,p_pto_input_value_id           => p_pto_input_value_id
    ,p_co_input_value_id            => l_co_input_value_id
    ,p_residual_input_value_id      => l_residual_input_value_id
    ,p_accrual_category             => p_accrual_category
    ,p_accrual_plan_name            => p_Accrual_plan_name
    ,p_accrual_start                => p_accrual_start
    ,p_accrual_units_of_measure     => p_accrual_units_of_measure
    ,p_ineligible_period_length     => p_ineligible_period_length
    ,p_ineligible_period_type       => p_ineligible_period_type
    ,p_accrual_formula_id           => p_accrual_formula_id
    ,p_co_formula_id                => p_co_formula_id
    ,p_co_date_input_value_id       => l_co_date_input_value_id
    ,p_co_exp_date_input_value_id   => l_co_exp_date_input_value_id
    ,p_residual_date_input_value_id => l_residual_date_input_value_id
    ,p_description                  => p_description
    ,p_ineligibility_formula_id     => p_ineligibility_formula_id
    ,p_payroll_formula_id           => l_payroll_formula_id
    ,p_defined_balance_id           => l_defined_balance_id
    ,p_tagging_element_type_id      => l_tagging_element_type_id
    ,p_balance_element_type_id      => l_balance_element_type_id
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_information21                => p_information21
    ,p_information22                => p_information22
    ,p_information23                => p_information23
    ,p_information24                => p_information24
    ,p_information25                => p_information25
    ,p_information26                => p_information26
    ,p_information27                => p_information27
    ,p_information28                => p_information28
    ,p_information29                => p_information29
    ,p_information30                => p_information30
    ,p_accrual_plan_id              => l_accrual_plan_id
    ,p_object_version_number        => l_object_version_number
    ,p_check_accrual_ff             => p_check_accrual_ff
    );

  hr_utility.set_location(l_proc, 280);
  --
  -- Insert the two default elements of the plan into the
  -- net_calculation_rules table, beginning with
  -- the pto input value (always reduces entitlement)
  --
  pay_ncr_api.create_pay_net_calc_rule (
                  p_net_calculation_rule_id => l_net_calc_rule_id,
                  p_accrual_plan_id         => l_accrual_plan_id,
                  p_business_group_id       => p_business_group_id,
                  p_input_value_id          => p_pto_input_value_id,
                  p_add_or_subtract         => '-1',
                  p_date_input_value_id     => null,
                  p_object_version_number   => l_dummy_number
                 );

  hr_utility.set_location(l_proc, 290);
  --
  -- insert the carried over input value (always increases entitlement)
  --
  pay_ncr_api.create_pay_net_calc_rule (
                  p_net_calculation_rule_id => l_net_calc_rule_id,
                  p_accrual_plan_id         => l_accrual_plan_id,
                  p_business_group_id       => p_business_group_id,
                  p_input_value_id          => l_co_input_value_id,
                  p_add_or_subtract         => '1',
                  p_date_input_value_id     => l_co_date_input_value_id,
                  p_object_version_number   => l_dummy_number
                 );

  hr_utility.set_location(l_proc, 300);
  --
  -- Make PAY VALUE input value non-updateable
  --
  UPDATE        pay_input_values_f
  SET           mandatory_flag = 'X'
  WHERE input_value_id =
              ( SELECT  piv.input_value_id
                FROM    pay_input_values_f      piv,
                        pay_accrual_plans       pap
                WHERE   pap.accrual_plan_id = p_accrual_plan_id
                AND     pap.accrual_plan_element_type_id = piv.element_type_id
                AND     piv.name = 'Pay Value'
              );


  hr_utility.set_location(l_proc, 310);

  --
  -- Call After Process User Hook
  --
  begin
    hr_accrual_plan_bk1.create_accrual_plan_a
      (p_effective_date               => p_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_accrual_formula_id           => p_accrual_formula_id
      ,p_co_formula_id                => p_co_formula_id
      ,p_pto_input_value_id           => p_pto_input_value_id
      ,p_accrual_plan_name            => p_accrual_plan_name
      ,p_accrual_units_of_measure     => p_accrual_units_of_measure
      ,p_accrual_category             => p_accrual_category
      ,p_accrual_start                => p_accrual_start
      ,p_ineligible_period_length     => p_ineligible_period_length
      ,p_ineligible_period_type       => p_ineligible_period_type
      ,p_description                  => p_description
      ,p_ineligibility_formula_id     => p_ineligibility_formula_id
      ,p_balance_dimension_id         => p_balance_dimension_id
      ,p_accrual_plan_id              => l_accrual_plan_id
      ,p_accrual_plan_element_type_id => l_accrual_plan_element_type_id
      ,p_co_element_type_id           => l_co_element_type_id
      ,p_co_input_value_id            => l_co_input_value_id
      ,p_co_date_input_value_id       => l_co_date_input_value_id
      ,p_co_exp_date_input_value_id   => l_co_exp_date_input_value_id
      ,p_residual_element_type_id     => l_residual_element_type_id
      ,p_residual_input_value_id      => l_residual_input_value_id
      ,p_residual_date_input_value_id => l_residual_date_input_value_id
      ,p_payroll_formula_id           => l_payroll_formula_id
      ,p_defined_balance_id           => l_defined_balance_id
      ,p_balance_element_type_id      => l_balance_element_type_id
      ,p_tagging_element_type_id      => l_tagging_element_type_id
      ,p_object_version_number        => l_object_version_number
      ,p_no_link_message              => l_no_link_message
      ,p_information1                 => p_information1
      ,p_information2                 => p_information2
      ,p_information3                 => p_information3
      ,p_information4                 => p_information4
      ,p_information5                 => p_information5
      ,p_information6                 => p_information6
      ,p_information7                 => p_information7
      ,p_information8                 => p_information8
      ,p_information9                 => p_information9
      ,p_information10                => p_information10
      ,p_information11                => p_information11
      ,p_information12                => p_information12
      ,p_information13                => p_information13
      ,p_information14                => p_information14
      ,p_information15                => p_information15
      ,p_information16                => p_information16
      ,p_information17                => p_information17
      ,p_information18                => p_information18
      ,p_information19                => p_information19
      ,p_information20                => p_information20
      ,p_information21                => p_information21
      ,p_information22                => p_information22
      ,p_information23                => p_information23
      ,p_information24                => p_information24
      ,p_information25                => p_information25
      ,p_information26                => p_information26
      ,p_information27                => p_information27
      ,p_information28                => p_information28
      ,p_information29                => p_information29
      ,p_information30                => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_accrual_plan'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 320);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_accrual_plan_id              := l_accrual_plan_id;
  p_accrual_plan_element_type_id := l_accrual_plan_element_type_id;
  p_co_element_type_id           := l_co_element_type_id;
  p_co_date_input_value_id       := l_co_date_input_value_id;
  p_co_exp_date_input_value_id   := l_co_exp_date_input_value_id;
  p_co_input_value_id            := l_co_input_value_id;
  p_residual_element_type_id     := l_residual_element_type_id;
  p_residual_date_input_value_id := l_residual_date_input_value_id;
  p_residual_input_value_id      := l_residual_input_value_id;
  p_payroll_formula_id           := l_payroll_formula_id;
  p_defined_balance_id           := l_defined_balance_id;
  p_balance_element_type_id      := l_balance_element_type_id;
  p_tagging_element_type_id      := l_tagging_element_type_id;
  p_object_version_number        := l_object_version_number;
  p_no_link_message              := l_no_link_message;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN OUT NOCOPY / OUT NOCOPY PARAMETER          '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_accrual_plan_id                '||
                      to_char(p_accrual_plan_id));
  hr_utility.trace('  p_accrual_plan_element_type_id   '||
                      to_char(p_accrual_plan_element_type_id));
  hr_utility.trace('  p_co_element_type_id             '||
                      to_char(p_co_element_type_id));
  hr_utility.trace('  p_co_input_value_id              '||
                      to_char(p_co_input_value_id));
  hr_utility.trace('  p_co_date_input_value_id         '||
                      to_char(p_co_date_input_value_id));
  hr_utility.trace('  p_co_exp_date_input_value_id     '||
                      to_char(p_co_exp_date_input_value_id));
  hr_utility.trace('  p_residual_element_type_id       '||
                      to_char(p_residual_element_type_id));
  hr_utility.trace('  p_residual_input_value_id        '||
                      to_char(p_residual_input_value_id));
  hr_utility.trace('  p_residual_date_input_value_id   '||
                      to_char(p_residual_date_input_value_id));
  hr_utility.trace('  p_payroll_formula_id             '||
                      to_char(p_payroll_formula_id));
  hr_utility.trace('  p_defined_balance_id             '||
                      to_char(p_defined_balance_id));
  hr_utility.trace('  p_balance_element_type_id        '||
                      to_char(p_balance_element_type_id));
  hr_utility.trace('  p_tagging_element_type_id        '||
                      to_char(p_tagging_element_type_id));
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  IF p_no_link_message THEN
    hr_utility.trace('  p_no_link_message                '||
                        'TRUE');
  ELSE
    hr_utility.trace('  p_no_link_message                '||
                        'FALSE');
  END IF;
  IF p_check_accrual_ff THEN
    hr_utility.trace('  p_check_accrual_ff               '||
                        'TRUE');
  ELSE
    hr_utility.trace('  p_check_accrual_ff               '||
                        'FALSE');
  END IF;
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  hr_utility.set_location(' Leaving:'||l_proc, 70);

EXCEPTION

  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK to create_accrual_plan;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_accrual_plan_id              := null;
    p_accrual_plan_element_type_id := null;
    p_co_element_type_id           := null;
    p_co_date_input_value_id       := null;
    p_co_exp_date_input_value_id   := null;
    p_co_input_value_id            := null;
    p_residual_element_type_id     := null;
    p_residual_date_input_value_id := null;
    p_residual_input_value_id      := null;
    p_payroll_formula_id           := null;
    p_defined_balance_id           := null;
    p_balance_element_type_id      := null;
    p_tagging_element_type_id      := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:'||l_proc, 330);

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK to create_accrual_plan;
    -- Set OUT parameters to NULL.
    p_accrual_plan_id               := null;
    p_accrual_plan_element_type_id  := null;
    p_co_element_type_id            := null;
    p_co_input_value_id             := null;
    p_co_date_input_value_id        := null;
    p_co_exp_date_input_value_id    := null;
    p_residual_element_type_id      := null;
    p_residual_input_value_id       := null;
    p_residual_date_input_value_id  := null;
    p_payroll_formula_id            := null;
    p_defined_balance_id            := null;
    p_balance_element_type_id       := null;
    p_tagging_element_type_id       := null;
    p_object_version_number         := null;
    p_no_link_message               := null;
    p_check_accrual_ff              := null;

    hr_utility.set_location(' Leaving:'||l_proc, 340);
    RAISE;

END create_accrual_plan;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_accrual_plan >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_accrual_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_accrual_plan_id               in     number
  ,p_pto_input_value_id            in     number   default hr_api.g_number
  ,p_accrual_category              in     varchar2 default hr_api.g_varchar2
  ,p_accrual_start                 in     varchar2 default hr_api.g_varchar2
  ,p_ineligible_period_length      in     number   default hr_api.g_number
  ,p_ineligible_period_type        in     varchar2 default hr_api.g_varchar2
  ,p_accrual_formula_id            in     number   default hr_api.g_number
  ,p_co_formula_id                 in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_ineligibility_formula_id      in     number   default hr_api.g_number
  ,p_balance_dimension_id          in     number   default hr_api.g_number
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_payroll_formula_id               out nocopy number
  ,p_defined_balance_id               out nocopy number
  ,p_balance_element_type_id          out nocopy number
  ,p_tagging_element_type_id          out nocopy number
  ,p_check_accrual_ff                 out nocopy boolean)
IS

  --
  -- Fetches the current accrual plan.
  --
  cursor csr_get_accrual_plan IS
  select *
  from   pay_accrual_plans pap
  where  pap.accrual_plan_id = p_accrual_plan_id;

  --
  -- Declare cursors and local variables
  --
  cursor c_get_ncr(p_pto_input_value_id number) is
  select net_calculation_rule_id,
         object_version_number
  from   pay_net_calculation_rules
  where  accrual_plan_id = p_accrual_plan_id
  and    input_value_id  = p_pto_input_value_id;

  cursor c_class_id(p_classification_name varchar2,
                    p_business_group_id   number,
                    p_legislation_code    varchar2) is
  select classification_id
  from   pay_element_classifications
  where  classification_name = p_classification_name
  and    (business_group_id = p_business_group_id or
          legislation_code = p_legislation_code);

  --
  -- Cursor to retrieve details of absence element link, to be
  -- copied into links for other elements.
  --
  cursor c_absence_element_link_id is
  select *
  from   pay_element_links_f
  where  element_link_id in ( select distinct pel.element_link_id
                             from   pay_element_links_f pel,
                                    pay_input_values_f piv
                             where  pel.element_type_id = piv.element_type_id
                             and    piv.input_value_id = p_pto_input_value_id);

  --
  -- Cursor to get translated values for element and input value names
  --
  cursor c_get_lookups(p_lookup_code varchar2) is
  select meaning
  from hr_lookups
  where lookup_type = 'NAME_TRANSLATIONS'
  and lookup_code = p_lookup_code;

  --
  -- Cursors to get balance category id - first check for
  --   legislative specific entry, then look for global entry
  --
  cursor c_get_leg_bal_cat_id(p_leg_code varchar2) is
  select balance_category_id
  from   pay_balance_categories_f
  where  category_name = 'PTO Accruals'
  and    legislation_code = p_leg_code;

  cursor c_get_gbl_bal_cat_id is
  select balance_category_id
  from   pay_balance_categories_f
  where  category_name = 'PTO Accruals'
  and    legislation_code is null;

  l_proc                         varchar2(72);
  l_plan_rec                     csr_get_accrual_plan%ROWTYPE;
  l_rec                          c_get_ncr%rowtype;
  l_net_calculation_rule_id      number;
  l_object_version_number        number;
  l_dummy                        number;
  l_effective_start_date         date;
  l_effective_end_date           date;
  l_user                         varchar2(80);
  l_rowid                        varchar2(80);
  l_status_processing_rule_id    number;
  l_formula_result_rule_id       number;
  l_priority                     number;
  l_balance_category_id          number;
  l_balance_type_id              number;
  l_balance_feed_id              number;
  l_tagging_formula_id           number;
  l_balance_input_value_id       number;
  l_tagging_input_value_id       number;
  l_balance_name                 varchar2(80);
  l_leg_code                     varchar2(30);
  l_uom_code                     varchar2(80);
  l_uom_code1                    varchar2(80);
  l_element_name                 varchar2(80);
  l_input_value_name             varchar2(80);
  l_primary_classification_id    number;
  l_classification_type          varchar2(2);
  l_bg_name                      per_business_groups.name%TYPE;
  l_curr_code                    varchar2(150);
  l_classification_name          varchar2(240);
  l_post_termination_rule        varchar2(240);
  l_temp_ovn                     number;

BEGIN

  l_proc  := g_package||'update_accrual_plan';
  l_temp_ovn := p_object_version_number;

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Pipe the main IN / IN OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN / IN OUT NOCOPY PARAMETER           '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  IF p_validate THEN
    hr_utility.trace('  p_validate                       '||
                        'TRUE');
  ELSE
    hr_utility.trace('  p_validate                       '||
                        'FALSE');
  END IF;
  hr_utility.trace('  p_effective_date                 '||
                      to_char(p_effective_date));
  hr_utility.trace('  p_accrual_plan_id                '||
                      to_char(p_accrual_plan_id));
  hr_utility.trace('  p_pto_input_value_id             '||
                      to_char(p_pto_input_value_id));
  hr_utility.trace('  p_accrual_category               '||
                      p_accrual_category);
  hr_utility.trace('  p_accrual_start                  '||
                      p_accrual_start);
  hr_utility.trace('  p_ineligible_period_length       '||
                      to_char(p_ineligible_period_length));
  hr_utility.trace('  p_ineligible_period_type         '||
                      p_ineligible_period_type);
  hr_utility.trace('  p_accrual_formula_id             '||
                      to_char(p_accrual_formula_id));
  hr_utility.trace('  p_co_formula_id                  '||
                      to_char(p_co_formula_id));
  hr_utility.trace('  p_description                    '||
                      p_description);
  hr_utility.trace('  p_ineligibility_formula_id       '||
                      to_char(p_ineligibility_formula_id));
  hr_utility.trace('  p_balance_dimension_id           '||
                      to_char(p_balance_dimension_id));
  hr_utility.trace('  p_information_category           '||
                      p_information_category);
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  --
  -- Issue a savepoint
  --
  savepoint update_accrual_plan;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_accrual_plan_bk2.update_accrual_plan_b
      (p_accrual_plan_id              => p_accrual_plan_id
      ,p_pto_input_value_id           => p_pto_input_value_id
      ,p_accrual_category             => p_accrual_category
      ,p_accrual_start                => p_accrual_start
      ,p_ineligible_period_length     => p_ineligible_period_length
      ,p_ineligible_period_type       => p_ineligible_period_type
      ,p_accrual_formula_id           => p_accrual_formula_id
      ,p_co_formula_id                => p_co_formula_id
      ,p_description                  => p_description
      ,p_ineligibility_formula_id     => p_ineligibility_formula_id
      ,p_balance_dimension_id         => p_balance_dimension_id
      ,p_object_version_number        => p_object_version_number
      ,p_information_category         => p_information_category
      ,p_information1                 => p_information1
      ,p_information2                 => p_information2
      ,p_information3                 => p_information3
      ,p_information4                 => p_information4
      ,p_information5                 => p_information5
      ,p_information6                 => p_information6
      ,p_information7                 => p_information7
      ,p_information8                 => p_information8
      ,p_information9                 => p_information9
      ,p_information10                => p_information10
      ,p_information11                => p_information11
      ,p_information12                => p_information12
      ,p_information13                => p_information13
      ,p_information14                => p_information14
      ,p_information15                => p_information15
      ,p_information16                => p_information16
      ,p_information17                => p_information17
      ,p_information18                => p_information18
      ,p_information19                => p_information19
      ,p_information20                => p_information20
      ,p_information21                => p_information21
      ,p_information22                => p_information22
      ,p_information23                => p_information23
      ,p_information24                => p_information24
      ,p_information25                => p_information25
      ,p_information26                => p_information26
      ,p_information27                => p_information27
      ,p_information28                => p_information28
      ,p_information29                => p_information29
      ,p_information30                => p_information30

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_accrual_plan'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);

  --
  -- Validation in addition to Row Handlers
  --
  -- Fetch the current accrual plan details.
  --
  OPEN  csr_get_accrual_plan;
  FETCH csr_get_accrual_plan into l_plan_rec;

  IF csr_get_accrual_plan%NOTFOUND THEN
    --
    -- p_accrual_plan_id does not exist so error.
    --
    hr_utility.set_location(l_proc, 30);
    CLOSE csr_get_accrual_plan;
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;

  END IF;

  CLOSE csr_get_accrual_plan;

  hr_utility.set_location(l_proc, 40);

  IF l_plan_rec.defined_balance_id IS NULL AND
     p_balance_dimension_id IS NOT NULL AND
     p_balance_dimension_id <> hr_api.g_number THEN

    --
    -- Setup the accrual plan for payroll balances.
    --

    -- The items returned by this select are used in setting up
    -- the elements with the correct leg code and currency code.
    --
    select name, legislation_code, currency_code
    into   l_bg_name, l_leg_code, l_curr_code
    from   per_business_groups
    where  business_group_id = l_plan_rec.business_group_id;

    hr_utility.trace('l_bg_name: '||l_bg_name);
    hr_utility.trace('l_leg_code: '||l_leg_code);
    hr_utility.trace('l_curr_code: '||l_curr_code);

    l_classification_name   := 'Information';

    open c_class_id('Information', l_plan_rec.business_group_id, l_leg_code);
    fetch c_class_id into l_primary_classification_id;
    close c_class_id;

    hr_utility.set_location(l_proc, 50);

    select processing_priority + 1
    into l_priority
    from pay_element_types_f
    where element_type_id = l_plan_rec.accrual_plan_element_type_id;

    hr_utility.trace('l_priority: '||to_char(l_priority));

    l_leg_code := null;

    --
    -- Get the termination rule
    --
    begin
    --
      select hl.meaning
      into l_post_termination_rule
      from hr_lookups hl
      where hl.lookup_type='TERMINATION_RULE'
      and hl.lookup_code='F';    -- Final Close

      hr_utility.trace('l_post_termination_rule: '||l_post_termination_rule);

    exception
    --
      when no_data_found then
      hr_utility.set_location(l_proc, 60);
      hr_utility.set_message(801,'HR_NO_F_TERM_RULE');
      hr_utility.raise_error;
    --
    end;

    l_classification_type       := 'Y';

    --
    if l_plan_rec.accrual_units_of_measure = 'D' then
    --
      hr_utility.set_location(l_proc, 70);
      open c_get_lookups('PTO_DAYS');
      l_uom_code := 'ND';
    --
    else
    --
      hr_utility.set_location(l_proc, 80);
      open c_get_lookups('PTO_HOURS');
      l_uom_code := 'H_DECIMAL3';
    --
    end if;

    fetch c_get_lookups into l_input_value_name;
    close c_get_lookups;

    hr_utility.trace('l_input_value_name: '||l_input_value_name);

    IF l_plan_rec.balance_element_type_id IS NULL THEN
      --
      -- This plan was created prior to the balance enhancements and
      -- so does not alerady have the balance element.  It is now
      -- being updated for the first time so create the additional
      -- element.
      --
      l_element_name := substr(l_plan_rec.accrual_plan_name
                               ||' Payroll Balance', 1, 80);

      hr_utility.trace('l_element_name: '||l_element_name);

      l_plan_rec.balance_element_type_id := create_element(
            l_element_name,
            null,
            'N',
            l_bg_name,
            l_classification_name,
            l_leg_code,
            l_curr_code,
            l_post_termination_rule,
            'Y',
            'Y',
            null,
            l_priority
            );

      hr_utility.trace('l_plan_rec.balance_element_type_id: '
                       ||to_char(l_plan_rec.balance_element_type_id));

      l_balance_input_value_id := create_input_value(
            l_element_name,
            l_input_value_name,
            l_uom_code,
            l_bg_name,
            l_plan_rec.balance_element_type_id,
            l_primary_classification_id,
            l_plan_rec.business_group_id,
            'N',
            l_leg_code,
            l_classification_type,
            'N'
            );

      hr_utility.trace('l_balance_input_value_id: '||to_char(l_balance_input_value_id));

      for l_element_link_rec in c_absence_element_link_id loop
        --
        --
        -- Create a link for the balance element
        --
        create_element_link
          (p_element_type_id  => l_plan_rec.balance_element_type_id,
           p_absence_link_rec => l_element_link_rec,
           p_legislation_code => l_leg_code);

      end loop;

    END IF;

    hr_utility.set_location(l_proc, 90);

    IF l_plan_rec.tagging_element_type_id IS NULL THEN
      --
      -- This plan was created prior to the balance enhancements and
      -- so does not alerady have the tagging element.  It is now
      -- being updated for the first time so create the additional
      -- element.
      --
      select processing_priority
      into l_priority
      from pay_element_types_f
      where element_type_id = l_plan_rec.accrual_plan_element_type_id;

      hr_utility.trace('l_priority: '||to_char(l_priority));

      l_element_name := substr(l_plan_rec.accrual_plan_name||' Tagging', 1, 80);

      hr_utility.trace('l_element_name: '||l_element_name);

      l_plan_rec.tagging_element_type_id := create_element(
            l_element_name,
            null,
            'N',
            l_bg_name,
            l_classification_name,
            l_leg_code,
            l_curr_code,
            l_post_termination_rule,
            'Y',
            'Y',
            null,
            l_priority
            );

      hr_utility.trace('l_plan_rec.tagging_element_type_id: '
                       ||to_char(l_plan_rec.tagging_element_type_id));
      l_uom_code1 := 'N';
      l_input_value_name := 'Element Entry ID';

      l_tagging_input_value_id := create_input_value(
            l_element_name,
            l_input_value_name,
            l_uom_code1,
            l_bg_name,
            l_plan_rec.tagging_element_type_id,
            l_primary_classification_id,
            l_plan_rec.business_group_id,
            'N',
            l_leg_code,
            l_classification_type,
            'N'
            );

      hr_utility.trace('l_tagging_input_value_id: '||to_char(l_tagging_input_value_id));

      for l_element_link_rec in c_absence_element_link_id loop
        --
        -- Create a link for the tagging element
        --
        create_element_link
          (p_element_type_id  => l_plan_rec.tagging_element_type_id,
           p_absence_link_rec => l_element_link_rec,
           p_legislation_code => l_leg_code);

      end loop;

    END IF;

    hr_utility.set_location(l_proc, 100);

    l_user := fnd_profile.value('USER');
    l_effective_start_date := hr_general.start_of_time;
    l_effective_end_date := hr_general.end_of_time;

    hr_utility.trace('l_user: '||l_user);
    --
    -- Now set up the balance information. This requires rows to be inserted in
    -- pay_balance_feeds, pay_balace_types, and pay_defined_balances. We will
    -- make use of the seeded balance dimension, route etc.
    --
    l_leg_code := null;
    l_balance_name := substr(l_plan_rec.accrual_plan_name||' Balance', 1, 80);

    open c_get_leg_bal_cat_id(l_leg_code);
    fetch c_get_leg_bal_cat_id into l_balance_category_id;
    if c_get_leg_bal_cat_id%notfound then
      open c_get_gbl_bal_cat_id;
      fetch c_get_gbl_bal_cat_id into l_balance_category_id;
      if c_get_gbl_bal_cat_id%notfound then
        l_balance_category_id := null;
      end if;
      close c_get_gbl_bal_cat_id;
    end if;
    close c_get_leg_bal_cat_id;

    pay_balance_types_pkg.Insert_Row(
                      X_Rowid                        => l_rowid,
                      X_Balance_Type_Id              => l_balance_type_id,
                      X_Business_Group_Id            => l_plan_rec.business_group_id,
                      X_Legislation_Code             => l_leg_code,
                      X_Currency_Code                => null,
                      X_Assignment_Remuneration_Flag => 'N',
                      X_Balance_Name                 => l_balance_name,
                      X_Base_Balance_Name            => l_balance_name,
                      X_Balance_Uom                  => l_uom_code,
                      X_Comments                     => null,
                      X_Legislation_Subgroup         => null,
                      X_Reporting_Name               => substr(l_balance_name, 1, 30),
                      X_Attribute_Category           => null,
                      X_Attribute1                   => null,
                      X_Attribute2                   => null,
                      X_Attribute3                   => null,
                      X_Attribute4                   => null,
                      X_Attribute5                   => null,
                      X_Attribute6                   => null,
                      X_Attribute7                   => null,
                      X_Attribute8                   => null,
                      X_Attribute9                   => null,
                      X_Attribute10                  => null,
                      X_Attribute11                  => null,
                      X_Attribute12                  => null,
                      X_Attribute13                  => null,
                      X_Attribute14                  => null,
                      X_Attribute15                  => null,
                      X_Attribute16                  => null,
                      X_Attribute17                  => null,
                      X_Attribute18                  => null,
                      X_Attribute19                  => null,
                      X_Attribute20                  => null,
                      X_Balance_Category_Id          => l_balance_category_id
                      );

    hr_utility.set_location(l_proc, 100);

    select input_value_id
    into l_balance_input_value_id
    from pay_input_values_f
    where element_type_id = l_plan_rec.balance_element_type_id
    and uom = l_uom_code;

    hr_utility.trace('l_balance_input_value_id: '||to_char(l_balance_input_value_id));

    pay_balance_feeds_f_pkg.Insert_Row(
                      X_Rowid                => l_rowid,
                      X_Balance_Feed_Id      => l_balance_feed_id,
                      X_Effective_Start_Date => hr_general.start_of_time,
                      X_Effective_End_Date   => hr_general.end_of_time,
                      X_Business_Group_Id    => l_plan_rec.business_group_id,
                      X_Legislation_Code     => l_leg_code,
                      X_Balance_Type_Id      => l_balance_type_id,
                      X_Input_Value_Id       => l_balance_input_value_id,
                      X_Scale                => 1,
                      X_Legislation_Subgroup => null
                      );

    hr_utility.set_location(l_proc, 110);

    pay_defined_balances_pkg.Insert_Row(
        X_Rowid                => l_rowid,
        X_Defined_Balance_Id   => l_plan_rec.defined_balance_id,
        X_Business_Group_Id    => l_plan_rec.business_group_id,
        X_Legislation_Code     => l_leg_code,
        X_Balance_Type_Id      => l_balance_type_id,
        X_Balance_Dimension_Id => p_balance_dimension_id,
        X_Force_Latest_Balance_Flag=> 'N',
        X_Legislation_Subgroup => null
        );

    hr_utility.set_location(l_proc, 120);

    --
    -- Call procedure to create new Oracle Payroll fomrula.
    --
    create_payroll_formula(
      p_formula_id           => l_plan_rec.payroll_formula_id,
      p_effective_start_date => l_effective_start_date,
      p_effective_end_date   => l_effective_end_date,
      p_accrual_plan_name    => l_plan_rec.accrual_plan_name,
      p_defined_balance_id   => l_plan_rec.defined_balance_id,
      p_business_group_id    => l_plan_rec.business_group_id,
      p_legislation_code     => l_leg_code
    );

    hr_utility.set_location(l_proc, 130);

    --
    -- Set up the status processing rules and formula result rules for the
    -- recurring accrual plan element.
    --
    pay_status_rules_pkg.insert_row
      (X_Rowid                     => l_rowid,
       X_Status_Processing_Rule_Id => l_status_processing_rule_id,
       X_Effective_Start_Date      => l_effective_start_date,
       X_Effective_End_Date        => l_effective_end_date,
       X_Business_Group_Id         => l_plan_rec.business_group_id,
       X_Legislation_Code          => l_leg_code,
       X_Element_Type_Id           => l_plan_rec.accrual_plan_element_type_id,
       X_Assignment_Status_Type_Id => null,
       X_Formula_Id                => l_plan_rec.payroll_formula_id,
       X_Processing_Rule           => 'P',
       X_Comment_Id                => null,
       X_Legislation_Subgroup      => null,
       X_Last_Update_Date          => sysdate,
       X_Last_Updated_By           => l_user,
       X_Last_Update_Login         => l_user,
       X_Created_By                => l_user,
       X_Creation_Date             => sysdate
      );

    hr_utility.set_location(l_proc, 140);

    pay_formula_result_rules_pkg.insert_row
      (p_Rowid                     => l_rowid,
       p_Formula_Result_Rule_Id    => l_formula_result_rule_id,
       p_Effective_Start_Date      => l_effective_start_date,
       p_Effective_End_Date        => l_effective_end_date,
       p_Business_Group_Id         => l_plan_rec.business_group_id,
       p_Legislation_Code          => l_leg_code,
       p_Element_Type_Id           => l_plan_rec.balance_element_type_id,
       p_Status_Processing_Rule_Id => l_status_processing_rule_id,
       p_Result_Name               => 'TOTAL_ACCRUED_PTO',
       p_Result_Rule_Type          => 'I',
       p_Legislation_Subgroup      => null,
       p_Severity_Level            => 'I',
       p_Input_Value_Id            => l_balance_input_value_id,
       p_Created_By                => l_user,
       p_session_date              => sysdate
      );

    l_formula_result_rule_id := null;

    select input_value_id
    into l_tagging_input_value_id
    from pay_input_values_f
    where element_type_id = l_plan_rec.tagging_element_type_id
    and uom = 'N';

    hr_utility.trace('l_tagging_input_value_id: '||to_char(l_tagging_input_value_id));

    pay_formula_result_rules_pkg.insert_row
      (p_Rowid                     => l_rowid,
       p_Formula_Result_Rule_Id    => l_formula_result_rule_id,
       p_Effective_Start_Date      => l_effective_start_date,
       p_Effective_End_Date        => l_effective_end_date,
       p_Business_Group_Id         => l_plan_rec.business_group_id,
       p_Legislation_Code          => l_leg_code,
       p_Element_Type_Id           => l_plan_rec.tagging_element_type_id,
       p_Status_Processing_Rule_Id => l_status_processing_rule_id,
       p_Result_Name               => 'DUMMY',
       p_Result_Rule_Type          => 'I',
       p_Legislation_Subgroup      => null,
       p_Severity_Level            => 'I',
       p_Input_Value_Id            => l_tagging_input_value_id,
       p_Created_By                => l_user,
       p_session_date              => sysdate
      );

    --
    -- Set up the status processing rules and formula result rules for the
    -- tagging element.
    --

    select formula_id
    into l_tagging_formula_id
    from ff_formulas_f ff,
         ff_formula_types ft
    where ff.formula_type_id = ft.formula_type_id
    and ft.formula_type_name = 'Oracle Payroll'
    and ff.formula_name = 'PTO_TAGGING_FORMULA';

    hr_utility.trace('l_tagging_formula_id: '||to_char(l_tagging_formula_id));

    l_status_processing_rule_id := null;
    l_formula_result_rule_id := null;

    pay_status_rules_pkg.insert_row
      (X_Rowid                     => l_rowid,
       X_Status_Processing_Rule_Id => l_status_processing_rule_id,
       X_Effective_Start_Date      => l_effective_start_date,
       X_Effective_End_Date        => l_effective_end_date,
       X_Business_Group_Id         => l_plan_rec.business_group_id,
       X_Legislation_Code          => l_leg_code,
       X_Element_Type_Id           => l_plan_rec.tagging_element_type_id,
       X_Assignment_Status_Type_Id => null,
       X_Formula_Id                => l_tagging_formula_id,
       X_Processing_Rule           => 'P',
       X_Comment_Id                => null,
       X_Legislation_Subgroup      => null,
       X_Last_Update_Date          => sysdate,
       X_Last_Updated_By           => l_user,
       X_Last_Update_Login         => l_user,
       X_Created_By                => l_user,
       X_Creation_Date             => sysdate
      );

    hr_utility.set_location(l_proc, 150);

    pay_formula_result_rules_pkg.insert_row
      (p_Rowid                     => l_rowid,
       p_Formula_Result_Rule_Id    => l_formula_result_rule_id,
       p_Effective_Start_Date      => l_effective_start_date,
       p_Effective_End_Date        => l_effective_end_date,
       p_Business_Group_Id         => l_plan_rec.business_group_id,
       p_Legislation_Code          => l_leg_code,
       p_Element_Type_Id           => l_plan_rec.tagging_element_type_id,
       p_Status_Processing_Rule_Id => l_status_processing_rule_id,
       p_Result_Name               => 'RETRO_ELEMENT_ENTRY_ID',
       p_Result_Rule_Type          => 'I',
       p_Legislation_Subgroup      => null,
       p_Severity_Level            => 'I',
       p_Input_Value_Id            => l_tagging_input_value_id,
       p_Created_By                => l_user,
       p_session_date              => sysdate
      );

    hr_utility.set_location(l_proc, 160);

  end if;

  l_object_version_number := p_object_version_number;

  hr_utility.set_location(l_proc, 170);

  pay_pap_upd.upd
    (p_effective_date               => p_effective_date,
     p_accrual_plan_id              => p_accrual_plan_id,
     p_pto_input_value_id           => p_pto_input_value_id,
     p_accrual_category             => p_accrual_category,
     p_accrual_start                => p_accrual_start,
     p_ineligible_period_length     => p_ineligible_period_length,
     p_ineligible_period_type       => p_ineligible_period_type,
     p_accrual_formula_id           => p_accrual_formula_id,
     p_co_formula_id                => p_co_formula_id,
     p_description                  => p_description,
     p_ineligibility_formula_id     => p_ineligibility_formula_id,
     p_payroll_formula_id           => l_plan_rec.payroll_formula_id,
     p_defined_balance_id           => l_plan_rec.defined_balance_id,
     p_tagging_element_type_id      => l_plan_rec.tagging_element_type_id,
     p_balance_element_type_id      => l_plan_rec.balance_element_type_id,
     p_information_category         => p_information_category,
     p_information1		    => p_information1,
     p_information2		    => p_information2,
     p_information3		    => p_information3,
     p_information4                 => p_information4,
     p_information5                 => p_information5,
     p_information6                 => p_information6,
     p_information7                 => p_information7,
     p_information8                 => p_information8,
     p_information9                 => p_information9,
     p_information10                => p_information10,
     p_information11                => p_information11,
     p_information12                => p_information12,
     p_information13                => p_information13,
     p_information14                => p_information14,
     p_information15                => p_information15,
     p_information16                => p_information16,
     p_information17                => p_information17,
     p_information18                => p_information18,
     p_information19                => p_information19,
     p_information20                => p_information20,
     p_information21                => p_information21,
     p_information22                => p_information22,
     p_information23                => p_information23,
     p_information24                => p_information24,
     p_information25                => p_information25,
     p_information26                => p_information26,
     p_information27                => p_information27,
     p_information28                => p_information28,
     p_information29                => p_information29,
     p_information30                => p_information30,
     p_object_version_number        => l_object_version_number,
     p_check_accrual_ff             => p_check_accrual_ff
    );

  hr_utility.set_location(l_proc, 180);

  if  p_pto_input_value_id <> hr_api.g_number
  and p_pto_input_value_id <> pay_pap_shd.g_old_rec.pto_input_value_id then
  --
    for l_ncr_rec in c_get_ncr(pay_pap_shd.g_old_rec.pto_input_value_id) loop
    --
      pay_ncr_api.delete_pay_net_calc_rule
          (p_net_calculation_rule_id => l_ncr_rec.net_calculation_rule_id,
           p_object_version_number   => l_ncr_rec.object_version_number
          );
    --
    end loop;

    --
    --   create a new net calculation rule for the new pto input value if one
    --   does not already exist
    --
    open c_get_ncr(p_pto_input_value_id);
    fetch c_get_ncr into l_rec;

    hr_utility.set_location(l_proc, 190);

    if c_get_ncr%notfound then
    --
      hr_utility.set_location(l_proc, 200);

      pay_ncr_api.create_pay_net_calc_rule(
                      p_net_calculation_rule_id => l_net_calculation_rule_id,
                      p_accrual_plan_id         => p_accrual_plan_id,
                      p_business_group_id       => l_plan_rec.business_group_id,
                      p_input_value_id          => p_pto_input_value_id,
                      p_add_or_subtract         => '-1',
                      p_date_input_value_id     => null,
                      p_object_version_number   => l_dummy
                      );

      hr_utility.set_location(l_proc, 210);

    end if;

    close c_get_ncr;
  --
  end if;

  hr_utility.set_location(l_proc, 210);
  --
  -- Call After Process User Hook
  --
  begin
    hr_accrual_plan_bk2.update_accrual_plan_a
      (p_accrual_plan_id              => p_accrual_plan_id
      ,p_pto_input_value_id           => p_pto_input_value_id
      ,p_accrual_category             => p_accrual_category
      ,p_accrual_start                => p_accrual_start
      ,p_ineligible_period_length     => p_ineligible_period_length
      ,p_ineligible_period_type       => p_ineligible_period_type
      ,p_accrual_formula_id           => p_accrual_formula_id
      ,p_co_formula_id                => p_co_formula_id
      ,p_description                  => p_description
      ,p_ineligibility_formula_id     => p_ineligibility_formula_id
      ,p_payroll_formula_id           => p_payroll_formula_id
      ,p_defined_balance_id           => l_plan_rec.defined_balance_id
      ,p_balance_dimension_id         => p_balance_dimension_id
      ,p_tagging_element_type_id      => l_plan_rec.tagging_element_type_id
      ,p_balance_element_type_id      => l_plan_rec.balance_element_type_id
      ,p_object_version_number        => l_object_version_number
      ,p_information_category	      => p_information_category
      ,p_information1                 => p_information1
      ,p_information2                 => p_information2
      ,p_information3                 => p_information3
      ,p_information4                 => p_information4
      ,p_information5                 => p_information5
      ,p_information6                 => p_information6
      ,p_information7                 => p_information7
      ,p_information8                 => p_information8
      ,p_information9                 => p_information9
      ,p_information10                => p_information10
      ,p_information11                => p_information11
      ,p_information12                => p_information12
      ,p_information13                => p_information13
      ,p_information14                => p_information14
      ,p_information15                => p_information15
      ,p_information16                => p_information16
      ,p_information17                => p_information17
      ,p_information18                => p_information18
      ,p_information19                => p_information19
      ,p_information20                => p_information20
      ,p_information21                => p_information21
      ,p_information22                => p_information22
      ,p_information23                => p_information23
      ,p_information24                => p_information24
      ,p_information25                => p_information25
      ,p_information26                => p_information26
      ,p_information27                => p_information27
      ,p_information28                => p_information28
      ,p_information29                => p_information29
      ,p_information30                => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_accrual_plan'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 220);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --

    p_object_version_number   := l_object_version_number;
    p_payroll_formula_id      := l_plan_rec.payroll_formula_id;
    p_defined_balance_id      := l_plan_rec.defined_balance_id;
    p_tagging_element_type_id := l_plan_rec.tagging_element_type_id;
    p_balance_element_type_id := l_plan_rec.balance_element_type_id;

  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN OUT NOCOPY / OUT NOCOPY PARAMETER          '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  hr_utility.trace('  p_payroll_formula_id             '||
                      to_char(p_payroll_formula_id));
  hr_utility.trace('  p_defined_balance_id             '||
                      to_char(p_defined_balance_id));
  hr_utility.trace('  p_balance_element_type_id        '||
                      to_char(p_balance_element_type_id));
  hr_utility.trace('  p_tagging_element_type_id        '||
                      to_char(p_tagging_element_type_id));
  IF p_check_accrual_ff THEN
    hr_utility.trace('  p_check_accrual_ff               '||
                        'TRUE');
  ELSE
    hr_utility.trace('  p_check_accrual_ff               '||
                        'FALSE');
  END IF;
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  hr_utility.set_location(' Leaving:'||l_proc, 230);

EXCEPTION

  WHEN hr_api.validate_enabled THEN

    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_accrual_plan;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    p_payroll_formula_id      := null;
    p_defined_balance_id      := null;
    p_tagging_element_type_id := null;
    p_balance_element_type_id := null;

    hr_utility.set_location(' Leaving:'||l_proc, 240);

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK to update_accrual_plan;
    -- Reset IN OUT parameters and set OUT parameters.
    p_object_version_number         := l_temp_ovn;
    p_payroll_formula_id            := null;
    p_defined_balance_id            := null;
    p_balance_element_type_id       := null;
    p_tagging_element_type_id       := null;
    p_check_accrual_ff              := null;
    hr_utility.set_location(' Leaving:'||l_proc, 250);

    RAISE;

END update_accrual_plan;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_accrual_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_accrual_plan_id               in     number
  ,p_accrual_plan_element_type_id  in     number
  ,p_co_element_type_id            in     number
  ,p_residual_element_type_id      in     number
  ,p_balance_element_type_id       in     number
  ,p_tagging_element_type_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  cursor c_get_ncr(p_accrual_plan_id number) is
  select net_calculation_rule_id,
         object_version_number
  from   pay_net_calculation_rules
  where  accrual_plan_id = p_accrual_plan_id;

  l_proc                varchar2(72);
  l_effective_start_date     date;
  l_effective_end_date       date;
  l_balance_element_type_id  number;

begin
  l_proc  := g_package||'delete_accrual_plan';
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_accrual_plan;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_accrual_plan_bk3.delete_accrual_plan_b
      (p_effective_date               => p_effective_date
      ,p_accrual_plan_id              => p_accrual_plan_id
      ,p_accrual_plan_element_type_id => p_accrual_plan_element_type_id
      ,p_co_element_type_id           => p_co_element_type_id
      ,p_residual_element_type_id     => p_residual_element_type_id
      ,p_balance_element_type_id      => p_balance_element_type_id
      ,p_tagging_element_type_id      => p_tagging_element_type_id
      ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_accrual_plan'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --

  l_effective_start_date := hr_general.start_of_time;
  l_effective_end_date   := hr_general.end_of_time;

  --
  -- delete the accrual bands
  --
  delete from pay_accrual_bands
  where  accrual_plan_id = p_accrual_plan_id;


  --
  -- delete the net calculation rules
  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 41);
  for l_ncr in c_get_ncr(p_accrual_plan_id) loop
  --
    pay_ncr_api.delete_pay_net_calc_rule (
          p_net_calculation_rule_id => l_ncr.net_calculation_rule_id,
          p_object_version_number   => l_ncr.object_version_number
          );
  --
  end loop;

  --
  -- delete the element types created for the plan
  --
  -- first the accrual plan element type...
  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 42);
  hr_elements.chk_del_element_type (
      'ZAP',
      p_accrual_plan_element_type_id,
      '',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date);

  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 43);
  hr_elements.del_3p_element_type (
      p_accrual_plan_element_type_id,
      'ZAP',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date,
      '');

  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions',44);
  delete from pay_element_types_f
  where  element_type_id = p_accrual_plan_element_type_id;

  --
  -- ...then the carried over element type...
  --

  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 45);
  hr_elements.chk_del_element_type (
      'ZAP',
      p_co_element_type_id,
      '',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date);

  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 46);
  hr_elements.del_3p_element_type (
      p_co_element_type_id,
      'ZAP',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date,
      '');

   --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions',47);
  hr_utility.trace('DELETE ELEMENT: '||to_char(p_co_element_type_id));
  delete from pay_element_types_f
  where  element_type_id = p_co_element_type_id;

  --
  -- ...then the residual element type.
  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 48);

  hr_elements.chk_del_element_type (
      'ZAP',
      p_residual_element_type_id,
      '',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date);

  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 49);
  hr_elements.del_3p_element_type (
      p_residual_element_type_id,
      'ZAP',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date,
      '');

  --
  delete from pay_element_types_f
  where  element_type_id = p_residual_element_type_id;


  --
  -- ...then the payroll balance element type.
  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 50);

  hr_elements.chk_del_element_type (
      'ZAP',
      p_balance_element_type_id,
      '',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date);

  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 51);
  hr_elements.del_3p_element_type (
      p_balance_element_type_id,
      'ZAP',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date,
      '');

  --
  delete from pay_element_types_f
  where  element_type_id = p_balance_element_type_id;

  --
  -- ...then the tagging element type.
  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 50);

  hr_elements.chk_del_element_type (
      'ZAP',
      p_tagging_element_type_id,
      '',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date);

  --
  hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 51);
  hr_elements.del_3p_element_type (
      p_tagging_element_type_id,
      'ZAP',
      p_effective_date,
      l_effective_start_date,
      l_effective_end_date,
      '');

  --
  delete from pay_element_types_f
  where  element_type_id = p_tagging_element_type_id;

  --
  -- Finally, delete the accrual plan record itself
  --
  pay_pap_del.del (
      p_accrual_plan_id       => p_accrual_plan_id,
      p_object_version_number => p_object_version_number
      );

  hr_utility.set_location(l_proc, 60);
  --
  -- Call After Process User Hook
  --
  begin
    hr_accrual_plan_bk3.delete_accrual_plan_a
      (p_effective_date               => p_effective_date
      ,p_accrual_plan_id              => p_accrual_plan_id
      ,p_accrual_plan_element_type_id => p_accrual_plan_element_type_id
      ,p_co_element_type_id           => p_co_element_type_id
      ,p_residual_element_type_id     => p_residual_element_type_id
      ,p_balance_element_type_id      => p_balance_element_type_id
      ,p_tagging_element_type_id      => p_tagging_element_type_id
      ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_accrual_plan'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 65);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_accrual_plan;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_accrual_plan;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_accrual_plan;
--
end hr_accrual_plan_api;

/
