--------------------------------------------------------
--  DDL for Package Body PAY_TFU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TFU_BUS" as
/* $Header: pytfurhi.pkb 120.0 2005/05/29 09:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_tfu_bus.';  -- Global package name
--
-- The following global variables are set by the chk_template_id.
--
g_legislation_code            varchar2(150)  default null;
g_business_group_id           number         default null;
g_template_type               varchar2(150)  default null;
g_template_id                 number         default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in pay_tfu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_argument varchar2(30);
  l_error    exception;
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_tfu_shd.api_updating
      (p_template_ff_usage_id              => p_rec.template_ff_usage_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- p_template_id
  --
  if nvl(p_rec.template_id, hr_api.g_number) <>
     nvl(pay_tfu_shd.g_old_rec.template_id, hr_api.g_number)
  then
    l_argument := 'p_template_id';
    raise l_error;
  end if;
  --
exception
    when l_error then
       hr_utility.set_location('Leaving:'||l_proc, 30);
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
      raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_unique >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_unique
  (p_template_ff_usage_id  in number
  ,p_template_id           in number
  ,p_object_version_number in number
  ,p_formula_id            in number
  ,p_object_id             in number
  ) is
  --
  -- Cursor to check that object_id corresponds to element_type_id for an
  -- element within the same template.
  --
  cursor csr_uniqueness_chk
         (p_template_ff_usage_id in number
         ,p_template_id          in number
         ,p_object_id            in number
         ,p_formula_id           in number
         ) is
  select null
  from   pay_template_ff_usages tfu
  where  tfu.template_id = p_template_id
  and    tfu.template_ff_usage_id <> p_template_ff_usage_id
  and    tfu.object_id = p_object_id
  and    tfu.formula_id = p_formula_id;
  --
  l_api_updating boolean;
  l_proc         varchar2(72) := g_package||'chk_unique';
  l_exists       varchar2(1);
--
Begin
  l_api_updating := pay_tfu_shd.api_updating
  (p_template_ff_usage_id  => p_template_ff_usage_id
  ,p_object_version_number => p_object_version_number
  );
  if l_api_updating and
     (
       nvl(p_object_id, hr_api.g_number) <>
       nvl(pay_tfu_shd.g_old_rec.object_id, hr_api.g_number) or
       nvl(p_formula_id, hr_api.g_number) <>
       nvl(pay_tfu_shd.g_old_rec.formula_id, hr_api.g_number)
     ) or
     not l_api_updating then
    open csr_uniqueness_chk
         (p_template_ff_usage_id => nvl(p_template_ff_usage_id, hr_api.g_number)
         ,p_template_id          => p_template_id
         ,p_object_id            => p_object_id
         ,p_formula_id           => p_formula_id
         );
    fetch csr_uniqueness_chk into l_exists;
    if csr_uniqueness_chk%found then
      close csr_uniqueness_chk;
      fnd_message.set_name('PAY', 'PAY_50207_TFU_FF_USAGE_EXISTS');
      fnd_message.raise_error;
    end if;
    close csr_uniqueness_chk;
  end if;
End chk_unique;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_template_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_id
  (p_template_id     in     number
  ) is
  --
  -- Cursor to check that template_id is valid.
  --
  cursor csr_template_info is
  select pet.template_id
  ,      pet.template_type
  ,      pet.business_group_id
  ,      nvl(pbg.legislation_code, pet.legislation_code)
  from   pay_element_templates pet
  ,      per_business_groups_perf pbg
  where  pet.template_id = p_template_id
  and    pet.template_type = 'T'
  and    pbg.business_group_id (+)= pet.business_group_id;
  --
  l_proc  varchar2(72) := g_package||'chk_template_id';
--
Begin
  open csr_template_info;
  fetch csr_template_info
  into  g_template_id
  ,     g_template_type
  ,     g_business_group_id
  ,     g_legislation_code
  ;
  if csr_template_info%notfound then
    close csr_template_info;
    fnd_message.set_name('PAY', 'PAY_50114_ETM_INVALID_TEMPLATE');
    fnd_message.raise_error;
  end if;
  close csr_template_info;
End chk_template_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_object_id >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_object_id
  (p_template_id     in     number
  ,p_object_id       in     number
  ) is
  --
  -- Cursor to check that object_id corresponds to element_type_id for an
  -- element within the same template.
  --
  cursor csr_object_id is
  select null
  from   pay_shadow_element_types pset
  where  pset.template_id = p_template_id
  and    pset.element_type_id = p_object_id;
  --
  l_proc  varchar2(72) := g_package||'chk_object_id';
  l_exists varchar2(1);
--
Begin
  --
  -- Check that template_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_object_id'
  ,p_argument_value => p_object_id
  );
  --
  -- Check that object_id is valid.
  --
  open csr_object_id;
  fetch csr_object_id into l_exists;
  if csr_object_id%notfound then
    close csr_object_id;
    fnd_message.set_name('PAY', 'PAY_50208_TFU_INVALID_OBJECT');
    fnd_message.raise_error;
  end if;
  close csr_object_id;
End chk_object_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in     number
  ,p_template_id           in     number
  ,p_template_ff_usage_id  in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from pay_template_exclusion_rules ter
  where ter.exclusion_rule_id = p_exclusion_rule_id
  and   ter.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'chk_exclusion_rule_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  --
  -- Check that exclusion_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'exclusion_rule_id'
  ,p_argument_value => p_exclusion_rule_id
  );
  --
  l_api_updating := pay_tfu_shd.api_updating
  (p_template_ff_usage_id  => p_template_ff_usage_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_tfu_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_exclusion_rule_id is not null then
      open csr_exclusion_rule_id_valid;
      fetch csr_exclusion_rule_id_valid into l_valid;
      if csr_exclusion_rule_id_valid%notfound then
        close csr_exclusion_rule_id_valid;
        fnd_message.set_name('PAY', 'PAY_50100_ETM_INVALID_EXC_RULE');
        fnd_message.raise_error;
      end if;
      close csr_exclusion_rule_id_valid;
    end if;
  end if;
End chk_exclusion_rule_id;
-- ----------------------------------------------------------------------------
-- | ------------------------< chk_formula_id >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_formula_id
(p_formula_id             in     number
,p_template_id            in     number
,p_template_type          in     varchar2
,p_business_group_id      in     number
,p_legislation_code       in     varchar2
,p_template_ff_usage_id   in     number
,p_object_version_number  in     number
) is
--
  --
  -- Check that the formula is valid.
  --
  -- Note: only payroll formulas are supported at this time.
  --
  -- The ff usage can only belong to a source template (template type 'T'). It
  -- may be shared with other templates, but the legislative domain of the
  -- formula must encompass that of the template.
  --
  cursor csr_formula_valid is
  select null
  from   pay_shadow_formulas sf
  where  sf.formula_id = p_formula_id
  and    sf.template_type = 'T'
  and    nvl(sf.formula_type_name, pay_sf_shd.g_payroll_formula_type) =
         pay_sf_shd.g_payroll_formula_type
  and    ((sf.legislation_code is null and sf.business_group_id is null) or
          sf.legislation_code = p_legislation_code or
          sf.business_group_id = p_business_group_id);
--
  l_proc  varchar2(72) := g_package||'chk_formula_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  l_api_updating := pay_tfu_shd.api_updating
  (p_template_ff_usage_id  => p_template_ff_usage_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_formula_id, hr_api.g_number) <>
      nvl(pay_tfu_shd.g_old_rec.formula_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_formula_id is not null then
      open csr_formula_valid;
      fetch csr_formula_valid into l_valid;
      if csr_formula_valid%notfound then
        close csr_formula_valid;
        fnd_message.set_name('PAY', 'PAY_50209_TFU_INVALID_FORMULA');
        fnd_message.raise_error;
      end if;
      close csr_formula_valid;
    end if;
  end if;
End chk_formula_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_tfu_shd.g_rec_type
  ) is
--
l_proc  varchar2(72) := g_package||'insert_validate';
l_leg_code varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  --
  chk_template_id(p_template_id => p_rec.template_id);
  --
  chk_unique
  (p_template_ff_usage_id  => p_rec.template_ff_usage_id
  ,p_template_id           => p_rec.template_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_formula_id            => p_rec.formula_id
  ,p_object_id             => p_rec.object_id
  );
  --
  chk_object_id
  (p_template_id => p_rec.template_id
  ,p_object_id   => p_rec.object_id
  );
  --
  chk_formula_id
  (p_formula_id             => p_rec.formula_id
  ,p_template_id            => p_rec.template_id
  ,p_template_type          => pay_tfu_bus.g_template_type
  ,p_business_group_id      => pay_tfu_bus.g_business_group_id
  ,p_legislation_code       => pay_tfu_bus.g_legislation_code
  ,p_template_ff_usage_id   => p_rec.template_ff_usage_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => p_rec.template_id
  ,p_template_ff_usage_id  => p_rec.template_ff_usage_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_tfu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
  (p_effective_date   => p_effective_date
  ,p_rec              => p_rec
  );
  --
  -- Do the template check again as it sets up the globals used in
  -- the chk_formula_id call.
  --
  chk_template_id(p_template_id => p_rec.template_id);
  --
  chk_unique
  (p_template_ff_usage_id  => p_rec.template_ff_usage_id
  ,p_template_id           => p_rec.template_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_formula_id            => p_rec.formula_id
  ,p_object_id             => p_rec.object_id
  );
  --
  chk_object_id
  (p_template_id => p_rec.template_id
  ,p_object_id   => p_rec.object_id
  );
  --
  chk_formula_id
  (p_formula_id             => p_rec.formula_id
  ,p_template_id            => p_rec.template_id
  ,p_template_type          => pay_tfu_bus.g_template_type
  ,p_business_group_id      => pay_tfu_bus.g_business_group_id
  ,p_legislation_code       => pay_tfu_bus.g_legislation_code
  ,p_template_ff_usage_id   => p_rec.template_ff_usage_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => p_rec.template_id
  ,p_template_ff_usage_id  => p_rec.template_ff_usage_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_tfu_shd.g_rec_type
  ) is
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
end pay_tfu_bus;

/
