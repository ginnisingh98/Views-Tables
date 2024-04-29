--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ABSENCE_CASE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ABSENCE_CASE_SWI" As
/* $Header: hrabcswi.pkb 120.1 2006/03/17 02:54 snukala noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_person_absence_case_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_person_absence_case >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_person_absence_case
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_name                         in     varchar2
  ,p_business_group_id            in     number
  ,p_incident_id                  in     number    default null
  ,p_absence_category             in     varchar2  default null
  ,p_ac_attribute_category        in     varchar2  default null
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
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_ac_information_category      in     varchar2  default null
  ,p_ac_information1              in     varchar2  default null
  ,p_ac_information2              in     varchar2  default null
  ,p_ac_information3              in     varchar2  default null
  ,p_ac_information4              in     varchar2  default null
  ,p_ac_information5              in     varchar2  default null
  ,p_ac_information6              in     varchar2  default null
  ,p_ac_information7              in     varchar2  default null
  ,p_ac_information8              in     varchar2  default null
  ,p_ac_information9              in     varchar2  default null
  ,p_ac_information10             in     varchar2  default null
  ,p_ac_information11             in     varchar2  default null
  ,p_ac_information12             in     varchar2  default null
  ,p_ac_information13             in     varchar2  default null
  ,p_ac_information14             in     varchar2  default null
  ,p_ac_information15             in     varchar2  default null
  ,p_ac_information16             in     varchar2  default null
  ,p_ac_information17             in     varchar2  default null
  ,p_ac_information18             in     varchar2  default null
  ,p_ac_information19             in     varchar2  default null
  ,p_ac_information20             in     varchar2  default null
  ,p_ac_information21             in     varchar2  default null
  ,p_ac_information22             in     varchar2  default null
  ,p_ac_information23             in     varchar2  default null
  ,p_ac_information24             in     varchar2  default null
  ,p_ac_information25             in     varchar2  default null
  ,p_ac_information26             in     varchar2  default null
  ,p_ac_information27             in     varchar2  default null
  ,p_ac_information28             in     varchar2  default null
  ,p_ac_information29             in     varchar2  default null
  ,p_ac_information30             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_absence_case_id               in  out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_person_absence_case';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_absence_case_swi;
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
  per_abc_ins.set_base_key_value
    (p_absence_case_id => p_absence_case_id
    );
  -- Call API
  --
  hr_person_absence_case_api.create_person_absence_case
    (p_validate                     => l_validate
    ,p_person_id                    => p_person_id
    ,p_name                         => p_name
    ,p_business_group_id            => p_business_group_id
    ,p_incident_id                  => p_incident_id
    ,p_absence_category             => p_absence_category
    ,p_ac_attribute_category        => p_ac_attribute_category
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_ac_information_category      => p_ac_information_category
    ,p_ac_information1              => p_ac_information1
    ,p_ac_information2              => p_ac_information2
    ,p_ac_information3              => p_ac_information3
    ,p_ac_information4              => p_ac_information4
    ,p_ac_information5              => p_ac_information5
    ,p_ac_information6              => p_ac_information6
    ,p_ac_information7              => p_ac_information7
    ,p_ac_information8              => p_ac_information8
    ,p_ac_information9              => p_ac_information9
    ,p_ac_information10             => p_ac_information10
    ,p_ac_information11             => p_ac_information11
    ,p_ac_information12             => p_ac_information12
    ,p_ac_information13             => p_ac_information13
    ,p_ac_information14             => p_ac_information14
    ,p_ac_information15             => p_ac_information15
    ,p_ac_information16             => p_ac_information16
    ,p_ac_information17             => p_ac_information17
    ,p_ac_information18             => p_ac_information18
    ,p_ac_information19             => p_ac_information19
    ,p_ac_information20             => p_ac_information20
    ,p_ac_information21             => p_ac_information21
    ,p_ac_information22             => p_ac_information22
    ,p_ac_information23             => p_ac_information23
    ,p_ac_information24             => p_ac_information24
    ,p_ac_information25             => p_ac_information25
    ,p_ac_information26             => p_ac_information26
    ,p_ac_information27             => p_ac_information27
    ,p_ac_information28             => p_ac_information28
    ,p_ac_information29             => p_ac_information29
    ,p_ac_information30             => p_ac_information30
    ,p_comments                     => p_comments
    ,p_absence_case_id              => p_absence_case_id
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
    rollback to create_person_absence_case_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_absence_case_id              := null;
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
    rollback to create_person_absence_case_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_absence_case_id              := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_person_absence_case;
-- ----------------------------------------------------------------------------
-- |----------------------< update_person_absence_case >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_person_absence_case
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_case_id              in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_incident_id                  in     number    default hr_api.g_number
  ,p_absence_category             in     varchar2  default hr_api.g_varchar2
  ,p_ac_attribute_category        in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_ac_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_ac_information1              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information2              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information3              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information4              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information5              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information6              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information7              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information8              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information9              in     varchar2  default hr_api.g_varchar2
  ,p_ac_information10             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information11             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information12             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information13             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information14             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information15             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information16             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information17             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information18             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information19             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information20             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information21             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information22             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information23             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information24             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information25             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information26             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information27             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information28             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information29             in     varchar2  default hr_api.g_varchar2
  ,p_ac_information30             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_person_absence_case';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_absence_case_swi;
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
  hr_person_absence_case_api.update_person_absence_case
    (p_validate                     => l_validate
    ,p_absence_case_id              => p_absence_case_id
    ,p_name                         => p_name
    ,p_incident_id                  => p_incident_id
    ,p_absence_category             => p_absence_category
    ,p_ac_attribute_category        => p_ac_attribute_category
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_ac_information_category      => p_ac_information_category
    ,p_ac_information1              => p_ac_information1
    ,p_ac_information2              => p_ac_information2
    ,p_ac_information3              => p_ac_information3
    ,p_ac_information4              => p_ac_information4
    ,p_ac_information5              => p_ac_information5
    ,p_ac_information6              => p_ac_information6
    ,p_ac_information7              => p_ac_information7
    ,p_ac_information8              => p_ac_information8
    ,p_ac_information9              => p_ac_information9
    ,p_ac_information10             => p_ac_information10
    ,p_ac_information11             => p_ac_information11
    ,p_ac_information12             => p_ac_information12
    ,p_ac_information13             => p_ac_information13
    ,p_ac_information14             => p_ac_information14
    ,p_ac_information15             => p_ac_information15
    ,p_ac_information16             => p_ac_information16
    ,p_ac_information17             => p_ac_information17
    ,p_ac_information18             => p_ac_information18
    ,p_ac_information19             => p_ac_information19
    ,p_ac_information20             => p_ac_information20
    ,p_ac_information21             => p_ac_information21
    ,p_ac_information22             => p_ac_information22
    ,p_ac_information23             => p_ac_information23
    ,p_ac_information24             => p_ac_information24
    ,p_ac_information25             => p_ac_information25
    ,p_ac_information26             => p_ac_information26
    ,p_ac_information27             => p_ac_information27
    ,p_ac_information28             => p_ac_information28
    ,p_ac_information29             => p_ac_information29
    ,p_ac_information30             => p_ac_information30
    ,p_comments                     => p_comments
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
    rollback to update_person_absence_case_swi;
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
    rollback to update_person_absence_case_swi;
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
end update_person_absence_case;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_case >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_person_absence_case
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_case_id              in     number
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
  l_proc    varchar2(72) := g_package ||'delete_person_absence_case';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_person_absence_case_swi;
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
  hr_person_absence_case_api.delete_person_absence_case
    (p_validate                     => l_validate
    ,p_absence_case_id              => p_absence_case_id
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
    rollback to delete_person_absence_case_swi;
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
    rollback to delete_person_absence_case_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_person_absence_case;
end hr_person_absence_case_swi;

/
