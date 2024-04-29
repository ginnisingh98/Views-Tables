--------------------------------------------------------
--  DDL for Package Body OTA_LEARNING_PATH_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LEARNING_PATH_SWI" As
/* $Header: otlpsswi.pkb 120.0 2005/05/29 07:24:23 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_learning_path_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_learning_path
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_path_name                    in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_description                  in     varchar2  default null
  ,p_objectives                   in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_purpose                      in     varchar2  default null
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
  ,p_path_source_code             in     varchar2  default null
  ,p_source_function_code         in     varchar2  default null
  ,p_assignment_id                in     number    default null
  ,p_source_id                    in     number    default null
  ,p_notify_days_before_target    in     number    default null
  ,p_person_id                    in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_public_flag                  in     varchar2  default null
,p_competency_update_level        in     varchar2  default null
  ,p_learning_path_id             in     number
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
  l_learning_path_id             number;
  l_path_name                    ota_learning_paths_tl.name%TYPE := p_path_name;

  l_proc    varchar2(72) := g_package ||'create_learning_path';

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_learning_path_swi;
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
  ota_lps_ins.set_base_key_value
    (p_learning_path_id => p_learning_path_id
    );

  IF p_path_source_code = 'TALENT_MGMT' AND
     p_path_name IS NULL THEN
     l_path_name := ota_utility.Get_lookup_meaning
                               (p_lookup_type    => 'OTA_PLAN_COMPONENT_SOURCE',
                                p_lookup_code    => p_source_function_code,
                                p_application_id => 810);

       IF p_source_function_code = 'APPRAISAL' THEN
          -- Bug 4032657
          -- l_path_name := substr(p_learning_path_id||l_path_name, 1, 80);
          l_path_name := substr(l_path_name || p_learning_path_id, 1, 80);
      END IF;

 END IF;

  check_duplicate_name
    ( p_name             => l_path_name
     ,p_learning_path_id => p_learning_path_id
     ,p_business_group_id=>p_business_group_id
     ,p_person_id        => p_person_id
     ,p_contact_id       => p_contact_id
     ,p_path_source_code => p_path_source_code);

  --
  -- Call API
  --
  ota_learning_path_api.create_learning_path
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_path_name                    => l_path_name
    ,p_business_group_id            => p_business_group_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_keywords                     => p_keywords
    ,p_purpose                      => p_purpose
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
    ,p_path_source_code             => p_path_source_code
    ,p_source_function_code         => p_source_function_code
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_public_flag                  => p_public_flag
    ,p_competency_update_level      => p_competency_update_level
    ,p_learning_path_id             => l_learning_path_id
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
    rollback to create_learning_path_swi;
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
    rollback to create_learning_path_swi;
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
end create_learning_path;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_learning_path
  (p_learning_path_id             in     number
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
  l_proc    varchar2(72) := g_package ||'delete_learning_path';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_learning_path_swi;
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
  ota_learning_path_api.delete_learning_path
    (p_learning_path_id             => p_learning_path_id
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
    rollback to delete_learning_path_swi;
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
    rollback to delete_learning_path_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_learning_path;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_learning_path
  (p_effective_date               in     date
  ,p_learning_path_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_path_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_purpose                      in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
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
  ,p_path_source_code                  in     varchar2  default hr_api.g_varchar2
  ,p_source_function_code              in     varchar2  default hr_api.g_varchar2
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_source_id                    in     number    default hr_api.g_number
  ,p_notify_days_before_target    in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_learning_path';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_learning_path_swi;
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

  IF p_path_name <> hr_api.g_varchar2 THEN
      check_duplicate_name
        ( p_name             => p_path_name
         ,p_learning_path_id => p_learning_path_id
         ,p_business_group_id=> p_business_group_id
         ,p_person_id        => p_person_id
         ,p_contact_id       => p_contact_id
         ,p_path_source_code => p_path_source_code);
  END IF;

  --
  -- Call API
  --
  ota_learning_path_api.update_learning_path
    (p_effective_date               => p_effective_date
    ,p_learning_path_id             => p_learning_path_id
    ,p_object_version_number        => p_object_version_number
    ,p_path_name                    => p_path_name
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_keywords                     => p_keywords
    ,p_purpose                      => p_purpose
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
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
    ,p_validate                     => l_validate
    ,p_path_source_code             => p_path_source_code
    ,p_source_function_code         => p_source_function_code
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_public_flag                  => p_public_flag
    ,p_competency_update_level      => p_competency_update_level
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
    rollback to update_learning_path_swi;
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
    rollback to update_learning_path_swi;
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
end update_learning_path;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_lp_enrollments_exist >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This function checks whether enrollments exist for the given Learning Path
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
FUNCTION check_lp_enrollments_exist
  (p_learning_path_id             in     number
  ) return varchar2 IS

  CURSOR csr_chk_lpe_exist is
  SELECT 1
  FROM ota_lp_enrollments lpe
  WHERE lpe.learning_path_id = p_learning_path_id;

l_update_allowed   varchar2(1);
l_fetch    number;
BEGIN

  open csr_chk_lpe_exist;
  fetch csr_chk_lpe_exist into l_fetch;
  if csr_chk_lpe_exist%FOUND then
     l_update_allowed := 'N';
  else
     l_update_allowed := 'Y';
  end if;
  close csr_chk_lpe_exist;

  return l_update_allowed;
END check_lp_enrollments_exist;



PROCEDURE check_duplicate_name
   ( p_name              IN VARCHAR2
    ,p_learning_path_id  IN NUMBER
    ,p_business_group_id IN NUMBER
    ,p_person_id         IN NUMBER
    ,p_contact_id        IN NUMBER
    ,p_path_source_code  IN VARCHAR2)
IS


   l_business_group_id OTA_LEARNING_PATHS.business_group_id%TYPE;

   CURSOR csr_ctg_name is
   SELECT 1
   FROM   OTA_LEARNING_PATHS_VL LPS
   WHERE  rtrim(p_name) = rtrim(lps.name)
      AND lps.business_group_id = l_business_group_id
      AND path_source_code = 'CATALOG'
      AND (p_learning_path_id IS NULL
            OR ( p_learning_path_id IS NOT NULL
                 AND p_learning_path_id <> lps.learning_path_id)) ;

   CURSOR csr_emp_name is
   SELECT 1
   FROM   OTA_LEARNING_PATHS_VL LPS
   WHERE  rtrim(p_name) = rtrim(lps.name)
      AND lps.business_group_id = l_business_group_id
      AND person_id = p_person_id
      AND (p_learning_path_id IS NULL
            OR ( p_learning_path_id IS NOT NULL
                 AND p_learning_path_id <> lps.learning_path_id)) ;

   CURSOR csr_ct_name is
   SELECT 1
   FROM   OTA_LEARNING_PATHS_VL LPS
   WHERE  rtrim(p_name) = rtrim(lps.name)
      AND lps.business_group_id = l_business_group_id
      AND contact_id = p_contact_id
      AND (p_learning_path_id IS NULL
            OR ( p_learning_path_id IS NOT NULL
                 AND p_learning_path_id <> lps.learning_path_id)) ;

  CURSOR csr_get_bg_id IS
  SELECT lps.business_group_id
  FROM OTA_LEARNING_PATHS lps
  WHERE lps.learning_path_id = p_learning_path_id;

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

  IF p_path_source_code = 'CATALOG' THEN

         OPEN csr_ctg_name;
        FETCH csr_ctg_name INTO l_exists;
           IF csr_ctg_name%FOUND THEN
        CLOSE csr_ctg_name;
              hr_utility.set_location(' Step:'|| l_proc, 10);
              fnd_message.set_name('OTA', 'OTA_13100_LPS_CTG_UNIQUE_NAME');
              fnd_message.raise_error;
         ELSE
              CLOSE csr_ctg_name;
              hr_utility.set_location(' Step:'|| l_proc, 20);
          END IF;
  ELSE
       IF p_person_id IS NOT NULL THEN

          OPEN csr_emp_name;
         FETCH csr_emp_name INTO l_exists;
            IF csr_emp_name%FOUND THEN
         CLOSE csr_emp_name;
               hr_utility.set_location(' Step:'|| l_proc, 30);
               fnd_message.set_name('OTA', 'OTA_443386_LPS_UNIQUE_NAME');
               fnd_message.raise_error;
          ELSE
         CLOSE csr_emp_name;
               hr_utility.set_location(' Step:'|| l_proc, 40);
           END IF;

       ELSIF p_contact_id IS NOT NULL THEN

         OPEN csr_ct_name;
        FETCH csr_ct_name INTO l_exists;
           IF csr_ct_name%FOUND THEN
        CLOSE csr_ct_name;
              hr_utility.set_location(' Step:'|| l_proc, 50);
              fnd_message.set_name('OTA', 'OTA_443386_LPS_UNIQUE_NAME');
              fnd_message.raise_error;
        ELSE
        CLOSE csr_ct_name;
              hr_utility.set_location(' Step:'|| l_proc, 60);
          END IF;

       END IF;
  END IF;


EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATHS.NAME') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END check_duplicate_name;


FUNCTION is_Duration_Updateable
  ( p_learning_path_id IN NUMBER
  ) return VARCHAR2 IS

l_updateable VARCHAR2(30);
l_duration NUMBER;
BEGIN

  l_updateable := ota_learning_path_swi.check_lp_enrollments_exist(p_learning_path_id);
  return l_updateable;

END is_Duration_Updateable;

end ota_learning_path_swi;


/
