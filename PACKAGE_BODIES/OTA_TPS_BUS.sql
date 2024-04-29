--------------------------------------------------------
--  DDL for Package Body OTA_TPS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPS_BUS" AS
/* $Header: ottpsrhi.pkb 120.2 2005/12/14 15:17:58 asud noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tps_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  DEFAULT NULL;
g_training_plan_id            number         DEFAULT NULL;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE set_security_group_id
  (p_training_plan_id            IN ota_training_plans.training_plan_id%TYPE
  ,p_associated_column1          IN varchar2
  ) IS
  --
  -- Declare cursor
  --
  CURSOR csr_sec_grp IS
    SELECT inf.org_information14
      FROM hr_organization_information inf
         , ota_training_plans tps
     WHERE tps.training_plan_id = p_training_plan_id
       AND inf.organization_id  = tps.business_group_id
       AND    inf.org_information_context || '' = 'Business Group Information';
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'training_plan_id'
    ,p_argument_value     => p_training_plan_id
    );
  --
  OPEN csr_sec_grp;
  FETCH csr_sec_grp INTO l_security_group_id;
  --
  IF csr_sec_grp%NOTFOUND THEN
     --
     CLOSE csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    -- fnd_message.raise_error;
     -- MULTI MESSAGING
     hr_multi_message.add
                (p_associated_column1 => NVL(p_associated_column1,'TRAINING_PLAN_ID'));
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
    END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION return_legislation_code
  (p_training_plan_id                     IN     number
  )
  RETURN Varchar2 IS
  --
  -- Declare cursor
  --
  CURSOR csr_leg_code IS
    SELECT pbg.legislation_code
      FROM per_business_groups pbg
         , ota_training_plans tps
     WHERE tps.training_plan_id = p_training_plan_id
       AND pbg.business_group_id = tps.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'training_plan_id'
    ,p_argument_value     => p_training_plan_id
    );
  --
  IF ( NVL(ota_tps_bus.g_training_plan_id, hr_api.g_number)
       = p_training_plan_id) THEN
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_tps_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  ELSE
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    OPEN csr_leg_code;
    FETCH csr_leg_code INTO l_legislation_code;
    --
    IF csr_leg_code%NOTFOUND THEN
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
    ota_tps_bus.g_training_plan_id  := p_training_plan_id;
    ota_tps_bus.g_legislation_code  := l_legislation_code;
  END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  RETURN l_legislation_code;
END return_legislation_code;
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
  (p_rec IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  IF ((p_rec.training_plan_id IS NOT NULL)  AND (
    NVL(ota_tps_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    NVL(p_rec.attribute_category, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    NVL(p_rec.attribute1, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    NVL(p_rec.attribute2, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    NVL(p_rec.attribute3, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    NVL(p_rec.attribute4, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    NVL(p_rec.attribute5, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    NVL(p_rec.attribute6, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    NVL(p_rec.attribute7, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    NVL(p_rec.attribute8, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    NVL(p_rec.attribute9, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    NVL(p_rec.attribute10, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    NVL(p_rec.attribute11, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    NVL(p_rec.attribute12, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    NVL(p_rec.attribute13, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    NVL(p_rec.attribute14, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    NVL(p_rec.attribute15, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    NVL(p_rec.attribute16, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    NVL(p_rec.attribute17, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    NVL(p_rec.attribute18, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    NVL(p_rec.attribute19, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    NVL(p_rec.attribute20, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    NVL(p_rec.attribute21, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    NVL(p_rec.attribute22, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    NVL(p_rec.attribute23, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    NVL(p_rec.attribute24, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    NVL(p_rec.attribute25, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    NVL(p_rec.attribute26, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    NVL(p_rec.attribute27, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    NVL(p_rec.attribute28, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    NVL(p_rec.attribute29, hr_api.g_varchar2)  OR
    NVL(ota_tps_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    NVL(p_rec.attribute30, hr_api.g_varchar2) ) )
    OR (p_rec.training_plan_id IS NULL)  THEN
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_TRAINING_PLANS'
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
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  (p_effective_date               IN date
  ,p_rec                          IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
BEGIN
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_tps_shd.api_updating
      (p_training_plan_id                     => p_rec.training_plan_id
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
  IF NVL(p_rec.business_group_id, hr_api.g_number) <>
     NVL(ota_tps_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'BUSINESS_GROUP_ID'
         ,p_base_table => ota_tps_shd.g_tab_nam);
  END IF;
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF NVL(p_rec.training_plan_id, hr_api.g_number) <>
     NVL(ota_tps_shd.g_old_rec.training_plan_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'TRAINING_PLAN_ID'
         ,p_base_table => ota_tps_shd.g_tab_nam);
  END IF;
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  IF NVL(p_rec.organization_id, hr_api.g_number) <>
     NVL(ota_tps_shd.g_old_rec.organization_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'ORGANIZATION_ID'
         ,p_base_table => ota_tps_shd.g_tab_nam);
  END IF;
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  IF NVL(p_rec.person_id, hr_api.g_number) <>
     NVL(ota_tps_shd.g_old_rec.person_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'PERSON_ID'
         ,p_base_table => ota_tps_shd.g_tab_nam);
  END IF;
  --
  EXCEPTION

    WHEN OTHERS THEN
       RAISE;
END chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_effective_date               IN date
  ,p_rec                          IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --Validate Important Attributes
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
                             ,p_associated_column1 => ota_tps_shd.g_tab_nam || '.BUSINESS_GROUP_ID');  -- Validate Bus Grp
  --
  hr_multi_message.end_validation_set;

  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  ota_tps_bus1.chk_org_person (
               p_organization_id        => p_rec.organization_id
              ,p_person_id              => p_rec.person_id
	      ,p_contact_id             =>  p_rec.contact_id);
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  ota_tps_bus1.chk_organization_id (
               p_organization_id        => p_rec.organization_id
              ,p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  ota_tps_bus1.chk_person_id (
               p_effective_date         => p_effective_date
              ,p_person_id              => p_rec.person_id
              ,p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  -- Set the Is_Per_Trng_Plan global variable
  IF p_rec.person_id IS NOT NULL OR p_rec.contact_id IS NOT NULL THEN
     OTA_TRNG_PLAN_UTIL_SS.g_is_per_trng_plan := TRUE;
  END IF;

  ota_tps_bus1.chk_plan_status_type_id (
               p_effective_date         => p_effective_date
              ,p_plan_status_type_id    => p_rec.plan_status_type_id);
  --
   hr_utility.set_location(' Step:'|| l_proc, 80);
  ota_tps_bus1.chk_currency_code (
               p_budget_currency        => p_rec.budget_currency
              ,p_training_plan_id       => p_rec.training_plan_id
              ,p_business_group_id      => p_rec.business_group_id
              ,p_object_version_number  => p_rec.object_version_number);
  --
  IF p_rec.learning_path_id IS NULL THEN
  hr_utility.set_location(' Step:'|| l_proc, 90);
  ota_tps_bus1.chk_name
               (p_name                   => p_rec.name
               ,p_training_plan_id       => p_rec.training_plan_id
               ,p_person_id              => p_rec.person_id  --Bug#3484692
	       ,p_contact_id             => p_rec.contact_id  --Bug#3855813
               ,p_business_group_id      => p_rec.business_group_id
               ,p_object_version_number  => p_rec.object_version_number );
  END IF;

  IF p_rec.person_id IS NOT NULL  OR p_rec.contact_id IS NOT NULL THEN
     hr_utility.set_location(' Step:'|| l_proc, 55);


     ota_tps_bus1.chk_tp_date_range
            (p_training_plan_id => p_rec.training_plan_id
            ,p_start_date => p_rec.start_date
            ,p_end_date => p_rec.end_date
            ,p_object_version_number => p_rec.object_version_number);

     ota_tps_bus1.chk_plan_source(
                p_effective_date => p_effective_date
               ,p_plan_source    => p_rec.plan_source
               ,p_training_plan_id => p_rec.training_plan_id);

  ELSIF p_rec.person_id IS NULL  AND p_rec.contact_id IS NULL THEN
  hr_utility.set_location(' Step:'|| l_proc, 60);
  ota_tps_bus1.chk_time_period_id (
               p_training_plan_id       => p_rec.training_plan_id
              ,p_object_version_number  => p_rec.object_version_number
              ,p_time_period_id         => p_rec.time_period_id
              ,p_business_group_id      => p_rec.business_group_id);
  --

  ota_tps_bus1.chk_unique (
               p_training_plan_id       => p_rec.training_plan_id
              ,p_object_version_number  => p_rec.object_version_number
              ,p_organization_id        => p_rec.organization_id
              ,p_person_id              => p_rec.person_id
              ,p_time_period_id         => p_rec.time_period_id );

  hr_utility.set_location(' Step:'|| l_proc, 70);
  ota_tps_bus1.chk_period_overlap (
               p_training_plan_id       => p_rec.training_plan_id
              ,p_object_version_number  => p_rec.object_version_number
              ,p_plan_status_type_id    => p_rec.plan_status_type_id
              ,p_time_period_id         => p_rec.time_period_id
              ,p_person_id              => p_rec.person_id
              ,p_organization_id        => p_rec.organization_id);
  --
  END IF;

   --
  ota_tps_bus.chk_df(p_rec);
  --
   hr_utility.set_location(' Leaving:'||l_proc, 100);
END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validate
  (p_effective_date               IN date
  ,p_rec                          IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_boolean boolean := null;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --Validate Important attribute

  hr_api.validate_bus_grp_id(p_rec.business_group_id
                            ,p_associated_column1 => ota_tps_shd.g_tab_nam || '.BUSINESS_GROUP_ID');  -- Validate Bus Grp
  --
  hr_multi_message.end_validation_set;

  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec                       => p_rec
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  -- Set the Is_Per_Trng_Plan global variable
  l_boolean := OTA_TRNG_PLAN_UTIL_SS.is_personal_trng_plan(p_rec.training_plan_id);

  ota_tps_bus1.chk_plan_status_type_id (
               p_effective_date         => p_effective_date
              ,p_plan_status_type_id    => p_rec.plan_status_type_id);
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);

  ota_tps_bus1.chk_currency_code (
               p_budget_currency        => p_rec.budget_currency
              ,p_training_plan_id       => p_rec.training_plan_id
              ,p_business_group_id      => p_rec.business_group_id
              ,p_object_version_number  => p_rec.object_version_number);
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);

  ota_tps_bus1.chk_name (
               p_name                   => p_rec.name
              ,p_training_plan_id       => p_rec.training_plan_id
              ,p_person_id              => p_rec.person_id  --Bug#3484692
              ,p_contact_id             => p_rec.contact_id  --Bug#3855813
              ,p_business_group_id      => p_rec.business_group_id
              ,p_object_version_number  => p_rec.object_version_number);
  --

  IF p_rec.person_id IS NOT NULL OR p_rec.contact_id IS NOT NULL THEN
  hr_utility.set_location(' Step:'|| l_proc, 15);

  ota_tps_bus1.chk_tp_date_range
            (p_training_plan_id => p_rec.training_plan_id
            ,p_start_date => p_rec.start_date
            ,p_end_date => p_rec.end_date
            ,p_object_version_number => p_rec.object_version_number);

  ota_tps_bus1.chk_plan_source(
                p_effective_date => p_effective_date
               ,p_plan_source    => p_rec.plan_source
               ,p_training_plan_id => p_rec.training_plan_id);

  END IF;
  --
  IF p_rec.person_id IS NULL AND p_rec.contact_id IS NULL THEN
  hr_utility.set_location(' Step:'|| l_proc, 20);
  ota_tps_bus1.chk_time_period_id (
               p_training_plan_id       => p_rec.training_plan_id
              ,p_object_version_number  => p_rec.object_version_number
              ,p_time_period_id         => p_rec.time_period_id
              ,p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

  ota_tps_bus1.chk_unique (
               p_training_plan_id       => p_rec.training_plan_id
              ,p_object_version_number  => p_rec.object_version_number
              ,p_organization_id        => p_rec.organization_id
              ,p_person_id              => p_rec.person_id
              ,p_time_period_id         => p_rec.time_period_id );


  ota_tps_bus1.chk_period_overlap (
               p_training_plan_id       => p_rec.training_plan_id
              ,p_object_version_number  => p_rec.object_version_number
              ,p_plan_status_type_id    => p_rec.plan_status_type_id
              ,p_time_period_id         => p_rec.time_period_id
              ,p_person_id              => p_rec.person_id
              ,p_organization_id        => p_rec.organization_id);
  END IF;

  hr_utility.set_location(' Step:'|| l_proc, 60);
  ota_tps_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec                          IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
   hr_utility.set_location(' Step:'|| l_proc, 10);
   ota_tps_bus1.chk_del_training_plan_id(
           p_training_plan_id    => ota_tps_shd.g_old_rec.training_plan_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END delete_validate;
--
END ota_tps_bus;

/
