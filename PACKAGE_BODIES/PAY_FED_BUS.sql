--------------------------------------------------------
--  DDL for Package Body PAY_FED_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FED_BUS" as
/* $Header: pyfedrhi.pkb 120.1.12000000.4 2007/07/26 11:08:20 vaprakas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_fed_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_sui_state_code >------|
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
--   p_emp_fed_tax_rule_id     PK
--   p_sui_state_code          ID of FK column
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
Procedure chk_sui_state_code
  (p_emp_fed_tax_rule_id      in number
  ,p_sui_state_code           in pay_us_emp_fed_tax_rules_f.sui_state_code%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sui_state_code';
  l_dummy        varchar2(1);
  --
  cursor csr_state_code is
    select null
    from   pay_us_states pus
    where  pus.state_code = p_sui_state_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_fed_tax_rule_id is not null
     and nvl(p_sui_state_code,hr_api.g_varchar2)
     <> pay_fed_shd.g_old_rec.sui_state_code)
   or (p_emp_fed_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_sui_state_code is null then
      hr_utility.set_message(801, 'PAY_72797_FED_SUI_STA_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if sui_state_code value exists in pay_us_states table
    --
    open csr_state_code;
      --
      fetch csr_state_code into l_dummy;
      if csr_state_code%notfound then
        --
        close csr_state_code;
        --
        -- raise error as FK does not relate to PK in pay_us_states table.
        --
        pay_fed_shd.constraint_error('PAY_US_EMP_FED_TAX_RULES_FK1');
        --
      end if;
      --
    close csr_state_code;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_sui_state_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_assignment_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the assignment_id with the following checks:
--    - the assignment_id exists in PER_ASSIGNMENTS_F
--    - the assignment's business group must match the tax record's bus grp.
--   The tax record's business_group_id is also validated by checking that it
--    matches an existing business_group_id in PER_ASSIGNMENTS_F.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id     PK
--   p_assignment_id           ID of FK column
--   p_business_group_id       business group id
--   p_object_version_number   object version number
--   p_effective_date          session date
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
  (p_emp_fed_tax_rule_id      in number
  ,p_assignment_id            in pay_us_emp_fed_tax_rules_f.assignment_id%TYPE
  ,p_business_group_id        in
                             pay_us_emp_fed_tax_rules_f.business_group_id%TYPE
  ,p_object_version_number    in number
  ,p_effective_date           in date
  ) is
  --
  l_proc                    varchar2(72) := g_package||'chk_assignment_id';
  l_dummy                   varchar2(1);
  l_api_updating            boolean;
  l_business_group_id       per_assignments_f.business_group_id%TYPE;
  --
  cursor csr_bg_id is
    select business_group_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    p_effective_date between asg.effective_start_date
             and asg.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  if p_assignment_id is null then
     hr_utility.set_message(801, 'PAY_72780_FED_ASG_NOT_NULL');
     hr_utility.raise_error;
  end if;
  --
  if p_business_group_id is null then
     hr_utility.set_message(801, 'PAY_72782_FED_BG_NOT_NULL');
     hr_utility.raise_error;
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  l_api_updating := pay_fed_shd.api_updating
     (p_emp_fed_tax_rule_id     => p_emp_fed_tax_rule_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  --  Since assignment_id cannot be updated, the case of
  --  l_api_updating = TRUE is not considered
  --
  if (not l_api_updating) then
    --
    open csr_bg_id;
      --
      fetch csr_bg_id into l_business_group_id;
      if csr_bg_id%notfound then
        --
        close csr_bg_id;
        --
        -- raise error as assignment_id not found in per_assignments_f
        -- table.
        --
        hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
        hr_utility.raise_error;
        --
      else
        --
        if p_business_group_id <> l_business_group_id then
          --
          close csr_bg_id;
          --
          hr_utility.set_message(801, 'PAY_72781_FED_BG_MATCH_ASG');
          hr_utility.raise_error;
          --
        end if;
        --
        close csr_bg_id;
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
-- |------< chk_sui_jurisdiction_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the sui_jurisdiction_code against PAY_STATE_RULES
--   where the state is the same as the sui_state_code
--
-- Pre-Conditions
--   Valid sui_state_code
--
-- In Parameters
--   p_emp_fed_tax_rule_id     PK
--   p_sui_jurisdiction_code
--   p_sui_state_code
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
Procedure chk_sui_jurisdiction_code
  (p_emp_fed_tax_rule_id      in number
  ,p_sui_jurisdiction_code    in
                         pay_us_emp_fed_tax_rules_f.sui_jurisdiction_code%TYPE
  ,p_sui_state_code           in pay_us_emp_fed_tax_rules_f.sui_state_code%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_sui_jurisdiction_code';
  l_dummy        varchar2(1);
  --
  cursor csr_sui_jd is
    select null
    from   pay_us_states pus, pay_state_rules psr
    where  pus.state_code = p_sui_state_code
    and    pus.state_abbrev = psr.state_code
    and    psr.jurisdiction_code = p_sui_jurisdiction_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'sui_state_code'
    ,p_argument_value => p_sui_state_code
    );
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_fed_tax_rule_id is not null
     and nvl(p_sui_jurisdiction_code,hr_api.g_varchar2)
     <> nvl(pay_fed_shd.g_old_rec.sui_jurisdiction_code,hr_api.g_varchar2)
   or (p_emp_fed_tax_rule_id is null)) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_sui_jurisdiction_code is null then
      hr_utility.set_message(801, 'PAY_72796_FED_SUI_JD_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if sui_jurisdiction_code value exists in pay_state_rules table
    --
    open csr_sui_jd;
      --
      fetch csr_sui_jd into l_dummy;
      if csr_sui_jd%notfound then
        --
        close csr_sui_jd;
        --
        -- raise error as code does not exist in pay_state_rules table.
        --
        hr_utility.set_message(801, 'PAY_8003_1099R_JU_CODE');
        hr_utility.raise_error;
        --
      end if;
      --
    close csr_sui_jd;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_sui_jurisdiction_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_additional_wa_amount >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that additional_wa_amount >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id    PK
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
  (p_emp_fed_tax_rule_id      in number
  ,p_additional_wa_amount     in
                          pay_us_emp_fed_tax_rules_f.additional_wa_amount%TYPE
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
  if (p_emp_fed_tax_rule_id is not null
      and nvl(p_additional_wa_amount,hr_api.g_number) <>
          pay_fed_shd.g_old_rec.additional_wa_amount)
   or (p_emp_fed_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_additional_wa_amount is null then
      hr_utility.set_message(801, 'PAY_72779_FED_ADDL_WA_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if additional_wa_amount value is in a valid range
    --
    if p_additional_wa_amount < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72778_FED_ADDL_WA_POSITIVE');
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
-- |------< chk_filing_status_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the filing_status_code against hr_lookups.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id    PK
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
  (p_emp_fed_tax_rule_id      in number
  ,p_filing_status_code       in
                            pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
  ,p_effective_date           in date
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_filing_status_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_fed_tax_rule_id is not null
     and nvl(p_filing_status_code,hr_api.g_varchar2)
     <> pay_fed_shd.g_old_rec.filing_status_code)
   or (p_emp_fed_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_filing_status_code is null then
      hr_utility.set_message(801, 'PAY_72786_FED_FIL_STAT_NOT_NUL');
      hr_utility.raise_error;
    end if;
    --
    -- check if filing_status_code value exists in hr_lookups table
    --
    if hr_api.not_exists_in_dt_hr_lookups
         (p_effective_date        => p_effective_date
         ,p_validation_start_date => p_validation_start_date
         ,p_validation_end_date   => p_validation_end_date
         ,p_lookup_type           => 'US_FIT_FILING_STATUS'
         ,p_lookup_code           => p_filing_status_code
         ) then
       --
       -- raise error as filing_status_code does not exist in hr_lookups
       -- table.
       --
       hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP');
       hr_utility.set_message_token('COLUMN','federal filing_status_code');
       hr_utility.set_message_token('LOOKUP_TYPE','US_FIT_FILING_STATUS');
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
-- |------< chk_fit_override_amount >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that fit_override_amount >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id    PK
--   p_fit_override_amount
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
Procedure chk_fit_override_amount
  (p_emp_fed_tax_rule_id      in number
  ,p_fit_override_amount      in
                           pay_us_emp_fed_tax_rules_f.fit_override_amount%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_fit_override_amount';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_fed_tax_rule_id is not null
     and nvl(p_fit_override_amount,hr_api.g_number)
     <> nvl(pay_fed_shd.g_old_rec.fit_override_amount,hr_api.g_number))
   or (p_emp_fed_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_fit_override_amount is null then
      hr_utility.set_message(801, 'PAY_72791_FED_OVD_AMT_NOT_NUL');
      hr_utility.raise_error;
    end if;
    --
    -- check if fit_override_amount value is in a valid range
    --
    if p_fit_override_amount < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72790_FED_OVRD_AMT_POSITIV');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_fit_override_amount;
--
-- ----------------------------------------------------------------------------
-- |------< chk_fit_override_rate >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that fit_override_rate is between 0 and 100
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id    PK
--   p_fit_override_rate
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
Procedure chk_fit_override_rate
  (p_emp_fed_tax_rule_id      in number
  ,p_fit_override_rate        in
                             pay_us_emp_fed_tax_rules_f.fit_override_rate%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_fit_override_rate';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being inserted or updated...
  --
  if (p_emp_fed_tax_rule_id is not null
     and nvl(p_fit_override_rate,hr_api.g_number)
     <> nvl(pay_fed_shd.g_old_rec.fit_override_rate,hr_api.g_number))
   or (p_emp_fed_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_fit_override_rate is null then
      hr_utility.set_message(801, 'PAY_72793_FED_OVD_RT_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if fit_override_rate value is in a valid range
    --
    if p_fit_override_rate < 0  or p_fit_override_rate > 100 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72792_FED_OVD_RT_IN_RANGE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_fit_override_rate;
--
-- ----------------------------------------------------------------------------
-- |------< chk_withholding_allowances >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that withholding_allowances >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id    PK
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
  (p_emp_fed_tax_rule_id      in number
  ,p_withholding_allowances   in
                        pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
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
  if (p_emp_fed_tax_rule_id is not null
     and nvl(p_withholding_allowances,hr_api.g_number)
     <> nvl(pay_fed_shd.g_old_rec.withholding_allowances,hr_api.g_number))
   or (p_emp_fed_tax_rule_id is null) then
    --
    -- Check that the mandatory parameters have been set
    --
    if p_withholding_allowances is null then
      hr_utility.set_message(801, 'PAY_72800_FED_WA_NOT_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- check if withholding_allowances value is in a valid range
    --
    if p_withholding_allowances < 0 then
      --
      -- raise error as given value is invalid
      --
      hr_utility.set_message(801,'PAY_72799_FED_WA_POSITIVE');
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
-- |------< chk_eic_filing_status_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the eic_filing_status_code against hr_lookups.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id     PK
--   p_eic_filing_status_code  ID of FK column
--   p_effective_date          session date
--   p_validation_start_date   date
--   p_validation_end_date     date
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
Procedure chk_eic_filing_status_code
  (p_emp_fed_tax_rule_id      in number
  ,p_eic_filing_status_code   in
                        pay_us_emp_fed_tax_rules_f.eic_filing_status_code%TYPE
  ,p_effective_date           in date
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_eic_filing_status_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- If the value is being updated or inserted...
  --
  if ((p_emp_fed_tax_rule_id is not null
     and nvl(p_eic_filing_status_code,hr_api.g_varchar2)
     <> nvl(pay_fed_shd.g_old_rec.eic_filing_status_code,hr_api.g_varchar2))
    or
     (p_emp_fed_tax_rule_id is null)) then
    --
    -- Validate only if attribute is not null
    --
    if p_eic_filing_status_code is not null then
      --
      -- check if eic_filing_status_code value exists in hr_lookups table
      --
      if hr_api.not_exists_in_dt_hr_lookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'US_EIC_FILING_STATUS'
           ,p_lookup_code           => p_eic_filing_status_code
           ) then
         --
         -- raise error as eic_filing_status_code does not exist in hr_lookups
         -- table.
         --
         pay_fed_shd.constraint_error('PAY_USFTR_EIC_FILING_STATU_CHK');
         --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_eic_filing_status_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_fit_additional_tax >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that fit_additional_tax >= 0
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id    PK
--   p_fit_additional_tax
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
Procedure chk_fit_additional_tax
  (p_emp_fed_tax_rule_id      in number
  ,p_fit_additional_tax       in
                            pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_fit_additional_tax';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being updated or inserted...
  --
  if ((p_emp_fed_tax_rule_id is not null
     and nvl(p_fit_additional_tax,hr_api.g_number)
     <> nvl(pay_fed_shd.g_old_rec.fit_additional_tax,hr_api.g_number))
    or
     (p_emp_fed_tax_rule_id is null)) then
    --
    -- Validate only if attribute is not null
    --
    if p_fit_additional_tax is not null then
      --
      -- check if fit_additional_tax value is in a valid range
      --
      if p_fit_additional_tax < 0 then
        --
        -- raise error as given value is invalid
        --
        hr_utility.set_message(801,'PAY_72777_FED_ADD_TAX_POSITIVE');
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
End chk_fit_additional_tax;
--
-- ----------------------------------------------------------------------------
-- |------< chk_supp_tax_override_rate >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that supp_tax_override_rate between 0 and 100
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_emp_fed_tax_rule_id PK
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
  (p_emp_fed_tax_rule_id      in number
  ,p_supp_tax_override_rate   in
                        pay_us_emp_fed_tax_rules_f.supp_tax_override_rate%TYPE
  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_supp_tax_override_rate';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the value is being updated or inserted...
  --
  if ((p_emp_fed_tax_rule_id is not null
     and nvl(p_supp_tax_override_rate,hr_api.g_number)
     <> nvl(pay_fed_shd.g_old_rec.supp_tax_override_rate,hr_api.g_number))
    or
     (p_emp_fed_tax_rule_id is null)) then
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
        hr_utility.set_message(801,'PAY_72798_FED_SUPP_RT_IN_RANGE');
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
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Tax rules may be deleted from pay_us_emp_fed_tax_rules_f only when the
--    assignment is being deleted.
--
-- Pre-Conditions
--   None
--
-- In Parameters
--   p_emp_fed_tax_rule_id           PK
--   p_assignment_id                 assignment id
--   p_effective_date                session date
--   p_object_version_number         object version number
--   p_validation_start_date         date
--   p_validation_end_date           date
--   p_delete_routine                varchar2
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
  (p_emp_fed_tax_rule_id             in number
  ,p_assignment_id                   in number
  ,p_effective_date                  in date
  ,p_datetrack_mode                  in varchar2
  ,p_validation_start_date           in date
  ,p_validation_end_date             in date
  ,p_delete_routine                  in varchar2
  ) is
  --
  l_effective_date           date;
  l_exists                   varchar2(1);
  l_proc                     varchar2(72) := g_package||'chk_delete';
  l_state_rule_exists        varchar2(1);
  --
  cursor csr_check_payroll(p_csr_tmp_date in date) is
       select null
         from dual
        where exists (select null
                        from pay_payroll_actions ppa,
                             pay_assignment_actions paa
                       where ppa.payroll_action_id = paa.payroll_action_id
                         and ppa.action_type in ('Q','R','B','I','V')
                         and ppa.date_earned > p_csr_tmp_date
                         and paa.assignment_id = pay_fed_shd.g_old_rec.assignment_id
                         and paa.action_status = 'C'
                     );
  --
  -- Cursor to check for existing state tax rules
  --
  cursor csr_state_tax_rules
  is
     select null
      from  pay_us_emp_state_tax_rules_f sta
      where sta.assignment_id      = p_assignment_id
      and   sta.effective_end_date > l_effective_date;
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
  if nvl(p_delete_routine,'X') <> 'ASSIGNMENT' then
    hr_utility.set_message(801, 'HR_6674_PAY_ASSIGN');
    hr_utility.raise_error;
  end if;
  --
  --
  if p_datetrack_mode in('ZAP', 'DELETE') then
    --
    if p_datetrack_mode = hr_api.g_zap then
      l_effective_date := trunc(hr_api.g_sot);
    else
      l_effective_date := trunc(p_effective_date);
    end if;
    --
    -- Check if payroll has been run for this assignment
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
  elsif p_datetrack_mode in('DELETE_NEXT_CHANGE', 'FUTURE_CHANGE') then
    --
    null;
    --
  else
    --
    hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
    hr_utility.raise_error;
    --
  end if;
  --
  -- If any state tax rules exist for this assignment, raise an error.
  --
  open csr_state_tax_rules;
  fetch csr_state_tax_rules into l_state_rule_exists;
  if csr_state_tax_rules%found then
     close csr_state_tax_rules;
     hr_utility.set_message(801,'HR_7215_DT_CHILD_EXISTS');
     hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_STATE_TAX_RULES_F');
     hr_utility.raise_error;
  end if;
  close csr_state_tax_rules;
  --
  --
End chk_delete;
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
  (p_rec                                in pay_fed_shd.g_rec_type
  ,p_effective_date                     in date
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
  if not pay_fed_shd.api_updating
      (p_emp_fed_tax_rule_id => p_rec.emp_fed_tax_rule_id
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
     pay_fed_shd.g_old_rec.assignment_id)then
     l_argument := 'assignment_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 40);
  --
  if (nvl(p_rec.business_group_id, hr_api.g_number) <>
     pay_fed_shd.g_old_rec.business_group_id)then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 50);
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 60);
end chk_non_updateable_args;
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
           p_datetrack_mode       in varchar2,
             p_validation_start_date      in date,
           p_validation_end_date      in date) Is
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
          (p_emp_fed_tax_rule_id      in number,
           p_datetrack_mode           in varchar2,
           p_validation_start_date    in date,
           p_validation_end_date      in date) Is
--
  l_proc      varchar2(72)   := g_package||'dt_delete_validate';
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
       p_argument       => 'emp_fed_tax_rule_id',
       p_argument_value => p_emp_fed_tax_rule_id);
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
      (p_rec                   in pay_fed_shd.g_rec_type,
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
  chk_assignment_id
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_assignment_id         => p_rec.assignment_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  );
  --
  chk_sui_state_code
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_sui_state_code        => p_rec.sui_state_code
  );
  --
  chk_sui_jurisdiction_code
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_sui_jurisdiction_code => p_rec.sui_jurisdiction_code
  ,p_sui_state_code        => p_rec.sui_state_code
  );
  --
  chk_additional_wa_amount
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_additional_wa_amount  => p_rec.additional_wa_amount
  );
  --
  chk_filing_status_code
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_filing_status_code    => p_rec.filing_status_code
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );
  --
  chk_fit_override_amount
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_fit_override_amount   => p_rec.fit_override_amount
  );
  --
  chk_fit_override_rate
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_fit_override_rate     => p_rec.fit_override_rate
  );
  --
  chk_withholding_allowances
  (p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id
  ,p_withholding_allowances => p_rec.withholding_allowances
  );
  --
  chk_eic_filing_status_code
  (p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id
  ,p_eic_filing_status_code => p_rec.eic_filing_status_code
  ,p_effective_date         => p_effective_date
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  );
  --
  chk_fit_additional_tax
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_fit_additional_tax    => p_rec.fit_additional_tax
  );
  --
  chk_supp_tax_override_rate
  (p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id
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
      (p_rec                   in pay_fed_shd.g_rec_type,
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
  chk_sui_state_code
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_sui_state_code        => p_rec.sui_state_code
  );
  --
  chk_sui_jurisdiction_code
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_sui_jurisdiction_code => p_rec.sui_jurisdiction_code
  ,p_sui_state_code        => p_rec.sui_state_code
  );
  --
  chk_additional_wa_amount
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_additional_wa_amount  => p_rec.additional_wa_amount
  );
  --
  chk_filing_status_code
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_filing_status_code    => p_rec.filing_status_code
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );
  --
  chk_fit_override_amount
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_fit_override_amount   => p_rec.fit_override_amount
  );
  --
  chk_fit_override_rate
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_fit_override_rate     => p_rec.fit_override_rate
  );
  --
  chk_withholding_allowances
  (p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id
  ,p_withholding_allowances => p_rec.withholding_allowances
  );
  --
  chk_eic_filing_status_code
  (p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id
  ,p_eic_filing_status_code => p_rec.eic_filing_status_code
  ,p_effective_date         => p_effective_date
  ,p_validation_start_date  => p_validation_start_date
  ,p_validation_end_date    => p_validation_end_date
  );
  --
  chk_fit_additional_tax
  (p_emp_fed_tax_rule_id   => p_rec.emp_fed_tax_rule_id
  ,p_fit_additional_tax    => p_rec.fit_additional_tax
  );
  --
  chk_supp_tax_override_rate
  (p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id
  ,p_supp_tax_override_rate => p_rec.supp_tax_override_rate
  );
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
     p_datetrack_mode              => p_datetrack_mode,
     p_validation_start_date       => p_validation_start_date,
     p_validation_end_date         => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
      (p_rec                   in pay_fed_shd.g_rec_type
      ,p_effective_date        in date
      ,p_datetrack_mode        in varchar2
      ,p_validation_start_date in date
      ,p_validation_end_date   in date
      ,p_delete_routine        in varchar2
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
  (p_emp_fed_tax_rule_id     => p_rec.emp_fed_tax_rule_id
  ,p_assignment_id           => pay_fed_shd.g_old_rec.assignment_id
  ,p_effective_date          => p_effective_date
  ,p_datetrack_mode          => p_datetrack_mode
  ,p_validation_start_date   => p_validation_start_date
  ,p_validation_end_date     => p_validation_end_date
  ,p_delete_routine          => p_delete_routine
  );
  --
  --
  --
  dt_delete_validate
    (p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date    => p_validation_end_date,
     p_emp_fed_tax_rule_id    => p_rec.emp_fed_tax_rule_id);
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
  (p_emp_fed_tax_rule_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select bus.legislation_code
    from   per_business_groups bus,
           pay_us_emp_fed_tax_rules_f fed
    where fed.emp_fed_tax_rule_id      = p_emp_fed_tax_rule_id
    and   bus.business_group_id = fed.business_group_id;
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
                             p_argument       => 'emp_fed_tax_rule_id',
                             p_argument_value => p_emp_fed_tax_rule_id);
  --
  if nvl(g_fed_tax_rule_id, hr_api.g_number) = p_emp_fed_tax_rule_id then
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
    g_fed_tax_rule_id  := p_emp_fed_tax_rule_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pay_fed_bus;

/
