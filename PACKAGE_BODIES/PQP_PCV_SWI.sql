--------------------------------------------------------
--  DDL for Package Body PQP_PCV_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_SWI" As
/* $Header: pqpcvswi.pkb 120.0 2005/05/29 01:55 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_pcv_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_configuration_value >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_configuration_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_pcv_attribute_category       in     varchar2  default null
  ,p_pcv_attribute1               in     varchar2  default null
  ,p_pcv_attribute2               in     varchar2  default null
  ,p_pcv_attribute3               in     varchar2  default null
  ,p_pcv_attribute4               in     varchar2  default null
  ,p_pcv_attribute5               in     varchar2  default null
  ,p_pcv_attribute6               in     varchar2  default null
  ,p_pcv_attribute7               in     varchar2  default null
  ,p_pcv_attribute8               in     varchar2  default null
  ,p_pcv_attribute9               in     varchar2  default null
  ,p_pcv_attribute10              in     varchar2  default null
  ,p_pcv_attribute11              in     varchar2  default null
  ,p_pcv_attribute12              in     varchar2  default null
  ,p_pcv_attribute13              in     varchar2  default null
  ,p_pcv_attribute14              in     varchar2  default null
  ,p_pcv_attribute15              in     varchar2  default null
  ,p_pcv_attribute16              in     varchar2  default null
  ,p_pcv_attribute17              in     varchar2  default null
  ,p_pcv_attribute18              in     varchar2  default null
  ,p_pcv_attribute19              in     varchar2  default null
  ,p_pcv_attribute20              in     varchar2  default null
  ,p_pcv_information_category     in     varchar2  default null
  ,p_pcv_information1             in     varchar2  default null
  ,p_pcv_information2             in     varchar2  default null
  ,p_pcv_information3             in     varchar2  default null
  ,p_pcv_information4             in     varchar2  default null
  ,p_pcv_information5             in     varchar2  default null
  ,p_pcv_information6             in     varchar2  default null
  ,p_pcv_information7             in     varchar2  default null
  ,p_pcv_information8             in     varchar2  default null
  ,p_pcv_information9             in     varchar2  default null
  ,p_pcv_information10            in     varchar2  default null
  ,p_pcv_information11            in     varchar2  default null
  ,p_pcv_information12            in     varchar2  default null
  ,p_pcv_information13            in     varchar2  default null
  ,p_pcv_information14            in     varchar2  default null
  ,p_pcv_information15            in     varchar2  default null
  ,p_pcv_information16            in     varchar2  default null
  ,p_pcv_information17            in     varchar2  default null
  ,p_pcv_information18            in     varchar2  default null
  ,p_pcv_information19            in     varchar2  default null
  ,p_pcv_information20            in     varchar2  default null
  ,p_configuration_name           in     varchar2  default null
  ,p_configuration_value_id          out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_configuration_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_configuration_value_swi;
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
  pqp_pcv_api.create_configuration_value
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_pcv_attribute_category       => p_pcv_attribute_category
    ,p_pcv_attribute1               => p_pcv_attribute1
    ,p_pcv_attribute2               => p_pcv_attribute2
    ,p_pcv_attribute3               => p_pcv_attribute3
    ,p_pcv_attribute4               => p_pcv_attribute4
    ,p_pcv_attribute5               => p_pcv_attribute5
    ,p_pcv_attribute6               => p_pcv_attribute6
    ,p_pcv_attribute7               => p_pcv_attribute7
    ,p_pcv_attribute8               => p_pcv_attribute8
    ,p_pcv_attribute9               => p_pcv_attribute9
    ,p_pcv_attribute10              => p_pcv_attribute10
    ,p_pcv_attribute11              => p_pcv_attribute11
    ,p_pcv_attribute12              => p_pcv_attribute12
    ,p_pcv_attribute13              => p_pcv_attribute13
    ,p_pcv_attribute14              => p_pcv_attribute14
    ,p_pcv_attribute15              => p_pcv_attribute15
    ,p_pcv_attribute16              => p_pcv_attribute16
    ,p_pcv_attribute17              => p_pcv_attribute17
    ,p_pcv_attribute18              => p_pcv_attribute18
    ,p_pcv_attribute19              => p_pcv_attribute19
    ,p_pcv_attribute20              => p_pcv_attribute20
    ,p_pcv_information_category     => p_pcv_information_category
    ,p_pcv_information1             => p_pcv_information1
    ,p_pcv_information2             => p_pcv_information2
    ,p_pcv_information3             => p_pcv_information3
    ,p_pcv_information4             => p_pcv_information4
    ,p_pcv_information5             => p_pcv_information5
    ,p_pcv_information6             => p_pcv_information6
    ,p_pcv_information7             => p_pcv_information7
    ,p_pcv_information8             => p_pcv_information8
    ,p_pcv_information9             => p_pcv_information9
    ,p_pcv_information10            => p_pcv_information10
    ,p_pcv_information11            => p_pcv_information11
    ,p_pcv_information12            => p_pcv_information12
    ,p_pcv_information13            => p_pcv_information13
    ,p_pcv_information14            => p_pcv_information14
    ,p_pcv_information15            => p_pcv_information15
    ,p_pcv_information16            => p_pcv_information16
    ,p_pcv_information17            => p_pcv_information17
    ,p_pcv_information18            => p_pcv_information18
    ,p_pcv_information19            => p_pcv_information19
    ,p_pcv_information20            => p_pcv_information20
    ,p_configuration_value_id       => p_configuration_value_id
    ,p_object_version_number        => p_object_version_number
    ,p_configuration_name           => p_configuration_name

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
    rollback to create_configuration_value_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_configuration_value_id       := null;
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
    rollback to create_configuration_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_configuration_value_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_configuration_value;
-- ----------------------------------------------------------------------------
-- |----------------------< update_configuration_value >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_configuration_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_configuration_value_id       in     number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information20            in     varchar2  default hr_api.g_varchar2
  ,p_configuration_name           in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_configuration_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_configuration_value_swi;
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
  pqp_pcv_api.update_configuration_value
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_configuration_value_id       => p_configuration_value_id
    ,p_legislation_code             => p_legislation_code
    ,p_pcv_attribute_category       => p_pcv_attribute_category
    ,p_pcv_attribute1               => p_pcv_attribute1
    ,p_pcv_attribute2               => p_pcv_attribute2
    ,p_pcv_attribute3               => p_pcv_attribute3
    ,p_pcv_attribute4               => p_pcv_attribute4
    ,p_pcv_attribute5               => p_pcv_attribute5
    ,p_pcv_attribute6               => p_pcv_attribute6
    ,p_pcv_attribute7               => p_pcv_attribute7
    ,p_pcv_attribute8               => p_pcv_attribute8
    ,p_pcv_attribute9               => p_pcv_attribute9
    ,p_pcv_attribute10              => p_pcv_attribute10
    ,p_pcv_attribute11              => p_pcv_attribute11
    ,p_pcv_attribute12              => p_pcv_attribute12
    ,p_pcv_attribute13              => p_pcv_attribute13
    ,p_pcv_attribute14              => p_pcv_attribute14
    ,p_pcv_attribute15              => p_pcv_attribute15
    ,p_pcv_attribute16              => p_pcv_attribute16
    ,p_pcv_attribute17              => p_pcv_attribute17
    ,p_pcv_attribute18              => p_pcv_attribute18
    ,p_pcv_attribute19              => p_pcv_attribute19
    ,p_pcv_attribute20              => p_pcv_attribute20
    ,p_pcv_information_category     => p_pcv_information_category
    ,p_pcv_information1             => p_pcv_information1
    ,p_pcv_information2             => p_pcv_information2
    ,p_pcv_information3             => p_pcv_information3
    ,p_pcv_information4             => p_pcv_information4
    ,p_pcv_information5             => p_pcv_information5
    ,p_pcv_information6             => p_pcv_information6
    ,p_pcv_information7             => p_pcv_information7
    ,p_pcv_information8             => p_pcv_information8
    ,p_pcv_information9             => p_pcv_information9
    ,p_pcv_information10            => p_pcv_information10
    ,p_pcv_information11            => p_pcv_information11
    ,p_pcv_information12            => p_pcv_information12
    ,p_pcv_information13            => p_pcv_information13
    ,p_pcv_information14            => p_pcv_information14
    ,p_pcv_information15            => p_pcv_information15
    ,p_pcv_information16            => p_pcv_information16
    ,p_pcv_information17            => p_pcv_information17
    ,p_pcv_information18            => p_pcv_information18
    ,p_pcv_information19            => p_pcv_information19
    ,p_pcv_information20            => p_pcv_information20
    ,p_object_version_number        => p_object_version_number
    ,p_configuration_name           => p_configuration_name

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
    rollback to update_configuration_value_swi;
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
    rollback to update_configuration_value_swi;
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
end update_configuration_value;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_configuration_value >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_configuration_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_configuration_value_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_configuration_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_configuration_value_swi;
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
  pqp_pcv_api.delete_configuration_value
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_configuration_value_id       => p_configuration_value_id
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
    rollback to delete_configuration_value_swi;
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
    rollback to delete_configuration_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_configuration_value;
end pqp_pcv_swi;

/
