--------------------------------------------------------
--  DDL for Package Body IRC_VCE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VCE_BUS" as
/* $Header: irvcerhi.pkb 120.1 2005/12/13 06:42:58 cnholmes noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_vce_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vacancy_id                  number         default null;
g_variable_comp_lookup        varchar2(30)   default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vacancy_id                           in number
  ,p_variable_comp_lookup                 in varchar2
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_all_vacancies pav
     where pav.vacancy_id = p_vacancy_id
     and   pbg.business_group_id = pav.business_group_id;
  --
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
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'variable_comp_lookup'
    ,p_argument_value     => p_variable_comp_lookup
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'VACANCY_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'VARIABLE_COMP_LOOKUP')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
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
  (p_vacancy_id                           in     number
  ,p_variable_comp_lookup                 in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- Join between irc_variable_comp_elements and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.

  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
          ,per_all_vacancies pav
     where pav.vacancy_id = p_vacancy_id
       and pbg.business_group_id = pav.business_group_id;
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
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'variable_comp_lookup'
    ,p_argument_value     => p_variable_comp_lookup
    );
  --
  if (( nvl(irc_vce_bus.g_vacancy_id, hr_api.g_number)
       = p_vacancy_id)
  and ( nvl(irc_vce_bus.g_variable_comp_lookup, hr_api.g_varchar2)
       = p_variable_comp_lookup)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_vce_bus.g_legislation_code;
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
    irc_vce_bus.g_vacancy_id                  := p_vacancy_id;
    irc_vce_bus.g_variable_comp_lookup        := p_variable_comp_lookup;
    irc_vce_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in irc_vce_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_vce_shd.api_updating
      (p_vacancy_id                           => p_rec.vacancy_id
      ,p_variable_comp_lookup                 => p_rec.variable_comp_lookup
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Since no update is there for IRC_VARIABLE_COMP_ELEMENTS, no additional
  -- checks need to be added here.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_variable_comp_lookup >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that variable compensation lookup is
--   correct.
--
-- Pre Conditions:
--
--
-- In Arguments:
--   p_variable_comp_lookup
--   p_effective_date
--
-- Post Success:
--   Processing continues if all the variable compensation lookup is correct
--
-- Post Failure:
--   An application error is raised if variable compensation lookup is
--   incorrect
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_variable_comp_lookup
  (p_effective_date       in date
  ,p_variable_comp_lookup in
                            irc_variable_comp_elements.variable_comp_lookup%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_variable_comp_lookup';
  l_ret      boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  -- Checks that variable compensation lookup is passed as mandatory argument.
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'variable_comp_lookup'
    ,p_argument_value     => p_variable_comp_lookup
    );
  --  Checks that variable compensation lookup is validated against hr_lookups.
  hr_utility.set_location(l_proc,15);
  l_ret := hr_api.not_exists_in_hr_lookups(
            p_effective_date => p_effective_date
           ,p_lookup_type    => 'IRC_VARIABLE_COMP_ELEMENT'
           ,p_lookup_code    => p_variable_comp_lookup);
  hr_utility.set_location(l_proc,20);
  if l_ret = true then
    fnd_message.set_name('PER','IRC_412030_VCE_INV_VAR_COMP_LO');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,25);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_VARIABLE_COMP_ELEMENTS.VARIABLE_COMP_LOOKUP'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,30);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,35);
end chk_variable_comp_lookup;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_vacancy_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that vacancy id exists in
--   PER_ALL_VACANCIES
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_vacancy_id
--
-- Post Success:
--   Processing continues if all the variable compensation lookup is correct
--
-- Post Failure:
--   An application error is raised if variable compensation lookup is
--   incorrect
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_effective_date in  date
  ,p_vacancy_id     in  irc_variable_comp_elements.vacancy_id%TYPE
  ) IS
--
  l_proc       varchar2(72) := g_package || 'chk_vacancy_id';
  l_vacancy_id varchar2(1);
--
  cursor csr_vacancy_id is
  select null from per_all_vacancies pav where pav.vacancy_id = p_vacancy_id
  and p_effective_date < NVL(pav.date_to,hr_api.g_eot);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  -- Checks that vacancy_id is passed as mandatory attribute
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'vacancy_id'
  ,p_argument_value     => p_vacancy_id
   );
  -- Checks that vacancy_id exists in PER_ALL_VACANCIES.
  hr_utility.set_location(l_proc,15);
  open csr_vacancy_id;
  fetch csr_vacancy_id into l_vacancy_id;
  if csr_vacancy_id%NOTFOUND then
    close csr_vacancy_id;
    fnd_message.set_name('PER','IRC_412031_VCE_INV_VACANCY_ID');
    fnd_message.raise_error;
  end if;
  close csr_vacancy_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_VARIABLE_COMP_ELEMENTS.VACANCY_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,25);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,30);
end chk_vacancy_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_vce_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  -- Call all supporting business operations
  --
  -- After validating the set of important attributes,
  -- if Mulitple message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc,10);
  chk_variable_comp_lookup
  (p_effective_date        => p_effective_date
  ,p_variable_comp_lookup  => p_rec.variable_comp_lookup
  );
  --
  --
  hr_utility.set_location(l_proc,15);
  chk_vacancy_id
  (p_effective_date => p_effective_date
  ,p_vacancy_id      => p_rec.vacancy_id
  );
  --
  --  As IRC_VARIABLE_COMP_ELEMENTS does not have a mandatory business_group_id
  --  column, client_info is populated by calling
  --  irc_vce_bus.set_security_group_id procedure.
  hr_utility.set_location(l_proc,20);
  irc_vce_bus.set_security_group_id(
   p_vacancy_id            => p_rec.vacancy_id
  ,p_variable_comp_lookup  => p_rec.variable_comp_lookup
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_vce_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  -- Call all supporting business operations
  --
  -- After validating the set of important attributes,
  -- if Mulitple message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc,10);
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
    ,p_rec                         => p_rec
    );
  --
  --  As IRC_VARIABLE_COMP_ELEMENTS does not have a mandatory business_group_id
  --  column, client_info is populated by calling
  --  irc_vce_bus.set_security_group_id procedure.
  hr_utility.set_location(l_proc,15);
  irc_vce_bus.set_security_group_id(
   p_vacancy_id            => p_rec.vacancy_id
  ,p_variable_comp_lookup  => p_rec.variable_comp_lookup
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_vce_shd.g_rec_type
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
end irc_vce_bus;

/
