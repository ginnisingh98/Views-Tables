--------------------------------------------------------
--  DDL for Package Body PAY_NCR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NCR_BUS" as
/* $Header: pyncrrhi.pkb 120.0 2005/05/29 06:52:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ncr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_net_calculation_rule_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   net_calculation_rule_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_net_calculation_rule_id(p_net_calculation_rule_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_net_calculation_rule_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_ncr_shd.api_updating
    (p_net_calculation_rule_id                => p_net_calculation_rule_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_net_calculation_rule_id,hr_api.g_number)
     <>  pay_ncr_shd.g_old_rec.net_calculation_rule_id) then
    --
    -- raise error as PK has changed
    --
    pay_ncr_shd.constraint_error('PAY_NET_CALCULATION_RULES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_net_calculation_rule_id is not null then
      --
      -- raise error as PK is not null
      --
      pay_ncr_shd.constraint_error('PAY_NET_CALCULATION_RULES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_net_calculation_rule_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_accrual_plan_id >------|
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
--   p_net_calculation_rule_id PK
--   p_accrual_plan_id ID of FK column
--   p_object_version_number object version number
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
Procedure chk_accrual_plan_id (p_net_calculation_rule_id          in number,
                            p_accrual_plan_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_accrual_plan_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_accrual_plans a
    where  a.accrual_plan_id = p_accrual_plan_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pay_ncr_shd.api_updating
     (p_net_calculation_rule_id            => p_net_calculation_rule_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_accrual_plan_id,hr_api.g_number)
     <> nvl(pay_ncr_shd.g_old_rec.accrual_plan_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if accrual_plan_id value exists in pay_accrual_plans table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pay_accrual_plans
        -- table.
        --
        pay_ncr_shd.constraint_error('PAY_NET_CALCULATION_RULES_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_accrual_plan_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_date_input_value >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the date input value for a net calculation rule -
--    this input value must be present for all rules on an accrual plan,
--    with the exception of the absence element's rule.
--
--  Prerequisites:
--
--  In Arguments:
--    p_accrual_plan_id
--    p_input_value_id
--    p_date_input_value_id
--
--  Post Success:
--    If date input value is present, processing continues.
--
--  Post Failure:
--    An error is raised if date input value is null.
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_date_input_value (p_accrual_plan_id     in number,
                                p_input_value_id      in number,
                                p_date_input_value_id in number ) is
--
  l_proc               varchar2(72) := g_package||'chk_date_input_value';
  l_pto_input_value_id number;

  cursor c_get_absence_iv is
  select pto_input_value_id
  from pay_accrual_plans
  where accrual_plan_id = p_accrual_plan_id;
--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c_get_absence_iv;
  fetch c_get_absence_iv into l_pto_input_value_id;
  close c_get_absence_iv;

  if (nvl(l_pto_input_value_id, -1) <> p_input_value_id) and
     (p_date_input_value_id is null) then
  --
    fnd_message.set_name('PER', 'PER_52857_DATE_IV_MANDATORY');
    fnd_message.raise_error;
  --
  end if;

  hr_utility.set_location('Entering:'||l_proc, 5);
--
end chk_date_input_value;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_duplicate_rule >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the rule is not a duplicate for a particular plan.
--
--  Prerequisites:
--
--  In Arguments:
--    p_accrual_plan_id
--    p_net_calc_rule_id
--    p_input_value_id
--    p_date_input_value_id
--
--  Post Success:
--    If duplicate not found, processing continues.
--
--  Post Failure:
--    An error is raised if duplicate is found
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_duplicate_rule (p_accrual_plan_id     in number,
                              p_net_calc_rule_id    in number,
                              p_input_value_id      in number,
                              p_date_input_value_id in number ) is
--
  l_proc               varchar2(72) := g_package||'chk_duplicate_rule';
  l_dummy              number;

  cursor c_get_duplicate is
  select 1
  from pay_net_calculation_rules
  where accrual_plan_id = p_accrual_plan_id
  and input_value_id = p_input_value_id
  and date_input_value_id = p_date_input_value_id
  and net_calculation_rule_id <> nvl(p_net_calc_rule_id, -1);
--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c_get_duplicate;
  fetch c_get_duplicate into l_dummy;

  if c_get_duplicate%found then
  --
    close c_get_duplicate;

    fnd_message.set_name('PER', 'HR_74022_PAP_NCR_DUPLICATE');
    fnd_message.raise_error;
  --
  else
  --
    close c_get_duplicate;
  --
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);
--
end chk_duplicate_rule;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_ncr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call all supporting business operations
  --
  chk_net_calculation_rule_id
  (p_net_calculation_rule_id          => p_rec.net_calculation_rule_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_accrual_plan_id
  (p_net_calculation_rule_id          => p_rec.net_calculation_rule_id,
   p_accrual_plan_id          => p_rec.accrual_plan_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_date_input_value(p_accrual_plan_id     => p_rec.accrual_plan_id,
                       p_input_value_id      => p_rec.input_value_id,
                       p_date_input_value_id => p_rec.date_input_value_id);
  --
  chk_duplicate_rule(p_accrual_plan_id     => p_rec.accrual_plan_id,
                     p_net_calc_rule_id    => p_rec.net_calculation_rule_id,
                     p_input_value_id      => p_rec.input_value_id,
                     p_date_input_value_id => p_rec.date_input_value_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_ncr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call all supporting business operations
  --
  chk_net_calculation_rule_id
  (p_net_calculation_rule_id          => p_rec.net_calculation_rule_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_accrual_plan_id
  (p_net_calculation_rule_id          => p_rec.net_calculation_rule_id,
   p_accrual_plan_id          => p_rec.accrual_plan_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_date_input_value(p_accrual_plan_id     => p_rec.accrual_plan_id,
                       p_input_value_id      => p_rec.input_value_id,
                       p_date_input_value_id => p_rec.date_input_value_id);
  --
  chk_duplicate_rule(p_accrual_plan_id     => p_rec.accrual_plan_id,
                     p_net_calc_rule_id    => p_rec.net_calculation_rule_id,
                     p_input_value_id      => p_rec.input_value_id,
                     p_date_input_value_id => p_rec.date_input_value_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_ncr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
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
  (p_net_calculation_rule_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_net_calculation_rules b
    where b.net_calculation_rule_id      = p_net_calculation_rule_id
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
                             p_argument       => 'net_calculation_rule_id',
                             p_argument_value => p_net_calculation_rule_id);
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
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pay_ncr_bus;

/
