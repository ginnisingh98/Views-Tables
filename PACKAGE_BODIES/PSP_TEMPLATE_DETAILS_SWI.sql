--------------------------------------------------------
--  DDL for Package Body PSP_TEMPLATE_DETAILS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_TEMPLATE_DETAILS_SWI" As
/* $Header: PSPRDSWB.pls 120.0 2005/06/02 15:41 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'psp_template_details_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_template_details >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_template_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_criteria_lookup_type         in     varchar2
  ,p_criteria_lookup_code         in     varchar2
  ,p_include_exclude_flag         in     varchar2
  ,p_criteria_value1              in     varchar2
  ,p_criteria_value2              in     varchar2
  ,p_criteria_value3              in     varchar2
  ,p_template_detail_id           in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status_from_api          out nocopy number
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
  l_template_detail_id           number;
  l_proc    varchar2(72) := g_package ||'create_template_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_details_swi;
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
  psp_rtd_ins.set_base_key_value
    (p_template_detail_id => p_template_detail_id
    );
  --
  -- Call API
  --
  psp_template_details_api.create_template_details
    (p_validate                     => l_validate
    ,p_template_id                  => p_template_id
    ,p_criteria_lookup_type         => p_criteria_lookup_type
    ,p_criteria_lookup_code         => p_criteria_lookup_code
    ,p_include_exclude_flag         => p_include_exclude_flag
    ,p_criteria_value1              => p_criteria_value1
    ,p_criteria_value2              => p_criteria_value2
    ,p_criteria_value3              => p_criteria_value3
    ,p_template_detail_id           => l_template_detail_id
    ,p_object_version_number        => p_object_version_number
    ,p_warning                      => l_warning
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_warning then
     fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to create_template_details_swi;
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
    rollback to create_template_details_swi;
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
end create_template_details;
-- ----------------------------------------------------------------------------
-- |------------------------< update_template_details >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_template_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_criteria_lookup_type         in     varchar2
  ,p_criteria_lookup_code         in     varchar2
  ,p_include_exclude_flag         in     varchar2
  ,p_criteria_value1              in     varchar2
  ,p_criteria_value2              in     varchar2
  ,p_criteria_value3              in     varchar2
  ,p_template_detail_id           in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_warning                       boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_template_detail_id            number;
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_template_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_details_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_template_detail_id            := p_template_detail_id;
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
  psp_template_details_api.update_template_details
    (p_validate                     => l_validate
    ,p_template_id                  => p_template_id
    ,p_criteria_lookup_type         => p_criteria_lookup_type
    ,p_criteria_lookup_code         => p_criteria_lookup_code
    ,p_include_exclude_flag         => p_include_exclude_flag
    ,p_criteria_value1              => p_criteria_value1
    ,p_criteria_value2              => p_criteria_value2
    ,p_criteria_value3              => p_criteria_value3
    ,p_template_detail_id           => p_template_detail_id
    ,p_object_version_number        => p_object_version_number
    ,p_warning                      => l_warning
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_warning then
     fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to update_template_details_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_template_detail_id           := l_template_detail_id;
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
    rollback to update_template_details_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_template_detail_id           := l_template_detail_id;
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_template_details;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_template_details >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_template_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_detail_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_template_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_details_swi;
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
  psp_template_details_api.delete_template_details
    (p_validate                     => l_validate
    ,p_template_detail_id           => p_template_detail_id
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
    rollback to delete_template_details_swi;
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
    rollback to delete_template_details_swi;
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
end delete_template_details;
end psp_template_details_swi;

/
