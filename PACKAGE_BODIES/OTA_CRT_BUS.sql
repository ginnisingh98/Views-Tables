--------------------------------------------------------
--  DDL for Package Body OTA_CRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CRT_BUS" as
/* $Header: otcrtrhi.pkb 120.14 2006/03/17 14:54 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_crt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_certification_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_certification_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_certifications_b crt
     where crt.certification_id = p_certification_id
       and pbg.business_group_id = crt.business_group_id;
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
    ,p_argument           => 'certification_id'
    ,p_argument_value     => p_certification_id
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
        => nvl(p_associated_column1,'CERTIFICATION_ID')
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
  (p_certification_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_certifications_b crt
     where crt.certification_id = p_certification_id
       and pbg.business_group_id = crt.business_group_id;
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
    ,p_argument           => 'certification_id'
    ,p_argument_value     => p_certification_id
    );
  --
  if ( nvl(ota_crt_bus.g_certification_id, hr_api.g_number)
       = p_certification_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_crt_bus.g_legislation_code;
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
    ota_crt_bus.g_certification_id            := p_certification_id;
    ota_crt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_crt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.certification_id is not null)  and (
    nvl(ota_crt_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_crt_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.certification_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_CERTIFICATIONS'
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
  ,p_rec in ota_crt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_crt_shd.api_updating
      (p_certification_id                  => p_rec.certification_id
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
     NVL(ota_crt_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'BUSINESS_GROUP_ID'
         ,p_base_table => ota_crt_shd.g_tab_nam);
  END IF;
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF NVL(p_rec.certification_id, hr_api.g_number) <>
     NVL(ota_crt_shd.g_old_rec.certification_id, hr_api.g_number) THEN
     hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'CERTIFICATION_ID'
         ,p_base_table => ota_crt_shd.g_tab_nam);
  END IF;
  --
 EXCEPTION

    WHEN OTHERS THEN
       RAISE;

End chk_non_updateable_args;

PROCEDURE chk_should_warn
  (p_certification_id              IN     ota_certifications_b.certification_id%TYPE
   , p_initial_completion_date     IN ota_certifications_b.initial_completion_date%TYPE
   , p_initial_completion_duration IN ota_certifications_b.initial_completion_duration%TYPE
   , p_renewal_duration            IN ota_certifications_b.renewal_duration%TYPE
   , p_validity_duration           IN ota_certifications_b.validity_duration%TYPE
   , p_validity_start_type         IN ota_certifications_b.validity_start_type%TYPE
   , p_renewable_flag              IN ota_certifications_b.renewable_flag%TYPE
   , p_return_status OUT  NOCOPY VARCHAR2)
  IS
--


   CURSOR csr_old_cert is
      SELECT
         c.initial_completion_date,
         c.initial_completion_duration,
         c.renewal_duration,
         c.validity_duration,
         c.validity_start_type,
         c.renewable_flag
      FROM ota_certifications_b c
      WHERE certification_id = p_certification_id;

    l_proc  VARCHAR2(72) :=      g_package|| 'chk_should_warn';

    l_old_init_compl_date     ota_certifications_b.initial_completion_date%TYPE;
    l_old_init_compl_duration ota_certifications_b.initial_completion_duration%TYPE;
    l_old_renew_duration      ota_certifications_b.renewal_duration%TYPE;
    l_old_valid_duration      ota_certifications_b.validity_duration%TYPE;
    l_old_start_type          ota_certifications_b.validity_start_type%TYPE;
    l_old_renew_flag          ota_certifications_b.renewable_flag%TYPE;

    l_init_compl_date_changed   BOOLEAN;
    l_init_compl_dur_changed    BOOLEAN;
    l_renew_dur_changed         BOOLEAN;
    l_valid_dur_changed         BOOLEAN;
    l_start_type_changed        BOOLEAN;
    l_renew_flag_changed        BOOLEAN;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  OPEN csr_old_cert;
  FETCH csr_old_cert into l_old_init_compl_date, l_old_init_compl_duration,
        l_old_renew_duration, l_old_valid_duration, l_old_start_type, l_old_renew_flag;
  CLOSE csr_old_cert;

  l_init_compl_date_changed  := ota_general.value_changed(l_old_init_compl_date,
                                       p_initial_completion_date);

  l_init_compl_dur_changed  := ota_general.value_changed(l_old_init_compl_duration,
                                       p_initial_completion_duration);

  l_renew_dur_changed  := ota_general.value_changed(l_old_renew_duration,
                                       p_renewal_duration);

  l_valid_dur_changed  := ota_general.value_changed(l_old_valid_duration,
                                       p_validity_duration);

  l_start_type_changed  := ota_general.value_changed(l_old_start_type,
                                       p_validity_start_type);

  l_renew_flag_changed  := ota_general.value_changed(l_old_renew_flag,
                                       p_renewable_flag);

  p_return_status := 'S';

  /*
  if l_init_compl_date_changed OR l_init_compl_dur_changed
     OR l_renew_dur_changed    OR l_valid_dur_changed
     OR l_start_type_changed   OR l_renew_flag_changed
  */
  if l_renew_dur_changed OR l_valid_dur_changed OR l_start_type_changed
  then
     p_return_status := 'E';
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End chk_should_warn;
  --
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_renewable_cert >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_renewable_cert
  (p_renewable_flag        IN     ota_certifications_b.renewable_flag%TYPE
  ,p_validity_duration     IN     ota_certifications_b.validity_duration%TYPE
  ,p_certification_id      IN  ota_certifications_b.certification_id%type
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_renewable_cert';
--

BEGIN

  IF p_renewable_flag = 'Y' AND p_validity_duration is null
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443778_CERT_VALIDITY_NULL');
    fnd_message.raise_error;
  END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.VALIDITY_DURATION') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_renewable_cert;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_renew_duration >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_renew_duration
  (p_validity_duration     IN     ota_certifications_b.validity_duration%TYPE
  ,p_renewal_duration      IN     ota_certifications_b.renewal_duration%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_renew_duration';
--

BEGIN

  IF p_validity_duration is not null AND p_renewal_duration is not null
     AND p_validity_duration < p_renewal_duration
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443777_CERT_RENEW');
    fnd_message.raise_error;
  END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.VALIDITY_DURATION') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_renew_duration;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_init_completion >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_init_completion
  (p_effective_date           in date
  ,p_init_compl_date          IN  ota_certifications_b.initial_completion_date%TYPE
  ,p_init_compl_duration      IN  ota_certifications_b.initial_completion_duration%TYPE
  ,p_start_date_active        IN  ota_certifications_b.start_date_active%type
  ,p_end_date_active          IN  ota_certifications_b.end_date_active%type
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_init_completion';
  l_current_year number;
  l_max_value number;
--

BEGIN

  IF p_init_compl_date is null AND p_init_compl_duration is null
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443775_CERT_INIT_COMPL_NUL');
    fnd_message.raise_error;
  END IF;

  IF p_init_compl_date is not null AND p_init_compl_duration is not null
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443774_CERT_INIT_COMPL');
    fnd_message.raise_error;
  END IF;

  if p_init_compl_date is not null
  then
     if p_start_date_active > p_init_compl_date
     then
        hr_utility.set_location(' Step:'|| l_proc, 60);
        fnd_message.set_name('OTA', 'OTA_443953_CRT_INIT_COMP_ERROR');
        fnd_message.raise_error;
     Elsif p_end_date_active is not null and p_end_date_active < p_init_compl_date
     then
     	 hr_utility.set_location(' Step:'|| l_proc, 60);
         fnd_message.set_name('OTA', 'OTA_443953_CRT_INIT_COMP_ERROR');
         fnd_message.raise_error;
     end if;
  end if;

  if p_init_compl_duration is not null
  then
     --l_current_year := EXTRACT(YEAR FROM sysdate);
     l_current_year := EXTRACT(YEAR FROM p_effective_date);
     --l_max_value := (4712 - l_current_year) * 365;
     if p_init_compl_duration > 9999
     then
        hr_utility.set_location(' Step:'|| l_proc, 60);
        fnd_message.set_name('OTA', 'OTA_443956_EXCEED_MAX_VALUE');
        fnd_message.set_token('MAX_VALUE', 9999);
        fnd_message.raise_error;
     end if;
  end if;



  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.initial_completion_duration'
				,p_associated_column2   => 'OTA_CERTIFICATIONS_B.initial_completion_date') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_init_completion;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_range >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_date_range
  (p_start_date          IN  ota_certifications_b.start_date_active%TYPE
  ,p_end_date            IN  ota_certifications_b.end_date_active%type
  ,p_init_compl_date     IN  ota_certifications_b.initial_completion_date%type
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_date_range';
--

BEGIN

  IF p_start_date is not null and p_end_date is not null and p_start_date > p_end_date
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13312_GEN_DATE_ORDER');
    fnd_message.raise_error;
  END IF;

  IF p_start_date is not null and p_init_compl_date is not null and p_start_date > p_init_compl_date
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443771_CERT_INIT_CMPL_DATE');
    fnd_message.raise_error;
  END IF;


  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.start_date_active') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_date_range;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_notify_days     >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_notify_days
  (p_effective_date  IN date
  ,p_notify_days     IN  ota_certifications_b.notify_days_before_expire%type
  ,p_initial_completion_duration IN ota_certifications_b.initial_completion_duration%type
  ,p_initial_completion_date IN ota_certifications_b.initial_completion_date%type
  ,p_validity_duration       IN ota_certifications_b.validity_duration%type
  ,p_certification_id   IN  ota_certifications_b.certification_id%type
    ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_notify_days';
  l_max_value number;
--

BEGIN

  IF p_notify_days is not null
  then
    if p_initial_completion_duration is not null and p_notify_days > p_initial_completion_duration
    then
       hr_utility.set_location(' Step:'|| l_proc, 60);
       fnd_message.set_name('OTA', 'OTA_443957_CRT_NTF_DAY_EXCEEDS');
       fnd_message.raise_error;
    elsif p_initial_completion_date is not null
    then
       if p_initial_completion_date >= trunc(p_effective_date) then
          l_max_value := trunc(p_initial_completion_date - p_effective_date);
       end if;

       --bypass notify days check for onetime older certs with no susbcrs

       if l_max_value is not null then
         if p_validity_duration is not null and p_validity_duration < l_max_value
         then
	      l_max_value := p_validity_duration;
	     end if;
	   elsif p_validity_duration is not null then
	      l_max_value := p_validity_duration;
       end if;

       if p_notify_days > l_max_value
	   then
	     hr_utility.set_location(' Step:'|| l_proc, 60);
         fnd_message.set_name('OTA', 'OTA_443956_EXCEED_MAX_VALUE');
         fnd_message.set_token('MAX_VALUE', l_max_value);
         fnd_message.raise_error;
       end if;
    end if;

  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.notify_days_before_expire') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_notify_days;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_init_compl_date >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_init_compl_date
  (p_effective_date      IN  date
  ,p_init_compl_date     IN  ota_certifications_b.initial_completion_date%type
  ,p_certification_id   IN  ota_certifications_b.certification_id%type
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_init_compl_date';

--

BEGIN
--Bug#4570505
--  IF p_init_compl_date is not null and p_init_compl_date < sysdate
--  IF p_init_compl_date is not null and p_init_compl_date < trunc(sysdate)
  IF p_init_compl_date is not null and p_init_compl_date < trunc(p_effective_date)
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443771_CERT_INIT_CMPL_DATE');
    fnd_message.raise_error;
  END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.initial_completion_date') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_init_compl_date;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_validity_duration >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_validity_duration
  (p_validity_duration     IN  ota_certifications_b.validity_duration%type
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_validity_duration';
--

BEGIN

  IF p_validity_duration is not null and p_validity_duration > 9999
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443956_EXCEED_MAX_VALUE');
    fnd_message.set_token('MAX_VALUE', 9999);
    fnd_message.raise_error;
  END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.validity_duration') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_validity_duration;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_based_cert >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_date_based_cert
  (p_init_compl_date     IN  ota_certifications_b.initial_completion_date%type
  ,p_renewable_flag      IN  ota_certifications_b.renewable_flag%TYPE
  ,p_renewal_duration    IN  ota_certifications_b.renewal_duration%TYPE
  ,p_validity_start_type  IN  ota_certifications_b.validity_start_type%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_date_based_cert';
--

BEGIN

  IF p_init_compl_date is not null and p_renewable_flag = 'Y'
    and p_renewal_duration is null
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443772_CERT_DATE_BASED');
    fnd_message.raise_error;
  END IF;

  IF p_init_compl_date is not null AND p_renewable_flag = 'Y'
    and p_validity_start_type = 'A'
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_443773_CERT_VALIDITY_START');
    fnd_message.raise_error;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_B.validity_start_type') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_date_based_cert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_enr_exists >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This certification may not be deleted if child rows in
--   ota_cert_enrollments exist.
--
Procedure chk_enr_exists
  (
   p_certification_id  in  number
  ) is
  --
  l_exists                varchar2(1);
  l_proc                  varchar2(72) := g_package||'chk_enr_exists';
  --
  cursor sel_enr_exists is
    select 'Y'
      from ota_cert_enrollments  cre
     where cre.certification_id = p_certification_id;
  --
Begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  Open  sel_enr_exists;
  fetch sel_enr_exists into l_exists;

  if sel_enr_exists%found then
    close sel_enr_exists;
    hr_utility.set_location(' Step:'|| l_proc, 20);
           fnd_message.set_name('OTA', 'OTA_443762_CERT_ENROLL_EXISTS');
           fnd_message.raise_error;
  else
    close sel_enr_exists;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
End chk_enr_exists;

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_enr_dates >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Update Validation.
--   The certification cannot start after or end before existing subscription dates.
--
Procedure chk_enr_dates
  (
   p_certification_id  in  number
   ,p_start_date_active in date
   ,p_end_date_active in date
  ) is
  --
  l_min_date              date;
  l_max_date			  date;
  l_proc                  varchar2(72) := g_package||'chk_enr_dates';
  --
  --
Begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  select min(cre.enrollment_date), max(cre.enrollment_date)
  into l_min_date, l_max_date
  from ota_cert_enrollments  cre
  where cre.certification_id = p_certification_id;

  if ((l_min_date is not null and l_min_date < p_start_date_active)
	   or (l_max_date is not null and p_end_date_active is not null and l_max_date > p_end_date_active))
  then
           hr_utility.set_location(' Step:'|| l_proc, 20);
           fnd_message.set_name('OTA', 'OTA_443960_CRT_ENRL_DATE_INVAL');
           fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);

  Exception
   when app_exception.application_exception then
      IF hr_multi_message.exception_add
            (p_associated_column1 => 'OTA_CERTIFICATIONS_B.START_DATE_ACTIVE'
            ,p_associated_column2 => 'OTA_CERTIFICATIONS_B.END_DATE_ACTIVE'
            ) THEN
          raise;
       END IF;

     --
  --
End chk_enr_dates;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_cmb_dates >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_cmb_dates
  (p_start_date          IN  ota_certifications_b.start_date_active%TYPE
  ,p_end_date            IN  ota_certifications_b.end_date_active%type
  ,p_cert_id             IN  ota_certifications_b.certification_id%type
  ) IS
--
  CURSOR csr_has_cmb is
     SELECT 'Y'
     FROM ota_certification_members m
     where m.certification_id = p_cert_id;

  CURSOR csr_cmb_dates is
      SELECT
         min(m.start_date_active) earliest_start, max(m.end_date_active) latest_end
      FROM ota_certification_members m
      WHERE m.certification_id = p_cert_id;

  l_proc  VARCHAR2(72) :=      g_package|| 'chk_cmb_dates';
  l_has_cmb             varchar2(1);
  l_earliest_start_date date;
  l_latest_end_date     date;
  l_cert_start_date     date;
  l_cert_end_date       date;
--

BEGIN
  open  csr_has_cmb;
  fetch csr_has_cmb into l_has_cmb;
  close csr_has_cmb;

  if l_has_cmb = 'Y'
  then

	 Open  csr_cmb_dates;
     fetch csr_cmb_dates into l_earliest_start_date, l_latest_end_date;
     close csr_cmb_dates;

     if l_earliest_start_date is null then
           l_earliest_start_date := hr_api.g_sot;
     end if;

     if l_latest_end_date is null then
         l_latest_end_date := hr_api.g_eot;
     end if;

     --
     l_cert_start_date := p_start_date;
     l_cert_end_date   := p_end_date;
  --
     if l_cert_end_date is null then
    		l_cert_end_date := hr_api.g_eot;
     end if;

     if l_earliest_start_date < l_cert_start_date or
            l_earliest_start_date > l_cert_end_date or
            l_latest_end_date > l_cert_end_date or
            l_latest_end_date < l_cert_start_date then

	        fnd_message.set_name('OTA','OTA_443936_CRT_DATE_OUT_OF_CMB');
            fnd_message.raise_error;
     end if;
  end if;
	--
	hr_utility.set_location(' Leaving:' || l_proc,10);

 Exception
   when app_exception.application_exception then
      IF hr_multi_message.exception_add
            (p_associated_column1 => 'OTA_CERTIFICATIONS_B.START_DATE_ACTIVE'
            ,p_associated_column2 => 'OTA_CERTIFICATIONS_B.END_DATE_ACTIVE'
            ) THEN
          raise;
       END IF;

     --

END chk_cmb_dates;

PROCEDURE chk_upd_exis_subscr
  (p_certification_id              IN     ota_certifications_b.certification_id%TYPE
   , p_initial_completion_date     IN ota_certifications_b.initial_completion_date%TYPE
   , p_initial_completion_duration IN ota_certifications_b.initial_completion_duration%TYPE
   , p_renewable_flag              IN ota_certifications_b.renewable_flag%TYPE
   , p_notify_days                 IN  ota_certifications_b.notify_days_before_expire%type)
  IS
--

CURSOR csr_exis_subscr
IS
SELECT 'Y'
  FROM OTA_CERT_ENROLLMENTS
 where certification_id = p_certification_id;

l_subscr_exists varchar2(1);


    l_proc  VARCHAR2(72) :=      g_package|| 'chk_upd_exis_subscr';

    l_init_compl_date_changed   BOOLEAN;
    l_init_compl_dur_changed    BOOLEAN;
    l_renew_flag_changed        BOOLEAN;
    l_notify_days_changed        BOOLEAN;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --Bug 4637071 chk for exist subscr and process
  OPEN csr_exis_subscr;
  FETCH csr_exis_subscr into l_subscr_exists;
  CLOSE csr_exis_subscr;

  if l_subscr_exists = 'Y' then
     l_init_compl_date_changed  := ota_general.value_changed(ota_crt_shd.g_old_rec.initial_completion_date,
					  p_initial_completion_date);

     l_init_compl_dur_changed  := ota_general.value_changed(ota_crt_shd.g_old_rec.initial_completion_duration,
					  p_initial_completion_duration);

     l_renew_flag_changed  := ota_general.value_changed(ota_crt_shd.g_old_rec.renewable_flag,
					  p_renewable_flag);

     l_notify_days_changed  := ota_general.value_changed(ota_crt_shd.g_old_rec.notify_days_before_expire,
					  p_notify_days);

     if l_init_compl_date_changed OR l_init_compl_dur_changed
	OR l_renew_flag_changed OR l_notify_days_changed
     then
	fnd_message.set_name('OTA', 'OTA_443962_CRT_NO_UPD_EXIS_SUB');
	fnd_message.raise_error;
     end if;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

EXCEPTION
WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

	 IF HR_MULTI_MESSAGE.EXCEPTION_ADD
	     (P_ASSOCIATED_COLUMN1   => null) THEN
	     HR_UTILITY.SET_LOCATION(' LEAVING:'||L_PROC, 15);
	     RAISE;
	 END IF;

	 HR_UTILITY.SET_LOCATION(' LEAVING:'||L_PROC, 20);

End chk_upd_exis_subscr;

--
--
-- BUG#4654544
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_category_start_end_dates  >----------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure chk_category_start_end_dates
  (p_certification_id            in            number
  ,p_start_date                   in            date
  ,p_end_date                    in            date
  )  is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR csr_cat_start_end_date is
    select
          ctu.start_date_active,
          ctu.end_date_active
        from
          ota_category_usages ctu,
          ota_cert_cat_inclusions cci
        where
          ctu.category_usage_id = cci.category_usage_id
          and cci.primary_flag= 'Y'
         and cci.certification_id =  p_certification_id ;

--
-- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'chk_category_start_end_dates';
  l_cat_start_date        date;
  l_cat_end_date          date;


Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
          (p_check_column1   => 'OTA_CERTIFICATIONS.START_DATE_ACTIVE'
          ,p_check_column2   => 'OTA_CERTIFICATIONS.END_DATE_ACTIVE'
          ,p_associated_column1   => 'OTA_CERTIFICATIONS.START_DATE_ACTIVE'
          ,p_associated_column2   => 'OTA_CERTIFICATIONS.END_DATE_ACTIVE'
        ) THEN
     --
     OPEN csr_cat_start_end_date;
     FETCH csr_cat_start_end_date into l_cat_start_date, l_cat_end_date;

     IF csr_cat_start_end_date%FOUND  THEN
        CLOSE csr_cat_start_end_date;

        IF ( l_cat_start_date > p_start_date
             or nvl(l_cat_end_date,hr_api.g_eot) < nvl(p_end_date,hr_api.g_eot)
           ) THEN
          --
          fnd_message.set_name      ( 'OTA','OTA_443896_CRT_OUT_OF_CAT_DATE');
	  fnd_message.raise_error;
          --
        End IF;
     ELSE
         CLOSE csr_cat_start_end_date;

     End IF;
  End IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CERTIFICATIONS.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CERTIFICATIONS.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End chk_category_start_end_dates;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_crt_shd.g_rec_type
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
    ,p_associated_column1 => ota_crt_shd.g_tab_nam
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

  ota_crt_bus.chk_date_based_cert
  (p_init_compl_date     => p_rec.initial_completion_date
  ,p_renewable_flag      => p_rec.renewable_flag
  ,p_renewal_duration    => p_rec.renewal_duration
  ,p_validity_start_type  => p_rec.validity_start_type
  );

  ota_crt_bus.chk_init_compl_date
  (p_effective_date      => p_effective_date
  ,p_init_compl_date     => p_rec.initial_completion_date
  ,p_certification_id      => p_rec.certification_id
  );

  ota_crt_bus.chk_date_range
  (p_start_date          =>  p_rec.start_date_active
  ,p_end_date            =>  p_rec.end_date_active
  ,p_init_compl_date     =>  p_rec.initial_completion_date
  );

  ota_crt_bus.chk_init_completion
  (p_effective_date           => p_effective_date
  ,p_init_compl_date          => p_rec.initial_completion_date
  ,p_init_compl_duration      => p_rec.initial_completion_duration
  ,p_start_date_active        => p_rec.start_date_active
  ,p_end_date_active          => p_rec.end_date_active
  );

  ota_crt_bus.chk_renew_duration
  (p_validity_duration     => p_rec.validity_duration
  ,p_renewal_duration      => p_rec.renewal_duration
  );

  ota_crt_bus.chk_renewable_cert
  (p_renewable_flag        => p_rec.renewable_flag
  ,p_validity_duration     => p_rec.validity_duration
  ,p_certification_id      => p_rec.certification_id
  );

  ota_crt_bus.chk_notify_days
  (p_effective_date              => p_effective_date
  ,p_notify_days                 => p_rec.notify_days_before_expire
  ,p_initial_completion_duration => p_rec.initial_completion_duration
  ,p_initial_completion_date     => p_rec.initial_completion_date
  ,p_validity_duration           => p_rec.validity_duration
  ,p_certification_id      => p_rec.certification_id
  );

  ota_crt_bus.chk_validity_duration
  (p_validity_duration     => p_rec.validity_duration
  );

   ota_crt_bus.chk_df(p_rec);
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
  ,p_rec                          in ota_crt_shd.g_rec_type
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
    ,p_associated_column1 => ota_crt_shd.g_tab_nam
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

   ota_crt_bus.chk_upd_exis_subscr
   (p_certification_id             => p_rec.certification_id
   , p_initial_completion_date     => p_rec.initial_completion_date
   , p_initial_completion_duration => p_rec.initial_completion_duration
   , p_renewable_flag              => p_rec.renewable_flag
   , p_notify_days                 => p_rec.notify_days_before_expire);

   ota_crt_bus.chk_date_based_cert
  (p_init_compl_date     => p_rec.initial_completion_date
  ,p_renewable_flag      => p_rec.renewable_flag
  ,p_renewal_duration    => p_rec.renewal_duration
  ,p_validity_start_type  => p_rec.validity_start_type
  );

  ota_crt_bus.chk_date_range
  (p_start_date          =>  p_rec.start_date_active
  ,p_end_date            =>  p_rec.end_date_active
  ,p_init_compl_date     =>  p_rec.initial_completion_date
  );

  ota_crt_bus.chk_init_completion
  (p_effective_date           => p_effective_date
  ,p_init_compl_date          => p_rec.initial_completion_date
  ,p_init_compl_duration      => p_rec.initial_completion_duration
  ,p_start_date_active        => p_rec.start_date_active
  ,p_end_date_active          => p_rec.end_date_active
  );

  ota_crt_bus.chk_renew_duration
  (p_validity_duration     => p_rec.validity_duration
  ,p_renewal_duration      => p_rec.renewal_duration
  );

  ota_crt_bus.chk_renewable_cert
  (p_renewable_flag        => p_rec.renewable_flag
  ,p_validity_duration     => p_rec.validity_duration
  ,p_certification_id               => p_rec.certification_id);

  ota_crt_bus.chk_cmb_dates
  (p_start_date          => p_rec.start_date_active
  ,p_end_date            => p_rec.end_date_active
  ,p_cert_id             => p_rec.certification_id
  );

  ota_crt_bus.chk_notify_days
  (p_effective_date              => p_effective_date
  ,p_notify_days                 => p_rec.notify_days_before_expire
  ,p_initial_completion_duration => p_rec.initial_completion_duration
  ,p_initial_completion_date     => p_rec.initial_completion_date
  ,p_validity_duration           => p_rec.validity_duration
  ,p_certification_id               => p_rec.certification_id
  );

  ota_crt_bus.chk_validity_duration
  (p_validity_duration     => p_rec.validity_duration
  );

  ota_crt_bus.chk_enr_dates
  (
   p_certification_id  => p_rec.certification_id
   ,p_start_date_active => p_rec.start_date_active
   ,p_end_date_active   => p_rec.end_date_active
  );

  chk_category_start_end_dates(p_certification_id =>p_rec.certification_id,
	p_start_date =>p_rec.start_date_active,
	p_end_date =>p_rec.end_date_active );

   ota_crt_bus.chk_df(p_rec);
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_crt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  chk_enr_exists(p_certification_id    => p_rec.certification_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_crt_bus;

/
