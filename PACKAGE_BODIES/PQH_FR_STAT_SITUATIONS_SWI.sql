--------------------------------------------------------
--  DDL for Package Body PQH_FR_STAT_SITUATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_STAT_SITUATIONS_SWI" As
/* $Header: pqstsswi.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_fr_stat_situations_swi.';
g_debug boolean := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_statutory_situation >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_statutory_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_business_group_id            in     number
  ,p_situation_name               in     varchar2
  ,p_type_of_ps                   in     varchar2
  ,p_situation_type               in     varchar2
  ,p_sub_type                     in     varchar2  default null
  ,p_source                       in     varchar2  default null
  ,p_location                     in     varchar2  default null
  ,p_reason                       in     varchar2  default null
  ,p_is_default                   in     varchar2  default null
  ,p_date_from                    in     date      default null
  ,p_date_to                      in     date      default null
  ,p_request_type                 in     varchar2  default null
  ,p_employee_agreement_needed    in     varchar2  default null
  ,p_manager_agreement_needed     in     varchar2  default null
  ,p_print_arrette                in     varchar2  default null
  ,p_reserve_position             in     varchar2  default null
  ,p_allow_progressions           in     varchar2  default null
  ,p_extend_probation_period      in     varchar2  default null
  ,p_remuneration_paid            in     varchar2  default null
  ,p_pay_share                    in     number    default null
  ,p_pay_periods                  in     number    default null
  ,p_frequency                    in     varchar2  default null
  ,p_first_period_max_duration    in     number    default null
  ,p_min_duration_per_request     in     number    default null
  ,p_max_duration_per_request     in     number    default null
  ,p_max_duration_whole_career    in     number    default null
  ,p_renewable_allowed            in     varchar2  default null
  ,p_max_no_of_renewals           in     number    default null
  ,p_max_duration_per_renewal     in     number    default null
  ,p_max_tot_continuous_duration  in     number    default null
  ,p_remunerate_assign_status_id  in     number    default null
  ,p_statutory_situation_id          out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_statutory_situation_id       number;
  l_proc    varchar2(72) := g_package ||'create_statutory_situation';
Begin

 g_debug := hr_utility.debug_enabled;

 if g_debug then
 --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  End if;
  --
  -- Issue a savepoint
  --
  savepoint create_statutory_situation_swi;
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
  pqh_sts_ins.set_base_key_value
    (p_statutory_situation_id => p_statutory_situation_id
    );
  --
  -- Call API
  --
  pqh_fr_stat_situations_api.create_statutory_situation
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_situation_name               => p_situation_name
    ,p_type_of_ps                   => p_type_of_ps
    ,p_situation_type               => p_situation_type
    ,p_sub_type                     => p_sub_type
    ,p_source                       => p_source
    ,p_location                     => p_location
    ,p_reason                       => p_reason
    ,p_is_default                   => p_is_default
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_request_type                 => p_request_type
    ,p_employee_agreement_needed    => p_employee_agreement_needed
    ,p_manager_agreement_needed     => p_manager_agreement_needed
    ,p_print_arrette                => p_print_arrette
    ,p_reserve_position             => p_reserve_position
    ,p_allow_progressions           => p_allow_progressions
    ,p_extend_probation_period      => p_extend_probation_period
    ,p_remuneration_paid            => p_remuneration_paid
    ,p_pay_share                    => p_pay_share
    ,p_pay_periods                  => p_pay_periods
    ,p_frequency                    => p_frequency
    ,p_first_period_max_duration    => p_first_period_max_duration
    ,p_min_duration_per_request     => p_min_duration_per_request
    ,p_max_duration_per_request     => p_max_duration_per_request
    ,p_max_duration_whole_career    => p_max_duration_whole_career
    ,p_renewable_allowed            => p_renewable_allowed
    ,p_max_no_of_renewals           => p_max_no_of_renewals
    ,p_max_duration_per_renewal     => p_max_duration_per_renewal
    ,p_max_tot_continuous_duration  => p_max_tot_continuous_duration
    ,p_statutory_situation_id       => l_statutory_situation_id
    ,p_object_version_number        => p_object_version_number
    ,p_remunerate_assign_status_id  => p_remunerate_assign_status_id
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
  p_statutory_situation_id := l_statutory_situation_id;
  p_return_status := hr_multi_message.get_return_status_disable;

   if g_debug then
   --
  hr_utility.set_location(' Leaving:' || l_proc,20);
   --
   End if;

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_statutory_situation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;

    p_return_status := hr_multi_message.get_return_status_disable;

     if g_debug then
     --
     hr_utility.set_location(' Leaving:' || l_proc, 30);
     --
     End if;

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_statutory_situation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
        if g_debug then
 	--
          hr_utility.set_location(' Leaving:' || l_proc,40);
        --
        End if;
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;

    p_return_status := hr_multi_message.get_return_status_disable;

   if g_debug then
     --
    hr_utility.set_location(' Leaving:' || l_proc,50);
     --
   End if;

end create_statutory_situation;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_statutory_situation >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_statutory_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_statutory_situation_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_statutory_situation';

  --
  Cursor csr_get_child_records IS
  Select stat_situation_rule_id , object_version_number
  from pqh_fr_stat_situation_rules
  where statutory_situation_id = p_statutory_situation_id;

Begin

  g_debug := hr_utility.debug_enabled;

   if g_debug then
   --
   hr_utility.set_location(' Entering:' || l_proc,10);
   --
   End if;

  --
  -- Issue a savepoint
  --
  savepoint delete_statutory_situation_swi;
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
  --
    --
    -- Call API to delete Child Records
    --
       FOR l_rec in csr_get_child_records
        Loop

    	pqh_fr_stat_sit_rules_api.delete_stat_situation_rule
        (p_validate                     => l_validate
        ,p_stat_situation_rule_id       => l_rec.stat_situation_rule_id
        ,p_object_version_number        => l_rec.object_version_number
    	);

    	End loop;

  --
  -- Call API Delete Master
  --
  pqh_fr_stat_situations_api.delete_statutory_situation
    (p_validate                     => l_validate
    ,p_statutory_situation_id       => p_statutory_situation_id
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
   if g_debug then
   --
  hr_utility.set_location(' Leaving:' || l_proc,20);
   --
   End if;
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_statutory_situation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;

   if g_debug then
   --
    hr_utility.set_location(' Leaving:' || l_proc, 30);
   --
   End if;

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_statutory_situation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
        if g_debug then
        --
         hr_utility.set_location(' Leaving:' || l_proc,40);
        --
        End if;

       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
     if g_debug then
     --
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --
    End if;

end delete_statutory_situation;
-- ----------------------------------------------------------------------------
-- |----------------------< update_statutory_situation >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_statutory_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_statutory_situation_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_name               in     varchar2  default hr_api.g_varchar2
  ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_sub_type                     in     varchar2  default hr_api.g_varchar2
  ,p_source                       in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
  ,p_is_default                   in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_type                 in     varchar2  default hr_api.g_varchar2
  ,p_employee_agreement_needed    in     varchar2  default hr_api.g_varchar2
  ,p_manager_agreement_needed     in     varchar2  default hr_api.g_varchar2
  ,p_print_arrette                in     varchar2  default hr_api.g_varchar2
  ,p_reserve_position             in     varchar2  default hr_api.g_varchar2
  ,p_allow_progressions           in     varchar2  default hr_api.g_varchar2
  ,p_extend_probation_period      in     varchar2  default hr_api.g_varchar2
  ,p_remuneration_paid            in     varchar2  default hr_api.g_varchar2
  ,p_pay_share                    in     number    default hr_api.g_number
  ,p_pay_periods                  in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_first_period_max_duration    in     number    default hr_api.g_number
  ,p_min_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_whole_career    in     number    default hr_api.g_number
  ,p_renewable_allowed            in     varchar2  default hr_api.g_varchar2
  ,p_max_no_of_renewals           in     number    default hr_api.g_number
  ,p_max_duration_per_renewal     in     number    default hr_api.g_number
  ,p_max_tot_continuous_duration  in     number    default hr_api.g_number
  ,p_remunerate_assign_status_id  in     number    default hr_api.g_number
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
  l_proc    varchar2(72) := g_package ||'update_statutory_situation';
Begin

  g_debug := hr_utility.debug_enabled;

   if g_debug then
   --
    hr_utility.set_location(' Entering:' || l_proc,10);
   --
   End if;
  --
  -- Issue a savepoint
  --
  savepoint update_statutory_situation_swi;
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
  pqh_fr_stat_situations_api.update_statutory_situation
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_statutory_situation_id       => p_statutory_situation_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_situation_name               => p_situation_name
    ,p_type_of_ps                   => p_type_of_ps
    ,p_situation_type               => p_situation_type
    ,p_sub_type                     => p_sub_type
    ,p_source                       => p_source
    ,p_location                     => p_location
    ,p_reason                       => p_reason
    ,p_is_default                   => p_is_default
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_request_type                 => p_request_type
    ,p_employee_agreement_needed    => p_employee_agreement_needed
    ,p_manager_agreement_needed     => p_manager_agreement_needed
    ,p_print_arrette                => p_print_arrette
    ,p_reserve_position             => p_reserve_position
    ,p_allow_progressions           => p_allow_progressions
    ,p_extend_probation_period      => p_extend_probation_period
    ,p_remuneration_paid            => p_remuneration_paid
    ,p_pay_share                    => p_pay_share
    ,p_pay_periods                  => p_pay_periods
    ,p_frequency                    => p_frequency
    ,p_first_period_max_duration    => p_first_period_max_duration
    ,p_min_duration_per_request     => p_min_duration_per_request
    ,p_max_duration_per_request     => p_max_duration_per_request
    ,p_max_duration_whole_career    => p_max_duration_whole_career
    ,p_renewable_allowed            => p_renewable_allowed
    ,p_max_no_of_renewals           => p_max_no_of_renewals
    ,p_max_duration_per_renewal     => p_max_duration_per_renewal
    ,p_max_tot_continuous_duration  => p_max_tot_continuous_duration
    ,p_remunerate_assign_status_id  => p_remunerate_assign_status_id
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

  if g_debug then
   --
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
  End if;

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_statutory_situation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;

   if g_debug then
    --
    hr_utility.set_location(' Leaving:' || l_proc, 30);
    --
   End if;

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_statutory_situation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       if g_debug then
       --
       hr_utility.set_location(' Leaving:' || l_proc,40);
       --
       End if;

       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;

    p_return_status := hr_multi_message.get_return_status_disable;

   if g_debug then
      --
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --
   end if;

end update_statutory_situation;
end pqh_fr_stat_situations_swi;

/
