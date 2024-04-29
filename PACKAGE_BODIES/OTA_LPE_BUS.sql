--------------------------------------------------------
--  DDL for Package Body OTA_LPE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LPE_BUS" as
/* $Header: otlperhi.pkb 120.7 2005/12/14 15:18 asud noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_lpe_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_lp_enrollment_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_lp_enrollment_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_lp_enrollments lpe
     where lpe.lp_enrollment_id = p_lp_enrollment_id
       and pbg.business_group_id = lpe.business_group_id;
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
    ,p_argument           => 'lp_enrollment_id'
    ,p_argument_value     => p_lp_enrollment_id
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
        => nvl(p_associated_column1,'LP_ENROLLMENT_ID')
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
  (p_lp_enrollment_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_lp_enrollments lpe
     where lpe.lp_enrollment_id = p_lp_enrollment_id
       and pbg.business_group_id = lpe.business_group_id;
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
    ,p_argument           => 'lp_enrollment_id'
    ,p_argument_value     => p_lp_enrollment_id
    );
  --
  if ( nvl(ota_lpe_bus.g_lp_enrollment_id, hr_api.g_number)
       = p_lp_enrollment_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_lpe_bus.g_legislation_code;
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
    ota_lpe_bus.g_lp_enrollment_id            := p_lp_enrollment_id;
    ota_lpe_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_lpe_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.lp_enrollment_id is not null)  and (
    nvl(ota_lpe_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(ota_lpe_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.lp_enrollment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_LP_ENROLLMENTS'
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
  ,p_rec in ota_lpe_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_lpe_shd.api_updating
      (p_lp_enrollment_id                  => p_rec.lp_enrollment_id
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
-- |---------------------< get_path_source_code >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--
Function get_path_source_code(p_learning_path_id  IN NUMBER)
    RETURN VARCHAR2 is
  --
  l_path_source_code      ota_learning_paths.path_source_code%TYPE;
  v_proc                  varchar2(72) := g_package||'get_path_source_code';
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
  fetch csr_is_catalog_lp into l_path_source_code;
  close csr_is_catalog_lp;
    --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  RETURN l_path_source_code;

End get_path_source_code;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< chk_person_contact >---------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_person_contact (p_person_id   ota_lp_enrollments.person_id%TYPE,
                              p_contact_id  ota_lp_enrollments.contact_id%TYPE)
is
--
  l_proc  varchar2(72) := g_package||'chk_person_contact';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   IF ( p_person_id IS NULL AND p_contact_id IS NULL) OR
      ( p_person_id IS NOT NULL AND p_contact_id IS NOT NULL) THEN
    fnd_message.set_name('OTA', 'OTA_13077_TPE_PRSN_OR_CNTCT');
    fnd_message.raise_error;
  END IF;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_person_contact;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_person_id>-------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_person_id
  (p_effective_date            IN     date
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  )  IS
--
  l_exists varchar2(1);
  l_proc   varchar2(72) :=      g_package|| 'chk_person_id';
--
 CURSOR csr_person_id IS
        SELECT null
        FROM PER_ALL_PEOPLE_F
        WHERE person_id = p_person_id;
BEGIN
--
  hr_utility.set_location(' Step:'|| l_proc, 20);

  IF p_person_id IS NOT NULL THEN
    OPEN  csr_person_id;
    FETCH csr_person_id INTO l_exists;
    IF csr_person_id%NOTFOUND THEN
      CLOSE csr_person_id;
      hr_utility.set_location(' Step:'|| l_proc, 40);
      fnd_message.set_name('OTA', 'OTA_13884_NHS_PERSON_INVALID');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_person_id;
    END IF;
  END IF;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 50);

 --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_LP_ENROLLMENTS.PERSON_ID') THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 52);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 55);

END chk_person_id;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_path_status_code >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_path_status_code
  (p_effective_date            IN     date
  ,p_path_status_code          IN     ota_lp_enrollments.path_status_code%TYPE
  ) IS
--
  l_proc  varchar2(72) :=      g_package|| 'chk_path_status_code';
--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_path_status_code'
    ,p_argument_value =>   p_path_status_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF hr_api.not_exists_in_hr_lookups
    (p_effective_date   =>   p_effective_date
    ,p_lookup_type      =>   'OTA_LEARNING_PATH_STATUS'
    ,p_lookup_code      =>   p_path_status_code
    ) THEN
    -- Error, lookup not available
        fnd_message.set_name('OTA', 'OTA_13864_TPS_BAD_PLAN_STATUS');
        fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);

--MULTI MESSAGE SUPPORT
EXCEPTION
        WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_LP_ENROLLMENTS.PATH_STATUS_CODE') THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 32);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 35);

END chk_path_status_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_enrollment_source_code >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_enrollment_source_code
  (p_effective_date            IN     date
  ,p_enrollment_source_code    IN     ota_lp_enrollments.enrollment_source_code%TYPE
  ) IS
--
  l_proc  varchar2(72) :=      g_package|| 'chk_enrollment_source_code';
--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_enrollment_source_code'
    ,p_argument_value =>   p_enrollment_source_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF hr_api.not_exists_in_hr_lookups
    (p_effective_date   =>   p_effective_date
    ,p_lookup_type      =>   'OTA_TRAINING_PLAN_SOURCE'
    ,p_lookup_code      =>   p_enrollment_source_code
    ) THEN
    -- Error, lookup not available
        fnd_message.set_name('OTA', 'OTA_13176_TPM_PLN_SRC_INVLD');
        fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);

--MULTI MESSAGE SUPPORT
EXCEPTION
        WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_LP_ENROLLMENTS.ENROLLMENT_SOURCE_CODE') THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 32);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 35);

END chk_enrollment_source_code;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_lp_enrollment_id >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_del_lp_enrollment_id
  (p_lp_enrollment_id          IN     ota_lp_enrollments.lp_enrollment_id%TYPE)
   IS
--
  l_exists varchar2(1);
  l_proc   varchar2(72) :=      g_package|| 'chk_del_lp_enrollment_id';

 CURSOR csr_lp_enr_id IS
 SELECT null
   FROM ota_lp_member_enrollments lme
  WHERE lme.lp_enrollment_id = p_lp_enrollment_id;
--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_lp_enrollment_id'
    ,p_argument_value =>   p_lp_enrollment_id
    );
  --
  -- Check that the lp_enrollment can be deleted
  --
   OPEN csr_lp_enr_id;
  FETCH csr_lp_enr_id INTO l_exists;
     IF csr_lp_enr_id%FOUND THEN
        CLOSE csr_lp_enr_id;
        hr_utility.set_location(' Step:'|| l_proc, 10);
        fnd_message.set_name('OTA', 'OTA_13078_LPS_LPM_EXIST');
        fnd_message.raise_error;
   ELSE
        CLOSE csr_lp_enr_id;
    END IF;


    hr_utility.set_location(' Leaving:'||l_proc, 20);

END chk_del_lp_enrollment_id;

--
--
-- ----------------------------------------------------------------------------
-- |----------------------<check_duplicate_subscription >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE check_duplicate_subscription
  (   p_learning_path_id IN ota_lp_enrollments.learning_path_id%TYPE
     ,p_contact_id IN ota_lp_enrollments.contact_id%TYPE default NULL
     ,p_person_id IN ota_lp_enrollments.person_id%TYPE default NULL)
   IS
--
  l_exists varchar2(1);
  l_proc   varchar2(72) :=      g_package|| 'check_duplicate_subscription';

 CURSOR csr_lp_enr_id IS
 SELECT null
   FROM ota_lp_enrollments lpe
  WHERE lpe.learning_path_id = p_learning_path_id
    AND ( lpe.person_id = p_person_id and lpe.contact_id IS NULL
          OR lpe.contact_id = p_contact_id and lpe.person_id IS NULL)
    AND lpe.path_status_code <> 'CANCELLED';

 CURSOR csr_get_object_type IS
 SELECT meaning
 FROM hr_lookups
 WHERE lookup_type = 'OTA_OBJECT_TYPE'
  and lookup_code = 'LP';

 l_person_name per_all_people_f.full_name%TYPE;
 l_object_type varchar2(240);

--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_learning_path_id'
    ,p_argument_value =>   p_learning_path_id
    );
  --
  -- check if learner is already subscribed
  --
   OPEN csr_lp_enr_id;
  FETCH csr_lp_enr_id INTO l_exists;
     IF csr_lp_enr_id%FOUND THEN
        CLOSE csr_lp_enr_id;

        OPEN csr_get_object_type;
        FETCH csr_get_object_type INTO l_object_type;
        CLOSE csr_get_object_type;

        l_person_name := ota_utility.get_learner_name(
                            p_person_id   => p_person_id
                           ,p_customer_id => NULL
                           ,p_contact_id  => p_contact_id);

        hr_utility.set_location(' Step:'|| l_proc, 10);
        fnd_message.set_name('OTA', 'OTA_443908_LRNR_DUPL_SUBSC_ERR');
        fnd_message.set_token('LEARNER_NAME', l_person_name);
        fnd_message.set_token('OBJECT_TYPE', l_object_type);
        fnd_message.raise_error;
   ELSE
        CLOSE csr_lp_enr_id;
    END IF;


    hr_utility.set_location(' Leaving:'||l_proc, 20);

END check_duplicate_subscription;
-- ----------------------------------------------------------------------------
-- |---------------------------<insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lpe_shd.g_rec_type
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
    ,p_associated_column1 => ota_lpe_shd.g_tab_nam
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
  chk_person_contact(p_person_id     	  => p_rec.person_id,
                     p_contact_id         => p_rec.contact_id);

  chk_person_id(p_effective_date          => p_effective_date,
                p_person_id               => p_rec.person_id);

  check_duplicate_subscription(  p_person_id         => p_rec.person_id
                                ,p_contact_id        => p_rec.contact_id
                                ,p_learning_path_id  => p_rec.learning_path_id);
  chk_path_status_code(p_effective_date   => p_effective_date,
                       p_path_status_code => p_rec.path_status_code);

  chk_enrollment_source_code(p_effective_date         => p_effective_date,
                             p_enrollment_source_code => p_rec.enrollment_source_code);
  --

  IF get_path_source_code(p_rec.learning_path_id) NOT IN ('CATALOG', 'TALENT_MGMT') THEN
     ota_lpe_bus.chk_df(p_rec);
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
  ,p_rec                          in ota_lpe_shd.g_rec_type
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
    ,p_associated_column1 => ota_lpe_shd.g_tab_nam
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
  --
  chk_person_contact(p_person_id     	=> p_rec.person_id,
                     p_contact_id       => p_rec.contact_id);

  chk_person_id(p_effective_date          => p_effective_date,
                p_person_id               => p_rec.person_id);

  chk_path_status_code(p_effective_date   => p_effective_date,
                       p_path_status_code => p_rec.path_status_code);

  chk_enrollment_source_code(p_effective_date         => p_effective_date,
                             p_enrollment_source_code => p_rec.enrollment_source_code);
  --
  IF get_path_source_code(p_rec.learning_path_id) NOT IN ('CATALOG', 'TALENT_MGMT') THEN
     ota_lpe_bus.chk_df(p_rec);
 END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_lpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_del_lp_enrollment_id(p_lp_enrollment_id    => p_rec.lp_enrollment_id);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_lpe_bus;

/
