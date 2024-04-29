--------------------------------------------------------
--  DDL for Package Body PAY_STA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STA_BUS" as
/* $Header: pystarhi.pkb 120.0.12000000.3 2007/05/23 00:34:32 ppanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sta_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_state_code >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id  PK
--   p_state_code             ID of FK column
--   p_effective_date         session date
--   p_object_version_number  object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_state_code
  (p_emp_state_tax_rule_id    in number
  ,p_state_code               in pay_us_emp_state_tax_rules_f.state_code%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_state_code';
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_us_states a
    where  a.state_code = p_state_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Since update is not allowed, only checking insert case
  --
  if (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_state_code is null then
      hr_utility.set_message(801, 'PAY_72824_STA_STA_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if state_code value exists in pay_us_states table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pay_us_states
        -- table.
        --
        pay_sta_shd.constraint_error('PAY_US_EMP_STATE_TAX_RULES_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_state_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_assignment_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the assignment_id with the following checks:
--    - the assignment_id exists in PER_ASSIGNMENTS_F
--    - the assignment's business group must match the business group of this
--      tax record.
--   The tax record's business_group_id is also validated by checking that it
--    matches an existing business_group_id in PER_ASSIGNMENTS_F.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id     PK
--   p_assignment_id           ID of FK column
--   p_business_group_id       business group id
--   p_effective_date          session date
--   p_object_version_number   object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_assignment_id
  (p_emp_state_tax_rule_id    in number
  ,p_assignment_id            in
                               pay_us_emp_state_tax_rules_f.assignment_id%TYPE
  ,p_business_group_id        in
                           pay_us_emp_state_tax_rules_f.business_group_id%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in number
  ) is
  --
  l_proc                    varchar2(72) := g_package||'chk_assignment_id';
  l_dummy                   varchar2(1);
  l_api_updating            boolean;
  l_business_group_id       per_assignments_f.business_group_id%TYPE;
  --
  cursor c1 is
    select business_group_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    p_effective_date between asg.effective_start_date
             and asg.effective_end_date;
  --
  cursor c2 is
    select null
    from   pay_us_emp_fed_tax_rules_f fed
    where  fed.assignment_id = p_assignment_id
    and    p_effective_date between fed.effective_start_date
             and fed.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  if p_assignment_id is null then
    hr_utility.set_message(801, 'PAY_72806_STA_ASG_NOT_NULL');
    hr_utility.raise_error;
  end if;
  --
  if p_business_group_id is null then
    hr_utility.set_message(801, 'PAY_72808_STA_BG_NOT_NULL');
    hr_utility.raise_error;
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  l_api_updating := pay_sta_shd.api_updating
     (p_emp_state_tax_rule_id     => p_emp_state_tax_rule_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  --  Since assignment_id cannot be updated, the case of
  --  l_api_updating = TRUE is not considered
  --
  if (not l_api_updating) then
    --
    open c1;
      --
      fetch c1 into l_business_group_id;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as assignment_id not found in per_assignments_f
        -- table.
        --
        hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
        hr_utility.raise_error;
        --
      else
        --
        close c1;
        --
        if p_business_group_id <> l_business_group_id then
          --
          hr_utility.set_message(801, 'PAY_72807_STA_BG_MATCH_ASG');
          hr_utility.raise_error;
          --
        else
          --
          open c2;
          fetch c2 into l_dummy;
          if c2%notfound then
            close c2;
            hr_utility.set_message(801, 'PAY_72801_STA_NO_FED_RULE');
            hr_utility.raise_error;
          end if;
          close c2;
          --
        end if;
        --
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_sit_optional_calc_ind >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_state_tax_rule_id   PK of record being inserted or updated.
--   sit_optional_calc_ind   Value of lookup code.
--   effective_date          effective date
--   object_version_number   Object version number of record being
--                           inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_sit_optional_calc_ind
  (p_emp_state_tax_rule_id    in number
  ,p_sit_optional_calc_ind    in
                       pay_us_emp_state_tax_rules_f.sit_optional_calc_ind%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in number
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sit_optional_calc_ind';
  l_api_updating boolean;
  lv_state_abbrev  pay_us_states.state_abbrev%type;
  --
  cursor csr_get_state_abbrev is
    select state_abbrev
      from pay_us_states pus,
           pay_us_emp_state_tax_rules_f str
     where pus.state_code = str.state_code
       and str.emp_state_tax_rule_id = p_emp_state_tax_rule_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  l_api_updating := pay_sta_shd.api_updating
    (p_emp_state_tax_rule_id       => p_emp_state_tax_rule_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  -- If the value is being inserted or updated...
  --
  if (l_api_updating
      and nvl(p_sit_optional_calc_ind,hr_api.g_varchar2)
      <> pay_sta_shd.g_old_rec.sit_optional_calc_ind
      or not l_api_updating)  then
    --
    -- Validate only if attribute is not null
    --
    if p_sit_optional_calc_ind is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      open  csr_get_state_abbrev;
      fetch csr_get_state_abbrev into lv_state_abbrev;
      if csr_get_state_abbrev%notfound then
        close csr_get_state_abbrev;
        --
        -- Raise error as FK does not relate to PK in pay_us_states
        -- table. Existence of state tax record was checked in a
        -- previous step.
        --

        pay_sta_shd.constraint_error('PAY_US_EMP_STATE_TAX_RULES_FK1');

      end If;
      close csr_get_state_abbrev;
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'US_SIT_OPT_CALC_' || lv_state_abbrev,
             p_lookup_code    => p_sit_optional_calc_ind,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_message(801,'PAY_72823_STA_SIT_OPT_INVALID');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_sit_optional_calc_ind;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_jurisdiction_code >----------------------- -|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the jurisdiction_code against PAY_STATE_RULES
--   where the state is the same as the state_code
--
-- Pre-Conditions
--   Valid state_code
--
-- In Parameters
--   p_emp_state_tax_rule_id     PK
--   p_jurisdiction_code
--   p_state_code
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_jurisdiction_code
  (p_emp_state_tax_rule_id    in number
  ,p_jurisdiction_code        in
                           pay_us_emp_state_tax_rules_f.jurisdiction_code%TYPE
  ,p_state_code               in pay_us_emp_state_tax_rules_f.state_code%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_jurisdiction_code';
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_us_states pus, pay_state_rules psr
    where  pus.state_code = p_state_code
    and    pus.state_abbrev = psr.state_code
    and    psr.jurisdiction_code = p_jurisdiction_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'state_code'
    ,p_argument_value => p_state_code
    );
  --
  -- Since update is not allowed, only checking insert case
  --
  if (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_jurisdiction_code is null then
      hr_utility.set_message(801, 'PAY_72811_STA_JD_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if jurisdiction_code value exists in pay_state_rules table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as code does not exist in pay_state_rules table.
        --
        hr_utility.set_message(801, 'PAY_8003_1099R_JU_CODE');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_jurisdiction_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_additional_wa_amount >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that additional_wa_amount >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_additional_wa_amount
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_additional_wa_amount
  (p_emp_state_tax_rule_id    in number
  ,p_additional_wa_amount     in
                        pay_us_emp_state_tax_rules_f.additional_wa_amount%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_additional_wa_amount';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_additional_wa_amount,hr_api.g_number) <>
          pay_sta_shd.g_old_rec.additional_wa_amount)
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_additional_wa_amount is null then
      hr_utility.set_message(801, 'PAY_72805_STA_ADDL_WA_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if additional_wa_amount value is in a valid range
    --
    if p_additional_wa_amount < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72804_STA_ADDL_WA_POSITIVE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_additional_wa_amount;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_filing_status_code >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the filing_status_code against hr_lookups.
--
-- Pre-Conditions
--   Valid state_code.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_state_code
--   p_filing_status_code
--   p_effective_date         session date
--   p_validation_start_date
--   p_validation_end_date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_filing_status_code
  (p_emp_state_tax_rule_id      in number
  ,p_state_code               in pay_us_emp_state_tax_rules_f.state_code%TYPE
  ,p_filing_status_code       in
                          pay_us_emp_state_tax_rules_f.filing_status_code%TYPE
  ,p_effective_date           in date
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
  --
  l_proc             varchar2(72) := g_package||'chk_filing_status_code';
  l_fs_lookup_type   pay_state_rules.fs_lookup_type%TYPE;
  l_filing_status_code  pay_us_emp_state_tax_rules_f.filing_status_code%TYPE;
  --
  cursor c1 is
    select psr.fs_lookup_type
    from   pay_us_states pus, pay_state_rules psr
    where  pus.state_code = p_state_code
    and    pus.state_abbrev = psr.state_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Following condition added to fix the Bug # 5968429
  --
  if length(p_filing_status_code) = 1
  then
     l_filing_status_code := lpad(p_filing_status_code,2,'0');
  else
     l_filing_status_code := p_filing_status_code;
  end if;

  --
  -- Check that the mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'state_code'
    ,p_argument_value => p_state_code
    );
  --
  -- Select the lookup type for this state.
  --
  open c1;
    fetch c1 into l_fs_lookup_type;
  close c1;
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_filing_status_code,hr_api.g_varchar2)
     <> pay_sta_shd.g_old_rec.filing_status_code)
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_filing_status_code is null then
      hr_utility.set_message(801, 'PAY_72810_STA_FIL_STAT_NOT_NUL');
      hr_utility.raise_error;
    end if;
    --
    -- check if filing_status_code value exists in hr_lookups table
    --
    if hr_api.not_exists_in_dt_hr_lookups
         (p_effective_date        => p_effective_date
         ,p_validation_start_date => p_validation_start_date
         ,p_validation_end_date   => p_validation_end_date
         ,p_lookup_type           => l_fs_lookup_type
         ,p_lookup_code           => substr(p_filing_status_code,2,1)
         ) then
       --
       -- raise error as filing_status_code does not exist in hr_lookups
       -- table.
       --
       hr_utility.set_message(801,'PAY_72809_STA_FIL_STAT_INVALID');
       hr_utility.raise_error;
       --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_filing_status_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_sit_additional_tax >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that sit_additional_tax >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_sit_additional_tax
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_sit_additional_tax
  (p_emp_state_tax_rule_id    in number
  ,p_sit_additional_tax       in
                          pay_us_emp_state_tax_rules_f.sit_additional_tax%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sit_additional_tax';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_sit_additional_tax,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.sit_additional_tax,hr_api.g_number))
  or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_sit_additional_tax is null then
      hr_utility.set_message(801, 'PAY_72803_STA_ADDL_TAX_NOT_NUL');
      hr_utility.raise_error;
    end if;
    --
    -- check if sit_additional_tax value is in a valid range
    --
    if p_sit_additional_tax < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72802_STA_ADD_TAX_POSITIVE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_sit_additional_tax;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_sit_override_amount >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that sit_override_amount >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_sit_override_amount
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_sit_override_amount
  (p_emp_state_tax_rule_id    in number
  ,p_sit_override_amount      in
                         pay_us_emp_state_tax_rules_f.sit_override_amount%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sit_override_amount';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_sit_override_amount,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.sit_override_amount,hr_api.g_number))
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_sit_override_amount is null then
      hr_utility.set_message(801, 'PAY_72814_STA_OVD_AMT_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if sit_override_amount value is in a valid range
    --
    if p_sit_override_amount < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72813_STA_OVD_AMT_POSITIVE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_sit_override_amount;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_sit_override_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that sit_override_rate is between 0 and 100
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_sit_override_rate
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_sit_override_rate
  (p_emp_state_tax_rule_id    in number
  ,p_sit_override_rate        in
                           pay_us_emp_state_tax_rules_f.sit_override_rate%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sit_override_rate';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_sit_override_rate,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.sit_override_rate,hr_api.g_number))
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_sit_override_rate is null then
      hr_utility.set_message(801, 'PAY_72816_STA_OVRD_RT_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if sit_override_rate value is in a valid range
    --
    if p_sit_override_rate < 0  or p_sit_override_rate > 100 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72815_STA_OVRD_RT_IN_RANGE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_sit_override_rate;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_remainder_percent >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that remainder_percent is between 0 and 100
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_remainder_percent
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_remainder_percent
  (p_emp_state_tax_rule_id    in number
  ,p_remainder_percent        in
                           pay_us_emp_state_tax_rules_f.remainder_percent%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_remainder_percent';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_remainder_percent,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.remainder_percent,hr_api.g_number))
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_remainder_percent is null then
      hr_utility.set_message(801, 'PAY_72818_STA_REM_PCT_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if remainder_percent value is in a valid range
    --
    if p_remainder_percent < 0  or p_remainder_percent > 100 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72817_STA_REM_PCT_IN_RANGE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_remainder_percent;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_secondary_wa >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that secondary_wa >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_secondary_wa
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_secondary_wa
  (p_emp_state_tax_rule_id    in number
  ,p_secondary_wa             in pay_us_emp_state_tax_rules_f.secondary_wa%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_secondary_wa';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_secondary_wa,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.secondary_wa,hr_api.g_number))
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_secondary_wa is null then
      hr_utility.set_message(801, 'PAY_72821_STA_SECND_WA_NOT_NUL');
      hr_utility.raise_error;
    end if;
    --
    -- check if secondary_wa value is in a valid range
    --
    if p_secondary_wa < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72820_STA_SECOND_WA_POSTVE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_secondary_wa;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_withholding_allowances >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that withholding_allowances >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_withholding_allowances
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_withholding_allowances
  (p_emp_state_tax_rule_id    in number
  ,p_withholding_allowances   in
                      pay_us_emp_state_tax_rules_f.withholding_allowances%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_withholding_allowances';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_state_tax_rule_id is not null
     and nvl(p_withholding_allowances,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.withholding_allowances,hr_api.g_number))
   or (p_emp_state_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_withholding_allowances is null then
      hr_utility.set_message(801, 'PAY_72830_STA_WA_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if withholding_allowances value is in a valid range
    --
    if p_withholding_allowances < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72829_STA_WA_POSITIVE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_withholding_allowances;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_sui_wage_base_override_amo >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that sui_wage_base_override_amount >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id    PK
--   p_sui_wage_base_override_amo
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_sui_wage_base_override_amo
  (p_emp_state_tax_rule_id      in number
  ,p_sui_wage_base_override_amo in
             pay_us_emp_state_tax_rules_f.sui_wage_base_override_amount%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sui_wage_base_override_amo';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if ((p_emp_state_tax_rule_id is not null
     and nvl(p_sui_wage_base_override_amo,hr_api.g_number) <>
     nvl(pay_sta_shd.g_old_rec.sui_wage_base_override_amount,hr_api.g_number))
    or
     (p_emp_state_tax_rule_id is null)) then
    --
    -- Validate only if attribute is not null
    --
    if p_sui_wage_base_override_amo is not null then
      --
      -- check if sui_wage_base_override_amo value is in a valid range
      --
      if p_sui_wage_base_override_amo < 0 then
        --
        -- raise error as given value is invalid
        --
        hr_utility.set_message(801,'PAY_72826_STA_SUI_OVD_POSITIVE');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_sui_wage_base_override_amo;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_supp_tax_override_rate >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that supp_tax_override_rate between 0 and 100
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id PK
--   p_supp_tax_override_rate
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_supp_tax_override_rate
  (p_emp_state_tax_rule_id    in number
  ,p_supp_tax_override_rate   in
                      pay_us_emp_state_tax_rules_f.supp_tax_override_rate%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_supp_tax_override_rate';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if ((p_emp_state_tax_rule_id is not null
     and nvl(p_supp_tax_override_rate,hr_api.g_number)
     <> nvl(pay_sta_shd.g_old_rec.supp_tax_override_rate,hr_api.g_number))
    or
     (p_emp_state_tax_rule_id is null)) then
    --
    -- Validate only if attribute is not null
    --
    if p_supp_tax_override_rate is not null then
      --
      -- check if supp_tax_override_rate value is in a valid range
      --
      if p_supp_tax_override_rate < 0 or p_supp_tax_override_rate > 100 then
        --
        -- raise error as given value is invalid
        --
        hr_utility.set_message(801,'PAY_72827_STA_SUPP_RT_IN_RANGE');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_supp_tax_override_rate;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that columns where updates are not allowed, have not
--   been changed from their original value.
--
-- Prerequisites:
--   None.
--
-- In Parameters
--   p_rec            record structure of row being updated
--   effective_date   Effective Date of session
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec            in pay_sta_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR schema
  --
  if not pay_sta_shd.api_updating
      (p_emp_state_tax_rule_id       => p_rec.emp_state_tax_rule_id
      ,p_object_version_number       => p_rec.object_version_number
      ,p_effective_date              => p_effective_date
      ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if (nvl(p_rec.assignment_id, hr_api.g_number) <>
       pay_sta_shd.g_old_rec.assignment_id) then
     l_argument := 'assignment_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 40);
  --
  if (nvl(p_rec.business_group_id, hr_api.g_number) <>
       pay_sta_shd.g_old_rec.business_group_id) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 50);
  --
  if nvl(p_rec.state_code, hr_api.g_varchar2) <>
      pay_sta_shd.g_old_rec.state_code then
     l_argument := 'state_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  if nvl(p_rec.jurisdiction_code, hr_api.g_varchar2) <>
     pay_sta_shd.g_old_rec.jurisdiction_code then
     l_argument := 'jurisdiction_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 70);
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 80);
end chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Tax rules may be deleted from pay_us_emp_state_tax_rules_f when the
--    following conditions are met:
--      - no payroll has been run for this state
--      - the state is not assigned to a work location
--      - the state is not assigned to a primary resident address
--
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_state_tax_rule_id         PK
--   p_assignment_id                 assignment id
--   p_effective_date                session date
--   p_object_version_number         object version number
--   p_validation_start_date         date
--   p_validation_end_date           date
--   p_delete_routine                varchar2   default null
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
procedure chk_delete
  (p_emp_state_tax_rule_id           in number
  ,p_assignment_id                   in number
  ,p_effective_date                  in date
  ,p_datetrack_mode                  in varchar2
  ,p_validation_start_date           in date
  ,p_validation_end_date             in date
  ,p_delete_routine                  in varchar2   default null
  ) is
  --
  l_effective_date   date;
  l_exists     varchar2(1);
  l_proc       varchar2(72) := g_package||'chk_delete';
  l_county_rule_exists        varchar2(1);
  --
  cursor csr_check_payroll(p_csr_tmp_date in date) is
      select null
      from   pay_run_results prr,
             pay_assignment_actions paa
      where substr(prr.jurisdiction_code,1,2)=pay_sta_shd.g_old_rec.state_code
        and  paa.assignment_action_id = prr.assignment_action_id
        and  paa.assignment_id = pay_sta_shd.g_old_rec.assignment_id
        and  exists (select null
                     from pay_payroll_actions ppa
                     where ppa.payroll_action_id = paa.payroll_action_id
                     and ppa.action_type in ('Q','R')
                     and ppa.date_earned > p_csr_tmp_date
                    );
  --
  cursor csr_check_work_loc(p_csr_tmp_date in date) is
      select null
      from   per_assignments_f asg,
             hr_locations      hrl
      where  asg.assignment_id = pay_sta_shd.g_old_rec.assignment_id
        and  hrl.location_id = asg.location_id
        and  asg.effective_end_date > p_csr_tmp_date
        and  exists (select null
                     from pay_us_states pus
                     where pus.state_abbrev = hrl.region_2
                     and pus.state_code = pay_sta_shd.g_old_rec.state_code);
  --
  cursor csr_check_residence_loc(p_csr_tmp_date in date) is
      select null
      from   per_assignments_f asg,
             per_addresses pad
      where  asg.assignment_id = pay_sta_shd.g_old_rec.assignment_id
        and  pad.person_id = asg.person_id
        and  pad.primary_flag = 'Y'
        and  nvl(pad.date_to, hr_api.g_eot) > p_csr_tmp_date
        and  exists (select null
                     from pay_us_states pus
                     where pus.state_abbrev = pad.region_2
                     and pus.state_code = pay_sta_shd.g_old_rec.state_code);
   --
   -- Cursor to check for existing county tax rules
   --
   cursor chk_county_tax_rules
   is
      select null
       from  pay_us_emp_county_tax_rules_f cnt
       where cnt.assignment_id      = p_assignment_id
       and   cnt.state_code         = pay_sta_shd.g_old_rec.state_code
       and   cnt.effective_end_date > p_effective_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Validate that this routine is called from Assignment code
  --
  if nvl(p_delete_routine,'X') = 'ASSIGNMENT' then
    --
    -- Perform validation for valid datetrack delete modes.
    --
    If p_datetrack_mode in(hr_api.g_zap, hr_api.g_delete) then
      --
      hr_utility.set_location(l_proc,20);
      --
      if p_datetrack_mode = hr_api.g_zap then
        l_effective_date := trunc(hr_api.g_sot);
      else
        l_effective_date := trunc(p_effective_date);
      end if;
      --
      -- Check if payroll has been run for this state
      --
      open csr_check_payroll(l_effective_date);
      fetch csr_check_payroll into l_exists;
      if csr_check_payroll%FOUND then
        hr_utility.set_location(l_proc,15);
        close csr_check_payroll;
        hr_utility.set_message(801, 'PAY_52235_TAX_RULE_DELETE');
        hr_utility.raise_error;
      end if;
      close csr_check_payroll;
    end if;
  else          -- p_delete_routine <> 'ASSIGNMENT'
    --
    hr_utility.set_location(l_proc,20);
    --
    if p_datetrack_mode = hr_api.g_zap then
      --
      l_effective_date := trunc(hr_api.g_sot);
      --
      -- Check if payroll has been run for this state
      --
      open csr_check_payroll(l_effective_date);
      fetch csr_check_payroll into l_exists;
      if csr_check_payroll%FOUND then
        hr_utility.set_location(l_proc,15);
        close csr_check_payroll;
        hr_utility.set_message(801, 'PAY_52235_TAX_RULE_DELETE');
        hr_utility.raise_error;
      end if;
      close csr_check_payroll;
      --
      -- Check if state has been assigned to a work location
      --
      open csr_check_work_loc(l_effective_date);
      fetch csr_check_work_loc into l_exists;
      if csr_check_work_loc%FOUND then
        hr_utility.set_location(l_proc,25);
        close csr_check_work_loc;
        hr_utility.set_message(801, 'PAY_52293_TAX_STDEL_LOC');
        hr_utility.raise_error;
      end if;
      close csr_check_work_loc;
      --
      hr_utility.set_location(l_proc,30);
      --
      -- Check if state has been assigned to a primary residence
      --
      open csr_check_residence_loc(l_effective_date);
      fetch csr_check_residence_loc into l_exists;
      if csr_check_residence_loc%FOUND then
        hr_utility.set_location(l_proc,35);
        close csr_check_residence_loc;
        hr_utility.set_message(801, 'PAY_52296_TAX_STDEL_RES');
        hr_utility.raise_error;
      end if;
      close csr_check_residence_loc;
      --
      hr_utility.set_location(l_proc,40);
      --
    else
      --
      -- Delete not allowed for this datetrack mode
      --
      hr_utility.set_message(801, 'PAY_52971_TAX_ZAP_ONLY');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  -- If any county tax rules exist for this assignment, raise an error.
  --
  open chk_county_tax_rules;
  fetch chk_county_tax_rules into l_county_rule_exists;
  if chk_county_tax_rules%found then
     close chk_county_tax_rules;
     hr_utility.set_message(801,'HR_7215_DT_CHILD_EXISTS');
     hr_utility.set_message_token('TABLE_NAME',
                                  'PAY_US_EMP_COUNTY_TAX_RULES_F');
     hr_utility.raise_error;
  end if;
  close chk_county_tax_rules;
  --
end chk_delete;
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
           p_datetrack_mode            in varchar2,
           p_validation_start_date     in date,
           p_validation_end_date       in date) Is
--
  l_proc     varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name     all_tables.table_name%TYPE;
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
            (p_emp_state_tax_rule_id    in number,
             p_datetrack_mode           in varchar2,
           p_validation_start_date      in date,
           p_validation_end_date        in date) Is
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
       p_argument       => 'emp_state_tax_rule_id',
       p_argument_value => p_emp_state_tax_rule_id);
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
      (p_rec                   in pay_sta_shd.g_rec_type,
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
  chk_state_code
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id,
   p_state_code            => p_rec.state_code);
  --
  chk_jurisdiction_code
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_jurisdiction_code     => p_rec.jurisdiction_code
  ,p_state_code            => p_rec.state_code
  );
  --
  chk_sit_optional_calc_ind
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id,
   p_sit_optional_calc_ind => p_rec.sit_optional_calc_ind,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_assignment_id
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_assignment_id         => p_rec.assignment_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_effective_date        => p_effective_date
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_additional_wa_amount
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_additional_wa_amount  => p_rec.additional_wa_amount
  );
  --
  chk_filing_status_code
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_state_code            => p_rec.state_code
  ,p_filing_status_code    => p_rec.filing_status_code
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );
  --
  chk_sit_additional_tax
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_sit_additional_tax    => p_rec.sit_additional_tax
  );
  --
  chk_sit_override_amount
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_sit_override_amount   => p_rec.sit_override_amount
  );
  --
  chk_sit_override_rate
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_sit_override_rate     => p_rec.sit_override_rate
  );
  --
  chk_remainder_percent
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_remainder_percent     => p_rec.remainder_percent
  );
  --
  chk_secondary_wa
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_secondary_wa          => p_rec.secondary_wa
  );
  --
  chk_withholding_allowances
  (p_emp_state_tax_rule_id    => p_rec.emp_state_tax_rule_id
  ,p_withholding_allowances => p_rec.withholding_allowances
  );
  --
  chk_sui_wage_base_override_amo
  (p_emp_state_tax_rule_id    => p_rec.emp_state_tax_rule_id
  ,p_sui_wage_base_override_amo => p_rec.sui_wage_base_override_amount
  );
  --
  chk_supp_tax_override_rate
  (p_emp_state_tax_rule_id  => p_rec.emp_state_tax_rule_id
  ,p_supp_tax_override_rate => p_rec.supp_tax_override_rate
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
      (p_rec                   in pay_sta_shd.g_rec_type,
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
  (p_rec                   => p_rec
  ,p_effective_date        => p_effective_date
  );
  --
  chk_sit_optional_calc_ind
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id,
   p_sit_optional_calc_ind => p_rec.sit_optional_calc_ind,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_additional_wa_amount
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_additional_wa_amount  => p_rec.additional_wa_amount
  );
  --
  chk_filing_status_code
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_state_code            => p_rec.state_code
  ,p_filing_status_code    => p_rec.filing_status_code
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );
  --
  chk_sit_additional_tax
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_sit_additional_tax    => p_rec.sit_additional_tax
  );
  --
  chk_sit_override_amount
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_sit_override_amount   => p_rec.sit_override_amount
  );
  --
  chk_sit_override_rate
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_sit_override_rate     => p_rec.sit_override_rate
  );
  --
  chk_remainder_percent
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_remainder_percent     => p_rec.remainder_percent
  );
  --
  chk_secondary_wa
  (p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id
  ,p_secondary_wa          => p_rec.secondary_wa
  );
  --
  chk_withholding_allowances
  (p_emp_state_tax_rule_id    => p_rec.emp_state_tax_rule_id
  ,p_withholding_allowances => p_rec.withholding_allowances
  );
  --
  chk_sui_wage_base_override_amo
  (p_emp_state_tax_rule_id    => p_rec.emp_state_tax_rule_id
  ,p_sui_wage_base_override_amo => p_rec.sui_wage_base_override_amount
  );
  --
  chk_supp_tax_override_rate
  (p_emp_state_tax_rule_id  => p_rec.emp_state_tax_rule_id
  ,p_supp_tax_override_rate => p_rec.supp_tax_override_rate
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
      (p_rec                    in pay_sta_shd.g_rec_type,
       p_effective_date       in date,
       p_datetrack_mode       in varchar2,
       p_validation_start_date in date,
       p_validation_end_date       in date,
       p_delete_routine        in varchar2
      ) is
--
  l_proc      varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete
  (p_emp_state_tax_rule_id   => p_rec.emp_state_tax_rule_id
  ,p_assignment_id           => pay_sta_shd.g_old_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_datetrack_mode          => p_datetrack_mode
  ,p_validation_start_date   => p_validation_start_date
  ,p_validation_end_date     => p_validation_end_date
  ,p_delete_routine          => p_delete_routine
  );
  --
  dt_delete_validate
    (p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date    => p_validation_end_date,
     p_emp_state_tax_rule_id  => p_rec.emp_state_tax_rule_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_emp_state_tax_rule_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_us_emp_state_tax_rules_f b
    where b.emp_state_tax_rule_id      = p_emp_state_tax_rule_id
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
                             p_argument       => 'emp_state_tax_rule_id',
                             p_argument_value => p_emp_state_tax_rule_id);
  --
  if nvl(g_sta_tax_rule_id, hr_api.g_number) = p_emp_state_tax_rule_id then
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
    g_sta_tax_rule_id  := p_emp_state_tax_rule_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pay_sta_bus;

/
