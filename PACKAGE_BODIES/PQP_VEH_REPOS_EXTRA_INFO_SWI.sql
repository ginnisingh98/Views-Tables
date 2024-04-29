--------------------------------------------------------
--  DDL for Package Body PQP_VEH_REPOS_EXTRA_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEH_REPOS_EXTRA_INFO_SWI" As
/* $Header: pqvriswi.pkb 120.0 2005/05/29 02:19 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_veh_repos_extra_info_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_veh_repos_extra_info >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_veh_repos_extra_info
  (p_validate                     in     number
  ,p_vehicle_repository_id        in     number
  ,p_information_type             in     varchar2
  ,p_vrei_attribute_category      in     varchar2
  ,p_vrei_attribute1              in     varchar2
  ,p_vrei_attribute2              in     varchar2
  ,p_vrei_attribute3              in     varchar2
  ,p_vrei_attribute4              in     varchar2
  ,p_vrei_attribute5              in     varchar2
  ,p_vrei_attribute6              in     varchar2
  ,p_vrei_attribute7              in     varchar2
  ,p_vrei_attribute8              in     varchar2
  ,p_vrei_attribute9              in     varchar2
  ,p_vrei_attribute10             in     varchar2
  ,p_vrei_attribute11             in     varchar2
  ,p_vrei_attribute12             in     varchar2
  ,p_vrei_attribute13             in     varchar2
  ,p_vrei_attribute14             in     varchar2
  ,p_vrei_attribute15             in     varchar2
  ,p_vrei_attribute16             in     varchar2
  ,p_vrei_attribute17             in     varchar2
  ,p_vrei_attribute18             in     varchar2
  ,p_vrei_attribute19             in     varchar2
  ,p_vrei_attribute20             in     varchar2
  ,p_vrei_information_category    in     varchar2
  ,p_vrei_information1            in     varchar2
  ,p_vrei_information2            in     varchar2
  ,p_vrei_information3            in     varchar2
  ,p_vrei_information4            in     varchar2
  ,p_vrei_information5            in     varchar2
  ,p_vrei_information6            in     varchar2
  ,p_vrei_information7            in     varchar2
  ,p_vrei_information8            in     varchar2
  ,p_vrei_information9            in     varchar2
  ,p_vrei_information10           in     varchar2
  ,p_vrei_information11           in     varchar2
  ,p_vrei_information12           in     varchar2
  ,p_vrei_information13           in     varchar2
  ,p_vrei_information14           in     varchar2
  ,p_vrei_information15           in     varchar2
  ,p_vrei_information16           in     varchar2
  ,p_vrei_information17           in     varchar2
  ,p_vrei_information18           in     varchar2
  ,p_vrei_information19           in     varchar2
  ,p_vrei_information20           in     varchar2
  ,p_vrei_information21           in     varchar2
  ,p_vrei_information22           in     varchar2
  ,p_vrei_information23           in     varchar2
  ,p_vrei_information24           in     varchar2
  ,p_vrei_information25           in     varchar2
  ,p_vrei_information26           in     varchar2
  ,p_vrei_information27           in     varchar2
  ,p_vrei_information28           in     varchar2
  ,p_vrei_information29           in     varchar2
  ,p_vrei_information30           in     varchar2
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
  ,p_veh_repos_extra_info_id         out nocopy   number
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
  l_veh_repos_extra_info_id      number;
  l_proc    varchar2(72) := g_package ||'create_veh_repos_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_veh_repos_xtra_info_swi;
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
  pqp_vri_ins.set_base_key_value
    (p_veh_repos_extra_info_id => p_veh_repos_extra_info_id
    );
  --
  -- Call API
  --
  pqp_veh_repos_extra_info_api.create_veh_repos_extra_info
    (p_validate                     => l_validate
    ,p_vehicle_repository_id        => p_vehicle_repository_id
    ,p_information_type             => p_information_type
    ,p_vrei_attribute_category      => p_vrei_attribute_category
    ,p_vrei_attribute1              => p_vrei_attribute1
    ,p_vrei_attribute2              => p_vrei_attribute2
    ,p_vrei_attribute3              => p_vrei_attribute3
    ,p_vrei_attribute4              => p_vrei_attribute4
    ,p_vrei_attribute5              => p_vrei_attribute5
    ,p_vrei_attribute6              => p_vrei_attribute6
    ,p_vrei_attribute7              => p_vrei_attribute7
    ,p_vrei_attribute8              => p_vrei_attribute8
    ,p_vrei_attribute9              => p_vrei_attribute9
    ,p_vrei_attribute10             => p_vrei_attribute10
    ,p_vrei_attribute11             => p_vrei_attribute11
    ,p_vrei_attribute12             => p_vrei_attribute12
    ,p_vrei_attribute13             => p_vrei_attribute13
    ,p_vrei_attribute14             => p_vrei_attribute14
    ,p_vrei_attribute15             => p_vrei_attribute15
    ,p_vrei_attribute16             => p_vrei_attribute16
    ,p_vrei_attribute17             => p_vrei_attribute17
    ,p_vrei_attribute18             => p_vrei_attribute18
    ,p_vrei_attribute19             => p_vrei_attribute19
    ,p_vrei_attribute20             => p_vrei_attribute20
    ,p_vrei_information_category    => p_vrei_information_category
    ,p_vrei_information1            => p_vrei_information1
    ,p_vrei_information2            => p_vrei_information2
    ,p_vrei_information3            => p_vrei_information3
    ,p_vrei_information4            => p_vrei_information4
    ,p_vrei_information5            => p_vrei_information5
    ,p_vrei_information6            => p_vrei_information6
    ,p_vrei_information7            => p_vrei_information7
    ,p_vrei_information8            => p_vrei_information8
    ,p_vrei_information9            => p_vrei_information9
    ,p_vrei_information10           => p_vrei_information10
    ,p_vrei_information11           => p_vrei_information11
    ,p_vrei_information12           => p_vrei_information12
    ,p_vrei_information13           => p_vrei_information13
    ,p_vrei_information14           => p_vrei_information14
    ,p_vrei_information15           => p_vrei_information15
    ,p_vrei_information16           => p_vrei_information16
    ,p_vrei_information17           => p_vrei_information17
    ,p_vrei_information18           => p_vrei_information18
    ,p_vrei_information19           => p_vrei_information19
    ,p_vrei_information20           => p_vrei_information20
    ,p_vrei_information21           => p_vrei_information21
    ,p_vrei_information22           => p_vrei_information22
    ,p_vrei_information23           => p_vrei_information23
    ,p_vrei_information24           => p_vrei_information24
    ,p_vrei_information25           => p_vrei_information25
    ,p_vrei_information26           => p_vrei_information26
    ,p_vrei_information27           => p_vrei_information27
    ,p_vrei_information28           => p_vrei_information28
    ,p_vrei_information29           => p_vrei_information29
    ,p_vrei_information30           => p_vrei_information30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_veh_repos_extra_info_id      => l_veh_repos_extra_info_id
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
    rollback to create_veh_repos_xtra_info_swi;
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
    rollback to create_veh_repos_xtra_info_swi;
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
end create_veh_repos_extra_info;
-- ----------------------------------------------------------------------------
-- |----------------------< update_veh_repos_extra_info >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_veh_repos_extra_info
  (p_validate                     in     number
  ,p_veh_repos_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_repository_id        in     number
  ,p_information_type             in     varchar2
  ,p_vrei_attribute_category      in     varchar2
  ,p_vrei_attribute1              in     varchar2
  ,p_vrei_attribute2              in     varchar2
  ,p_vrei_attribute3              in     varchar2
  ,p_vrei_attribute4              in     varchar2
  ,p_vrei_attribute5              in     varchar2
  ,p_vrei_attribute6              in     varchar2
  ,p_vrei_attribute7              in     varchar2
  ,p_vrei_attribute8              in     varchar2
  ,p_vrei_attribute9              in     varchar2
  ,p_vrei_attribute10             in     varchar2
  ,p_vrei_attribute11             in     varchar2
  ,p_vrei_attribute12             in     varchar2
  ,p_vrei_attribute13             in     varchar2
  ,p_vrei_attribute14             in     varchar2
  ,p_vrei_attribute15             in     varchar2
  ,p_vrei_attribute16             in     varchar2
  ,p_vrei_attribute17             in     varchar2
  ,p_vrei_attribute18             in     varchar2
  ,p_vrei_attribute19             in     varchar2
  ,p_vrei_attribute20             in     varchar2
  ,p_vrei_information_category    in     varchar2
  ,p_vrei_information1            in     varchar2
  ,p_vrei_information2            in     varchar2
  ,p_vrei_information3            in     varchar2
  ,p_vrei_information4            in     varchar2
  ,p_vrei_information5            in     varchar2
  ,p_vrei_information6            in     varchar2
  ,p_vrei_information7            in     varchar2
  ,p_vrei_information8            in     varchar2
  ,p_vrei_information9            in     varchar2
  ,p_vrei_information10           in     varchar2
  ,p_vrei_information11           in     varchar2
  ,p_vrei_information12           in     varchar2
  ,p_vrei_information13           in     varchar2
  ,p_vrei_information14           in     varchar2
  ,p_vrei_information15           in     varchar2
  ,p_vrei_information16           in     varchar2
  ,p_vrei_information17           in     varchar2
  ,p_vrei_information18           in     varchar2
  ,p_vrei_information19           in     varchar2
  ,p_vrei_information20           in     varchar2
  ,p_vrei_information21           in     varchar2
  ,p_vrei_information22           in     varchar2
  ,p_vrei_information23           in     varchar2
  ,p_vrei_information24           in     varchar2
  ,p_vrei_information25           in     varchar2
  ,p_vrei_information26           in     varchar2
  ,p_vrei_information27           in     varchar2
  ,p_vrei_information28           in     varchar2
  ,p_vrei_information29           in     varchar2
  ,p_vrei_information30           in     varchar2
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
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
  l_proc    varchar2(72) := g_package ||'update_veh_repos_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_veh_repos_xtra_info_swi;
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
  pqp_veh_repos_extra_info_api.update_veh_repos_extra_info
    (p_validate                     => l_validate
    ,p_veh_repos_extra_info_id      => p_veh_repos_extra_info_id
    ,p_object_version_number        => p_object_version_number
    ,p_vehicle_repository_id        => p_vehicle_repository_id
    ,p_information_type             => p_information_type
    ,p_vrei_attribute_category      => p_vrei_attribute_category
    ,p_vrei_attribute1              => p_vrei_attribute1
    ,p_vrei_attribute2              => p_vrei_attribute2
    ,p_vrei_attribute3              => p_vrei_attribute3
    ,p_vrei_attribute4              => p_vrei_attribute4
    ,p_vrei_attribute5              => p_vrei_attribute5
    ,p_vrei_attribute6              => p_vrei_attribute6
    ,p_vrei_attribute7              => p_vrei_attribute7
    ,p_vrei_attribute8              => p_vrei_attribute8
    ,p_vrei_attribute9              => p_vrei_attribute9
    ,p_vrei_attribute10             => p_vrei_attribute10
    ,p_vrei_attribute11             => p_vrei_attribute11
    ,p_vrei_attribute12             => p_vrei_attribute12
    ,p_vrei_attribute13             => p_vrei_attribute13
    ,p_vrei_attribute14             => p_vrei_attribute14
    ,p_vrei_attribute15             => p_vrei_attribute15
    ,p_vrei_attribute16             => p_vrei_attribute16
    ,p_vrei_attribute17             => p_vrei_attribute17
    ,p_vrei_attribute18             => p_vrei_attribute18
    ,p_vrei_attribute19             => p_vrei_attribute19
    ,p_vrei_attribute20             => p_vrei_attribute20
    ,p_vrei_information_category    => p_vrei_information_category
    ,p_vrei_information1            => p_vrei_information1
    ,p_vrei_information2            => p_vrei_information2
    ,p_vrei_information3            => p_vrei_information3
    ,p_vrei_information4            => p_vrei_information4
    ,p_vrei_information5            => p_vrei_information5
    ,p_vrei_information6            => p_vrei_information6
    ,p_vrei_information7            => p_vrei_information7
    ,p_vrei_information8            => p_vrei_information8
    ,p_vrei_information9            => p_vrei_information9
    ,p_vrei_information10           => p_vrei_information10
    ,p_vrei_information11           => p_vrei_information11
    ,p_vrei_information12           => p_vrei_information12
    ,p_vrei_information13           => p_vrei_information13
    ,p_vrei_information14           => p_vrei_information14
    ,p_vrei_information15           => p_vrei_information15
    ,p_vrei_information16           => p_vrei_information16
    ,p_vrei_information17           => p_vrei_information17
    ,p_vrei_information18           => p_vrei_information18
    ,p_vrei_information19           => p_vrei_information19
    ,p_vrei_information20           => p_vrei_information20
    ,p_vrei_information21           => p_vrei_information21
    ,p_vrei_information22           => p_vrei_information22
    ,p_vrei_information23           => p_vrei_information23
    ,p_vrei_information24           => p_vrei_information24
    ,p_vrei_information25           => p_vrei_information25
    ,p_vrei_information26           => p_vrei_information26
    ,p_vrei_information27           => p_vrei_information27
    ,p_vrei_information28           => p_vrei_information28
    ,p_vrei_information29           => p_vrei_information29
    ,p_vrei_information30           => p_vrei_information30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to update_veh_repos_xtra_info_swi;
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
    rollback to update_veh_repos_xtra_info_swi;
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
end update_veh_repos_extra_info;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_veh_repos_extra_info >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_veh_repos_extra_info
  (p_validate                     in     number
  ,p_veh_repos_extra_info_id      in     number
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
  l_proc    varchar2(72) := g_package ||'delete_veh_repos_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_veh_repos_xtra_info_swi;
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
  pqp_veh_repos_extra_info_api.delete_veh_repos_extra_info
    (p_validate                     => l_validate
    ,p_veh_repos_extra_info_id      => p_veh_repos_extra_info_id
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
    rollback to delete_veh_repos_xtra_info_swi;
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
    rollback to delete_veh_repos_xtra_info_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_veh_repos_extra_info;
end pqp_veh_repos_extra_info_swi;

/
