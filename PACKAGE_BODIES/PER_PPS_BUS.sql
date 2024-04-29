--------------------------------------------------------
--  DDL for Package Body PER_PPS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PPS_BUS" as
/* $Header: peppsrhi.pkb 120.0 2005/05/31 15:03:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pps_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_parent_spine_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_parent_spine_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_parent_spines pps
     where pps.parent_spine_id = p_parent_spine_id
       and pbg.business_group_id = pps.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'parent_spine_id'
    ,p_argument_value     => p_parent_spine_id
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
        => nvl(p_associated_column1,'PARENT_SPINE_ID')
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
  (p_parent_spine_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_parent_spines pps
     where pps.parent_spine_id = p_parent_spine_id
       and pbg.business_group_id = pps.business_group_id;
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
    ,p_argument           => 'parent_spine_id'
    ,p_argument_value     => p_parent_spine_id
    );
  --
  if ( nvl(per_pps_bus.g_parent_spine_id, hr_api.g_number)
       = p_parent_spine_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pps_bus.g_legislation_code;
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
    per_pps_bus.g_parent_spine_id             := p_parent_spine_id;
    per_pps_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_parent_spine_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   parent_spine_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--   inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_parent_spine_id
 ( p_parent_spine_id       in     per_parent_spines.parent_spine_id%TYPE
  ,p_object_version_number in     per_parent_spines.object_version_number%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_parent_spine_id';
  l_api_updating boolean;
  --
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_pps_shd.api_updating
    (p_parent_spine_id              => p_parent_spine_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_parent_spine_id,hr_api.g_number)
     <>  per_pps_shd.g_old_rec.parent_spine_id) then
    --
    -- raise error as PK has changed
    --
    per_pps_shd.constraint_error('PER_PARENT_SPINES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_parent_spine_id is not null then
      --
      -- raise error as PK is not null
      --
      per_pps_shd.constraint_error('PER_PARENT_SPINES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_parent_spine_id;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_name >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name is mandatory and
--   unique within a business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_parent_spine_id
--   p_name
--   p_business_group_id
--   p_object_version_number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name(
     p_parent_spine_id          in per_parent_spines.parent_spine_id%TYPE
    ,p_name                     in per_parent_spines.name%TYPE
    ,p_business_group_id        in per_parent_spines.business_group_id%TYPE
    ,p_object_version_number    in per_parent_spines.object_version_number%TYPE
   ) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
--
cursor csr_unique_name is
  select 'x'
    from per_parent_spines
    where p_name is not null
    and upper(name)   = upper(p_name)
    and business_group_id + 0 = p_business_group_id
    -- Start of 3312706
    and (p_parent_spine_id is not null
    and parent_spine_id <> p_parent_spine_id);
    -- End of 3312706
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'name'
    ,p_argument_value => p_name
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The name value has changed
  --
  l_api_updating := per_pps_shd.api_updating
         (p_parent_spine_id        => p_parent_spine_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and upper(per_pps_shd.g_old_rec.name) <> upper(p_name))
      or (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 20);
    --
    open csr_unique_name;
    fetch csr_unique_name into l_exists;
    if csr_unique_name%found then
      close csr_unique_name;
      hr_utility.set_message(801, 'PER_7920_PAR_SPN_EXISTS');
      hr_utility.raise_error;
    end if;
    close csr_unique_name;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PARENT_SPINES.NAME'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,40);
      raise;
    end if;
  --
End chk_name;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_increment_frequency >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the increment_frequncy is mandatory
--   when increment_period is entered.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_parent_spine_id
--   p_increment_frequency
--   p_increment_period
--   p_object_version_number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_increment_frequency(
  p_parent_spine_id       in per_parent_spines.parent_spine_id%TYPE
 ,p_increment_frequency   in per_parent_spines.increment_frequency%TYPE
 ,p_increment_period      in per_parent_spines.increment_period%TYPE
 ,p_object_version_number in per_parent_spines.object_version_number%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_increment_frequency';
  l_api_updating boolean;
  --
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := per_pps_shd.api_updating
    ( p_parent_spine_id              => p_parent_spine_id
     ,p_object_version_number        => p_object_version_number
    );
  --
  if (l_api_updating
     and nvl(p_increment_frequency,hr_api.g_number)
     <>  per_pps_shd.g_old_rec.increment_frequency) then
    --
    -- Check mandatory parameters have been set
    --
    hr_utility.set_location(l_proc,20);
    if (p_increment_period is not null and p_increment_frequency is null)  then
      hr_utility.set_message(801,'HR_6919_SPINE_ENTER_INC');
      hr_utility.raise_error;
    end if;
  elsif not l_api_updating then
    --
    if p_increment_frequency is null then
      hr_utility.set_location(l_proc,30);
--      p_increment_frequency := 1;
    end if;
    --
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc, 40);
--
end chk_increment_frequency;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_increment_period >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the increment_period is mandatory
--   when increment_frequency is entered. And the value should come from
--   lookups.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_increment_period
--   p_increment_frequency
--   p_effective_date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_increment_period(
  p_increment_period      in per_parent_spines.increment_period%TYPE
 ,p_increment_frequency   in per_parent_spines.increment_frequency%TYPE
 ,p_effective_date        in date
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_increment_period';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  if (p_increment_frequency is not null and p_increment_period is null) then
    hr_utility.set_message(801,'HR_6919_SPINE_ENTER_INC');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if p_increment_period is not null then
      --
      -- Check that the frequency exists in hr_lookups for the lookup
      -- type 'FREQUENCY' with an enabled flag set to 'Y'
      --
      hr_utility.set_location(l_proc, 30);
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'FREQUENCY'
        ,p_lookup_code           => p_increment_period
        )
      then
        --
        hr_utility.set_message(801, 'HR_289564_INVALID_INCR_PERIOD');
        hr_utility.raise_error;
        --
      end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 40);
--
end chk_increment_period;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_last_aut_inc_date >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the last_automatic_increment_date
--   cannot insert.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_last_automatic_increment_dat
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_last_aut_inc_date(
  p_last_automatic_increment_dat in per_parent_spines.last_automatic_increment_date%TYPE
) is
  --
  l_proc         varchar2(72) := g_package||'chk_last_aut_inc_date';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check the parameters is not inserted
  --
  if (p_last_automatic_increment_dat is not null) then
    hr_utility.set_message(800,'HR_289565_ERR_LST_AUT_INC_DATE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
end chk_last_aut_inc_date;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_delete >--------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there are no values in
--   per_spinal_points, per_grade_spines_f and pay_rates
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_parent_spine_id
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_delete(
   p_parent_spine_id         in per_parent_spines.parent_spine_id%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_exists       varchar2(1);
  --
cursor csr_spinal_points is
           select 'x'
           FROM per_spinal_points
           WHERE parent_spine_id = p_parent_spine_id;
--
cursor csr_grade_spines is
           select 'x'
           FROM per_grade_spines_f
           WHERE parent_spine_id = p_parent_spine_id;
--
cursor csr_pay_rates is
           select 'x'
           FROM pay_rates
           WHERE parent_spine_id = p_parent_spine_id;
--
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --  Check there are no values in per_spinal_points, per_grade_spines_f
  --  and pay_rates
  --
  open csr_spinal_points;
  --
  fetch csr_spinal_points into l_exists;
  --
    If csr_spinal_points%found Then
    --
      close csr_spinal_points;
      --
      hr_utility.set_message(801, 'PER_7921_DEL_PAR_SPN_POINT');
      fnd_message.raise_error;
      --
    End If;
  --
  close csr_spinal_points;
  --
  hr_utility.set_location(l_proc, 20);

  --
  --  Check there are no values in per_grade_spines_f
  --
  open csr_grade_spines;
  --
  fetch csr_grade_spines into l_exists;
  --
    If csr_grade_spines%found Then
    --
      close csr_grade_spines;
      --
      hr_utility.set_message(801, 'PER_7922_DEL_PAR_SPN_GRDSPN');
      fnd_message.raise_error;
      --
    End If;
  --
  close csr_grade_spines;
  --
  hr_utility.set_location(l_proc, 30);

  --
  --  Check there are no values in pay_rates
  --
  open csr_pay_rates;
  --
  fetch csr_pay_rates into l_exists;
  --
    If csr_pay_rates%found Then
    --
      close csr_pay_rates;
      --
      hr_utility.set_message(801, 'PER_7923_DEL_PAR_SPN_RATE');
      fnd_message.raise_error;
      --
    End If;
  --
  close csr_pay_rates;
  hr_utility.set_location('Leaving:' || l_proc, 40);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_pps_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.parent_spine_id is not null)  and (
    nvl(per_pps_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.parent_spine_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PARENT_SPINES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_pps_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.parent_spine_id is not null)  and (
    nvl(per_pps_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(per_pps_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2) ))
    or (p_rec.parent_spine_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_utility.set_location('Entering:'||l_proc,20);

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Further Parent Spine DF'
      ,p_attribute_category              => p_rec.INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      ,p_attribute21_name                => 'INFORMATION21'
      ,p_attribute21_value               => p_rec.information21
      ,p_attribute22_name                => 'INFORMATION22'
      ,p_attribute22_value               => p_rec.information22
      ,p_attribute23_name                => 'INFORMATION23'
      ,p_attribute23_value               => p_rec.information23
      ,p_attribute24_name                => 'INFORMATION24'
      ,p_attribute24_value               => p_rec.information24
      ,p_attribute25_name                => 'INFORMATION25'
      ,p_attribute25_value               => p_rec.information25
      ,p_attribute26_name                => 'INFORMATION26'
      ,p_attribute26_value               => p_rec.information26
      ,p_attribute27_name                => 'INFORMATION27'
      ,p_attribute27_value               => p_rec.information27
      ,p_attribute28_name                => 'INFORMATION28'
      ,p_attribute28_value               => p_rec.information28
      ,p_attribute29_name                => 'INFORMATION29'
      ,p_attribute29_value               => p_rec.information29
      ,p_attribute30_name                => 'INFORMATION30'
      ,p_attribute30_value               => p_rec.information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,30);
end chk_ddf;
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
  ,p_rec                          in per_pps_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pps_shd.api_updating
      (p_parent_spine_id                   => p_rec.parent_spine_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_pps_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'BUSINESS_GROUP_ID'
    ,p_base_table => per_pps_shd.g_tab_nam
    );
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
--  ,p_rec                          in out nocopy per_pps_shd.g_rec_type
  ,p_rec                          in per_pps_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 => per_pps_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  --
  -- Validate parent spine id
  --
  chk_parent_spine_id
   (p_parent_spine_id       => p_rec.parent_spine_id
   ,p_object_version_number => p_rec.object_version_number
  );


  hr_utility.set_location(l_proc, 20);

  --
  -- Validate name
  --
  chk_name
   (p_parent_spine_id       => p_rec.parent_spine_id
   ,p_name                  => p_rec.name
   ,p_business_group_id     => p_rec.business_group_id
   ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate increment frequency
  --
  chk_increment_frequency
   (p_parent_spine_id       => p_rec.parent_spine_id
   ,p_increment_frequency   => p_rec.increment_frequency
   ,p_increment_period      => p_rec.increment_period
   ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate increment period
  --
  chk_increment_period
   (p_increment_period      => p_rec.increment_period
   ,p_increment_frequency   => p_rec.increment_frequency
   ,p_effective_date        => p_effective_date
  );

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate last automatic increment date
  --
  chk_last_aut_inc_date
   (p_last_automatic_increment_dat => p_rec.last_automatic_increment_date
  );

  hr_utility.set_location(l_proc, 60);

  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  hr_utility.set_location(l_proc, 70);

  --
  --    Flexfield Validation
  --
  per_pps_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 80);

  --
  --    Developer Descriptive Flexfield Validation
  --
  per_pps_bus.chk_ddf(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 100);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pps_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_pps_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- Validate parent spine id
  --
  chk_parent_spine_id
  (p_parent_spine_id       => p_rec.parent_spine_id
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 20);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate non updatable args
  --
  chk_non_updateable_args
   (p_effective_date   => p_effective_date
   ,p_rec              => p_rec
   );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate name
  --
  chk_name
  (p_parent_spine_id       => p_rec.parent_spine_id
  ,p_name                  => p_rec.name
  ,p_business_group_id     => p_rec.business_group_id
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate increment frequency
  --
  chk_increment_frequency
   (p_parent_spine_id       => p_rec.parent_spine_id
   ,p_increment_frequency   => p_rec.increment_frequency
   ,p_increment_period      => p_rec.increment_period
   ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate increment period
  --
  chk_increment_period
  (p_increment_period      => p_rec.increment_period
  ,p_increment_frequency   => p_rec.increment_frequency
  ,p_effective_date        => p_effective_date
  );

  hr_utility.set_location(l_proc, 60);

  --
  --    Flexfield Validation
  --
  per_pps_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 70);
  --
  --    Developer Descriptive Flexfield Validation
  --
  per_pps_bus.chk_ddf(p_rec);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pps_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Call all supporting business operations
  --
  chk_delete(p_parent_spine_id  => p_rec.parent_spine_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_pps_bus;

/
