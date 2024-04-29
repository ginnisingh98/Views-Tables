--------------------------------------------------------
--  DDL for Package Body OTA_CRE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CRE_BUS" as
/* $Header: otcrerhi.pkb 120.8 2006/02/01 15:02 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cre_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cert_enrollment_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cert_enrollment_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_cert_enrollments cre
     where cre.cert_enrollment_id = p_cert_enrollment_id
       and pbg.business_group_id = cre.business_group_id;
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
    ,p_argument           => 'cert_enrollment_id'
    ,p_argument_value     => p_cert_enrollment_id
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
        => nvl(p_associated_column1,'CERT_ENROLLMENT_ID')
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
  (p_cert_enrollment_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_cert_enrollments cre
     where cre.cert_enrollment_id = p_cert_enrollment_id
       and pbg.business_group_id = cre.business_group_id;
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
    ,p_argument           => 'cert_enrollment_id'
    ,p_argument_value     => p_cert_enrollment_id
    );
  --
  if ( nvl(ota_cre_bus.g_cert_enrollment_id, hr_api.g_number)
       = p_cert_enrollment_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_cre_bus.g_legislation_code;
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
    ota_cre_bus.g_cert_enrollment_id          := p_cert_enrollment_id;
    ota_cre_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_cre_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.cert_enrollment_id is not null)  and (
    nvl(ota_cre_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_cre_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.cert_enrollment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_CERT_ENROLLMENTS'
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
  ,p_rec in ota_cre_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_cre_shd.api_updating
      (p_cert_enrollment_id                => p_rec.cert_enrollment_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --  Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< chk_person_contact >---------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_person_contact (p_person_id   ota_cert_enrollments.person_id%TYPE,
                              p_contact_id  ota_cert_enrollments.contact_id%TYPE)
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
                    p_associated_column1    => 'OTA_CERT_ENROLLMENTS.PERSON_ID') THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 52);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 55);

END chk_person_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_certification_status_code >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_certification_status_code
  (p_effective_date            IN     date
  ,p_certification_status_code    IN     ota_cert_enrollments.CERTIFICATION_STATUS_CODE%TYPE
  ) IS
--
  l_proc  varchar2(72) :=      g_package|| 'chk_certification_status_code';
--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_certification_status_code'
    ,p_argument_value =>   p_certification_status_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF hr_api.not_exists_in_hr_lookups
    (p_effective_date   =>   p_effective_date
    ,p_lookup_type      =>   'OTA_CERT_ENROLL_STATUS'
    ,p_lookup_code      =>   p_certification_status_code
    ) THEN
    -- Error, lookup not available
        fnd_message.set_name('OTA', 'OTA_443665_CRE_STAT_INVALID');
        fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);

--MULTI MESSAGE SUPPORT
EXCEPTION
        WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CERT_ENROLLMENTS.CERTIFICATION_STATUS_CODE') THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 32);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 35);

END chk_certification_status_code;

--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_cert_enrollment_id >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_del_cert_enrollment_id
  (p_cert_enrollment_id          IN     ota_cert_enrollments.cert_enrollment_id%TYPE)
   IS
--
  l_exists varchar2(1);
  l_proc   varchar2(72) :=      g_package|| 'chk_del_cert_enrollment_id';
  l_cert_enroll_status varchar2(30);

 CURSOR csr_cert_prd_enr_id IS
 SELECT null
   FROM ota_cert_prd_enrollments cpe
  WHERE cpe.cert_enrollment_id = p_cert_enrollment_id;

 CURSOR csr_cert_enr_status is
 SELECT certification_status_code
  FROM  ota_cert_enrollments
  WHERE cert_enrollment_id = p_cert_enrollment_id;


--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_cert_enrollment_id'
    ,p_argument_value =>   p_cert_enrollment_id
    );
  --
  -- Check that the cert_enrollment can be deleted
  --
   OPEN csr_cert_prd_enr_id;
  FETCH csr_cert_prd_enr_id INTO l_exists;
     IF csr_cert_prd_enr_id%FOUND THEN
        CLOSE csr_cert_prd_enr_id;
        hr_utility.set_location(' Step:'|| l_proc, 20);
        fnd_message.set_name('OTA', 'OTA_443818_NO_DEL_HAS_CHILD');
        FND_MESSAGE.SET_TOKEN ('ENTITY_NAME', 'Certification Period Enrollment');
        fnd_message.raise_error;
   ELSE
        CLOSE csr_cert_prd_enr_id;
    END IF;

  OPEN csr_cert_enr_status;
  FETCH csr_cert_enr_status INTO l_cert_enroll_status;
     IF csr_cert_enr_status%FOUND THEN
        CLOSE csr_cert_enr_status;
        IF l_cert_enroll_status= 'AWAITING_APPROVAL' then
           hr_utility.set_location(' Step:'|| l_proc, 30);
           fnd_message.set_name('OTA', 'OTA_443920_CRT_NO_DEL_APV_WAIT');
           fnd_message.raise_error;
        END IF;
   ELSE
        CLOSE csr_cert_enr_status;
    END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 40);

END chk_del_cert_enrollment_id;

--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<check_duplicate_subscription >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE check_duplicate_subscription
  (   p_certification_id IN ota_cert_enrollments.certification_id%TYPE
     ,p_contact_id IN ota_cert_enrollments.contact_id%TYPE default NULL
     ,p_person_id IN ota_cert_enrollments.person_id%TYPE default NULL)
   IS
--
  l_exists varchar2(1);
  l_proc   varchar2(72) :=      g_package|| 'check_duplicate_subscription';

 CURSOR csr_cert_enr_id IS
 SELECT null
   FROM ota_cert_enrollments cre
  WHERE cre.certification_id = p_certification_id
    AND ( cre.person_id = p_person_id and cre.contact_id IS NULL
          OR cre.contact_id = p_contact_id and cre.person_id IS NULL)
    AND cre.certification_status_code <> 'CANCELLED';

 CURSOR csr_get_object_type IS
 SELECT meaning
 FROM hr_lookups
 WHERE lookup_type = 'OTA_OBJECT_TYPE'
  and lookup_code = 'CRT';

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
    ,p_argument       =>  'p_certification_id'
    ,p_argument_value =>   p_certification_id
    );
  --
  -- check if learner is already subscribed
  --
   OPEN csr_cert_enr_id;
  FETCH csr_cert_enr_id INTO l_exists;
     IF csr_cert_enr_id%FOUND THEN
        CLOSE csr_cert_enr_id;

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
        CLOSE csr_cert_enr_id;
    END IF;


    hr_utility.set_location(' Leaving:'||l_proc, 20);

END check_duplicate_subscription;

-- ----------------------------------------------------------------------------
-- |----------------------<check_due_date_passed >-------------------------|
-- ----------------------------------------------------------------------------
-- Removed this check for renewal based certifications to allow for
-- new employees to subscribe to ongoing date based certs.
--
PROCEDURE check_due_date_passed
  (   p_certification_id IN ota_cert_enrollments.certification_id%TYPE)
   IS
--
  l_exists varchar2(1);
  l_proc   varchar2(72) :=      g_package|| 'check_due_date_passed';

 CURSOR csr_crt IS
 select
         b.INITIAL_COMPLETION_DATE
 from ota_certifications_b b
where certification_id = p_certification_id
and renewable_flag = 'N';

rec_crt csr_crt%rowtype;

--
BEGIN
--
-- check mandatory parameters have been set
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_certification_id'
    ,p_argument_value =>   p_certification_id
    );
  --
  -- check if the due date is passed already
  --

    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    if (rec_crt.initial_completion_date is not null and trunc(sysdate) > rec_crt.initial_completion_date) then
       --throw error for subscriptions beyond the due date.
       hr_utility.set_location(' Step:'|| l_proc, 20);
       fnd_message.set_name('OTA', 'OTA_443958_CRT_DUE_DATE_PASSED');
       FND_MESSAGE.SET_TOKEN ('DUE_DATE', rec_crt.INITIAL_COMPLETION_DATE);
       fnd_message.raise_error;
    end if;

    hr_utility.set_location(' Leaving:'||l_proc, 20);

END check_due_date_passed;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Important Attributes
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_cre_shd.g_tab_nam
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
  --
  chk_person_contact(p_person_id          => p_rec.person_id,
                     p_contact_id         => p_rec.contact_id);

  chk_person_id(p_effective_date          => p_effective_date,
                p_person_id               => p_rec.person_id);

	  check_duplicate_subscription(  p_person_id         => p_rec.person_id
	                                ,p_contact_id        => p_rec.contact_id
	                                ,p_certification_id  => p_rec.certification_id);
  --chk_path_status_code(p_effective_date   => p_effective_date,
  --                     p_path_status_code => p_rec.path_status_code);

  chk_certification_status_code(p_effective_date         => p_effective_date,
                             p_certification_status_code => p_rec.certification_status_code);
  --
  check_due_date_passed(p_certification_id  => p_rec.certification_id);
  --
  ota_cre_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Important Attributes
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_cre_shd.g_tab_nam
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
  chk_person_contact(p_person_id        => p_rec.person_id,
                     p_contact_id       => p_rec.contact_id);

  chk_person_id(p_effective_date          => p_effective_date,
                p_person_id               => p_rec.person_id);

  --chk_path_status_code(p_effective_date   => p_effective_date,
  --                     p_path_status_code => p_rec.path_status_code);

  chk_certification_status_code(p_effective_date         => p_effective_date,
                             p_certification_status_code => p_rec.certification_status_code);
  --
  --
  ota_cre_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_cre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  chk_del_cert_enrollment_id(p_cert_enrollment_id    => p_rec.cert_enrollment_id);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_cre_bus;

/
