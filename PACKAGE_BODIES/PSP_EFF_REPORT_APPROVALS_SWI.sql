--------------------------------------------------------
--  DDL for Package Body PSP_EFF_REPORT_APPROVALS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFF_REPORT_APPROVALS_SWI" As
/* $Header: PSPEASWB.pls 120.3 2006/03/26 01:11 dpaudel noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'psp_eff_report_approvals_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_eff_report_approvals >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_eff_report_approvals
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effort_report_approval_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_eff_report_approvals';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eff_report_approval_swi;
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
  l_return_status :=
    hr_api.constant_to_boolean
      (p_constant_value => p_return_status);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  psp_eff_report_approvals_api.delete_eff_report_approvals
    (p_validate                     => l_validate
    ,p_effort_report_approval_id    => p_effort_report_approval_id
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_return_status :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_return_status
      );
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
    rollback to delete_eff_report_approval_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
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
    rollback to delete_eff_report_approval_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_eff_report_approvals;
-- ----------------------------------------------------------------------------
-- |----------------------< insert_eff_report_approvals >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_eff_report_approvals
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effort_report_detail_id      in     number
  ,p_wf_role_name                 in     varchar2
  ,p_wf_orig_system_id            in     number
  ,p_wf_orig_system               in     varchar2
  ,p_approver_order_num           in     number
  ,p_approval_status              in     varchar2
  ,p_response_date                in     date
  ,p_actual_cost_share            in     number
  ,p_overwritten_effort_percent   in     number
  ,p_wf_item_key                  in     varchar2
  ,p_comments                     in     varchar2
  ,p_pera_information_category    in     varchar2
  ,p_pera_information1            in     varchar2
  ,p_pera_information2            in     varchar2
  ,p_pera_information3            in     varchar2
  ,p_pera_information4            in     varchar2
  ,p_pera_information5            in     varchar2
  ,p_pera_information6            in     varchar2
  ,p_pera_information7            in     varchar2
  ,p_pera_information8            in     varchar2
  ,p_pera_information9            in     varchar2
  ,p_pera_information10           in     varchar2
  ,p_pera_information11           in     varchar2
  ,p_pera_information12           in     varchar2
  ,p_pera_information13           in     varchar2
  ,p_pera_information14           in     varchar2
  ,p_pera_information15           in     varchar2
  ,p_pera_information16           in     varchar2
  ,p_pera_information17           in     varchar2
  ,p_pera_information18           in     varchar2
  ,p_pera_information19           in     varchar2
  ,p_pera_information20           in     varchar2
  ,p_wf_role_display_name         in     varchar2
  ,p_eff_information_category     in     varchar2
  ,p_eff_information1             in     varchar2
  ,p_eff_information2             in     varchar2
  ,p_eff_information3             in     varchar2
  ,p_eff_information4             in     varchar2
  ,p_eff_information5             in     varchar2
  ,p_eff_information6             in     varchar2
  ,p_eff_information7             in     varchar2
  ,p_eff_information8             in     varchar2
  ,p_eff_information9             in     varchar2
  ,p_eff_information10            in     varchar2
  ,p_eff_information11            in     varchar2
  ,p_eff_information12            in     varchar2
  ,p_eff_information13            in     varchar2
  ,p_eff_information14            in     varchar2
  ,p_eff_information15            in     varchar2
  ,p_effort_report_approval_id       out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'insert_eff_report_approvals';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_eff_report_approval_swi;
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
  l_return_status :=
    hr_api.constant_to_boolean
      (p_constant_value => p_return_status);
  --
  -- Register Surrogate ID or user key values
  --
  psp_era_ins.set_base_key_value
    (p_effort_report_approval_id => p_effort_report_approval_id
    );
  --
  -- Call API
  --
  psp_eff_report_approvals_api.insert_eff_report_approvals
    (p_validate                     => l_validate
    ,p_effort_report_detail_id      => p_effort_report_detail_id
    ,p_wf_role_name                 => p_wf_role_name
    ,p_wf_orig_system_id            => p_wf_orig_system_id
    ,p_wf_orig_system               => p_wf_orig_system
    ,p_approver_order_num           => p_approver_order_num
    ,p_approval_status              => p_approval_status
    ,p_response_date                => p_response_date
    ,p_actual_cost_share            => p_actual_cost_share
    ,p_overwritten_effort_percent   => p_overwritten_effort_percent
    ,p_wf_item_key                  => p_wf_item_key
    ,p_comments                     => p_comments
    ,p_pera_information_category    => p_pera_information_category
    ,p_pera_information1            => p_pera_information1
    ,p_pera_information2            => p_pera_information2
    ,p_pera_information3            => p_pera_information3
    ,p_pera_information4            => p_pera_information4
    ,p_pera_information5            => p_pera_information5
    ,p_pera_information6            => p_pera_information6
    ,p_pera_information7            => p_pera_information7
    ,p_pera_information8            => p_pera_information8
    ,p_pera_information9            => p_pera_information9
    ,p_pera_information10           => p_pera_information10
    ,p_pera_information11           => p_pera_information11
    ,p_pera_information12           => p_pera_information12
    ,p_pera_information13           => p_pera_information13
    ,p_pera_information14           => p_pera_information14
    ,p_pera_information15           => p_pera_information15
    ,p_pera_information16           => p_pera_information16
    ,p_pera_information17           => p_pera_information17
    ,p_pera_information18           => p_pera_information18
    ,p_pera_information19           => p_pera_information19
    ,p_pera_information20           => p_pera_information20
    ,p_wf_role_display_name         => p_wf_role_display_name
    ,p_eff_information_category     => p_eff_information_category
    ,p_eff_information1             => p_eff_information1
    ,p_eff_information2             => p_eff_information2
    ,p_eff_information3             => p_eff_information3
    ,p_eff_information4             => p_eff_information4
    ,p_eff_information5             => p_eff_information5
    ,p_eff_information6             => p_eff_information6
    ,p_eff_information7             => p_eff_information7
    ,p_eff_information8             => p_eff_information8
    ,p_eff_information9             => p_eff_information9
    ,p_eff_information10            => p_eff_information10
    ,p_eff_information11            => p_eff_information11
    ,p_eff_information12            => p_eff_information12
    ,p_eff_information13            => p_eff_information13
    ,p_eff_information14            => p_eff_information14
    ,p_eff_information15            => p_eff_information15
    ,p_effort_report_approval_id    => p_effort_report_approval_id
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_return_status :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_return_status
      );
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
    rollback to insert_eff_report_approval_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effort_report_approval_id    := null;
    p_object_version_number        := null;
    p_return_status                := null;
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
    rollback to insert_eff_report_approval_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_effort_report_approval_id    := null;
    p_object_version_number        := null;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_eff_report_approvals;
-- ----------------------------------------------------------------------------
-- |----------------------< update_eff_report_approvals >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_eff_report_approvals
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effort_report_approval_id    in     number
  ,p_effort_report_detail_id      in     number    default hr_api.g_number
  ,p_wf_role_name                 in     varchar2  default hr_api.g_varchar2
  ,p_wf_orig_system_id            in     number    default hr_api.g_number
  ,p_wf_orig_system               in     varchar2  default hr_api.g_varchar2
  ,p_approver_order_num           in     number    default hr_api.g_number
  ,p_approval_status              in     varchar2  default hr_api.g_varchar2
  ,p_response_date                in     date      default hr_api.g_date
  ,p_actual_cost_share            in     number    default hr_api.g_number
  ,p_overwritten_effort_percent   in     number    default hr_api.g_number
  ,p_wf_item_key                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_pera_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_pera_information1            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information2            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information3            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information4            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information5            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information6            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information7            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information8            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information9            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information10           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information11           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information12           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information13           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information14           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information15           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information16           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information17           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information18           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information19           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information20           in     varchar2  default hr_api.g_varchar2
  ,p_wf_role_display_name         in     varchar2  default hr_api.g_varchar2
  ,p_eff_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eff_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information15            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eff_report_approvals';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eff_report_approval_swi;
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
  l_return_status :=
    hr_api.constant_to_boolean
      (p_constant_value => p_return_status);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  psp_eff_report_approvals_api.update_eff_report_approvals
    (p_validate                     => l_validate
    ,p_effort_report_approval_id    => p_effort_report_approval_id
    ,p_effort_report_detail_id      => p_effort_report_detail_id
    ,p_wf_role_name                 => p_wf_role_name
    ,p_wf_orig_system_id            => p_wf_orig_system_id
    ,p_wf_orig_system               => p_wf_orig_system
    ,p_approver_order_num           => p_approver_order_num
    ,p_approval_status              => p_approval_status
    ,p_response_date                => p_response_date
    ,p_actual_cost_share            => p_actual_cost_share
    ,p_overwritten_effort_percent   => p_overwritten_effort_percent
    ,p_wf_item_key                  => p_wf_item_key
    ,p_comments                     => p_comments
    ,p_pera_information_category    => p_pera_information_category
    ,p_pera_information1            => p_pera_information1
    ,p_pera_information2            => p_pera_information2
    ,p_pera_information3            => p_pera_information3
    ,p_pera_information4            => p_pera_information4
    ,p_pera_information5            => p_pera_information5
    ,p_pera_information6            => p_pera_information6
    ,p_pera_information7            => p_pera_information7
    ,p_pera_information8            => p_pera_information8
    ,p_pera_information9            => p_pera_information9
    ,p_pera_information10           => p_pera_information10
    ,p_pera_information11           => p_pera_information11
    ,p_pera_information12           => p_pera_information12
    ,p_pera_information13           => p_pera_information13
    ,p_pera_information14           => p_pera_information14
    ,p_pera_information15           => p_pera_information15
    ,p_pera_information16           => p_pera_information16
    ,p_pera_information17           => p_pera_information17
    ,p_pera_information18           => p_pera_information18
    ,p_pera_information19           => p_pera_information19
    ,p_pera_information20           => p_pera_information20
    ,p_wf_role_display_name         => p_wf_role_display_name
    ,p_eff_information_category     => p_eff_information_category
    ,p_eff_information1             => p_eff_information1
    ,p_eff_information2             => p_eff_information2
    ,p_eff_information3             => p_eff_information3
    ,p_eff_information4             => p_eff_information4
    ,p_eff_information5             => p_eff_information5
    ,p_eff_information6             => p_eff_information6
    ,p_eff_information7             => p_eff_information7
    ,p_eff_information8             => p_eff_information8
    ,p_eff_information9             => p_eff_information9
    ,p_eff_information10            => p_eff_information10
    ,p_eff_information11            => p_eff_information11
    ,p_eff_information12            => p_eff_information12
    ,p_eff_information13            => p_eff_information13
    ,p_eff_information14            => p_eff_information14
    ,p_eff_information15            => p_eff_information15
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_return_status :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_return_status
      );
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
    rollback to update_eff_report_approval_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
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
    rollback to update_eff_report_approval_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_eff_report_approvals;
end psp_eff_report_approvals_swi;

/
