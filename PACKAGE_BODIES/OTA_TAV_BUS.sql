--------------------------------------------------------
--  DDL for Package Body OTA_TAV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TAV_BUS" as
/* $Header: ottav01t.pkb 120.2.12010000.3 2009/08/11 13:44:21 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tav_bus.';  -- Global package name
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
  (p_rec in ota_tav_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.activity_version_id is not null)  and (
    nvl(ota_tav_shd.g_old_rec.tav_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information_category, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information1, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information1, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information2, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information2, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information3, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information3, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information4, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information4, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information5, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information5, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information6, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information6, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information7, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information7, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information8, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information8, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information9, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information9, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information10, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information10, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information11, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information11, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information12, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information12, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information13, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information13, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information14, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information14, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information15, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information15, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information16, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information16, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information17, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information17, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information18, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information18, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information19, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information19, hr_api.g_varchar2)  or
    nvl(ota_tav_shd.g_old_rec.tav_information20, hr_api.g_varchar2) <>
    nvl(p_rec.tav_information20, hr_api.g_varchar2) ))
    or (p_rec.activity_version_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_ACTIVITY_VERSIONS'
      ,p_attribute_category              => p_rec.tav_information_category
      ,p_attribute1_name                 => 'TAV_INFORMATION1'
      ,p_attribute1_value                => p_rec.tav_information1
      ,p_attribute2_name                 => 'TAV_INFORMATION2'
      ,p_attribute2_value                => p_rec.tav_information2
      ,p_attribute3_name                 => 'TAV_INFORMATION3'
      ,p_attribute3_value                => p_rec.tav_information3
      ,p_attribute4_name                 => 'TAV_INFORMATION4'
      ,p_attribute4_value                => p_rec.tav_information4
      ,p_attribute5_name                 => 'TAV_INFORMATION5'
      ,p_attribute5_value                => p_rec.tav_information5
      ,p_attribute6_name                 => 'TAV_INFORMATION6'
      ,p_attribute6_value                => p_rec.tav_information6
      ,p_attribute7_name                 => 'TAV_INFORMATION7'
      ,p_attribute7_value                => p_rec.tav_information7
      ,p_attribute8_name                 => 'TAV_INFORMATION8'
      ,p_attribute8_value                => p_rec.tav_information8
      ,p_attribute9_name                 => 'TAV_INFORMATION9'
      ,p_attribute9_value                => p_rec.tav_information9
      ,p_attribute10_name                => 'TAV_INFORMATION10'
      ,p_attribute10_value               => p_rec.tav_information10
      ,p_attribute11_name                => 'TAV_INFORMATION11'
      ,p_attribute11_value               => p_rec.tav_information11
      ,p_attribute12_name                => 'TAV_INFORMATION12'
      ,p_attribute12_value               => p_rec.tav_information12
      ,p_attribute13_name                => 'TAV_INFORMATION13'
      ,p_attribute13_value               => p_rec.tav_information13
      ,p_attribute14_name                => 'TAV_INFORMATION14'
      ,p_attribute14_value               => p_rec.tav_information14
      ,p_attribute15_name                => 'TAV_INFORMATION15'
      ,p_attribute15_value               => p_rec.tav_information15
      ,p_attribute16_name                => 'TAV_INFORMATION16'
      ,p_attribute16_value               => p_rec.tav_information16
      ,p_attribute17_name                => 'TAV_INFORMATION17'
      ,p_attribute17_value               => p_rec.tav_information17
      ,p_attribute18_name                => 'TAV_INFORMATION18'
      ,p_attribute18_value               => p_rec.tav_information18
      ,p_attribute19_name                => 'TAV_INFORMATION19'
      ,p_attribute19_value               => p_rec.tav_information19
      ,p_attribute20_name                => 'TAV_INFORMATION20'
      ,p_attribute20_value               => p_rec.tav_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--

--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_min_max_values >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The minimum attendees must be less then or equal to the maximum attendees.
--
Procedure check_min_max_values
  (
   p_min  in  number
  ,p_max  in  number
  ) Is
  --
  v_proc 	varchar2(72) := g_package||'check_min_max_values';
  --
Begin
  --
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  ota_tav_api_business_rules.check_min_max_values( p_min
                                                 , p_max );
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.MINIMUM_ATTENDEES'
               ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.MAXIMUM_ATTENDEES'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_min_max_values;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_unique_name >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--
Procedure check_unique_name
  (
   p_business_group_id in number
  ,p_activity_id in number
  ,p_version_name  in  varchar2
  ,p_activity_version_id in number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_unique_name';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_unique_name( p_business_group_id
                                              , p_activity_id
                                              , p_version_name
                                              , p_activity_version_id);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_unique_name;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_competency_update_level  >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_competency_update_level (p_activity_version_id                     IN number
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

  l_api_updating := ota_tav_shd.api_updating
    (p_activity_version_id          => p_activity_version_id
    ,p_object_version_number     => p_object_version_number);


IF ((l_api_updating AND
       NVL(ota_tav_shd.g_old_rec.competency_update_level,hr_api.g_varchar2) <>
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
                (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.COMPETENCY_UPDATE_LEVEL') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_competency_update_level;

--
-- ----------------------------------------------------------------------------
-- |---------------------< check_superseding_version >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   A activity version may not be superseded ba a activity whose end_date
--   is greater than it's own. The supersedinthg activity version must have
--   an end date greater than the end date of the activity it supersedes.
--
Procedure check_superseding_version
  (
   p_sup_act_vers_id in  number
  ,p_end_date        in  date
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_superseding_version';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_superseding_version( p_sup_act_vers_id
                                                      , p_end_date );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.SUPERSEDE_BY_ACT_VERSION_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_superseding_version;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_user_status >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The user status must be in the domain 'Activity User Status'.
--
Procedure check_user_status
  (
   p_user_status  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_user_status';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_user_status( p_user_status );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
exception
  when app_exception.application_exception then
     if hr_multi_message.exception_add
             (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.USER_STATUS'
             ) then
        hr_utility.set_location(' Leaving:'|| v_proc,70);
        raise;
     end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_user_status;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_success_criteria >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The success criteria must be in the domain 'Activity Success Criteria'.
--
Procedure check_success_criteria
  (
   p_succ_criteria  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_success_criteria';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_success_criteria( p_succ_criteria );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
exception
  when app_exception.application_exception then
     if hr_multi_message.exception_add
             (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.SUCCESS_CRITERIA'
             ) then
        hr_utility.set_location(' Leaving:'|| v_proc,70);
        raise;
     end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_success_criteria;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_activity_version_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the surrogate key from a passed parameter
--
Function get_activity_version_id
  (
   p_activity_id      in     number
  ,p_version_name     in     varchar2
  )
   Return number is
  --
  v_proc                  varchar2(72) := g_package||'get_activity_version_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Return ota_tav_api_business_rules.get_activity_version_id( p_activity_id
                                                           , p_version_name );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_activity_version_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_activity_version_name >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the activity version name.
--
Function get_activity_version_name
  (
   p_activity_version_id   in   number
  ) Return varchar2 is
  --
  v_proc                 varchar2(72) := g_package||'get_activity_version_name';
  --
Begin
  --
  return ota_tav_api_business_rules.get_activity_version_name
                                   ( p_activity_version_id );
  --
End get_activity_version_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_start_end_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
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
  ota_tav_api_business_rules.check_start_end_dates( p_start_date
                                                  , p_end_date );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
exception
  when app_exception.application_exception then
     if hr_multi_message.exception_add
             (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
             ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
             ) then
        hr_utility.set_location(' Leaving:'|| v_proc,70);
        raise;
     end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_start_end_dates;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_ple >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate price list entry
--   for this activity version.
--
Procedure check_dates_update_ple
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  v_proc                  varchar2(72) := g_package||'check_dates_update_ple';
  --
  cursor sel_check_dates is
    select start_date
         , end_date
      from ota_price_list_entries    ple
     where ple.activity_version_id   = p_activity_version_id;
  --
Begin
  if hr_multi_message.no_error_message
  (p_check_message_name1 => 'OTA_13312_GEN_DATE_ORDER'
  ) then

  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_dates_update_ple( p_activity_version_id
                                                   , p_start_date
                                                   , p_end_date );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  end if;
exception
  when app_exception.application_exception then
     if hr_multi_message.exception_add
             (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
             ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
             ) then
        hr_utility.set_location(' Leaving:'|| v_proc,70);
        raise;
     end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_dates_update_ple;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_tbd >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate booking deals
--   for this activity version.
--
Procedure check_dates_update_tbd
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_dates_update_tbd';
  --
Begin
  if hr_multi_message.no_error_message
    (p_check_message_name1 => 'OTA_13312_GEN_DATE_ORDER'
  ) then
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_dates_update_tbd( p_activity_version_id
                                                   , p_start_date
                                                   , p_end_date );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  end if;
exception
  when app_exception.application_exception then
     if hr_multi_message.exception_add
             (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
             ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
             ) then
        hr_utility.set_location(' Leaving:'|| v_proc,70);
        raise;
     end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_dates_update_tbd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_evt >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate events
--   for this activity version.
--   This requires a check to ensure that the activity version dates do not
--   invalidate the Event Booking DAtes or the Event Course Dates if either
--   have been entered.
--
Procedure check_dates_update_evt
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_dates_update_evt';
  --
Begin
  if hr_multi_message.no_error_message
    (p_check_message_name1 => 'OTA_13312_GEN_DATE_ORDER'
  ) then
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_dates_update_evt( p_activity_version_id
                                                   , p_start_date
                                                   , p_end_date );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  end if;
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
               ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_dates_update_evt;
/* bug 3795299
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_tpm >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate training plan members
--   for this activity version.

Procedure check_dates_update_tpm
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_dates_update_tpm';
  --
Begin
  if hr_multi_message.no_error_message
    (p_check_message_name1 => 'OTA_13312_GEN_DATE_ORDER'
  ) then
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_trng_plan_util_ss.chk_valid_act_version_dates
                          (p_activity_version_id
                          ,p_start_date
                          ,p_end_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  end if;
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
               ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_dates_update_tpm;
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_evt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_events exist.
--
Procedure check_if_evt_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_evt_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_evt_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_evt_exists;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_evt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_offerings exist.
--
Procedure check_if_off_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_off_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_off_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_off_exists;
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- |-------------------------< check_if_tpm_exists >--------------------------
-- ---------------------------------------------------------------------------
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_training_plan_members exist.
--
Procedure check_if_tpm_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_tpm_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_tpm_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_tpm_exists;
--
--
-- ---------------------------------------------------------------------------
-- |-------------------------< check_if_lpm_exists >--------------------------
-- ---------------------------------------------------------------------------
-- PUBLIC
-- Description:
--Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_learning_path_members exist.
--
--
Procedure check_if_lpm_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_lpm_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_lpm_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_lpm_exists;
--
--

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tbd_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_booking_deals exist.
--
Procedure check_if_tbd_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_tbd_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_tbd_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_tbd_exists;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_ple_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_price_lists_entries exist.
--
Procedure check_if_ple_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_ple_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_ple_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_ple_exists;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_comp_exists >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_price_lists_entries exist.
--
Procedure check_if_comp_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_comp_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_comp_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_comp_exists;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tav_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_activity_versions exists where this activity version has superseded
--   another earlier activity version.
--
Procedure check_if_tav_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_tav_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_tav_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_tav_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tsp_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_skill_provisions
Procedure check_if_tsp_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_tsp_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_tsp_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_if_tsp_exists;
--

--
-- ----------------------------------------------------------------------------
-- |------------------------< check_duration_units >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The duration units must be in the domain 'Units'.
--
Procedure check_duration_units
  (
   p_duration_units  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_duration_units';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_duration_units( p_duration_units );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.DURATION_UNITS'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_duration_units;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_duration >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The duration must be a positive integer greater than zero.
--
Procedure check_duration
  (
   p_duration  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_duration';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_duration( p_duration );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.DURATION'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_duration;
-- ----------------------------------------------------------------------------
-- |---------------------------<  check_dur_unit_comb >-----------------------------|
-- ----------------------------------------------------------------------------


procedure check_dur_unit_comb( p_duration number,p_duration_units varchar2) is

begin
	if( p_duration < 0  )
	then
            fnd_message.set_name('OTA','OTA_443368_POSITIVE_NUMBER');
            fnd_message.raise_error;
	end if;

	if( (p_duration is null and p_duration_units is not null) or (p_duration is not null and p_duration_units is null)  )
	then
            fnd_message.set_name('OTA','OTA_13881_NHS_COMB_INVALID');
            fnd_message.raise_error;
	end if;
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_ACTIVITY_VERSIONS.DURATION'
	    ,p_associated_column2    => 'OTA_ACTIVITY_VERSIONS.DURATION_UNITS')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;
end check_dur_unit_comb;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_language >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The language must be in the domain 'Languages'.
--
Procedure check_language
  (
   p_language_id  in  number
  ) is
  v_proc                  varchar2(72) := g_package||'check_language';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_language( p_language_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.LANGUAGE_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_language;
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_controlling_person >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The controlling person should exist as a valid person on the Validity
--   Start Date of the Activity Version.
--
Procedure check_controlling_person
  (
   p_person_id  in  number
  ,p_date       in  date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_controlling_person';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_controlling_person( p_person_id
                                                     , p_date );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.CONTROLLING_PERSON_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_controlling_person;
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_multiple_con_version >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' then Versions of the Activity may not
--   have overlapping validity dates.
--
Procedure check_multiple_con_version
  (
   p_activity_id    in  number,
   p_activity_version_id in number,
   p_start_date in date,
   p_end_date   in date
  ) is
  --
  v_proc              varchar2(72) := g_package||'check_multiple_con_versions';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_multiple_con_version
                         ( p_activity_id
                         , p_activity_version_id
                         , p_start_date
                         , p_end_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
               ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
               ,p_associated_column3   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_multiple_con_version;
--
-- ----------------------------------------------------------------------------
-- |------------------< check_version_after_supersede >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' and the latest Activity Version has
--   been superseded by a Version of a different Activity, then new Version of
--   the Activity are not allowed (because there would be confusion over which
--   is the valid version of the activity, the new one or the superseding one).
--
Procedure check_version_after_supersede
  (
   p_activity_id    in  number
  ) is
  --
  v_proc            varchar2(72) := g_package||'check_version_after_supersede';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_version_after_supersede( p_activity_id );
    --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_version_after_supersede;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_course_lp_dates>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check dates of Course and Learning Path
--
--
--
--
Procedure check_course_lp_dates
(
p_activity_version_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE)

IS

l_proc  varchar2(72) := g_package||'check_course_lp_dates';
--
  l_start_date_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.start_date
                                , p_start_date );
--
  l_end_date_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.end_date
                                , p_end_date );

Begin

 hr_utility.set_location('Entering:'||l_proc, 5);
 ota_tav_api_business_rules.check_course_lp_dates( p_activity_version_id, p_start_date, p_end_date );

exception
    when app_exception.application_exception then
       if l_start_date_changed AND hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| l_proc,70);
          raise;
        elsif l_end_date_changed AND hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| l_proc,80);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| l_proc,90);
hr_utility.set_location('Leaving:'||l_proc, 30);
End;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_course_crt_dates>---------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check dates of Course and certification
--
--
--
--
Procedure check_course_crt_dates
(
p_activity_version_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE)

IS

l_proc  varchar2(72) := g_package||'check_course_crt_dates';
--
  l_start_date_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.start_date
                                , p_start_date );
--
  l_end_date_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.end_date
                                , p_end_date );

Begin

 hr_utility.set_location('Entering:'||l_proc, 5);
 ota_tav_api_business_rules.check_course_crt_dates( p_activity_version_id, p_start_date, p_end_date );

exception
    when app_exception.application_exception then
       if l_start_date_changed AND hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| l_proc,70);
          raise;
        elsif l_end_date_changed AND hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
               ) then
          hr_utility.set_location(' Leaving:'|| l_proc,80);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| l_proc,90);
hr_utility.set_location('Leaving:'||l_proc, 30);
End check_course_crt_dates;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_category >---------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check whether course is getting created under root category
--
--
--

PROCEDURE chk_category (p_activity_id                     IN number
                         ) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_category';
  l_api_updating boolean;
  l_parent_cat_usage_id number:= null;

cursor csr_is_root_category is
select cat.parent_cat_usage_id
from
ota_activity_definitions oad,
ota_category_usages cat
where
oad.category_usage_id=cat.category_usage_id
and oad.activity_id=p_activity_id;


BEGIN
  hr_utility.set_location(' Entering:'||l_proc, 10);
  --
  OPEN csr_is_root_category;
	FETCH csr_is_root_category into l_parent_cat_usage_id;
  CLOSE csr_is_root_category;



       IF l_parent_cat_usage_id IS  NULL THEN
               fnd_message.set_name('OTA','OTA_443361_COURSE_IN_ROOT_CAT');
               fnd_message.raise_error;
       END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 20);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.COMPETENCY_UPDATE_LEVEL') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 30);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 40);

END chk_category;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
        ,p_associated_column1 => ota_tav_shd.g_tab_nam ||
                                 '.BUSINESS_GROUP_ID'
       );
  end if;
  --
  -- After validating the set of important attributes,
  --  if multiple message detection is enabled and atleast
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  -- Call all supporting business operations
  --
  --
  check_min_max_values( p_rec.minimum_attendees
                      , p_rec.maximum_attendees);
  --

  check_unique_name( null
                   , p_rec.activity_id
                   , p_rec.version_name
                   , p_rec.activity_version_id);

  --
  check_superseding_version( p_rec.superseded_by_act_version_id
                           , p_rec.end_date);
  --
  check_version_after_supersede( p_rec.activity_id );
  --
  check_user_status( p_rec.user_status);
  --
  check_success_criteria( p_rec.success_criteria);
  --
  check_start_end_dates( p_rec.start_date
                       , p_rec.end_date );
  --
  check_duration_units( p_rec.duration_units);
  --
  check_duration( p_rec.duration);
check_dur_unit_comb( p_rec.duration,p_rec.duration_units);
  --
  check_language( p_rec.language_id);
  chk_competency_update_level (p_activity_version_id        => p_rec.activity_version_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_competency_update_level        => p_rec.competency_update_level
              ,p_effective_date          => trunc(sysdate));

  --
  ota_tav_api_business_rules.check_Inventory_item_id(
	p_rec.activity_version_id ,
	p_rec.inventory_item_id  ,
	p_rec.organization_id    );
  --
  -- **** Bug #2154926 changed call to check_controlling_person to use
  -- **** p_rec.end_date rather than p_rec.start_date
  --
  check_controlling_person( p_rec.controlling_person_id, p_rec.end_date);
  --
  check_multiple_con_version( p_rec.activity_id
                             , p_rec.activity_version_id
                             , p_rec.start_date
                             , p_rec.end_date);
  --
  ota_tav_api_business_rules.check_vendor (p_rec.vendor_id);
  --
  ota_tav_api_business_rules.check_currency(p_rec.budget_currency_code);
  --
  ota_tav_api_business_rules.check_cost_vals
              (p_rec.budget_currency_code
              ,p_rec.budget_cost
              ,p_rec.actual_cost);
  --
  ota_tav_api_business_rules.check_professional_credit_vals
              (p_rec.professional_credit_type
              ,p_rec.professional_credits);
  --
  ota_tav_api_business_rules.check_professional_credit_type
              (p_rec.professional_credit_type);

  /* For ILearning */
  ota_tav_api_business_rules.check_unique_rco_id
              (p_rec.activity_version_id,
		   p_rec.rco_id);
  --
ota_tav_bus.chk_ddf(p_rec);

chk_category(p_rec.activity_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_validate(p_rec in ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
  l_api_updating boolean
    := ota_tav_shd.api_updating(p_rec.activity_version_id
                               ,p_rec.object_version_number);
--
  l_minimum_attendees_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.minimum_attendees
                                , p_rec.minimum_attendees );
--
  l_maximum_attendees_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.maximum_attendees
                                , p_rec.maximum_attendees );
--
  l_activity_version_id_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.activity_version_id
                                , p_rec.activity_version_id );
--
  l_activity_id_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.activity_id
                                , p_rec.activity_id );
--
  l_version_name_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.version_name
                                , p_rec.version_name );
--
  l_super_by_act_vers_id_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.superseded_by_act_version_id
                                , p_rec.superseded_by_act_version_id );
--
  l_start_date_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.start_date
                                , p_rec.start_date );
--
  l_end_date_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.end_date
                                , p_rec.end_date );
--
  l_user_status_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.user_status
                                , p_rec.user_status );
--
  l_success_criteria_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.success_criteria
                                , p_rec.success_criteria );
--
  l_duration_units_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.duration_units
                                , p_rec.duration_units );
--
  l_duration_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.duration
                                , p_rec.duration );
--
  l_language_id_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.language_id
                                , p_rec.language_id );
--
  l_person_id_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.controlling_person_id
                                , p_rec.controlling_person_id );
--
  l_vendor_id_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.vendor_id
                                , p_rec.vendor_id);
--
  l_professional_ctype_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.professional_credit_type
                                , p_rec.professional_credit_type);
--
  l_professional_credits_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.professional_credits
                                , p_rec.professional_credits);
--
  l_budget_currency_code_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.budget_currency_code
                                , p_rec.budget_currency_code);
--
  l_budget_cost_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.budget_cost
                                , p_rec.budget_cost);
--
  l_actual_cost_changed   boolean
    := ota_general.value_changed( ota_tav_shd.g_old_rec.actual_cost
                                , p_rec.actual_cost);
--
  l_inventory_item_id_changed boolean
    := ota_general.value_changed (ota_tav_shd.g_old_rec.inventory_item_id
                                 , p_rec.inventory_item_id);

  l_rco_id_changed boolean
    := ota_general.value_changed (ota_tav_shd.g_old_rec.rco_id
                                 , p_rec.rco_id);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
        ,p_associated_column1 => ota_tav_shd.g_tab_nam ||
                                 '.BUSINESS_GROUP_ID'
       );
  end if;
  --
  -- After validating the set of important attributes,
  -- if multiple message detection is enabled and atleast
  -- one error has been found then abort further validation.
  hr_multi_message.end_validation_set;
  --
  --
  -- Validate Dependent Attributes
  --
  --
  -- Call all supporting business operations
  --
  If l_minimum_attendees_changed  Or
     l_maximum_attendees_changed  Then
    --
    check_min_max_values( p_rec.minimum_attendees
                        , p_rec.maximum_attendees);
    --
  End if;


chk_competency_update_level (p_activity_version_id        => p_rec.activity_version_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_competency_update_level        => p_rec.competency_update_level
              ,p_effective_date          => trunc(sysdate));



  If l_activity_id_changed   Or
     l_version_name_changed  Then
    --
  check_unique_name( null
                   , p_rec.activity_id
                   , p_rec.version_name
                   , p_rec.activity_version_id);

  chk_category(p_rec.activity_id);

    --
  End if;
  --
  If l_super_by_act_vers_id_changed  Or
     l_end_date_changed              Then
    --
    check_superseding_version( p_rec.superseded_by_act_version_id
                             , p_rec.end_date);
    --
  End if;
  --
  If l_user_status_changed  Then
    --
    check_user_status( p_rec.user_status);
    --
  End if;
  --
  If l_success_criteria_changed  Then
    --
    check_success_criteria( p_rec.success_criteria);
    --
  End if;
  --
  If l_start_date_changed  Or
     l_end_date_changed    Then
    --
    check_start_end_dates( p_rec.start_date
                         , p_rec.end_date );
    --
    check_dates_update_ple( p_rec.activity_version_id
                          , p_rec.start_date
                          , p_rec.end_date );
    --
/*
  ota_tav_api_business_rules.check_dates_update_rud( p_rec.activity_version_id
                                                   , p_rec.start_date
                                                   , p_rec.end_date
                                          , ota_tav_shd.g_old_rec.start_date
                                          , ota_tav_shd.g_old_rec.end_date
                                                   );
*/
    check_dates_update_tbd( p_rec.activity_version_id
                          , p_rec.start_date
                          , p_rec.end_date );
    --
    check_dates_update_evt( p_rec.activity_version_id
                          , p_rec.start_date
                          , p_rec.end_date );
    --
    check_multiple_con_version( p_rec.activity_id
                              , p_rec.activity_version_id
                              , p_rec.start_date
                              , p_rec.end_date);
    /* bug 3795299
      -- Added by dbatra for Training plan component

    check_dates_update_tpm
                          (p_rec.activity_version_id
                          ,p_rec.start_date
                          ,p_rec.end_date);
   */
    -- Added for Learning Paths
    check_course_lp_dates( p_rec.activity_version_id
                          ,p_rec.start_date
                          ,p_rec.end_date);
    --

   -- Added for certification
    check_course_crt_dates( p_rec.activity_version_id
                          ,p_rec.start_date
                          ,p_rec.end_date);
  End if;
  --
  ota_tav_api_business_rules.check_category_dates
  (
   p_activity_version_id    =>    p_rec.activity_version_id
  ,p_start_date             =>    p_rec.start_date
  ,p_end_date               =>    p_rec.end_date
  );
  --
  If l_duration_units_changed  Then
    --
    check_duration_units( p_rec.duration_units);
    --
  End if;
  --
  If l_duration_changed  Then
    --
    check_duration( p_rec.duration);
    --
  End if;

If l_duration_units_changed  or l_duration_changed Then
  check_dur_unit_comb( p_rec.duration,p_rec.duration_units);
  end if;
  --
  If l_language_id_changed  Then
    --
    check_language( p_rec.language_id);
    --
  End if;
  --
  If l_person_id_changed  Then
    --
    --
    -- **** Bug #2154926 changed call to check_controlling_person to use
    -- **** p_rec.end_date rather than p_rec.start_date
    --
    check_controlling_person( p_rec.controlling_person_id, p_rec.end_date);
    --
  End if;
  --
  if l_vendor_id_changed then
     ota_tav_api_business_rules.check_vendor (p_rec.vendor_id);
  end if;
  --
  if l_budget_currency_code_changed then
     ota_tav_api_business_rules.check_currency(p_rec.budget_currency_code);
  end if;
  --
  if l_budget_currency_code_changed or
     l_budget_cost_changed or
     l_actual_cost_changed then
        ota_tav_api_business_rules.check_cost_vals
              (p_rec.budget_currency_code
              ,p_rec.budget_cost
              ,p_rec.actual_cost);
  end if;
  --
  if l_professional_ctype_changed or
     l_professional_credits_changed then
        ota_tav_api_business_rules.check_professional_credit_vals
              (p_rec.professional_credit_type
              ,p_rec.professional_credits);
  end if;
  --
  if l_professional_ctype_changed then
     ota_tav_api_business_rules.check_professional_credit_type
              (p_rec.professional_credit_type);
  end if;
  --
  if l_inventory_item_id_changed then
      ota_tav_api_business_rules.check_Inventory_item_id(
				p_rec.activity_version_id ,
				p_rec.inventory_item_id  ,
				p_rec.organization_id);


     ota_tav_api_business_rules.check_oe_lines_exist(
				p_rec.activity_version_id ,
				p_rec.inventory_item_id  ,
				p_rec.organization_id);

  end if;
  /* For ILearning */
  if l_rco_id_changed then
     ota_tav_api_business_rules.check_unique_rco_id(
				p_rec.activity_version_id ,
				p_rec.rco_id );

  end if;

ota_tav_bus.chk_ddf(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  check_if_tpm_exists( p_rec.activity_version_id );
  --
  check_if_evt_exists( p_rec.activity_version_id );
  --
  check_if_tbd_exists( p_rec.activity_version_id );
  --
  check_if_ple_exists( p_rec.activity_version_id );
  --
  check_if_tav_exists( p_rec.activity_version_id );
  --
  check_if_off_exists( p_rec.activity_version_id );

  check_if_noth_exists( p_rec.activity_version_id );

  check_if_crt_exists(p_rec.activity_version_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
--
--   This function will be used by the user hooks. Currently this will be used
--   hr_competence_element_api business processes and in future will be made use
--   of by the user hooks of activity_versions business process.
--
Function return_legislation_code
         (  p_activity_version_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups      pbg,
                 ota_activity_versions    oav,
                 ota_activity_definitions oad
          where  pbg.business_group_id    = oad.business_group_id
            and  oad.activity_id          = oav.activity_id
            and  oav.activity_version_id  = p_activity_version_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'activity_version_id',
                              p_argument_value => p_activity_version_id );
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_noth_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_notrng_histories exists where this activity version.
--
Procedure check_if_noth_exists
  (
   p_activity_version_id  in  number
  )
 is
  --
  v_proc                  varchar2(72) := g_package||'check_if_noth_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_noth_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_if_noth_exists;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_crt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_certification_members exists where this activity version.
--
Procedure check_if_crt_exists
  (
   p_activity_version_id  in  number
  )
 is
  --
  v_proc                  varchar2(72) := g_package||'check_if_crt_exists';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_tav_api_business_rules.check_if_crt_exists( p_activity_version_id );
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_if_crt_exists;
--
end ota_tav_bus;

/
