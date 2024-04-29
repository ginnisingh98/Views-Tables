--------------------------------------------------------
--  DDL for Package Body PAY_CTY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CTY_BUS" as
/* $Header: pyctyrhi.pkb 120.0.12000000.2 2007/05/01 22:44:28 ahanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_cty_bus.';  -- Global package name
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_assignment_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Determines if the current assignment has:
--     a valid assignment id as of the defaulting date.
--
--  Pre_conditions:
--    A valid business_group_id
--
--  In Arguments:
--    p_emp_county_tax_rule_id
--    p_business_group_id
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    The assignment_id is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the assignment_id is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
procedure chk_assignment_id
   (p_emp_city_tax_rule_id in
       pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE
   ,p_assignment_id          in
       pay_us_emp_city_tax_rules_f.assignment_id%TYPE
   ,p_business_group_id      in
       pay_us_emp_city_tax_rules_f.business_group_id%TYPE
   ,p_effective_date         in date
   ,p_object_version_number  in number
   )
   is
--
   l_proc                     varchar2(72) := g_package||'chk_assignment_id';
   l_tmp                      varchar2(2);
   l_api_updating             boolean;
   l_assignment_id            per_assignments_f.assignment_id%TYPE;
   l_business_group_id        per_assignments_f.business_group_id%TYPE;
   --
   --
   cursor csr_business_grp is
      select business_group_id
      from per_assignments_f
      where assignment_id = p_assignment_id
        and p_effective_date between effective_start_date and
            effective_end_date;
   --
   cursor csr_defaulting is
      select null
      from pay_us_emp_fed_tax_rules_f
      where assignment_id = p_assignment_id
        and p_effective_date between effective_start_date and
            effective_end_date;
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- Check to see if mandatory parameters have been set.
   --
   if p_assignment_id is null then
     hr_utility.set_message(801,'PAY_72736_CTY_ASG_NOT_NULL');
     hr_utility.raise_error;
   elsif p_business_group_id is null then
     hr_utility.set_message(801,'PAY_72738_CTY_BG_NOT_NULL');
     hr_utility.raise_error;
   end if;
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'effective_date'
      ,p_argument_value   => p_effective_date
      );
   --
   l_api_updating := pay_cty_shd.api_updating
      (
       p_emp_city_tax_rule_id => p_emp_city_tax_rule_id,
       p_effective_date         => p_effective_date,
       p_object_version_number  => p_object_version_number
      );
   if (not l_api_updating) then
      open csr_business_grp;
      fetch csr_business_grp into l_business_group_id;
      if csr_business_grp%NOTFOUND then
         close csr_business_grp;
         hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
         hr_utility.raise_error;
      else
         --
         close csr_business_grp;
         --
         if nvl(p_business_group_id, hr_api.g_number) <> l_business_group_id
         then
            hr_utility.set_message(801, 'PAY_72737_CTY_BG_MATCH_ASG');
            hr_utility.raise_error;
         else
            open csr_defaulting;
            fetch csr_defaulting into l_tmp;
            if csr_defaulting%NOTFOUND then
               close csr_defaulting;
               hr_utility.set_message(801, 'PAY_72731_CTY_NO_FED_RULE');
               hr_utility.raise_error;
            end if;
            close csr_defaulting;
         end if;
      end if;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 65);
end chk_assignment_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_state_code >----------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Determines if the current state code has:
--        1. an entry in the pay_us_states table.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_state_code
--
--  Post Success:
--    Process continues if :
--    The state_code is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the state_code is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
procedure chk_state_code
   (p_state_code       in   pay_us_emp_city_tax_rules_f.state_code%TYPE
   )
   is
--
   l_proc                     varchar2(72) := g_package||'chk_state_code';
   l_state_code               pay_us_emp_city_tax_rules_f.state_code%TYPE;
   --
   --
   cursor csr_valid_state_code is
      select state_code
      from pay_us_states
      where state_code = p_state_code;
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- Check state_code is not null.
   --
   --
   if (p_state_code IS NOT NULL) then
      hr_utility.set_location(l_proc, 10);
      --
      -- Check state code is valid.
      --
      open csr_valid_state_code;
      fetch csr_valid_state_code into l_state_code;
      if csr_valid_state_code%notfound then
         close csr_valid_state_code;
         pay_cty_shd.constraint_error
            ('PAY_US_EMP_CITY_TAX_RULES_FK1');
      end if;
      close csr_valid_state_code;
   else
      hr_utility.set_message(801,'PAY_72752_CTY_STA_NOT_NULL');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 20);
end chk_state_code;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_county_code >------------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Determines if the current county_code has:
--   -    1. an entry in the pay_us_emp_counties table, where the state_code
--           matches the tax record state_code.
--
--
--  Pre_conditions:
--    A valid state_code
--
--  In Arguments:
--    p_state_code
--    p_county_code
--
--  Post Success:
--    Process continues if :
--    The county_code is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the county_code is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
procedure chk_county_code
   (p_county_code       in   pay_us_emp_city_tax_rules_f.county_code%TYPE
   ,p_state_code        in   pay_us_emp_city_tax_rules_f.state_code%TYPE
   )
   is
--
   l_proc                     varchar2(72) := g_package||'chk_county_code';
   l_county_code              pay_us_emp_city_tax_rules_f.county_code%TYPE;
   l_state_code               pay_us_emp_city_tax_rules_f.state_code%TYPE;
   --
   --
   cursor csr_valid_county_code is
      select county_code
      from pay_us_counties
      where state_code = p_state_code
        and county_code = p_county_code;
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- Check to see if mandatory parameters have been set.
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'state_code'
      ,p_argument_value   => p_state_code
      );
     --
     if (p_county_code IS NOT NULL) then
         hr_utility.set_location(l_proc, 10);
         --
         -- Check for valid county code.
         --
         open csr_valid_county_code;
         fetch csr_valid_county_code into l_county_code;
         if csr_valid_county_code%notfound then
            close csr_valid_county_code;
            hr_utility.set_message(801,'HR_51279_ADD_INV_CTY_CO_ST_CMB');
            hr_utility.raise_error;
         end if;
         close csr_valid_county_code;
         hr_utility.set_location(l_proc, 20);
      else
         hr_utility.set_message(801,'PAY_72740_CTY_CNT_NOT_NULL');
         hr_utility.raise_error;
      end if;
   hr_utility.set_location(' Leaving: '||l_proc, 25);
end chk_county_code;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_city_code >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   - Determines if the current city code has:
--   -    1. an entry in the pay_us_emp_city_geocodes table.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_state_code
--    p_county_code
--    p_city_code
--
--  Post Success:
--    Process continues if :
--    The city_code is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the city_code is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
procedure chk_city_code
   (p_state_code      in   pay_us_emp_city_tax_rules_f.state_code%TYPE
   ,p_county_code     in   pay_us_emp_city_tax_rules_f.county_code%TYPE
   ,p_city_code       in   pay_us_emp_city_tax_rules_f.city_code%TYPE
   )
   is
--
   l_proc                    varchar2(72) := g_package||'chk_city_code';
   l_city_code               pay_us_emp_city_tax_rules_f.city_code%TYPE;
   --
   --
   cursor csr_valid_city_code is
      select city_code
      from pay_us_city_geocodes
      where state_code = p_state_code
        and county_code = p_county_code
        and city_code = p_city_code;
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- Check city_code is not null.
   --
   if (p_city_code IS NOT NULL) then
      hr_utility.set_location(l_proc, 10);
      --
      -- Check city code is valid.
      --
      open csr_valid_city_code;
      fetch csr_valid_city_code into l_city_code;
      if csr_valid_city_code%notfound then
         close csr_valid_city_code;
         pay_cty_shd.constraint_error
            (p_constraint_name => 'PAY_US_EMP_CITY_TAX_RULES_FK3');
      end if;
      close csr_valid_city_code;
   else
      hr_utility.set_message(801,'PAY_72739_CTY_CTY_NOT_NULL');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_city_code;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_jurisdiction_code >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   - Determines if the current jurisdiction_code has:
--   -    1. an entry in the pay_state_rules table, where the state_code
--           matches the tax record state_code.
--
--
--  Pre_conditions:
--    A valid state_code.
--    A valid county_code.
--    A valid city_code.
--
--  In Arguments:
--    p_jurisdiction_code
--    p_state_code
--    p_county_code
--    p_city_code
--
--  Post Success:
--    Process continues if :
--    The jurisdiction_code is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the jurisdiction_code is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
procedure chk_jurisdiction_code
   (p_jurisdiction_code in   pay_us_emp_city_tax_rules_f.jurisdiction_code%TYPE
   ,p_city_code         in   pay_us_emp_city_tax_rules_f.city_code%TYPE
   ,p_county_code       in   pay_us_emp_city_tax_rules_f.county_code%TYPE
   ,p_state_code        in   pay_us_emp_city_tax_rules_f.state_code%TYPE)
   is
--
   l_proc                  varchar2(72) := g_package||'chk_jurisdiction_code';
   l_jurisdiction          number;
   --
   --
   cursor csr_valid_jurisdiction_code is
     select count(*)
     from pay_us_city_names
     where state_code = p_state_code
       and county_code = p_county_code
       and city_code = p_city_code;
--
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   if p_jurisdiction_code is null then
     hr_utility.set_message(801,'PAY_72744_CTY_JD_NOT_NULL');
     hr_utility.raise_error;
   end if;
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'state_code'
      ,p_argument_value   => p_state_code
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'county_code'
      ,p_argument_value   => p_county_code
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'city_code'
      ,p_argument_value   => p_city_code
      );
      --
      hr_utility.set_location(l_proc, 10);
      --
      --
      -- Check for valid jurisdiction code
      --
      open csr_valid_jurisdiction_code;
      fetch csr_valid_jurisdiction_code into l_jurisdiction;
      if l_jurisdiction = 0 then
         close csr_valid_jurisdiction_code;
         hr_utility.set_message(801,'PAY_8003_1099R_JU_CODE');
         hr_utility.raise_error;
      end if;
      close csr_valid_jurisdiction_code;
      hr_utility.set_location(l_proc, 20);
end chk_jurisdiction_code;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_additional_wa_rate >----------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Determines if the current additional_wa_rate has:
--   -    1. a value between 0 and 100.
--
--  Pre_conditions: none.
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_additional_wa_rate
--
--  Post Success:
--    Process continues if :
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the additional_wa_rate is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_additional_wa_rate
   (p_emp_city_tax_rule_id  in
      pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE
   ,p_additional_wa_rate    in
      pay_us_emp_city_tax_rules_f.additional_wa_rate%TYPE
   )
   is
--
   l_proc                 varchar2(72) := g_package||'chk_additional_wa_rate';
   l_additional_wa_rate   pay_us_emp_city_tax_rules_f.additional_wa_rate%TYPE;
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- If value is being inserted or updated ...
   --
   if (p_emp_city_tax_rule_id is not null
       and nvl(p_additional_wa_rate,hr_api.g_number) <>
           pay_cty_shd.g_old_rec.additional_wa_rate)
       or (p_emp_city_tax_rule_id is null) then
      --
      -- Check that additional_wa_rate is not null.
      --
      if p_additional_wa_rate is null then
        hr_utility.set_message(801,'PAY_72735_CTY_ADDL_WA_NOT_NULL');
        hr_utility.raise_error;
      else
         --
         -- Check that additional_wa_rate is in a valid range.
         --
         if p_additional_wa_rate < 0 or p_additional_wa_rate > 100 then
            --
            hr_utility.set_message(801,'PAY_72734_CTY_ADDL_WA_IN_RANGE');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_additional_wa_rate;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_filing_status_code >-----------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Determines if the current filing_status_code has:
--   -    1. an entry (lookup_code) in HR_LOOKUPS, where
--           lookup_type = 'US_LIT_FILING_STATUS'
--
--
--  Pre_conditions:
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_filing_status_code
--    p_state_code
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Process continues if :
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the filing_status_code is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_filing_status_code
   (p_emp_city_tax_rule_id  in
      pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE,
    p_filing_status_code    in
      pay_us_emp_city_tax_rules_f.filing_status_code%TYPE,
    p_state_code            in   pay_us_emp_city_tax_rules_f.state_code%TYPE,
    p_effective_date        in   date,
    p_validation_start_date in   date,
    p_validation_end_date   in   date
   )
   is
--
   l_proc                    varchar2(72) := g_package||
                                             'chk_filing_status_code';
--
begin
   --
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'effective_date'
      ,p_argument_value   => p_effective_date
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'state_code'
      ,p_argument_value   => p_state_code
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'validation_start_date'
      ,p_argument_value   => p_validation_start_date
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'validation_end_date'
      ,p_argument_value   => p_validation_end_date
      );
   --
   -- If value is being inserted or updated ...
   --
   if (p_emp_city_tax_rule_id is not null
       and nvl(p_filing_status_code,hr_api.g_varchar2) <>
           pay_cty_shd.g_old_rec.filing_status_code)
       or (p_emp_city_tax_rule_id is null) then
      --
      -- Check that filing_status_code is not null.
      --
      if p_filing_status_code is null then
        hr_utility.set_message(801,'PAY_72742_CTY_FIL_STA_NOT_NULL');
        hr_utility.raise_error;
      else
         --
         -- Check that filing_status_code is in a valid range.
         --
         if hr_api.not_exists_in_dt_hr_lookups
                (p_effective_date         => p_effective_date
                ,p_validation_start_date  => p_validation_start_date
                ,p_validation_end_date    => p_validation_end_date
                ,p_lookup_type            => 'US_LIT_FILING_STATUS'
                ,p_lookup_code            => p_filing_status_code
                ) then
            --
            hr_utility.set_message(801,'PAY_72741_CTY_FIL_STAT_INVALID');
            hr_utility.raise_error;
         end if;
      end if;
   end if;

   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_filing_status_code;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_lit_additional_tax >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   - Determines if the current lit_additional_tax has:
--   -    1. a valid value >= 0.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_lit_additional_tax
--
--  Post Success:
--    Process continues if :
--    The lit_additional_tax is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the lit_additional_tax is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
procedure chk_lit_additional_tax
   (p_emp_city_tax_rule_id  in
      pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE
   ,p_lit_additional_tax    in
      pay_us_emp_city_tax_rules_f.lit_additional_tax%TYPE
   )
   is
--
   l_proc                 varchar2(72) := g_package||'chk_lit_additional_tax';
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- If value is being inserted or updated ...
   --
   if (p_emp_city_tax_rule_id is not null
       and nvl(p_lit_additional_tax,hr_api.g_number) <>
           pay_cty_shd.g_old_rec.lit_additional_tax)
       or (p_emp_city_tax_rule_id is null) then
      --
      -- Check that lit_additional_tax is not null.
      --
      if p_lit_additional_tax is null then
        hr_utility.set_message(801,'PAY_72733_CTY_ADL_TAX_NOT_NULL');
        hr_utility.raise_error;
      else
         --
         -- Check that lit_additional_tax is in a valid range.
         --
         if p_lit_additional_tax < 0  then
            hr_utility.set_message(801,'PAY_72732_CTY_ADL_TAX_POSITIVE');
            hr_utility.raise_error;
         end if;
      end if;
   end if;

   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_lit_additional_tax;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_lit_override_amount >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   - Determines if the current lit_override_amount has:
--   -    1. a valid value >= 0.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_lit_override_amount
--
--  Post Success:
--    Process continues if :
--    The lit_override_amount is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the lit_override_amount is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_lit_override_amount
   (p_emp_city_tax_rule_id  in
      pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE
   ,p_lit_override_amount   in
      pay_us_emp_city_tax_rules_f.lit_override_amount%TYPE
   )
   is
--
   l_proc                    varchar2(72) := g_package||
                                             'chk_lit_override_amount';
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- If value is being inserted or updated ...
   --
   if (p_emp_city_tax_rule_id is not null
       and nvl(p_lit_override_amount,hr_api.g_number) <>
           pay_cty_shd.g_old_rec.lit_override_amount)
       or (p_emp_city_tax_rule_id is null) then
      --
      -- Check that lit_override_amount is not null.
      --
      if p_lit_override_amount is null then
        hr_utility.set_message(801,'PAY_72747_CTY_OVRD_AMT_NOT_NUL');
        hr_utility.raise_error;
      else
         --
         -- Check that lit_override_amount is in a valid range.
         --
         if p_lit_override_amount < 0  then
            hr_utility.set_message(801,'PAY_72746_CTY_OVRD_AMT_POSTVE');
            hr_utility.raise_error;
         end if;
      end if;
   end if;

   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_lit_override_amount;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_lit_override_rate >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   - Determines if the current lit_override_rate has:
--   -    1. a valid value between 0 and 100.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_lit_override_rate
--
--  Post Success:
--    Process continues if :
--    The lit_override_rate is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the lit_override_rate is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_lit_override_rate
   (p_emp_city_tax_rule_id  in
      pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE
   ,p_lit_override_rate     in
      pay_us_emp_city_tax_rules_f.lit_override_rate%TYPE
   )
   is
--
   l_proc                    varchar2(72) := g_package||
                                             'chk_lit_override_rate';
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- If value is being inserted or updated ...
   --
   if (p_emp_city_tax_rule_id is not null
       and nvl(p_lit_override_rate,hr_api.g_number) <>
           pay_cty_shd.g_old_rec.lit_override_rate)
       or (p_emp_city_tax_rule_id is null) then
      --
      -- Check that lit_override_rate is not null.
      --
      if p_lit_override_rate is null then
        hr_utility.set_message(801,'PAY_72749_CTY_OVRD_RT_NOT_NULL');
        hr_utility.raise_error;
      else
         --
         -- Check that lit_override_rate is in a valid range.
         --
         if p_lit_override_rate < 0  or p_lit_override_rate > 100 then
            hr_utility.set_message(801,'PAY_72748_CTY_OVRD_RT_IN_RANG');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_lit_override_rate;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_withholding_allowances >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   - Determines if the current withholding_allowances has:
--   -    1. a valid value >= 0.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_withholding_allowances
--
--  Post Success:
--    Process continues if :
--    The withholding_allowances is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the withholding_allowances is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_withholding_allowances
   (p_emp_city_tax_rule_id   in
       pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE
   ,p_withholding_allowances in
       pay_us_emp_city_tax_rules_f.withholding_allowances%TYPE
   )
   is
--
   l_proc                    varchar2(72) := g_package||
                                             'chk_withholding_allowances';
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   -- If value is being inserted or updated ...
   --
   if (p_emp_city_tax_rule_id is not null
       and nvl(p_withholding_allowances,hr_api.g_number) <>
       pay_cty_shd.g_old_rec.withholding_allowances)
       or (p_emp_city_tax_rule_id is null) then
      --
      -- Check that withholding_allowances is not null.
      --
      if p_withholding_allowances is null then
        hr_utility.set_message(801,'PAY_72754_CTY_WA_NOT_NULL');
        hr_utility.raise_error;
      else
         --
         -- Check that withholding_allowances is in a valid range.
         --
         if p_withholding_allowances < 0  then
            hr_utility.set_message(801,'PAY_72753_CTY_WA_POSITIVE');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_withholding_allowances;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_school_district_code >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   -This routine performs the following validation on the school district code
--   -   a. the school district code exists in PAY_US_SCHOOL_DSTS for the
--          current state, county and city.
--   -   b. the current county does not contain any specified school districts
--          for the given assignment, within the specified time period
--   -   c. the current city does not contain any school districts for the
--          given assignment, within the specified time period, except for the
--          one specified in this routine
--
--  Pre_conditions:
--
--  In Arguments:
--    p_emp_city_tax_rule_id
--    p_assignment_id
--    p_school_district_code
--    p_state_code
--    p_county_code
--    p_city_code
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    The school district code is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated
--    if the school district code is invalid.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_school_district_code
   (p_emp_city_tax_rule_id       in
      pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE,
    p_assignment_id              in
      pay_us_emp_city_tax_rules_f.assignment_id%TYPE,
    p_school_district_code       in
      pay_us_emp_city_tax_rules_f.school_district_code%TYPE,
    p_state_code                 in
      pay_us_emp_city_tax_rules_f.state_code%TYPE,
    p_county_code                in
      pay_us_emp_city_tax_rules_f.county_code%TYPE,
    p_city_code                  in
      pay_us_emp_city_tax_rules_f.city_code%TYPE,
    p_effective_date             in   date,
    p_validation_start_date      in   date,
    p_validation_end_date        in   date,
    p_object_version_number      in
      pay_us_emp_city_tax_rules_f.object_version_number%TYPE
   )
   is
--
   l_proc               varchar2(72) := g_package||'chk_school_district_code';
   l_school_district_code
      pay_us_emp_city_tax_rules_f.school_district_code%TYPE;
   l_cty_schl_dist_code
      pay_us_emp_city_tax_rules_f.school_district_code%TYPE;
   l_cnt_schl_dist_code
      pay_us_emp_county_tax_rules_f.school_district_code%TYPE;
   l_api_updating       boolean;
--
   cursor csr_school_district_code (p_sta_code     varchar2,
                                    p_cnt_code     varchar2,
                                    p_cty_code     varchar2,
                                    p_sch_dst_code varchar2) is
      select school_dst_code from pay_us_city_school_dsts
      where state_code      = p_sta_code
        and county_code     = p_cnt_code
        and city_code       = p_cty_code
        and school_dst_code = p_sch_dst_code;
   --
   cursor csr_cty_school_district_code (p_val_start_date date,
                                        p_val_end_date   date,
                                        p_asg_id         number,
                                        p_sta_code       varchar2,
                                        p_cnt_code       varchar2,
                                        p_cty_code       varchar2,
                                        p_tax_rule_id    number) is
      select school_district_code
      from pay_us_emp_city_tax_rules_f ctr
      where ctr.assignment_id         = p_asg_id
        and ctr.effective_end_date   >= p_validation_start_date
        and ctr.effective_start_date <= p_validation_end_date
        and ctr.school_district_code is not null
        and ctr.state_code            = p_sta_code
        and ctr.county_code           = p_cnt_code
        and ctr.city_code             = p_cty_code
        and ctr.emp_city_tax_rule_id
                  <> NVL(p_tax_rule_id, ctr.emp_city_tax_rule_id);
   --
   cursor csr_cnt_school_district_code (p_val_start_date date,
                                        p_val_end_date   date,
                                        p_asg_id         number,
                                        p_sta_code       varchar2,
                                        p_cnt_code       varchar2) is
      select school_district_code
      from pay_us_emp_county_tax_rules_f ctr
      where ctr.assignment_id         = p_asg_id
        and ctr.effective_end_date   >= p_validation_start_date
        and ctr.effective_start_date <= p_validation_end_date
        and ctr.school_district_code is not null
        and ctr.state_code            = p_sta_code
        and ctr.county_code           = p_cnt_code;
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'state_code'
      ,p_argument_value   => p_state_code
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'county_code'
      ,p_argument_value   => p_county_code
      );
   --
   hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'city_code'
      ,p_argument_value   => p_city_code
      );
   --
   l_api_updating := pay_cty_shd.api_updating
     (
      p_effective_date              => p_effective_date,
      p_emp_city_tax_rule_id        => p_emp_city_tax_rule_id,
      p_object_version_number       => p_object_version_number
     );
   --
   -- If the value is being inserted or updated...
   --
   if (l_api_updating
      and nvl(p_school_district_code,hr_api.g_number) <>
          pay_cty_shd.g_old_rec.school_district_code)
      or (not l_api_updating)  then
      --
      -- Check school_district_code.
      --
      if p_school_district_code is not null then
         hr_utility.set_location(l_proc, 10);
         --
         open csr_school_district_code (p_state_code,
                                        p_county_code,
                                        p_city_code,
                                        p_school_district_code);
         fetch csr_school_district_code into l_school_district_code;
         if csr_school_district_code%found then
            close csr_school_district_code;
            open csr_cnt_school_district_code (p_validation_start_date,
                                               p_validation_end_date,
                                               p_assignment_id,
                                               p_state_code,
                                               p_county_code);
            fetch csr_cnt_school_district_code into l_cnt_schl_dist_code;
            open csr_cty_school_district_code (p_validation_start_date,
                                               p_validation_end_date,
                                               p_assignment_id,
                                               p_state_code,
                                               p_county_code,
                                               p_city_code,
                                               p_emp_city_tax_rule_id);
            fetch csr_cty_school_district_code into l_cty_schl_dist_code;
            if (csr_cty_school_district_code%found)
               or (csr_cnt_school_district_code%found) then
               close csr_cty_school_district_code;
               close csr_cnt_school_district_code;
               --
               hr_utility.set_message(801,'PAY_52240_TAX_SD_CHK');
               hr_utility.raise_error;
               --
            end if;
            close csr_cty_school_district_code;
            close csr_cnt_school_district_code;
         else
            --
            close csr_school_district_code;
            hr_utility.set_message(801,'PAY_72750_CTY_SCHL_DST_INVALID');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 15);
end chk_school_district_code;
--
--  ---------------------------------------------------------------------------
--  |-------------------------------< chk_delete >----------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   Tax rules may be deleted from pay_us_emp_city_tax_rules_f when the
--    following conditions are met:
--      - no payroll has been run for this city
--      - the city is not assigned to a work location
--      - the city is not assigned to a primary resident address
--
--  Pre_conditions: None.
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--    p_city_code
--    p_county_code
--    p_state_code
--    p_delete_mode
--    p_delete_routine
--
--  Post Success:
--    Processing continues.
--
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status
--    Internal Row Handler Use Only.
--
procedure chk_delete
   (p_effective_date    in   date,
    p_assignment_id     in   per_assignments_f.assignment_id%TYPE,
    p_city_code         in   pay_us_emp_city_tax_rules_f.city_code%TYPE,
    p_county_code       in   pay_us_emp_city_tax_rules_f.county_code%TYPE,
    p_state_code        in   pay_us_emp_city_tax_rules_f.state_code%TYPE,
    p_delete_mode       in   varchar2,
    p_delete_routine    in   varchar2
   )
   is
--
   l_proc                    varchar2(72) := g_package||'chk_delete';
   l_payroll_exists          number;
   l_city_work_exists        number;
   l_city_residence          number;
   l_effective_date          date;
   --
   cursor chk_city_payroll(p_csr_tmp_date in date)
      is
      select prr.run_result_id from
             pay_run_results prr,
             pay_assignment_actions paa,
             per_assignments_f paf   -- Bug 3419786
      where paf.assignment_id = p_assignment_id   -- Bug 3419786
        and paf.assignment_id = paa.assignment_id
        and prr.assignment_action_id = paa.assignment_action_id
        and prr.jurisdiction_code =
             p_state_code||'-'||p_county_code||'-'||p_city_code
        and  exists (select null
                     from pay_payroll_actions ppa,
                          pay_payrolls_f ppf  -- Bug 3419786
                     where ppa.payroll_action_id = paa.payroll_action_id
                     and ppa.action_type in ('Q','R')
                     and ppa.date_earned > p_csr_tmp_date
                     and ppa.payroll_id = ppf.payroll_id  -- Bug 3419786
                     and ppa.effective_date between ppf.effective_start_date
                         and ppf.effective_end_date
                     and ppf.payroll_id >= 0
                     and ppf.payroll_id = paf.payroll_id
                    );
   --
   -- Cursor to check if the city has been assigned as the state of a work
   -- location of the assignment.
   --
   cursor chk_city_work(p_csr_tmp_date in date)
      is
       select hrl.location_id
       from   per_assignments_f   paf,
              hr_locations        hrl
       where  paf.assignment_id   = p_assignment_id
       and    hrl.location_id     = paf.location_id
       and    paf.effective_end_date > p_csr_tmp_date
       and    exists (select null
                      from pay_us_states pus,
                           pay_us_counties puc,
                           pay_us_city_names pucn
                      where pus.state_abbrev = hrl.region_2
                        and pus.state_code   = p_state_code
                        and puc.state_code   = pus.state_code
                        and puc.county_name  = hrl.region_1
                        and puc.county_code  = p_county_code
                        and pucn.state_code   = pus.state_code
                        and pucn.county_code  = puc.county_code
                        and pucn.city_name    = hrl.town_or_city
                        and pucn.city_code    = p_city_code);
   --
   --
   -- Cursor to check if the city has been assigned as the city of a
   -- resident address of the assignment.
   --
   --
   cursor chk_city_residence(p_csr_tmp_date in date)
   is
      select 1
       from   per_assignments_f   paf,
              per_addresses       pa
       where  paf.assignment_id   = p_assignment_id
       and    pa.person_id        = paf.person_id
       and    pa.primary_flag = 'Y'
       and    nvl(pa.date_to, hr_api.g_eot) > p_csr_tmp_date
       and    exists (select null
                      from pay_us_states pus,
                           pay_us_counties puco,
                           pay_us_city_names puci
                      where pus.state_abbrev = pa.region_2
                        and pus.state_code   = p_state_code
                        and puco.state_code  = pus.state_code
                        and puco.county_name = pa.region_1
                        and puco.county_code = p_county_code
                        and puci.state_code  = pus.state_code
                        and puci.county_code = puco.county_code
                        and puci.city_name   = pa.town_or_city
                        and puci.city_code   = p_city_code);
--
--
--
begin
   hr_utility.set_location('Entering: '|| l_proc, 5);
   --
   if p_delete_mode in ('ZAP','DELETE') then
      hr_utility.set_location(l_proc, 10);
      if p_delete_mode = hr_api.g_zap then
         l_effective_date := trunc(hr_api.g_sot);
      else
         l_effective_date := trunc(p_effective_date);
      end if;
      if p_delete_mode = 'DELETE' and p_delete_routine = 'ASSIGNMENT' then
         open chk_city_payroll(l_effective_date);
         fetch chk_city_payroll into l_payroll_exists;
         if chk_city_payroll%found then
            close chk_city_payroll;
            hr_utility.set_message(801,'PAY_52235_TAX_RULE_DELETE');
            hr_utility.raise_error;
         end if;
         close chk_city_payroll;
      end if;
   end if;
   --
   if p_delete_mode = 'ZAP' and p_delete_routine <> 'ASSIGNMENT' then
      hr_utility.set_location(l_proc, 15);
      open chk_city_work(l_effective_date);
      fetch chk_city_work into l_city_work_exists;
      if chk_city_work%found then
         close chk_city_work;
         hr_utility.set_message(801,'PAY_52295_TAX_CIDEL_LOC');
         hr_utility.raise_error;
      end if;
      close chk_city_work;
      --
      hr_utility.set_location(l_proc, 20);
      open chk_city_residence(l_effective_date);
      fetch chk_city_residence into l_city_residence;
      if chk_city_residence%found then
         close chk_city_residence;
         hr_utility.set_message(801,'PAY_52298_TAX_CIDEL_RES');
         hr_utility.raise_error;
      end if;
      close chk_city_residence;
   end if;
   --
   if p_delete_mode <> 'ZAP' and p_delete_routine <> 'ASSIGNMENT' then
      hr_utility.set_message(801,'PAY_52971_TAX_ZAP_ONLY');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location(' Leaving: '||l_proc, 45);
   --
end chk_delete;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >-----------------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:  This procedure checks that columns where updates are not
--                allowed, have not been changed from their original value.
--
--  Pre_conditions: None
--
--  In Arguments:
--    p_rec
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status
--    Internal Row Handler Use Only.
--
--
Procedure chk_non_updateable_args
   (p_rec            in pay_cty_shd.g_rec_type,
    p_effective_date in date
   ) is
--
   l_proc      varchar2(72) := g_package||'chk_non_updateable_args';
   l_error     exception;
   l_argument  varchar2(30);
--
Begin
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   --
   if not pay_cty_shd.api_updating
      (p_emp_city_tax_rule_id  => p_rec.emp_city_tax_rule_id,
       p_object_version_number => p_rec.object_version_number,
       p_effective_date        => p_effective_date
      ) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP',20);
   end if;
   hr_utility.set_location(l_proc, 30);
   --
   if (nvl(p_rec.business_group_id, hr_api.g_number) <>
       pay_cty_shd.g_old_rec.business_group_id) then
      l_argument := 'business_group_id';
      raise l_error;
   end if;
   hr_utility.set_location(l_proc, 40);
   --
   if (nvl(p_rec.assignment_id, hr_api.g_number) <>
       pay_cty_shd.g_old_rec.assignment_id) then
      l_argument := 'assignment_id';
      raise l_error;
   end if;
   hr_utility.set_location(l_proc, 50);
   --
   if (nvl(p_rec.state_code, hr_api.g_varchar2) <>
       pay_cty_shd.g_old_rec.state_code) then
      l_argument := 'state_code';
      raise l_error;
   end if;
   hr_utility.set_location(l_proc, 60);
   --
   if (nvl(p_rec.county_code, hr_api.g_varchar2) <>
       pay_cty_shd.g_old_rec.county_code) then
      l_argument := 'county_code';
      raise l_error;
   end if;
   hr_utility.set_location(l_proc, 70);
   --
   if (nvl(p_rec.city_code, hr_api.g_varchar2) <>
       pay_cty_shd.g_old_rec.city_code) then
      l_argument := 'city_code';
      raise l_error;
   end if;
   hr_utility.set_location(l_proc, 80);
   --
   if (nvl(p_rec.jurisdiction_code, hr_api.g_varchar2) <>
       pay_cty_shd.g_old_rec.jurisdiction_code) then
      l_argument := 'jurisdiction_code';
      raise l_error;
   end if;
   hr_utility.set_location('Leaving: '||l_proc, 90);
   --
   exception
      when l_error then
         hr_api.argument_changed_error
            (p_api_name => l_proc,
             p_argument => l_argument
            );
      when others then
         raise;
end chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (
           p_datetrack_mode                 in varchar2,
             p_validation_start_date           in date,
           p_validation_end_date           in date) Is
--
  l_proc          varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name          all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_emp_city_tax_rule_id      in number,
             p_datetrack_mode            in varchar2,
           p_validation_start_date       in date,
           p_validation_end_date         in date) Is
--
  l_proc      varchar2(72)  := g_package||'dt_delete_validate';
  l_rows_exist      Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'emp_city_tax_rule_id',
       p_argument_value => p_emp_city_tax_rule_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
      (p_rec                   in pay_cty_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date) is
--
  l_proc      varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_assignment_id
  (
   p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_assignment_id          => p_rec.assignment_id,
   p_business_group_id      => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_state_code
  (p_state_code             => p_rec.state_code
  );
  --
  chk_county_code
  (p_county_code            => p_rec.county_code,
   p_state_code             => p_rec.state_code
  );
  --
  chk_city_code
  (p_city_code              => p_rec.city_code,
   p_county_code            => p_rec.county_code,
   p_state_code             => p_rec.state_code
  );
  --
  chk_jurisdiction_code
  (p_jurisdiction_code      => p_rec.jurisdiction_code,
   p_city_code              => p_rec.city_code,
   p_county_code            => p_rec.county_code,
   p_state_code             => p_rec.state_code
  );
  --
  chk_additional_wa_rate
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_additional_wa_rate     => p_rec.additional_wa_rate
  );
  --
  chk_filing_status_code
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_filing_status_code     => p_rec.filing_status_code,
   p_state_code             => p_rec.state_code,
   p_effective_date         => p_effective_date,
   p_validation_start_date  => p_validation_start_date,
   p_validation_end_date    => p_validation_end_date
  );
  --
  chk_lit_additional_tax
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_lit_additional_tax     => p_rec.lit_additional_tax
  );
  --
  chk_lit_override_amount
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_lit_override_amount    => p_rec.lit_override_amount
  );
  --
  chk_lit_override_rate
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_lit_override_rate      => p_rec.lit_override_rate
  );
  --
  chk_withholding_allowances
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_withholding_allowances => p_rec.withholding_allowances
  );
  --
  chk_school_district_code
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_assignment_id          => p_rec.assignment_id,
   p_school_district_code   => p_rec.school_district_code,
   p_state_code             => p_rec.state_code,
   p_county_code            => p_rec.county_code,
   p_city_code              => p_rec.city_code,
   p_effective_date         => p_effective_date,
   p_validation_start_date  => p_validation_start_date,
   p_validation_end_date    => p_validation_end_date,
   p_object_version_number  => p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
      (p_rec                   in pay_cty_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date) is
--
  l_proc      varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
   (p_rec                  => p_rec,
    p_effective_date       => p_effective_date
   );
  --
  chk_additional_wa_rate
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_additional_wa_rate     => p_rec.additional_wa_rate
  );
  --
  chk_filing_status_code
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_filing_status_code     => p_rec.filing_status_code,
   p_state_code             => p_rec.state_code,
   p_effective_date         => p_effective_date,
   p_validation_start_date  => p_validation_start_date,
   p_validation_end_date    => p_validation_end_date
  );
  --
  chk_lit_additional_tax
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_lit_additional_tax     => p_rec.lit_additional_tax
  );
  --
  chk_lit_override_amount
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_lit_override_amount    => p_rec.lit_override_amount
  );
  --
  chk_lit_override_rate
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_lit_override_rate      => p_rec.lit_override_rate
  );
  --
  chk_withholding_allowances
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_withholding_allowances => p_rec.withholding_allowances
  );
  --
  chk_school_district_code
  (p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id,
   p_assignment_id          => p_rec.assignment_id,
   p_school_district_code   => p_rec.school_district_code,
   p_state_code             => p_rec.state_code,
   p_county_code            => p_rec.county_code,
   p_city_code              => p_rec.city_code,
   p_effective_date         => p_effective_date,
   p_validation_start_date  => p_validation_start_date,
   p_validation_end_date    => p_validation_end_date,
   p_object_version_number  => p_rec.object_version_number
  );
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date           => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
      (p_rec                   in pay_cty_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_delete_routine        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date) is
--
  l_proc      varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete
    (p_effective_date           => p_effective_date,
     p_assignment_id            => pay_cty_shd.g_old_rec.assignment_id,
     p_city_code                => pay_cty_shd.g_old_rec.city_code,
     p_county_code              => pay_cty_shd.g_old_rec.county_code,
     p_state_code               => pay_cty_shd.g_old_rec.state_code,
     p_delete_mode              => p_datetrack_mode,
     p_delete_routine           => p_delete_routine
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  dt_delete_validate
    (p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date    => p_validation_end_date,
     p_emp_city_tax_rule_id   => p_rec.emp_city_tax_rule_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_emp_city_tax_rule_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_us_emp_city_tax_rules_f b
    where b.emp_city_tax_rule_id      = p_emp_city_tax_rule_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'emp_city_tax_rule_id',
                             p_argument_value => p_emp_city_tax_rule_id);
  --
  if nvl(g_cty_tax_rule_id, hr_api.g_number) = p_emp_city_tax_rule_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function.  Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
    --
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 30);
    --
    -- Set the global variables to the values are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_cty_tax_rule_id  := p_emp_city_tax_rule_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
  --
end return_legislation_code;
end pay_cty_bus;

/
