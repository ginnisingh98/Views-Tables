--------------------------------------------------------
--  DDL for Package Body PSP_PERIOD_FREQUENCY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PERIOD_FREQUENCY_SWI" As
/* $Header: PSPFBSWB.pls 120.0 2005/06/02 16:01 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'psp_period_frequency_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_period_frequency >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_period_frequency
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_start_date                   in     date
  ,p_unit_of_measure              in     varchar2
  ,p_period_duration              in     number
  ,p_report_type                  in     varchar2  default null
  ,p_period_frequency             in     varchar2
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_period_frequency_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_api_warning                     out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_period_frequency_id          number;
  l_proc    varchar2(72) := g_package ||'create_period_frequency';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_period_frequency_swi;
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
  psp_pfb_ins.set_base_key_value
    (p_period_frequency_id => p_period_frequency_id
    );
  --
  -- Call API
  --
  psp_period_frequency_api.create_period_frequency
    (p_validate                     => l_validate
    ,p_start_date                   => p_start_date
    ,p_unit_of_measure              => p_unit_of_measure
    ,p_period_duration              => p_period_duration
    ,p_report_type                  => p_report_type
    ,p_period_frequency             => p_period_frequency
    ,p_language_code                => p_language_code
    ,p_period_frequency_id          => l_period_frequency_id
    ,p_object_version_number        => p_object_version_number
    ,p_api_warning                  => p_api_warning
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
    rollback to create_period_frequency_swi;
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
    rollback to create_period_frequency_swi;
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
end create_period_frequency;
-- ----------------------------------------------------------------------------
-- |------------------------< update_period_frequency >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_period_frequency
  (p_validate                     in     number   default hr_api.g_false_num
  ,p_start_date                   in     date
  ,p_unit_of_measure              in     varchar2
  ,p_period_duration              in     number
  ,p_report_type                  in     varchar2  default hr_api.g_varchar2
  ,p_period_frequency             in     varchar2
  ,p_period_frequency_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_api_warning                     out nocopy varchar2
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
  l_proc    varchar2(72) := g_package ||'update_period_frequency';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_period_frequency_swi;
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
  psp_period_frequency_api.update_period_frequency
    (p_validate                     => l_validate
    ,p_start_date                   => p_start_date
    ,p_unit_of_measure              => p_unit_of_measure
    ,p_period_duration              => p_period_duration
    ,p_report_type                  => p_report_type
    ,p_period_frequency             => p_period_frequency
    ,p_period_frequency_id          => p_period_frequency_id
    ,p_object_version_number        => p_object_version_number
    ,p_api_warning                  => p_api_warning
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
    rollback to update_period_frequency_swi;
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
    rollback to update_period_frequency_swi;
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
end update_period_frequency;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_period_frequency >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_period_frequency
  (p_validate                     in     number   default hr_api.g_false_num
  ,p_period_frequency_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_api_warning                     out nocopy varchar2
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
  l_proc    varchar2(72) := g_package ||'delete_period_frequency';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_period_frequency_swi;
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
  psp_period_frequency_api.delete_period_frequency
    (p_validate                     => l_validate
    ,p_period_frequency_id          => p_period_frequency_id
    ,p_object_version_number        => p_object_version_number
    ,p_api_warning                  => p_api_warning
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
    rollback to delete_period_frequency_swi;
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
    rollback to delete_period_frequency_swi;
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
end delete_period_frequency;
end psp_period_frequency_swi;

/
