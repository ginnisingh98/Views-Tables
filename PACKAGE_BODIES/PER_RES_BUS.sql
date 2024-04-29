--------------------------------------------------------
--  DDL for Package Body PER_RES_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RES_BUS" as
/* $Header: peresrhi.pkb 115.2 2003/04/02 13:38:24 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_res_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cagr_entitlement_result_id  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cagr_entitlement_result_id           in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_cagr_entitlement_results res
     where res.cagr_entitlement_result_id = p_cagr_entitlement_result_id
       and pbg.business_group_id = res.business_group_id;
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
    ,p_argument           => 'cagr_entitlement_result_id'
    ,p_argument_value     => p_cagr_entitlement_result_id
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
  (p_cagr_entitlement_result_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_cagr_entitlement_results res
     where res.cagr_entitlement_result_id = p_cagr_entitlement_result_id
       and pbg.business_group_id (+) = res.business_group_id;
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
    ,p_argument           => 'cagr_entitlement_result_id'
    ,p_argument_value     => p_cagr_entitlement_result_id
    );
  --
  if ( nvl(per_res_bus.g_cagr_entitlement_result_id, hr_api.g_number)
       = p_cagr_entitlement_result_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_res_bus.g_legislation_code;
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
    per_res_bus.g_cagr_entitlement_result_id  := p_cagr_entitlement_result_id;
    per_res_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in per_res_shd.g_rec_type
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
  IF NOT per_res_shd.api_updating
      (p_cagr_entitlement_result_id           => p_rec.cagr_entitlement_result_id
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
   hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.assignment_id
        ,hr_api.g_number) then
     l_argument := 'assignment_id';
     raise l_error;
  end if;
/*
  if nvl(p_rec.cagr_request_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.cagr_request_id
        ,hr_api.g_number) then
     l_argument := 'cagr_request_id';
     raise l_error;
  end if;
*/

  if nvl(p_rec.start_date, hr_api.g_date) <>
     nvl(per_res_shd.g_old_rec.start_date
        ,hr_api.g_date) then
     l_argument := 'start_date';
     raise l_error;
  end if;

  if nvl(p_rec.end_date, hr_api.g_date) <>
     nvl(per_res_shd.g_old_rec.end_date
        ,hr_api.g_date) then
     l_argument := 'end_date';
     raise l_error;
  end if;

  if nvl(p_rec.collective_agreement_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.collective_agreement_id
        ,hr_api.g_number) then
     l_argument := 'collective_agreement_id';
     raise l_error;
  end if;

  if nvl(p_rec.cagr_entitlement_item_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.cagr_entitlement_item_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_item_id';
     raise l_error;
  end if;

 if nvl(p_rec.element_type_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.element_type_id
        ,hr_api.g_number) then
     l_argument := 'element_type_id';
     raise l_error;
  end if;

 if nvl(p_rec.input_value_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.input_value_id
        ,hr_api.g_number) then
     l_argument := 'input_value_id';
     raise l_error;
  end if;

 if nvl(p_rec.cagr_api_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.cagr_api_id
        ,hr_api.g_number) then
     l_argument := 'cagr_api_id';
     raise l_error;
  end if;

 if nvl(p_rec.cagr_api_param_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.cagr_api_param_id
        ,hr_api.g_number) then
     l_argument := 'cagr_api_param_id';
     raise l_error;
  end if;

 if nvl(p_rec.category_name, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.category_name
        ,hr_api.g_varchar2) then
     l_argument := 'category_name';
     raise l_error;
  end if;

 if nvl(p_rec.cagr_entitlement_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.cagr_entitlement_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_id';
     raise l_error;
  end if;

 if nvl(p_rec.cagr_entitlement_line_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.cagr_entitlement_line_id
        ,hr_api.g_number) then
     l_argument := 'cagr_entitlement_line_id';
     raise l_error;
  end if;
-- works

 if nvl(p_rec.value, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.value
        ,hr_api.g_varchar2) then
     l_argument := 'value';
     raise l_error;
  end if;

  if nvl(p_rec.units_of_measure, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.units_of_measure
        ,hr_api.g_varchar2) then
     l_argument := 'units_of_measure';
     raise l_error;
  end if;

 if nvl(p_rec.range_from, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.range_from
        ,hr_api.g_varchar2) then
     l_argument := 'range_from';
     raise l_error;
  end if;

 if nvl(p_rec.range_to, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.range_to
        ,hr_api.g_varchar2) then
     l_argument := 'range_to';
     raise l_error;
  end if;

 if nvl(p_rec.grade_spine_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.grade_spine_id
        ,hr_api.g_number) then
     l_argument := 'grade_spine_id';
     raise l_error;
  end if;

 if nvl(p_rec.parent_spine_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.parent_spine_id
        ,hr_api.g_number) then
     l_argument := 'parent_spine_id';
     raise l_error;
  end if;

  if nvl(p_rec.step_id , hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.step_id
        ,hr_api.g_number) then
     l_argument := 'step_id ';
     raise l_error;
  end if;

 if nvl(p_rec.from_step_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.from_step_id
        ,hr_api.g_number) then
     l_argument := 'from_step_id';
     raise l_error;
  end if;

  if nvl(p_rec.to_step_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.to_step_id
        ,hr_api.g_number) then
     l_argument := 'to_step_id';
     raise l_error;
  end if;

  if nvl(p_rec.oipl_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.oipl_id
        ,hr_api.g_number) then
     l_argument := 'oipl_id';
     raise l_error;
  end if;

  if nvl(p_rec.column_type, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.column_type
        ,hr_api.g_varchar2) then
     l_argument := 'column_type';
     raise l_error;
  end if;

  if nvl(p_rec.column_size, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.column_size
        ,hr_api.g_number) then
     l_argument := 'column_size';
     raise l_error;
  end if;

  if nvl(p_rec.beneficial_flag, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.beneficial_flag ,hr_api.g_varchar2) then
     l_argument := 'beneficial_flag';
     raise l_error;
  end if;

  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.business_group_id
        ,hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;

  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(per_res_shd.g_old_rec.legislation_code
        ,hr_api.g_varchar2) then
     l_argument := 'legislation_code';
     raise l_error;
  end if;

  if nvl(p_rec.eligy_prfl_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.eligy_prfl_id
        ,hr_api.g_number) then
     l_argument := 'eligy_prfl_id';
     raise l_error;
  end if;

  if nvl(p_rec.formula_id, hr_api.g_number) <>
     nvl(per_res_shd.g_old_rec.formula_id
        ,hr_api.g_number) then
     l_argument := 'formula_id';
     raise l_error;
  end if;
  --
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
-- |--------------------------< chk_chosen_flag >------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the value for chosen_flag exists in hr_lookups (lookup_code)
--    for the lookup_type 'YES_NO' on the effective date.
--    Only called by update_validate since the row_handler deliberately only
--    supports update of per_cagr_entitlement_results.
--
--  Pre-conditions:
--    Effective_date must be valid.
--
--  In Arguments:
--    p_cagr_entitlement_result_id
--    p_chosen_flag
--    p_effective_date
--
--  Post Success:
--    If a row does exist in hr_lookups for the given chosen_flag value then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_lookups for the given chosen_flag value then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_chosen_flag (p_cagr_entitlement_result_id in number
                          ,p_chosen_flag                in varchar2
                          ,p_effective_date             in date) is
 --
   l_proc           varchar2(72)  :=  g_package||'chk_chosen_flag';
 --

Begin
 --
 hr_utility.set_location('Entering:'|| l_proc, 1);
 --
 hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
 --
 if p_chosen_flag is not null then
   --
   hr_utility.set_location(l_proc, 5);
   -- Only proceed with validation if :
   -- Updating and the value for chosen_flag has changed
   --
   if ((p_cagr_entitlement_result_id is not null) and
      (per_res_shd.g_old_rec.chosen_flag <> p_chosen_flag)) then
       --
     if hr_api.not_exists_in_hr_lookups
       (p_effective_date        => p_effective_date
       ,p_lookup_type           => 'YES_NO'
       ,p_lookup_code           => p_chosen_flag
       )
     then
     --
       hr_utility.set_message(800, 'HR_XXXXXX_CAGR_INV_CHOSEN');
       hr_utility.raise_error;
     --
     end if;
   end if;
 end if;

 --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 --
End chk_chosen_flag;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Error out - this rowhandler should not be used  to insert data as only
  -- per_cagr_engine_pkg may write records to the per_cagr_entitlement_results table.
  --
     hr_utility.set_message(800, 'HR_XXXXX_CAGR_INV_RES_INS');
     hr_utility.raise_error;
  --
  --
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
  ,p_rec                          in per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
    ,p_rec                       => p_rec
    );
  --
  -- validate chosen flag, when updating only.
  --
  chk_chosen_flag (p_cagr_entitlement_result_id => p_rec.cagr_entitlement_result_id
                  ,p_chosen_flag                => p_rec.chosen_flag
                  ,p_effective_date             => p_effective_date);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,per_res_shd.g_old_rec.business_group_id
                    ,per_res_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_res_bus;

/
