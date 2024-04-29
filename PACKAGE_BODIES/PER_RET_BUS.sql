--------------------------------------------------------
--  DDL for Package Body PER_RET_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RET_BUS" as
/* $Header: peretrhi.pkb 115.1 2002/12/06 11:29:20 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ret_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cagr_retained_right_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cagr_retained_right_id              in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_cagr_retained_rights ret
     where ret.cagr_retained_right_id = p_cagr_retained_right_id
       and pbg.business_group_id = ret.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cagr_retained_right_id'
    ,p_argument_value     => p_cagr_retained_right_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_cagr_retained_right_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_cagr_retained_rights ret
     where ret.cagr_retained_right_id = p_cagr_retained_right_id
       and pbg.business_group_id (+) = ret.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cagr_retained_right_id'
    ,p_argument_value     => p_cagr_retained_right_id
    );
  --
  if ( nvl(per_ret_bus.g_cagr_retained_right_id, hr_api.g_number)
       = p_cagr_retained_right_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ret_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_ret_bus.g_cagr_retained_right_id     := p_cagr_retained_right_id;
    per_ret_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  ,p_rec in per_ret_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ret_shd.api_updating
      (p_cagr_retained_right_id              => p_rec.cagr_retained_right_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Checks to ensure non-updateable args have
  -- not been updated.
  --
  if nvl(p_rec.cagr_entitlement_result_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.cagr_entitlement_result_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_result_id';
     raise l_error;
  end if;

  if nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.assignment_id
        ,hr_api.g_number) then
     l_argument := 'assignment_id';
     raise l_error;
  end if;

  if nvl(p_rec.start_date, hr_api.g_date) <>
     nvl(per_ret_shd.g_old_rec.start_date
        ,hr_api.g_date) then
     l_argument := 'start_date';
     raise l_error;
  end if;

  if nvl(p_rec.collective_agreement_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.collective_agreement_id
        ,hr_api.g_number) then
     l_argument := 'collective_agreement_id';
     raise l_error;
  end if;

  if nvl(p_rec.cagr_entitlement_item_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.cagr_entitlement_item_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_item_id';
     raise l_error;
  end if;

 if nvl(p_rec.element_type_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.element_type_id
        ,hr_api.g_number) then
     l_argument := 'element_type_id';
     raise l_error;
  end if;

 if nvl(p_rec.input_value_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.input_value_id
        ,hr_api.g_number) then
     l_argument := 'input_value_id';
     raise l_error;
  end if;

  if nvl(p_rec.cagr_api_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.cagr_api_id
        ,hr_api.g_number) then
     l_argument := 'cagr_api_id';
     raise l_error;
  end if;

 if nvl(p_rec.cagr_api_param_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.cagr_api_param_id
        ,hr_api.g_number) then
     l_argument := 'cagr_api_param_id';
     raise l_error;
  end if;

 if nvl(p_rec.category_name, hr_api.g_varchar2) <>
     nvl(per_ret_shd.g_old_rec.category_name
        ,hr_api.g_varchar2) then
     l_argument := 'category_name';
     raise l_error;
  end if;

 if nvl(p_rec.freeze_flag, hr_api.g_varchar2) <>
     nvl(per_ret_shd.g_old_rec.freeze_flag
        ,hr_api.g_varchar2) then
     l_argument := 'freeze_flag';
     raise l_error;
  end if;

 if nvl(p_rec.cagr_entitlement_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.cagr_entitlement_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_id';
     raise l_error;
  end if;

  if nvl(p_rec.cagr_entitlement_line_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.cagr_entitlement_line_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_line_id';
     raise l_error;
  end if;

 if nvl(p_rec.value, hr_api.g_varchar2) <>
     nvl(per_ret_shd.g_old_rec.value
        ,hr_api.g_varchar2) then
     l_argument := 'value';
     raise l_error;
  end if;

  if nvl(p_rec.units_of_measure, hr_api.g_varchar2) <>
     nvl(per_ret_shd.g_old_rec.units_of_measure
        ,hr_api.g_varchar2) then
     l_argument := 'units_of_measure';
     raise l_error;
  end if;

  if nvl(p_rec.grade_spine_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.grade_spine_id
        ,hr_api.g_number) then
     l_argument := 'grade_spine_id';
     raise l_error;
  end if;

 if nvl(p_rec.parent_spine_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.parent_spine_id
        ,hr_api.g_number) then
     l_argument := 'parent_spine_id';
     raise l_error;
  end if;

  if nvl(p_rec.step_id , hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.step_id
        ,hr_api.g_number) then
     l_argument := 'step_id ';
     raise l_error;
  end if;

  if nvl(p_rec.oipl_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.oipl_id
        ,hr_api.g_number) then
     l_argument := 'oipl_id';
     raise l_error;
  end if;

  if nvl(p_rec.column_type, hr_api.g_varchar2) <>
     nvl(per_ret_shd.g_old_rec.column_type
        ,hr_api.g_varchar2) then
     l_argument := 'column_type';
     raise l_error;
  end if;

  if nvl(p_rec.column_size, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.column_size
        ,hr_api.g_number) then
     l_argument := 'column_size';
     raise l_error;
  end if;

   if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.business_group_id
        ,hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;

  if nvl(p_rec.eligy_prfl_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.eligy_prfl_id
        ,hr_api.g_number) then
     l_argument := 'eligy_prfl_id';
     raise l_error;
  end if;

  if nvl(p_rec.formula_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.formula_id
        ,hr_api.g_number) then
     l_argument := 'formula_id';
     raise l_error;
  end if;

  if nvl(p_rec.flex_value_set_id, hr_api.g_number) <>
     nvl(per_ret_shd.g_old_rec.flex_value_set_id
        ,hr_api.g_number) then
     l_argument := 'flex_value_set_id';
     raise l_error;
  end if;


  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- ensure lookup validation fires when BG is not null
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;


  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ret_shd.g_rec_type
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
end per_ret_bus;

/
