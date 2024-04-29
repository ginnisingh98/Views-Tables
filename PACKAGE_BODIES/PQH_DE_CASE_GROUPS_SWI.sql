--------------------------------------------------------
--  DDL for Package Body PQH_DE_CASE_GROUPS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_CASE_GROUPS_SWI" As
/* $Header: pqcgnswi.pkb 115.2 2002/11/27 04:43:33 rpasapul noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_de_case_groups_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_case_groups >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_case_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_case_group_id                in     number
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
  l_proc    varchar2(72) := g_package ||'delete_case_groups';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_case_groups_swi;
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
  pqh_de_case_groups_api.delete_case_groups
    (p_validate                     => l_validate
    ,p_case_group_id                => p_case_group_id
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
    rollback to delete_case_groups_swi;
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
    rollback to delete_case_groups_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_case_groups;
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_case_groups >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_case_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_case_group_number            in     varchar2
  ,p_description                  in     varchar2
  ,p_advanced_pay_grade           in     number
  ,p_entries_in_minute            in     varchar2
  ,p_period_of_prob_advmnt        in     number
  ,p_period_of_time_advmnt        in     number
  ,p_advancement_to               in     number
  ,p_advancement_additional_pyt   in     number
  ,p_time_advanced_pay_grade      in     number
  ,p_time_advancement_to          in     number
  ,p_business_group_id            in     number
  ,p_time_advn_units              in     varchar2
  ,p_prob_advn_units              in     varchar2
  ,p_SUB_CSGRP_DESCRIPTION        in     varchar2
  ,p_case_group_id                   out nocopy number
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
  l_proc    varchar2(72) := g_package ||'insert_case_groups';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_case_groups_swi;
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
  pqh_de_case_groups_api.Insert_CASE_GROUPS
   (p_validate                      =>   l_validate
  ,p_effective_date                 =>   p_effective_date
  ,p_Case_Group_NUMBER              =>   p_Case_Group_NUMBER
  ,P_DESCRIPTION                    =>   P_DESCRIPTION
  ,p_Advanced_Pay_Grade		    =>   p_Advanced_Pay_Grade
  ,p_Entries_in_Minute		    =>   p_Entries_in_Minute
  ,p_Period_Of_Prob_Advmnt          =>   p_Period_Of_Prob_Advmnt
  ,p_Period_Of_Time_Advmnt	    =>   p_Period_Of_Time_Advmnt
  ,p_Advancement_To		    =>   p_Advancement_To
  ,p_Advancement_Additional_pyt     =>   p_Advancement_Additional_pyt
  ,p_time_advanced_pay_grade        =>   p_time_advanced_pay_grade
  ,p_time_advancement_to            =>   p_time_advancement_to
  ,p_business_group_id              =>   p_business_group_id
  ,p_time_advn_units                =>   p_time_advn_units
  ,p_prob_advn_units                =>   p_prob_advn_units
  ,p_sub_csgrp_description          =>   p_sub_csgrp_description
  ,P_CASE_GROUP_ID                  =>   P_CASE_GROUP_ID
  ,p_object_version_number          =>   p_object_version_number   );
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
    rollback to insert_case_groups_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_case_group_id                := null;
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
    rollback to insert_case_groups_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_case_group_id                := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_case_groups;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_case_groups >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_case_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_case_group_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_case_group_number            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_advanced_pay_grade           in     number    default hr_api.g_number
  ,p_entries_in_minute            in     varchar2  default hr_api.g_varchar2
  ,p_period_of_prob_advmnt        in     number    default hr_api.g_number
  ,p_period_of_time_advmnt        in     number    default hr_api.g_number
  ,p_advancement_to               in     number    default hr_api.g_number
  ,p_advancement_additional_pyt   in     number    default hr_api.g_number
  ,p_time_advanced_pay_grade      in     number    default hr_api.g_number
  ,p_time_advancement_to          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_time_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_prob_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_SUB_CSGRP_DESCRIPTION        in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_case_groups';
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_case_groups_swi;
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
  pqh_de_case_groups_api.update_case_groups
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_case_group_id                => p_case_group_id
    ,p_object_version_number        => p_object_version_number
    ,p_case_group_number            => p_case_group_number
    ,p_description                  => p_description
    ,p_advanced_pay_grade           => p_advanced_pay_grade
    ,p_entries_in_minute            => p_entries_in_minute
    ,p_period_of_prob_advmnt        => p_period_of_prob_advmnt
    ,p_period_of_time_advmnt        => p_period_of_time_advmnt
    ,p_advancement_to               => p_advancement_to
    ,p_advancement_additional_pyt   => p_advancement_additional_pyt
    ,p_time_advanced_pay_grade      => p_time_advanced_pay_grade
    ,p_time_advancement_to          => p_time_advancement_to
    ,p_business_group_id            => p_business_group_id
    ,p_time_advn_units              => p_time_advn_units
    ,p_prob_advn_units              => p_prob_advn_units
    ,p_SUB_CSGRP_DESCRIPTION        =>p_SUB_CSGRP_DESCRIPTION
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
    rollback to update_case_groups_swi;
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
    rollback to update_case_groups_swi;
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
end update_case_groups;
end pqh_de_case_groups_swi;

/
