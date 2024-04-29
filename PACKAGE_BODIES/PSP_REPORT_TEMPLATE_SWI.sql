--------------------------------------------------------
--  DDL for Package Body PSP_REPORT_TEMPLATE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_REPORT_TEMPLATE_SWI" As
/* $Header: PSPRTSWB.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'psp_report_template_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_report_template >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_report_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_template_name                in     varchar2
  ,p_business_group_id            in     number
  ,p_set_of_books_id              in     number
  ,p_report_type                  in     varchar2
  ,p_period_frequency_id          in     number
  ,p_report_template_code         in     varchar2
  ,p_display_all_emp_distrib_flag in     varchar2
  ,p_manual_entry_override_flag   in     varchar2
  ,p_approval_type                in     varchar2
  ,p_sup_levels                   in     number
  ,p_preview_effort_report_flag   in     varchar2
  ,p_notification_reminder        in     number
  ,p_sprcd_tolerance_amt          in     number
  ,p_sprcd_tolerance_percent      in     number
  ,p_description                  in     varchar2
  ,p_egislation_code              in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_custom_approval_code         in     varchar2
  ,p_hundred_pcent_eff_at_per_asg in     varchar2
  ,p_selection_match_level        in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_warning                       boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_template_id                  number;
  l_proc    varchar2(72) := g_package ||'create_report_template';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_report_template_swi;
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
  psp_prt_ins.set_base_key_value
    (p_template_id => p_template_id
    );
  --
  -- Call API
  --
  psp_report_template_api.create_report_template
    (p_validate                     => l_validate
    ,p_template_id                  => l_template_id
    ,p_template_name                => p_template_name
    ,p_business_group_id            => p_business_group_id
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_report_type                  => p_report_type
    ,p_period_frequency_id          => p_period_frequency_id
    ,p_report_template_code         => p_report_template_code
    ,p_display_all_emp_distrib_flag => p_display_all_emp_distrib_flag
    ,p_manual_entry_override_flag   => p_manual_entry_override_flag
    ,p_approval_type                => p_approval_type
    ,p_sup_levels                   => p_sup_levels
    ,p_preview_effort_report_flag   => p_preview_effort_report_flag
    ,p_notification_reminder        => p_notification_reminder
    ,p_sprcd_tolerance_amt          => p_sprcd_tolerance_amt
    ,p_sprcd_tolerance_percent      => p_sprcd_tolerance_percent
    ,p_description                  => p_description
    ,p_egislation_code              => p_egislation_code
    ,p_object_version_number        => p_object_version_number
    ,p_warning                      => l_warning
    ,p_return_status                => l_return_status
    ,p_custom_approval_code         => p_custom_approval_code
    ,p_hundred_pcent_eff_at_per_asg => p_hundred_pcent_eff_at_per_asg
    ,p_selection_match_level        => p_selection_match_level
    );
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
    rollback to create_report_template_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_report_template_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_report_template;
-- ----------------------------------------------------------------------------
-- |------------------------< update_report_template >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_report_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_template_name                in     varchar2
  ,p_business_group_id            in     number
  ,p_set_of_books_id              in     number
  ,p_report_type                  in     varchar2
  ,p_period_frequency_id          in     number
  ,p_report_template_code         in     varchar2
  ,p_display_all_emp_distrib_flag in     varchar2
  ,p_manual_entry_override_flag   in     varchar2
  ,p_approval_type                in     varchar2
  ,p_sup_levels                   in     number
  ,p_preview_effort_report_flag   in     varchar2
  ,p_notification_reminder        in     number
  ,p_sprcd_tolerance_amt          in     number
  ,p_sprcd_tolerance_percent      in     number
  ,p_description                  in     varchar2
  ,p_egislation_code              in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_custom_approval_code         in     varchar2
  ,p_hundred_pcent_eff_at_per_asg in     varchar2
  ,p_selection_match_level        in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_warning                       boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_report_template';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_report_template_swi;
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
  psp_report_template_api.update_report_template
    (p_validate                     => l_validate
    ,p_template_id                  => p_template_id
    ,p_template_name                => p_template_name
    ,p_business_group_id            => p_business_group_id
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_report_type                  => p_report_type
    ,p_period_frequency_id          => p_period_frequency_id
    ,p_report_template_code         => p_report_template_code
    ,p_display_all_emp_distrib_flag => p_display_all_emp_distrib_flag
    ,p_manual_entry_override_flag   => p_manual_entry_override_flag
    ,p_approval_type                => p_approval_type
    ,p_sup_levels                   => p_sup_levels
    ,p_preview_effort_report_flag   => p_preview_effort_report_flag
    ,p_notification_reminder        => p_notification_reminder
    ,p_sprcd_tolerance_amt          => p_sprcd_tolerance_amt
    ,p_sprcd_tolerance_percent      => p_sprcd_tolerance_percent
    ,p_description                  => p_description
    ,p_egislation_code              => p_egislation_code
    ,p_object_version_number        => p_object_version_number
    ,p_warning                      => l_warning
    ,p_return_status                => l_return_status
    ,p_custom_approval_code         => p_custom_approval_code
    ,p_hundred_pcent_eff_at_per_asg => p_hundred_pcent_eff_at_per_asg
    ,p_selection_match_level        => p_selection_match_level
    );
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
    rollback to update_report_template_swi;
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
    rollback to update_report_template_swi;
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
end update_report_template;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_report_template >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_report_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_warning                         out nocopy varchar2
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
  l_proc    varchar2(72) := g_package ||'delete_report_template';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_report_template_swi;
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
  psp_report_template_api.delete_report_template
    (p_validate                     => l_validate
    ,p_template_id                  => p_template_id
    ,p_object_version_number        => p_object_version_number
    ,p_warning                      => p_warning
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
    rollback to delete_report_template_swi;
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
    rollback to delete_report_template_swi;
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
end delete_report_template;
end psp_report_template_swi;

/
