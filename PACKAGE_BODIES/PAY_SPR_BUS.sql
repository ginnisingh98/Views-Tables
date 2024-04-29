--------------------------------------------------------
--  DDL for Package Body PAY_SPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SPR_BUS" as
/* $Header: pysprrhi.pkb 120.0 2005/05/29 08:54:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_spr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_security_profile_id         number         default null;
g_payroll_id                  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_security_profile_id                  in number
  ,p_payroll_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_security_payrolls spr
     where spr.security_profile_id = p_security_profile_id
       and spr.payroll_id = p_payroll_id
       and pbg.business_group_id = spr.business_group_id;
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
    ,p_argument           => 'security_profile_id'
    ,p_argument_value     => p_security_profile_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'payroll_id'
    ,p_argument_value     => p_payroll_id
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
        => nvl(p_associated_column1,'SECURITY_PROFILE_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'PAYROLL_ID')
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
  (p_security_profile_id                  in     number
  ,p_payroll_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_security_payrolls spr
     where spr.security_profile_id = p_security_profile_id
       and spr.payroll_id = p_payroll_id
       and pbg.business_group_id = spr.business_group_id;
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
    ,p_argument           => 'security_profile_id'
    ,p_argument_value     => p_security_profile_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'payroll_id'
    ,p_argument_value     => p_payroll_id
    );
  --
  if (( nvl(pay_spr_bus.g_security_profile_id, hr_api.g_number)
       = p_security_profile_id)
  and ( nvl(pay_spr_bus.g_payroll_id, hr_api.g_number)
       = p_payroll_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_spr_bus.g_legislation_code;
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
    pay_spr_bus.g_security_profile_id         := p_security_profile_id;
    pay_spr_bus.g_payroll_id                  := p_payroll_id;
    pay_spr_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- --------------------------------------------------------------------------
-- |---------------------------< chk_payroll_id >---------------------------|
-- --------------------------------------------------------------------------
Procedure chk_payroll_id
  (p_payroll_id              in         pay_all_payrolls_f.payroll_id%type
  ,p_security_profile_id     in         pay_security_payrolls.security_profile_id%type
  ,p_business_group_id       out nocopy pay_all_payrolls_f.business_group_id%type)
--
is
--
     l_proc varchar2(80) := g_package||'chk_payroll_id';
--
Begin
    hr_utility.set_location('Entering:'||l_proc, 5);

    hr_utility.set_location(to_char(p_payroll_id),10);
    hr_utility.set_location(to_char(p_security_profile_id),15);

    --Ensure that the payroll_id and security_profile_id are valid

      Select distinct pay_all_payrolls_f.business_group_id
      Into  p_business_group_id
      From per_security_profiles, pay_all_payrolls_f
      Where pay_all_payrolls_f.business_group_id =
                                       per_security_profiles.business_group_id
      And pay_all_payrolls_f.payroll_id = p_payroll_id
      And per_security_profiles.security_profile_id = p_security_profile_id;

Exception
    When no_data_found then
    fnd_message.set_name('PER', 'HR_289801_INVALID_PAYROLL_ID');
    fnd_message.raise_error;

End chk_payroll_id;
--
-- --------------------------------------------------------------------------
-- |-------------------------<chk_security_profile>-------------------------|
-- --------------------------------------------------------------------------
Procedure chk_security_profile
  (p_security_profile_id     in  	per_security_profiles.security_profile_id%type
  ,p_business_group_id       out nocopy per_security_profiles.business_group_id%type)
--
is
--
     e_null_business_group_id  Exception;
     l_proc varchar2(80) := g_package||'chk_security_profile';
--
Begin
    hr_utility.set_location('Entering:'||l_proc, 5);

    --Ensure that the security profile id is not global

    Select business_group_id
    Into  p_business_group_id
    From per_security_profiles
    Where security_profile_id = p_security_profile_id;
    hr_utility.set_location(to_char(p_business_group_id),15);
    If p_business_group_id is null then
    hr_utility.set_location(to_char(p_business_group_id),16);
    Raise  e_null_business_group_id;
    End if;

Exception
    When e_null_business_group_id  then
    fnd_message.set_name ('PER', 'HR_289800_GLOBAL_SEC_PROFILE');
    fnd_message.raise_error;

When no_data_found then
    fnd_message.set_name ('PER', 'HR_289799_INVALID_SEC_PROFILE');
    fnd_message.raise_error;
     hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_security_profile;
--
-- --------------------------------------------------------------------------
-- |-------------------------<chk_for_duplicate>----------------------------|
-- --------------------------------------------------------------------------
--
PROCEDURE chk_for_duplicate
  (p_security_profile_id IN NUMBER
  ,p_payroll_id          IN NUMBER)
IS

  l_proc  VARCHAR2(80) := g_package||'chk_for_duplicate';
  l_dummy NUMBER;

  --
  -- Check that this payroll does not already exist in this security profile.
  --
  CURSOR csr_chk_for_dup IS
  SELECT NULL
  FROM   pay_security_payrolls spr
  WHERE  spr.security_profile_id = p_security_profile_id
  AND    spr.payroll_id = p_payroll_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation when the Multiple Message List
  -- does not already contain an error associated with the
  -- below columns.
  --
  IF hr_multi_message.no_exclusive_error
       (p_check_column1      => pay_spr_shd.g_tab_nam||'.SECURITY_PROFILE_ID'
       ,p_associated_column1 => pay_spr_shd.g_tab_nam||'.SECURITY_PROFILE_ID'
       ,p_check_column2      => pay_spr_shd.g_tab_nam||'.PAYROLL_ID'
       ,p_associated_column2 => pay_spr_shd.g_tab_nam||'.PAYROLL_ID')
  THEN

    hr_utility.set_location(l_proc, 20);

    OPEN  csr_chk_for_dup;
    FETCH csr_chk_for_dup INTO l_dummy;

    IF csr_chk_for_dup%FOUND THEN
      --
      -- This security profile already has this payroll; raise an error.
      --
      hr_utility.set_location(l_proc, 30);
      CLOSE csr_chk_for_dup;
      fnd_message.set_name('PER','PER_7061_DEF_SECPROF_PAY_EXIST');
      fnd_message.raise_error;

    END IF;
    CLOSE csr_chk_for_dup;

    hr_utility.set_location('Leaving:'||l_proc, 40);

  END IF;

EXCEPTION
  --
  -- Multiple Error Detection is enabled so handle the Application Errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple Message List and associate the error with the above columns.
  --
  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
        (p_same_associated_columns => 'Y') THEN

      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      RAISE;

    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);

END chk_for_duplicate;
--
-- --------------------------------------------------------------------------
-- |-------------------------<chk_view_all_payrolls_flag>-------------------|
-- --------------------------------------------------------------------------
--
PROCEDURE chk_view_all_payrolls_flag
  (p_security_profile_id IN NUMBER)
IS

  l_proc   VARCHAR2(80) := g_package||'chk_view_all_payrolls_flag';
  l_view_all_payrolls_flag per_security_profiles.view_all_payrolls_flag%TYPE;

  --
  -- Fetches the view_all_payrolls_flag.
  --
  CURSOR csr_get_view_all_payrolls IS
  SELECT psp.view_all_payrolls_flag
  FROM   per_security_profiles psp
  WHERE  psp.security_profile_id = p_security_profile_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation when the Multiple Message List
  -- does not already contain an error associated with the
  -- below columns.
  --
  IF hr_multi_message.no_exclusive_error
       (p_check_column1      => pay_spr_shd.g_tab_nam||'.SECURITY_PROFILE_ID'
       ,p_associated_column1 => pay_spr_shd.g_tab_nam||'.SECURITY_PROFILE_ID')
  THEN

    hr_utility.set_location(l_proc, 20);

    OPEN  csr_get_view_all_payrolls;
    FETCH csr_get_view_all_payrolls INTO l_view_all_payrolls_flag;
    CLOSE csr_get_view_all_payrolls;

    IF l_view_all_payrolls_flag <> 'N' THEN
      --
      -- Payrolls cannot be added for this profile because it is set to
      -- "View All Payrolls."
      --
      hr_utility.set_location(l_proc, 30);
      fnd_message.set_name('PER','HR_289830_SPR_VIEW_ALL_PAY_SET');
      fnd_message.raise_error;

    END IF;

    hr_utility.set_location('Leaving:'||l_proc, 40);

  END IF;

EXCEPTION
  --
  -- Multiple Error Detection is enabled so handle the Application Errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple Message List and associate the error with the above columns.
  --
  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
        (p_same_associated_columns => 'Y') THEN

      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      RAISE;

    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);

END chk_view_all_payrolls_flag;
--
-- --------------------------------------------------------------------------
-- |-------------------------<set_view_all_payrolls_flag>-------------------|
-- --------------------------------------------------------------------------
--
PROCEDURE set_view_all_payrolls_flag
  (p_security_profile_id IN NUMBER)
IS

  l_proc   VARCHAR2(80) := g_package||'set_view_all_payrolls_flag';
  l_dummy  NUMBER;

  --
  -- Fetches the security payrolls.
  --
  CURSOR csr_get_security_payrolls IS
  SELECT NULL
  FROM   pay_security_payrolls spr
  WHERE  spr.security_profile_id = p_security_profile_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  OPEN  csr_get_security_payrolls;
  FETCH csr_get_security_payrolls INTO l_dummy;

  IF csr_get_security_payrolls%NOTFOUND THEN
    --
    -- Update the view all payrolls flag on the Security Profile.
    --
    hr_utility.set_location(l_proc, 30);

    UPDATE per_security_profiles
    SET    view_all_payrolls_flag = 'Y'
    WHERE  security_profile_id = p_security_profile_id;

  END IF;

  CLOSE csr_get_security_payrolls;

  hr_utility.set_location('Leaving:'||l_proc, 40);

END set_view_all_payrolls_flag;
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
  ,p_rec in pay_spr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_spr_shd.api_updating
      (p_security_profile_id               => p_rec.security_profile_id
      ,p_payroll_id                        => p_rec.payroll_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_spr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_spr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Dependent Attributes.
  -- First check for a duplicate payroll in this security profile.
  --
  chk_for_duplicate
    (p_security_profile_id        => p_rec.security_profile_id
    ,p_payroll_id                 => p_rec.payroll_id);

  --
  -- Check that the view all payrolls flag is correct.
  --
  chk_view_all_payrolls_flag
    (p_security_profile_id        => p_rec.security_profile_id);

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_spr_shd.g_rec_type
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
--
end pay_spr_bus;

/
