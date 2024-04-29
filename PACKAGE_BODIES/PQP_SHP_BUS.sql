--------------------------------------------------------
--  DDL for Package Body PQP_SHP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SHP_BUS" as
/* $Header: pqshprhi.pkb 115.8 2003/02/17 22:14:48 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_shp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_service_history_period_id   number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_service_history_period_id            in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqp_service_history_periods shp
     where shp.service_history_period_id = p_service_history_period_id
       and pbg.business_group_id = shp.business_group_id;
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
    ,p_argument           => 'service_history_period_id'
    ,p_argument_value     => p_service_history_period_id
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
  (p_service_history_period_id            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqp_service_history_periods shp
     where shp.service_history_period_id = p_service_history_period_id
       and pbg.business_group_id = shp.business_group_id;
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
    ,p_argument           => 'service_history_period_id'
    ,p_argument_value     => p_service_history_period_id
    );
  --
  if ( nvl(pqp_shp_bus.g_service_history_period_id, hr_api.g_number)
       = p_service_history_period_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_shp_bus.g_legislation_code;
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
    pqp_shp_bus.g_service_history_period_id := p_service_history_period_id;
    pqp_shp_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
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
  (p_rec in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.service_history_period_id is not null)  and (
    nvl(pqp_shp_shd.g_old_rec.shp_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information_category, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information1, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information1, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information2, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information2, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information3, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information3, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information4, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information4, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information5, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information5, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information6, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information6, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information7, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information7, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information8, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information8, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information9, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information9, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information10, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information10, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information11, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information11, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information12, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information12, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information13, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information13, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information14, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information14, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information15, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information15, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information16, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information16, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information17, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information17, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information18, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information18, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information19, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information19, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_information20, hr_api.g_varchar2) <>
    nvl(p_rec.shp_information20, hr_api.g_varchar2) ))
    or (p_rec.service_history_period_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Employment History DDF'
      ,p_attribute_category              => p_rec.shp_information_category
      ,p_attribute1_name                 => 'SHP_INFORMATION1'
      ,p_attribute1_value                => p_rec.shp_information1
      ,p_attribute2_name                 => 'SHP_INFORMATION2'
      ,p_attribute2_value                => p_rec.shp_information2
      ,p_attribute3_name                 => 'SHP_INFORMATION3'
      ,p_attribute3_value                => p_rec.shp_information3
      ,p_attribute4_name                 => 'SHP_INFORMATION4'
      ,p_attribute4_value                => p_rec.shp_information4
      ,p_attribute5_name                 => 'SHP_INFORMATION5'
      ,p_attribute5_value                => p_rec.shp_information5
      ,p_attribute6_name                 => 'SHP_INFORMATION6'
      ,p_attribute6_value                => p_rec.shp_information6
      ,p_attribute7_name                 => 'SHP_INFORMATION7'
      ,p_attribute7_value                => p_rec.shp_information7
      ,p_attribute8_name                 => 'SHP_INFORMATION8'
      ,p_attribute8_value                => p_rec.shp_information8
      ,p_attribute9_name                 => 'SHP_INFORMATION9'
      ,p_attribute9_value                => p_rec.shp_information9
      ,p_attribute10_name                => 'SHP_INFORMATION10'
      ,p_attribute10_value               => p_rec.shp_information10
      ,p_attribute11_name                => 'SHP_INFORMATION11'
      ,p_attribute11_value               => p_rec.shp_information11
      ,p_attribute12_name                => 'SHP_INFORMATION12'
      ,p_attribute12_value               => p_rec.shp_information12
      ,p_attribute13_name                => 'SHP_INFORMATION13'
      ,p_attribute13_value               => p_rec.shp_information13
      ,p_attribute14_name                => 'SHP_INFORMATION14'
      ,p_attribute14_value               => p_rec.shp_information14
      ,p_attribute15_name                => 'SHP_INFORMATION15'
      ,p_attribute15_value               => p_rec.shp_information15
      ,p_attribute16_name                => 'SHP_INFORMATION16'
      ,p_attribute16_value               => p_rec.shp_information16
      ,p_attribute17_name                => 'SHP_INFORMATION17'
      ,p_attribute17_value               => p_rec.shp_information17
      ,p_attribute18_name                => 'SHP_INFORMATION18'
      ,p_attribute18_value               => p_rec.shp_information18
      ,p_attribute19_name                => 'SHP_INFORMATION19'
      ,p_attribute19_value               => p_rec.shp_information19
      ,p_attribute20_name                => 'SHP_INFORMATION20'
      ,p_attribute20_value               => p_rec.shp_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  (p_rec in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.service_history_period_id is not null)  and (
    nvl(pqp_shp_shd.g_old_rec.shp_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_shp_shd.g_old_rec.shp_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.shp_attribute20, hr_api.g_varchar2) ))
    or (p_rec.service_history_period_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Employment History Details DF'
      ,p_attribute_category              => p_rec.shp_attribute_category
      ,p_attribute1_name                 => 'SHP_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.shp_attribute1
      ,p_attribute2_name                 => 'SHP_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.shp_attribute2
      ,p_attribute3_name                 => 'SHP_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.shp_attribute3
      ,p_attribute4_name                 => 'SHP_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.shp_attribute4
      ,p_attribute5_name                 => 'SHP_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.shp_attribute5
      ,p_attribute6_name                 => 'SHP_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.shp_attribute6
      ,p_attribute7_name                 => 'SHP_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.shp_attribute7
      ,p_attribute8_name                 => 'SHP_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.shp_attribute8
      ,p_attribute9_name                 => 'SHP_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.shp_attribute9
      ,p_attribute10_name                => 'SHP_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.shp_attribute10
      ,p_attribute11_name                => 'SHP_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.shp_attribute11
      ,p_attribute12_name                => 'SHP_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.shp_attribute12
      ,p_attribute13_name                => 'SHP_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.shp_attribute13
      ,p_attribute14_name                => 'SHP_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.shp_attribute14
      ,p_attribute15_name                => 'SHP_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.shp_attribute15
      ,p_attribute16_name                => 'SHP_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.shp_attribute16
      ,p_attribute17_name                => 'SHP_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.shp_attribute17
      ,p_attribute18_name                => 'SHP_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.shp_attribute18
      ,p_attribute19_name                => 'SHP_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.shp_attribute19
      ,p_attribute20_name                => 'SHP_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.shp_attribute20
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
  (
  p_rec in pqp_shp_shd.g_rec_type
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
  IF NOT pqp_shp_shd.api_updating
      (p_service_history_period_id            => p_rec.service_history_period_id
      ,p_object_version_number                => p_rec.object_version_number
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
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
--
-- A new chk criteria has been added
-- PS Bug 2028104 for more details
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_periods >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--
--    Validates that period years or period days is mandatory if start date and end date
--    doesn't hold a value
--
--  Pre-conditions :
--
--  In Arguments :
--    p_service_history_period_id
--    p_start_date
--    p_end_date
--    p_period_years
--    p_period_days
--    p_assignment_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied then procesing continues.
--
--  Post Failure :
--       If  the above business rules are violated then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_periods
  (p_service_history_period_id        in number
  ,p_start_date                       in date
  ,p_end_date                         in date
  ,p_period_years                     in number
  ,p_period_days                      in number
  ,p_assignment_id                    in number
  ,p_object_version_number            in number )
is
--
  l_exists             varchar2(1) ;
  l_proc               varchar2(72) := g_package||'chk_periods';
  l_api_updating       boolean;
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name        => l_proc
     ,p_argument        => 'assignment_id'
     ,p_argument_value  => p_assignment_id
     );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The year value or day value has changed
  --
  --

  l_api_updating := pqp_shp_shd.api_updating
    (p_service_history_period_id  => p_service_history_period_id
    ,p_object_version_number      => p_object_version_number);
  --

  if ((l_api_updating and ((nvl(pqp_shp_shd.g_old_rec.period_years, hr_api.g_number) <>
                              nvl(p_period_years, hr_api.g_number)) or
                           (nvl(pqp_shp_shd.g_old_rec.period_days, hr_api.g_number) <>
                              nvl(p_period_days, hr_api.g_number)))) or
       (NOT l_api_updating)) then
    --
    -- Check that either year value or day value is not null
    --

    if p_period_years is null and
       p_period_days  is null and
       p_start_date   is null and
       p_end_date     is null then

    --
      hr_utility.set_message(8303, 'PQP_230543_SHP_REQ_VALUES');
      hr_utility.raise_error;
    --

    end if; -- end if of period is null check...

  end if; -- end if of api updatin check...
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
--
end chk_periods;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_start_date >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--    Validates that start_date is less than or equal to end date
--
--    Validates that start_date does not overlap with those of another
--    service history record. (This is now validated on the forms side)
--
--  Pre-conditions :
--    Format of p_start_date and p_end_date must be correct
--
--  In Arguments :
--    p_service_history_period_id
--    p_start_date
--    p_end_date
--    p_assignment_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied then procesing continues.
--
--  Post Failure :
--       If  the above business rules are violated then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_start_date
  (p_service_history_period_id        in number
  ,p_start_date                       in date
  ,p_end_date                         in date
  ,p_assignment_id                    in number
  ,p_object_version_number            in number )
is
--
  l_exists             varchar2(1) ;
  l_proc               varchar2(72) := g_package||'chk_start_date';
  l_api_updating       boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name        => l_proc
     ,p_argument        => 'assignment_id'
     ,p_argument_value  => p_assignment_id
     );
  --
  -- Commented out the following lines of code
  -- as start dates and end dates are no longer mandatory
  -- PS Bug 2028104

--  hr_api.mandatory_arg_error
--     (p_api_name        => l_proc
--     ,p_argument        => 'start_date'
--     ,p_argument_value  => p_start_date
--     );
  --
--  hr_api.mandatory_arg_error
--     (p_api_name        => l_proc
--     ,p_argument        => 'end_date'
--     ,p_argument_value  => p_end_date
--     );
  --

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The start_date value has changed
  --
  l_api_updating := pqp_shp_shd.api_updating
    (p_service_history_period_id  => p_service_history_period_id
    ,p_object_version_number      => p_object_version_number);

  --
  if ((l_api_updating and nvl(pqp_shp_shd.g_old_rec.start_date, hr_api.g_date) <>
                              nvl(p_start_date, hr_api.g_date)) or
       (NOT l_api_updating)) then
  --
    --
    -- Check that the start_date value is less than or equal to the end_date
    -- value for the current record
    --
    if p_start_date > p_end_date then
    --
      hr_utility.set_message(8303, 'PQP_230503_SHP_START_DT_GREAT');
      hr_utility.raise_error;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
--
end chk_start_date;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_end_date >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--    Validates that an end_date is mandatory if start date has a value
--    otherwise it shouldn't hold a value
--
--    Validates that end_date is greater than or equal to start_date
--
--    Validates year or days to have a value if dates are null
--
--    Validates that end_date does not overlap with those of another
--    service history record for a given assignment_id. (This is now validated
--     on the forms side)
--
--  Pre-conditions :
--    Format of p_start_date and p_end_date must be correct
--
--  In Arguments :
--    p_service_history_period_id
--    p_start_date
--    p_end_date
--    p_period_years
--    p_period_days
--    p_assignment_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied then procesing continues.
--
--  Post Failure :
--       If  the above business rules are violated then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_end_date
  (p_service_history_period_id        in number
  ,p_start_date                       in date
  ,p_end_date                         in date
  ,p_period_years                     in number
  ,p_period_days                      in number
  ,p_assignment_id                    in number
  ,p_object_version_number            in number )
is
--
  l_exists             varchar2(1) ;
  l_proc               varchar2(72) := g_package||'chk_end_date';
  l_api_updating       boolean;
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name        => l_proc
     ,p_argument        => 'assignment_id'
     ,p_argument_value  => p_assignment_id
     );
  --
  -- Commented out the following lines of code
  -- as start and end dates are no longer mandatory
  -- but an end date becomes a mandatory input if a
  -- start date is specified
  -- PS Bug 2028104

--  hr_api.mandatory_arg_error
--     (p_api_name        => l_proc
--     ,p_argument        => 'start_date'
--     ,p_argument_value  => p_start_date
--     );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The end_date value has changed
  --
  --

  l_api_updating := pqp_shp_shd.api_updating
    (p_service_history_period_id  => p_service_history_period_id
    ,p_object_version_number      => p_object_version_number);
  --

  if ((l_api_updating and nvl(pqp_shp_shd.g_old_rec.end_date, hr_api.g_date) <>
                              nvl(p_end_date, hr_api.g_date)) or
       (NOT l_api_updating)) then
    --
    -- Check that the end date has a value if start date has a value
    -- error out if it has a value when start date doesn't have one
    --
    if p_start_date is not null then

      hr_api.mandatory_arg_error
         (p_api_name        => l_proc
         ,p_argument        => 'end_date'
         ,p_argument_value  => p_end_date
         );

    elsif p_end_date is not null then

        hr_utility.set_message(8303, 'PQP_230504_SHP_END_DT_LESSER');
        hr_utility.raise_error;

    elsif p_period_years is null and
          p_period_days  is null then

        hr_utility.set_message(8303, 'PQP_230543_SHP_REQ_VALUES');
        hr_utility.raise_error;

    --
    end if; -- End if of start date is not null check..
    --
    --
    -- Check that the end_date value is greater than or equal to the start_date
    -- value for the current record
    --
    if p_end_date < p_start_date then
    --
      hr_utility.set_message(8303, 'PQP_230504_SHP_END_DT_LESSER');
      hr_utility.raise_error;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
--
end chk_end_date;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (
   p_rec                          in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  pqp_shp_bus.chk_ddf(p_rec);
  --
  pqp_shp_bus.chk_df(p_rec);
  --
  --
  -- Validate start date
  -- Only if it has a value
  --

  if p_rec.start_date is not null then

    chk_start_date
         (p_service_history_period_id   => p_rec.service_history_period_id
         ,p_start_date                  => p_rec.start_date
         ,p_end_date                    => p_rec.end_date
         ,p_assignment_id               => p_rec.assignment_id
         ,p_object_version_number       => p_rec.object_version_number);

  end if; -- End if of start date is not null check...

  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate end date
  --
  chk_end_date
       (p_service_history_period_id   => p_rec.service_history_period_id
       ,p_start_date                  => p_rec.start_date
       ,p_end_date                    => p_rec.end_date
       ,p_period_years                => p_rec.period_years
       ,p_period_days                 => p_rec.period_days
       ,p_assignment_id               => p_rec.assignment_id
       ,p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (
   p_rec                          in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (
    p_rec              => p_rec
    );
  --
  --
  pqp_shp_bus.chk_ddf(p_rec);
  --
  pqp_shp_bus.chk_df(p_rec);
  --
  --
  -- Validate start date
  -- Only if it has a value
  --

  if p_rec.start_date is not null then

    chk_start_date
         (p_service_history_period_id   => p_rec.service_history_period_id
         ,p_start_date                  => p_rec.start_date
         ,p_end_date                    => p_rec.end_date
         ,p_assignment_id               => p_rec.assignment_id
         ,p_object_version_number       => p_rec.object_version_number);

  end if; -- end if of start date is not null check...
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate end date
  --
  chk_end_date
       (p_service_history_period_id   => p_rec.service_history_period_id
       ,p_start_date                  => p_rec.start_date
       ,p_end_date                    => p_rec.end_date
       ,p_period_years                => p_rec.period_years
       ,p_period_days                 => p_rec.period_days
       ,p_assignment_id               => p_rec.assignment_id
       ,p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 8);
  --
  chk_periods
       (p_service_history_period_id   => p_rec.service_history_period_id
       ,p_start_date                  => p_rec.start_date
       ,p_end_date                    => p_rec.end_date
       ,p_period_years                => p_rec.period_years
       ,p_period_days                 => p_rec.period_days
       ,p_assignment_id               => p_rec.assignment_id
       ,p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_shp_shd.g_rec_type
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
end pqp_shp_bus;

/
