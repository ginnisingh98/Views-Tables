--------------------------------------------------------
--  DDL for Package Body IRC_LCV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_LCV_BUS" as
/* $Header: irlcvrhi.pkb 120.0 2005/10/03 14:58 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_lcv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_location_criteria_value_id  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_location_criteria_value_id           in number
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
    ,p_argument           => 'location_criteria_value_id'
    ,p_argument_value     => p_location_criteria_value_id
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
  (p_location_criteria_value_id           in     number
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
    ,p_argument           => 'location_criteria_value_id'
    ,p_argument_value     => p_location_criteria_value_id
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
  (p_rec in irc_lcv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_lcv_shd.api_updating
      (p_location_criteria_value_id        => p_rec.location_criteria_value_id
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
  if p_rec.location_criteria_value_id <>
       irc_lcv_shd.g_old_rec.location_criteria_value_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'LOCATION_CRITERIA_VALUE_ID'
     ,p_base_table => irc_lcv_shd.g_tab_nam
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
  (p_search_criteria_id     in irc_location_criteria_values.search_criteria_id%TYPE
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
  -- Check that search_criteria_id exists in irc_search_criteria.
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
         'IRC_LOCATION_CRITERIA_VALUES.SEARCH_CRITERIA_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_search_criteria_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_lcv_shd.g_rec_type
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
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  chk_search_criteria_id
    (p_search_criteria_id => p_rec.search_criteria_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DERIVED_LOCALE'
    ,p_argument_value     => p_rec.derived_locale
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_lcv_shd.g_rec_type
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
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_lcv_shd.g_rec_type
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
end irc_lcv_bus;

/
