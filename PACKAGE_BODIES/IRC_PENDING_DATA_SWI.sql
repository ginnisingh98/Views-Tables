--------------------------------------------------------
--  DDL for Package Body IRC_PENDING_DATA_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PENDING_DATA_SWI" As
/* $Header: iripdswi.pkb 120.0 2005/07/26 15:09:58 mbocutt noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_pending_data_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pending_data >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_pending_data
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_email_address                in     varchar2
  ,p_last_name                    in     varchar2
  ,p_vacancy_id                   in     number    default null
  ,p_first_name                   in     varchar2  default null
  ,p_user_password                in     varchar2  default null
  ,p_resume_file_name             in     varchar2  default null
  ,p_resume_description           in     varchar2  default null
  ,p_resume_mime_type             in     varchar2  default null
  ,p_source_type                  in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_person_id                    in     number    default null
  ,p_processed                    in     varchar2  default null
  ,p_sex                          in     varchar2  default null
  ,p_date_of_birth                in     date      default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_error_message                in     varchar2  default null
  ,p_creation_date                in     date
  ,p_last_update_date             in     date
  ,p_pending_data_id              in     number
  ,p_allow_access                 in     varchar2 default null
  ,p_user_guid                    in     raw      default null
  ,p_visitor_resp_key             in     varchar2 default null
  ,p_visitor_resp_appl_id         in     number   default null
  ,p_security_group_key           in     varchar2 default null
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_pending_data_id              number;
  l_proc    varchar2(72) := g_package ||'create_pending_data';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_pending_data_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
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
  irc_ipd_ins.set_base_key_value
    (p_pending_data_id => p_pending_data_id
    );
  --
  -- Call API
  --
  irc_pending_data_api.create_pending_data
    (p_validate                     => l_validate
	,p_email_address                => p_email_address
    ,p_last_name                    => p_last_name
    ,p_vacancy_id                   => p_vacancy_id
    ,p_first_name                   => p_first_name
    ,p_user_password                => p_user_password
    ,p_resume_file_name             => p_resume_file_name
    ,p_resume_description           => p_resume_description
    ,p_resume_mime_type             => p_resume_mime_type
    ,p_source_type                  => p_source_type
    ,p_job_post_source_name         => p_job_post_source_name
    ,p_posting_content_id           => p_posting_content_id
    ,p_person_id                    => p_person_id
    ,p_processed                    => p_processed
    ,p_sex                          => p_sex
    ,p_date_of_birth                => p_date_of_birth
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_error_message                => p_error_message
    ,p_creation_date                => p_creation_date
    ,p_last_update_date             => p_last_update_date
    ,p_pending_data_id              => l_pending_data_id
    ,p_allow_access                 => p_allow_access
    ,p_user_guid                    => p_user_guid
    ,p_visitor_resp_key             => p_visitor_resp_key
    ,p_visitor_resp_appl_id         => p_visitor_resp_appl_id
    ,p_security_group_key           => p_security_group_key
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
    rollback to create_pending_data_swi;
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
    rollback to create_pending_data_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_pending_data;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pending_data >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_pending_data
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pending_data_id              in     number
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_user_password                in     varchar2  default hr_api.g_varchar2
  ,p_resume_file_name             in     varchar2  default hr_api.g_varchar2
  ,p_resume_description           in     varchar2  default hr_api.g_varchar2
  ,p_resume_mime_type             in     varchar2  default hr_api.g_varchar2
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_processed                    in     varchar2  default hr_api.g_varchar2
  ,p_sex                          in     varchar2  default hr_api.g_varchar2
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_error_message                in     varchar2  default hr_api.g_varchar2
  ,p_creation_date                in     date      default hr_api.g_date
  ,p_last_update_date             in     date      default hr_api.g_date
  ,p_allow_access                 in     varchar2  default hr_api.g_varchar2
  ,p_user_guid                    in     raw       default null
  ,p_visitor_resp_key             in     varchar2  default hr_api.g_varchar2
  ,p_visitor_resp_appl_id         in     number    default hr_api.g_number
  ,p_security_group_key           in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_pending_data';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_pending_data_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Call API
  --
  irc_pending_data_api.update_pending_data
    (p_validate                     => l_validate
	,p_pending_data_id              => p_pending_data_id
    ,p_email_address                => p_email_address
    ,p_last_name                    => p_last_name
    ,p_vacancy_id                   => p_vacancy_id
    ,p_first_name                   => p_first_name
    ,p_user_password                => p_user_password
    ,p_resume_file_name             => p_resume_file_name
    ,p_resume_description           => p_resume_description
    ,p_resume_mime_type             => p_resume_mime_type
    ,p_source_type                  => p_source_type
    ,p_job_post_source_name         => p_job_post_source_name
    ,p_posting_content_id           => p_posting_content_id
    ,p_person_id                    => p_person_id
    ,p_processed                    => p_processed
    ,p_sex                          => p_sex
    ,p_date_of_birth                => p_date_of_birth
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_error_message                => p_error_message
    ,p_creation_date                => p_creation_date
    ,p_last_update_date             => p_last_update_date
    ,p_allow_access                 => p_allow_access
    ,p_user_guid                    => p_user_guid
    ,p_visitor_resp_key             => p_visitor_resp_key
    ,p_visitor_resp_appl_id         => p_visitor_resp_appl_id
    ,p_security_group_key           => p_security_group_key
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
    rollback to update_pending_data_swi;
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
    rollback to update_pending_data_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_pending_data;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pending_data >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_pending_data
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pending_data_id              in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_pending_data';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pending_data_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Call API
  --
  irc_pending_data_api.delete_pending_data
    (p_validate                     => l_validate
	,p_pending_data_id              => p_pending_data_id
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
    rollback to delete_pending_data_swi;
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
    rollback to delete_pending_data_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_pending_data;
end irc_pending_data_swi;

/
