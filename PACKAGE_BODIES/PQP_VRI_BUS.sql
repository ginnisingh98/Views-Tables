--------------------------------------------------------
--  DDL for Package Body PQP_VRI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRI_BUS" as
/* $Header: pqvrirhi.pkb 120.0.12010000.2 2008/08/08 07:24:11 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vri_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_veh_repos_extra_info_id     number         default null;
g_vehicle_repository_id       number         default null;

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_veh_repos_extra_info_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqp_veh_repos_extra_info and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_veh_repos_extra_info vri
      --   , EDIT_HERE table_name(s) 333
     where vri.veh_repos_extra_info_id = p_veh_repos_extra_info_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'veh_repos_extra_info_id'
    ,p_argument_value     => p_veh_repos_extra_info_id
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
        => nvl(p_associated_column1,'VEH_REPOS_EXTRA_INFO_ID')
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
--  |---------------------< return_veh_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--  used to get legislation code for Vehicle repository Id
--
FUNCTION return_veh_legislation_code
            ( p_vehicle_repository_id    IN     NUMBER
            ) RETURN VARCHAR2 IS
  --
  -- Declare cursor
  --
  CURSOR   csr_leg_code IS
    SELECT pbg.legislation_code
      FROM per_business_groups_perf pbg
          ,pqp_vehicle_repository_f vre
     WHERE vre.vehicle_repository_id = p_vehicle_repository_id
      AND   pbg.business_group_id=vre.business_group_id ;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_veh_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'vehicle_repository_id'
    ,p_argument_value     => p_vehicle_repository_id
    );
  --
  IF ( nvl(pqp_vri_bus.g_vehicle_repository_id, hr_api.g_number)
       = p_vehicle_repository_id) THEN
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_vri_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  ELSE
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    OPEN  csr_leg_code;
    FETCH csr_leg_code into l_legislation_code;
    --
    IF csr_leg_code%notfound THEN
      --
      -- The primary key is invalid therefore we must error
      --
      CLOSE csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    END IF;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    CLOSE csr_leg_code;
    pqp_vri_bus.g_vehicle_repository_id     := g_vehicle_repository_id;
    pqp_vri_bus.g_legislation_code  := l_legislation_code;
  END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
END return_veh_legislation_code;

--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_vehicle_repository_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor   csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
          ,pqp_vehicle_repository_f vre
     where vre.vehicle_repository_id = p_vehicle_repository_id
       and pbg.business_group_id     = vre.business_group_id ;
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
    ,p_argument           => 'vehicle_repository_id'
    ,p_argument_value     => p_vehicle_repository_id
    );
  --
  if ( nvl(pqp_vri_bus.g_vehicle_repository_id, hr_api.g_number)
       = p_vehicle_repository_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_vri_bus.g_legislation_code;
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
    pqp_vri_bus.g_vehicle_repository_id := p_vehicle_repository_id;
    pqp_vri_bus.g_legislation_code      := l_legislation_code;
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
  (p_rec in pqp_vri_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.veh_repos_extra_info_id is not null)  and (
    nvl(pqp_vri_shd.g_old_rec.information_type, hr_api.g_varchar2) <>
    nvl(p_rec.information_type, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information_category, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information1, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information2, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information3, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information4, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information5, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information6, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information7, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information8, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information9, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information10, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information11, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information12, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information13, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information14, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information15, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information16, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information17, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information18, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information19, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information20, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information21, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information22, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information23, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information24, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information25, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information26, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information27, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information28, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information29, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_information30, hr_api.g_varchar2) ))
    or (p_rec.veh_repos_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Repos Extra Info DDF'
      ,p_attribute_category              => p_rec.vrei_information_category
      ,p_attribute1_name                 => 'VREI_INFORMATION1'
      ,p_attribute1_value                => p_rec.vrei_information1
      ,p_attribute2_name                 => 'VREI_INFORMATION2'
      ,p_attribute2_value                => p_rec.vrei_information2
      ,p_attribute3_name                 => 'VREI_INFORMATION3'
      ,p_attribute3_value                => p_rec.vrei_information3
      ,p_attribute4_name                 => 'VREI_INFORMATION4'
      ,p_attribute4_value                => p_rec.vrei_information4
      ,p_attribute5_name                 => 'VREI_INFORMATION5'
      ,p_attribute5_value                => p_rec.vrei_information5
      ,p_attribute6_name                 => 'VREI_INFORMATION6'
      ,p_attribute6_value                => p_rec.vrei_information6
      ,p_attribute7_name                 => 'VREI_INFORMATION7'
      ,p_attribute7_value                => p_rec.vrei_information7
      ,p_attribute8_name                 => 'VREI_INFORMATION8'
      ,p_attribute8_value                => p_rec.vrei_information8
      ,p_attribute9_name                => 'VREI_INFORMATION9'
      ,p_attribute9_value               => p_rec.vrei_information9
      ,p_attribute10_name                => 'VREI_INFORMATION10'
      ,p_attribute10_value               => p_rec.vrei_information10
      ,p_attribute11_name                => 'VREI_INFORMATION11'
      ,p_attribute11_value               => p_rec.vrei_information11
      ,p_attribute12_name                => 'VREI_INFORMATION12'
      ,p_attribute12_value               => p_rec.vrei_information12
      ,p_attribute13_name                => 'VREI_INFORMATION13'
      ,p_attribute13_value               => p_rec.vrei_information13
      ,p_attribute14_name                => 'VREI_INFORMATION14'
      ,p_attribute14_value               => p_rec.vrei_information14
      ,p_attribute15_name                => 'VREI_INFORMATION15'
      ,p_attribute15_value               => p_rec.vrei_information15
      ,p_attribute16_name                => 'VREI_INFORMATION16'
      ,p_attribute16_value               => p_rec.vrei_information16
      ,p_attribute17_name                => 'VREI_INFORMATION17'
      ,p_attribute17_value               => p_rec.vrei_information17
      ,p_attribute18_name                => 'VREI_INFORMATION18'
      ,p_attribute18_value               => p_rec.vrei_information18
      ,p_attribute19_name                => 'VREI_INFORMATION19'
      ,p_attribute19_value               => p_rec.vrei_information19
      ,p_attribute20_name                => 'VREI_INFORMATION20'
      ,p_attribute20_value               => p_rec.vrei_information20
      ,p_attribute21_name                => 'VREI_INFORMATION21'
      ,p_attribute21_value               => p_rec.vrei_information21
      ,p_attribute22_name                => 'VREI_INFORMATION22'
      ,p_attribute22_value               => p_rec.vrei_information22
      ,p_attribute23_name                => 'VREI_INFORMATION23'
      ,p_attribute23_value               => p_rec.vrei_information23
      ,p_attribute24_name                => 'VREI_INFORMATION24'
      ,p_attribute24_value               => p_rec.vrei_information24
      ,p_attribute25_name                => 'VREI_INFORMATION25'
      ,p_attribute25_value               => p_rec.vrei_information25
      ,p_attribute26_name                => 'VREI_INFORMATION26'
      ,p_attribute26_value               => p_rec.vrei_information26
      ,p_attribute27_name                => 'VREI_INFORMATION27'
      ,p_attribute27_value               => p_rec.vrei_information27
      ,p_attribute28_name                => 'VREI_INFORMATION28'
      ,p_attribute28_value               => p_rec.vrei_information28
      ,p_attribute29_name                => 'VREI_INFORMATION29'
      ,p_attribute29_value               => p_rec.vrei_information29
      ,p_attribute30_name                => 'VREI_INFORMATION30'
      ,p_attribute30_value               => p_rec.vrei_information30
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
  (p_rec in pqp_vri_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.veh_repos_extra_info_id is not null)  and (
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_vri_shd.g_old_rec.vrei_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.vrei_attribute20, hr_api.g_varchar2) ))
    or (p_rec.veh_repos_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Repos Extra Info DF'
      ,p_attribute_category              => p_rec.vrei_attribute_category
      ,p_attribute1_name                 => 'VREI_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.vrei_attribute1
      ,p_attribute2_name                 => 'VREI_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.vrei_attribute2
      ,p_attribute3_name                 => 'VREI_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.vrei_attribute3
      ,p_attribute4_name                 => 'VREI_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.vrei_attribute4
      ,p_attribute5_name                 => 'VREI_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.vrei_attribute5
      ,p_attribute6_name                 => 'VREI_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.vrei_attribute6
      ,p_attribute7_name                 => 'VREI_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.vrei_attribute7
      ,p_attribute8_name                 => 'VREI_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.vrei_attribute8
      ,p_attribute9_name                 => 'VREI_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.vrei_attribute9
      ,p_attribute10_name                => 'VREI_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.vrei_attribute10
      ,p_attribute11_name                => 'VREI_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.vrei_attribute11
      ,p_attribute12_name                => 'VREI_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.vrei_attribute12
      ,p_attribute13_name                => 'VREI_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.vrei_attribute13
      ,p_attribute14_name                => 'VREI_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.vrei_attribute14
      ,p_attribute15_name                => 'VREI_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.vrei_attribute15
      ,p_attribute16_name                => 'VREI_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.vrei_attribute16
      ,p_attribute17_name                => 'VREI_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.vrei_attribute17
      ,p_attribute18_name                => 'VREI_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.vrei_attribute18
      ,p_attribute19_name                => 'VREI_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.vrei_attribute19
      ,p_attribute20_name                => 'VREI_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.vrei_attribute20
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
  (p_rec in pqp_vri_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_vri_shd.api_updating
      (p_veh_repos_extra_info_id           => p_rec.veh_repos_extra_info_id
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
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pqp_vri_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  pqp_vri_bus.chk_ddf(p_rec);
  --
  pqp_vri_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqp_vri_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  pqp_vri_bus.chk_ddf(p_rec);
  --
  pqp_vri_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_vri_shd.g_rec_type
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
end pqp_vri_bus;

/
