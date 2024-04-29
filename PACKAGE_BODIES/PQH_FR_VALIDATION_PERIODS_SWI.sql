--------------------------------------------------------
--  DDL for Package Body PQH_FR_VALIDATION_PERIODS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_VALIDATION_PERIODS_SWI" As
/* $Header: pqvlpswi.pkb 115.1 2002/12/05 00:31:42 rpasapul noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_fr_validation_periods_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_validation_period >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validation_period
  (p_validation_period_id         in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_validation_period';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_validation_period_swi;
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
  pqh_fr_validation_periods_api.delete_validation_period
    (p_validation_period_id         => p_validation_period_id
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
    rollback to delete_validation_period_swi;
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
    rollback to delete_validation_period_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_validation_period;
-- ----------------------------------------------------------------------------
-- |-----------------------< insert_validation_period >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validation_period
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_previous_employer_id         in     number    default null
  ,p_assignment_category	  in	 varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_frequency                    in     varchar2  default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_validation_status            in     varchar2  default null
  ,p_validation_period_id            out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'insert_validation_period';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_validation_period_swi;
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
  pqh_vlp_ins.set_base_key_value
    (p_validation_period_id => p_validation_period_id
    );
  --
  -- Call API
  --
  pqh_fr_validation_periods_api.insert_validation_period
    (p_effective_date               => p_effective_date
    ,p_validation_id                => p_validation_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_assignment_category	    => p_assignment_category
    ,p_normal_hours                 => p_normal_hours
    ,p_frequency                    => p_frequency
    ,p_period_years                 => p_period_years
    ,p_period_months                => p_period_months
    ,p_period_days                  => p_period_days
    ,p_comments                     => p_comments
    ,p_validation_status            => p_validation_status
    ,p_validation_period_id         => p_validation_period_id
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
    rollback to insert_validation_period_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_validation_period_id         := null;
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
    rollback to insert_validation_period_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_validation_period_id         := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_validation_period;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_validation_period >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validation_period
  (p_effective_date               in     date
  ,p_validation_period_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_assignment_category	  in 	 varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_validation_status            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_validation_period';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_validation_period_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_fr_validation_periods_api.update_validation_period
    (p_effective_date               => p_effective_date
    ,p_validation_period_id         => p_validation_period_id
    ,p_object_version_number        => p_object_version_number
    ,p_validation_id                => p_validation_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_assignment_category	    => p_assignment_category
    ,p_normal_hours                 => p_normal_hours
    ,p_frequency                    => p_frequency
    ,p_period_years                 => p_period_years
    ,p_period_months                => p_period_months
    ,p_period_days                  => p_period_days
    ,p_comments                     => p_comments
    ,p_validation_status            => p_validation_status
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
    rollback to update_validation_period_swi;
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
    rollback to update_validation_period_swi;
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
end update_validation_period;
end pqh_fr_validation_periods_swi;

/
