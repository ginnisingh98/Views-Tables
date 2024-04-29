--------------------------------------------------------
--  DDL for Package Body IRC_PCV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PCV_BUS" as
/* $Header: irpcvrhi.pkb 120.0 2005/10/03 14:59:01 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_pcv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_prof_area_criteria_value_id number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_prof_area_criteria_value_id          in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare local variables
  --
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
    ,p_argument           => 'prof_area_criteria_value_id'
    ,p_argument_value     => p_prof_area_criteria_value_id
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
  (p_prof_area_criteria_value_id          in     number
  )
  Return Varchar2 Is
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150) := 'NONE';
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
    ,p_argument           => 'prof_area_criteria_value_id'
    ,p_argument_value     => p_prof_area_criteria_value_id
    );
  --
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
  ,p_rec in irc_pcv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_pcv_shd.api_updating
      (p_prof_area_criteria_value_id       => p_rec.prof_area_criteria_value_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  --            not been updated.
  --
  if p_rec.prof_area_criteria_value_id <>
       irc_pcv_shd.g_old_rec.prof_area_criteria_value_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'PROF_AREA_CRITERIA_VALUE_ID'
     ,p_base_table => irc_pcv_shd.g_tab_nam
     );
  end if;
  --
  if p_rec.search_criteria_id <>
       irc_pcv_shd.g_old_rec.search_criteria_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'SEARCH_CRITERIA_ID'
     ,p_base_table => irc_pcv_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_search_criteria_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that search criteria id exists in
--   IRC_SEARCH_CRITERIA
--
-- Pre Conditions:
--
-- In Arguments:
--   p_search_criteria_id
--
-- Post Success:
--   Processing continues if search criteria id is valid
--
-- Post Failure:
--   An application error is raised if search criteria id is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_search_criteria_id
  (p_search_criteria_id     in irc_prof_area_criteria_values.search_criteria_id%TYPE
  ) IS
--
  l_proc       varchar2(72) := g_package || 'chk_search_criteria_id';
  l_search_criteria_id varchar2(1);
--
  cursor csr_search_criteria is
    select null from irc_search_criteria isc
    where isc.search_criteria_id = p_search_criteria_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  -- Check that search_criteria_id is not null.
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SEARCH_CRITERIA_ID'
    ,p_argument_value     => p_search_criteria_id
    );
  --
  hr_utility.set_location(l_proc,20);
  if p_search_criteria_id is not null then
    -- Check that search_criteria_id exists in irc_search_criteria.
    hr_utility.set_location(l_proc,30);
    open csr_search_criteria;
    fetch csr_search_criteria into l_search_criteria_id;
    hr_utility.set_location(l_proc,40);
    if csr_search_criteria%NOTFOUND then
      close csr_search_criteria;
      fnd_message.set_name('PER','IRC_412226_INV_SRCH_CRITERIA');
      fnd_message.raise_error;
    end if;
  end if;
  close csr_search_criteria;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
         'IRC_PROF_AREA_CRITERIA_VALUES.SEARCH_CRITERIA_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_search_criteria_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_professional_area >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that professional area exists in
--   hr_lookups
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_professional_area
--  p_effective_date
--  p_prof_area_criteria_value_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if professional_area is valid.
--
-- Post Failure:
--   An application error is raised if professional_area is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_professional_area
  (p_professional_area             in irc_prof_area_criteria_values.professional_area%TYPE
  ,p_effective_date                in date
  ,p_prof_area_criteria_value_id   in irc_prof_area_criteria_values.prof_area_criteria_value_id%TYPE
  ,p_object_version_number in irc_prof_area_criteria_values.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72) := g_package || 'chk_professional_area';
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PROFESSIONAL_AREA'
    ,p_argument_value     => p_professional_area
    );
  --
  hr_utility.set_location(l_proc,20);
  if p_professional_area is not null then
    -- Check that professional_area exists in hr_lookups
    hr_utility.set_location(l_proc,30);
    l_ret := hr_api.not_exists_in_hr_lookups(
                                     p_effective_date => p_effective_date
                                    ,p_lookup_type    => 'IRC_PROFESSIONAL_AREA'
                                    ,p_lookup_code    => p_professional_area);
    if l_ret = true then
      fnd_message.set_name('PER','IRC_412022_BAD_PROF_AREA');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'IRC_PROF_AREA_CRITERIA_VALUES.PROFESSIONAL_AREA'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_professional_area;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 30);
  chk_search_criteria_id
    (p_search_criteria_id => p_rec.search_criteria_id
    );
  --
  hr_utility.set_location(l_proc, 40);
  irc_pcv_bus.chk_professional_area(
        p_professional_area           => p_rec.professional_area
       ,p_effective_date              => p_effective_date
       ,p_prof_area_criteria_value_id => p_rec.prof_area_criteria_value_id
       ,p_object_version_number       => p_rec.object_version_number
       );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_pcv_shd.g_rec_type
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
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_pcv_shd.g_rec_type
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
end irc_pcv_bus;

/
