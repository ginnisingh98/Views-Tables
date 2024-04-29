--------------------------------------------------------
--  DDL for Package Body OTA_ACI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACI_BUS" as
/* $Header: otacirhi.pkb 120.0 2005/05/29 06:51:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_aci_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_activity_version_id         number         default null;
g_category_usage_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_activity_version_id                  in number
  ,p_category_usage_id                    in number
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
         , ota_act_cat_inclusions aci
         , ota_category_usages ctu
     where aci.activity_version_id = p_activity_version_id
       and aci.category_usage_id = p_category_usage_id
       and pbg.business_group_id = ctu.business_group_id
       and ctu.category_usage_id = aci.category_usage_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  v_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => v_proc
    ,p_argument           => 'activity_version_id'
    ,p_argument_value     => p_activity_version_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => v_proc
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
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
        => nvl(p_associated_column1,'ACTIVITY_VERSION_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'CATEGORY_USAGE_ID')
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
  hr_utility.set_location(' Leaving:'|| v_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_activity_version_id                  in     number
  ,p_category_usage_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ota_act_cat_inclusions aci
         , ota_category_usages ctu
     where aci.activity_version_id = p_activity_version_id
       and aci.category_usage_id = p_category_usage_id
       and pbg.business_group_id = ctu.business_group_id
       and ctu.category_usage_id = aci.category_usage_id ;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  v_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => v_proc
    ,p_argument           => 'activity_version_id'
    ,p_argument_value     => p_activity_version_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => v_proc
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
  --
  if (( nvl(ota_aci_bus.g_activity_version_id, hr_api.g_number)
       = p_activity_version_id)
  and ( nvl(ota_aci_bus.g_category_usage_id, hr_api.g_number)
       = p_category_usage_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_aci_bus.g_legislation_code;
    hr_utility.set_location(v_proc, 20);
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
    hr_utility.set_location(v_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    ota_aci_bus.g_activity_version_id         := p_activity_version_id;
    ota_aci_bus.g_category_usage_id           := p_category_usage_id;
    ota_aci_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| v_proc, 40);
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
  (p_rec in ota_aci_shd.g_rec_type
  ) is
--
  v_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||v_proc,10);
  --
  if (
       --(p_rec.activity_version_id is not null)
       --(p_rec.category_usage_id is not null)  and
       (
    nvl(ota_aci_shd.g_old_rec.aci_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information_category, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information1, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information1, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information2, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information2, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information3, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information3, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information4, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information4, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information5, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information5, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information6, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information6, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information7, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information7, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information8, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information8, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information9, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information9, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information10, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information10, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information11, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information11, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information12, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information12, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information13, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information13, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information14, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information14, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information15, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information15, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information16, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information16, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information17, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information17, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information18, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information18, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information19, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information19, hr_api.g_varchar2)  or
    nvl(ota_aci_shd.g_old_rec.aci_information20, hr_api.g_varchar2) <>
    nvl(p_rec.aci_information20, hr_api.g_varchar2) ))
    --or (p_rec.activity_version_id is null)
    --   (p_rec.category_usage_id is null)
    then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_ACT_CAT_INCLUSIONS'
      ,p_attribute_category              => p_rec.aci_information_category
      ,p_attribute1_name                 => 'ACI_INFORMATION1'
      ,p_attribute1_value                => p_rec.aci_information1
      ,p_attribute2_name                 => 'ACI_INFORMATION2'
      ,p_attribute2_value                => p_rec.aci_information2
      ,p_attribute3_name                 => 'ACI_INFORMATION3'
      ,p_attribute3_value                => p_rec.aci_information3
      ,p_attribute4_name                 => 'ACI_INFORMATION4'
      ,p_attribute4_value                => p_rec.aci_information4
      ,p_attribute5_name                 => 'ACI_INFORMATION5'
      ,p_attribute5_value                => p_rec.aci_information5
      ,p_attribute6_name                 => 'ACI_INFORMATION6'
      ,p_attribute6_value                => p_rec.aci_information6
      ,p_attribute7_name                 => 'ACI_INFORMATION7'
      ,p_attribute7_value                => p_rec.aci_information7
      ,p_attribute8_name                 => 'ACI_INFORMATION8'
      ,p_attribute8_value                => p_rec.aci_information8
      ,p_attribute9_name                 => 'ACI_INFORMATION9'
      ,p_attribute9_value                => p_rec.aci_information9
      ,p_attribute10_name                => 'ACI_INFORMATION10'
      ,p_attribute10_value               => p_rec.aci_information10
      ,p_attribute11_name                => 'ACI_INFORMATION11'
      ,p_attribute11_value               => p_rec.aci_information11
      ,p_attribute12_name                => 'ACI_INFORMATION12'
      ,p_attribute12_value               => p_rec.aci_information12
      ,p_attribute13_name                => 'ACI_INFORMATION13'
      ,p_attribute13_value               => p_rec.aci_information13
      ,p_attribute14_name                => 'ACI_INFORMATION14'
      ,p_attribute14_value               => p_rec.aci_information14
      ,p_attribute15_name                => 'ACI_INFORMATION15'
      ,p_attribute15_value               => p_rec.aci_information15
      ,p_attribute16_name                => 'ACI_INFORMATION16'
      ,p_attribute16_value               => p_rec.aci_information16
      ,p_attribute17_name                => 'ACI_INFORMATION17'
      ,p_attribute17_value               => p_rec.aci_information17
      ,p_attribute18_name                => 'ACI_INFORMATION18'
      ,p_attribute18_value               => p_rec.aci_information18
      ,p_attribute19_name                => 'ACI_INFORMATION19'
      ,p_attribute19_value               => p_rec.aci_information19
      ,p_attribute20_name                => 'ACI_INFORMATION20'
      ,p_attribute20_value               => p_rec.aci_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc,20);
end chk_ddf;
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
  ,p_rec in ota_aci_shd.g_rec_type
  ) IS
--
  v_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_aci_shd.api_updating
      (p_activity_version_id               => p_rec.activity_version_id
      ,p_category_usage_id                 => p_rec.category_usage_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALv_procEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', v_proc);
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
-- |--------------------------< Check_course_category_dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure Check_course_category_dates
  (p_activity_version_id        in    number
  ,p_category_usage_id          in    number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get dates of primary category.

  CURSOR csr_cat_start_end_date is
    SELECT
      start_date_active,
      nvl(end_date_active, hr_api.g_eot ),
      type
    FROM  ota_category_usages
    WHERE category_usage_id =p_category_usage_id;

   CURSOR csr_course_start_end_date IS
     SELECT
      start_date,
      nvl(end_date, hr_api.g_eot)
     FROM ota_activity_versions
     WHERE activity_version_id = p_activity_version_id;


   --
  -- Variables for API Boolean parameters
  l_proc                  varchar2(72) := g_package ||'Check_course_category_dates';
  l_cat_start_date        date;
  l_cat_end_date          date;
  l_cate_type             varchar2(30);
  l_course_start_date     date;
  l_course_end_date       date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
          (p_check_column1   => 'ota_activity_versions.START_DATE'
          ,p_check_column2   => 'ota_activity_versions.END_DATE'
          ,p_associated_column1   => 'ota_activity_versions.START_DATE'
          ,p_associated_column2   => 'ota_activity_versions.END_DATE'
        ) THEN
     --
     OPEN csr_cat_start_end_date;
     FETCH csr_cat_start_end_date into l_cat_start_date, l_cat_end_date,l_cate_type;

     OPEN csr_course_start_end_date;
     FETCH csr_course_start_end_date into l_course_start_date, l_course_end_date;

     IF csr_cat_start_end_date%FOUND  AND csr_course_start_end_date%FOUND THEN
        CLOSE csr_cat_start_end_date;
	CLOSE csr_course_start_end_date;
	hr_utility.set_location(' Cursors found:' || l_proc,10);
	IF (l_cate_type = 'C') THEN
	--
          IF ( l_cat_start_date > l_course_start_date
               or l_cat_end_date < l_course_end_date
             ) THEN
            --
            fnd_message.set_name      ( 'OTA','OTA_13062_ACT_OUT_OF_CAT_DATES');
            fnd_message.raise_error;
            --
          End IF;
        --
        End IF;
     ELSE
         CLOSE csr_cat_start_end_date;
	 CLOSE csr_course_start_end_date;
     End IF;
  End IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'ota_activity_versions.START_DATE'
                 ,p_associated_column2   => 'ota_activity_versions.END_DATE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Check_course_category_dates;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_category >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The activity category must be in the domain of 'ACTIVITY_CATEGORY'.
--
Procedure check_category
  (
   p_activity_category  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_category';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ota_general.check_domain_value( 'ACTIVITY_CATEGORY', p_activity_category);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End check_category;
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
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_multiple_primary_ctgr';
  v_exists                varchar2(1);
  cursor sel_multiple_primary is
  select 'Y'
  from ota_act_cat_inclusions aci
  where aci.activity_version_id = p_activity_version_id
  and aci.primary_flag = 'Y';
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
End check_multiple_primary_ctgr;
--
--
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
    p_activity_version_id  in  number
   ,p_category_usage_id    in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_primary_category';
  v_exists                varchar2(1);
  cursor sel_primary_category is
  select 'Y'
  from ota_act_cat_inclusions aci
  where aci.activity_version_id = p_activity_version_id
  and   aci.category_usage_id = p_category_usage_id
  and aci.primary_flag = 'Y';
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
                    p_associated_column1    => 'OTA_ACT_CAT_INCLUSIONS.PRIMARY_FLAG')

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
  ota_general.check_start_end_dates( p_start_date, p_end_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_ACT_CAT_INCLUSIONS.START_DATE_ACTIVE'
                    ,p_associated_column2    => 'OTA_ACT_CAT_INCLUSIONS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_start_end_dates;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must be within the Category dates
--   for this Course Category.
--
Procedure check_dates_update
  (
   p_category_usage_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  l_error                 boolean := FALSE;
  v_proc                  varchar2(72) := g_package||'check_dates_update';
  --
  cursor sel_check_dates is
    select start_date_active
         , end_date_active
      from ota_category_usages       aci
     where aci.category_usage_id   = p_category_usage_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date
                           , v_end_date;
  --
  Loop
    --
    Exit When sel_check_dates%notfound OR sel_check_dates%notfound is null;
    --

    If v_start_date is not null  Then
      --
      -- Child startdate is earlier than parent startdate
      --
      If p_start_date is not null  Then
        if p_start_date < v_start_date then
        --
           l_error := TRUE;
        --
        end if;
      End if;
      --
      -- Child enddate is earlier than parent startdate
      --
      If nvl( p_end_date, hr_api.g_eot) < v_start_date Then
        --
        l_error := TRUE;
        --
      End if;
      --
    End if;
    --
    -- Existing date for the parent enddate => Boundary parent enddate
    --
    If v_end_date is not null  Then
      --
      -- Child startdate is later than parent enddate
      --
      If nvl(p_start_date, hr_api.g_sot) > v_end_date Then
        --
        l_error := TRUE;
        --
      End if;
      --
      -- Child enddate is later than parent enddate
      --
      If p_end_date is not null Then
        if p_end_date > v_end_date then
        --
           l_error := TRUE;
        --
       end if;
      End if;
      --
    End if;
    --

    if l_error = true then
      fnd_message.set_name('OTA', 'OTA_443267_DCI_DATES');
      fnd_message.raise_error;
      l_error := false;
    end if;

    Fetch sel_check_dates into v_start_date
                             , v_end_date;
  End loop;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_ACT_CAT_INCLUSIONS.START_DATE_ACTIVE'
                    ,p_associated_column2    => 'OTA_ACT_CAT_INCLUSIONS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_dates_update;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_act >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must be within the Course dates
--   for this Course Category.
--

Procedure check_dates_update_act
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  l_error                 boolean := FALSE;
  v_proc                  varchar2(72) := g_package||'check_dates_update_act';
  --
  cursor sel_check_dates is
    select start_date
         , end_date
      from ota_activity_versions       tav
     where tav.activity_version_id   = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date
                           , v_end_date;
  --
  Loop
    --
    Exit When sel_check_dates%notfound OR sel_check_dates%notfound is null;
    --

    If v_start_date is not null  Then
      --
      -- Child startdate is earlier than parent startdate
      --
      If p_start_date is not null  Then
        if p_start_date < v_start_date then
        --
           l_error := TRUE;
        --
        end if;
      End if;
      --
      -- Child enddate is earlier than parent startdate
      --
      If nvl( p_end_date, hr_api.g_eot) < v_start_date Then
        --
        l_error := TRUE;
        --
      End if;
      --
    End if;
    --
    -- Existing date for the parent enddate => Boundary parent enddate
    --
    If v_end_date is not null  Then
      --
      -- Child startdate is later than parent enddate
      --
      If nvl(p_start_date, hr_api.g_sot) > v_end_date Then
        --
        l_error := TRUE;
        --
      End if;
      --
      -- Child enddate is later than parent enddate
      --
      If p_end_date is not null Then
        if p_end_date > v_end_date then
        --
           l_error := TRUE;
        --
       end if;
      End if;
      --
    End if;
    --

    if l_error = true then
      fnd_message.set_name('OTA', 'OTA_443533_ACI_AVT_DATES');
      fnd_message.raise_error;
      l_error := false;
    end if;

    Fetch sel_check_dates into v_start_date
                             , v_end_date;
  End loop;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_ACT_CAT_INCLUSIONS.START_DATE_ACTIVE'
                    ,p_associated_column2    => 'OTA_ACT_CAT_INCLUSIONS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_dates_update_act;


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
   p_activity_version_id in  number
  ,p_category_usage_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_unique_key';
  --
  cursor sel_unique_key is
    select 'Y'
      from ota_act_cat_inclusions  aci
     where aci.activity_version_id = p_activity_version_id
       and aci.category_usage_id   = p_category_usage_id;
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
                    p_associated_column1    => 'OTA_ACT_CAT_INCLUSIONS.ACTIVITY_VERSION_ID',
                    p_associated_column2    => 'OTA_ACT_CAT_INCLUSIONS.CATEGORY_USAGE_ID')
                                                              THEN
                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
End check_unique_key;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_aci_shd.g_rec_type
  ,p_activity_version_id in number
  ,p_category_usage_id in number
  ) is
--
  v_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  ota_ctu_bus.set_security_group_id(p_category_usage_id);
  --
  -- Call all supporting business operations
  --
  --
  check_unique_key( p_rec.activity_version_id
                  , p_rec.category_usage_id );
  --
  check_category( p_rec.activity_category );
  --
  if p_rec.primary_flag = 'Y' then
     check_multiple_primary_ctgr(p_rec.activity_version_id);
     --
     Check_course_category_dates
       (p_activity_version_id   =>  p_rec.activity_version_id
       ,p_category_usage_id     =>  p_rec.category_usage_id);
     --
  end if;

  check_start_end_dates(p_rec.start_date_active
                       ,p_rec.end_date_active);
  --
  check_dates_update(p_rec.category_usage_id
                    ,p_rec.start_date_active
                    ,p_rec.end_date_active);
 --
 check_dates_update_act( p_rec.activity_version_id
                        , p_rec.start_date_active
                        , p_rec.end_date_active);
  --
  ota_aci_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_aci_shd.g_rec_type
  ) is
--
  v_proc  varchar2(72) := g_package||'update_validate';
--
  l_activity_version_id_changed   boolean
    := ota_general.value_changed( ota_aci_shd.g_old_rec.activity_version_id
                               , p_rec.activity_version_id );
--
  l_activity_category_changed   boolean
    := ota_general.value_changed( ota_aci_shd.g_old_rec.activity_category
                               , p_rec.activity_category );
 l_primary_flag_changed   boolean
    := ota_general.value_changed( ota_aci_shd.g_old_rec.primary_flag
                               , p_rec.primary_flag );
--
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  ota_ctu_bus.set_security_group_id(p_rec.category_usage_id);
  --
  --
  --
  -- Validate Dependent Attributes
  --
/*
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
 */
  --
  -- Call all supporting business operations
  --
  If l_activity_version_id_changed   Or
     l_activity_category_changed     Then
    --
    check_unique_key( p_rec.activity_version_id
                    , p_rec.category_usage_id );

    --
  End if;
  --
  If l_activity_category_changed   Then
    --
    check_category( p_rec.activity_category );
    --
  End if;

  if p_rec.primary_flag = 'Y' then
    --
    Check_course_category_dates
      (p_activity_version_id   =>  p_rec.activity_version_id
      ,p_category_usage_id     =>  p_rec.category_usage_id);
    --
  end if;
  --
  if not l_primary_flag_changed then
  check_start_end_dates(p_rec.start_date_active
                       ,p_rec.end_date_active);
  --
  check_dates_update(p_rec.category_usage_id
                    ,p_rec.start_date_active
                    ,p_rec.end_date_active);

--
check_dates_update_act( p_rec.activity_version_id
                        , p_rec.start_date_active
                        , p_rec.end_date_active);

  --
  ota_aci_bus.chk_ddf(p_rec);
 end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_aci_shd.g_rec_type
  ) is
--
  v_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
    check_if_primary_category( p_rec.activity_version_id
                              ,p_rec.category_usage_id);
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
End delete_validate;
--
end ota_aci_bus;


/
