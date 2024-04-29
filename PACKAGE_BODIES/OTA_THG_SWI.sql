--------------------------------------------------------
--  DDL for Package Body OTA_THG_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_THG_SWI" As
/* $Header: otthgswi.pkb 120.0 2005/06/24 07:59 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_thg_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_hr_gl_flex >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_hr_gl_flex
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_segment                      in     varchar2
  ,p_segment_num                  in     number
  ,p_hr_data_source               in     varchar2  default null
  ,p_constant                     in     varchar2  default null
  ,p_hr_cost_segment              in     varchar2  default null
  ,p_gl_default_segment_id           out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_hr_gl_flex';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_hr_gl_flex_swi;
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
  ota_thg_api.create_hr_gl_flex
    (p_effective_date               => p_effective_date
    ,p_cross_charge_id              => p_cross_charge_id
    ,p_segment                      => p_segment
    ,p_segment_num                  => p_segment_num
    ,p_hr_data_source               => p_hr_data_source
    ,p_constant                     => p_constant
    ,p_hr_cost_segment              => p_hr_cost_segment
    ,p_gl_default_segment_id        => p_gl_default_segment_id
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to create_hr_gl_flex_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_gl_default_segment_id        := null;
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
    rollback to create_hr_gl_flex_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_gl_default_segment_id        := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_hr_gl_flex;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_hr_gl_flex >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_hr_gl_flex
  (p_effective_date               in     date
  ,p_gl_default_segment_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_cross_charge_id              in     number    default hr_api.g_number
  ,p_segment                      in     varchar2  default hr_api.g_varchar2
  ,p_segment_num                  in     number    default hr_api.g_number
  ,p_hr_data_source               in     varchar2  default hr_api.g_varchar2
  ,p_constant                     in     varchar2  default hr_api.g_varchar2
  ,p_hr_cost_segment              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
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
  l_proc    varchar2(72) := g_package ||'update_hr_gl_flex';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_hr_gl_flex_swi;
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
  ota_thg_api.update_hr_gl_flex
    (p_effective_date               => p_effective_date
    ,p_gl_default_segment_id        => p_gl_default_segment_id
    ,p_object_version_number        => p_object_version_number
    ,p_cross_charge_id              => p_cross_charge_id
    ,p_segment                      => p_segment
    ,p_segment_num                  => p_segment_num
    ,p_hr_data_source               => p_hr_data_source
    ,p_constant                     => p_constant
    ,p_hr_cost_segment              => p_hr_cost_segment
    ,p_validate                     => l_validate
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
    rollback to update_hr_gl_flex_swi;
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
    rollback to update_hr_gl_flex_swi;
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
end update_hr_gl_flex;
end ota_thg_swi;

/
