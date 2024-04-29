--------------------------------------------------------
--  DDL for Package Body OTA_CCI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CCI_BUS" as
/* $Header: otccirhi.pkb 120.1 2005/07/21 15:07 estreacy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cci_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_category_usage_id           number         default null;
g_certification_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_category_usage_id                    in number
  ,p_certification_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_cert_cat_inclusions cci
         , ota_category_usages ctu
     where ctu.category_usage_id = p_category_usage_id
       and cci.category_usage_id = ctu.category_usage_id
       and cci.certification_id = p_certification_id
       and pbg.business_group_id = ctu.business_group_id;
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
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
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
        => nvl(p_associated_column1,'CATEGORY_USAGE_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'CERTIFICATION_ID')
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
  (p_category_usage_id                    in     number
  ,p_certification_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ota_cert_cat_inclusions cci
         , ota_category_usages ctu
     where ctu.category_usage_id = p_category_usage_id
       and cci.category_usage_id = ctu.category_usage_id
       and cci.certification_id = p_certification_id
       and pbg.business_group_id = ctu.business_group_id;
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
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'certification_id'
    ,p_argument_value     => p_certification_id
    );
  --
  if (( nvl(ota_cci_bus.g_category_usage_id, hr_api.g_number)
       = p_category_usage_id)
  and ( nvl(ota_cci_bus.g_certification_id, hr_api.g_number)
       = p_certification_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_cci_bus.g_legislation_code;
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
    ota_cci_bus.g_category_usage_id           := p_category_usage_id;
    ota_cci_bus.g_certification_id            := p_certification_id;
    ota_cci_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_cci_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.category_usage_id is not null) and
       (p_rec.certification_id is not null)  and (
    nvl(ota_cci_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_cci_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.category_usage_id is null) and
       (p_rec.certification_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_CERT_CAT_INCLUSIONS'
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
  ,p_rec in ota_cci_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_cci_shd.api_updating
      (p_category_usage_id                 => p_rec.category_usage_id
      ,p_certification_id                  => p_rec.certification_id
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
-- |--------------------------< check_crt_category_dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure check_cert_category_dates
  (
   p_certification_id           in    number
  , p_category_usage_id        in number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR csr_cat_start_end_date is
    SELECT
      start_date_active,
      nvl(end_date_active, to_date ('31-12-4712', 'DD-MM-YYYY'))
    FROM  ota_category_usages
    WHERE category_usage_id =p_category_usage_id;

   CURSOR csr_cert_start_end_date IS
     SELECT start_date_active,
                      nvl(end_date_active, to_date ('31-12-4712', 'DD-MM-YYYY'))
    FROM ota_certifications_b
    WHERE certification_id = p_certification_id;


   --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'check_category_dates';
  l_cat_start_date        date;
  l_cat_end_date          date;
  l_cert_start_date date;
  l_cert_end_date   date;

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

     OPEN csr_cert_start_end_date;
     FETCH csr_cert_start_end_date into l_cert_start_date, l_cert_end_date;

     IF csr_cat_start_end_date%FOUND  AND csr_cert_start_end_date%FOUND THEN
        CLOSE csr_cat_start_end_date;
	 CLOSE csr_cert_start_end_date;
        IF ( l_cat_start_date > l_cert_start_date
             or l_cat_end_date < l_cert_end_date
           ) THEN
          --
          fnd_message.set_name      ( 'OTA','OTA_443896_CRT_OUT_OF_CAT_DATE');
	  fnd_message.raise_error;
          --
        End IF;
     ELSE
         CLOSE csr_cat_start_end_date;
	 CLOSE csr_cert_start_end_date;
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
End check_cert_category_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cci_shd.g_rec_type
  ,p_certification_id in number
  ,p_category_usage_id in number
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  ota_ctu_bus.set_security_group_id(p_category_usage_id => p_category_usage_id);
  --
  -- Validate Dependent Attributes
  --
  --
  check_unique_key( p_certification_id
                  , p_category_usage_id );

  if p_rec.primary_flag = 'Y' then
     check_multiple_primary_ctgr(p_certification_id);
     check_cert_category_dates(p_certification_id => p_rec.certification_id
                               ,p_category_usage_id => p_rec.category_usage_id);
  end if;

  check_start_end_dates(p_rec.start_date_active
                        ,p_rec.end_date_active);

  --
  ota_cci_bus.chk_df(p_rec);
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cci_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';

  l_start_date_changed boolean := ota_general.value_changed(ota_cci_shd.g_old_rec.start_date_active
                             					,p_rec.start_date_active);
  l_end_date_changed boolean := ota_general.value_changed(ota_cci_shd.g_old_rec.end_date_active
                                               ,p_rec.end_date_active );
  l_start_date ota_cert_cat_inclusions.start_date_active%TYPE;
  l_end_date ota_cert_cat_inclusions.end_date_active%TYPE;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  ota_ctu_bus.set_security_group_id(p_category_usage_id => p_rec.category_usage_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  IF l_start_date_changed OR l_end_date_changed THEN
  		check_start_end_dates(p_rec.start_date_active
  		                      ,p_rec.end_date_active);

 		IF (l_start_date_changed) THEN
 		    l_start_date := p_rec.start_date_active;
 		ELSE
 		   l_start_date := ota_cci_shd.g_old_rec.start_date_active;
 		END IF;

 		IF (l_end_date_changed) THEN
 		    l_end_date := p_rec.end_date_active;
 		ELSE
 			l_end_date := ota_cci_shd.g_old_rec.end_date_active;
 		END IF;

 		check_category_dates(p_rec.category_usage_id
 		              ,l_start_date
 		              ,l_end_date);
  END IF;

  IF p_rec.primary_flag = 'Y' THEN
      check_cert_category_dates
	      (p_certification_id => p_rec.certification_id,
		   p_category_usage_id => p_rec.category_usage_id);
  END IF;
  --
  ota_cci_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_cci_shd.g_rec_type
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
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_multiple_primary_ctgr >---------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   There can be only one primary category for an activity.
--
Procedure check_multiple_primary_ctgr
  (
   p_certification_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_multiple_primary_ctgr';
  v_exists                varchar2(1);
  cursor sel_multiple_primary is
  select 'Y'
  from OTA_CERT_CAT_inclusions cci
  where cci.certification_id = p_certification_id
  and cci.primary_flag = 'Y';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open sel_multiple_primary;
  fetch sel_multiple_primary into v_exists;
  --
  if sel_multiple_primary%found then
    close sel_multiple_primary;

   fnd_message.set_name('OTA', 'OTA_13676_DCI_DUPLICATE');
    fnd_message.raise_error;
  end if;
  close sel_multiple_primary;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

Exception
WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CERT_CAT_INCLUSIONS.PRIMARY_FLAG')

                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
End check_multiple_primary_ctgr;

-- ----------------------------------------------------------------------------
-- |----------------------------< check_if_primary_category >-----------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check if an activity category already has a primary category.
--   This category cannot be deleted.
--
Procedure check_if_primary_category
  (
    p_certification_id  in  number
   ,p_category_usage_id    in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_primary_category';
  v_exists                varchar2(1);
  cursor sel_primary_category is
  select 'Y'
  from OTA_CERT_CAT_inclusions cci
  where cci.certification_id = p_certification_id
  and   cci.category_usage_id = p_category_usage_id
  and cci.primary_flag = 'Y';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open sel_primary_category;
  fetch sel_primary_category into v_exists;
  --
  if sel_primary_category%found then
    close sel_primary_category;

    fnd_message.set_name('OTA', 'OTA_443266_DCI_DEL_PRIMARY');
    fnd_message.raise_error;
  end if;
  close sel_primary_category;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CERT_CAT_INCLUSIONS.PRIMARY_FLAG')

                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
End check_if_primary_category;

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
  (
   p_start_date     in     date
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
                    p_associated_column1    => 'OTA_CERT_CAT_INCLUSIONS.START_DATE_ACTIVE'
                    ,p_associated_column2    => 'OTA_CERT_CAT_INCLUSIONS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_start_end_dates;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--   The module version and module category must form a unique key.
--
Procedure check_unique_key
  (
   p_certification_id in  number
  ,p_category_usage_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_unique_key';
  --
  cursor sel_unique_key is
    select 'Y'
      from OTA_CERT_CAT_inclusions  cci
     where cci.certification_id = p_certification_id
       and cci.category_usage_id   = p_category_usage_id;
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open sel_unique_key;
  fetch sel_unique_key into v_exists;
  --
  if sel_unique_key%found then
    close sel_unique_key;

    fnd_message.set_name('OTA', 'OTA_13676_DCI_DUPLICATE');
    fnd_message.raise_error;
  end if;
  close sel_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CERT_CAT_INCLUSIONS.certification_id',
                    p_associated_column2    => 'OTA_CERT_CAT_INCLUSIONS.CATEGORY_USAGE_ID')
                                                              THEN
                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
End check_unique_key;
--

--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_category_dates >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate booking deals
--   for this activity version.
--
Procedure check_category_dates
  (
   p_category_usage_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  l_error                 varchar2(10) := NULL;
  v_proc                  varchar2(72) := g_package||'check_category_dates';
  --
  cursor sel_check_dates is
    select start_date_active
         , end_date_active
      from ota_category_usages       ctu
     where ctu.category_usage_id   = p_category_usage_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date, v_end_date;
  IF sel_check_dates%FOUND THEN
   ota_general.check_par_child_dates(v_start_date, v_end_date,p_start_date,p_end_date);
  END IF;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CERT_CAT_INCLUSIONS.START_DATE_ACTIVE'
                    ,p_associated_column2    => 'OTA_CERT_CAT_INCLUSIONS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_category_dates;
--
--

end ota_cci_bus;

/
