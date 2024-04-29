--------------------------------------------------------
--  DDL for Package Body PAY_OPT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_OPT_BUS" as
/* $Header: pyoptrhi.pkb 115.3 2002/12/05 17:29:47 nbristow noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_opt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_org_payment_method_id       number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_org_payment_method_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_org_payment_methods_f opm
     where opm.org_payment_method_id = p_org_payment_method_id
       and pbg.business_group_id = opm.business_group_id;
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
    ,p_argument           => 'org_payment_method_id'
    ,p_argument_value     => p_org_payment_method_id
    );
  --
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
  (p_org_payment_method_id                in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_org_payment_methods_f_tl opt
         , pay_org_payment_methods_f opm
     where opt.org_payment_method_id = p_org_payment_method_id
       and opt.language = p_language
       and opm.org_payment_method_id = opt.org_payment_method_id
       and pbg.business_group_id = opm.business_group_id;
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
    ,p_argument           => 'org_payment_method_id'
    ,p_argument_value     => p_org_payment_method_id
    );
  --
  --
  if (( nvl(pay_opt_bus.g_org_payment_method_id, hr_api.g_number)
       = p_org_payment_method_id)
  and ( nvl(pay_opt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_opt_bus.g_legislation_code;
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
    pay_opt_bus.g_org_payment_method_id:= p_org_payment_method_id;
    pay_opt_bus.g_language          := p_language;
    pay_opt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_opt_shd.g_rec_type
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
  IF NOT pay_opt_shd.api_updating
      (p_org_payment_method_id                => p_rec.org_payment_method_id
      ,p_language                             => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Checks to ensure non-updateable args have not been updated.
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
-- |--------------------< chk_org_payment_method_name >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Check that the org_payment_method_name is not null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_org_payment_method_name
--    p_language
--    p_org_payment_method_id
--
--  Post Success:
--    Processing continues if the org_payment_method_name is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the org_payment_method_name is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_org_payment_method_name
  (p_org_payment_method_name in pay_org_payment_methods_f.org_payment_method_name%TYPE
  ,p_language                in varchar2
  ,p_org_payment_method_id   in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_org_payment_method_name';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor csr_org_pay_meth_name_exists is
     select  null
       from  pay_org_payment_methods_f opm,
             pay_org_payment_methods_f_tl opt
      where  upper(opt.org_payment_method_name) = upper(p_org_payment_method_name)
        and  opt.language = p_language
        and  opm.org_payment_method_id = opt.org_payment_method_id
        and  opm.org_payment_method_id <> p_org_payment_method_id
        and  exists
             (select null
                from pay_org_payment_methods_f opm1
               where opm1.org_payment_method_id = p_org_payment_method_id
                 and opm1.business_group_id = opm.business_group_id);
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --    Check mandatory org_payment_method_name exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'org_payment_method_name'
    ,p_argument_value               => p_org_payment_method_name
    );
  --
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ( nvl(pay_opm_shd.g_old_rec.org_payment_method_name,hr_api.g_varchar2) <>
       nvl(p_org_payment_method_name,hr_api.g_varchar2)) then
     --
     hr_utility.set_location(l_proc,20);
     --
     --
     open csr_org_pay_meth_name_exists;
     fetch csr_org_pay_meth_name_exists into l_dummy;
     if csr_org_pay_meth_name_exists%found then
        close csr_org_pay_meth_name_exists;
        -- RAISE ERROR MESSAGE
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'ORG_PAYMENT_METHOD_NAME');
        fnd_message.raise_error;
     end if;
     close csr_org_pay_meth_name_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_org_payment_method_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_opt_shd.g_rec_type
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
  pay_opt_bus.set_security_group_id(p_org_payment_method_id
                                    => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc,30);
  --
  pay_opt_bus.chk_org_payment_method_name(p_org_payment_method_name => p_rec.org_payment_method_name
                                          ,p_language => p_rec.language
                                          ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc,40);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_opt_shd.g_rec_type
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
  pay_opt_bus.set_security_group_id(p_org_payment_method_id
                                    => p_rec.org_payment_method_id);
  --
  pay_opt_bus.chk_org_payment_method_name(p_org_payment_method_name => p_rec.org_payment_method_name
                                          ,p_language => p_rec.language
                                          ,p_org_payment_method_id => p_rec.org_payment_method_id);
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
  (p_rec                          in pay_opt_shd.g_rec_type
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
end pay_opt_bus;

/
