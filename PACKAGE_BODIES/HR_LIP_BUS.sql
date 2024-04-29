--------------------------------------------------------
--  DDL for Package Body HR_LIP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LIP_BUS" as
/* $Header: hrliprhi.pkb 115.5 2002/12/04 05:07:14 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_lip_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_organization_link_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_organization_link_id                 in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups      pbg
         , hr_de_organization_links ord
     where ord.organization_link_id = p_organization_link_id
       and pbg.business_group_id    = ord.business_group_id;
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
    ,p_argument           => 'organization_link_id'
    ,p_argument_value     => p_organization_link_id
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
  (p_organization_link_id                 in number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups      pbg
         , hr_de_organization_links ord
     where ord.organization_link_id = p_organization_link_id
       and pbg.business_group_id    = ord.business_group_id;
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
    ,p_argument           => 'organization_link_id'
    ,p_argument_value     => p_organization_link_id
    );
  --
  if ( nvl(hr_lip_bus.g_organization_link_id, hr_api.g_number)
       = p_organization_link_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_lip_bus.g_legislation_code;
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
    hr_lip_bus.g_organization_link_id := p_organization_link_id;
    hr_lip_bus.g_legislation_code     := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_organization_link_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following organization link rules...
--
--    1. It is mandatory.
--    2. It exists in the table HR_DE_ORGANIZATION_LINK. where the row has a
--    3. The row in the table HR_DE_ORGANIZATION_LINK must have a link type of
--       'DE_LIABILITY_INSURANCE'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_organization_link_id
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_organization_link_id
(p_organization_link_id in number) is
  --
  --
  -- Local Cursors.
  --
  cursor c_organization_link
    (p_organization_link_id in number) is
    select org_link_type
    from   hr_de_organization_links
    where  organization_link_id = p_organization_link_id;
  --
  --
  -- Local Variables.
  --
  l_proc          varchar2(72) :=  g_package || 'chk_organization_link_id';
  l_org_link_type varchar2(30);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'organization_link_id'
    ,p_argument_value => p_organization_link_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Check that the organization link exists.
  --
  open c_organization_link
    (p_organization_link_id => p_organization_link_id);
  fetch c_organization_link into l_org_link_type;
  if c_organization_link%notfound then
    close c_organization_link;
    fnd_message.set_name('PER', 'HR_DE_ORG_LINK_CHK');
    fnd_message.raise_error;
  else
    close c_organization_link;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Check that the organization link has a link type of 'DE_LIABILITY_INSURANCE'.
  --
  if not (l_org_link_type = 'DE_LIABILITY_INSURANCE') then
    fnd_message.set_name('PER', 'HR_DE_LINK_LIABILITY_INS');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_organization_link_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_calculation_method >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following calculation method rules...
--
--    1. It is valid value from the lookup type 'DE_WORKING_HOURS_CALC_METHOD'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_liability_premiums_id
--    p_object_version_number
--    p_calculation_method
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_calculation_method
(p_effective_date        in date
,p_liability_premiums_id in number
,p_object_version_number in number
,p_calculation_method    in varchar2) is
  --
  --
  -- Local Variables.
  --
  l_proc         varchar2(72) :=  g_package || 'chk_calculation_method';
  l_api_updating boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := hr_lip_shd.api_updating
                      (p_effective_date        => p_effective_date
                      ,p_liability_premiums_id => p_liability_premiums_id
                      ,p_object_version_number => p_object_version_number);
  --
  if (not l_api_updating
      and p_calculation_method is not null)
  or (l_api_updating
      and nvl(hr_lip_shd.g_old_rec.calculation_method, hr_api.g_varchar2) <> nvl(p_calculation_method, hr_api.g_varchar2)
      and p_calculation_method is not null) then
    --
    --
    -- Check that it is a valid value from the lookup type 'DE_WORKING_HOURS_CALC_METHOD'.
    --
    if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'DE_WORKING_HOURS_CALC_METHOD'
         ,p_lookup_code    => p_calculation_method) then
      fnd_message.set_name('PER', 'HR_DE_CALC_METHOD_LOOKUP_CHK');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_calculation_method;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_std_working_hours_per_year >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following standard working hours per year rules...
--
--    1. It must be between 0 and 999999999999999.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_liability_premiums_id
--    p_object_version_number
--    p_std_working_hours_per_year
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_std_working_hours_per_year
(p_effective_date             in date
,p_liability_premiums_id      in number
,p_object_version_number      in number
,p_std_working_hours_per_year in number) is
  --
  --
  -- Local Variables.
  --
  l_proc         varchar2(72) :=  g_package || 'chk_std_working_hours_per_year';
  l_api_updating boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := hr_lip_shd.api_updating
                      (p_effective_date        => p_effective_date
                      ,p_liability_premiums_id => p_liability_premiums_id
                      ,p_object_version_number => p_object_version_number);
  --
  if (not l_api_updating
      and p_std_working_hours_per_year is not null)
  or (l_api_updating
      and nvl(hr_lip_shd.g_old_rec.std_working_hours_per_year, hr_api.g_number) <> nvl(p_std_working_hours_per_year, hr_api.g_number)
      and p_std_working_hours_per_year is not null) then
    --
    --
    -- Check that it is between 0 and 999999999999999.
    --
    if not (p_std_working_hours_per_year >= 0 and p_std_working_hours_per_year <= 999999999999999) then
      fnd_message.set_name('PER', 'HR_DE_WORK_HRS_VALUE_CHK');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_std_working_hours_per_year;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_std_percentage >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following standard percentage rules...
--
--    1. It must be between 0 and 100.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_liability_premiums_id
--    p_object_version_number
--    p_std_percentage
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_std_percentage
(p_effective_date        in date
,p_liability_premiums_id in number
,p_object_version_number in number
,p_std_percentage        in varchar2) is
  --
  --
  -- Local Variables.
  --
  l_proc         varchar2(72) :=  g_package || 'chk_std_percentage';
  l_api_updating boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := hr_lip_shd.api_updating
                      (p_effective_date        => p_effective_date
                      ,p_liability_premiums_id => p_liability_premiums_id
                      ,p_object_version_number => p_object_version_number);
  --
  if (not l_api_updating
      and p_std_percentage is not null)
  or (l_api_updating
      and nvl(hr_lip_shd.g_old_rec.std_percentage, hr_api.g_number) <> nvl(p_std_percentage, hr_api.g_number)
      and p_std_percentage is not null) then
    --
    --
    -- Check that it is between 0 and 100.
    --
    if not (p_std_percentage >= 0 and p_std_percentage <= 100) then
      fnd_message.set_name('PER', 'HR_DE_STD_PERC_VALUE_CHK');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_std_percentage;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_max_remuneration >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following max remuneration rules...
--
--    1. It must be between 0 and 9999999999.99.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_liability_premiums_id
--    p_object_version_number
--    p_max_remuneration
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_max_remuneration
(p_effective_date        in date
,p_liability_premiums_id in number
,p_object_version_number in number
,p_max_remuneration    in varchar2) is
  --
  --
  -- Local Variables.
  --
  l_proc         varchar2(72) :=  g_package || 'chk_max_remuneration';
  l_api_updating boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := hr_lip_shd.api_updating
                      (p_effective_date        => p_effective_date
                      ,p_liability_premiums_id => p_liability_premiums_id
                      ,p_object_version_number => p_object_version_number);
  --
  if (not l_api_updating
      and p_max_remuneration is not null)
  or (l_api_updating
      and nvl(hr_lip_shd.g_old_rec.max_remuneration, hr_api.g_number) <> nvl(p_max_remuneration, hr_api.g_number)
      and p_max_remuneration is not null) then
    --
    --
    -- Check that it is between 0 and 9999999999.99.
    --
    if not (p_max_remuneration >= 0 and p_max_remuneration <= 9999999999.99) then
      fnd_message.set_name('PER', 'HR_DE_MAX_REM_VALUE_CHK');
      fnd_message.raise_error;
    end if;
    null;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_max_remuneration;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_overlapping_premiums >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following rules...
--
--    1. Premium records cannot overlap for the same organization link.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_liability_premiums_id
--    p_object_version_number
--    p_max_remuneration
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_overlapping_premiums
(p_liability_premiums_id  in number
,p_organization_link_id   in number
,p_validation_start_date  in date
,p_validation_end_date    in date) is
  --
  --
  -- Local Cursors.
  --
  cursor c_liability_premiums
    (p_liability_premiums_id in number
    ,p_organization_link_id  in number
    ,p_validation_start_date in date
    ,p_validation_end_date   in date) is
    select null
    from   hr_de_liability_premiums_f
    where  organization_link_id   = p_organization_link_id
      and  liability_premiums_id <> nvl(p_liability_premiums_id, hr_api.g_number)
      and  p_validation_start_date <= effective_end_date
      and  p_validation_end_date   >= effective_start_date;

  --
  --
  -- Local Variables.
  --
  l_proc  varchar2(72) :=  g_package || 'chk_overlapping_premiums';
  l_dummy varchar2(2000);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check that there are no overlapping records for the same organization link.
  --
  open c_liability_premiums
    (p_liability_premiums_id => p_liability_premiums_id
    ,p_organization_link_id  => p_organization_link_id
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date);
  fetch c_liability_premiums into l_dummy;
  if c_liability_premiums%found then
    close c_liability_premiums;
    fnd_message.set_name('PER', 'HR_DE_SINGLE_LIAB_PREMIUM_CHK');
    fnd_message.raise_error;
  else
    close c_liability_premiums;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_overlapping_premiums;
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
  (p_rec in hr_lip_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.liability_premiums_id is not null)  and (
    nvl(hr_lip_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hr_lip_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.liability_premiums_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_DE_LIABILITY_PREMIUMS'
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
  (p_effective_date  in date
  ,p_rec             in hr_lip_shd.g_rec_type
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
  IF NOT hr_lip_shd.api_updating
      (p_liability_premiums_id            => p_rec.liability_premiums_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF NVL(p_rec.organization_link_id, hr_api.g_number) <> NVL(hr_lip_shd.g_old_rec.organization_link_id, hr_api.g_number) THEN
    l_argument := 'organization_link_id';
    RAISE l_error;
  END IF;
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
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_liability_premiums_id            in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'liability_premiums_id'
      ,p_argument_value => p_liability_premiums_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in hr_lip_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_lip_bus.set_security_group_id(p_organization_link_id => p_rec.organization_link_id);
  --
  chk_overlapping_premiums
    (p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_organization_link_id  => p_rec.organization_link_id
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date);
  --
  chk_organization_link_id
    (p_organization_link_id => p_rec.organization_link_id);
  --
  chk_calculation_method
    (p_effective_date        => p_effective_date
    ,p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_calculation_method    => p_rec.calculation_method);
  --
  chk_std_working_hours_per_year
    (p_effective_date             => p_effective_date
    ,p_liability_premiums_id      => p_rec.liability_premiums_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_std_working_hours_per_year => p_rec.std_working_hours_per_year);
  --
  chk_std_percentage
    (p_effective_date        => p_effective_date
    ,p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_std_percentage        => p_rec.std_percentage);
  --
 chk_max_remuneration
    (p_effective_date        => p_effective_date
    ,p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_max_remuneration      => p_rec.max_remuneration);
  --
  hr_lip_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in hr_lip_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_lip_bus.set_security_group_id(p_organization_link_id => p_rec.organization_link_id);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  chk_overlapping_premiums
    (p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_organization_link_id  => p_rec.organization_link_id
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date);
  --
  chk_calculation_method
    (p_effective_date        => p_effective_date
    ,p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_calculation_method    => p_rec.calculation_method);
  --
  chk_std_working_hours_per_year
    (p_effective_date             => p_effective_date
    ,p_liability_premiums_id      => p_rec.liability_premiums_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_std_working_hours_per_year => p_rec.std_working_hours_per_year);
  --
  chk_std_percentage
    (p_effective_date        => p_effective_date
    ,p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_std_percentage        => p_rec.std_percentage);
  --
 chk_max_remuneration
    (p_effective_date        => p_effective_date
    ,p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_max_remuneration      => p_rec.max_remuneration);
  --
  hr_lip_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in hr_lip_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_liability_premiums_id            => p_rec.liability_premiums_id
    );
  --
  chk_overlapping_premiums
    (p_liability_premiums_id => p_rec.liability_premiums_id
    ,p_organization_link_id  => p_rec.organization_link_id
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_lip_bus;

/
