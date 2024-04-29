--------------------------------------------------------
--  DDL for Package Body HR_CWK_TERMINATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CWK_TERMINATION_SWI" As
/* $Header: hrcwtswi.pkb 120.0 2005/05/30 23:33 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_cwk_termination_swi.';
lv_transaction_steps hr_transaction_ss.transaction_table;
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_placement >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE actual_termination_placement
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in out nocopy date
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_supervisor_warning            boolean;
  l_event_warning                 boolean;
  l_interview_warning             boolean;
  l_review_warning                boolean;
  l_recruiter_warning             boolean;
  l_asg_future_changes_warning    boolean;
  l_pay_proposal_warning          boolean;
  l_dod_warning                   boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_last_standard_process_date    date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'actual_termination_placement';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint actual_term_placement_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_last_standard_process_date    := p_last_standard_process_date;
  --
  -- Convert constant values to their corresponding boolean value
  --

  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_contingent_worker_api.actual_termination_placement
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_date_start                   => p_date_start
    ,p_object_version_number        => p_object_version_number
    ,p_actual_termination_date      => p_actual_termination_date
    ,p_last_standard_process_date   => p_last_standard_process_date
    ,p_person_type_id               => p_person_type_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_termination_reason           => p_termination_reason
    ,p_supervisor_warning           => l_supervisor_warning
    ,p_event_warning                => l_event_warning
    ,p_interview_warning            => l_interview_warning
    ,p_review_warning               => l_review_warning
    ,p_recruiter_warning            => l_recruiter_warning
    ,p_asg_future_changes_warning   => l_asg_future_changes_warning
    ,p_entries_changed_warning      => p_entries_changed_warning
    ,p_pay_proposal_warning         => l_pay_proposal_warning
    ,p_dod_warning                  => l_dod_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  /*
  if l_supervisor_warning then
     fnd_message.set_name('PER', 'HR_289757_CWK_IS_SUPER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_event_warning then
     fnd_message.set_name('PER', 'HR_289759_CWK_HAS_EVENTS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_interview_warning then
     fnd_message.set_name('PER', 'HR_289760_CWK_IS_INTERVIEWER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_review_warning then
     fnd_message.set_name('PER', 'HR_289761_CWK_DUE_REVIEW');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_recruiter_warning then
     fnd_message.set_name('PER', 'HR_289762_CWK_VAC_RECRUITER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_asg_future_changes_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASG_FUTURE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  -- l_pay_proposal_warning Reserved for future Use
  if l_pay_proposal_warning then
     fnd_message.set_name('PER', 'HR_PAY_PROPOSAL_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
   if l_dod_warning then
     fnd_message.set_name('PER', 'PER_52475_DEATH_TERM_DATES');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  */
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
    rollback to actual_term_placement_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_last_standard_process_date   := l_last_standard_process_date;
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
    rollback to actual_term_placement_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_last_standard_process_date   := l_last_standard_process_date;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end actual_termination_placement;
-- ----------------------------------------------------------------------------
-- |------------------------< final_process_placement >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE final_process_placement
  (p_validate                     in     boolean
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in out nocopy date
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_org_now_no_manager_warning    boolean;
  l_asg_future_changes_warning    boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_final_process_date            date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'final_process_placement';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint final_process_placement_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_final_process_date            := p_final_process_date;
  --
  -- Convert constant values to their corresponding boolean value
  --

  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_contingent_worker_api.final_process_placement
    (p_validate                     => p_validate
    ,p_person_id                    => p_person_id
    ,p_date_start                   => p_date_start
    ,p_object_version_number        => p_object_version_number
    ,p_final_process_date           => p_final_process_date
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_asg_future_changes_warning   => l_asg_future_changes_warning
    ,p_entries_changed_warning      => p_entries_changed_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
/*
  if l_org_now_no_manager_warning then
     fnd_message.set_name('PER', 'HR_ORG_NOW_NO_MANAGER_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_asg_future_changes_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASG_FUTURE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
*/
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
    rollback to final_process_placement_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_final_process_date           := l_final_process_date;
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
    rollback to final_process_placement_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_final_process_date           := l_final_process_date;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end final_process_placement;
-- ----------------------------------------------------------------------------
-- |------------------------< get_length_of_placement >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_length_of_placement
  (p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_total_years                     out nocopy number
  ,p_total_months                    out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'get_length_of_placement';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint get_length_of_placement_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_contingent_worker_api.get_length_of_placement
    (p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_date_start                   => p_date_start
    ,p_total_years                  => p_total_years
    ,p_total_months                 => p_total_months
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
    rollback to get_length_of_placement_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_total_years                  := null;
    p_total_months                 := null;
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
    rollback to get_length_of_placement_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_total_years                  := null;
    p_total_months                 := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end get_length_of_placement;
-- ----------------------------------------------------------------------------
-- |----------------------< reverse_terminate_placement >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE reverse_terminate_placement
  (p_validate                     in     boolean
  ,p_person_id                    in     number
  ,p_actual_termination_date      in     date
  ,p_clear_details                in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_fut_actns_exist_warning       boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'reverse_terminate_placement';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint reverse_term_placement_swi;
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

  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_contingent_worker_api.reverse_terminate_placement
    (p_validate                     => p_validate
    ,p_person_id                    => p_person_id
    ,p_actual_termination_date      => p_actual_termination_date
    ,p_clear_details                => p_clear_details
    ,p_fut_actns_exist_warning      => l_fut_actns_exist_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  -- l_fut_actns_exist_warning Reserved for Future Use
/*  if l_fut_actns_exist_warning then
     fnd_message.set_name('PER', 'EDIT_HERE: MESSAGE_NAME ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
*/

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
    rollback to reverse_term_placement_swi;
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
    rollback to reverse_term_placement_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end reverse_terminate_placement;
-- ----------------------------------------------------------------------------
-- |--------------------------< terminate_placement >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE terminate_placement
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_actual_termination_date      in     date      default hr_api.g_date
  ,p_final_process_date           in out nocopy date
  ,p_last_standard_process_date   in out nocopy date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_projected_termination_date   in     date      default hr_api.g_date
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
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
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_supervisor_warning            boolean;
  l_event_warning                 boolean;
  l_interview_warning             boolean;
  l_review_warning                boolean;
  l_recruiter_warning             boolean;
  l_asg_future_changes_warning    boolean;
  l_pay_proposal_warning          boolean;
  l_dod_warning                   boolean;
  l_org_now_no_manager_warning    boolean;
  l_addl_rights_warning 	  boolean; -- Bug 1370960
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_final_process_date            date;
  l_last_standard_process_date    date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'terminate_placement';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint terminate_placement_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_final_process_date            := p_final_process_date;
  l_last_standard_process_date    := p_last_standard_process_date;
  --
  -- Convert constant values to their corresponding boolean value
  --

  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_contingent_worker_api.terminate_placement
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_date_start                   => p_date_start
    ,p_object_version_number        => p_object_version_number
    ,p_person_type_id               => p_person_type_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_actual_termination_date      => p_actual_termination_date
    ,p_final_process_date           => p_final_process_date
    ,p_last_standard_process_date   => p_last_standard_process_date
    ,p_termination_reason           => p_termination_reason
    ,p_projected_termination_date   => p_projected_termination_date
--    ,p_rehire_recommendation        => p_rehire_recommendation
--    ,p_rehire_reason                => p_rehire_reason
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
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_information21                => p_information21
    ,p_information22                => p_information22
    ,p_information23                => p_information23
    ,p_information24                => p_information24
    ,p_information25                => p_information25
    ,p_information26                => p_information26
    ,p_information27                => p_information27
    ,p_information28                => p_information28
    ,p_information29                => p_information29
    ,p_information30                => p_information30
    ,p_supervisor_warning           => l_supervisor_warning
    ,p_event_warning                => l_event_warning
    ,p_interview_warning            => l_interview_warning
    ,p_review_warning               => l_review_warning
    ,p_recruiter_warning            => l_recruiter_warning
    ,p_asg_future_changes_warning   => l_asg_future_changes_warning
    ,p_entries_changed_warning      => p_entries_changed_warning
    ,p_pay_proposal_warning         => l_pay_proposal_warning
    ,p_dod_warning                  => l_dod_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_addl_rights_warning          => l_addl_rights_warning    -- Fix 1370960
    );
  --
  --
  -- Core HR API will not support update of field Rehire Recommendation
  -- and Rehire Reason. Hence we make following call to Person API
  -- to update the Fields.

  DECLARE
      l_person_id                   per_all_people_f.person_id%TYPE;
      l_per_object_version_number   per_all_people_f.object_version_number%TYPE;
      l_employee_number             per_all_people_f.employee_number%TYPE;
      l_effective_start_date        date;
      l_effective_end_date          date;
      l_full_name                   per_all_people_f.full_name%TYPE;
      l_comment_id                  per_all_people_f.comment_id%TYPE;
      l_name_combination_warning    boolean;
      l_assign_payroll_warning      boolean;
      l_orig_hire_warning           boolean;

  cursor csr_get_derived_details is
    select per.person_id
         , per.employee_number
         , per.object_version_number
      from per_all_people_f       per
     where per.person_id             = p_person_id
     and   p_actual_termination_date between per.effective_start_date
                                     and     per.effective_end_date;

  BEGIN
      open  csr_get_derived_details;
      fetch csr_get_derived_details
       into l_person_id
          , l_employee_number
          , l_per_object_version_number;
    SAVEPOINT update_person_details;
    hr_person_api.update_person (
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_person_id                    => l_person_id
      ,p_object_version_number        => l_per_object_version_number
      ,p_employee_number              => l_employee_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_rehire_recommendation        => p_rehire_recommendation
      ,p_rehire_reason                => p_rehire_reason
      ,p_full_name                    => l_full_name
      ,p_comment_id                   => l_comment_id
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
    );
    IF p_validate THEN
        ROLLBACK TO update_person_details;
    END IF;
  END;

  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
/*
  if l_supervisor_warning then
     fnd_message.set_name('PER', 'HR_289757_CWK_IS_SUPER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_event_warning then
     fnd_message.set_name('PER', 'HR_289759_CWK_HAS_EVENTS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_interview_warning then
     fnd_message.set_name('PER', 'HR_289760_CWK_IS_INTERVIEWER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_review_warning then
     fnd_message.set_name('PER', 'HR_289761_CWK_DUE_REVIEW');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_recruiter_warning then
     fnd_message.set_name('PER', 'HR_289762_CWK_VAC_RECRUITER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_asg_future_changes_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASG_FUTURE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  -- l_pay_proposal_warning Reserved for future Use
   if l_pay_proposal_warning then
     fnd_message.set_name('PER', 'HR_PAY_PROPOSAL_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;

  if l_dod_warning then
     fnd_message.set_name('PER', 'PER_52475_DEATH_TERM_DATES');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_org_now_no_manager_warning then
     fnd_message.set_name('PER', 'HR_ORG_NOW_NO_MANAGER_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
*/
  -- Fix Bug 1370960
  if l_addl_rights_warning and p_validate then
     fnd_message.set_name('PER', 'PER_449140_OPEN_CWK_ADDL_RIGHT');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
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
    rollback to terminate_placement_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_final_process_date           := l_final_process_date;
    p_last_standard_process_date   := l_last_standard_process_date;
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
    rollback to terminate_placement_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_final_process_date           := l_final_process_date;
    p_last_standard_process_date   := l_last_standard_process_date;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end terminate_placement;

PROCEDURE process_save
(  p_item_type                    in     wf_items.item_type%TYPE
  ,p_item_key                     in     wf_items.item_key%TYPE
  ,p_actid                        in     varchar2
  ,p_transaction_mode             in     varchar2 DEFAULT '#'
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in     number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_actual_termination_date      in     date      default hr_api.g_date
  ,p_final_process_date           in     date
  ,p_last_standard_process_date   in     date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_projected_termination_date   in     date      default hr_api.g_date
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_review_proc_call             in     varchar2  default hr_api.g_varchar2
  ,p_effective_date_option        in     varchar2  default hr_api.g_varchar2
  ,p_login_person_id              in     number
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_return_on_warning             in     varchar2 default null --Bug fix 1370960
) Is

  -- Local params for Saving Transaction
  lv_cnt                    integer;
  lv_activity_name          wf_item_activity_statuses_v.activity_name%TYPE;
  lv_result                 varchar2(100);
  ln_transaction_id         number;
  ltt_trans_obj_vers_num    hr_util_web.g_varchar2_tab_type;
  ln_trans_step_rows        NUMBER  default 0;
  ltt_trans_step_ids        hr_util_web.g_varchar2_tab_type;
  ln_transaction_step_id    hr_api_transaction_steps.transaction_step_id%TYPE;
  ln_ovn                    hr_api_transaction_steps.object_version_number%TYPE;

  -- In out params for terminate_placement
  l_object_version_number      per_periods_of_placement.object_version_number%TYPE;
  l_final_process_date         per_periods_of_placement.final_process_Date%TYPE;
  l_last_standard_process_date
               per_periods_of_placement.last_standard_process_date%TYPE;

  validate_exception        EXCEPTION;

BEGIN

  l_object_version_number := p_object_version_number;

  IF p_transaction_mode <> 'SAVE_FOR_LATER' THEN
      hr_cwk_termination_swi.terminate_placement
          (p_validate                    =>  true
          ,p_effective_date              =>  p_effective_date
          ,p_person_id                   =>  p_person_id
          ,p_date_start                  =>  p_date_start
          ,p_object_version_number       =>  l_object_version_number
          ,p_person_type_id              =>  p_person_type_id
          ,p_actual_termination_date     =>  p_actual_termination_date
          ,p_final_process_date          =>  l_final_process_date
          ,p_last_standard_process_date  =>  l_last_standard_process_date
          ,p_termination_reason          =>  p_termination_reason
          ,p_projected_termination_date  =>  p_projected_termination_date
          ,p_attribute_category          =>  p_attribute_category
          ,p_attribute1                  =>  p_attribute1
          ,p_attribute2                  =>  p_attribute2
          ,p_attribute3                  =>  p_attribute3
          ,p_attribute4                  =>  p_attribute4
          ,p_attribute5                  =>  p_attribute5
          ,p_attribute6                  =>  p_attribute6
          ,p_attribute7                  =>  p_attribute7
          ,p_attribute8                  =>  p_attribute8
          ,p_attribute9                  =>  p_attribute9
          ,p_attribute10                 =>  p_attribute10
          ,p_attribute11                 =>  p_attribute11
          ,p_attribute12                 =>  p_attribute12
          ,p_attribute13                 =>  p_attribute13
          ,p_attribute14                 =>  p_attribute14
          ,p_attribute15                 =>  p_attribute15
          ,p_attribute16                 =>  p_attribute16
          ,p_attribute17                 =>  p_attribute17
          ,p_attribute18                 =>  p_attribute18
          ,p_attribute19                 =>  p_attribute19
          ,p_attribute20                 =>  p_attribute20
          ,p_attribute21                 =>  p_attribute21
          ,p_attribute22                 =>  p_attribute22
          ,p_attribute23                 =>  p_attribute23
          ,p_attribute24                 =>  p_attribute24
          ,p_attribute25                 =>  p_attribute25
          ,p_attribute26                 =>  p_attribute26
          ,p_attribute27                 =>  p_attribute27
          ,p_attribute28                 =>  p_attribute28
          ,p_attribute29                 =>  p_attribute29
      	  ,p_attribute30	             =>  p_attribute30
          ,p_information_category        =>  p_information_category
          ,p_information1                =>  p_information1
          ,p_information2                =>  p_information2
          ,p_information3                =>  p_information3
          ,p_information4                =>  p_information4
          ,p_information5                =>  p_information5
          ,p_information6                =>  p_information6
          ,p_information7                =>  p_information7
          ,p_information8                =>  p_information8
          ,p_information9                =>  p_information9
          ,p_information10               =>  p_information10
          ,p_information11               =>  p_information11
          ,p_information12               =>  p_information12
          ,p_information13               =>  p_information13
          ,p_information14               =>  p_information14
          ,p_information15               =>  p_information15
          ,p_information16               =>  p_information16
          ,p_information17               =>  p_information17
          ,p_information18               =>  p_information18
          ,p_information19               =>  p_information19
          ,p_information20               =>  p_information20
          ,p_information21               =>  p_information21
          ,p_information22               =>  p_information22
          ,p_information23               =>  p_information23
          ,p_information24               =>  p_information24
          ,p_information25               =>  p_information25
          ,p_information26               =>  p_information26
          ,p_information27               =>  p_information27
          ,p_information28               =>  p_information28
          ,p_information29               =>  p_information29
          ,p_information30               =>  p_information30
          ,p_entries_changed_warning     =>  p_entries_changed_warning
          ,p_return_status               =>  p_return_status
          ,p_rehire_recommendation       => p_rehire_recommendation
          ,p_rehire_reason               => p_rehire_reason
      );
  END IF;
  IF p_return_status = 'E' AND p_return_on_warning = 'true' THEN
     RAISE validate_exception;
  END IF;
  ---- All validations successful, proceed and save transaction.
  lv_cnt := 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_PERSON_ID';
  lv_transaction_steps(lv_cnt).param_value := p_person_id;
  lv_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_DATE_START';
  lv_transaction_steps(lv_cnt).param_value := to_char(p_date_start, hr_transaction_ss.g_date_format);
  lv_transaction_steps(lv_cnt).param_data_type := 'DATE';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_EFFECTIVE_DATE';
  lv_transaction_steps(lv_cnt).param_value := to_char(p_effective_date, hr_transaction_ss.g_date_format);
  lv_transaction_steps(lv_cnt).param_data_type := 'DATE';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_OBJECT_VERSION_NUMBER';
  lv_transaction_steps(lv_cnt).param_value := p_object_version_number;
  lv_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_PERSON_TYPE_ID';
  lv_transaction_steps(lv_cnt).param_value := p_person_type_id;
  lv_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ACTUAL_TERMINATION_DATE';
  lv_transaction_steps(lv_cnt).param_value := to_char(p_actual_termination_date, hr_transaction_ss.g_date_format);
  lv_transaction_steps(lv_cnt).param_data_type := 'DATE';

  IF p_final_process_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    lv_transaction_steps(lv_cnt).param_name := 'P_FINAL_PROCESS_DATE';
    lv_transaction_steps(lv_cnt).param_value := to_char(p_final_process_date, hr_transaction_ss.g_date_format);
    lv_transaction_steps(lv_cnt).param_data_type := 'DATE';
  END IF;

  IF p_last_standard_process_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    lv_transaction_steps(lv_cnt).param_name := 'P_LAST_STANDARD_PROCESS_DATE';
    lv_transaction_steps(lv_cnt).param_value := to_char(p_last_standard_process_date, hr_transaction_ss.g_date_format);
    lv_transaction_steps(lv_cnt).param_data_type := 'DATE';
  END IF;

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_TERMINATION_REASON';
  lv_transaction_steps(lv_cnt).param_value := p_termination_reason;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  IF p_projected_termination_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    lv_transaction_steps(lv_cnt).param_name := 'P_PROJECTED_TERMINATION_DATE';
    lv_transaction_steps(lv_cnt).param_value := to_char(p_projected_termination_date, hr_transaction_ss.g_date_format);
    lv_transaction_steps(lv_cnt).param_data_type := 'DATE';
  END IF;

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_REHIRE_RECOMMENDATION';
  lv_transaction_steps(lv_cnt).param_value := p_rehire_recommendation;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_REHIRE_REASON';
  lv_transaction_steps(lv_cnt).param_value := p_rehire_reason;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  ------------------------------------------------------------
  -- DFF Segments
  ------------------------------------------------------------
  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE_CATEGORY';
  lv_transaction_steps(lv_cnt).param_value := p_attribute_category;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE1';
  lv_transaction_steps(lv_cnt).param_value := p_attribute1;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE2';
  lv_transaction_steps(lv_cnt).param_value := p_attribute2;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE3';
  lv_transaction_steps(lv_cnt).param_value := p_attribute3;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE4';
  lv_transaction_steps(lv_cnt).param_value := p_attribute4;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE5';
  lv_transaction_steps(lv_cnt).param_value := p_attribute5;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE6';
  lv_transaction_steps(lv_cnt).param_value := p_attribute6;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE7';
  lv_transaction_steps(lv_cnt).param_value := p_attribute7;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE8';
  lv_transaction_steps(lv_cnt).param_value := p_attribute8;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE9';
  lv_transaction_steps(lv_cnt).param_value := p_attribute9;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE10';
  lv_transaction_steps(lv_cnt).param_value := p_attribute10;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE11';
  lv_transaction_steps(lv_cnt).param_value := p_attribute11;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE12';
  lv_transaction_steps(lv_cnt).param_value := p_attribute12;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE13';
  lv_transaction_steps(lv_cnt).param_value := p_attribute13;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE14';
  lv_transaction_steps(lv_cnt).param_value := p_attribute14;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE15';
  lv_transaction_steps(lv_cnt).param_value := p_attribute15;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE16';
  lv_transaction_steps(lv_cnt).param_value := p_attribute16;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE17';
  lv_transaction_steps(lv_cnt).param_value := p_attribute17;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE18';
  lv_transaction_steps(lv_cnt).param_value := p_attribute18;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE19';
  lv_transaction_steps(lv_cnt).param_value := p_attribute19;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE20';
  lv_transaction_steps(lv_cnt).param_value := p_attribute20;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE21';
  lv_transaction_steps(lv_cnt).param_value := p_attribute21;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE22';
  lv_transaction_steps(lv_cnt).param_value := p_attribute22;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE23';
  lv_transaction_steps(lv_cnt).param_value := p_attribute23;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE24';
  lv_transaction_steps(lv_cnt).param_value := p_attribute24;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE25';
  lv_transaction_steps(lv_cnt).param_value := p_attribute25;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE26';
  lv_transaction_steps(lv_cnt).param_value := p_attribute26;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE27';
  lv_transaction_steps(lv_cnt).param_value := p_attribute27;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE28';
  lv_transaction_steps(lv_cnt).param_value := p_attribute28;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE29';
  lv_transaction_steps(lv_cnt).param_value := p_attribute29;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE30';
  lv_transaction_steps(lv_cnt).param_value := p_attribute30;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION_CATEGORY';
  lv_transaction_steps(lv_cnt).param_value := p_information_category;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION1';
  lv_transaction_steps(lv_cnt).param_value := p_information1;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION2';
  lv_transaction_steps(lv_cnt).param_value := p_information2;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION3';
  lv_transaction_steps(lv_cnt).param_value := p_information3;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION4';
  lv_transaction_steps(lv_cnt).param_value := p_information4;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION5';
  lv_transaction_steps(lv_cnt).param_value := p_information5;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION6';
  lv_transaction_steps(lv_cnt).param_value := p_information6;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION7';
  lv_transaction_steps(lv_cnt).param_value := p_information7;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION8';
  lv_transaction_steps(lv_cnt).param_value := p_information8;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION9';
  lv_transaction_steps(lv_cnt).param_value := p_information9;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION10';
  lv_transaction_steps(lv_cnt).param_value := p_information10;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION11';
  lv_transaction_steps(lv_cnt).param_value := p_information11;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION12';
  lv_transaction_steps(lv_cnt).param_value := p_information12;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION13';
  lv_transaction_steps(lv_cnt).param_value := p_information13;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION14';
  lv_transaction_steps(lv_cnt).param_value := p_information14;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION15';
  lv_transaction_steps(lv_cnt).param_value := p_information15;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION16';
  lv_transaction_steps(lv_cnt).param_value := p_information16;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION17';
  lv_transaction_steps(lv_cnt).param_value := p_information17;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION18';
  lv_transaction_steps(lv_cnt).param_value := p_information18;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION19';
  lv_transaction_steps(lv_cnt).param_value := p_information19;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION20';
  lv_transaction_steps(lv_cnt).param_value := p_information20;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

      lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION21';
  lv_transaction_steps(lv_cnt).param_value := p_information21;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION22';
  lv_transaction_steps(lv_cnt).param_value := p_information22;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION23';
  lv_transaction_steps(lv_cnt).param_value := p_information23;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION24';
  lv_transaction_steps(lv_cnt).param_value := p_information24;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION25';
  lv_transaction_steps(lv_cnt).param_value := p_information25;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION26';
  lv_transaction_steps(lv_cnt).param_value := p_information26;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION27';
  lv_transaction_steps(lv_cnt).param_value := p_information27;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION28';
  lv_transaction_steps(lv_cnt).param_value := p_information28;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION29';
  lv_transaction_steps(lv_cnt).param_value := p_information29;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_INFORMATION30';
  lv_transaction_steps(lv_cnt).param_value := p_information30;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  ----------------------------------------------------------------------
  -- Store the activity internal name for this particular
  -- activity with other information.
  ----------------------------------------------------------------------
  lv_activity_name := HR_CWK_TERMINATION_SWI.gv_TERMINATION_ACTIVITY_NAME;
  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_ACTIVITY_NAME';
  lv_transaction_steps(lv_cnt).param_value := lv_activity_name;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  ----------------------------------------------------------------------
  -- Store the the Review Procedure Call and
  -- activity id with other information.
  ----------------------------------------------------------------------
  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_REVIEW_PROC_CALL';
  IF p_review_proc_call IS NULL THEN
      lv_transaction_steps(lv_cnt).param_value
          := wf_engine.GetActivityAttrText( p_item_type,p_item_key, p_actid
                                        ,'HR_REVIEW_REGION_ITEM', False);
  ELSE
      lv_transaction_steps(lv_cnt).param_value := p_review_proc_call;
  END IF;

  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';
  lv_cnt := lv_cnt + 1;
  lv_transaction_steps(lv_cnt).param_name := 'P_REVIEW_ACTID';
  lv_transaction_steps(lv_cnt).param_value := p_actid;
  lv_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  -------------------------------------------------------------------
  -- Check if Transaction Already Exists !
  -------------------------------------------------------------------

  ln_transaction_id := hr_transaction_ss.get_transaction_id (
                            p_Item_Type => p_item_type,
                            p_Item_Key  => p_item_key
                       );
  IF ln_transaction_id IS NULL THEN
    -- Create a New Transaction
    hr_transaction_ss.start_transaction (
        itemtype                => p_item_type,
        itemkey                 => p_item_key,
        actid                   => TO_NUMBER(p_actid),
        funmode                 => 'RUN',
        p_effective_date_option => p_effective_date_option,
        p_login_person_id       => p_login_person_id,
        result                  => lv_result
    );

    ln_transaction_id := hr_transaction_ss.get_transaction_id (
                            p_Item_Type => p_item_type,
                            p_Item_Key  => p_item_key
                         );
  END IF;
  ---------------------------------------------------------------------
  -- There is already a transaction for this process.
  -- Retieve the transaction step for this current
  -- activity. We will update this transaction step with
  -- the new information.
  ---------------------------------------------------------------------

    hr_transaction_api.get_transaction_step_info(
             p_item_type                => p_item_type
            ,p_item_key                 => p_item_key
            ,p_activity_id              => to_number(p_actid)
            ,p_transaction_step_id      => ltt_trans_step_ids
            ,p_object_version_number    => ltt_trans_obj_vers_num
            ,p_rows                     => ln_trans_step_rows
         );

    IF ln_trans_step_rows < 1
    THEN
      --------------------------------------------------------------------
      -- There is no transaction step for this transaction.
      -- Create a step within this new transaction
      --------------------------------------------------------------------
      hr_transaction_api.create_transaction_step (
        p_validate              => false,
        p_creator_person_id     => p_login_person_id,
        p_transaction_id        => ln_transaction_id,
        p_api_name              => g_package || 'PROCESS_API',
        p_Item_Type             => p_item_type,
        p_Item_Key              => p_item_key,
        p_activity_id           => TO_NUMBER(p_actid),
        p_transaction_step_id   => ln_transaction_step_id,
        p_object_version_number => ln_ovn
      );
    ELSE
      --------------------------------------------------------------------
      -- There are transaction steps for this transaction.
      -- Get the Transaction Step ID for this activity.
      --------------------------------------------------------------------
      ln_transaction_step_id  :=
        hr_transaction_ss.get_activity_trans_step_id (
          p_activity_name     => lv_activity_name,
          p_trans_step_id_tbl => ltt_trans_step_ids
        );

    END IF;
    -- Save Transaction Step.

    hr_transaction_ss.save_transaction_step (
      p_item_Type           => p_item_type,
      p_item_Key            => p_item_key,
      p_actid               => TO_NUMBER(p_actid),
      p_login_person_id     => p_login_person_id,
      p_transaction_step_id => ln_transaction_step_id,
      p_api_name            => 'hr_cwk_termination_swi.process_save',
      p_transaction_data    => lv_transaction_steps
    );
EXCEPTION
WHEN validate_exception THEN
     -- Multi Messaging: Do not raise exception.
     -- The Calling Proc in Java will look at this status
     -- and retrieve all Messages
     p_return_status := hr_multi_message.get_return_status_disable;

END process_save;

PROCEDURE getTransactionDetails
(  p_transaction_step_id          in      varchar2
  ,p_person_id                    out nocopy     number
  ,p_date_start                   out nocopy     date
  ,p_object_version_number        out nocopy     number
  ,p_person_type_id               out nocopy     number
  ,p_actual_termination_date      out nocopy     date
  ,p_final_process_date           out nocopy     date
  ,p_last_standard_process_date   out nocopy     date
  ,p_termination_reason           out nocopy     varchar2
  ,p_rehire_recommendation        out nocopy     varchar2
  ,p_rehire_reason                out nocopy     varchar2
  ,p_projected_termination_date   out nocopy     date
  ,p_attribute_category           out nocopy     varchar2
  ,p_attribute1                   out nocopy     varchar2
  ,p_attribute2                   out nocopy     varchar2
  ,p_attribute3                   out nocopy     varchar2
  ,p_attribute4                   out nocopy     varchar2
  ,p_attribute5                   out nocopy     varchar2
  ,p_attribute6                   out nocopy     varchar2
  ,p_attribute7                   out nocopy     varchar2
  ,p_attribute8                   out nocopy     varchar2
  ,p_attribute9                   out nocopy     varchar2
  ,p_attribute10                  out nocopy     varchar2
  ,p_attribute11                  out nocopy     varchar2
  ,p_attribute12                  out nocopy     varchar2
  ,p_attribute13                  out nocopy     varchar2
  ,p_attribute14                  out nocopy     varchar2
  ,p_attribute15                  out nocopy     varchar2
  ,p_attribute16                  out nocopy     varchar2
  ,p_attribute17                  out nocopy     varchar2
  ,p_attribute18                  out nocopy     varchar2
  ,p_attribute19                  out nocopy     varchar2
  ,p_attribute20                  out nocopy     varchar2
  ,p_attribute21                  out nocopy     varchar2
  ,p_attribute22                  out nocopy     varchar2
  ,p_attribute23                  out nocopy     varchar2
  ,p_attribute24                  out nocopy     varchar2
  ,p_attribute25                  out nocopy     varchar2
  ,p_attribute26                  out nocopy     varchar2
  ,p_attribute27                  out nocopy     varchar2
  ,p_attribute28                  out nocopy     varchar2
  ,p_attribute29                  out nocopy     varchar2
  ,p_attribute30                  out nocopy     varchar2
  ,p_information_category         out NOCOPY     varchar2
  ,p_information1                 out nocopy     varchar2
  ,p_information2                 out nocopy     varchar2
  ,p_information3                 out nocopy     varchar2
  ,p_information4                 out nocopy     varchar2
  ,p_information5                 out nocopy     varchar2
  ,p_information6                 out nocopy     varchar2
  ,p_information7                 out nocopy     varchar2
  ,p_information8                 out nocopy     varchar2
  ,p_information9                 out nocopy     varchar2
  ,p_information10                out nocopy     varchar2
  ,p_information11                out nocopy     varchar2
  ,p_information12                out nocopy     varchar2
  ,p_information13                out nocopy     varchar2
  ,p_information14                out nocopy     varchar2
  ,p_information15                out nocopy     varchar2
  ,p_information16                out nocopy     varchar2
  ,p_information17                out nocopy     varchar2
  ,p_information18                out nocopy     varchar2
  ,p_information19                out nocopy     varchar2
  ,p_information20                out nocopy     varchar2
  ,p_information21                out nocopy     varchar2
  ,p_information22                out nocopy     varchar2
  ,p_information23                out nocopy     varchar2
  ,p_information24                out nocopy     varchar2
  ,p_information25                out nocopy     varchar2
  ,p_information26                out nocopy     varchar2
  ,p_information27                out nocopy     varchar2
  ,p_information28                out nocopy     varchar2
  ,p_information29                out nocopy     varchar2
  ,p_information30                out nocopy     varchar2
) IS

l_proc    varchar2(72) := g_package ||'getTransactionDetails';

BEGIN

hr_utility.set_location(' Entering:' || l_proc, 5);
  --
    p_person_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_ID');
  --
    p_date_start :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_DATE_START');
  --
    p_object_version_number :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  --
    p_person_type_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_TYPE_ID');
  --
--    p_assignment_status_type_id :=
--      hr_transaction_api.get_number_value
--      (p_transaction_step_id => p_transaction_step_id
--      ,p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID');
  --
    p_actual_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ACTUAL_TERMINATION_DATE');
  --
    p_final_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_FINAL_PROCESS_DATE');
  --
    p_last_standard_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_LAST_STANDARD_PROCESS_DATE');
  --
    p_termination_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_TERMINATION_REASON');
  --
    p_rehire_recommendation :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_RECOMMENDATION');
  --
    p_rehire_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_REASON');
  --
    p_projected_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PROJECTED_TERMINATION_DATE');
  --
    p_attribute_category :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE_CATEGORY');
  --
    p_attribute1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE1');
  --
    p_attribute2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE2');
  --
    p_attribute3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE3');
  --
    p_attribute4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE4');
  --
    p_attribute5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE5');
  --
    p_attribute6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE6');
  --
    p_attribute7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE7');
  --
    p_attribute8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE8');
  --
    p_attribute9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE9');
  --
    p_attribute10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE10');
  --
    p_attribute11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE11');
  --
    p_attribute12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE12');
  --
    p_attribute13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE13');
  --
    p_attribute14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE14');
  --
    p_attribute15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE15');
  --
    p_attribute16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE16');
  --
    p_attribute17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE17');
  --
    p_attribute18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE18');
  --
    p_attribute19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE19');
  --
    p_attribute20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE20');
  --
    p_attribute21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE21');
  --
    p_attribute22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE22');
  --
    p_attribute23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE23');
  --
    p_attribute24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE24');
  --
    p_attribute25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE25');
  --
    p_attribute26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE26');
  --
    p_attribute27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE27');
  --
    p_attribute28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE28');
  --
    p_attribute29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE29');
  --
    p_attribute30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE30');
  --
    p_information_category :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION_CATEGORY');
  --
    p_information1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION1');
  --
    p_information2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION2');
  --
    p_information3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION3');
  --
    p_information4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION4');
  --
    p_information5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION5');
  --
    p_information6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION6');
  --
    p_information7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION7');
  --
    p_information8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION8');
  --
    p_information9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION9');
  --
    p_information10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION10');
  --
    p_information11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION11');
  --
    p_information12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION12');
  --
    p_information13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION13');
  --
    p_information14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION14');
  --
    p_information15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION15');
  --
    p_information16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION16');
  --
    p_information17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION17');
  --
    p_information18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION18');
  --
    p_information19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION19');
  --
    p_information20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION20');

  --
    p_information21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION21');
  --
    p_information22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION22');
  --
    p_information23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION23');
  --
    p_information24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION24');
  --
    p_information25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION25');
  --
    p_information26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION26');
  --
    p_information27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION27');
  --
    p_information28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION28');
  --
    p_information29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION29');
  --
    p_information30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION30');

hr_utility.set_location(' Leaving:' || l_proc, 10);

END getTransactionDetails;

procedure process_api
(    p_validate			  in	boolean  default false
    ,p_transaction_step_id	  in	number   default null
    ,p_effective_date		  in	varchar2 default NULL
) IS

/*l_person_id                    VARCHAR2(100);
l_date_start                   VARCHAR2(100);
l_object_version_number        VARCHAR2(100);
l_person_type_id               VARCHAR2(100);
l_actual_termination_date      VARCHAR2(100);
l_final_process_date           VARCHAR2(100);
l_last_standard_process_date   VARCHAR2(100);*/
/*l_projected_termination_date   VARCHAR2(100);*/

l_attribute_category   per_periods_of_placement.attribute_category%TYPE;
l_attribute1                   per_periods_of_placement.attribute1%TYPE;
l_attribute2                   per_periods_of_placement.attribute2%TYPE;
l_attribute3                   per_periods_of_placement.attribute3%TYPE;
l_attribute4                   per_periods_of_placement.attribute4%TYPE;
l_attribute5                   per_periods_of_placement.attribute5%TYPE;
l_attribute6                   per_periods_of_placement.attribute6%TYPE;
l_attribute7                   per_periods_of_placement.attribute7%TYPE;
l_attribute8                   per_periods_of_placement.attribute8%TYPE;
l_attribute9                   per_periods_of_placement.attribute9%TYPE;
l_attribute10                  per_periods_of_placement.attribute10%TYPE;
l_attribute11                  per_periods_of_placement.attribute11%TYPE;
l_attribute12                  per_periods_of_placement.attribute12%TYPE;
l_attribute13                  per_periods_of_placement.attribute13%TYPE;
l_attribute14                  per_periods_of_placement.attribute14%TYPE;
l_attribute15                  per_periods_of_placement.attribute15%TYPE;
l_attribute16                  per_periods_of_placement.attribute16%TYPE;
l_attribute17                  per_periods_of_placement.attribute17%TYPE;
l_attribute18                  per_periods_of_placement.attribute18%TYPE;
l_attribute19                  per_periods_of_placement.attribute19%TYPE;
l_attribute20                  per_periods_of_placement.attribute20%TYPE;
l_attribute21                  per_periods_of_placement.attribute21%TYPE;
l_attribute22                  per_periods_of_placement.attribute22%TYPE;
l_attribute23                  per_periods_of_placement.attribute23%TYPE;
l_attribute24                  per_periods_of_placement.attribute24%TYPE;
l_attribute25                  per_periods_of_placement.attribute25%TYPE;
l_attribute26                  per_periods_of_placement.attribute26%TYPE;
l_attribute27                  per_periods_of_placement.attribute27%TYPE;
l_attribute28                  per_periods_of_placement.attribute28%TYPE;
l_attribute29                  per_periods_of_placement.attribute29%TYPE;
l_attribute30                  per_periods_of_placement.attribute30%TYPE;

l_information_category    per_periods_of_placement.information_category%TYPE;
l_information1                 per_periods_of_placement.information1%TYPE;
l_information2                 per_periods_of_placement.information2%TYPE;
l_information3                 per_periods_of_placement.information3%TYPE;
l_information4                 per_periods_of_placement.information4%TYPE;
l_information5                 per_periods_of_placement.information5%TYPE;
l_information6                 per_periods_of_placement.information6%TYPE;
l_information7                 per_periods_of_placement.information7%TYPE;
l_information8                 per_periods_of_placement.information8%TYPE;
l_information9                 per_periods_of_placement.information9%TYPE;
l_information10                per_periods_of_placement.information10%TYPE;
l_information11                per_periods_of_placement.information11%TYPE;
l_information12                per_periods_of_placement.information12%TYPE;
l_information13                per_periods_of_placement.information13%TYPE;
l_information14                per_periods_of_placement.information14%TYPE;
l_information15                per_periods_of_placement.information15%TYPE;
l_information16                per_periods_of_placement.information16%TYPE;
l_information17                per_periods_of_placement.information17%TYPE;
l_information18                per_periods_of_placement.information18%TYPE;
l_information19                per_periods_of_placement.information19%TYPE;
l_information20                per_periods_of_placement.information20%TYPE;
l_information21                per_periods_of_placement.information21%TYPE;
l_information22                per_periods_of_placement.information22%TYPE;
l_information23                per_periods_of_placement.information23%TYPE;
l_information24                per_periods_of_placement.information24%TYPE;
l_information25                per_periods_of_placement.information25%TYPE;
l_information26                per_periods_of_placement.information26%TYPE;
l_information27                per_periods_of_placement.information27%TYPE;
l_information28                per_periods_of_placement.information28%TYPE;
l_information29                per_periods_of_placement.information29%TYPE;
l_information30                per_periods_of_placement.information30%TYPE;

l_entries_changed_warning      VARCHAR2(30);
l_return_status                VARCHAR2(30);

l_person_id                    per_periods_of_placement.person_id%TYPE;
l_date_start                   per_periods_of_placement.date_start%TYPE;
l_object_version_number        per_periods_of_placement.object_version_number%TYPE;
l_person_type_id               per_all_people_f.person_type_id%TYPE;
l_actual_termination_date      per_periods_of_placement.actual_termination_date%TYPE;
l_final_process_date           per_periods_of_placement.final_process_date%TYPE;
l_last_standard_process_date   per_periods_of_placement.last_standard_process_date%TYPE;
l_projected_termination_date   per_periods_of_placement.projected_termination_date%TYPE;
l_termination_reason           per_periods_of_placement.termination_reason%TYPE;
l_rehire_recommendation        per_all_people_f.rehire_recommendation%TYPE;
l_rehire_reason                per_all_people_f.rehire_reason%TYPE;

l_proc    varchar2(72) := g_package ||'process_api';
l_effective_date	    date;

BEGIN

hr_utility.set_location(' Entering:' || l_proc, 5);

hr_cwk_termination_swi.getTransactionDetails
(  p_transaction_step_id              =>  p_transaction_step_id
  ,p_person_id                   	    =>  l_person_id
  ,p_date_start                  	    =>  l_date_start
  ,p_object_version_number       	    =>  l_object_version_number
  ,p_person_type_id              	    =>  l_person_type_id
  ,p_actual_termination_date     	    =>  l_actual_termination_date
  ,p_final_process_date          	    =>  l_final_process_date
  ,p_last_standard_process_date  	    =>  l_last_standard_process_date
  ,p_termination_reason          	    =>  l_termination_reason
  ,p_rehire_recommendation              =>  l_rehire_recommendation
  ,p_rehire_reason                      =>  l_rehire_reason
  ,p_projected_termination_date  	    =>  l_projected_termination_date
  ,p_attribute_category          	    =>  l_attribute_category
  ,p_attribute1                  	    =>  l_attribute1
  ,p_attribute2                  	    =>  l_attribute2
  ,p_attribute3                  	    =>  l_attribute3
  ,p_attribute4                  	    =>  l_attribute4
  ,p_attribute5                  	    =>  l_attribute5
  ,p_attribute6                  	    =>  l_attribute6
  ,p_attribute7                  	    =>  l_attribute7
  ,p_attribute8                  	    =>  l_attribute8
  ,p_attribute9                  	    =>  l_attribute9
  ,p_attribute10                 	    =>  l_attribute10
  ,p_attribute11                 	    =>  l_attribute11
  ,p_attribute12                 	    =>  l_attribute12
  ,p_attribute13                 	    =>  l_attribute13
  ,p_attribute14                 	    =>  l_attribute14
  ,p_attribute15                 	    =>  l_attribute15
  ,p_attribute16                 	    =>  l_attribute16
  ,p_attribute17                 	    =>  l_attribute17
  ,p_attribute18                 	    =>  l_attribute18
  ,p_attribute19                 	    =>  l_attribute19
  ,p_attribute20                 	    =>  l_attribute20
  ,p_attribute21                 	    =>  l_attribute21
  ,p_attribute22                 	    =>  l_attribute22
  ,p_attribute23                 	    =>  l_attribute23
  ,p_attribute24                 	    =>  l_attribute24
  ,p_attribute25                 	    =>  l_attribute25
  ,p_attribute26                 	    =>  l_attribute26
  ,p_attribute27                 	    =>  l_attribute27
  ,p_attribute28                 	    =>  l_attribute28
  ,p_attribute29                 	    =>  l_attribute29
  ,p_attribute30                 	    =>  l_attribute30
  ,p_information_category               =>  l_information_category
  ,p_information1                       =>  l_information1
  ,p_information2                       =>  l_information2
  ,p_information3                       =>  l_information3
  ,p_information4                       =>  l_information4
  ,p_information5                       =>  l_information5
  ,p_information6                       =>  l_information6
  ,p_information7                       =>  l_information7
  ,p_information8                       =>  l_information8
  ,p_information9                       =>  l_information9
  ,p_information10                      =>  l_information10
  ,p_information11                      =>  l_information11
  ,p_information12                      =>  l_information12
  ,p_information13                      =>  l_information13
  ,p_information14                      =>  l_information14
  ,p_information15                      =>  l_information15
  ,p_information16                      =>  l_information16
  ,p_information17                      =>  l_information17
  ,p_information18                      =>  l_information18
  ,p_information19                      =>  l_information19
  ,p_information20                      =>  l_information20
  ,p_information21                      =>  l_information21
  ,p_information22                      =>  l_information22
  ,p_information23                      =>  l_information23
  ,p_information24                      =>  l_information24
  ,p_information25                      =>  l_information25
  ,p_information26                      =>  l_information26
  ,p_information27                      =>  l_information27
  ,p_information28                      =>  l_information28
  ,p_information29                      =>  l_information29
  ,p_information30                      =>  l_information30
);

/*person_id                    :=  to_number(l_person_id);
object_version_number        :=	 to_number(l_object_version_number);
person_type_id               :=	 to_number(l_person_type_id);
date_start :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_DATE_START');
actual_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ACTUAL_TERMINATION_DATE');
final_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_FINAL_PROCESS_DATE');
last_standard_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_LAST_STANDARD_PROCESS_DATE');
projected_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PROJECTED_TERMINATION_DATE');
*/
l_effective_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_EFFECTIVE_DATE');


hr_cwk_termination_swi.terminate_placement
    (p_validate                    =>  false
    ,p_effective_date              =>  l_effective_date
    ,p_person_id                   =>  l_person_id
    ,p_date_start                  =>  l_date_start
    ,p_object_version_number       =>  l_object_version_number
    ,p_person_type_id              =>  l_person_type_id
    ,p_actual_termination_date     =>  l_actual_termination_date
    ,p_final_process_date          =>  l_final_process_date
    ,p_last_standard_process_date  =>  l_last_standard_process_date
    ,p_termination_reason          =>  l_termination_reason
    ,p_projected_termination_date  =>  l_projected_termination_date
    ,p_rehire_recommendation       =>  l_rehire_recommendation
    ,p_rehire_reason               =>  l_rehire_reason
    ,p_attribute_category          =>  l_attribute_category
    ,p_attribute1                  =>  l_attribute1
    ,p_attribute2                  =>  l_attribute2
    ,p_attribute3                  =>  l_attribute3
    ,p_attribute4                  =>  l_attribute4
    ,p_attribute5                  =>  l_attribute5
    ,p_attribute6                  =>  l_attribute6
    ,p_attribute7                  =>  l_attribute7
    ,p_attribute8                  =>  l_attribute8
    ,p_attribute9                  =>  l_attribute9
    ,p_attribute10                 =>  l_attribute10
    ,p_attribute11                 =>  l_attribute11
    ,p_attribute12                 =>  l_attribute12
    ,p_attribute13                 =>  l_attribute13
    ,p_attribute14                 =>  l_attribute14
    ,p_attribute15                 =>  l_attribute15
    ,p_attribute16                 =>  l_attribute16
    ,p_attribute17                 =>  l_attribute17
    ,p_attribute18                 =>  l_attribute18
    ,p_attribute19                 =>  l_attribute19
    ,p_attribute20                 =>  l_attribute20
    ,p_attribute21                 =>  l_attribute21
    ,p_attribute22                 =>  l_attribute22
    ,p_attribute23                 =>  l_attribute23
    ,p_attribute24                 =>  l_attribute24
    ,p_attribute25                 =>  l_attribute25
    ,p_attribute26                 =>  l_attribute26
    ,p_attribute27                 =>  l_attribute27
    ,p_attribute28                 =>  l_attribute28
    ,p_attribute29                 =>  l_attribute29
    ,p_attribute30	           =>  l_attribute30
    ,p_entries_changed_warning     =>  l_entries_changed_warning
    ,p_return_status               =>  l_return_status
);

if l_return_status = 'E' then
	raise hr_multi_message.error_message_exist;
end if;
hr_utility.set_location(' Leaving:' || l_proc, 10);
END;

end hr_cwk_termination_swi;

/
