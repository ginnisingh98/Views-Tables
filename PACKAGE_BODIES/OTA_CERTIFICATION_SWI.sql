--------------------------------------------------------
--  DDL for Package Body OTA_CERTIFICATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERTIFICATION_SWI" As
/* $Header: otcrtswi.pkb 120.1 2005/06/14 15:13 estreacy noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_certification_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_certification >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_certification
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_name                         in     varchar2
  ,p_business_group_id            in     number
  ,p_public_flag                  in     varchar2  default null
  ,p_initial_completion_date      in     date      default null
  ,p_initial_completion_duration  in     number    default null
  ,p_initial_compl_duration_units in     varchar2  default null
  ,p_renewal_duration             in     number    default null
  ,p_renewal_duration_units       in     varchar2  default null
  ,p_notify_days_before_expire    in     number    default null
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_description                  in     varchar2  default null
  ,p_objectives                   in     varchar2  default null
  ,p_purpose                      in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_end_date_comments            in     varchar2  default null
  ,p_initial_period_comments      in     varchar2  default null
  ,p_renewal_period_comments      in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_VALIDITY_DURATION            in     NUMBER   default null
  ,p_VALIDITY_DURATION_UNITS      in     VARCHAR2 default null
  ,p_RENEWABLE_FLAG               in     VARCHAR2 default null
  ,p_VALIDITY_START_TYPE          in     VARCHAR2 default null
  ,p_COMPETENCY_UPDATE_LEVEL      in     VARCHAR2 default null
  ,p_certification_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_certification_id             number;
  l_proc    varchar2(72) := g_package ||'create_certification';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_certification_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  ota_crt_ins.set_base_key_value
    (p_certification_id => p_certification_id
    );

  check_duplicate_name
    ( p_name             => p_name
     ,p_certification_id => p_certification_id
     ,p_business_group_id=>p_business_group_id
    );
  --
  -- Call API
  --
  ota_certification_api.create_certification
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_name                         => p_name
    ,p_business_group_id            => p_business_group_id
    ,p_public_flag                  => p_public_flag
    ,p_initial_completion_date      => p_initial_completion_date
    ,p_initial_completion_duration  => p_initial_completion_duration
    ,p_initial_compl_duration_units => p_initial_compl_duration_units
    ,p_renewal_duration             => p_renewal_duration
    ,p_renewal_duration_units       => p_renewal_duration_units
    ,p_notify_days_before_expire    => p_notify_days_before_expire
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_purpose                      => p_purpose
    ,p_keywords                     => p_keywords
    ,p_end_date_comments            => p_end_date_comments
    ,p_initial_period_comments      => p_initial_period_comments
    ,p_renewal_period_comments      => p_renewal_period_comments
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_VALIDITY_DURATION            => p_VALIDITY_DURATION
    ,p_VALIDITY_DURATION_UNITS      => p_VALIDITY_DURATION_UNITS
    ,p_RENEWABLE_FLAG               => p_RENEWABLE_FLAG
    ,p_VALIDITY_START_TYPE          => p_VALIDITY_START_TYPE
    ,p_COMPETENCY_UPDATE_LEVEL      => p_COMPETENCY_UPDATE_LEVEL
    ,p_certification_id             => l_certification_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_certification_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_certification_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_certification;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_certification >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_certification
  (p_effective_date               in     date
  ,p_certification_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_initial_completion_date      in     date      default hr_api.g_date
  ,p_initial_completion_duration  in     number    default hr_api.g_number
  ,p_initial_compl_duration_units in     varchar2  default hr_api.g_varchar2
  ,p_renewal_duration             in     number    default hr_api.g_number
  ,p_renewal_duration_units       in     varchar2  default hr_api.g_varchar2
  ,p_notify_days_before_expire    in     number    default hr_api.g_number
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_purpose                      in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date_comments            in     varchar2  default hr_api.g_varchar2
  ,p_initial_period_comments      in     varchar2  default hr_api.g_varchar2
  ,p_renewal_period_comments      in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_VALIDITY_DURATION            in     NUMBER    default hr_api.g_number
  ,p_VALIDITY_DURATION_UNITS      in     VARCHAR2  default hr_api.g_varchar2
  ,p_RENEWABLE_FLAG               in     VARCHAR2  default hr_api.g_varchar2
  ,p_VALIDITY_START_TYPE          in     VARCHAR2  default hr_api.g_varchar2
  ,p_COMPETENCY_UPDATE_LEVEL      in     VARCHAR2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_certification';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_certification_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --

  IF p_name <> hr_api.g_varchar2 THEN
      check_duplicate_name
        ( p_name             => p_name
         ,p_certification_id => p_certification_id
         ,p_business_group_id=> p_business_group_id
         );
  END IF;
  --
  -- Call API
  --
  ota_certification_api.update_certification
    (p_effective_date               => p_effective_date
    ,p_certification_id             => p_certification_id
    ,p_object_version_number        => p_object_version_number
    ,p_name                         => p_name
    ,p_public_flag                  => p_public_flag
    ,p_initial_completion_date      => p_initial_completion_date
    ,p_initial_completion_duration  => p_initial_completion_duration
    ,p_initial_compl_duration_units => p_initial_compl_duration_units
    ,p_renewal_duration             => p_renewal_duration
    ,p_renewal_duration_units       => p_renewal_duration_units
    ,p_notify_days_before_expire    => p_notify_days_before_expire
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_purpose                      => p_purpose
    ,p_keywords                     => p_keywords
    ,p_end_date_comments            => p_end_date_comments
    ,p_initial_period_comments      => p_initial_period_comments
    ,p_renewal_period_comments      => p_renewal_period_comments
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_business_group_id            => p_business_group_id
    ,p_VALIDITY_DURATION            => p_VALIDITY_DURATION
    ,p_VALIDITY_DURATION_UNITS      => p_VALIDITY_DURATION_UNITS
    ,p_RENEWABLE_FLAG               => p_RENEWABLE_FLAG
    ,p_VALIDITY_START_TYPE          => p_VALIDITY_START_TYPE
    ,p_COMPETENCY_UPDATE_LEVEL      => p_COMPETENCY_UPDATE_LEVEL
    ,p_validate                     => l_validate
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_certification_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_certification_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_certification;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_certification >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_certification
  (p_certification_id             in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_certification';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_certification_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ota_certification_api.delete_certification
    (p_certification_id             => p_certification_id
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_certification_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_certification_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_certification;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_crt_enrollments_exist >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This function checks whether enrollments exist for the given certification
--
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
FUNCTION check_crt_enrollments_exist
  (p_certification_id             in     number
  ) return varchar2 IS

  CURSOR csr_chk_ce_exist is
  SELECT 1
  FROM ota_cert_enrollments ce
  WHERE ce.certification_id = p_certification_id;

l_update_allowed   varchar2(1);
l_fetch    number;
BEGIN

  open csr_chk_ce_exist;
  fetch csr_chk_ce_exist into l_fetch;
  if csr_chk_ce_exist%FOUND then
     l_update_allowed := 'N';
  else
     l_update_allowed := 'Y';
  end if;
  close csr_chk_ce_exist;

  return l_update_allowed;
END check_crt_enrollments_exist;



PROCEDURE check_duplicate_name
   ( p_name              IN VARCHAR2
    ,p_certification_id  IN NUMBER
    ,p_business_group_id IN NUMBER)
IS


   l_business_group_id OTA_LEARNING_PATHS.business_group_id%TYPE;

   CURSOR csr_name is
   SELECT 1
   FROM   OTA_CERTIFICATIONS_VL cert
   WHERE  rtrim(p_name) = rtrim(cert.name)
      AND cert.business_group_id = l_business_group_id
      AND (p_certification_id IS NULL
            OR ( p_certification_id IS NOT NULL
                 AND p_certification_id <> cert.certification_id)) ;

  CURSOR csr_get_bg_id IS
  SELECT cert.business_group_id
  FROM OTA_CERTIFICATIONS_B cert
  WHERE cert.certification_id = p_certification_id;

  l_exists number;
  l_proc    varchar2(72) := g_package ||'check_duplicate_name';

BEGIN

  IF p_business_group_id IS NULL THEN
    OPEN csr_get_bg_id;
    FETCH csr_get_bg_id INTO l_business_group_id;
    CLOSE csr_get_bg_id;
  ELSE
    l_business_group_id := p_business_group_id;
  END IF;



         OPEN csr_name;
        FETCH csr_name INTO l_exists;
           IF csr_name%FOUND THEN
        CLOSE csr_name;
              hr_utility.set_location(' Step:'|| l_proc, 10);
              fnd_message.set_name('OTA', 'OTA_443810_CERT_UNIQUE_NAME');
              fnd_message.raise_error;
         ELSE
              CLOSE csr_name;
              hr_utility.set_location(' Step:'|| l_proc, 20);
          END IF;



EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_CERTIFICATIONS_TL.NAME') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END check_duplicate_name;



end ota_certification_swi;

/
