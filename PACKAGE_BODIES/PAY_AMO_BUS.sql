--------------------------------------------------------
--  DDL for Package Body PAY_AMO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AMO_BUS" as
/* $Header: pyamorhi.pkb 120.0.12000000.1 2007/01/17 15:29:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33);  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_module_id                   number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_module_id                            in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_au_modules amo
     where amo.module_id = p_module_id
       and pbg.business_group_id (+) = amo.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72);
  l_legislation_code  varchar2(150);
  --
begin
  --
  l_proc :=  g_package||'set_security_group_id';
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'module_id'
    ,p_argument_value     => p_module_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'MODULE_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_module_id                            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_au_modules amo
     where amo.module_id = p_module_id
       and pbg.business_group_id (+) = amo.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
  --
Begin
  --
  l_proc :=  g_package||'return_legislation_code';
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'module_id'
    ,p_argument_value     => p_module_id
    );
  --
  if ( nvl(pay_amo_bus.g_module_id, hr_api.g_number)
       = p_module_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_amo_bus.g_legislation_code;
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
    pay_amo_bus.g_module_id                   := p_module_id;
    pay_amo_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_amo_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72);
--
Begin
  --
  l_proc := g_package || 'chk_non_updateable_args';
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_amo_shd.api_updating
      (p_module_id                         => p_rec.module_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_legislation_code >----------------------------|
-- ---------------------------------------------------------------------------
PROCEDURE chk_legislation_code
  (p_legislation_code                  in     varchar2
  ) IS
  l_proc     varchar2(72);
--
Begin
  --
  l_proc := g_package || 'chk_legislation_code';
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  -- To check if the legislation is 'AU' or 'NZ'
  if p_legislation_code is null then
    fnd_message.set_name('PAY', 'HR_AU_MISSING_LEGISLATION_CODE');
    fnd_message.raise_error;
  end if;
  --
  if not (p_legislation_code = 'AU' or p_legislation_code = 'NZ') then
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  --
End chk_legislation_code;
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_business_group_id >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Check the business group id existl for choosen legislation code
--
--  Prerequisites:
--
--  In Arguments:
--    p_legislation_code
--    p_business_group_id
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if mismatch the legislation code  and business group id
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_business_group_id
  (p_legislation_code                  in     varchar2
  ,p_business_group_id                 in     number
  ) IS
--
  l_proc          varchar2(72);
  l_dummy_number  number;
--
  cursor csr_valid_bgd_leg(
                     p_leg_code   varchar2,
                     p_bg_id      number) is
  select 1
  from per_business_groups pbg
  where pbg.business_group_id = p_bg_id
  and   pbg.legislation_code  = p_leg_code;
--
Begin
  l_proc := g_package || 'chk_business_group_id';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_business_group_id is not null then
    open csr_valid_bgd_leg(p_legislation_code,
                           p_business_group_id);
    fetch csr_valid_bgd_leg into l_dummy_number;
    --
    if csr_valid_bgd_leg%notfound then
      --
      --
      close csr_valid_bgd_leg;
      fnd_message.set_name('PAY','HR_33586_INVALID_BG_LEG_COMBI');
      fnd_message.raise_error;
    end if;
    --
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_business_group_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_amo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'insert_validate';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_legislation_code(p_rec.legislation_code);
  chk_business_group_id(p_rec.legislation_code,
                        p_rec.business_group_id);
  --
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_amo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'update_validate';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_legislation_code(p_rec.legislation_code);
  chk_business_group_id(p_rec.legislation_code,
                        p_rec.business_group_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
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
  (p_rec                          in pay_amo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'delete_validate';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
begin
  g_package := '  pay_amo_bus.';  -- Global package name
end pay_amo_bus;

/
