--------------------------------------------------------
--  DDL for Package Body PQP_VRE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRE_BUS" as
/* $Header: pqvrerhi.pkb 120.0.12010000.2 2008/08/08 07:23:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vre_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vehicle_repository_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE set_security_group_id
          (p_vehicle_repository_id                IN NUMBER
          ,p_associated_column1                   IN VARCHAR2
          ) IS
  --
  -- Declare cursor
  --
  CURSOR   csr_sec_grp IS
    SELECT pbg.security_group_id,
           pbg.legislation_code
      FROM per_business_groups_perf pbg
         , pqp_vehicle_repository_f vre
     WHERE vre.vehicle_repository_id = p_vehicle_repository_id
       AND pbg.business_group_id = vre.business_group_id;

  --
  -- Declare local variables
  --
  l_security_group_id NUMBER;
  l_proc              VARCHAR2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  VARCHAR2(150);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           =>'vehicle_repository_id'
    ,p_argument_value     => p_vehicle_repository_id
    );
  --
  OPEN csr_sec_grp;
  FETCH csr_sec_grp INTO l_security_group_id,l_legislation_code;
  --
  IF csr_sec_grp%notfound THEN
     --
     CLOSE csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
                => nvl(p_associated_column1,'VEHICLE_REPOSITORY_ID')
       );
     --
  ELSE
    CLOSE csr_sec_grp;
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
  END IF;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--  used to get legislation code for Vehicle repository Id
--
FUNCTION return_legislation_code
            (
	      p_vehicle_repository_id    IN     NUMBER
            ) RETURN VARCHAR2 IS
  --
  -- Declare cursor
  --
  CURSOR   csr_leg_code IS
    SELECT pbg.legislation_code
      FROM per_business_groups_perf pbg
          ,pqp_vehicle_repository_f vre
     WHERE vre.vehicle_repository_id = p_vehicle_repository_id
       AND pbg.business_group_id = vre.business_group_id;
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
  IF ( nvl(pqp_vre_bus.g_vehicle_repository_id, hr_api.g_number)
       = p_vehicle_repository_id) THEN
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_vre_bus.g_legislation_code;
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
    pqp_vre_bus.g_vehicle_repository_id       := p_vehicle_repository_id;
    pqp_vre_bus.g_legislation_code  := l_legislation_code;
  END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
END return_legislation_code;
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
PROCEDURE chk_ddf
  (p_rec in pqp_vre_shd.g_rec_type
  ) IS
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  IF ((p_rec.vehicle_repository_id is not null)  and (
    nvl(pqp_vre_shd.g_old_rec.vre_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information_category, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information1, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information1, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information2, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information2, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information3, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information3, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information4, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information4, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information5, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information5, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information6, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information6, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information7, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information7, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information8, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information8, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information9, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information9, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information10, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information10, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information11, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information11, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information12, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information12, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information13, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information13, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information14, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information14, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information15, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information15, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information16, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information16, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information17, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information17, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information18, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information18, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information19, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information19, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_information20, hr_api.g_varchar2) <>
    nvl(p_rec.vre_information20, hr_api.g_varchar2) ))
    or (p_rec.vehicle_repository_id is null)  THEN
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 =>'PQP'
      ,p_descflex_name                   =>'Vehicle Repository Info DDF'
      ,p_attribute_category              => p_rec.vre_information_category
      ,p_attribute1_name                 =>'VRE_INFORMATION1'
      ,p_attribute1_value                => p_rec.vre_information1
      ,p_attribute2_name                 =>'VRE_INFORMATION2'
      ,p_attribute2_value                => p_rec.vre_information2
      ,p_attribute3_name                 =>'VRE_INFORMATION3'
      ,p_attribute3_value                => p_rec.vre_information3
      ,p_attribute4_name                 =>'VRE_INFORMATION4'
      ,p_attribute4_value                => p_rec.vre_information4
      ,p_attribute5_name                 =>'VRE_INFORMATION5'
      ,p_attribute5_value                => p_rec.vre_information5
      ,p_attribute6_name                 =>'VRE_INFORMATION6'
      ,p_attribute6_value                => p_rec.vre_information6
      ,p_attribute7_name                 =>'VRE_INFORMATION7'
      ,p_attribute7_value                => p_rec.vre_information7
      ,p_attribute8_name                 =>'VRE_INFORMATION8'
      ,p_attribute8_value                => p_rec.vre_information8
      ,p_attribute9_name                 =>'VRE_INFORMATION9'
      ,p_attribute9_value                => p_rec.vre_information9
      ,p_attribute10_name                =>'VRE_INFORMATION10'
      ,p_attribute10_value               => p_rec.vre_information10
      ,p_attribute11_name                =>'VRE_INFORMATION11'
      ,p_attribute11_value               => p_rec.vre_information11
      ,p_attribute12_name                =>'VRE_INFORMATION12'
      ,p_attribute12_value               => p_rec.vre_information12
      ,p_attribute13_name                =>'VRE_INFORMATION13'
      ,p_attribute13_value               => p_rec.vre_information13
      ,p_attribute14_name                =>'VRE_INFORMATION14'
      ,p_attribute14_value               => p_rec.vre_information14
      ,p_attribute15_name                =>'VRE_INFORMATION15'
      ,p_attribute15_value               => p_rec.vre_information15
      ,p_attribute16_name                =>'VRE_INFORMATION16'
      ,p_attribute16_value               => p_rec.vre_information16
      ,p_attribute17_name                =>'VRE_INFORMATION17'
      ,p_attribute17_value               => p_rec.vre_information17
      ,p_attribute18_name                =>'VRE_INFORMATION18'
      ,p_attribute18_value               => p_rec.vre_information18
      ,p_attribute19_name                =>'VRE_INFORMATION19'
      ,p_attribute19_value               => p_rec.vre_information19
      ,p_attribute20_name                =>'VRE_INFORMATION20'
      ,p_attribute20_value               => p_rec.vre_information20
      );
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
END chk_ddf;
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
PROCEDURE chk_df
  (p_rec in pqp_vre_shd.g_rec_type
  ) IS
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  IF ((p_rec.vehicle_repository_id is not null)  and (
    nvl(pqp_vre_shd.g_old_rec.vre_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_vre_shd.g_old_rec.vre_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.vre_attribute20, hr_api.g_varchar2) ))
    or (p_rec.vehicle_repository_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Repository Info DF'
      ,p_attribute_category              => p_rec.vre_attribute_category
      ,p_attribute1_name                 => 'VRE_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.vre_attribute1
      ,p_attribute2_name                 => 'VRE_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.vre_attribute2
      ,p_attribute3_name                 => 'VRE_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.vre_attribute3
      ,p_attribute4_name                 => 'VRE_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.vre_attribute4
      ,p_attribute5_name                 => 'VRE_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.vre_attribute5
      ,p_attribute6_name                 => 'VRE_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.vre_attribute6
      ,p_attribute7_name                 => 'VRE_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.vre_attribute7
      ,p_attribute8_name                 => 'VRE_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.vre_attribute8
      ,p_attribute9_name                 => 'VRE_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.vre_attribute9
      ,p_attribute10_name                => 'VRE_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.vre_attribute10
      ,p_attribute11_name                => 'VRE_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.vre_attribute11
      ,p_attribute12_name                => 'VRE_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.vre_attribute12
      ,p_attribute13_name                => 'VRE_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.vre_attribute13
      ,p_attribute14_name                => 'VRE_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.vre_attribute14
      ,p_attribute15_name                => 'VRE_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.vre_attribute15
      ,p_attribute16_name                => 'VRE_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.vre_attribute16
      ,p_attribute17_name                => 'VRE_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.vre_attribute17
      ,p_attribute18_name                => 'VRE_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.vre_attribute18
      ,p_attribute19_name                => 'VRE_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.vre_attribute19
      ,p_attribute20_name                => 'VRE_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.vre_attribute20
      );
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
END chk_df;
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
PROCEDURE chk_non_updateable_args
            (p_effective_date  IN DATE
            ,p_rec             IN pqp_vre_shd.g_rec_type
             ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
BEGIN
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_vre_shd.api_updating
      (p_vehicle_repository_id            => p_rec.vehicle_repository_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
PROCEDURE dt_update_validate
  (p_datetrack_mode                IN VARCHAR2
  ,p_validation_start_date         IN DATE
  ,p_validation_end_date           IN DATE
  ) IS
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
BEGIN
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
EXCEPTION
  WHEN Others THEN
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
END dt_update_validate;
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
PROCEDURE dt_delete_validate
  (p_vehicle_repository_id            IN NUMBER
  ,p_datetrack_mode                   IN VARCHAR2
  ,p_validation_start_date            IN DATE
  ,p_validation_end_date              IN DATE
  ) IS
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
BEGIN
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
  IF (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) THEN
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
      ,p_argument       => 'vehicle_repository_id'
      ,p_argument_value => p_vehicle_repository_id
      );
    --
  --
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
END dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------< Chk Unique Veh Identification Number ---------------|
-- ----------------------------------------------------------------------------
--Checking the Vehicle Identification existence ,if same id  exist
--then user cannot enter same Identification number once again.
PROCEDURE chk_unique_idennum
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ,p_update_flag           IN VARCHAR2
  ) IS

--Declare the cursor to get the registration number count
 CURSOR  c_iden_exist_cursor IS
 SELECT  COUNT(pvr.vehicle_id_number)
   FROM  pqp_vehicle_repository_f pvr
  WHERE  pvr.vehicle_id_number=p_rec.vehicle_id_number
    AND  pvr.business_group_id=p_rec.business_group_id
    AND  (p_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date
     OR  p_effective_date < pvr.effective_start_date);

 --Cursor to get the previous vehicle_id_number
 CURSOR  c_chk_previous_value_cur IS
 SELECT  pvr.vehicle_id_number
   FROM  pqp_vehicle_repository_f pvr
  WHERE  pvr.registration_number=p_rec.registration_number
    AND  pvr.business_group_id=p_rec.business_group_id
    AND  (p_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date
     OR  p_effective_date < pvr.effective_start_date);


   --Declare local variable
   l_count number;
   l_previous_id_number pqp_vehicle_repository_f.vehicle_id_number%TYPE;
BEGIN
   IF p_update_flag = 'Y' THEN
    OPEN c_chk_previous_value_cur;
    FETCH c_chk_previous_value_cur INTO  l_previous_id_number;
    CLOSE c_chk_previous_value_cur;
    IF nvl(l_previous_id_number,-1) <> p_rec.vehicle_id_number THEN
     OPEN  c_iden_exist_cursor;
     FETCH c_iden_exist_cursor INTO  l_count;
     CLOSE c_iden_exist_cursor;
     IF l_count>0 THEN
      fnd_message.set_name('PQP','PQP_230150_INDEN_EXISTS');
      fnd_message.raise_error;
     END IF;
    END IF;
   ELSE
    OPEN  c_iden_exist_cursor;
    FETCH c_iden_exist_cursor INTO  l_count;
    CLOSE c_iden_exist_cursor;
    IF l_count>0 THEN
     fnd_message.set_name('PQP','PQP_230150_INDEN_EXISTS');
     fnd_message.raise_error;
    END IF;
   END IF;
EXCEPTION
--------
WHEN no_data_found THEN
NULL;
End chk_unique_idennum;

-- ----------------------------------------------------------------------------
-- |------------------------< Chk Unique Reg Number >------------------------|
-- ----------------------------------------------------------------------------
--Checking th RegNumber existence ,if same registration number exist
--then user cannot enter same registration number once again.
PROCEDURE chk_unique_regnum
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS

--Declare the cursor to get the registration number count
 CURSOR  reg_exist_cursor IS
 SELECT  COUNT(pvr.registration_number)
   FROM  pqp_vehicle_repository_f pvr
  WHERE  pvr.registration_number=p_rec.registration_number
    AND  pvr.business_group_id=p_rec.business_group_id
    AND  (p_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date
     OR  p_effective_date < pvr.effective_start_date);

   --Declare local variable
   l_count number;
BEGIN
   OPEN  reg_exist_cursor;
   FETCH reg_exist_cursor INTO  l_count;
   CLOSE reg_exist_cursor;
   IF l_count>0 THEN
    fnd_message.set_name('PQP','PQP_230728_VEH_EXISTS');
    fnd_message.raise_error;
   END IF;
EXCEPTION
--------
WHEN no_data_found THEN
NULL;
End;

------------------------------------------------------------------------------
----------------------Used to get Columnname for Configuration table----------
------------------------------------------------------------------------------
--This function will be used to get column Name for SegmentName
--Why we used this function is,If there will be any future changes in
--configuration table column structure then we will have to change the column
--names only with in this function.
--It always will call from pqp_get_config_value function.

FUNCTION pqp_get_colname
          (p_segment_name           IN  VARCHAR2,--Segment Name
           p_information_category   IN  VARCHAR2 --Information category
	  ) RETURN VARCHAR2 IS

  l_column_name  VARCHAR2(30) ;

  BEGIN
   IF     p_segment_name   = 'CalculationMethod'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION1';
   ELSIF  p_segment_name = 'MaxCmyVehAllow'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION2';
   ELSIF  p_segment_name = 'MaxPriVehAllow'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION3';
   ELSIF  p_segment_name = 'ShareCmyCar'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION4';
   ELSIF  p_segment_name = 'SharePriCar'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION5';
   ELSIF  p_segment_name = 'PreTaxYearClmVldUntil'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION6';
   ELSIF  p_segment_name = 'AllowCmyPriVehClms'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION7';
   ELSIF  p_segment_name = 'SrchCriteriaRtTbl'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION8';
   ELSIF  p_segment_name = 'ValidatePriVehClmsInRep'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION9';
   ELSIF  p_segment_name = 'VehClmsCrectionPrdInDays'
      AND p_information_category = 'PQP_VEHICLE_MILEAGE' THEN
          l_column_name := 'PCV_INFORMATION10';
   ELSIF  p_segment_name = 'OwnerShip'
      AND p_information_category = 'GB_VEHICLE_CALC_INFO' THEN
          l_column_name := 'PCV_INFORMATION1';
   ELSIF  p_segment_name = 'UsageType'
      AND p_information_category = 'GB_VEHICLE_CALC_INFO' THEN
          l_column_name := 'PCV_INFORMATION2';
   ELSIF  p_segment_name = 'VehicleType'
      AND p_information_category = 'GB_VEHICLE_CALC_INFO' THEN
          l_column_name := 'PCV_INFORMATION3';
   ELSIF  p_segment_name = 'Fueltype'
      AND p_information_category = 'GB_VEHICLE_CALC_INFO' THEN
          l_column_name := 'PCV_INFORMATION4';
   ELSIF  p_segment_name = 'RatesTable'
      AND p_information_category = 'GB_VEHICLE_CALC_INFO' THEN
          l_column_name := 'PCV_INFORMATION5';
   ELSIF  p_segment_name = 'ClaimElement'
      AND p_information_category = 'GB_VEHICLE_CALC_INFO' THEN
          l_column_name := 'PCV_INFORMATION6';
   END IF;
   RETURN l_column_name ;
 END pqp_get_colname;
  --End of pqp_get_colname
--------------------------------------------------------------------------------
-------------------This is used to get the Configuration value-----------------
--------------------------------------------------------------------------------
--Used to get the configuration value based on either business groupId
--or legislation Id
--If there is value at business groupId ,then it will return that value
--otherwise it will returns legistation specific value

FUNCTION pqp_get_config_value
             (p_business_group_id    IN  NUMBER,
              p_legislation_code     IN  VARCHAR2,
              p_seg_col_name         IN  VARCHAR2,  -- Col Value to be found
              p_table_name           IN  VARCHAR2,  -- Table Name
              p_information_category IN  VARCHAR2
	     ) RETURN VARCHAR2 IS

--Local variable declaration
    l_column_value         VARCHAR(50);
    l_column_name          VARCHAR(50);
    TYPE ref_csr_typ  IS   REF CURSOR;
    c_column_cursor        ref_csr_typ;
    l_temp_str             VARCHAR2(1000);
BEGIN
  -- Call funtion to get the specific columnName for segment and category
  BEGIN
  --Used to get the column name for Segment name .
  l_column_name := pqp_get_colname(p_seg_col_name,p_information_category);
  END;

  l_temp_str := 'SELECT '|| l_column_name ||'
                   FROM  (SELECT '|| l_column_name ||'
                   FROM  pqp_configuration_values
                  WHERE  ((business_group_id = ' ||p_business_group_id ||'
                    AND  legislation_code IS NULL )
                     OR  (business_group_id IS NULL
                    AND  legislation_code =
		         '||''''||p_legislation_code ||''''||')
                    OR (business_group_id IS NULL
                    AND legislation_code IS NULL))
                    AND  PCV_INFORMATION_CATEGORY =
		        '|| ''''||p_information_category ||''''||'
                  ORDER  BY business_group_id,legislation_code )
		  WHERE  ROWNUM=1' ;

 OPEN c_column_cursor FOR l_temp_str;
 FETCH c_column_cursor INTO l_column_value;
 CLOSE c_column_cursor;
 RETURN l_column_value;
END pqp_get_config_value;
-- end function
----------------------------------------------------------------------------
---------------Used to get the fiscal ratings-------------------------------
----------------------------------------------------------------------------
--Used to get the fiscal ratings UOM value for business groupId
PROCEDURE get_uom_fiscal_ratings
               (p_business_group_id  IN   NUMBER
               ,p_meaning            OUT  NOCOPY VARCHAR2
 	       ) IS
   CURSOR fiscal_cursor IS
   SELECT meaning
     FROM hr_lookups
    WHERE lookup_type = 'PQP_FISCAL_RATINGS_UOM'
      AND enabled_flag    = 'Y';

     --Local variables
     l_meaning           hr_lookups.meaning%TYPE;
     l_legislation_code  pqp_configuration_values.legislation_code%TYPE;
Begin

   --Getting the legislationId for business groupId
   l_legislation_code :=
                  pqp_vre_bus.get_legislation_code(p_business_group_id);
   --setting the lg context
   hr_api.set_legislation_context(l_legislation_code);
   OPEN fiscal_cursor;
   FETCH fiscal_cursor INTO  l_meaning;
   CLOSE fiscal_cursor;
   p_meaning := NVL(l_meaning,'NONE');
EXCEPTION
WHEN no_data_found THEN
 p_meaning := 'NONE';
NULL;
End ;

-- ----------------------------------------------------------------------------
-- |------------------------< Used to check the lookup codes >-----------------
-- ----------------------------------------------------------------------------
--Used to check the passed lookup code is correct or not
FUNCTION chk_lookup
           (p_vehicle_repository_id  IN  NUMBER
	   ,p_lookup_type            IN  VARCHAR2
   	   ,p_lookup_code            IN  VARCHAR2
           ,p_effective_date         IN  DATE
           ,p_validation_start_date  IN  DATE
           ,p_validation_end_date    IN  DATE
	   ) RETURN NUMBER IS
 BEGIN
       --
       --  If argument value is not null then
       --  Check if the argument value exists in hr_lookups
       --  where the lookup_type is passed lookuptype
       --
       IF p_lookup_code IS NOT NULL then
           IF hr_api.not_exists_in_dt_hrstanlookups
             (p_effective_date        => p_effective_date
             ,p_validation_start_date => p_validation_start_date
             ,p_validation_end_date   => p_validation_end_date
             ,p_lookup_type           => p_lookup_type
             ,p_lookup_code           => p_lookup_code
             ) THEN
          RETURN -1;
         END IF;
       END IF;
  RETURN 0;
 END;

/*  CURSOR csr_lookup(cp_argument_value VARCHAR2,cp_lookup_type VARCHAR2) IS
  SELECT lookup_code
    FROM hr_lookups hrl
   WHERE hrl.lookup_type = cp_lookup_type
     AND hrl.lookup_code = cp_argument_value
     AND enabled_flag    = 'Y';
BEGIN
--
-- Validation of the lookup value based on the lookup type
--
    OPEN  csr_lookup(p_argument_value,p_lookup_type);
    FETCH csr_lookup INTO  l_lookup_code;
    IF csr_lookup%NOTFOUND THEN
     p_message := p_argument || 'Value is wrong ';
    END IF;
    CLOSE csr_lookup;
    IF p_message IS NULL THEN
        RETURN 0;
    ELSE
        RETURN -1;
    END IF;
END check_lookup;
*/

/*
  This is used for checking all lookup types at once ,but now we removed this
  because individual calls to
 FUNCTION check_lookup
              (p_rec          IN    pqp_vre_shd.g_rec_type
              ,p_message      OUT   NOCOPY VARCHAR2
	      ) RETURN NUMBER IS

    CURSOR csr_lookup(cp_argument_value VARCHAR2,cp_lookup_type VARCHAR2) IS
    SELECT COUNT(rowid)
      FROM hr_lookups hrl
     WHERE hrl.lookup_type = cp_lookup_type
       AND hrl.lookup_code = cp_argument_value
       AND enabled_flag    = 'Y';

  l_lookup_code     hr_lookups.lookup_code%TYPE;
  l_lookup_count    NUMBER;
BEGIN
--
-- Validation of the lookup value based on the lookup type
--

    IF p_rec.vehicle_ownership IS NOT NULL THEN
       OPEN csr_lookup(p_rec.vehicle_ownership,'PQP_VEHICLE_OWNERSHIP_TYPE');
       FETCH csr_lookup INTO  l_lookup_count;
       CLOSE csr_lookup;
        IF  l_lookup_count = 0  THEN
          p_message := 'Vehicle Ownership value is wrong ';
          RETURN -1;
        END IF;
    END IF;
    --This is for Vehicle Status lookup
    IF  p_rec.vehicle_status IS NOT NULL THEN
       OPEN csr_lookup(p_rec.vehicle_status,'PQP_VEHICLE_STATUS');
       FETCH csr_lookup INTO  l_lookup_count;
       CLOSE csr_lookup;
       IF  l_lookup_count = 0  THEN
         p_message := 'Vehicle Status value is wrong';
         RETURN -1;
       END IF;
    END IF;
    --This is for Fuel Type lookup
    IF p_rec.fuel_type IS NOT NULL THEN
       OPEN csr_lookup(p_rec.fuel_type,'PQP_FUEL_TYPE');
       FETCH csr_lookup INTO  l_lookup_count;
       CLOSE csr_lookup;
       IF  l_lookup_count = 0  THEN
         p_message := 'Fuel Type value is wrong';
         RETURN -1;
       END IF;
     END IF;
     --Vehicle Type lookup check
     IF p_rec.vehicle_type IS NOT NULL THEN
       --Check if it is pedal Cycle then user cannot creat repository
       IF p_rec.vehicle_type = 'P' THEN
        p_message := 'Pedal Cycle for vehicle type is not' ||
  	              || 'allowed for Repository';
        RETURN -1;
       END IF;
       OPEN csr_lookup(p_rec.vehicle_type, 'PQP_VEHICLE_TYPE');
       FETCH csr_lookup INTO  l_lookup_count;
       CLOSE csr_lookup;
       IF  l_lookup_count = 0  THEN
         p_message := 'Vehicle Type value is wrong';
         RETURN -1;
       END IF;
     END IF;
    RETURN 0;
END check_lookup;
*/

-----------------------------------------------------------------------------
------------------------<Update Validate for Regnum>-------------------------
----------------------------------------------------------------------------
--Used to check is there any ragistraion number change at update time.
--If there is any change in reg number then throw error
PROCEDURE validate_regnum
           (p_rec                     in pqp_vre_shd.g_rec_type
           ,p_effective_date          in date
           ,p_datetrack_mode          in varchar2
           ,p_validation_start_date   in date
           ,p_validation_end_date     in date
           ) IS
BEGIN
 IF p_rec.registration_number<> pqp_vre_shd.g_old_rec.registration_number THEN
   fnd_message.set_name('PQP', 'PQP_230727_REGNUM_UPD_RSTRICT');
   fnd_message.raise_error;
 END IF;
END;
--
---------------------------------------------------------------------------
-----------------Ownership Change Check-----------------------------------
---------------------------------------------------------------------------
--The change in the Ownership at update time must pop a warning message
--is given to the user if the vehicle is assigned to employee to
--indicate the change has to be done in the assignment on the usage type.

FUNCTION  pqp_check_ownership_change
              (p_rec                IN   pqp_vre_shd.g_rec_type
              ,p_effective_date     IN   DATE
              ,p_message            OUT  NOCOPY VARCHAR2
	      ) RETURN NUMBER IS

--Getting the allocation count for repositoryId
CURSOR  c_alloc_count_cursor IS
 SELECT COUNT(vehicle_allocation_id)
   FROM pqp_vehicle_allocations_f
  WHERE vehicle_repository_id = p_rec.vehicle_repository_id
    AND (p_effective_date between effective_start_date and effective_end_date
     OR p_effective_date <= effective_start_date)
    AND business_group_id = p_rec.business_group_id;

 l_rowcount NUMBER;

BEGIN
  hr_utility.set_location('Entering pqp_check_ownership_change',45);
  OPEN c_alloc_count_cursor;
  FETCH c_alloc_count_cursor INTO l_rowcount;
  CLOSE c_alloc_count_cursor;

   IF l_rowcount > 0 THEN

       IF pqp_vre_shd.g_old_rec.vehicle_ownership
                              <> p_rec.vehicle_ownership THEN
          p_message :='There is allocation for this vehicle, '||
	             ' Please change the allocation usage type';
          RETURN -1;
       END IF;

    END IF ;
  RETURN 0;
END pqp_check_ownership_change;
-- end pqp_ownership_check

------------------------------------------------------------------------------
-----------------Vehicle Status Change from Active to Inactive----------------
------------------------------------------------------------------------------
--Updating a status from 'Active' to 'Inactive' must show a warning message
--if the vehicle is being used by employees,indicating that
--the vehicle cannot be claimed for mileage by an employee during Inactive
--period
--
FUNCTION pqp_check_veh_status
               ( p_vehicle_repository_id    IN   NUMBER
		,p_business_group_id        IN   NUMBER
		,p_vehicle_status           IN   VARCHAR2
                ,p_effective_date           IN   DATE
                ,p_message                  OUT  NOCOPY VARCHAR2
	       ) RETURN NUMBER IS
--Getting the vehicle allocation count for repositoryId
  CURSOR c_alloc_count_cursor IS
  SELECT pvr.vehicle_status ,1 test
    FROM PQP_VEHICLE_ALLOCATIONS_F pva,pqp_vehicle_repository_f pvr
   WHERE pva.vehicle_repository_id= p_vehicle_repository_id
     AND pva.vehicle_repository_id =pvr.vehicle_repository_id
     AND pva.business_group_id = pvr.business_group_id
     AND (p_effective_date between pva.effective_start_date
          AND pva.effective_end_date
           OR p_effective_date <= pva.effective_start_date)
     AND (p_effective_date between pvr.effective_start_date
          AND pvr.effective_end_date
           OR p_effective_date <= pvr.effective_start_date)
     AND pva.business_group_id = p_business_group_id;

  --Declare local variables
  l_vehicle_status  pqp_vehicle_repository_f.vehicle_status%TYPE;
  l_test_number     NUMBER;

BEGIN
  OPEN  c_alloc_count_cursor;
  FETCH c_alloc_count_cursor INTO l_vehicle_status,l_test_number;
  CLOSE c_alloc_count_cursor ;
  --check for original vehicle status ,if it is Active then check
  --current status
  IF l_vehicle_status = 'A' THEN
    IF p_vehicle_status = 'I' THEN
        IF l_test_number = 1 THEN
        --If record exist then returns -1
         p_message :='There is allocations for this Vehicle,'||
	       ' So User cannot be  change the vehicle status from Active '||
	        ' to InActive';
         RETURN -1;
        END IF ;
    END IF ;
  END IF;
  RETURN 0;
END pqp_check_veh_status;
-- end function
-----------------------------------------------------------------------------
----------------------Share Vehicle Across Employees-------------------------
-----------------------------------------------------------------------------
--Share Across Employees Field has marked the car as shared car,
--then the user updates it as not a shared car at this point a check
--need to be given to see if the car has been shared between the different
--persons and if it has been shared  then an error message to be given to
--user indicating the car has been shared and need to go and
--unallocated the car for employees and make this change.

FUNCTION pqp_check_shared_veh
               (p_rec             IN   pqp_vre_shd.g_rec_type,
                p_effective_date  IN   DATE ,
                p_message         OUT  NOCOPY VARCHAR2
	       ) RETURN NUMBER IS

   --Getting the all personIds which are allocated to this
   --vehicle repositoryId
     CURSOR  c_alloc_count_cursor IS
     SELECT  paa.person_id
       FROM  pqp_vehicle_allocations_f pva
            ,per_all_assignments_f    paa
      WHERE  pva.vehicle_repository_id=p_rec.vehicle_repository_id
        AND  paa.assignment_id=pva.assignment_id
	AND  pva.business_group_id=p_rec.business_group_id
        AND  p_effective_date
	     BETWEEN paa.effective_start_date
	         AND paa.effective_end_date
        AND  (p_effective_date
	     BETWEEN pva.effective_start_date
	         AND pva.effective_end_date
       	          OR p_effective_date < pva.effective_start_date);

  --Local variables declaration
  l_person_id       NUMBER;
  l_temp_person_id  NUMBER;
  l_count           NUMBER := 0;

BEGIN
   hr_utility.set_location('Entering pqp_check_shared_veh',45);

 --If ShareVehicle is 'N' then check the value of original
 --shared vehicle value
 IF p_rec.shared_vehicle = 'N' THEN

    IF pqp_vre_shd.g_old_rec.shared_vehicle = 'Y' THEN

      --Check value existence in allcations table
      OPEN c_alloc_count_cursor;
      LOOP
          FETCH c_alloc_count_cursor INTO l_person_id;
	   EXIT when c_alloc_count_cursor%NOTFOUND ;
           --If it is first iteration

           IF l_count  = 0 THEN
               --if count is zero then assign personId to TempPersonId
               l_temp_person_id := l_person_id;
               l_count :=l_count+1;
           ELSE
              --If Vehicle is assigned to multiple personId's
	      --then user cannot chage the shared status
              IF l_temp_person_id <> l_person_id THEN
	        hr_utility.set_location('Assigned to two different persons',45);
                close c_alloc_count_cursor ;
		p_message := 'Vehicle is allocated to multilpe personIds ' ||
		 ' So user cannot change the Shared Status ';
                RETURN -1;
              END IF;
              -- increse the count by 1
              l_count :=l_count+1;
           END IF;
      END LOOP ;

     close c_alloc_count_cursor ;
   END IF ;
 END IF;
RETURN 0;
END pqp_check_shared_veh;
-- end function
---------------------------------------------------------------------------
------------------------<Check Mandatory Fields>-------------------------
---------------------------------------------------------------------------
FUNCTION chk_mandatory
           (p_argument         IN   VARCHAR2,
            p_argument_value   IN   VARCHAR2,
	    p_message          OUT  NOCOPY VARCHAR2
	   ) RETURN NUMBER IS
BEGIN

    IF p_argument_value IS NULL THEN
       p_message := p_argument || 'Value should be Mandatory';
       RETURN -1;
    END IF;
    RETURN 0;
END chk_mandatory;

/*
 This is used checking all mandatory values at once
 removed this functin and made individual calls
FUNCTION chk_mandatory
             ( p_rec             IN   pqp_vre_shd.g_rec_type
              ,p_message         OUT  NOCOPY VARCHAR2
	     ) RETURN NUMBER IS
BEGIN
 IF p_rec.vehicle_ownership IS NULL THEN
     p_message := 'Vehicle ownership is mandatory';
     RETURN -1;
 ELSIF p_rec.vehicle_type IS NULL THEN
     p_message := 'Vehicle type is mandatory';
     RETURN -1;
 ELSIF p_rec.registration_number IS NULL THEN
     p_message := 'Registration Number is mandatory';
     RETURN -1;
 ELSIF p_rec.make IS NULL THEN
     p_message := 'Make is mandatory';
     RETURN -1;
 ELSIF p_rec.model IS NULL THEN
     p_message := 'Model is mandatory';
     RETURN -1;
 ELSIF p_rec.engine_capacity_in_cc IS NULL THEN
     p_message := 'Engine Capacity in CC is mandatory';
     RETURN -1;
 ELSIF p_rec.fuel_type IS NULL THEN
     p_message := 'Fuel Type  is mandatory';
     RETURN -1;
 ELSIF p_rec.vehicle_status IS NULL THEN
     p_message := 'Vehicle Status is mandatory';
     RETURN -1;
 END IF;
 RETURN 0;
END chk_mandatory; */
--------------------------------------------------------------------------
------------------Purge delete validation---------------------------------
---------------------------------------------------------------------------
--Purge means the data is completely zapped from the database
--but again the error message is given if the vehicle has been assigned to
--an employee
FUNCTION pqp_purge_delete_veh
             (p_rec                    IN  pqp_vre_shd.g_rec_type,
              p_effective_date         IN  DATE ,
              p_message                OUT NOCOPY VARCHAR2
	     ) RETURN VARCHAR2 IS
 --Getting the allocation count for past ,future and current date tracks
 /*CURSOR  c_pesron_names_cursor IS
  SELECT distinct papf.title ||' '||papf.first_name ||' '|| papf.last_name
   FROM  pqp_vehicle_allocations_f pva
        ,per_all_assignments_f    paa
        ,per_people_f papf
  WHERE  pva.vehicle_repository_id=p_rec.vehicle_repository_id
    AND  paa.assignment_id=pva.assignment_id
    AND  papf.person_id=paa.person_id
    AND  (p_effective_date
           BETWEEN  papf.effective_start_date AND papf.effective_end_date
                OR  p_effective_date <= papf.effective_start_date
                OR  p_effective_date >= papf.effective_start_date )
    AND  (p_effective_date
           BETWEEN  paa.effective_start_date AND paa.effective_end_date
                OR  p_effective_date <= paa.effective_start_date
                OR  p_effective_date >= paa.effective_start_date )
    AND  (p_effective_date
           BETWEEN pva.effective_start_date AND pva.effective_end_date
                OR  p_effective_date <= pva.effective_start_date
                OR  p_effective_date >= pva.effective_start_date ); */
CURSOR  c_pesron_names_cursor IS
  SELECT distinct hl.meaning ||' '||papf.first_name ||' '|| papf.last_name
   FROM  pqp_vehicle_allocations_f pva
        ,per_all_assignments_f    paa
        ,per_people_f papf
        ,hr_lookups            hl
  WHERE  pva.vehicle_repository_id=p_rec.vehicle_repository_id
    AND  paa.assignment_id=pva.assignment_id
    AND  papf.person_id=paa.person_id
    and  hl.lookup_code=papf.title
    and  hl.lookup_type = 'TITLE'
    and  enabled_flag    = 'Y'
    AND  (p_effective_date
           BETWEEN  papf.effective_start_date AND papf.effective_end_date
                OR  p_effective_date <= papf.effective_start_date
                OR  p_effective_date >= papf.effective_start_date )
    AND  (p_effective_date
           BETWEEN  paa.effective_start_date AND paa.effective_end_date
                OR  p_effective_date <= paa.effective_start_date
                OR  p_effective_date >= paa.effective_start_date );


 --local variables declaration
 l_person_name per_All_people_f.full_name%TYPE ;
 temp_name_str varchar2(2000);

BEGIN
      OPEN c_pesron_names_cursor;
      LOOP
           FETCH c_pesron_names_cursor INTO l_person_name;
	   EXIT when c_pesron_names_cursor%NOTFOUND ;
              --Append all allocated personNames in string to display on UI.
	      IF temp_name_str IS NOT NULL THEN
  	        temp_name_str := temp_name_str ||', ' ||l_person_name;
	      ELSE
	        temp_name_str := l_person_name;
	      END IF;
      END LOOP ;
      CLOSE c_pesron_names_cursor ;
      p_message := 'This vehicle has been assigned to an employee,so please '||
	' delete that allocation entry';
      RETURN temp_name_str;
END pqp_purge_delete_veh;
-- end function
-------------------------------------------------------------------------------
-------------Delete End date -------------------------------------------------
------------------------------------------------------------------------------
--End date: This end dates a record in repository but an error
--message will be given if the user is still using the vehicle.
--The user must end date all the allocations and then end date repository data.
--
FUNCTION pqp_enddate_delete_veh
              (p_rec                    IN  pqp_vre_shd.g_rec_type,
               p_effective_date         IN  DATE ,
               p_message                OUT NOCOPY VARCHAR2
	      ) RETURN VARCHAR2 IS

--Getting the allocation count for current and future date tracks
 CURSOR  c_pesron_names_cursor IS
 SELECT  distinct hl.meaning ||' '||papf.first_name ||' '|| papf.last_name
   FROM  pqp_vehicle_allocations_f pva
        ,per_all_assignments_f    paa
        ,per_people_f papf
        ,hr_lookups            hl
  WHERE  pva.vehicle_repository_id=p_rec.vehicle_repository_id
    AND  paa.assignment_id=pva.assignment_id
    AND  papf.person_id=paa.person_id
    and  hl.lookup_code=papf.title
    AND  hl.lookup_type = 'TITLE'
    and  enabled_flag    = 'Y'
    AND  (p_effective_date
           BETWEEN  papf.effective_start_date AND papf.effective_end_date
                OR  p_effective_date <= papf.effective_start_date )
    AND  (p_effective_date
           BETWEEN  paa.effective_start_date AND paa.effective_end_date
                OR  p_effective_date <= paa.effective_start_date )
    AND (p_effective_date
           BETWEEN pva.effective_start_date AND pva.effective_end_date
                OR  p_effective_date <= pva.effective_start_date );

 --Declare slocal variables
 l_person_name per_All_people_f.full_name%TYPE ;
 temp_name_str varchar2(2000);

BEGIN
      OPEN c_pesron_names_cursor;
      LOOP
         FETCH c_pesron_names_cursor INTO l_person_name;
	   EXIT when c_pesron_names_cursor%NOTFOUND ;

	      IF temp_name_str IS NOT NULL THEN
  	        temp_name_str := temp_name_str ||', ' ||l_person_name;
	      ELSE
	        temp_name_str := l_person_name;
	      END IF;

      END LOOP ;
      CLOSE c_pesron_names_cursor ;
      p_message := 'This vehicle has been assigned to an employee,so please '||
	' delete that allocation entry';
      RETURN temp_name_str;
END pqp_enddate_delete_veh;
-- end function
-----------------------------------------------------------------------------
-----------------------Get the legistionId for BusinessGroupId---------------
-----------------------------------------------------------------------------
FUNCTION get_legislation_code
                 (p_business_group_id IN NUMBER
		 ) RETURN VARCHAR2 IS
   --declare local variables
   l_legislation_code  per_business_groups.legislation_code%TYPE;

   CURSOR c_get_leg_code IS
   SELECT legislation_code
    FROM  per_business_groups_perf
    WHERE business_group_id =p_business_group_id;

 BEGIN
   OPEN c_get_leg_code;
   LOOP
      FETCH c_get_leg_code INTO l_legislation_code;
      EXIT WHEN c_get_leg_code%NOTFOUND;
   END LOOP;
   CLOSE c_get_leg_code;
   RETURN (l_legislation_code);
 EXCEPTION
 ---------
 WHEN OTHERS THEN
 RETURN(NULL);
 END;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) is

--
  l_proc        varchar2(72) := g_package||'insert_validate';
  l_return_status NUMBER ;
  l_message VARCHAR2(2500) ;
  l_currency_code  pqp_vehicle_repository_f.currency_code%TYPE;
  l_share_conf_value pqp_vehicle_repository_f.shared_vehicle%TYPE;
  l_legislation_code  varchar2(150);
--

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 => pqp_vre_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --Checking the unique regNumber
  chk_unique_regnum
  (p_rec                   =>p_rec
  ,p_effective_date        =>p_effective_date
  ,p_datetrack_mode        =>p_datetrack_mode
  ,p_validation_start_date =>p_validation_start_date
  ,p_validation_end_date   =>p_validation_end_date
  );

   --Checking the unique Iden Number
  --Fix #3693656
 IF p_rec.vehicle_id_number is not null THEN
  chk_unique_idennum
  (p_rec                   =>p_rec
  ,p_effective_date        =>p_effective_date
  ,p_datetrack_mode        =>p_datetrack_mode
  ,p_validation_start_date =>p_validation_start_date
  ,p_validation_end_date   =>p_validation_end_date
  ,p_update_flag           =>'N'
  );
  END IF;


     --Getting the legislationId for business groupId
  l_legislation_code :=
                    get_legislation_code(p_rec.business_group_id);

 --Added by sshetty as the registration number is
 --non mandatory for global company vehicles
 --but mandatory for UK leg
 --for both company and private vehicles.

--Global requirement to make Model mandatory.
   l_return_status := chk_mandatory(
                          p_argument        =>'Model'
                         ,p_argument_value  =>p_rec.registration_number
                         ,p_message         =>l_message);

   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Model');
    fnd_message.raise_error;
   END IF;
 -- Added by gattu for phase 2
 IF  p_rec.vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
 --Added to check the listprice is mandatory for Irish leg
  IF l_legislation_code in ('IE','GB','PL') THEN
   l_return_status := chk_mandatory(
                          p_argument        =>'ListPrice'
                         ,p_argument_value  =>p_rec.list_price
                         ,p_message         =>l_message);

   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','List Price');
    fnd_message.raise_error;
   END IF;
  END IF;

 --Taxation Method is Mandatory for German Leg and should have values
 --Flate rate and Mileage Book
  IF l_legislation_code = 'DE' THEN
   l_return_status := chk_mandatory(
                           p_argument        =>'Taxation Method'
                          ,p_argument_value  =>p_rec.taxation_method
                          ,p_message         =>l_message);

   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Taxation Method');
    fnd_message.raise_error;
   END IF;
  --If taxation method value exist then check for value validation for german
   l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_TAXATION_METHOD'
                     ,p_lookup_code            => p_rec.taxation_method
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP','PQP_230114_VLD_TAXATION_CDE');
    fnd_message.raise_error;
   END IF;
  END IF;
 END IF;

  --Checking vehicle_ownership Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'Vehicle Ownership'
                      ,p_argument_value  => p_rec.vehicle_ownership
                      ,p_message         => l_message);

  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Vehicle Ownership');
    fnd_message.raise_error;
  END IF;

  --Checking Vehicle Type Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'vehicle_type'
                      ,p_argument_value  => p_rec.vehicle_type
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Vehicle Type');
    fnd_message.raise_error;
  END IF;


   --Checking Registration Number Mandatory
--Added by sshetty as the registration number is
 --non mandatory for global company vehicles
 --but mandatory for UK leg
 --for both company and private vehicles.
  IF l_legislation_code = 'GB' THEN
   l_return_status := chk_mandatory(
                          p_argument        =>'Registration Number'
                         ,p_argument_value  =>p_rec.registration_number
                         ,p_message         =>l_message);

   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Registration Number');
    fnd_message.raise_error;
   END IF;
  END IF;

   --Checking Make Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'make'
                      ,p_argument_value  => p_rec.make
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Make');
    fnd_message.raise_error;
  END IF;

  --Checking Model Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'Model'
                      ,p_argument_value  => p_rec.model
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Model');
    fnd_message.raise_error;
  END IF;

    --Checking EngineCapacity Mandatory
 IF l_legislation_code = 'GB' OR l_legislation_code = 'PL' THEN
  l_return_status := chk_mandatory(
                       p_argument        =>'Engine Capacity'
                      ,p_argument_value  => p_rec.engine_capacity_in_cc
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Engine Capacity');
    fnd_message.raise_error;
  END IF;

 --Checking Fueltype Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'fuelType'
                      ,p_argument_value  => p_rec.fuel_type
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Fuel Type');
    fnd_message.raise_error;
  END IF;
 END IF;
  --Checking vehicleStatus Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'VehicleStatus'
                      ,p_argument_value  => p_rec.vehicle_status
		      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Vehicle Status');
    fnd_message.raise_error;
  END IF;


   --Checking Ownership lookup validation
  l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_OWNERSHIP_TYPE'
                     ,p_lookup_code            => p_rec.vehicle_ownership
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP','PQP_230741_VLD_OWNRSHP_CDE');
    fnd_message.raise_error;
  END IF;

  --Checking vehicle_status lookup validation
    l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_STATUS'
                     ,p_lookup_code            => p_rec.vehicle_status
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP','PQP_230742_VLD_STATUS_CDE');
    fnd_message.raise_error;
  END IF;

  --Checking Fuel Type lookup validation
   l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_FUEL_TYPE'
                     ,p_lookup_code            => p_rec.fuel_type
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP','PQP_230743_VLD_FUEL_TYP');
    fnd_message.raise_error;
  END IF;

   --Checking Vehicle Type lookup validation
   l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_TYPE'
                     ,p_lookup_code            => p_rec.vehicle_type
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP','PQP_230744_VLD_VEH_TYP');
    fnd_message.raise_error;
  END IF;

  --Checking If Vehicle Status is Inactive then inactive reason with lookup
  IF p_rec.vehicle_status = 'I' THEN
      --Checking Vehicle reason lookup validation
     l_return_status := chk_lookup(
                      p_vehicle_repository_id=> p_rec.vehicle_repository_id
                     ,p_lookup_type          =>'PQP_VEHICLE_INACTIVE_REASONS'
                     ,p_lookup_code          => p_rec.vehicle_inactivity_reason
	             ,p_effective_date       => p_effective_date
                     ,p_validation_start_date=> p_validation_start_date
                     ,p_validation_end_date  => p_validation_end_date);
    IF l_return_status = -1 THEN
       fnd_message.set_name('PQP','PQP_230852_VEH_INACTIVE_REASON');
       fnd_message.raise_error;
     END IF;
  ELSE
      --If vehicle status is active then Inactive Reason should be NULL
      IF p_rec.vehicle_inactivity_reason IS NOT NULL THEN
         fnd_message.set_name('PQP','PQP_230853_INACTIVE_REASON_ERR');
         fnd_message.raise_error;
      END IF;
  END IF;

  --Checking the  mandatory fields for company vehicle
  IF  p_rec.vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
     --Check for initial_registration
      l_return_status := chk_mandatory(
                             p_argument        =>'Registration Number'
                            ,p_argument_value  =>p_rec.initial_registration
                            ,p_message         =>l_message);

      IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230738_COMP_OWNR_MNDTRY');
         fnd_message.set_token('TOKEN','Registration Number');
         fnd_message.raise_error;
      END IF;
       --Check for list_price
  END IF;


   --Getting the cmy veh Share Across Emp value from configuration table
    IF  p_rec.vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
     l_share_conf_value := PQP_GET_CONFIG_VALUE(
                             p_business_group_id   =>p_rec.business_group_id,
                             p_legislation_code    =>l_legislation_code,
                             p_seg_col_name        =>'ShareCmyCar',
                             p_table_name          =>'p_table_name',
                             p_information_category=>'PQP_VEHICLE_MILEAGE');

    hr_utility.set_location('Config cmy veh share val:'||l_share_conf_value,40);

     --If configuration value is 'N' then user shouldnot select the checkbox
     --If user selects then raise error
     IF l_share_conf_value = 'N' THEN
       IF p_rec.shared_vehicle = 'Y' THEN
          fnd_message.set_name('PQP','PQP_230720_COMP_CAR_NT_SHARED');
          fnd_message.raise_error;
       END IF;
     END IF;

   ELSE
    l_share_conf_value := PQP_GET_CONFIG_VALUE(
                            p_business_group_id    => p_rec.business_group_id,
                            p_legislation_code     => l_legislation_code,
                            p_seg_col_name         => 'SharePriCar',
                            p_table_name           => 'p_table_name',
                            p_information_category =>'PQP_VEHICLE_MILEAGE');

    hr_utility.set_location('Config pri veh share val:'||l_share_conf_value,40);

    IF l_share_conf_value = 'N' THEN
      IF p_rec.shared_vehicle = 'Y' THEN
         fnd_message.set_name('PQP', 'PQP_230721_PVT_CAR_NT_SHARED');
         fnd_message.raise_error;
      END IF;
    END IF;
   END IF;
  --handling multiple messages
  --catching all errors and adding to multi message package.
  EXCEPTION
  WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add
         (p_same_associated_columns => 'Y') THEN
      RAISE;
  END IF;
  -- After validating the set of important attributes
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  pqp_vre_bus.chk_ddf(p_rec);
  --
  pqp_vre_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validate
  (p_rec                     in pqp_vre_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) IS
--
  l_proc           VARCHAR2(72) := g_package||'update_validate';
  l_return_status  NUMBER ;
  l_message        VARCHAR2(2500) ;
  l_currency_code  pqp_vehicle_repository_f.currency_code%TYPE;
  l_legislation_code  varchar2(150);
  l_return_message varchar2(2000);

--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --


  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqp_vre_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');


  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );


  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );


  --cheking the regnumber change at update
  validate_regnum
  (p_rec                   =>p_rec
  ,p_effective_date        =>p_effective_date
  ,p_datetrack_mode        =>p_datetrack_mode
  ,p_validation_start_date =>p_validation_start_date
  ,p_validation_end_date   =>p_validation_end_date
  );

   --Checking the unique Iden Number
  --First check null ot not null
  --If not null ,then check if there is any change in update
  --If change then check if there is already exist
  --Fix #3693656
 IF p_rec.vehicle_id_number is not null THEN
  chk_unique_idennum
  (p_rec                   =>p_rec
  ,p_effective_date        =>p_effective_date
  ,p_datetrack_mode        =>p_datetrack_mode
  ,p_validation_start_date =>p_validation_start_date
  ,p_validation_end_date   =>p_validation_end_date
  ,p_update_flag           =>'Y'
  );
 END IF;


 --Getting the legislationId for business groupId
l_legislation_code :=
                    get_legislation_code(p_rec.business_group_id);

--Added by gattu for phase 2
IF  p_rec.vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
 --Added to check the listprice is mandatory for Irish leg
 IF l_legislation_code = 'IE' THEN
      l_return_status := chk_mandatory(
                               p_argument        =>'ListPrice'
                              ,p_argument_value  =>p_rec.list_price
                              ,p_message         =>l_message);

      IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
         fnd_message.set_token('FEILD','List Price');
         fnd_message.raise_error;
      END IF;
 END IF;

 --Taxation Method is Mandatory for German Leg and should have values
 --Flate rate and Mileage Book
 IF l_legislation_code = 'DE' THEN
      l_return_status := chk_mandatory(
                               p_argument        =>'Taxation Method'
                              ,p_argument_value  =>p_rec.taxation_method
                              ,p_message         =>l_message);

      IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
         fnd_message.set_token('FEILD','Taxation Method');
         fnd_message.raise_error;
      END IF;
  --If taxation method value exist then check for value validation for german
  l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_TAXATION_METHOD'
                     ,p_lookup_code            => p_rec.taxation_method
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP','PQP_230114_VLD_TAXATION_CDE');
    fnd_message.raise_error;
  END IF;
 END IF;
END IF;


 /* This check is removed from API....and calling from UI.
    Because this is warning not a error.
  --Checking the Vehicle Status change
  l_return_status := pqp_check_veh_status
                       (p_vehicle_repository_id  =>p_rec.vehicle_repository_id
                       ,p_business_group_id      =>p_rec.business_group_id
		       ,p_vehicle_status         => p_rec.vehicle_status
                       ,p_effective_date         =>p_effective_date
                       ,p_message                =>l_message
		       );

  IF l_return_status = -1 THEN
   fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
   fnd_message.set_token('PROCEDURE',l_message);
   fnd_message.raise_error;
  END IF;
  */

  --Checking the Ownership Change validation
  l_return_status := pqp_check_ownership_change
                         (p_rec             =>p_rec
                         ,p_effective_date  =>p_effective_date
                         ,p_message         => l_message
			 );
   IF l_return_status = -1 THEN
      -- added gattu to fix 3448070
      l_return_message := pqp_purge_delete_veh
                          (p_rec             =>p_rec
                          ,p_effective_date  =>p_effective_date
                          ,p_message         =>l_message
                          );
     fnd_message.set_name('PQP', 'PQP_230731_OWNRSHP_CHG_RSTRICT');
     fnd_message.set_token('NAME',l_return_message);
     fnd_message.raise_error;
   END IF;

  --Checking vehicle_ownership Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'OwnerShip'
                      ,p_argument_value  => p_rec.vehicle_ownership
                      ,p_message         => l_message);

  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','OwnerShip');
    fnd_message.raise_error;
  END IF;

  --Checking Vehicle Type Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'vehicle_type'
                      ,p_argument_value  => p_rec.vehicle_type
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Vehicle Type');
    fnd_message.raise_error;
  END IF;


   --Checking Registration Number Mandatory
  IF l_legislation_code ='GB' OR l_legislation_code ='PL' THEN
   l_return_status := chk_mandatory(
                       p_argument        =>'registration_number'
                      ,p_argument_value  => p_rec.registration_number
                      ,p_message         => l_message);
   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Registration Number');
    fnd_message.raise_error;
   END IF;
  END IF;

   --Checking Make Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'make'
                      ,p_argument_value  => p_rec.make
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Make');
    fnd_message.raise_error;
  END IF;

  --Checking Model Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'Model'
                      ,p_argument_value  => p_rec.model
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Model');
    fnd_message.raise_error;
  END IF;

    --Checking EngineCapacity Mandatory
    --Not required now to be mandatory as this is non mandatory
    --for global module and this is mandatory only for GB.
  IF l_legislation_code ='GB' OR l_legislation_code ='PL'THEN
   l_return_status := chk_mandatory(
                       p_argument        =>'Engine Capacity'
                      ,p_argument_value  => p_rec.engine_capacity_in_cc
                      ,p_message         => l_message);
   IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Engine Capacity');
    fnd_message.raise_error;
   END IF;
  END IF;
 --Checking Fueltype Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'fuelType'
                      ,p_argument_value  => p_rec.fuel_type
                      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Fuel Type');
    fnd_message.raise_error;
  END IF;

  --Checking vehicleStatus Mandatory
  l_return_status := chk_mandatory(
                       p_argument        =>'VehicleStatus'
                      ,p_argument_value  => p_rec.vehicle_status
		      ,p_message         => l_message);
  IF l_return_status = -1 THEN
    fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
    fnd_message.set_token('FEILD','Vehicle Status');
    fnd_message.raise_error;
  END IF;


  --Checking for value change
  IF ( nvl(pqp_vre_shd.g_old_rec.vehicle_status,hr_api.g_varchar2)
       <> nvl(p_rec.vehicle_status,hr_api.g_varchar2) ) THEN

     --Checking If Vehicle Status is Inactive then inactive reason is mandatory
     --and should check with lookup
      IF  p_rec.vehicle_status = 'I' THEN
        --Checking Vehicle Type lookup validation
        l_return_status := chk_lookup(
                      p_vehicle_repository_id=> p_rec.vehicle_repository_id
                     ,p_lookup_type          =>'PQP_VEHICLE_INACTIVE_REASONS'
                     ,p_lookup_code          => p_rec.vehicle_inactivity_reason
	             ,p_effective_date       => p_effective_date
                     ,p_validation_start_date=> p_validation_start_date
                     ,p_validation_end_date  => p_validation_end_date);
        IF l_return_status = -1 THEN
           fnd_message.set_name('PQP','PQP_230852_VEH_INACTIVE_REASON');
           fnd_message.raise_error;
        END IF;
   ELSE
      --If vehicle status is active then Inactive Reason should be NULL
      IF p_rec.vehicle_inactivity_reason IS NOT NULL THEN
         fnd_message.set_name('PQP','PQP_230853_INACTIVE_REASON_ERR');
         fnd_message.raise_error;
      END IF;

      END IF;
   END IF;

  --Checking for value change
  IF ( nvl(pqp_vre_shd.g_old_rec.vehicle_ownership,hr_api.g_varchar2)
       <> nvl(p_rec.vehicle_ownership,hr_api.g_varchar2) ) THEN
      --If not equal then Checking Ownership lookup validation
      l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_OWNERSHIP_TYPE'
                     ,p_lookup_code            => p_rec.vehicle_ownership
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

     IF l_return_status = -1 THEN
        fnd_message.set_name('PQP','PQP_230741_VLD_OWNRSHP_CDE');
       fnd_message.raise_error;
     END IF;
   END IF;

  --Checking for value change
  IF ( nvl(pqp_vre_shd.g_old_rec.vehicle_status,hr_api.g_varchar2)
       <> nvl(p_rec.vehicle_status,hr_api.g_varchar2) ) THEN
    --If not equal then Checking vehicle_status lookup validation
    l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_STATUS'
                     ,p_lookup_code            => p_rec.vehicle_status
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);

    IF l_return_status = -1 THEN
       fnd_message.set_name('PQP','PQP_230742_VLD_STATUS_CDE');
       fnd_message.raise_error;
    END IF;
  END IF;

  --Checking for value change
  IF ( nvl(pqp_vre_shd.g_old_rec.fuel_type,hr_api.g_varchar2)
       <> nvl(p_rec.fuel_type,hr_api.g_varchar2) ) THEN
    --Checking Fuel Type lookup validation
    l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_FUEL_TYPE'
                     ,p_lookup_code            => p_rec.fuel_type
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);
    IF l_return_status = -1 THEN
       fnd_message.set_name('PQP','PQP_230743_VLD_FUEL_TYP');
       fnd_message.raise_error;
    END IF;
  END IF;

  --Checking for value change
  IF ( nvl(pqp_vre_shd.g_old_rec.vehicle_type,hr_api.g_varchar2)
       <> nvl(p_rec.vehicle_type,hr_api.g_varchar2) ) THEN
      --Checking Vehicle Type lookup validation
      l_return_status := chk_lookup(
                      p_vehicle_repository_id  => p_rec.vehicle_repository_id
                     ,p_lookup_type            =>'PQP_VEHICLE_TYPE'
                     ,p_lookup_code            => p_rec.vehicle_type
	             ,p_effective_date         => p_effective_date
                     ,p_validation_start_date  => p_validation_start_date
                     ,p_validation_end_date    => p_validation_end_date);
    IF l_return_status = -1 THEN
       fnd_message.set_name('PQP','PQP_230744_VLD_VEH_TYP');
       fnd_message.raise_error;
    END IF;
  END IF;


  --Checking the  mandatory fields for company vehicle
     IF  p_rec.vehicle_ownership in ('C','PL_LEC','PL_LC') THEN
     --Check for initial_registration
      l_return_status := chk_mandatory(
                             p_argument        =>'Intial Registration Number'
                            ,p_argument_value  => p_rec.initial_registration
                            ,p_message         => l_message);

      IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230738_COMP_OWNR_MNDTRY');
         fnd_message.set_token('FEILD','Initial Registration');
         fnd_message.raise_error;
      END IF;
       --Check for list_price
      l_return_status := chk_mandatory(
                               p_argument        =>'ListPrice'
                              ,p_argument_value  => p_rec.list_price
                              ,p_message         => l_message);

      IF l_return_status = -1 THEN
         fnd_message.set_name('PQP', 'PQP_230738_COMP_OWNR_MNDTRY');
         fnd_message.set_token('FEILD','List Price');
         fnd_message.raise_error;
      END IF;
  END IF;


  -- Share Across Employees Field updation check
  l_return_status := pqp_check_shared_veh
                       (p_rec             =>p_rec
                       ,p_effective_date  =>p_effective_date
                       ,p_message         =>l_message
		       );
  IF l_return_status = -1 THEN
   fnd_message.set_name('PQP', 'PQP_230758_SHARE_EMP_CHG');
   fnd_message.raise_error;
  END IF;
 EXCEPTION
  WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add
        (
	  p_same_associated_columns => 'Y'
	) THEN
      RAISE;
   END IF;

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --

  pqp_vre_bus.chk_ddf(p_rec);
  --
  pqp_vre_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec                    IN pqp_vre_shd.g_rec_type
  ,p_effective_date         IN DATE
  ,p_datetrack_mode         IN VARCHAR2
  ,p_validation_start_date  IN DATE
  ,p_validation_end_date    IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'delete_validate';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_return_status NUMBER ;
  l_message VARCHAR2(2500) ;
  l_return_message varchar2(2000);
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_vehicle_repository_id            => p_rec.vehicle_repository_id
    );


  --Checking the vehicle availability before delete or purge.
  IF p_datetrack_mode = 'ZAP' THEN

     --This is for purge
     l_return_message := pqp_purge_delete_veh
                          (p_rec             =>p_rec
                          ,p_effective_date  =>p_effective_date
                          ,p_message         =>l_message
			  );

     hr_utility.set_location('Veh purge Delete Status :'||l_return_message,50);

     IF l_return_message IS NOT NULL THEN
        fnd_message.set_name('PQP', 'PQP_230730_VEH_DEL_RSTRICT');
        fnd_message.set_token('NAME',l_return_message);
        fnd_message.raise_error;
     END IF;
  ELSIF p_datetrack_mode = 'DELETE' THEN
     --This is for enddate
     l_return_message := pqp_enddate_delete_veh
                            ( p_rec            =>p_rec
                             ,p_effective_date =>p_effective_date
                             ,p_message        =>l_message
			     );

     hr_utility.set_location('Veh enddate Delete Status :'||l_return_message,55);

     IF l_return_message IS NOT NULL THEN
        fnd_message.set_name('PQP', 'PQP_230729_VEH_ENDDT_RSTRICT');
        fnd_message.set_token('NAME',l_return_message);
      fnd_message.raise_error;
     END IF;

  END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --handling multiple messages
--catching all errors and adding to multi message package.
  Exception
  when app_exception.application_exception then
   IF hr_multi_message.exception_add
         (p_same_associated_columns => 'Y') THEN
      RAISE;
  END IF;
  -- After validating the set of important attributes
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  hr_multi_message.end_validation_set;
End delete_validate;
--
end pqp_vre_bus;

/
