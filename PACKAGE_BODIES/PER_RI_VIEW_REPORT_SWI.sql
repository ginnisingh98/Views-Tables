--------------------------------------------------------
--  DDL for Package Body PER_RI_VIEW_REPORT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_VIEW_REPORT_SWI" As
/* $Header: pervrswi.pkb 120.0 2005/05/31 20:29:24 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_ri_view_report_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_view_report >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_view_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_view_report_code   in     varchar2
  ,p_workbench_view_report_name   in     varchar2
  ,p_wb_view_report_description   in     varchar2
  ,p_workbench_item_code          in     varchar2
  ,p_workbench_view_report_type   in     varchar2
  ,p_workbench_view_report_action in     varchar2
  ,p_workbench_view_country       in     varchar2
  ,p_wb_view_report_instruction   in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_primary_industry		  in	 varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_view_report';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_view_report_swi;
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
  per_ri_view_report_api.create_view_report
    (p_validate                     => l_validate
    ,p_workbench_view_report_code   => p_workbench_view_report_code
    ,p_workbench_view_report_name   => p_workbench_view_report_name
    ,p_wb_view_report_description   => p_wb_view_report_description
    ,p_workbench_item_code          => p_workbench_item_code
    ,p_workbench_view_report_type   => p_workbench_view_report_type
    ,p_workbench_view_report_action => p_workbench_view_report_action
    ,p_workbench_view_country       => p_workbench_view_country
    ,p_wb_view_report_instruction   => p_wb_view_report_instruction
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    ,p_primary_industry		    => p_primary_industry
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
    rollback to create_view_report_swi;
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
    rollback to create_view_report_swi;
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
end create_view_report;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_view_report >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_view_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_view_report_code   in     varchar2
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
  l_proc    varchar2(72) := g_package ||'delete_view_report';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_view_report_swi;
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
  per_ri_view_report_api.delete_view_report
    (p_validate                     => l_validate
    ,p_workbench_view_report_code   => p_workbench_view_report_code
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
    rollback to delete_view_report_swi;
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
    rollback to delete_view_report_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_view_report;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_view_report >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_view_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_view_report_code   in     varchar2
  ,p_workbench_view_report_name   in     varchar2  default hr_api.g_varchar2
  ,p_wb_view_report_description   in     varchar2  default hr_api.g_varchar2
  ,p_workbench_item_code          in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_report_type   in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_report_action in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_country       in     varchar2  default hr_api.g_varchar2
  ,p_wb_view_report_instruction   in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_primary_industry		  in	 varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_view_report';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_view_report_swi;
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
  per_ri_view_report_api.update_view_report
    (p_validate                     => l_validate
    ,p_workbench_view_report_code   => p_workbench_view_report_code
    ,p_workbench_view_report_name   => p_workbench_view_report_name
    ,p_wb_view_report_description   => p_wb_view_report_description
    ,p_workbench_item_code          => p_workbench_item_code
    ,p_workbench_view_report_type   => p_workbench_view_report_type
    ,p_workbench_view_report_action => p_workbench_view_report_action
    ,p_workbench_view_country       => p_workbench_view_country
    ,p_wb_view_report_instruction   => p_wb_view_report_instruction
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    ,p_primary_industry		    => p_primary_industry
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
    rollback to update_view_report_swi;
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
    rollback to update_view_report_swi;
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
end update_view_report;
end per_ri_view_report_swi;

/
