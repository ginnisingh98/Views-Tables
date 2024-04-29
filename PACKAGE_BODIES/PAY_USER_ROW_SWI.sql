--------------------------------------------------------
--  DDL for Package Body PAY_USER_ROW_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_ROW_SWI" As
/* $Header: pypurswi.pkb 120.0 2005/05/29 08:01 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_user_row_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_user_row >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_user_row
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_user_table_id                in     number
  ,p_row_low_range_or_name        in     varchar2
  ,p_display_sequence             in out nocopy number
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_disable_range_overlap_check  in     number    default null
  ,p_disable_units_check          in     number    default null
  ,p_row_high_range               in     varchar2  default null
  ,p_user_row_id                     out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_disable_range_overlap_check   boolean;
  l_disable_units_check           boolean;
  --
  -- Variables for IN/OUT parameters
  l_display_sequence              number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_user_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_row_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_display_sequence              := p_display_sequence;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  l_disable_range_overlap_check :=
    hr_api.constant_to_boolean
      (p_constant_value => p_disable_range_overlap_check);
  l_disable_units_check :=
    hr_api.constant_to_boolean
      (p_constant_value => p_disable_units_check);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_user_row_api.create_user_row
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_user_table_id                => p_user_table_id
    ,p_row_low_range_or_name        => p_row_low_range_or_name
    ,p_display_sequence             => p_display_sequence
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_disable_range_overlap_check  => l_disable_range_overlap_check
    ,p_disable_units_check          => l_disable_units_check
    ,p_row_high_range               => p_row_high_range
    ,p_user_row_id                  => p_user_row_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to create_user_row_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_display_sequence             := l_display_sequence;
    p_user_row_id                  := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to create_user_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_display_sequence             := l_display_sequence;
    p_user_row_id                  := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_user_row;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_user_row >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_user_row
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_user_row_id                  in     number
  ,p_display_sequence             in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_row_low_range_or_name        in     varchar2  default hr_api.g_varchar2
  ,p_disable_range_overlap_check  in     number    default null
  ,p_disable_units_check          in     number    default null
  ,p_row_high_range               in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_disable_range_overlap_check   boolean;
  l_disable_units_check           boolean;
  --
  -- Variables for IN/OUT parameters
  l_display_sequence              number;
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_user_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_row_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_display_sequence              := p_display_sequence;
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  l_disable_range_overlap_check :=
    hr_api.constant_to_boolean
      (p_constant_value => p_disable_range_overlap_check);
  l_disable_units_check :=
    hr_api.constant_to_boolean
      (p_constant_value => p_disable_units_check);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_user_row_api.update_user_row
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_user_row_id                  => p_user_row_id
    ,p_display_sequence             => p_display_sequence
    ,p_object_version_number        => p_object_version_number
    ,p_row_low_range_or_name        => p_row_low_range_or_name
    ,p_disable_range_overlap_check  => l_disable_range_overlap_check
    ,p_disable_units_check          => l_disable_units_check
    ,p_row_high_range               => p_row_high_range
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to update_user_row_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_display_sequence             := l_display_sequence;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to update_user_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_display_sequence             := l_display_sequence;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_user_row;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_user_row >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_user_row
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_user_row_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_disable_range_overlap_check  in     number    default null
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_disable_range_overlap_check   boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_user_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_row_swi;
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
  l_disable_range_overlap_check :=
    hr_api.constant_to_boolean
      (p_constant_value => p_disable_range_overlap_check);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_user_row_api.delete_user_row
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_user_row_id                  => p_user_row_id
    ,p_object_version_number        => p_object_version_number
    ,p_disable_range_overlap_check  => l_disable_range_overlap_check
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to delete_user_row_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to delete_user_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_user_row;
end pay_user_row_swi;

/
