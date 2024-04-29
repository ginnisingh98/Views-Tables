--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TYPES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TYPES_SWI" As
/* $Header: pyetpswi.pkb 120.0 2005/05/29 04:44 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_element_types_swi.';
--
-- ---------------------------------------------------------------------------+
-- |--------------------------< create_element_type >------------------------|+
-- ---------------------------------------------------------------------------+
PROCEDURE create_element_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_classification_id            in     number
  ,p_element_name                 in     varchar2
  ,p_input_currency_code          in     varchar2
  ,p_output_currency_code         in     varchar2
  ,p_multiple_entries_allowed_fla in     varchar2
  ,p_processing_type              in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_formula_id                   in     number    default null
  ,p_benefit_classification_id    in     number    default null
  ,p_additional_entry_allowed_fla in     varchar2  default null
  ,p_adjustment_only_flag         in     varchar2  default null
  ,p_closed_for_entry_flag        in     varchar2  default null
  ,p_reporting_name               in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_indirect_only_flag           in     varchar2  default null
  ,p_multiply_value_flag          in     varchar2  default null
  ,p_post_termination_rule        in     varchar2  default null
  ,p_process_in_run_flag          in     varchar2  default null
  ,p_processing_priority          in     number    default null
  ,p_standard_link_flag           in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_third_party_pay_only_flag    in     varchar2  default null
  ,p_iterative_flag               in     varchar2  default null
  ,p_iterative_formula_id         in     number    default null
  ,p_iterative_priority           in     number    default null
  ,p_creator_type                 in     varchar2  default null
  ,p_retro_summ_ele_id            in     number    default null
  ,p_grossup_flag                 in     varchar2  default null
  ,p_process_mode                 in     varchar2  default null
  ,p_advance_indicator            in     varchar2  default null
  ,p_advance_payable              in     varchar2  default null
  ,p_advance_deduction            in     varchar2  default null
  ,p_process_advance_entry        in     varchar2  default null
  ,p_proration_group_id           in     number    default null
  ,p_proration_formula_id         in     number    default null
  ,p_recalc_event_group_id        in     number    default null
  ,p_legislation_subgroup         in     varchar2  default null
  ,p_qualifying_age               in     number    default null
  ,p_qualifying_length_of_service in     number    default null
  ,p_qualifying_units             in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_element_information_category in     varchar2  default null
  ,p_element_information1         in     varchar2  default null
  ,p_element_information2         in     varchar2  default null
  ,p_element_information3         in     varchar2  default null
  ,p_element_information4         in     varchar2  default null
  ,p_element_information5         in     varchar2  default null
  ,p_element_information6         in     varchar2  default null
  ,p_element_information7         in     varchar2  default null
  ,p_element_information8         in     varchar2  default null
  ,p_element_information9         in     varchar2  default null
  ,p_element_information10        in     varchar2  default null
  ,p_element_information11        in     varchar2  default null
  ,p_element_information12        in     varchar2  default null
  ,p_element_information13        in     varchar2  default null
  ,p_element_information14        in     varchar2  default null
  ,p_element_information15        in     varchar2  default null
  ,p_element_information16        in     varchar2  default null
  ,p_element_information17        in     varchar2  default null
  ,p_element_information18        in     varchar2  default null
  ,p_element_information19        in     varchar2  default null
  ,p_element_information20        in     varchar2  default null
  ,p_default_uom                  in     varchar2  default null
  ,p_once_each_period_flag        in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  ,p_element_type_id                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_processing_priority_warning   boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_element_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_element_type_swi;
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
  pay_element_types_api.create_element_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_classification_id            => p_classification_id
    ,p_element_name                 => p_element_name
    ,p_input_currency_code          => p_input_currency_code
    ,p_output_currency_code         => p_output_currency_code
    ,p_multiple_entries_allowed_fla => p_multiple_entries_allowed_fla
    ,p_processing_type              => p_processing_type
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_formula_id                   => p_formula_id
    ,p_benefit_classification_id    => p_benefit_classification_id
    ,p_additional_entry_allowed_fla => p_additional_entry_allowed_fla
    ,p_adjustment_only_flag         => p_adjustment_only_flag
    ,p_closed_for_entry_flag        => p_closed_for_entry_flag
    ,p_reporting_name               => p_reporting_name
    ,p_description                  => p_description
    ,p_indirect_only_flag           => p_indirect_only_flag
    ,p_multiply_value_flag          => p_multiply_value_flag
    ,p_post_termination_rule        => p_post_termination_rule
    ,p_process_in_run_flag          => p_process_in_run_flag
    ,p_processing_priority          => p_processing_priority
    ,p_standard_link_flag           => p_standard_link_flag
    ,p_comments                     => p_comments
    ,p_third_party_pay_only_flag    => p_third_party_pay_only_flag
    ,p_iterative_flag               => p_iterative_flag
    ,p_iterative_formula_id         => p_iterative_formula_id
    ,p_iterative_priority           => p_iterative_priority
    ,p_creator_type                 => p_creator_type
    ,p_retro_summ_ele_id            => p_retro_summ_ele_id
    ,p_grossup_flag                 => p_grossup_flag
    ,p_process_mode                 => p_process_mode
    ,p_advance_indicator            => p_advance_indicator
    ,p_advance_payable              => p_advance_payable
    ,p_advance_deduction            => p_advance_deduction
    ,p_process_advance_entry        => p_process_advance_entry
    ,p_proration_group_id           => p_proration_group_id
    ,p_proration_formula_id         => p_proration_formula_id
    ,p_recalc_event_group_id        => p_recalc_event_group_id
    ,p_legislation_subgroup         => p_legislation_subgroup
    ,p_qualifying_age               => p_qualifying_age
    ,p_qualifying_length_of_service => p_qualifying_length_of_service
    ,p_qualifying_units             => p_qualifying_units
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_element_information_category => p_element_information_category
    ,p_element_information1         => p_element_information1
    ,p_element_information2         => p_element_information2
    ,p_element_information3         => p_element_information3
    ,p_element_information4         => p_element_information4
    ,p_element_information5         => p_element_information5
    ,p_element_information6         => p_element_information6
    ,p_element_information7         => p_element_information7
    ,p_element_information8         => p_element_information8
    ,p_element_information9         => p_element_information9
    ,p_element_information10        => p_element_information10
    ,p_element_information11        => p_element_information11
    ,p_element_information12        => p_element_information12
    ,p_element_information13        => p_element_information13
    ,p_element_information14        => p_element_information14
    ,p_element_information15        => p_element_information15
    ,p_element_information16        => p_element_information16
    ,p_element_information17        => p_element_information17
    ,p_element_information18        => p_element_information18
    ,p_element_information19        => p_element_information19
    ,p_element_information20        => p_element_information20
    ,p_default_uom                  => p_default_uom
    ,p_once_each_period_flag        => p_once_each_period_flag
    ,p_language_code                => p_language_code
    ,p_element_type_id              => p_element_type_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_object_version_number        => p_object_version_number
    ,p_comment_id                   => p_comment_id
    ,p_processing_priority_warning  => l_processing_priority_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --if l_processing_priority_warning then
  --   fnd_message.set_name('PAY', 'PAY_6149_ELEMENT_PRIORITY_UPD');
  --    hr_multi_message.add
  --      (p_message_type => hr_multi_message.g_warning_msg
  --      );
  --end if;  --
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
    rollback to create_element_type_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_element_type_id              := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_comment_id                   := null;
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
    rollback to create_element_type_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_element_type_id              := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_comment_id                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_element_type;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_element_type >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_element_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_element_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_benefit_classification_id    in     number    default hr_api.g_number
  ,p_additional_entry_allowed_fla in     varchar2  default hr_api.g_varchar2
  ,p_adjustment_only_flag         in     varchar2  default hr_api.g_varchar2
  ,p_closed_for_entry_flag        in     varchar2  default hr_api.g_varchar2
  ,p_element_name                 in     varchar2  default hr_api.g_varchar2
  ,p_reporting_name               in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_indirect_only_flag           in     varchar2  default hr_api.g_varchar2
  ,p_multiple_entries_allowed_fla in     varchar2  default hr_api.g_varchar2
  ,p_multiply_value_flag          in     varchar2  default hr_api.g_varchar2
  ,p_post_termination_rule        in     varchar2  default hr_api.g_varchar2
  ,p_process_in_run_flag          in     varchar2  default hr_api.g_varchar2
  ,p_processing_priority          in     number    default hr_api.g_number
  ,p_standard_link_flag           in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_only_flag    in     varchar2  default hr_api.g_varchar2
  ,p_iterative_flag               in     varchar2  default hr_api.g_varchar2
  ,p_iterative_formula_id         in     number    default hr_api.g_number
  ,p_iterative_priority           in     number    default hr_api.g_number
  ,p_creator_type                 in     varchar2  default hr_api.g_varchar2
  ,p_retro_summ_ele_id            in     number    default hr_api.g_number
  ,p_grossup_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_process_mode                 in     varchar2  default hr_api.g_varchar2
  ,p_advance_indicator            in     varchar2  default hr_api.g_varchar2
  ,p_advance_payable              in     varchar2  default hr_api.g_varchar2
  ,p_advance_deduction            in     varchar2  default hr_api.g_varchar2
  ,p_process_advance_entry        in     varchar2  default hr_api.g_varchar2
  ,p_proration_group_id           in     number    default hr_api.g_number
  ,p_proration_formula_id         in     number    default hr_api.g_number
  ,p_recalc_event_group_id        in     number    default hr_api.g_number
  ,p_qualifying_age               in     number    default hr_api.g_number
  ,p_qualifying_length_of_service in     number    default hr_api.g_number
  ,p_qualifying_units             in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_element_information_category in     varchar2  default hr_api.g_varchar2
  ,p_element_information1         in     varchar2  default hr_api.g_varchar2
  ,p_element_information2         in     varchar2  default hr_api.g_varchar2
  ,p_element_information3         in     varchar2  default hr_api.g_varchar2
  ,p_element_information4         in     varchar2  default hr_api.g_varchar2
  ,p_element_information5         in     varchar2  default hr_api.g_varchar2
  ,p_element_information6         in     varchar2  default hr_api.g_varchar2
  ,p_element_information7         in     varchar2  default hr_api.g_varchar2
  ,p_element_information8         in     varchar2  default hr_api.g_varchar2
  ,p_element_information9         in     varchar2  default hr_api.g_varchar2
  ,p_element_information10        in     varchar2  default hr_api.g_varchar2
  ,p_element_information11        in     varchar2  default hr_api.g_varchar2
  ,p_element_information12        in     varchar2  default hr_api.g_varchar2
  ,p_element_information13        in     varchar2  default hr_api.g_varchar2
  ,p_element_information14        in     varchar2  default hr_api.g_varchar2
  ,p_element_information15        in     varchar2  default hr_api.g_varchar2
  ,p_element_information16        in     varchar2  default hr_api.g_varchar2
  ,p_element_information17        in     varchar2  default hr_api.g_varchar2
  ,p_element_information18        in     varchar2  default hr_api.g_varchar2
  ,p_element_information19        in     varchar2  default hr_api.g_varchar2
  ,p_element_information20        in     varchar2  default hr_api.g_varchar2
  ,p_once_each_period_flag        in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_processing_priority_warning   boolean;
  l_element_name_warning          boolean;
  l_element_name_change_warning   boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_element_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_element_type_swi;
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
  pay_element_types_api.update_element_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_element_type_id              => p_element_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_formula_id                   => p_formula_id
    ,p_benefit_classification_id    => p_benefit_classification_id
    ,p_additional_entry_allowed_fla => p_additional_entry_allowed_fla
    ,p_adjustment_only_flag         => p_adjustment_only_flag
    ,p_closed_for_entry_flag        => p_closed_for_entry_flag
    ,p_element_name                 => p_element_name
    ,p_reporting_name               => p_reporting_name
    ,p_description                  => p_description
    ,p_indirect_only_flag           => p_indirect_only_flag
    ,p_multiple_entries_allowed_fla => p_multiple_entries_allowed_fla
    ,p_multiply_value_flag          => p_multiply_value_flag
    ,p_post_termination_rule        => p_post_termination_rule
    ,p_process_in_run_flag          => p_process_in_run_flag
    ,p_processing_priority          => p_processing_priority
    ,p_standard_link_flag           => p_standard_link_flag
    ,p_comments                     => p_comments
    ,p_third_party_pay_only_flag    => p_third_party_pay_only_flag
    ,p_iterative_flag               => p_iterative_flag
    ,p_iterative_formula_id         => p_iterative_formula_id
    ,p_iterative_priority           => p_iterative_priority
    ,p_creator_type                 => p_creator_type
    ,p_retro_summ_ele_id            => p_retro_summ_ele_id
    ,p_grossup_flag                 => p_grossup_flag
    ,p_process_mode                 => p_process_mode
    ,p_advance_indicator            => p_advance_indicator
    ,p_advance_payable              => p_advance_payable
    ,p_advance_deduction            => p_advance_deduction
    ,p_process_advance_entry        => p_process_advance_entry
    ,p_proration_group_id           => p_proration_group_id
    ,p_proration_formula_id         => p_proration_formula_id
    ,p_recalc_event_group_id        => p_recalc_event_group_id
    ,p_qualifying_age               => p_qualifying_age
    ,p_qualifying_length_of_service => p_qualifying_length_of_service
    ,p_qualifying_units             => p_qualifying_units
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_element_information_category => p_element_information_category
    ,p_element_information1         => p_element_information1
    ,p_element_information2         => p_element_information2
    ,p_element_information3         => p_element_information3
    ,p_element_information4         => p_element_information4
    ,p_element_information5         => p_element_information5
    ,p_element_information6         => p_element_information6
    ,p_element_information7         => p_element_information7
    ,p_element_information8         => p_element_information8
    ,p_element_information9         => p_element_information9
    ,p_element_information10        => p_element_information10
    ,p_element_information11        => p_element_information11
    ,p_element_information12        => p_element_information12
    ,p_element_information13        => p_element_information13
    ,p_element_information14        => p_element_information14
    ,p_element_information15        => p_element_information15
    ,p_element_information16        => p_element_information16
    ,p_element_information17        => p_element_information17
    ,p_element_information18        => p_element_information18
    ,p_element_information19        => p_element_information19
    ,p_element_information20        => p_element_information20
    ,p_once_each_period_flag        => p_once_each_period_flag
    ,p_language_code                => p_language_code
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_comment_id                   => p_comment_id
    ,p_processing_priority_warning  => l_processing_priority_warning
    ,p_element_name_warning         => l_element_name_warning
    ,p_element_name_change_warning  => l_element_name_change_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_processing_priority_warning then
      fnd_message.set_name('PAY','PAY_6149_ELEMENT_PRIORITY_UPD');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_element_name_warning then
      fnd_message.set_name('PAY','PAY_6365_ELEMENT_NO_DB_NAME');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_element_name_change_warning then
      fnd_message.set_name('PAY','PAY_6137_ELEMENT_DUP_NAME');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to update_element_type_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_comment_id                   := null;
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
    rollback to update_element_type_swi;
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
    p_comment_id                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_element_type;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_element_type >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_element_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_element_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_balance_feeds_warning         boolean;
  l_processing_rules_warning      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_element_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_element_type_swi;
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
  pay_element_types_api.delete_element_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_delete_mode        => p_datetrack_delete_mode
    ,p_element_type_id              => p_element_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_balance_feeds_warning        => l_balance_feeds_warning
    ,p_processing_rules_warning     => l_processing_rules_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_balance_feeds_warning then
     fnd_message.set_name('PAY', 'HR_6208_BAL_DEL_NOT_AUTO');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_processing_rules_warning then
     fnd_message.set_name('PAY', 'PAY_6156_ELEMENT_NO_DEL_SPR');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to delete_element_type_swi;
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
    rollback to delete_element_type_swi;
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
end delete_element_type;
end pay_element_types_swi;

/
