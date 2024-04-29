--------------------------------------------------------
--  DDL for Package Body OTA_LPS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LPS_BUS" as
/* $Header: otlpsrhi.pkb 120.0 2005/05/29 07:24:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_lps_bus.';  -- Global package name
g_dummy    NUMBER(1);
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_learning_path_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_learning_path_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_learning_paths lps
     where lps.learning_path_id = p_learning_path_id
       and pbg.business_group_id = lps.business_group_id;
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
    ,p_argument           => 'learning_path_id'
    ,p_argument_value     => p_learning_path_id
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
        => nvl(p_associated_column1,'LEARNING_PATH_ID')
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
  (p_learning_path_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_learning_paths lps
     where lps.learning_path_id = p_learning_path_id
       and pbg.business_group_id = lps.business_group_id;
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
    ,p_argument           => 'learning_path_id'
    ,p_argument_value     => p_learning_path_id
    );
  --
  if ( nvl(ota_lps_bus.g_learning_path_id, hr_api.g_number)
       = p_learning_path_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_lps_bus.g_legislation_code;
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
    ota_lps_bus.g_learning_path_id            := p_learning_path_id;
    ota_lps_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in ota_lps_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.learning_path_id is not null)  and (
    nvl(ota_lps_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_lps_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.learning_path_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_LEARNING_PATHS'
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
  (p_effective_date               in date
  ,p_rec in ota_lps_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_lps_shd.api_updating
      (p_learning_path_id                  => p_rec.learning_path_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  IF NVL(p_rec.business_group_id, hr_api.g_number) <>
     NVL(ota_lps_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'BUSINESS_GROUP_ID'
         ,p_base_table => ota_lps_shd.g_tab_nam);
  END IF;
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF NVL(p_rec.learning_path_id, hr_api.g_number) <>
     NVL(ota_lps_shd.g_old_rec.learning_path_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'LEARNING_PATH_ID'
         ,p_base_table => ota_lps_shd.g_tab_nam);
  END IF;
  --
 EXCEPTION

    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_duration>---------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_duration
  (p_learning_path_id      IN     ota_learning_paths.learning_path_id%TYPE
  ,p_object_version_number IN     ota_learning_paths.object_version_number%TYPE
  ,p_duration			   IN     ota_learning_paths.duration%TYPE
  ,p_duration_units		   IN     ota_learning_paths.duration_units%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_duration';
  l_exists VARCHAR2(1);
  l_api_updating  boolean;
--

BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

IF hr_multi_message.no_exclusive_error
    (p_check_column1        => 'OTA_LEARNING_PATHS.LEARNING_PATH_ID'
    ,p_associated_column1   => 'OTA_LEARNING_PATHS.LEARNING_PATH_ID' ) THEN


hr_utility.set_location(' Step:'|| l_proc, 40);

  l_api_updating := ota_lps_shd.api_updating
    (p_learning_path_id          => p_learning_path_id
    ,p_object_version_number     => p_object_version_number);
  --
  -- Check if anything is changing, or this is an insert
  --
  IF (l_api_updating AND
       NVL(ota_lps_shd.g_old_rec.duration, hr_api.g_number) <>
       NVL(p_duration, hr_api.g_number)
      OR NVL(ota_lps_shd.g_old_rec.duration_units,hr_api.g_varchar2) <>
         NVL(p_duration_units, hr_api.g_varchar2))
    OR (NOT l_api_updating AND (p_duration IS NOT NULL OR p_duration_units IS NOT NULL))  THEN
    --
    -- check the duration is positive
    --
   hr_utility.set_location(' Step:'|| l_proc, 50);
   IF (p_duration <= 0) THEN
       hr_utility.set_location(' Step:'|| l_proc, 60);
       fnd_message.set_name('OTA', 'OTA_13443_EVT_DURATION_NOT_0');
       fnd_message.raise_error;
   ELSE IF((p_duration IS NOT NULL AND p_duration_units IS NULL)
            OR (p_duration IS NULL AND p_duration_units IS NOT NULL)) THEN
       hr_utility.set_location(' Step:'|| l_proc, 60);
       fnd_message.set_name('OTA', 'OTA_13881_NHS_COMB_INVALID');
       fnd_message.raise_error;
   END IF;
  END IF;
 END IF;
--
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.DURATION') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_duration;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_duration_units  >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_duration_units (p_learning_path_id 	  	   IN number
                              ,p_object_version_number     IN NUMBER
                              ,p_duration_units  	   	   IN VARCHAR2
                              ,p_effective_date			   IN date) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_duration_units';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
     ,p_argument	=> 'effective_date'
     ,p_argument_value  => p_effective_date);

  l_api_updating := ota_lps_shd.api_updating
    (p_learning_path_id          => p_learning_path_id
    ,p_object_version_number     => p_object_version_number);


IF ((l_api_updating AND
       NVL(ota_lps_shd.g_old_rec.duration_units,hr_api.g_varchar2) <>
         NVL(p_duration_units, hr_api.g_varchar2))
     OR NOT l_api_updating AND p_duration_units IS NOT NULL) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       IF p_duration_units IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_DURATION_UNITS'
              ,p_lookup_code => p_duration_units) THEN
              fnd_message.set_name('OTA','OTA_13882_NHS_DURATION_INVALID');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.DURATION_UNITS') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_duration_units;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<chk_notify_days_before_target >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_notify_days_before_target(p_path_source_code          IN ota_learning_paths.path_source_code%TYPE
                                       ,p_duration                  IN ota_learning_paths.duration%TYPE
                                       ,p_notify_days_before_target IN ota_learning_paths.notify_days_before_target%TYPE)
IS
--
  l_proc  VARCHAR2(72) := g_package||'chk_notify_days_before_target';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
 IF p_path_source_code = 'CATALOG' THEN
    IF p_duration IS NOT NULL AND p_notify_days_before_target IS NOT NULL THEN
       -- Modified for Bug#3861864
       IF p_duration <= p_notify_days_before_target THEN
          fnd_message.set_name('OTA','OTA_13079_LPS_NOTIFY_TARGET');
          fnd_message.raise_error;
       END IF;
  ELSIF p_duration IS NULL and p_notify_days_before_target IS NOT NULL THEN
          fnd_message.set_name('OTA','OTA_13083_LP_CT_NOT_ERR');
          fnd_message.raise_error;
    END IF;
 END IF;

    IF p_notify_days_before_target < 0 THEN
       fnd_message.set_name('OTA','OTA_443368_POSITIVE_NUMBER');
       fnd_message.raise_error;
    END IF;

 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.NOTIFY_DAYS_BEFORE_TARGET') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_notify_days_before_target;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_path_source_code>------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_path_source_code(p_learning_path_id                  IN number
                              ,p_object_version_number             IN NUMBER
                              ,p_path_source_code                  IN VARCHAR2
                              ,p_effective_date                    IN date) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_path_source_code';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
     ,p_argument        => 'effective_date'
     ,p_argument_value  => p_effective_date);

  l_api_updating := ota_lps_shd.api_updating
    (p_learning_path_id          => p_learning_path_id
    ,p_object_version_number     => p_object_version_number);

IF ((l_api_updating AND
       NVL(ota_lps_shd.g_old_rec.path_source_code,hr_api.g_varchar2) <>
         NVL(p_path_source_code, hr_api.g_varchar2))
     OR NOT l_api_updating AND p_path_source_code IS NOT NULL) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       IF p_path_source_code IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_TRAINING_PLAN_SOURCE'
              ,p_lookup_code => p_path_source_code) THEN
              fnd_message.set_name('OTA','OTA_13176_TPS_PLN_SRC_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.PATH_SOURCE_CODE') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_path_source_code;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_source_function_code  >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_source_function_code (p_learning_path_id                     IN number
                                   ,p_object_version_number                IN NUMBER
                                   ,p_source_function_code                 IN VARCHAR2
                                   ,p_effective_date                       IN date) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_source_function_code';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
     ,p_argument        => 'effective_date'
     ,p_argument_value  => p_effective_date);

  l_api_updating := ota_lps_shd.api_updating
    (p_learning_path_id          => p_learning_path_id
    ,p_object_version_number     => p_object_version_number);


IF ((l_api_updating AND
       NVL(ota_lps_shd.g_old_rec.source_function_code,hr_api.g_varchar2) <>
         NVL(p_source_function_code, hr_api.g_varchar2))
     OR NOT l_api_updating AND p_source_function_code IS NOT NULL) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       IF p_source_function_code IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_PLAN_COMPONENT_SOURCE'
              ,p_lookup_code => p_source_function_code) THEN
              fnd_message.set_name('OTA','OTA_13178_TPM_SRC_FUNC_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.SOURCE_FUNCTION_CODE') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_source_function_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_competency_update_level  >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_competency_update_level (p_learning_path_id                     IN number
                                   ,p_object_version_number                IN NUMBER
                                   ,p_competency_update_level                 IN VARCHAR2
                                   ,p_effective_date                       IN date) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_competency_update_level';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
     ,p_argument        => 'effective_date'
     ,p_argument_value  => p_effective_date);

  l_api_updating := ota_lps_shd.api_updating
    (p_learning_path_id          => p_learning_path_id
    ,p_object_version_number     => p_object_version_number);


IF ((l_api_updating AND
       NVL(ota_lps_shd.g_old_rec.competency_update_level,hr_api.g_varchar2) <>
         NVL(p_competency_update_level, hr_api.g_varchar2))
     OR NOT l_api_updating AND p_competency_update_level IS NOT NULL) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       IF p_competency_update_level IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_COMPETENCY_UPDATE_LEVEL'
              ,p_lookup_code => p_competency_update_level) THEN
              fnd_message.set_name('OTA','OTA_443411_COMP_UPD_LEV_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.competency_update_level') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_competency_update_level;

--

-- ----------------------------------------------------------------------------
-- |----------------------------< check_start_end_dates >-----------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Startdate must be less than, or equal to, enddate.
--
Procedure check_start_end_dates
  ( p_start_date IN DATE
  ,p_end_date       in     date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_start_end_dates';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_general.check_start_end_dates(  p_start_date, p_end_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE')
       --             ,p_associated_column2    => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_start_end_dates;
--

-- ----------------------------------------------------------------------------
-- |----------------------------< check_lp_course_dates >-----------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates the LP dates with Course Dates
--   Startdate must be less than, or equal to, enddate.
--
Procedure check_lp_course_dates
  (
     p_learning_path_id IN NUMBER
    ,p_start_date IN DATE
    ,p_end_date IN DATE
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_lp_course_dates';

  l_start_date_active DATE;
  l_end_date_active DATE;
  l_course_id NUMBER;
  l_upd_start_date BOOLEAN;
  l_upd_end_date BOOLEAN;

  CURSOR csr_lp_course_dates(l_start_date_active DATE, l_end_date_active DATE)IS
  SELECT  1
  FROM ota_learning_path_members lpm,
       ota_activity_versions tav
  WHERE tav.activity_version_id = lpm.activity_version_id
      AND lpm.learning_path_id = p_learning_path_id
      AND (( tav.end_date IS NOT NULL AND l_start_date_active > tav.end_date)
           OR (l_end_date_active IS NOT NULL AND tav.start_date > l_end_date_active));
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
 IF hr_multi_message.no_exclusive_error
    (p_check_column1        => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE'
    ,p_check_column2        => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE'
    ,p_associated_column1   => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE'
    ,p_associated_column2   => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE' ) THEN

    IF (NVL(ota_lps_shd.g_old_rec.start_date_active, hr_api.g_date) <>
         NVL( p_start_date, hr_api.g_date )) THEN
       l_upd_start_date := TRUE;
       l_start_date_active := p_start_date;
    ELSE
       l_upd_start_date := FALSE;
       l_start_date_active := ota_lps_shd.g_old_rec.start_date_active;
    END IF;

    IF (NVL(ota_lps_shd.g_old_rec.end_date_active, hr_api.g_date) <>
         NVL( p_end_date, hr_api.g_date )) THEN
       l_upd_end_date := TRUE;
       l_end_date_active := p_end_date;
    ELSE
       l_upd_end_date := FALSE;
       l_end_date_active := ota_lps_shd.g_old_rec.end_date_active;
    END IF;

    IF (l_upd_start_date OR l_upd_end_date) THEN

      OPEN csr_lp_course_dates(l_start_date_active, l_end_date_active);
      FETCH csr_lp_course_dates INTO l_course_id;

      IF csr_lp_course_dates%FOUND THEN
         fnd_message.set_name('OTA', 'OTA_443062_LP_CRS_DTS_INVALID');
         fnd_message.raise_error;
        CLOSE csr_lp_course_dates;
      ELSE
          CLOSE csr_lp_course_dates;
      END IF;
   END IF;
 END IF;

  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

          IF l_upd_start_date THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;
               END IF;
          ELSIF l_upd_end_date THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;
               END IF;
          END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_lp_course_dates;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_category_dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure check_category_dates
  (
   p_learning_path_id           in    number
  , p_object_version_number in number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_cat_start_end_date is
    select
      ctu.start_date_active,
      nvl(ctu.end_date_active, to_date ('31-12-4712', 'DD-MM-YYYY'))
    from
      ota_lp_cat_inclusions lci,
      ota_category_usages ctu
    where
      ctu.category_usage_id = lci.category_usage_id
      and lci.learning_path_id = p_learning_path_id
      and lci.primary_flag = 'Y';
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'check_category_dates';
  l_cat_start_date        date;
  l_cat_end_date          date;
  l_start_date_active date;
  l_end_date_active   date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
          (p_check_column1   => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE'
          ,p_check_column2   => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE'
          ,p_associated_column1   => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE'
          ,p_associated_column2   => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE'
        ) THEN
     --
     OPEN cur_cat_start_end_date;
     FETCH cur_cat_start_end_date into l_cat_start_date, l_cat_end_date;

     IF (NVL(ota_lps_shd.g_old_rec.start_date_active, hr_api.g_date) <>
         NVL( p_start_date, hr_api.g_date )) THEN
       l_start_date_active := p_start_date;
    ELSE
       l_start_date_active := ota_lps_shd.g_old_rec.start_date_active;
    END IF;

    IF (NVL(ota_lps_shd.g_old_rec.end_date_active, hr_api.g_date) <>
         NVL( p_end_date, hr_api.g_date )) THEN
       l_end_date_active := p_end_date;
    ELSE
       l_end_date_active := ota_lps_shd.g_old_rec.end_date_active;
    END IF;

     IF cur_cat_start_end_date%FOUND THEN
        CLOSE cur_cat_start_end_date;
        IF ( l_cat_start_date > l_start_date_active
             or l_cat_end_date < nvl(l_end_date_active, to_date ('31-12-4712', 'DD-MM-YYYY'))
           ) THEN
          --
          fnd_message.set_name      ( 'OTA','OTA_443382_LP_OUT_OF_CAT_DATES');
	  fnd_message.raise_error;
          --
        End IF;
     ELSE
        CLOSE cur_cat_start_end_date;
     End IF;
  End IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_LEARNING_PATHS.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_LEARNING_PATHS.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End check_category_dates;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_path_source_code >-----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION  get_path_source_code
  (p_learning_path_id      IN     ota_learning_paths.learning_path_id%TYPE
  ) RETURN VARCHAR2 IS
--
  l_path_source_code  ota_learning_paths.path_source_code%TYPE;
  l_proc   VARCHAR2(72) :=      g_package||'get_path_source_code';

 CURSOR csr_get_path_source IS
        SELECT path_source_code
        FROM   ota_learning_paths lps
        WHERE  lps.learning_path_id = p_learning_path_id;


BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_learning_path_id'
    ,p_argument_value =>  p_learning_path_id
    );
  --
   OPEN csr_get_path_source;
  FETCH csr_get_path_source INTO l_path_source_code;
  CLOSE csr_get_path_source;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
  RETURN l_path_source_code;
END  get_path_source_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_lp_enrollments_exist>---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION  chk_lp_enrollments_exist
  (p_learning_path_id      IN     ota_learning_paths.learning_path_id%TYPE
  ) RETURN BOOLEAN IS
--
  l_exists BOOLEAN := FALSE;
  l_proc   VARCHAR2(72) :=      g_package||'chk_lp_enrollments_exist';

 CURSOR csr_del_lp_id IS
        SELECT 1
        FROM   ota_lp_enrollments lpm
        WHERE  lpm.learning_path_id = p_learning_path_id;

BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_learning_path_id'
    ,p_argument_value =>  p_learning_path_id
    );
  --
  -- Check that the code can be deleted
  --
  OPEN  csr_del_lp_id;
  FETCH csr_del_lp_id INTO g_dummy;
  IF csr_del_lp_id%FOUND THEN
    l_exists := TRUE;
    hr_utility.set_location(' Step:'|| l_proc, 10);
  END IF;
    CLOSE csr_del_lp_id;
    hr_utility.set_location(' Leaving:'||l_proc, 20);
--
  RETURN l_exists;
END  chk_lp_enrollments_exist;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lps_shd.g_rec_type
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
    ,p_associated_column1 => ota_lps_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
--  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
   ota_lps_bus.chk_path_source_code(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_path_source_code        => p_rec.path_source_code
              ,p_effective_date          => p_effective_date);

    ota_lps_bus.chk_notify_days_before_target(
               p_path_source_code          => p_rec.path_source_code
              ,p_duration                  => p_rec.duration
              ,p_notify_days_before_target => p_rec.notify_days_before_target);

ota_lps_bus.chk_competency_update_level (p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_competency_update_level        => p_rec.competency_update_level
              ,p_effective_date          => p_effective_date);

 IF p_rec.path_source_code = 'CATALOG' THEN


  ota_lps_bus.chk_duration_units(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration_units          => p_rec.duration_units
              ,p_effective_date          => p_effective_date);

  ota_lps_bus.chk_duration(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration                => p_rec.duration
              ,p_duration_units          => p_rec.duration_units);

  ota_lps_bus.check_start_end_dates(p_rec.start_date_active
                       ,p_rec.end_date_active);

   -- enable dff validation for only Catalog Learning Paths
    ota_lps_bus.chk_df(p_rec);

ELSIF p_rec.path_source_code = 'TALENT_MGMT' THEN

   ota_lps_bus.chk_source_function_code(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_source_function_code    => p_rec.source_function_code
              ,p_effective_date          => p_effective_date);

END IF;
  --
  hr_multi_message.end_validation_set;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lps_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';

  l_duration_changed   BOOLEAN
          := ota_general.value_changed(ota_lps_shd.g_old_rec.duration,
                                       p_rec.duration);
  l_duration_units_changed   BOOLEAN
          := ota_general.value_changed(ota_lps_shd.g_old_rec.duration_units,
                                       p_rec.duration_units);

  l_start_date_active_changed BOOLEAN
          := ota_general.value_changed(ota_lps_shd.g_old_rec.start_date_active,
                                       p_rec.start_date_active);


--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_lps_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
   ota_lps_bus.chk_path_source_code(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_path_source_code        => p_rec.path_source_code
              ,p_effective_date          => p_effective_date);

    ota_lps_bus.chk_notify_days_before_target(
               p_path_source_code          => p_rec.path_source_code
              ,p_duration                  => p_rec.duration
              ,p_notify_days_before_target => p_rec.notify_days_before_target);

ota_lps_bus.chk_competency_update_level (p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_competency_update_level        => p_rec.competency_update_level
              ,p_effective_date          => p_effective_date);

IF p_rec.path_source_code = 'CATALOG' THEN

  ota_lps_bus.chk_duration_units(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration_units          => p_rec.duration_units
              ,p_effective_date          => p_effective_date);

  ota_lps_bus.chk_duration(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration                => p_rec.duration
              ,p_duration_units          => p_rec.duration_units);

  check_start_end_dates(p_rec.start_date_active
                       ,p_rec.end_date_active);
  check_lp_course_dates(p_rec.learning_path_id
                       ,p_rec.start_date_active
                       ,p_rec.end_date_active);

  check_category_dates(p_learning_path_id => p_rec.learning_path_id
                       ,p_object_version_number => p_rec.object_version_number
                       ,p_start_date => p_rec.start_date_active
                       ,p_end_date   => p_rec.end_date_active);

   IF l_duration_changed OR
      l_duration_units_changed OR
      l_start_date_active_changed THEN
      IF chk_lp_enrollments_exist(p_learning_path_id  => p_rec.learning_path_id) THEN
         fnd_message.set_name('OTA','OTA_13063_LPM_UPD_ERR');
         fnd_message.raise_error;
     END IF;
   END IF;
  --
   -- enable dff validation for only Catalog Learning Paths
     ota_lps_bus.chk_df(p_rec);

 ELSIF p_rec.path_source_code = 'TALENT_MGMT' THEN

   ota_lps_bus.chk_source_function_code(
               p_learning_path_id        => p_rec.learning_path_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_source_function_code    => p_rec.source_function_code
              ,p_effective_date          => p_effective_date);

 END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_lps_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
   IF get_path_source_code(ota_lps_shd.g_old_rec.learning_path_id) = 'CATALOG' THEN

      IF  chk_lp_enrollments_exist(
                p_learning_path_id   => ota_lps_shd.g_old_rec.learning_path_id) THEN
          fnd_message.set_name('OTA','OTA_443383_LP_TP_EXISTS');
          fnd_message.raise_error;
      END IF;

  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;


--
end ota_lps_bus;

/
