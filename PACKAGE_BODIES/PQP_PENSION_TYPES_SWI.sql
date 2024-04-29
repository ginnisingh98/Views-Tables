--------------------------------------------------------
--  DDL for Package Body PQP_PENSION_TYPES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PENSION_TYPES_SWI" As
/* $Header: pqptyswi.pkb 120.0.12000000.1 2007/01/16 04:29:08 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_pension_types_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_Pension_Type >-------------------------|
-- ----------------------------------------------------------------------------
Procedure Create_Pension_Type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_pension_type_name            in     varchar2
  ,p_pension_category             in     varchar2
  ,p_pension_provider_type        in     varchar2  default null
  ,p_salary_calculation_method    in     varchar2  default null
  ,p_threshold_conversion_rule    in     varchar2  default null
  ,p_contribution_conversion_rule in     varchar2  default null
  ,p_er_annual_limit              in     number    default null
  ,p_ee_annual_limit              in     number    default null
  ,p_er_annual_salary_threshold   in     number    default null
  ,p_ee_annual_salary_threshold   in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_minimum_age                  in     number    default null
  ,p_ee_contribution_percent      in     number    default null
  ,p_maximum_age                  in     number    default null
  ,p_er_contribution_percent      in     number    default null
  ,p_ee_annual_contribution       in     number    default null
  ,p_er_annual_contribution       in     number    default null
  ,p_annual_premium_amount        in     number    default null
  ,p_ee_contribution_bal_type_id  in     number    default null
  ,p_er_contribution_bal_type_id  in     number    default null
  ,p_balance_init_element_type_id in     number    default null
  ,p_ee_contribution_fixed_rate   in     number    default null --added for UK
  ,p_er_contribution_fixed_rate   in     number    default null --added for UK
  ,p_pty_attribute_category       in     varchar2  default null
  ,p_pty_attribute1               in     varchar2  default null
  ,p_pty_attribute2               in     varchar2  default null
  ,p_pty_attribute3               in     varchar2  default null
  ,p_pty_attribute4               in     varchar2  default null
  ,p_pty_attribute5               in     varchar2  default null
  ,p_pty_attribute6               in     varchar2  default null
  ,p_pty_attribute7               in     varchar2  default null
  ,p_pty_attribute8               in     varchar2  default null
  ,p_pty_attribute9               in     varchar2  default null
  ,p_pty_attribute10              in     varchar2  default null
  ,p_pty_attribute11              in     varchar2  default null
  ,p_pty_attribute12              in     varchar2  default null
  ,p_pty_attribute13              in     varchar2  default null
  ,p_pty_attribute14              in     varchar2  default null
  ,p_pty_attribute15              in     varchar2  default null
  ,p_pty_attribute16              in     varchar2  default null
  ,p_pty_attribute17              in     varchar2  default null
  ,p_pty_attribute18              in     varchar2  default null
  ,p_pty_attribute19              in     varchar2  default null
  ,p_pty_attribute20              in     varchar2  default null
  ,p_pty_information_category     in     varchar2  default null
  ,p_pty_information1             in     varchar2  default null
  ,p_pty_information2             in     varchar2  default null
  ,p_pty_information3             in     varchar2  default null
  ,p_pty_information4             in     varchar2  default null
  ,p_pty_information5             in     varchar2  default null
  ,p_pty_information6             in     varchar2  default null
  ,p_pty_information7             in     varchar2  default null
  ,p_pty_information8             in     varchar2  default null
  ,p_pty_information9             in     varchar2  default null
  ,p_pty_information10            in     varchar2  default null
  ,p_pty_information11            in     varchar2  default null
  ,p_pty_information12            in     varchar2  default null
  ,p_pty_information13            in     varchar2  default null
  ,p_pty_information14            in     varchar2  default null
  ,p_pty_information15            in     varchar2  default null
  ,p_pty_information16            in     varchar2  default null
  ,p_pty_information17            in     varchar2  default null
  ,p_pty_information18            in     varchar2  default null
  ,p_pty_information19            in     varchar2  default null
  ,p_pty_information20            in     varchar2  default null
  ,p_special_pension_type_code    in     varchar2  default null  -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default null  -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default null  -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default null  -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default null  -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default null  -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default null  -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default null  -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default null  -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default null  -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default null  -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default null  -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default null  -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default null  -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default null  -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default null  -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default null  -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default null  -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default null  -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_er_age_threshold             in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_ee_age_contribution          in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_er_age_contribution          in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_pension_type_id              out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_pension_type_id              number;
  l_proc    varchar2(72) := g_package ||'create_pension_type';
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);

  --
  -- Issue a savepoint
  --
  savepoint create_pension_type_swi;
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
  pqp_pty_ins.set_base_key_value
    (p_pension_type_id => p_pension_type_id
    );
  --
  -- Call API
  --
  pqp_pension_types_api.create_pension_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_pension_type_name            => p_pension_type_name
    ,p_pension_category             => p_pension_category
    ,p_pension_provider_type        => p_pension_provider_type
    ,p_salary_calculation_method    => p_salary_calculation_method
    ,p_threshold_conversion_rule    => p_threshold_conversion_rule
    ,p_contribution_conversion_rule => p_contribution_conversion_rule
    ,p_er_annual_limit              => p_er_annual_limit
    ,p_ee_annual_limit              => p_ee_annual_limit
    ,p_er_annual_salary_threshold   => p_er_annual_salary_threshold
    ,p_ee_annual_salary_threshold   => p_ee_annual_salary_threshold
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_description                  => p_description
    ,p_minimum_age                  => p_minimum_age
    ,p_ee_contribution_percent      => p_ee_contribution_percent
    ,p_maximum_age                  => p_maximum_age
    ,p_er_contribution_percent      => p_er_contribution_percent
    ,p_ee_annual_contribution       => p_ee_annual_contribution
    ,p_er_annual_contribution       => p_er_annual_contribution
    ,p_annual_premium_amount        => p_annual_premium_amount
    ,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
    ,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
    ,p_balance_init_element_type_id => p_balance_init_element_type_id
    ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate   --added for UK
    ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate   --added for UK
    ,p_pty_attribute_category       => p_pty_attribute_category
    ,p_pty_attribute1               => p_pty_attribute1
    ,p_pty_attribute2               => p_pty_attribute2
    ,p_pty_attribute3               => p_pty_attribute3
    ,p_pty_attribute4               => p_pty_attribute4
    ,p_pty_attribute5               => p_pty_attribute5
    ,p_pty_attribute6               => p_pty_attribute6
    ,p_pty_attribute7               => p_pty_attribute7
    ,p_pty_attribute8               => p_pty_attribute8
    ,p_pty_attribute9               => p_pty_attribute9
    ,p_pty_attribute10              => p_pty_attribute10
    ,p_pty_attribute11              => p_pty_attribute11
    ,p_pty_attribute12              => p_pty_attribute12
    ,p_pty_attribute13              => p_pty_attribute13
    ,p_pty_attribute14              => p_pty_attribute14
    ,p_pty_attribute15              => p_pty_attribute15
    ,p_pty_attribute16              => p_pty_attribute16
    ,p_pty_attribute17              => p_pty_attribute17
    ,p_pty_attribute18              => p_pty_attribute18
    ,p_pty_attribute19              => p_pty_attribute19
    ,p_pty_attribute20              => p_pty_attribute20
    ,p_pty_information_category     => p_pty_information_category
    ,p_pty_information1             => p_pty_information1
    ,p_pty_information2             => p_pty_information2
    ,p_pty_information3             => p_pty_information3
    ,p_pty_information4             => p_pty_information4
    ,p_pty_information5             => p_pty_information5
    ,p_pty_information6             => p_pty_information6
    ,p_pty_information7             => p_pty_information7
    ,p_pty_information8             => p_pty_information8
    ,p_pty_information9             => p_pty_information9
    ,p_pty_information10            => p_pty_information10
    ,p_pty_information11            => p_pty_information11
    ,p_pty_information12            => p_pty_information12
    ,p_pty_information13            => p_pty_information13
    ,p_pty_information14            => p_pty_information14
    ,p_pty_information15            => p_pty_information15
    ,p_pty_information16            => p_pty_information16
    ,p_pty_information17            => p_pty_information17
    ,p_pty_information18            => p_pty_information18
    ,p_pty_information19            => p_pty_information19
    ,p_pty_information20            => p_pty_information20
    ,p_special_pension_type_code    => p_special_pension_type_code     -- added for NL Phase 2B
    ,p_pension_sub_category         => p_pension_sub_category          -- added for NL Phase 2B
    ,p_pension_basis_calc_method    => p_pension_basis_calc_method     -- added for NL Phase 2B
    ,p_pension_salary_balance       => p_pension_salary_balance        -- added for NL Phase 2B
    ,p_recurring_bonus_percent      => p_recurring_bonus_percent       -- added for NL Phase 2B
    ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent   -- added for NL Phase 2B
    ,p_recurring_bonus_balance      => p_recurring_bonus_balance       -- added for NL Phase 2B
    ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance   -- added for NL Phase 2B
    ,p_std_tax_reduction            => p_std_tax_reduction             -- added for NL Phase 2B
    ,p_spl_tax_reduction            => p_spl_tax_reduction             -- added for NL Phase 2B
    ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction     -- added for NL Phase 2B
    ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction     -- added for NL Phase 2B
    ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction     -- added for NL Phase 2B
    ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction         -- added for NL Phase 2B
    ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction         -- added for NL Phase 2B
    ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction         -- added for NL Phase 2B
    ,p_previous_year_bonus_included => p_previous_year_bonus_included  -- added for NL Phase 2B
    ,p_recurring_bonus_period       => p_recurring_bonus_period        -- added for NL Phase 2B
    ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period    -- added for NL Phase 2B
    ,p_ee_age_threshold             => p_ee_age_threshold              -- added for ABP TAR Fixes
    ,p_er_age_threshold             => p_er_age_threshold              -- added for ABP TAR Fixes
    ,p_ee_age_contribution          => p_ee_age_contribution           -- added for ABP TAR Fixes
    ,p_er_age_contribution          => p_er_age_contribution           -- added for ABP TAR Fixes
    ,p_pension_type_id              => p_pension_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to create_pension_type_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_pension_type_swi;
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
    p_return_status := hr_multi_message.get_return_status_disable;

    hr_utility.set_location(' Leaving:' || l_proc,50);

End Create_Pension_Type;
-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_Pension_Type >-------------------------|
-- ----------------------------------------------------------------------------
Procedure Delete_Pension_Type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_api_warning                     out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_pension_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pension_type_swi;
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
  pqp_pension_types_api.delete_pension_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_pension_type_id              => p_pension_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to delete_pension_type_swi;
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
    rollback to delete_pension_type_swi;
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
End Delete_Pension_Type;
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Pension_Type >-------------------------|
-- ----------------------------------------------------------------------------
Procedure Update_Pension_Type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_type_name            in     varchar2  default hr_api.g_varchar2
  ,p_pension_category             in     varchar2  default hr_api.g_varchar2
  ,p_pension_provider_type        in     varchar2  default hr_api.g_varchar2
  ,p_salary_calculation_method    in     varchar2  default hr_api.g_varchar2
  ,p_threshold_conversion_rule    in     varchar2  default hr_api.g_varchar2
  ,p_contribution_conversion_rule in     varchar2  default hr_api.g_varchar2
  ,p_er_annual_limit              in     number    default hr_api.g_number
  ,p_ee_annual_limit              in     number    default hr_api.g_number
  ,p_er_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_ee_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_minimum_age                  in     number    default hr_api.g_number
  ,p_ee_contribution_percent      in     number    default hr_api.g_number
  ,p_maximum_age                  in     number    default hr_api.g_number
  ,p_er_contribution_percent      in     number    default hr_api.g_number
  ,p_ee_annual_contribution       in     number    default hr_api.g_number
  ,p_er_annual_contribution       in     number    default hr_api.g_number
  ,p_annual_premium_amount        in     number    default hr_api.g_number
  ,p_ee_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_er_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_balance_init_element_type_id in     number    default hr_api.g_number
  ,p_ee_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_er_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_pty_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pty_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pty_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information20            in     varchar2  default hr_api.g_varchar2
  ,p_special_pension_type_code    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_er_age_threshold             in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_ee_age_contribution          in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_er_age_contribution          in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_api_warning                     out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_pension_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_pension_type_swi;
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
  pqp_pension_types_api.update_pension_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_pension_type_id              => p_pension_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_pension_type_name            => p_pension_type_name
    ,p_pension_category             => p_pension_category
    ,p_pension_provider_type        => p_pension_provider_type
    ,p_salary_calculation_method    => p_salary_calculation_method
    ,p_threshold_conversion_rule    => p_threshold_conversion_rule
    ,p_contribution_conversion_rule => p_contribution_conversion_rule
    ,p_er_annual_limit              => p_er_annual_limit
    ,p_ee_annual_limit              => p_ee_annual_limit
    ,p_er_annual_salary_threshold   => p_er_annual_salary_threshold
    ,p_ee_annual_salary_threshold   => p_ee_annual_salary_threshold
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_description                  => p_description
    ,p_minimum_age                  => p_minimum_age
    ,p_ee_contribution_percent      => p_ee_contribution_percent
    ,p_maximum_age                  => p_maximum_age
    ,p_er_contribution_percent      => p_er_contribution_percent
    ,p_ee_annual_contribution       => p_ee_annual_contribution
    ,p_er_annual_contribution       => p_er_annual_contribution
    ,p_annual_premium_amount        => p_annual_premium_amount
    ,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
    ,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
    ,p_balance_init_element_type_id => p_balance_init_element_type_id
    ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate   --added for UK
    ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate   --added for UK
    ,p_pty_attribute_category       => p_pty_attribute_category
    ,p_pty_attribute1               => p_pty_attribute1
    ,p_pty_attribute2               => p_pty_attribute2
    ,p_pty_attribute3               => p_pty_attribute3
    ,p_pty_attribute4               => p_pty_attribute4
    ,p_pty_attribute5               => p_pty_attribute5
    ,p_pty_attribute6               => p_pty_attribute6
    ,p_pty_attribute7               => p_pty_attribute7
    ,p_pty_attribute8               => p_pty_attribute8
    ,p_pty_attribute9               => p_pty_attribute9
    ,p_pty_attribute10              => p_pty_attribute10
    ,p_pty_attribute11              => p_pty_attribute11
    ,p_pty_attribute12              => p_pty_attribute12
    ,p_pty_attribute13              => p_pty_attribute13
    ,p_pty_attribute14              => p_pty_attribute14
    ,p_pty_attribute15              => p_pty_attribute15
    ,p_pty_attribute16              => p_pty_attribute16
    ,p_pty_attribute17              => p_pty_attribute17
    ,p_pty_attribute18              => p_pty_attribute18
    ,p_pty_attribute19              => p_pty_attribute19
    ,p_pty_attribute20              => p_pty_attribute20
    ,p_pty_information_category     => p_pty_information_category
    ,p_pty_information1             => p_pty_information1
    ,p_pty_information2             => p_pty_information2
    ,p_pty_information3             => p_pty_information3
    ,p_pty_information4             => p_pty_information4
    ,p_pty_information5             => p_pty_information5
    ,p_pty_information6             => p_pty_information6
    ,p_pty_information7             => p_pty_information7
    ,p_pty_information8             => p_pty_information8
    ,p_pty_information9             => p_pty_information9
    ,p_pty_information10            => p_pty_information10
    ,p_pty_information11            => p_pty_information11
    ,p_pty_information12            => p_pty_information12
    ,p_pty_information13            => p_pty_information13
    ,p_pty_information14            => p_pty_information14
    ,p_pty_information15            => p_pty_information15
    ,p_pty_information16            => p_pty_information16
    ,p_pty_information17            => p_pty_information17
    ,p_pty_information18            => p_pty_information18
    ,p_pty_information19            => p_pty_information19
    ,p_pty_information20            => p_pty_information20
    ,p_special_pension_type_code    => p_special_pension_type_code     -- added for NL Phase 2B
    ,p_pension_sub_category         => p_pension_sub_category          -- added for NL Phase 2B
    ,p_pension_basis_calc_method    => p_pension_basis_calc_method     -- added for NL Phase 2B
    ,p_pension_salary_balance       => p_pension_salary_balance        -- added for NL Phase 2B
    ,p_recurring_bonus_percent      => p_recurring_bonus_percent       -- added for NL Phase 2B
    ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent   -- added for NL Phase 2B
    ,p_recurring_bonus_balance      => p_recurring_bonus_balance       -- added for NL Phase 2B
    ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance   -- added for NL Phase 2B
    ,p_std_tax_reduction            => p_std_tax_reduction             -- added for NL Phase 2B
    ,p_spl_tax_reduction            => p_spl_tax_reduction             -- added for NL Phase 2B
    ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction     -- added for NL Phase 2B
    ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction     -- added for NL Phase 2B
    ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction     -- added for NL Phase 2B
    ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction         -- added for NL Phase 2B
    ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction         -- added for NL Phase 2B
    ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction         -- added for NL Phase 2B
    ,p_previous_year_bonus_included => p_previous_year_bonus_included  -- added for NL Phase 2B
    ,p_recurring_bonus_period       => p_recurring_bonus_period        -- added for NL Phase 2B
    ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period    -- added for NL Phase 2B
    ,p_ee_age_threshold             => p_ee_age_threshold              -- added for ABP TAR Fixes
    ,p_er_age_threshold             => p_er_age_threshold              -- added for ABP TAR Fixes
    ,p_ee_age_contribution          => p_ee_age_contribution           -- added for ABP TAR Fixes
    ,p_er_age_contribution          => p_er_age_contribution           -- added for ABP TAR Fixes
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
Exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_pension_type_swi;
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
    rollback to update_pension_type_swi;
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

End Update_Pension_Type;

End PQP_Pension_Types_swi;

/
