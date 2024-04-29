--------------------------------------------------------
--  DDL for Package Body PAY_CNU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNU_BUS" as
/* $Header: pycnurhi.pkb 120.0 2005/05/29 04:04:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cnu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_contribution_usage_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_contribution_usage_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_fr_contribution_usages con
     where con.contribution_usage_id = p_contribution_usage_id
       and pbg.business_group_id = con.business_group_id;
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
    ,p_argument           => 'contribution_usage_id'
    ,p_argument_value     => p_contribution_usage_id
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
  (p_contribution_usage_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_fr_contribution_usages con
     where con.contribution_usage_id = p_contribution_usage_id
       and pbg.business_group_id (+) = con.business_group_id;
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
    ,p_argument           => 'contribution_usage_id'
    ,p_argument_value     => p_contribution_usage_id
    );
  --
  if ( nvl(pay_cnu_bus.g_contribution_usage_id, hr_api.g_number)
       = p_contribution_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_cnu_bus.g_legislation_code;
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
    pay_cnu_bus.g_contribution_usage_id := p_contribution_usage_id;
    pay_cnu_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_cnu_shd.g_rec_type
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
  IF NOT pay_cnu_shd.api_updating
      (p_contribution_usage_id                => p_rec.contribution_usage_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  if nvl(p_rec.contribution_usage_id, hr_api.g_number) <>
     nvl(pay_cnu_shd.g_old_rec.contribution_usage_id, hr_api.g_number) then
     l_argument := 'contribution_usage_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  if nvl(p_rec.date_from, hr_api.g_date) <>
     nvl(pay_cnu_shd.g_old_rec.date_from, hr_api.g_date) then
     l_argument := 'date_from';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  if nvl(p_rec.group_code, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.group_code, hr_api.g_varchar2) then
     l_argument := 'group_code';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  if nvl(p_rec.process_type, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.process_type, hr_api.g_varchar2) then
     l_argument := 'process_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 60);
  if nvl(p_rec.element_name, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.element_name, hr_api.g_varchar2) then
     l_argument := 'element_name';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 70);
  if nvl(p_rec.rate_type, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.rate_type, hr_api.g_varchar2) then
     l_argument := 'rate_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 80);
/*  if nvl(p_rec.contribution_code, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.contribution_code, hr_api.g_varchar2) then
     l_argument := 'contribution_code';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 90);
  if nvl(p_rec.contribution_type, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.contribution_type, hr_api.g_varchar2) then
     l_argument := 'contribution_type';
     raise l_error;
  end if;*/
  --
  hr_utility.set_location(' Step:'|| l_proc, 100);
  if nvl(p_rec.contribution_usage_type, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.contribution_usage_type, hr_api.g_varchar2) then
     l_argument := 'contribution_usage_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 110);
  if nvl(p_rec.rate_category, hr_api.g_varchar2) <>
     nvl(pay_cnu_shd.g_old_rec.rate_category, hr_api.g_varchar2) then
     l_argument := 'rate_category';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 120);
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_cnu_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 130);
  /*if nvl(p_rec.code_rate_id, hr_api.g_number) <>
     nvl(pay_cnu_shd.g_old_rec.code_rate_id, hr_api.g_number) then
     l_argument := 'code_rate_id';
     raise l_error;
  end if;*/
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in     date
  ,p_rec                          in pay_cnu_shd.g_rec_type
  ,p_code_Rate_id                 out nocopy PAY_FR_CONTRIBUTION_USAGES.CODE_RATE_ID%TYPE
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_code_Rate_id  PAY_FR_CONTRIBUTION_USAGES.CODE_RATE_ID%TYPE := p_rec.code_Rate_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.
  --
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  pay_cnu_bus1.chk_dates (
    p_contribution_usage_id   => p_rec.contribution_usage_id
   ,p_object_version_number   => p_rec.object_version_number
   ,p_date_from               => p_rec.date_from
   ,p_date_to                 => p_rec.date_to
   ,p_group_code              => p_rec.group_code
   ,p_process_type            => p_rec.process_type
   ,p_element_name            => p_rec.element_name
   ,p_contribution_usage_type => p_rec.contribution_usage_type
   ,p_business_group_id       => p_rec.business_group_id
   );
  --

  hr_utility.set_location(' Step:'|| l_proc, 15);
  pay_cnu_bus1.chk_lu_group_code (
  p_effective_date          => p_effective_date
 ,p_group_code              => p_rec.group_code
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  pay_cnu_bus1.chk_group_code (
    p_group_code              => p_rec.group_code
   ,p_process_type            => p_rec.process_type
   ,p_element_name            => p_rec.element_name
   ,p_contribution_usage_type => p_rec.contribution_usage_type
   ,p_business_group_id       => p_rec.business_group_id
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  pay_cnu_bus1.chk_contribution_type (
    p_contribution_type => p_rec.contribution_type
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  pay_cnu_bus1.chk_contribution_codes (
  p_contribution_usage_id   => p_rec.contribution_usage_id
 ,p_object_version_number   => p_rec.object_version_number
 ,p_contribution_type       => p_rec.contribution_type
 ,p_contribution_code       => p_rec.contribution_code
 ,p_retro_contribution_code => p_rec.retro_contribution_code
 ,p_rate_category           => p_rec.rate_category
 );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  pay_cnu_bus1.chk_rate_category_type (
  p_rate_type               => p_rec.rate_type
 ,p_rate_category           => p_rec.rate_category
 );
  --
  hr_utility.set_location(' Step:'|| l_proc, 60);
  pay_cnu_bus1.chk_business_group_id (
  p_business_group_id       => p_rec.business_group_id
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 80);
  pay_cnu_bus1.chk_process_type (
  p_effective_date          => p_effective_date
 ,p_process_type            => p_rec.process_type
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 90);
  pay_cnu_bus1.chk_rate_type (
  p_effective_date          => p_effective_date
 ,p_rate_type               => p_rec.rate_type
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 90);
  pay_cnu_bus1.chk_contribution_usage_type (
  p_effective_date          => p_effective_date
 ,p_contribution_usage_type => p_rec.contribution_usage_type
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 100);
  pay_cnu_bus1.chk_element_name (
  p_element_name            => p_rec.element_name
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 110);
  pay_cnu_bus1.chk_code_rate_id (
  p_code_rate_id            => l_code_Rate_id
 ,p_contribution_code       => p_rec.contribution_code
 ,p_business_group_id       => p_rec.business_group_id
 ,p_rate_type               => p_rec.rate_type
 ,p_rate_category           => p_rec.rate_category
  );
  /* set the out parameter */
  p_code_Rate_id := l_code_rate_id;
  hr_utility.set_location(' Leaving:'||l_proc, 200);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in     date
  ,p_rec                          in pay_cnu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.
  --
  -- Call all supporting business operations
  --
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  pay_cnu_bus1.chk_dates (
    p_contribution_usage_id   => p_rec.contribution_usage_id
   ,p_object_version_number   => p_rec.object_version_number
   ,p_date_from               => p_rec.date_from
   ,p_date_to                 => p_rec.date_to
   ,p_group_code              => p_rec.group_code
   ,p_process_type            => p_rec.process_type
   ,p_element_name            => p_rec.element_name
   ,p_contribution_usage_type => p_rec.contribution_usage_type
   ,p_business_group_id       => p_rec.business_group_id
   );
   -- The contribution type is also updated.  Though the contribution
   -- type is checked in chk_non_updateable_args, it is also checked here.
   hr_utility.set_location(' Step:'|| l_proc, 50);
   pay_cnu_bus1.chk_contribution_type (
    p_contribution_type => p_rec.contribution_type
   );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  pay_cnu_bus1.chk_contribution_codes (
  p_contribution_usage_id   => p_rec.contribution_usage_id
 ,p_object_version_number   => p_rec.object_version_number
 ,p_contribution_type       => p_rec.contribution_type
 ,p_contribution_code       => p_rec.contribution_code
 ,p_retro_contribution_code => p_rec.retro_contribution_code
 ,p_rate_category           => p_rec.rate_category
 );
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_cnu_shd.g_rec_type
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
end pay_cnu_bus;

/
