--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_EIT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_EIT_SWI" As
/* $Header: pyeeimwi.pkb 120.0 2005/12/16 15:01 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_element_extra_info_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_element_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_element_type_id              in     number
  ,p_information_type             in     varchar2
  ,p_eei_attribute_category       in     varchar2  default null
  ,p_eei_attribute1               in     varchar2  default null
  ,p_eei_attribute2               in     varchar2  default null
  ,p_eei_attribute3               in     varchar2  default null
  ,p_eei_attribute4               in     varchar2  default null
  ,p_eei_attribute5               in     varchar2  default null
  ,p_eei_attribute6               in     varchar2  default null
  ,p_eei_attribute7               in     varchar2  default null
  ,p_eei_attribute8               in     varchar2  default null
  ,p_eei_attribute9               in     varchar2  default null
  ,p_eei_attribute10              in     varchar2  default null
  ,p_eei_attribute11              in     varchar2  default null
  ,p_eei_attribute12              in     varchar2  default null
  ,p_eei_attribute13              in     varchar2  default null
  ,p_eei_attribute14              in     varchar2  default null
  ,p_eei_attribute15              in     varchar2  default null
  ,p_eei_attribute16              in     varchar2  default null
  ,p_eei_attribute17              in     varchar2  default null
  ,p_eei_attribute18              in     varchar2  default null
  ,p_eei_attribute19              in     varchar2  default null
  ,p_eei_attribute20              in     varchar2  default null
  ,p_eei_information_category     in     varchar2  default null
  ,p_eei_information1             in     varchar2  default null
  ,p_eei_information2             in     varchar2  default null
  ,p_eei_information3             in     varchar2  default null
  ,p_eei_information4             in     varchar2  default null
  ,p_eei_information5             in     varchar2  default null
  ,p_eei_information6             in     varchar2  default null
  ,p_eei_information7             in     varchar2  default null
  ,p_eei_information8             in     varchar2  default null
  ,p_eei_information9             in     varchar2  default null
  ,p_eei_information10            in     varchar2  default null
  ,p_eei_information11            in     varchar2  default null
  ,p_eei_information12            in     varchar2  default null
  ,p_eei_information13            in     varchar2  default null
  ,p_eei_information14            in     varchar2  default null
  ,p_eei_information15            in     varchar2  default null
  ,p_eei_information16            in     varchar2  default null
  ,p_eei_information17            in     varchar2  default null
  ,p_eei_information18            in     varchar2  default null
  ,p_eei_information19            in     varchar2  default null
  ,p_eei_information20            in     varchar2  default null
  ,p_eei_information21            in     varchar2  default null
  ,p_eei_information22            in     varchar2  default null
  ,p_eei_information23            in     varchar2  default null
  ,p_eei_information24            in     varchar2  default null
  ,p_eei_information25            in     varchar2  default null
  ,p_eei_information26            in     varchar2  default null
  ,p_eei_information27            in     varchar2  default null
  ,p_eei_information28            in     varchar2  default null
  ,p_eei_information29            in     varchar2  default null
  ,p_eei_information30            in     varchar2  default null
  ,p_element_type_extra_info_id      out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_element_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_element_extra_info_swi;
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
  pay_element_eit_mig.create_element_extra_info
    (p_validate                     => l_validate
    ,p_element_type_id              => p_element_type_id
    ,p_information_type             => p_information_type
    ,p_eei_attribute_category       => p_eei_attribute_category
    ,p_eei_attribute1               => p_eei_attribute1
    ,p_eei_attribute2               => p_eei_attribute2
    ,p_eei_attribute3               => p_eei_attribute3
    ,p_eei_attribute4               => p_eei_attribute4
    ,p_eei_attribute5               => p_eei_attribute5
    ,p_eei_attribute6               => p_eei_attribute6
    ,p_eei_attribute7               => p_eei_attribute7
    ,p_eei_attribute8               => p_eei_attribute8
    ,p_eei_attribute9               => p_eei_attribute9
    ,p_eei_attribute10              => p_eei_attribute10
    ,p_eei_attribute11              => p_eei_attribute11
    ,p_eei_attribute12              => p_eei_attribute12
    ,p_eei_attribute13              => p_eei_attribute13
    ,p_eei_attribute14              => p_eei_attribute14
    ,p_eei_attribute15              => p_eei_attribute15
    ,p_eei_attribute16              => p_eei_attribute16
    ,p_eei_attribute17              => p_eei_attribute17
    ,p_eei_attribute18              => p_eei_attribute18
    ,p_eei_attribute19              => p_eei_attribute19
    ,p_eei_attribute20              => p_eei_attribute20
    ,p_eei_information_category     => p_eei_information_category
    ,p_eei_information1             => p_eei_information1
    ,p_eei_information2             => p_eei_information2
    ,p_eei_information3             => p_eei_information3
    ,p_eei_information4             => p_eei_information4
    ,p_eei_information5             => p_eei_information5
    ,p_eei_information6             => p_eei_information6
    ,p_eei_information7             => p_eei_information7
    ,p_eei_information8             => p_eei_information8
    ,p_eei_information9             => p_eei_information9
    ,p_eei_information10            => p_eei_information10
    ,p_eei_information11            => p_eei_information11
    ,p_eei_information12            => p_eei_information12
    ,p_eei_information13            => p_eei_information13
    ,p_eei_information14            => p_eei_information14
    ,p_eei_information15            => p_eei_information15
    ,p_eei_information16            => p_eei_information16
    ,p_eei_information17            => p_eei_information17
    ,p_eei_information18            => p_eei_information18
    ,p_eei_information19            => p_eei_information19
    ,p_eei_information20            => p_eei_information20
    ,p_eei_information21            => p_eei_information21
    ,p_eei_information22            => p_eei_information22
    ,p_eei_information23            => p_eei_information23
    ,p_eei_information24            => p_eei_information24
    ,p_eei_information25            => p_eei_information25
    ,p_eei_information26            => p_eei_information26
    ,p_eei_information27            => p_eei_information27
    ,p_eei_information28            => p_eei_information28
    ,p_eei_information29            => p_eei_information29
    ,p_eei_information30            => p_eei_information30
    ,p_element_type_extra_info_id   => p_element_type_extra_info_id
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
    rollback to create_element_extra_info_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_element_type_extra_info_id   := null;
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
    rollback to create_element_extra_info_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_element_type_extra_info_id   := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_element_extra_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_element_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_element_type_extra_info_id   in     number
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
  l_proc    varchar2(72) := g_package ||'delete_element_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_element_extra_info_swi;
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
  pay_element_eit_mig.delete_element_extra_info
    (p_validate                     => l_validate
    ,p_element_type_extra_info_id   => p_element_type_extra_info_id
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
    rollback to delete_element_extra_info_swi;
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
    rollback to delete_element_extra_info_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_element_extra_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_element_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_element_type_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_eei_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_eei_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eei_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information15            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information16            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information17            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information18            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information19            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information20            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information21            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information22            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information23            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information24            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information25            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information26            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information27            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information28            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information29            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information30            in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_element_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_element_extra_info_swi;
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
  pay_element_eit_mig.update_element_extra_info
    (p_validate                     => l_validate
    ,p_element_type_extra_info_id   => p_element_type_extra_info_id
    ,p_object_version_number        => p_object_version_number
    ,p_eei_attribute_category       => p_eei_attribute_category
    ,p_eei_attribute1               => p_eei_attribute1
    ,p_eei_attribute2               => p_eei_attribute2
    ,p_eei_attribute3               => p_eei_attribute3
    ,p_eei_attribute4               => p_eei_attribute4
    ,p_eei_attribute5               => p_eei_attribute5
    ,p_eei_attribute6               => p_eei_attribute6
    ,p_eei_attribute7               => p_eei_attribute7
    ,p_eei_attribute8               => p_eei_attribute8
    ,p_eei_attribute9               => p_eei_attribute9
    ,p_eei_attribute10              => p_eei_attribute10
    ,p_eei_attribute11              => p_eei_attribute11
    ,p_eei_attribute12              => p_eei_attribute12
    ,p_eei_attribute13              => p_eei_attribute13
    ,p_eei_attribute14              => p_eei_attribute14
    ,p_eei_attribute15              => p_eei_attribute15
    ,p_eei_attribute16              => p_eei_attribute16
    ,p_eei_attribute17              => p_eei_attribute17
    ,p_eei_attribute18              => p_eei_attribute18
    ,p_eei_attribute19              => p_eei_attribute19
    ,p_eei_attribute20              => p_eei_attribute20
    ,p_eei_information_category     => p_eei_information_category
    ,p_eei_information1             => p_eei_information1
    ,p_eei_information2             => p_eei_information2
    ,p_eei_information3             => p_eei_information3
    ,p_eei_information4             => p_eei_information4
    ,p_eei_information5             => p_eei_information5
    ,p_eei_information6             => p_eei_information6
    ,p_eei_information7             => p_eei_information7
    ,p_eei_information8             => p_eei_information8
    ,p_eei_information9             => p_eei_information9
    ,p_eei_information10            => p_eei_information10
    ,p_eei_information11            => p_eei_information11
    ,p_eei_information12            => p_eei_information12
    ,p_eei_information13            => p_eei_information13
    ,p_eei_information14            => p_eei_information14
    ,p_eei_information15            => p_eei_information15
    ,p_eei_information16            => p_eei_information16
    ,p_eei_information17            => p_eei_information17
    ,p_eei_information18            => p_eei_information18
    ,p_eei_information19            => p_eei_information19
    ,p_eei_information20            => p_eei_information20
    ,p_eei_information21            => p_eei_information21
    ,p_eei_information22            => p_eei_information22
    ,p_eei_information23            => p_eei_information23
    ,p_eei_information24            => p_eei_information24
    ,p_eei_information25            => p_eei_information25
    ,p_eei_information26            => p_eei_information26
    ,p_eei_information27            => p_eei_information27
    ,p_eei_information28            => p_eei_information28
    ,p_eei_information29            => p_eei_information29
    ,p_eei_information30            => p_eei_information30
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
    rollback to update_element_extra_info_swi;
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
    rollback to update_element_extra_info_swi;
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
end update_element_extra_info;
end pay_element_eit_swi;

/
