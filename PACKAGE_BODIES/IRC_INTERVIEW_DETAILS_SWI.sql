--------------------------------------------------------
--  DDL for Package Body IRC_INTERVIEW_DETAILS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_INTERVIEW_DETAILS_SWI" As
/* $Header: iriidswi.pkb 120.0 2007/12/10 09:10:30 mkjayara noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_interview_details_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_irc_interview_details >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_irc_interview_details
  (p_validate                      in     number   default hr_api.g_false_num
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_feedback                      in     varchar2 default hr_api.g_varchar2
  ,p_notes                         in     varchar2 default hr_api.g_varchar2
  ,p_notes_to_candidate            in     varchar2  default hr_api.g_varchar2
  ,p_category                      in     varchar2  default hr_api.g_varchar2
  ,p_result                        in     varchar2 default hr_api.g_varchar2
  ,p_iid_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20             in     varchar2  default hr_api.g_varchar2
  ,p_event_id                      in     number
  ,p_interview_details_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_interview_details_id             number;
  l_proc    varchar2(72) := g_package ||'create_irc_interview_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_interview_details_swi;
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
  irc_iid_ins.set_base_key_value
    (p_interview_details_id => p_interview_details_id
    );
  --
  -- Call API
  --
  irc_interview_details_api.create_irc_interview_details
    (p_validate                  => l_validate
    ,p_status                    => p_status
    ,p_feedback                  => p_feedback
    ,p_notes                     => p_notes
    ,p_notes_to_candidate        => p_notes_to_candidate
    ,p_category                  => p_category
    ,p_result                    => p_result
    ,p_iid_information_category  => p_iid_information_category
    ,p_iid_information1          => p_iid_information1
    ,p_iid_information2          => p_iid_information2
    ,p_iid_information3          => p_iid_information3
    ,p_iid_information4          => p_iid_information4
    ,p_iid_information5          => p_iid_information5
    ,p_iid_information6          => p_iid_information6
    ,p_iid_information7          => p_iid_information7
    ,p_iid_information8          => p_iid_information8
    ,p_iid_information9          => p_iid_information9
    ,p_iid_information10         => p_iid_information10
    ,p_iid_information11         => p_iid_information11
    ,p_iid_information12         => p_iid_information12
    ,p_iid_information13         => p_iid_information13
    ,p_iid_information14         => p_iid_information14
    ,p_iid_information15         => p_iid_information15
    ,p_iid_information16         => p_iid_information16
    ,p_iid_information17         => p_iid_information17
    ,p_iid_information18         => p_iid_information18
    ,p_iid_information19         => p_iid_information19
    ,p_iid_information20         => p_iid_information20
    ,p_event_id                  => p_event_id
    ,p_interview_details_id      => l_interview_details_id
    ,p_object_version_number     => p_object_version_number
    ,p_start_date                => p_start_date
    ,p_end_date                  => p_end_date
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
    rollback to create_interview_details_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
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
    rollback to create_interview_details_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_irc_interview_details;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_irc_interview_details >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_irc_interview_details
  (p_validate                      in     number    default hr_api.g_false_num
  ,p_interview_details_id          in     number
  ,p_status                        in     varchar2  default hr_api.g_varchar2
  ,p_feedback                      in     varchar2  default hr_api.g_varchar2
  ,p_notes                         in     varchar2  default hr_api.g_varchar2
  ,p_notes_to_candidate            in     varchar2  default hr_api.g_varchar2
  ,p_category                      in     varchar2  default hr_api.g_varchar2
  ,p_result                        in     varchar2  default hr_api.g_varchar2
  ,p_iid_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20             in     varchar2  default hr_api.g_varchar2
  ,p_event_id                      in     number
  ,p_object_version_number         in out nocopy number
  ,p_start_date                       out nocopy date
  ,p_end_date                         out nocopy date
  ,p_return_status                    out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_irc_interview_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_interview_details_swi;
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
  irc_interview_details_api.update_irc_interview_details
    (p_validate                  => l_validate
    ,p_interview_details_id      => p_interview_details_id
    ,p_status                    => p_status
    ,p_feedback                  => p_feedback
    ,p_notes                     => p_notes
    ,p_notes_to_candidate        => p_notes_to_candidate
    ,p_category                  => p_category
    ,p_result                    => p_result
    ,p_iid_information_category  => p_iid_information_category
    ,p_iid_information1          => p_iid_information1
    ,p_iid_information2          => p_iid_information2
    ,p_iid_information3          => p_iid_information3
    ,p_iid_information4          => p_iid_information4
    ,p_iid_information5          => p_iid_information5
    ,p_iid_information6          => p_iid_information6
    ,p_iid_information7          => p_iid_information7
    ,p_iid_information8          => p_iid_information8
    ,p_iid_information9          => p_iid_information9
    ,p_iid_information10         => p_iid_information10
    ,p_iid_information11         => p_iid_information11
    ,p_iid_information12         => p_iid_information12
    ,p_iid_information13         => p_iid_information13
    ,p_iid_information14         => p_iid_information14
    ,p_iid_information15         => p_iid_information15
    ,p_iid_information16         => p_iid_information16
    ,p_iid_information17         => p_iid_information17
    ,p_iid_information18         => p_iid_information18
    ,p_iid_information19         => p_iid_information19
    ,p_iid_information20         => p_iid_information20
    ,p_event_id                  => p_event_id
    ,p_object_version_number     => p_object_version_number
    ,p_start_date                => p_start_date
    ,p_end_date                  => p_end_date
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
    rollback to update_interview_details_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to update_interview_details_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_irc_interview_details;
---
end irc_interview_details_swi;

/
