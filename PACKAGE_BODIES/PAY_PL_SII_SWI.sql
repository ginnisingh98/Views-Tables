--------------------------------------------------------
--  DDL for Package Body PAY_PL_SII_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_SII_SWI" As
/* $Header: pypsdswi.pkb 120.0 2005/10/16 22:24 mseshadr noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_pl_sii_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_sii_details >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_pl_sii_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_contract_category            in     varchar2
  ,p_per_or_asg_id                in     number
  ,p_business_group_id            in     number
  ,p_emp_social_security_info     in     varchar2
  ,p_old_age_contribution         in     varchar2  default null
  ,p_pension_contribution         in     varchar2  default null
  ,p_sickness_contribution        in     varchar2  default null
  ,p_work_injury_contribution     in     varchar2  default null
  ,p_labor_contribution           in     varchar2  default null
  ,p_health_contribution          in     varchar2  default null
  ,p_unemployment_contribution    in     varchar2  default null
  ,p_old_age_cont_end_reason      in     varchar2  default null
  ,p_pension_cont_end_reason      in     varchar2  default null
  ,p_sickness_cont_end_reason     in     varchar2  default null
  ,p_work_injury_cont_end_reason  in     varchar2  default null
  ,p_labor_fund_cont_end_reason   in     varchar2  default null
  ,p_health_cont_end_reason       in     varchar2  default null
  ,p_unemployment_cont_end_reason in     varchar2  default null
  ,p_sii_details_id               in     number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date_warning          out nocopy   boolean
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Other variables
  l_sii_details_id               number;
  l_effective_date_warning       boolean;
  l_proc    varchar2(72) := g_package ||'create_pl_sii_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_pl_sii_details_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
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
  pay_psd_ins.set_base_key_value
    (p_sii_details_id => p_sii_details_id
    );
  --
  -- Call API
  --
  pay_pl_sii_api.create_pl_sii_details
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_contract_category            => p_contract_category
    ,p_per_or_asg_id                => p_per_or_asg_id
    ,p_business_group_id            => p_business_group_id
    ,p_emp_social_security_info     => p_emp_social_security_info
    ,p_old_age_contribution         => p_old_age_contribution
    ,p_pension_contribution         => p_pension_contribution
    ,p_sickness_contribution        => p_sickness_contribution
    ,p_work_injury_contribution     => p_work_injury_contribution
    ,p_labor_contribution           => p_labor_contribution
    ,p_health_contribution          => p_health_contribution
    ,p_unemployment_contribution    => p_unemployment_contribution
    ,p_old_age_cont_end_reason      => p_old_age_cont_end_reason
    ,p_pension_cont_end_reason      => p_pension_cont_end_reason
    ,p_sickness_cont_end_reason     => p_sickness_cont_end_reason
    ,p_work_injury_cont_end_reason  => p_work_injury_cont_end_reason
    ,p_labor_fund_cont_end_reason   => p_labor_fund_cont_end_reason
    ,p_health_cont_end_reason       => p_health_cont_end_reason
    ,p_unemployment_cont_end_reason => p_unemployment_cont_end_reason
    ,p_sii_details_id               => l_sii_details_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_effective_date_warning       => l_effective_date_warning
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
    rollback to create_pl_sii_details_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_effective_date_warning       := null;
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
    rollback to create_pl_sii_details_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_effective_date_warning       := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_pl_sii_details;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_sii_details >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_pl_sii_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_sii_details_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_emp_social_security_info     in     varchar2  default hr_api.g_varchar2
  ,p_old_age_contribution         in     varchar2  default hr_api.g_varchar2
  ,p_pension_contribution         in     varchar2  default hr_api.g_varchar2
  ,p_sickness_contribution        in     varchar2  default hr_api.g_varchar2
  ,p_work_injury_contribution     in     varchar2  default hr_api.g_varchar2
  ,p_labor_contribution           in     varchar2  default hr_api.g_varchar2
  ,p_health_contribution          in     varchar2  default hr_api.g_varchar2
  ,p_unemployment_contribution    in     varchar2  default hr_api.g_varchar2
  ,p_old_age_cont_end_reason      in     varchar2  default hr_api.g_varchar2
  ,p_pension_cont_end_reason      in     varchar2  default hr_api.g_varchar2
  ,p_sickness_cont_end_reason     in     varchar2  default hr_api.g_varchar2
  ,p_work_injury_cont_end_reason  in     varchar2  default hr_api.g_varchar2
  ,p_labor_fund_cont_end_reason   in     varchar2  default hr_api.g_varchar2
  ,p_health_cont_end_reason       in     varchar2  default hr_api.g_varchar2
  ,p_unemployment_cont_end_reason in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'update_pl_sii_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_pl_sii_details_swi;
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
  pay_pl_sii_api.update_pl_sii_details
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_sii_details_id               => p_sii_details_id
    ,p_object_version_number        => p_object_version_number
    ,p_emp_social_security_info     => p_emp_social_security_info
    ,p_old_age_contribution         => p_old_age_contribution
    ,p_pension_contribution         => p_pension_contribution
    ,p_sickness_contribution        => p_sickness_contribution
    ,p_work_injury_contribution     => p_work_injury_contribution
    ,p_labor_contribution           => p_labor_contribution
    ,p_health_contribution          => p_health_contribution
    ,p_unemployment_contribution    => p_unemployment_contribution
    ,p_old_age_cont_end_reason      => p_old_age_cont_end_reason
    ,p_pension_cont_end_reason      => p_pension_cont_end_reason
    ,p_sickness_cont_end_reason     => p_sickness_cont_end_reason
    ,p_work_injury_cont_end_reason  => p_work_injury_cont_end_reason
    ,p_labor_fund_cont_end_reason   => p_labor_fund_cont_end_reason
    ,p_health_cont_end_reason       => p_health_cont_end_reason
    ,p_unemployment_cont_end_reason => p_unemployment_cont_end_reason
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
    rollback to update_pl_sii_details_swi;
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
    rollback to update_pl_sii_details_swi;
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
end update_pl_sii_details;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_sii_details >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_pl_sii_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_sii_details_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_pl_sii_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pl_sii_details_swi;
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
  pay_pl_sii_api.delete_pl_sii_details
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_delete_mode        => p_datetrack_delete_mode
    ,p_sii_details_id               => p_sii_details_id
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
    rollback to delete_pl_sii_details_swi;
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
    rollback to delete_pl_sii_details_swi;
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
end delete_pl_sii_details;
end pay_pl_sii_swi;

/
