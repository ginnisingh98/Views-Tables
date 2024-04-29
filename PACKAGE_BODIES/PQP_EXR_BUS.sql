--------------------------------------------------------
--  DDL for Package Body PQP_EXR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXR_BUS" as
/* $Header: pqexrrhi.pkb 120.4 2006/10/20 18:38:32 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_exr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150) default null  ;
g_exception_report_id         number        default null ;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_exception_report_id                  in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqp_exception_reports exr
     where exr.exception_report_id = p_exception_report_id
       and pbg.business_group_id = exr.business_group_id;
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
    ,p_argument           => 'exception_report_id'
    ,p_argument_value     => p_exception_report_id
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
    IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
                =>'EXCEPTION_REPORT_ID' );

     fnd_message.raise_error;
    END IF;
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
  (p_business_group_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
     where  pbg.business_group_id  = p_business_group_id;
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
  --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    if pqp_exr_bus.g_legislation_code IS NOT NULL THEN
    l_legislation_code := pqp_exr_bus.g_legislation_code;
    end if;
    hr_utility.set_location(l_proc, 20);
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
     IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
     END IF;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
   -- pqp_exr_bus.g_exception_report_id         := p_exception_report_id;
    pqp_exr_bus.g_legislation_code  := l_legislation_code;
 -- end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_exr_legislation_code
  (p_exception_report_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
  select pbg.legislation_code
        ,exr.legislation_code
    from per_business_groups   pbg
        ,pqp_exception_reports exr
    where pbg.business_group_id  = exr.business_group_id
      and exr.exception_report_id= p_exception_report_id;
  --
  -- Declare local variables
  --
  l_legislation_code     varchar2(150);
  l_exr_legislation_code varchar2(150);
  l_proc                 varchar2(72)  :=  g_package||'return_exr_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  -- The legislation code has already been found with a previous
  -- call to this function. Just return the value in the global
  -- variable.
  --
  if pqp_exr_bus.g_legislation_code is not null and
     p_exception_report_id = g_exception_report_id then
    l_legislation_code := pqp_exr_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 19);
  else
    hr_utility.set_location(l_proc, 20);
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code,l_exr_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
     IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
     END IF;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    If l_legislation_code is not null then
       pqp_exr_bus.g_exception_report_id := p_exception_report_id;
       pqp_exr_bus.g_legislation_code    := l_legislation_code;
    elsif l_exr_legislation_code is not null then
       pqp_exr_bus.g_exception_report_id := p_exception_report_id;
       pqp_exr_bus.g_legislation_code    := l_exr_legislation_code;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_exr_legislation_code;
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
  (p_rec in pqp_exr_shd.g_rec_type
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
  IF NOT pqp_exr_shd.api_updating
      (p_exception_report_id                  => p_rec.exception_report_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
       nvl (pqp_exr_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;

  IF nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
       nvl (pqp_exr_shd.g_old_rec.legislation_code, hr_api.g_varchar2) THEN
     l_argument := 'legislation_code';
     RAISE l_error;
  END IF;

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
  ,p_legislation_subgroup IN varchar2 ) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
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
-- |-------------------------< chk_currency_code >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the currency code matches with
--   the currency code of the Business Group.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   business_group_id
--   currency_code
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_currency_code
  (p_exception_report_id   IN number
  ,p_business_group_id     IN number
  ,p_currency_code         IN varchar2
  ,p_object_version_number IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_currency_code';
  l_api_updating          boolean;
  l_default_currency_code varchar2(15);
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The currency code value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --

  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.currency_code, hr_api.g_varchar2) <>
                               nvl(p_currency_code, hr_api.g_varchar2))) or
       (NOT l_api_updating)) THEN

    --
    -- Get currency code information
    --

    IF p_currency_code is not null THEN

      hr_utility.set_location(l_proc, 20);

      l_default_currency_code := hr_general.default_currency_code
                                   (p_business_group_id => p_business_group_id);


      IF p_currency_code <> l_default_currency_code THEN

         -- Raise error as the input currency code is not equal
         -- to the default currency for the BG

         fnd_message.set_name('PQP','PQP_230520_CUR_CODE_MISMATCH'  );
         fnd_message.raise_error;
         --hr_utility.set_message(8303,'PQP_230520_CUR_CODE_MISMATCH'  );
         --hr_utility.raise_error;

      END IF; -- end if of currency code check ...
      --

   END IF; -- End if of currency code not null check ...
   --

  END IF; -- end if of api updating check ...
  --

  hr_utility.set_location(' Leaving:' || l_proc, 30);
  --
END chk_currency_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_balance_type_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the balance_type_id should be for
--   that BG and Leg code is null or Leg code and BG is null
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   business_group_id
--   legislation_id
--   balance_type_id
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_balance_type_id
  (p_exception_report_id   IN number
  ,p_business_group_id     IN number
  ,p_legislation_code      IN varchar2
  ,p_balance_type_id       IN number
  ,p_object_version_number IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_balance_type_id';
  l_api_updating          boolean;
  l_exists                varchar2(1);
  l_legislation_code      per_business_groups.legislation_code%TYPE;

  cursor csr_bal_type
  is
  select 'X'
    from pay_balance_types
  where balance_type_id = p_balance_type_id
    and ( (legislation_code is not null
                            and legislation_code = l_legislation_code)
                   or (business_group_id is not null
                            and business_group_id = p_business_group_id));
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The balance type id value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --

  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.balance_type_id, hr_api.g_number) <>
                               nvl(p_balance_type_id, hr_api.g_number))) or
       (NOT l_api_updating)) THEN

    --
    -- Check whether the balance type id exists within the BG or Leg Code
    --
    IF p_legislation_code is NULL THEN
     l_legislation_code:=pqp_exr_bus.return_legislation_code(p_business_group_id);
    ELSE
     l_legislation_code:=p_legislation_code;
    END IF;

    IF p_balance_type_id is not null THEN

      hr_utility.set_location(l_proc, 20);

      open csr_bal_type;
      fetch csr_bal_type into l_exists;

      IF csr_bal_type%NOTFOUND THEN

         -- Raise an error

         fnd_message.set_name('PQP','PQP_230549_BAL_TYPE_NOT_FOUND'  );
         fnd_message.raise_error;
        -- hr_utility.set_message(8303,'PQP_230549_BAL_TYPE_NOT_FOUND'  );
         --hr_utility.raise_error;

      END IF; -- end if of balance type id check ...
      close csr_bal_type;
      --

   END IF; -- End if of balance type id not null check ...
   --

  END IF; -- end if of api updating check ...
  --

  hr_utility.set_location(' Leaving:' || l_proc, 30);
  --
END chk_balance_type_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_bal_dim_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the balance dimension id should
--   be of the balance type id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   balance_type_id
--   balance_dimension_id
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_bal_dim_id
  (p_exception_report_id   IN number
  ,p_balance_type_id       IN number
  ,p_balance_dimension_id  IN number
  ,p_object_version_number IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_bal_dim_id';
  l_api_updating          boolean;
  l_exists                varchar2(1);

  cursor csr_bal_dim
  is
  select 'X'
    from pay_defined_balances
  where balance_type_id      = p_balance_type_id
    and balance_dimension_id = p_balance_dimension_id;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The balance dimension id value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --

  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.balance_dimension_id, hr_api.g_number) <>
                               nvl(p_balance_dimension_id, hr_api.g_number))) or
       (NOT l_api_updating)) THEN

    --
    -- Check whether this balance dimension id exists for this balance type id
    --

    IF p_balance_dimension_id is not null THEN

      hr_utility.set_location(l_proc, 20);

      open csr_bal_dim;
      fetch csr_bal_dim into l_exists;

      IF csr_bal_dim%NOTFOUND THEN

         -- Raise an error

         fnd_message.set_name('PQP','PQP_230550_BAL_DIM_NOT_FOUND'  );
         fnd_message.raise_error;
         --hr_utility.set_message(8303,'PQP_230550_BAL_DIM_NOT_FOUND'  );
         --hr_utility.raise_error;

      END IF; -- end if of balance dimension check...
      --

   END IF; -- End if of balance dimension id check ...
   --

  END IF; -- end if of api updating check ...
  --

  hr_utility.set_location(' Leaving:' || l_proc, 30);
  --
END chk_bal_dim_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_variance_type >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the variance_type can only be
--   'A' or 'P'
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   variance_type
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_variance_type
  (p_exception_report_id   IN number
  ,p_variance_type         IN varchar2
  ,p_comparison_type       IN varchar2
  ,p_object_version_number IN number

  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_variance_type';
  l_api_updating          boolean;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The variance type value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --

  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.variance_type, hr_api.g_varchar2) <>
                               nvl(p_variance_type, hr_api.g_varchar2))) or
       (NOT l_api_updating)) THEN

    IF p_variance_type is not null THEN

       --
       -- Check whether the variance type value is 'A' or 'P'
       --

       IF p_variance_type NOT IN ('A', 'P') THEN

          -- Raise error as the variance type is not 'A' or 'P'

          fnd_message.set_name('PQP','PQP_230551_VARIANCE_MISMATCH'  );
          fnd_message.raise_error;
         -- hr_utility.set_message(8303,'PQP_230551_VARIANCE_MISMATCH'  );
         -- hr_utility.raise_error;

      END IF; -- end if of variance type check ...
      --

    END IF; -- End if of variance type not null check ...
    --

  END IF; -- end if of api updating check ...
  --
  --added by pjavaji
  IF p_comparison_type ='PC' AND p_variance_type='P' THEN
          fnd_message.set_name('PQP','PQP_230583_INVALID_VAR_TYPE'  );
          fnd_message.raise_error;
--       hr_utility.set_message(8303,'PQP_230583_INVALID_VAR_TYPE'  );
--       hr_utility.raise_error;
  END IF;
  --

  hr_utility.set_location(' Leaving:' || l_proc, 20);
  --
END chk_variance_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_output_format >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the output_format should be from the
--   lookup type 'PQP_OUTPUT_FORAMT_TYPES'
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   output_format_type
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_output_format
  (p_exception_report_id   IN number
  ,p_business_group_id     IN number
  ,p_output_format_type    IN varchar2
  ,p_object_version_number IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_output_format';
  l_api_updating          boolean;
  l_effective_date        date;

  cursor csr_eff_date
  is
  select effective_date
    from fnd_sessions
  where session_id = USERENV('sessionid');
  --
BEGIN
  -- Code is changed to validate the existence of
  -- TXT format.
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The output_format type value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --
  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.output_format_type, hr_api.g_varchar2) <>
                               nvl(p_output_format_type, hr_api.g_varchar2))) or
       (NOT l_api_updating)) THEN

    IF p_output_format_type is not null THEN

      hr_utility.set_location(l_proc, 20);

     /* open csr_eff_date;
      fetch csr_eff_date into l_effective_date;
      close csr_eff_date;*/
      --
      /*IF l_effective_date is NULL THEN
         l_effective_date:=TRUNC(sysdate);
      END IF;*/
      --
      hr_utility.set_location(l_proc, 30);

      IF p_business_group_id is not null THEN
       IF p_output_format_type='TXT' THEN
        fnd_message.set_name('PQP','PQP_230444_BACKCOMP_SUPPORT');
        fnd_message.raise_error;
       END IF;
       /* IF hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => 'PQP_OUTPUT_FORMAT_TYPES'
                ,p_lookup_code    => p_output_format_type
                ,p_effective_date => l_effective_date ) THEN

            -- Raise error as the value does not exist as a lookup

            fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
            fnd_message.set_token('COLUMN','output_format_TYPE' );
            fnd_message.set_token('LOOKUP_TYPE', 'PQP_output_format_TYPES'  );
            fnd_message.raise_error;
        END IF; */ -- End if of lookup check ...
        hr_utility.set_location(l_proc, 40);
     /* ELSE
        IF hr_api.not_exists_in_hrstanlookups
                (p_lookup_type    => 'PQP_OUTPUT_FORMAT_TYPES'
                ,p_lookup_code    => p_output_format_type
                ,p_effective_date => l_effective_date ) THEN

              -- Raise error as the value does not exist as a lookup

            fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
            fnd_message.set_token('COLUMN','output_format_TYPE' );
            fnd_message.set_token('LOOKUP_TYPE', 'PQP_OUTPUT_FORMAT_TYPES'  );
            fnd_message.raise_error;

        END IF; */ -- End if of lookup check ...
        hr_utility.set_location(l_proc, 50);
      END IF; -- End if of business group check...
      --
    hr_utility.set_location(l_proc, 60);
    --
    END IF; --  p_output_format_type is not null check...
    --
  END IF; -- end if of api updating check ...
  --
  hr_utility.set_location(' Leaving:' || l_proc, 70);
  --
END chk_output_format;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_variance_value >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}

--
-- Description:
--   This procedure is used to ensure that the variance_value cannot
--   exceed 100 if variance type is 'P'
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   variance type
--   variance_value
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_variance_value
  (p_exception_report_id   IN number
  ,p_variance_type         IN varchar2
  ,p_variance_value        IN varchar2
  ,p_object_version_number IN number
  ) IS
--
--
  l_proc                  varchar2(72) := g_package||'chk_variance_value';
  l_api_updating          boolean;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The variance type is 'P'
  -- b) The g_old_rec is current and
  -- c) The variance value has changed
  --

  IF p_variance_type = 'P' and
     p_variance_value is not null THEN
      l_api_updating := pqp_exr_shd.api_updating
      (p_exception_report_id   => p_exception_report_id
     ,p_object_version_number => p_object_version_number);

    --

 /*  IF ((l_api_updating
    and (nvl(pqp_exr_shd.g_old_rec.variance_value, hr_api.g_number) <> nvl(p_variance_value, hr_api.g_number)))
    OR (NOT l_api_updating))
        THEN   */ -- commented by pjavaji

       --
       -- Check whether the variance value is greater than 100
       --
      IF p_variance_value > 100 THEN

          --Raise error as the variance value exceeded 100

          fnd_message.set_name('PQP','PQP_230552_VARIANCE_VALUE_MORE'  );
          fnd_message.raise_error;
          --hr_utility.set_message(8303,'PQP_230552_VARIANCE_VALUE_MORE'  );
          --hr_utility.raise_error;

       END IF; -- end if of variance value check ...
      --
   --END IF; -- end if of api updating check ...
    --
  END IF; -- end if of variance_type check ...
  --

  hr_utility.set_location(' Leaving:' || l_proc, 20);
  --
END chk_variance_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_comparison_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the comparison type should be from
--   the look up type 'PQP_COMPARISON_TYPE'.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   comparison_type
--   object_version_number
--   balance_dimension_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_comparison_type
  (p_exception_report_id   IN number
  ,p_business_group_id     IN number
  ,p_comparison_type       IN varchar2
  ,p_object_version_number IN number
  ,p_balance_dimension_id  IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_comparison_type';
  l_api_updating          boolean;
  l_effective_date        date;

  cursor csr_eff_date
  is
  select effective_date
    from fnd_sessions
  where session_id = USERENV('sessionid');
  --
  CURSOR c_dim_suffix IS
  SELECT decode(pers.exception_report_period
               ,'YEAR'   ,'Y'
               ,'QUARTER','Q'
               ,'PERIOD' ,'P'
               ,'MONTH'  ,'M','INCEPTION','I','X') db_suffix
  FROM   pay_balance_dimensions pbd
        ,pqp_exception_report_suffix pers
  WHERE  pbd.balance_dimension_id = p_balance_dimension_id
    and  pers.legislation_code = pbd.legislation_code
    and  pers.database_item_suffix = pbd.database_item_suffix;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The comparison type value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --
  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.comparison_type, hr_api.g_varchar2) <>
                               nvl(p_comparison_type, hr_api.g_varchar2))) or
       (NOT l_api_updating)) THEN

    IF p_comparison_type is not null THEN

      hr_utility.set_location(l_proc, 20);

      open csr_eff_date;
      fetch csr_eff_date into l_effective_date;
      close csr_eff_date;
      --
      IF l_effective_date is NULL THEN
         l_effective_date:=TRUNC(sysdate);
      END IF;
      --
      hr_utility.set_location(l_proc, 30);

      IF p_business_group_id is not null THEN
        IF hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => 'PQP_COMPARISON_TYPE'
                ,p_lookup_code    => p_comparison_type
                ,p_effective_date => l_effective_date ) THEN

            -- Raise error as the value does not exist as a lookup

            fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
            fnd_message.set_token('COLUMN','COMPARISON_TYPE' );
            fnd_message.set_token('LOOKUP_TYPE', 'PQP_COMPARISON_TYPE'  );
            fnd_message.raise_error;
        END IF; -- End if of lookup check ...
        hr_utility.set_location(l_proc, 40);
      ELSE
        IF hr_api.not_exists_in_hrstanlookups
                (p_lookup_type    => 'PQP_COMPARISON_TYPE'
                ,p_lookup_code    => p_comparison_type
                ,p_effective_date => l_effective_date ) THEN

              -- Raise error as the value does not exist as a lookup

            fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
            fnd_message.set_token('COLUMN','COMPARISON_TYPE' );
            fnd_message.set_token('LOOKUP_TYPE', 'PQP_COMPARISON_TYPE'  );
            fnd_message.raise_error;

        END IF; -- End if of lookup check ...
        hr_utility.set_location(l_proc, 50);
      END IF; -- End if of business group check...
      --
    hr_utility.set_location(l_proc, 60);
    --
    END IF; --  End if of comparison type not null check...
    --
  END IF; -- end if of api updating check ...
  --
  -- added by skutteti to validate the combination of comparison type
  -- and balance dimension
  --
  FOR c_rec IN c_dim_suffix LOOP
     IF upper(c_rec.db_suffix) <> upper(substr(p_comparison_type,1,1)) THEN
        fnd_message.set_name('PQP','PQP_230567_DIM_COM_TYP_INVALID');
        fnd_message.raise_error;
        --hr_utility.set_message(8303,'PQP_230567_DIM_COM_TYP_INVALID');
        --hr_utility.raise_error;
     END IF;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:' || l_proc, 70);
  --
END chk_comparison_type;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_variance_operator >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the variance_operator type should be from
--   the look up type 'PQP_variance_operator_TYPES'.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   variance_operator
--   object_version_number
--   balance_dimension_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_variance_operator
  (p_exception_report_id   IN number
  ,p_business_group_id     IN number
  ,p_variance_operator             IN varchar2
  ,p_object_version_number IN number
  ,p_balance_dimension_id  IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_variance_operator';
  l_api_updating          boolean;
  l_effective_date        date;

  cursor csr_eff_date
  is
  select effective_date
    from fnd_sessions
  where session_id = USERENV('sessionid');
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The variance_operator type value has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --
  IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.variance_operator, hr_api.g_varchar2) <>
                               nvl(p_variance_operator, hr_api.g_varchar2))) or
       (NOT l_api_updating)) THEN

    IF p_variance_operator is not null THEN

      hr_utility.set_location(l_proc, 20);

      open csr_eff_date;
      fetch csr_eff_date into l_effective_date;
      close csr_eff_date;
      --
      IF l_effective_date is NULL THEN
         l_effective_date:=TRUNC(sysdate);
      END IF;
      --
      hr_utility.set_location(l_proc, 30);

      IF p_business_group_id is not null THEN
        IF hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => 'PQP_VARIANCE_OPERATOR_TYPES'
                ,p_lookup_code    => p_variance_operator
                ,p_effective_date => l_effective_date ) THEN

            -- Raise error as the value does not exist as a lookup

            fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
            fnd_message.set_token('COLUMN','variance_operator_TYPE' );
            fnd_message.set_token('LOOKUP_TYPE', 'PQP_VARIANCE_OPERATOR_TYPES'  );
            fnd_message.raise_error;
        END IF; -- End if of lookup check ...
        hr_utility.set_location(l_proc, 40);
      ELSE
        IF hr_api.not_exists_in_hrstanlookups
                (p_lookup_type    => 'PQP_VARIANCE_OPERATOR_TYPES'
                ,p_lookup_code    => p_variance_operator
                ,p_effective_date => l_effective_date ) THEN

              -- Raise error as the value does not exist as a lookup

            fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
            fnd_message.set_token('COLUMN','variance_operator_TYPE' );
            fnd_message.set_token('LOOKUP_TYPE', 'PQP_VARIANCE_OPERATOR_TYPES'  );
            fnd_message.raise_error;

        END IF; -- End if of lookup check ...
        hr_utility.set_location(l_proc, 50);
      END IF; -- End if of business group check...
      --
    hr_utility.set_location(l_proc, 60);
    --
    END IF; --  End if of variance_operator not null check...
    --
  END IF; -- end if of api updating check ...
  --
  hr_utility.set_location(' Leaving:' || l_proc, 70);
  --
END chk_variance_operator;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_comparison_value >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the comparison value has a value
--   one if the second characterof comparion type is 'P'
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   comparison_type
--   comparison_value
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_comparison_value
  (p_exception_report_id   IN number
  ,p_comparison_type       IN varchar2
  ,p_comparison_value      IN number
  ,p_object_version_number IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_comparison_value';
  l_api_updating          boolean;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The second character of comparison_type is 'P'
  -- b) The g_old_rec is current and
  -- c) The comparison value has changed
  --

  IF substr(p_comparison_type,2,1) = 'P' THEN

    l_api_updating := pqp_exr_shd.api_updating
      (p_exception_report_id   => p_exception_report_id
      ,p_object_version_number => p_object_version_number);

    --
    IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.comparison_value, hr_api.g_number) <>
                                 nvl(p_comparison_value, hr_api.g_number))) or
         (NOT l_api_updating)) THEN


      IF nvl(p_comparison_value, hr_api.g_number) <> 1 THEN

         -- Raise error as the input comparison value is not equal
         -- to one

         fnd_message.set_name('PQP','PQP_230553_COMPARISON_VAL_QUAL'  );
         fnd_message.raise_error;
         --hr_utility.set_message(8303,'PQP_230553_COMPARISON_VAL_QUAL'  );
         --hr_utility.raise_error;

      END IF; -- end if of comparison value check ...
      --

    END IF; -- end if of api updating check ...
    --

  END IF; -- End if of comparison type check ...
  --
--Added by sshetty
  IF substr(p_comparison_type,2,1) = 'C' THEN

    l_api_updating := pqp_exr_shd.api_updating
      (p_exception_report_id   => p_exception_report_id
      ,p_object_version_number => p_object_version_number);

    --
    IF ((l_api_updating and (nvl(pqp_exr_shd.g_old_rec.comparison_value, hr_api.g_number) <>
                                 nvl(p_comparison_value, hr_api.g_number))) or
         (NOT l_api_updating)) THEN


      IF nvl(p_comparison_value, hr_api.g_number) <> 0 THEN

         -- Raise error as the input comparison value is not equal
         -- to one

         fnd_message.set_name('PQP','PQP_230553_COMPARISON_VAL_QUAL'  );
         fnd_message.raise_error;
         --hr_utility.set_message(8303,'PQP_230553_COMPARISON_VAL_QUAL'  );
         --hr_utility.raise_error;

      END IF; -- end if of comparison value check ...
      --

    END IF; -- end if of api updating check ...
    --

  END IF; -- End if of comparison type check ...
  hr_utility.set_location(' Leaving:' || l_proc, 30);
  --
END chk_comparison_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_report_name >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the exception report name is unique
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--   business_group_id
--   legislation_code
--   exception_report_name
--   object_version_number
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_report_name
  (p_exception_report_id   IN number
  ,p_business_group_id     IN number
  ,p_legislation_code      IN varchar2
  ,p_exception_report_name IN varchar2
  ,p_object_version_number IN number
  ) IS
--
  l_proc                  varchar2(72) := g_package||'chk_report_name';
  l_exists                varchar2(1);
  l_api_updating          boolean;
  l_legislation_code      per_business_groups.legislation_code%TYPE;

  cursor csr_report_name
  is
  select 'X'
    from pqp_exception_reports
  where exception_report_name = p_exception_report_name
    and( (legislation_code is not null
                            and legislation_code = l_legislation_code)
                      or (business_group_id is not null
                            and business_group_id = p_business_group_id)
                    );
--
BEGIN
 IF p_legislation_code is NULL THEN
  l_legislation_code:=pqp_exr_bus.return_legislation_code(p_business_group_id);
 ELSE
  l_legislation_code:=p_legislation_code;
 END IF;

  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

  -- Check manadatory arg

    hr_api.mandatory_arg_error
     (p_api_name        => l_proc
     ,p_argument        => 'exception_report_name'
     ,p_argument_value  => p_exception_report_name
     );

  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The report name has changed
  --

  l_api_updating := pqp_exr_shd.api_updating
    (p_exception_report_id   => p_exception_report_id
    ,p_object_version_number => p_object_version_number);

  --
  IF ((l_api_updating and (pqp_exr_shd.g_old_rec.exception_report_name) <>
                               (p_exception_report_name)) or
       (NOT l_api_updating)) THEN

    --
    -- Check whether a row exists already in pqp_exception_reports
    -- with this exception_report_name
    --

    hr_utility.set_location(l_proc, 20);

    open csr_report_name;
    fetch csr_report_name into l_exists;

    IF csr_report_name%FOUND THEN

       -- Raise an error

       fnd_message.set_name('PQP','PQP_230554_REPORT_NAME_UNIQUE'  );
       fnd_message.raise_error;
       --hr_utility.set_message(8303,'PQP_230554_REPORT_NAME_UNIQUE'  );
       --hr_utility.raise_error;

    END IF; -- end if of report name check ...
    close csr_report_name;
    --

  END IF; -- end if of api updating check ...
  --

  hr_utility.set_location(' Leaving:' || l_proc, 30);
  --
END chk_report_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_report_grp_exists >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the a row doesn't exist in
--   exception_report_groups table with the same exception_report_id before
--   deleting exception_reports
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   exception_report_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated
--
-- Access Status :
--   Internal Table Handler Use only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_report_grp_exists
  (p_exception_report_id   IN number
  ) IS
--
  l_proc    varchar2(72) := g_package||'chk_report_grp_exists';
  l_exists  varchar2(1);

  cursor csr_rep_grp
  is
  select 'X'
    from pqp_exception_report_groups
  where exception_report_id = p_exception_report_id;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

  open csr_rep_grp;
  fetch csr_rep_grp into l_exists;

  IF csr_rep_grp%FOUND THEN

     -- Raise error

     fnd_message.set_name('PQP','PQP_230555_CHILD_REPORT_GRP'  );
     fnd_message.raise_error;
     --hr_utility.set_message(8303,'PQP_230555_CHILD_REPORT_GRP'  );
     --hr_utility.raise_error;

  END IF; -- end if of report group row check...
  --

  hr_utility.set_location(' Leaving:' || l_proc, 20);
  --
END chk_report_grp_exists;
--
--This procedure is introduced when a bug was detected
--while deleteing the seeded report which was throwing
--core message.

Procedure chk_del_seed_report ( p_rec  in pqp_exr_shd.g_rec_type)
IS

BEGIN

 IF p_rec.business_group_id IS NULL THEN

     fnd_message.set_name('PQP','PQP_230919_SEED_DEL_CHK'  );
     fnd_message.raise_error;

 END IF;

END;


Procedure chk_upd_seed_report ( p_rec  in pqp_exr_shd.g_rec_type)
IS

BEGIN
 IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
  IF p_rec.business_group_id IS NULL THEN

     fnd_message.set_name('PQP','PQP_230584_SEED_UPD_CHK'  );
     fnd_message.raise_error;

  END IF;
 END IF;

END;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pqp_exr_shd.g_rec_type
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

  chk_startup_action(p_insert                =>true
                    ,p_business_group_id     =>p_rec.business_group_id
                    ,p_legislation_code      =>p_rec.legislation_code
                    ,p_legislation_subgroup  =>NULL
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;

  --
  -- Check currency code
  --

  hr_utility.set_location('Entering:'||l_proc, 10);
   chk_output_format
  (p_exception_report_id   => p_rec.exception_report_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_output_format_type    => p_rec.output_format_type
  ,p_object_version_number => p_rec.object_version_number
  );






  hr_utility.set_location(l_proc, 20);

  chk_currency_code (p_exception_report_id   => p_rec.exception_report_id
                  ,p_business_group_id     => p_rec.business_group_id
                  ,p_currency_code         => p_rec.currency_code
                  ,p_object_version_number => p_rec.object_version_number
                  );
  --

  -- Check balance type id
  --

  hr_utility.set_location(l_proc, 30);

  chk_balance_type_id (p_exception_report_id   => p_rec.exception_report_id
                      ,p_business_group_id     => p_rec.business_group_id
                      ,p_legislation_code      => p_rec.legislation_code
                      ,p_balance_type_id       => p_rec.balance_type_id
                      ,p_object_version_number => p_rec.object_version_number
                      );

  --
  -- Check balance dimension id
  --

  hr_utility.set_location(l_proc, 40);

  chk_bal_dim_id (p_exception_report_id   => p_rec.exception_report_id
                 ,p_balance_type_id       => p_rec.balance_type_id
                 ,p_balance_dimension_id  => p_rec.balance_dimension_id
                 ,p_object_version_number => p_rec.object_version_number
                 );

  --
  -- Check variance type
  --

  hr_utility.set_location(l_proc, 50);

  chk_variance_type (p_exception_report_id   => p_rec.exception_report_id
                    ,p_variance_type         => p_rec.variance_type
                    ,p_comparison_type       => p_rec.comparison_type
                    ,p_object_version_number => p_rec.object_version_number
                    );

  --
  -- Check variance value
  --

  hr_utility.set_location(l_proc, 60);

  chk_variance_value (p_exception_report_id   => p_rec.exception_report_id
                     ,p_variance_type         => p_rec.variance_type
                     ,p_variance_value        => p_rec.variance_value
                     ,p_object_version_number => p_rec.object_version_number
                     );

  --
  -- Check comparison type
  --

  hr_utility.set_location(l_proc, 70);

  chk_comparison_type (p_exception_report_id   => p_rec.exception_report_id
                      ,p_business_group_id     => p_rec.business_group_id
                      ,p_comparison_type       => p_rec.comparison_type
                      ,p_object_version_number => p_rec.object_version_number
                      ,p_balance_dimension_id  => p_rec.balance_dimension_id
                      );

  --
  -- Check comparison value
  --

  hr_utility.set_location(l_proc, 80);

  chk_comparison_value (p_exception_report_id   => p_rec.exception_report_id
                       ,p_comparison_type       => p_rec.comparison_type
                       ,p_comparison_value      => p_rec.comparison_value
                       ,p_object_version_number => p_rec.object_version_number
                       );

  --
  -- Check report name
  --

  hr_utility.set_location(l_proc, 90);

  chk_report_name (p_exception_report_id   => p_rec.exception_report_id
                  ,p_business_group_id     => p_rec.business_group_id
                  ,p_legislation_code      => p_rec.legislation_code
                  ,p_exception_report_name => p_rec.exception_report_name
                  ,p_object_version_number => p_rec.object_version_number
                  );

  --
  --
EXCEPTION
  WHEN app_exception.application_exception THEN
  -- IF hr_multi_message.exception_add
   --      (p_same_associated_columns => 'Y') THEN
      RAISE;
  --END IF;
  -- After validating the set of important attributes
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  hr_multi_message.end_validation_set;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqp_exr_shd.g_rec_type
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
 IF p_rec.business_group_id IS NOT NULL THEN
  chk_startup_action(p_insert              =>false
                    ,p_business_group_id   =>p_rec.business_group_id
                    ,p_legislation_code    =>p_rec.legislation_code
                    ,p_legislation_subgroup=>NULL
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
 END IF;


 chk_upd_seed_report ( p_rec=>p_rec );
  --

  hr_multi_message.end_validation_set;
  chk_non_updateable_args (
      p_rec              => p_rec
    );
  --

  hr_multi_message.end_validation_set;
  --
  -- Check currency code
  --

  hr_utility.set_location(l_proc, 10);
   chk_output_format
  (p_exception_report_id   => p_rec.exception_report_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_output_format_type    => p_rec.output_format_type
  ,p_object_version_number => p_rec.object_version_number
  );


  hr_utility.set_location(l_proc, 20);



  chk_currency_code (p_exception_report_id   => p_rec.exception_report_id
                    ,p_business_group_id     => p_rec.business_group_id
                    ,p_currency_code         => p_rec.currency_code
                    ,p_object_version_number => p_rec.object_version_number
                    );

  --
  -- Check balance type id
  --

  hr_utility.set_location(l_proc, 30);

  chk_balance_type_id (p_exception_report_id   => p_rec.exception_report_id
                      ,p_business_group_id     => p_rec.business_group_id
                      ,p_legislation_code      => p_rec.legislation_code
                      ,p_balance_type_id       => p_rec.balance_type_id
                      ,p_object_version_number => p_rec.object_version_number
                      );

  --
  -- Check balance dimension id
  --

  hr_utility.set_location(l_proc, 40);

  chk_bal_dim_id (p_exception_report_id   => p_rec.exception_report_id
                 ,p_balance_type_id       => p_rec.balance_type_id
                 ,p_balance_dimension_id  => p_rec.balance_dimension_id
                 ,p_object_version_number => p_rec.object_version_number
                 );

  --
  -- Check variance type
  --

  hr_utility.set_location(l_proc, 50);

  chk_variance_type (p_exception_report_id   => p_rec.exception_report_id
                    ,p_variance_type         => p_rec.variance_type
                    ,p_comparison_type       => p_rec.comparison_type
                    ,p_object_version_number => p_rec.object_version_number
                    );

  --
  -- Check variance value
  --

  hr_utility.set_location(l_proc, 60);

  chk_variance_value (p_exception_report_id   => p_rec.exception_report_id
                     ,p_variance_type         => p_rec.variance_type
                     ,p_variance_value        => p_rec.variance_value
                     ,p_object_version_number => p_rec.object_version_number
                     );

  --
  -- Check comparison type
  --

  hr_utility.set_location(l_proc, 70);

  chk_comparison_type (p_exception_report_id   => p_rec.exception_report_id
                      ,p_business_group_id     => p_rec.business_group_id
                      ,p_comparison_type       => p_rec.comparison_type
                      ,p_object_version_number => p_rec.object_version_number
                      ,p_balance_dimension_id  => p_rec.balance_dimension_id
                      );

  --
  -- Check comparison value
  --

  hr_utility.set_location(l_proc, 80);

  chk_comparison_value (p_exception_report_id   => p_rec.exception_report_id
                       ,p_comparison_type       => p_rec.comparison_type
                       ,p_comparison_value      => p_rec.comparison_value
                       ,p_object_version_number => p_rec.object_version_number
                       );

  --
  -- Check report name
  --

  hr_utility.set_location(l_proc, 90);

  chk_report_name (p_exception_report_id   => p_rec.exception_report_id
                  ,p_business_group_id     => p_rec.business_group_id
                  ,p_legislation_code      => p_rec.legislation_code
                  ,p_exception_report_name => p_rec.exception_report_name
                  ,p_object_version_number => p_rec.object_version_number
                  );


  --
EXCEPTION
  WHEN app_exception.application_exception THEN
   --IF hr_multi_message.exception_add
  --      (
   --       p_same_associated_columns => 'Y'
    --    )
    --THEN
      RAISE;
   --END IF;
--
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  hr_utility.set_location(' Leaving:'||l_proc, 100);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
 IF pqp_exr_shd.g_old_rec.business_group_id IS NOT NULL THEN
  chk_startup_action(p_insert               =>false
                    ,p_business_group_id    =>pqp_exr_shd.g_old_rec.business_group_id
                    ,p_legislation_code     =>pqp_exr_shd.g_old_rec.legislation_code
                    ,p_legislation_subgroup =>NULL
                    );
 END IF;

  --
  -- Call all supporting business operations
  --

  --
  -- Check whether exception record group exists for this report id
  --
  chk_del_seed_report ( p_rec=>pqp_exr_shd.g_old_rec);
  hr_multi_message.end_validation_set;
  hr_utility.set_location(l_proc, 10);
  chk_report_grp_exists(p_exception_report_id => p_rec.exception_report_id);
Exception
  when app_exception.application_exception then
  -- IF hr_multi_message.exception_add
   --      (p_same_associated_columns => 'Y')
   -- THEN
      RAISE;
 -- END IF;
  -- After validating the set of important attributes
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  hr_multi_message.end_validation_set;

  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end pqp_exr_bus;

/
