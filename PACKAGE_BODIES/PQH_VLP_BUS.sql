--------------------------------------------------------
--  DDL for Package Body PQH_VLP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLP_BUS" as
/* $Header: pqvlprhi.pkb 115.6 2004/03/31 00:31:40 kgowripe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_vlp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_validation_period_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_validation_period_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_fr_validation_periods vlp
         , pqh_fr_validations vld
     where vld.validation_id = vlp.validation_id
         and vlp.validation_period_id = p_validation_period_id
         and pbg.business_group_id = vld.business_group_id;
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
    ,p_argument           => 'validation_period_id'
    ,p_argument_value     => p_validation_period_id
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
        => nvl(p_associated_column1,'VALIDATION_PERIOD_ID')
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
  (p_validation_period_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqh_fr_validation_periods vlp
         , pqh_Fr_validations vld
     where vld.validation_id = vlp.validation_id
         and vlp.validation_period_id = p_validation_period_id
       and pbg.business_group_id = vld.business_group_id;
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
    ,p_argument           => 'validation_period_id'
    ,p_argument_value     => p_validation_period_id
    );
  --
  if ( nvl(pqh_vlp_bus.g_validation_period_id, hr_api.g_number)
       = p_validation_period_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_vlp_bus.g_legislation_code;
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
    pqh_vlp_bus.g_validation_period_id        := p_validation_period_id;
    pqh_vlp_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_vlp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_vlp_shd.api_updating
      (p_validation_period_id              => p_rec.validation_period_id
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
  ,p_rec                          in pqh_vlp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
cnt number;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
pqh_vld_bus.set_security_group_id(p_rec.validation_id, null);
  --
  -- Validate Dependent Attributes
  --
  --
    select count(*) into cnt from pqh_fr_validation_periods
  where previous_employer_id = p_rec.previous_employer_id;
if cnt > 0 then
-- p_rec.start_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and
nvl(p_rec.start_date, hr_general.start_of_time)
between
nvl(start_date, hr_general.start_of_time)
and
nvl(end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
-- for p_rec.end_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and
nvl(p_rec.end_date, hr_general.end_of_time)
between
nvl(start_date, hr_general.start_of_time)
and
nvl(end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
--for start_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and
nvl(start_date, hr_general.start_of_time)
between
nvl(p_rec.start_date, hr_general.start_of_time)
and
nvl(p_rec.end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
-- for end_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and
nvl(end_date, hr_general.end_of_time)
between
nvl(p_rec.start_date, hr_general.start_of_time)
and
nvl(p_rec.end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_vlp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
cnt number;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
pqh_vld_bus.set_security_group_id(p_rec.validation_id, null);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
    select count(*) into cnt from pqh_fr_validation_periods
  where previous_employer_id = p_rec.previous_employer_id
  and validation_period_id <> p_rec.validation_period_id;
if cnt > 0 then
-- p_rec.start_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and validation_period_id <> p_rec.validation_period_id
and
nvl(p_rec.start_date, hr_general.start_of_time)
between
nvl(start_date, hr_general.start_of_time)
and
nvl(end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
-- for p_rec.end_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and validation_period_id <> p_rec.validation_period_id
and
nvl(p_rec.end_date, hr_general.end_of_time)
between
nvl(start_date, hr_general.start_of_time)
and
nvl(end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
--for start_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and validation_period_id <> p_rec.validation_period_id
and
nvl(start_date, hr_general.start_of_time)
between
nvl(p_rec.start_date, hr_general.start_of_time)
and
nvl(p_rec.end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
-- for end_date
select count(*) into cnt from pqh_fr_validation_periods
where previous_employer_id = p_rec.previous_employer_id
and validation_period_id <> p_rec.validation_period_id
and
nvl(end_date, hr_general.end_of_time)
between
nvl(p_rec.start_date, hr_general.start_of_time)
and
nvl(p_rec.end_date, hr_general.end_of_time);

if cnt > 0 then
     fnd_message.set_name('PQH', 'FR_PQH_VALIDATION_OVERLAP');
     fnd_message.raise_error;
end if;
end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_vlp_shd.g_rec_type
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
end pqh_vlp_bus;

/
