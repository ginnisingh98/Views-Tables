--------------------------------------------------------
--  DDL for Package Body OTA_LPM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LPM_BUS" as
/* $Header: otlpmrhi.pkb 120.0 2005/05/29 07:22:37 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_lpm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_learning_path_member_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_learning_path_member_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_learning_path_members lpm
     where lpm.learning_path_member_id = p_learning_path_member_id
       and pbg.business_group_id = lpm.business_group_id;
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
    ,p_argument           => 'learning_path_member_id'
    ,p_argument_value     => p_learning_path_member_id
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
        => nvl(p_associated_column1,'LEARNING_PATH_MEMBER_ID')
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
  (p_learning_path_member_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_learning_path_members lpm
     where lpm.learning_path_member_id = p_learning_path_member_id
       and pbg.business_group_id = lpm.business_group_id;
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
    ,p_argument           => 'learning_path_member_id'
    ,p_argument_value     => p_learning_path_member_id
    );
  --
  if ( nvl(ota_lpm_bus.g_learning_path_member_id, hr_api.g_number)
       = p_learning_path_member_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_lpm_bus.g_legislation_code;
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
    ota_lpm_bus.g_learning_path_member_id     := p_learning_path_member_id;
    ota_lpm_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_lpm_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.learning_path_member_id is not null)  and (
    nvl(ota_lpm_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_lpm_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.learning_path_member_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_LEARNING_PATH_MEMBERS'
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
  ,p_rec in ota_lpm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_lpm_shd.api_updating
      (p_learning_path_member_id           => p_rec.learning_path_member_id
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
--
-- ----------------------------------------------------------------------------
-- |---------------------< is_catalog_lp >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--
Function is_catalog_lp(p_learning_path_id  IN NUMBER)
    RETURN BOOLEAN is
  --
  v_path_source_code      ota_learning_paths.path_source_code%TYPE;
  l_return                boolean := FALSE;
  v_proc                  varchar2(72) := g_package||'is_catalog_lp';
  --
  cursor csr_is_catalog_lp is
    select path_source_code
      from ota_learning_paths lps
     where lps.learning_path_id = p_learning_path_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
   Open csr_is_catalog_lp;
  fetch csr_is_catalog_lp into v_path_source_code;
  close csr_is_catalog_lp;
    --
   IF v_path_source_code = 'CATALOG' THEN
      l_return := TRUE;
  END IF;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  RETURN l_return;

End is_catalog_lp;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<chk_notify_days_before_target >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_notify_days_before_target(p_learning_path_id          IN ota_learning_paths.learning_path_id%TYPE
                                       ,p_duration                  IN ota_learning_path_members.duration%TYPE
                                       ,p_notify_days_before_target IN ota_learning_path_members.notify_days_before_target%TYPE)
IS
--
  l_proc  VARCHAR2(72) := g_package||'chk_notify_days_before_target';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
 IF is_catalog_lp(p_learning_path_id) THEN
    IF p_duration IS NOT NULL AND p_notify_days_before_target IS NOT NULL THEN
       --Modified for Bug#3861864
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
-- |----------------------<chk_activity_version_id>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_activity_version_id (
   p_learning_path_member_id   IN     ota_learning_path_members.learning_path_member_id%TYPE
  ,p_object_version_number     IN     ota_learning_path_members.object_version_number%TYPE
  ,p_activity_version_id       IN     ota_learning_path_members.activity_version_id%TYPE
  ,p_business_group_id         IN     ota_learning_path_members.business_group_id%TYPE
  ,p_learning_path_id          IN     ota_learning_path_members.learning_path_id%TYPE
  ) IS
--
--
  l_proc               VARCHAR2(72) :=      g_package|| 'activity_definition_id';
  l_api_updating       BOOLEAN;
  l_business_group_id  ota_learning_path_members.business_group_id%TYPE;
  l_exists             VARCHAR2(1);

--

  CURSOR csr_activity_version_id IS
  SELECT oad.business_group_id
    FROM ota_activity_versions  oav,
         ota_activity_definitions oad
   WHERE oav.activity_id = oad.activity_id
     AND oav.activity_version_id = p_activity_version_id;
--
--
BEGIN
--
-- check mandatory parameters have been set.
--
  hr_utility.set_location(' Step:'|| l_proc, 10);

IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID'
    ,p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID') THEN

  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  l_api_updating := ota_lpm_shd.api_updating
    (p_learning_path_member_id   => p_learning_path_member_id
    ,p_object_version_number     => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  IF p_activity_version_id IS NOT NULL THEN
    IF (l_api_updating AND
         NVL(ota_lpm_shd.g_old_rec.activity_version_id, hr_api.g_number) <>
         NVL(p_activity_version_id, hr_api.g_number) )
      OR (NOT l_api_updating)
    THEN
      -- Check that the definition exists
      --
      hr_utility.set_location(' Step:'|| l_proc, 20);
      OPEN csr_activity_version_id;
      FETCH csr_activity_version_id INTO l_business_group_id;
      IF csr_activity_version_id%NOTFOUND THEN
        CLOSE csr_activity_version_id;
        fnd_message.set_name('OTA', 'OTA_13850_TPM_BAD_ACT_VER');
        fnd_message.raise_error;
      ELSE
        IF l_business_group_id <> p_business_group_id THEN
          CLOSE csr_activity_version_id;
          fnd_message.set_name('OTA', 'OTA_13851_TPM_WRONG_ACT_VER');
          fnd_message.raise_error;
        ELSE
          hr_utility.set_location(' Step:'|| l_proc, 30);
          CLOSE csr_activity_version_id;
        END IF;
      END IF;
      --
    END IF;
  END IF;
  --

  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

        WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.ACTIVITY_VERSION_ID') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 42);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 44);


END chk_activity_version_id;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_learning_path_id>-------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_learning_path_id
  (p_learning_path_id          IN     ota_learning_path_members.learning_path_id%TYPE
  ,p_business_group_id         IN     ota_learning_path_members.business_group_id%TYPE
  )  IS
--
  l_exists VARCHAR2(1);
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_learning_path_id';
--
 CURSOR csr_learning_path_id IS
        SELECT NULL
        FROM OTA_LEARNING_PATHS
        WHERE learning_path_id    = p_learning_path_id
        AND   business_group_id   = p_business_group_id;
BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_learning_path_id'
    ,p_argument_value =>  p_learning_path_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  OPEN  csr_learning_path_id;
  FETCH csr_learning_path_id INTO l_exists;
  IF csr_learning_path_id%NOTFOUND THEN
    CLOSE csr_learning_path_id;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13605_LPM_NO_LEARNING_PATH');
    fnd_message.raise_error;
  ELSE
    hr_utility.set_location(' Step:'|| l_proc, 80);
    CLOSE csr_learning_path_id;
  END IF;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);

EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 92);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_learning_path_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique_course>---------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_unique_course
  (p_learning_path_member_id    IN     ota_learning_path_members.learning_path_member_id%TYPE
  ,p_object_version_number      IN     ota_learning_path_members.object_version_number%TYPE
  ,p_activity_version_id        IN     ota_learning_path_members.activity_version_id%TYPE
  ,p_learning_path_id           IN     ota_learning_path_members.learning_path_id%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_unique';
  l_exists VARCHAR2(1);
  l_api_updating  boolean;
--
 CURSOR csr_unique IS
        SELECT NULL
        FROM OTA_LEARNING_PATH_MEMBERS
        WHERE learning_path_id       = p_learning_path_id
        AND (p_activity_version_id IS NOT NULL AND
               p_activity_version_id = activity_version_id)
        AND (p_learning_path_member_id IS NULL
              OR p_learning_path_member_id <> learning_path_member_id);
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID'
    ,p_check_column2    => 'OTA_LEARNING_PATH_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID'
    ,p_associated_column2   => 'OTA_LEARNING_PATH_MEMBERS.ACTIVITY_VERSION_ID' ) THEN


  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_learning_path_id'
    ,p_argument_value =>  p_learning_path_id
    );

  l_api_updating := ota_lpm_shd.api_updating
    (p_learning_path_member_id   => p_learning_path_member_id
    ,p_object_version_number     => p_object_version_number);
  --
  -- Check if anything is changing, or this is an insert
  --
  IF (l_api_updating AND
       NVL(ota_lpm_shd.g_old_rec.activity_version_id, hr_api.g_number) <>
       NVL(p_activity_version_id, hr_api.g_number))
    OR (NOT l_api_updating)  THEN
    --
    -- check the combination is unique
    --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_unique;
    FETCH csr_unique INTO l_exists;
    IF csr_unique%FOUND THEN
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13620_LPM_NOT_UNIQUE');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 70);
    END IF;
  END IF;
--
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.ACTIVITY_VERSION_ID') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_unique_course;
--

/*
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique_sequence>--------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_unique_sequence
  (p_learning_path_member_id    IN     ota_learning_path_members.learning_path_member_id%TYPE
  ,p_object_version_number      IN     ota_learning_path_members.object_version_number%TYPE
  ,p_course_sequence            IN     ota_learning_path_members.course_sequence%TYPE
  ,p_learning_path_id           IN     ota_learning_path_members.learning_path_id%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_unique';
  l_exists VARCHAR2(1);
  l_api_updating  boolean;
--
 CURSOR csr_unique IS
        SELECT NULL
        FROM OTA_LEARNING_PATH_MEMBERS
        WHERE learning_path_id       = p_learning_path_id
        AND  (p_course_sequence IS NOT NULL AND
               p_course_sequence = course_sequence)
        AND (p_learning_path_member_id IS NULL
              OR p_learning_path_member_id <> learning_path_member_id);
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

IF hr_multi_message.no_exclusive_error
    (p_check_column1        => 'OTA_LEARNING_PATH_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.ACTIVITY_VERSION_ID' ) THEN


  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_learning_path_id'
    ,p_argument_value =>  p_learning_path_id
    );

  l_api_updating := ota_lpm_shd.api_updating
    (p_learning_path_member_id   => p_learning_path_member_id
    ,p_object_version_number     => p_object_version_number);
  --
  -- Check if anything is changing, or this is an insert
  --
  IF (l_api_updating AND
       NVL(ota_lpm_shd.g_old_rec.course_sequence, hr_api.g_number) <>
       NVL(p_course_sequence, hr_api.g_number))
    OR (NOT l_api_updating)  THEN
    --
    -- check the sequence is unique
    --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_unique;
    FETCH csr_unique INTO l_exists;
    IF csr_unique%FOUND THEN
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13844_TPM_NOT_UNIQUE');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 70);
    END IF;
  END IF;
--
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.COURSE_SEQUENCE') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_unique_sequence;
--

*/


-- ----------------------------------------------------------------------------
-- |----------------------<chk_duration>---------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_duration
  (p_learning_path_member_id    IN     ota_learning_path_members.learning_path_member_id%TYPE
  ,p_object_version_number      IN     ota_learning_path_members.object_version_number%TYPE
  ,p_duration			IN     ota_learning_path_members.duration%TYPE
  ,p_duration_units		IN     ota_learning_path_members.duration_units%TYPE
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
    (p_check_column1        => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID'
    ,p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.LEARNING_PATH_ID' ) THEN


hr_utility.set_location(' Step:'|| l_proc, 40);

  l_api_updating := ota_lpm_shd.api_updating
    (p_learning_path_member_id   => p_learning_path_member_id
    ,p_object_version_number     => p_object_version_number);
  --
  -- Check if anything is changing, or this is an insert
  --
  IF (l_api_updating AND
       NVL(ota_lpm_shd.g_old_rec.duration, hr_api.g_number) <>
       NVL(p_duration, hr_api.g_number)
      OR NVL(ota_lpm_shd.g_old_rec.duration_units,hr_api.g_varchar2) <>
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
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.DURATION') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_duration;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_duration_units  >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_duration_units (p_learning_path_member_id 		IN number
                              ,p_object_version_number          IN NUMBER
                              ,p_duration_units  	 		IN VARCHAR2
                              ,p_effective_date			        IN date) IS

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

  l_api_updating := ota_lpm_shd.api_updating
    (p_learning_path_member_id   => p_learning_path_member_id
    ,p_object_version_number     => p_object_version_number);


IF ((l_api_updating AND
       NVL(ota_lpm_shd.g_old_rec.duration_units,hr_api.g_varchar2) <>
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
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.DURATION_UNITS') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_duration_units;
--


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lpm_shd.g_rec_type
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
    ,p_associated_column1 => ota_lpm_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  hr_utility.set_location(' Step:'|| l_proc, 10);
  --
  -- Validate Dependent Attributes
  --
  --
  /*
  ota_lpm_bus.chk_learning_path_id(
               p_learning_path_id       => p_rec.learning_path_id
              ,p_business_group_id      => p_rec.business_group_id);
  */

   hr_utility.set_location(' Step:'|| l_proc, 20);

   ota_lpm_bus.chk_notify_days_before_target(
               p_learning_path_id          => p_rec.learning_path_id
              ,p_duration                  => p_rec.duration
              ,p_notify_days_before_target => p_rec.notify_days_before_target);

  --validations based on learning path source
  IF is_catalog_lp(p_rec.learning_path_id) THEN

   ota_lpm_bus.chk_activity_version_id (
               p_learning_path_member_id => p_rec.learning_path_member_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_activity_version_id     => p_rec.activity_version_id
              ,p_learning_path_id        => p_rec.learning_path_id
              ,p_business_group_id       => p_rec.business_group_id);

  ota_lpm_bus.chk_unique_course(
               p_learning_path_member_id => p_rec.learning_path_member_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_activity_version_id     => p_rec.activity_version_id
              ,p_learning_path_id        => p_rec.learning_path_id);

  ota_lpm_bus.chk_duration_units(
               p_learning_path_member_id => p_rec.learning_path_member_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration_units          => p_rec.duration_units
              ,p_effective_date          => p_effective_date);

  ota_lpm_bus.chk_duration(
               p_learning_path_member_id => p_rec.learning_path_member_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration                => p_rec.duration
              ,p_duration_units          => p_rec.duration_units);

  ota_lpm_bus.chk_df(p_rec);
  END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lpm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_lpm_shd.g_tab_nam
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
      ,p_rec                       => p_rec
    );
  --
   ota_lpm_bus.chk_notify_days_before_target(
               p_learning_path_id          => p_rec.learning_path_id
              ,p_duration                  => p_rec.duration
              ,p_notify_days_before_target => p_rec.notify_days_before_target);

  --
  --validations based on learning path source
  IF is_catalog_lp(p_rec.learning_path_id) THEN

  ota_lpm_bus.chk_duration_units(
               p_learning_path_member_id => p_rec.learning_path_member_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration_units          => p_rec.duration_units
              ,p_effective_date          => p_effective_date);

  ota_lpm_bus.chk_duration(
               p_learning_path_member_id => p_rec.learning_path_member_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_duration                => p_rec.duration
              ,p_duration_units          => p_rec.duration_units);
  --
  ota_lpm_bus.chk_df(p_rec);
  END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_lpm_shd.g_rec_type
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
end ota_lpm_bus;

/
