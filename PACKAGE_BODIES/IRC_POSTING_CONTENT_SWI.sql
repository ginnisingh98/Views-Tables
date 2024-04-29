--------------------------------------------------------
--  DDL for Package Body IRC_POSTING_CONTENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_POSTING_CONTENT_SWI" As
/* $Header: iripcswi.pkb 120.4.12010000.2 2009/05/28 10:16:41 avarri ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_posting_content_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_posting_content >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_posting_content
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_display_manager_info         in     varchar2
  ,p_display_recruiter_info       in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_name                         in     varchar2
  ,p_org_name                     in     varchar2  default null
  ,p_org_description              in     varchar2  default null
  ,p_job_title                    in     varchar2  default null
  ,p_brief_description            in     varchar2  default null
  ,p_detailed_description         in     varchar2  default null
  ,p_job_requirements             in     varchar2  default null
  ,p_additional_details           in     varchar2  default null
  ,p_how_to_apply                 in     varchar2  default null
  ,p_benefit_info                 in     varchar2  default null
  ,p_image_url                    in     varchar2  default null
  ,p_alt_image_url                in     varchar2  default null
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
  ,p_ipc_information_category     in     varchar2  default null
  ,p_ipc_information1             in     varchar2  default null
  ,p_ipc_information2             in     varchar2  default null
  ,p_ipc_information3             in     varchar2  default null
  ,p_ipc_information4             in     varchar2  default null
  ,p_ipc_information5             in     varchar2  default null
  ,p_ipc_information6             in     varchar2  default null
  ,p_ipc_information7             in     varchar2  default null
  ,p_ipc_information8             in     varchar2  default null
  ,p_ipc_information9             in     varchar2  default null
  ,p_ipc_information10            in     varchar2  default null
  ,p_ipc_information11            in     varchar2  default null
  ,p_ipc_information12            in     varchar2  default null
  ,p_ipc_information13            in     varchar2  default null
  ,p_ipc_information14            in     varchar2  default null
  ,p_ipc_information15            in     varchar2  default null
  ,p_ipc_information16            in     varchar2  default null
  ,p_ipc_information17            in     varchar2  default null
  ,p_ipc_information18            in     varchar2  default null
  ,p_ipc_information19            in     varchar2  default null
  ,p_ipc_information20            in     varchar2  default null
  ,p_ipc_information21            in     varchar2  default null
  ,p_ipc_information22            in     varchar2  default null
  ,p_ipc_information23            in     varchar2  default null
  ,p_ipc_information24            in     varchar2  default null
  ,p_ipc_information25            in     varchar2  default null
  ,p_ipc_information26            in     varchar2  default null
  ,p_ipc_information27            in     varchar2  default null
  ,p_ipc_information28            in     varchar2  default null
  ,p_ipc_information29            in     varchar2  default null
  ,p_ipc_information30            in     varchar2  default null
  ,p_date_approved                in     date      default null
  ,p_posting_content_id           in     number
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
  l_posting_content_id           number;
  l_proc    varchar2(72) := g_package ||'create_posting_content';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_posting_content_swi;
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
  irc_ipc_ins.set_base_key_value
    (p_posting_content_id => p_posting_content_id
    );
  --
  -- Call API
  --
  irc_posting_content_api.create_posting_content
    (p_validate                     => l_validate
    ,p_display_manager_info         => p_display_manager_info
    ,p_display_recruiter_info       => p_display_recruiter_info
    ,p_language_code                => p_language_code
    ,p_name                         => p_name
    ,p_org_name                     => p_org_name
    ,p_org_description              => p_org_description
    ,p_job_title                    => p_job_title
    ,p_brief_description            => p_brief_description
    ,p_detailed_description         => p_detailed_description
    ,p_job_requirements             => p_job_requirements
    ,p_additional_details           => p_additional_details
    ,p_how_to_apply                 => p_how_to_apply
    ,p_benefit_info                 => p_benefit_info
    ,p_image_url                    => p_image_url
    ,p_alt_image_url                => p_alt_image_url
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
    ,p_ipc_information_category     => p_ipc_information_category
    ,p_ipc_information1             => p_ipc_information1
    ,p_ipc_information2             => p_ipc_information2
    ,p_ipc_information3             => p_ipc_information3
    ,p_ipc_information4             => p_ipc_information4
    ,p_ipc_information5             => p_ipc_information5
    ,p_ipc_information6             => p_ipc_information6
    ,p_ipc_information7             => p_ipc_information7
    ,p_ipc_information8             => p_ipc_information8
    ,p_ipc_information9             => p_ipc_information9
    ,p_ipc_information10            => p_ipc_information10
    ,p_ipc_information11            => p_ipc_information11
    ,p_ipc_information12            => p_ipc_information12
    ,p_ipc_information13            => p_ipc_information13
    ,p_ipc_information14            => p_ipc_information14
    ,p_ipc_information15            => p_ipc_information15
    ,p_ipc_information16            => p_ipc_information16
    ,p_ipc_information17            => p_ipc_information17
    ,p_ipc_information18            => p_ipc_information18
    ,p_ipc_information19            => p_ipc_information19
    ,p_ipc_information20            => p_ipc_information20
    ,p_ipc_information21            => p_ipc_information21
    ,p_ipc_information22            => p_ipc_information22
    ,p_ipc_information23            => p_ipc_information23
    ,p_ipc_information24            => p_ipc_information24
    ,p_ipc_information25            => p_ipc_information25
    ,p_ipc_information26            => p_ipc_information26
    ,p_ipc_information27            => p_ipc_information27
    ,p_ipc_information28            => p_ipc_information28
    ,p_ipc_information29            => p_ipc_information29
    ,p_ipc_information30            => p_ipc_information30
    ,p_date_approved                => p_date_approved
    ,p_posting_content_id           => l_posting_content_id
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
    rollback to create_posting_content_swi;
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
    rollback to create_posting_content_swi;
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
end create_posting_content;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_posting_content >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_posting_content
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_posting_content_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_posting_content';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_posting_content_swi;
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
  irc_posting_content_api.delete_posting_content
    (p_validate                     => l_validate
    ,p_posting_content_id           => p_posting_content_id
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
    rollback to delete_posting_content_swi;
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
    rollback to delete_posting_content_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_posting_content;
-- ----------------------------------------------------------------------------
-- |------------------------< update_posting_content >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_posting_content
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_posting_content_id           in     number
  ,p_display_manager_info         in     varchar2  default hr_api.g_varchar2
  ,p_display_recruiter_info       in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_org_name                     in     varchar2  default hr_api.g_varchar2
  ,p_org_description              in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_brief_description            in     varchar2  default hr_api.g_varchar2
  ,p_detailed_description         in     varchar2  default hr_api.g_varchar2
  ,p_job_requirements             in     varchar2  default hr_api.g_varchar2
  ,p_additional_details           in     varchar2  default hr_api.g_varchar2
  ,p_how_to_apply                 in     varchar2  default hr_api.g_varchar2
  ,p_benefit_info                 in     varchar2  default hr_api.g_varchar2
  ,p_image_url                    in     varchar2  default hr_api.g_varchar2
  ,p_alt_image_url                in     varchar2  default hr_api.g_varchar2
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
  ,p_ipc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_approved                in     date      default hr_api.g_date
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
  l_proc    varchar2(72) := g_package ||'update_posting_content';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_posting_content_swi;
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
  irc_posting_content_api.update_posting_content
    (p_validate                     => l_validate
    ,p_posting_content_id           => p_posting_content_id
    ,p_display_manager_info         => p_display_manager_info
    ,p_display_recruiter_info       => p_display_recruiter_info
    ,p_language_code                => p_language_code
    ,p_name                         => p_name
    ,p_org_name                     => p_org_name
    ,p_org_description              => p_org_description
    ,p_job_title                    => p_job_title
    ,p_brief_description            => p_brief_description
    ,p_detailed_description         => p_detailed_description
    ,p_job_requirements             => p_job_requirements
    ,p_additional_details           => p_additional_details
    ,p_how_to_apply                 => p_how_to_apply
    ,p_benefit_info                 => p_benefit_info
    ,p_image_url                    => p_image_url
    ,p_alt_image_url                => p_alt_image_url
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
    ,p_ipc_information_category     => p_ipc_information_category
    ,p_ipc_information1             => p_ipc_information1
    ,p_ipc_information2             => p_ipc_information2
    ,p_ipc_information3             => p_ipc_information3
    ,p_ipc_information4             => p_ipc_information4
    ,p_ipc_information5             => p_ipc_information5
    ,p_ipc_information6             => p_ipc_information6
    ,p_ipc_information7             => p_ipc_information7
    ,p_ipc_information8             => p_ipc_information8
    ,p_ipc_information9             => p_ipc_information9
    ,p_ipc_information10            => p_ipc_information10
    ,p_ipc_information11            => p_ipc_information11
    ,p_ipc_information12            => p_ipc_information12
    ,p_ipc_information13            => p_ipc_information13
    ,p_ipc_information14            => p_ipc_information14
    ,p_ipc_information15            => p_ipc_information15
    ,p_ipc_information16            => p_ipc_information16
    ,p_ipc_information17            => p_ipc_information17
    ,p_ipc_information18            => p_ipc_information18
    ,p_ipc_information19            => p_ipc_information19
    ,p_ipc_information20            => p_ipc_information20
    ,p_ipc_information21            => p_ipc_information21
    ,p_ipc_information22            => p_ipc_information22
    ,p_ipc_information23            => p_ipc_information23
    ,p_ipc_information24            => p_ipc_information24
    ,p_ipc_information25            => p_ipc_information25
    ,p_ipc_information26            => p_ipc_information26
    ,p_ipc_information27            => p_ipc_information27
    ,p_ipc_information28            => p_ipc_information28
    ,p_ipc_information29            => p_ipc_information29
    ,p_ipc_information30            => p_ipc_information30
    ,p_date_approved                => p_date_approved
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
    rollback to update_posting_content_swi;
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
    rollback to update_posting_content_swi;
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
end update_posting_content;

-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------

procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState               VARCHAR2(2);
   l_return_status           VARCHAR2(1);
   l_object_version_number   number;
   l_posting_content_id   number;
   l_commitElement           xmldom.DOMElement;
   l_parser                  xmlparser.Parser;
   l_CommitNode              xmldom.DOMNode;

   l_proc               varchar2(72)  := g_package || 'process_api';
   l_effective_date     date          :=  trunc(sysdate);

BEGIN
--
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
--
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
--
--Get the values for in/out parameters
--
    l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');
    l_posting_content_id    := hr_transaction_swi.getNumberValue(l_CommitNode,'PostingContentId');
--
   if p_effective_date is null then
     l_effective_date := trunc(sysdate);
   else
     l_effective_date := p_effective_date;
   end if;
--
   if l_postState = '0' then
--
   hr_utility.set_location('creating :' || l_proc,30);
--
     create_posting_content
     (p_validate                   => p_validate
     ,p_display_manager_info       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DisplayManagerInfo',NULL)
     ,p_display_recruiter_info     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DisplayRecruiterInfo',NULL)
     ,p_language_code              => hr_transaction_swi.getVarchar2Value(l_CommitNode,'LanguageCode',NULL)
     ,p_name                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name',NULL)
     ,p_org_name                   => getClobValue(l_CommitNode,'OrgName',NULL)
     ,p_org_description            => getClobValue(l_CommitNode,'OrgDescription',NULL)
     ,p_job_title                  => getClobValue(l_CommitNode,'JobTitle',NULL)
     ,p_brief_description          => getClobValue(l_CommitNode,'BriefDescription',NULL)
     ,p_detailed_description       => getClobValue(l_CommitNode,'DetailedDescription',NULL)
     ,p_job_requirements           => getClobValue(l_CommitNode,'JobRequirements',NULL)
     ,p_additional_details         => getClobValue(l_CommitNode,'AdditionalDetails',NULL)
     ,p_how_to_apply               => getClobValue(l_CommitNode,'HowToApply',NULL)
     ,p_benefit_info               => getClobValue(l_CommitNode,'BenefitInfo',NULL)
     ,p_image_url                  => getClobValue(l_CommitNode,'ImageUrl',NULL)
     ,p_alt_image_url              => getClobValue(l_CommitNode,'AltImageUrl',NULL)
     ,p_attribute_category         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_attribute21                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
     ,p_attribute22                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
     ,p_attribute23                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
     ,p_attribute24                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
     ,p_attribute25                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
     ,p_attribute26                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
     ,p_attribute27                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
     ,p_attribute28                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
     ,p_attribute29                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
     ,p_attribute30                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
     ,p_ipc_information_category   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformationCategory',NULL)
     ,p_ipc_information1           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation1',NULL)
     ,p_ipc_information2           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation2',NULL)
     ,p_ipc_information3           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation3',NULL)
     ,p_ipc_information4           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation4',NULL)
     ,p_ipc_information5           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation5',NULL)
     ,p_ipc_information6           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation6',NULL)
     ,p_ipc_information7           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation7',NULL)
     ,p_ipc_information8           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation8',NULL)
     ,p_ipc_information9           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation9',NULL)
     ,p_ipc_information10          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation10',NULL)
     ,p_ipc_information11          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation11',NULL)
     ,p_ipc_information12          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation12',NULL)
     ,p_ipc_information13          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation13',NULL)
     ,p_ipc_information14          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation14',NULL)
     ,p_ipc_information15          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation15',NULL)
     ,p_ipc_information16          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation16',NULL)
     ,p_ipc_information17          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation17',NULL)
     ,p_ipc_information18          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation18',NULL)
     ,p_ipc_information19          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation19',NULL)
     ,p_ipc_information20          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation20',NULL)
     ,p_ipc_information21          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation21',NULL)
     ,p_ipc_information22          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation22',NULL)
     ,p_ipc_information23          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation23',NULL)
     ,p_ipc_information24          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation24',NULL)
     ,p_ipc_information25          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation25',NULL)
     ,p_ipc_information26          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation26',NULL)
     ,p_ipc_information27          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation27',NULL)
     ,p_ipc_information28          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation28',NULL)
     ,p_ipc_information29          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation29',NULL)
     ,p_ipc_information30          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation30',NULL)
     ,p_date_approved              => hr_transaction_swi.getDateValue(l_CommitNode,'DateApproved',NULL)
     ,p_posting_content_id         => l_posting_content_id
     ,p_object_version_number      => l_object_version_number
     ,p_return_status              => l_return_status
     );
     --
   elsif l_postState = '2' then
--
   hr_utility.set_location('updating :' || l_proc,32);
     --
     update_posting_content
     (p_validate                   => p_validate
     ,p_posting_content_id         => l_posting_content_id
     -- ,p_display_manager_info       => 'Y'
     -- ,p_display_recruiter_info     => 'Y'
     ,p_display_manager_info       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DisplayManagerInfo',NULL)
     ,p_display_recruiter_info     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DisplayRecruiterInfo',NULL)
     ,p_language_code              => hr_transaction_swi.getVarchar2Value(l_CommitNode,'LanguageCode',NULL)
     ,p_name                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name',NULL)
     ,p_org_name                   => getClobValue(l_CommitNode,'OrgName',NULL)
     ,p_org_description            => getClobValue(l_CommitNode,'OrgDescription',NULL)
     ,p_job_title                  => getClobValue(l_CommitNode,'JobTitle',NULL)
     ,p_brief_description          => getClobValue(l_CommitNode,'BriefDescription',NULL)
     ,p_detailed_description       => getClobValue(l_CommitNode,'DetailedDescription',NULL)
     ,p_job_requirements           => getClobValue(l_CommitNode,'JobRequirements',NULL)
     ,p_additional_details         => getClobValue(l_CommitNode,'AdditionalDetails',NULL)
     ,p_how_to_apply               => getClobValue(l_CommitNode,'HowToApply',NULL)
     ,p_benefit_info               => getClobValue(l_CommitNode,'BenefitInfo',NULL)
     ,p_image_url                  => getClobValue(l_CommitNode,'ImageUrl',NULL)
     ,p_alt_image_url              => getClobValue(l_CommitNode,'AltImageUrl',NULL)
     ,p_attribute_category         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_attribute21                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
     ,p_attribute22                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
     ,p_attribute23                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
     ,p_attribute24                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
     ,p_attribute25                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
     ,p_attribute26                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
     ,p_attribute27                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
     ,p_attribute28                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
     ,p_attribute29                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
     ,p_attribute30                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
     ,p_ipc_information_category   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformationCategory',NULL)
     ,p_ipc_information1           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation1',NULL)
     ,p_ipc_information2           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation2',NULL)
     ,p_ipc_information3           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation3',NULL)
     ,p_ipc_information4           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation4',NULL)
     ,p_ipc_information5           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation5',NULL)
     ,p_ipc_information6           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation6',NULL)
     ,p_ipc_information7           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation7',NULL)
     ,p_ipc_information8           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation8',NULL)
     ,p_ipc_information9           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation9',NULL)
     ,p_ipc_information10          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation10',NULL)
     ,p_ipc_information11          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation11',NULL)
     ,p_ipc_information12          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation12',NULL)
     ,p_ipc_information13          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation13',NULL)
     ,p_ipc_information14          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation14',NULL)
     ,p_ipc_information15          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation15',NULL)
     ,p_ipc_information16          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation16',NULL)
     ,p_ipc_information17          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation17',NULL)
     ,p_ipc_information18          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation18',NULL)
     ,p_ipc_information19          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation19',NULL)
     ,p_ipc_information20          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation20',NULL)
     ,p_ipc_information21          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation21',NULL)
     ,p_ipc_information22          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation22',NULL)
     ,p_ipc_information23          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation23',NULL)
     ,p_ipc_information24          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation24',NULL)
     ,p_ipc_information25          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation25',NULL)
     ,p_ipc_information26          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation26',NULL)
     ,p_ipc_information27          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation27',NULL)
     ,p_ipc_information28          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation28',NULL)
     ,p_ipc_information29          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation29',NULL)
     ,p_ipc_information30          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IpcInformation30',NULL)
     ,p_date_approved              => hr_transaction_swi.getDateValue(l_CommitNode,'DateApproved',NULL)
     ,p_object_version_number      => l_object_version_number
     ,p_return_status              => l_return_status
     );
     --
   elsif l_postState = '3' then
--
   hr_utility.set_location('deleting :' || l_proc,33);
     --
     delete_posting_content
     (p_validate                     => p_validate
     ,p_object_version_number        => l_object_version_number
     ,p_posting_content_id           => l_posting_content_id
     ,p_return_status                => l_return_status
     );
     --
   end if;
   p_return_status := l_return_status;

   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);

end process_api;

Function getClobValue(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in varchar2 default hr_api.g_varchar2)
  return varchar2 IS
  l_varchar2 VARCHAR2(32767);
  l_isNull VARCHAR2(10);
  l_element xmldom.DOMElement;
  l_proc    varchar2(72) := g_package || 'getVarchar2Value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  xslprocessor.valueof(commitNode,attributeName,l_varchar2);
  l_element := xmldom.makeElement(commitNode);
  l_isNull := xmldom.getAttribute(l_element, 'null');
  if l_isNull = 'true' then
    l_varchar2 := NULL;
  else
    l_varchar2 := NVL(l_varchar2, gmisc_value);
  end if;
  hr_utility.set_location(' Exiting :' || l_proc,15);
  return l_varchar2;
End getClobValue;


end irc_posting_content_swi;

/
