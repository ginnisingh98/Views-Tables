--------------------------------------------------------
--  DDL for Package Body OTA_LP_MEMBER_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_MEMBER_SWI" As
/* $Header: otlpmswi.pkb 120.0 2005/05/29 07:23 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_lp_member_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_learning_path_member >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_learning_path_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_learning_path_id             in     number
  ,p_activity_version_id          in     number
  ,p_course_sequence              in     number
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
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
  ,p_learning_path_section_id     in     number
  ,p_notify_days_before_target    in     number default null
  ,p_learning_path_member_id      in     number
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
  l_learning_path_member_id      number;
  l_proc    varchar2(72) := g_package ||'create_learning_path_member'; Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_lpm_swi;
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
  ota_lpm_ins.set_base_key_value
    (p_learning_path_member_id => p_learning_path_member_id
    );

  -- Call API
  --
  ota_lp_member_api.create_learning_path_member
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_learning_path_id             => p_learning_path_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_course_sequence              => p_course_sequence
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
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
    ,p_learning_path_section_id     => p_learning_path_section_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_learning_path_member_id      => l_learning_path_member_id
    ,p_object_version_number        => p_object_version_number
    );

 /* Commenting out the call since this feature is no longer desirable in LP
  * Enhancement
  * */
  /*
  --
  -- Check Duration is defined on Component
  --
  ota_lp_member_swi.check_lpm_duration(
           p_learning_path_member_id => p_learning_path_member_id
          ,p_duration                => p_duration
          ,p_learning_path_id        => p_learning_path_id);
  */
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
    rollback to create_lpm_swi;
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
    rollback to create_lpm_swi;
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
end create_learning_path_member;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_learning_path_member >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_learning_path_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_learning_path_member_id      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_learning_path_member';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_lpm_swi;
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
  ota_lp_member_api.delete_learning_path_member
    (p_validate                     => l_validate
    ,p_learning_path_member_id      => p_learning_path_member_id
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
    rollback to delete_lpm_swi;
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
    rollback to delete_lpm_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_learning_path_member;
-- ----------------------------------------------------------------------------
-- |----------------------< update_learning_path_member >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_learning_path_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_learning_path_member_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_course_sequence              in     number    default hr_api.g_number
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
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
  ,p_notify_days_before_target    in     number default hr_api.g_number
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
  l_proc    varchar2(72) := g_package ||'update_learning_path_member';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_lpm_swi;
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
  --
  -- Call API
  --
  ota_lp_member_api.update_learning_path_member
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_learning_path_member_id      => p_learning_path_member_id
    ,p_object_version_number        => p_object_version_number
    ,p_activity_version_id          => p_activity_version_id
    ,p_course_sequence              => p_course_sequence
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
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
    ,p_notify_days_before_target    => p_notify_days_before_target
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
    rollback to update_lpm_swi;
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
    rollback to update_lpm_swi;
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
end update_learning_path_member;


FUNCTION check_course_exists
  ( p_learning_path_id IN NUMBER
   ,p_activity_version_id IN NUMBER
  ) return VARCHAR2 IS

 cursor csr_course is
     select NULL
     from ota_learning_path_members lpm
     where lpm.learning_path_id = p_learning_path_id
        and lpm.activity_version_id = p_activity_version_id;

    l_exists varchar2(1) := 'N';
begin
   open csr_course;
   fetch csr_course  into l_exists;
   if csr_course%NOTFOUND then
      l_exists := 'N';
   else
      l_exists := 'Y';
   end if;
   close csr_course;

   return l_exists;
end check_course_exists;


PROCEDURE check_all_duration(
   p_learning_path_id IN NUMBER
  ,p_return_status OUT NOCOPY VARCHAR2
  ,p_max_duration OUT NOCOPY NUMBER)
IS
  CURSOR csr_chk_duration IS
    SELECT count(learning_path_member_id) lpm_num,
           count(duration) duration_num,
	   max(duration) max_duration
    FROM ota_learning_path_members
    WHERE learning_path_id = p_learning_path_id;

    no_of_lpms NUMBER;
    no_of_durations NUMBER;
    max_duration NUMBER;
BEGIN
   OPEN csr_chk_duration;
   FETCH csr_chk_duration INTO no_of_lpms, no_of_durations, max_duration;
   IF csr_chk_duration%NOTFOUND THEN
     p_return_status := 'S';
     p_max_duration := NULL;
   ELSIF no_of_durations = 0 THEN
     p_return_status := 'S';
     p_max_duration := NULL;
   ELSIF no_of_durations = no_of_lpms OR no_of_durations < no_of_lpms THEN
     p_return_status := 'S';
     p_max_duration := max_duration;
   ELSE
     p_return_status := 'E';
     p_max_duration := NULL;
   END IF;
   CLOSE csr_chk_duration;

END check_all_duration;
/* Commenting out procedure for Task#428905
PROCEDURE check_lpm_duration(
   p_learning_path_member_id IN NUMBER
  ,p_duration IN NUMBER
  ,p_learning_path_id IN NUMBER)
IS
 l_return_status VARCHAR2(30);
 l_max_duration NUMBER;
 l_proc               VARCHAR2(72) :=      g_package|| 'check_lpm_duration';
BEGIN
  hr_utility.set_location(' Step:'|| l_proc, 10);
  ota_lp_member_swi.check_all_duration(
         p_learning_path_id => p_learning_path_id
	,p_return_status    => l_return_status
	,p_max_duration     => l_max_duration
       );
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF l_return_status = 'E'  THEN
	hr_utility.set_location(' Step:'|| l_proc, 30);
	fnd_message.set_name('OTA', 'OTA_443100_LPM_DURATION_ERROR');
        fnd_message.raise_error;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION

        WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LEARNING_PATH_MEMBERS.DURATION') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 42);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 44);
END check_lpm_duration;
*/
end ota_lp_member_swi;

/
