--------------------------------------------------------
--  DDL for Package Body PAY_SHADOW_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SHADOW_ELEMENT_API" as
/* $Header: pysetapi.pkb 120.0 2005/05/29 08:38:16 appldev noship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  pay_shadow_element_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_shadow_element >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_shadow_element
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_element_type_id               in     number
  ,p_classification_name           in     varchar2 default hr_api.g_varchar2
  ,p_additional_entry_allowed_fla  in     varchar2 default hr_api.g_varchar2
  ,p_adjustment_only_flag          in     varchar2 default hr_api.g_varchar2
  ,p_closed_for_entry_flag         in     varchar2 default hr_api.g_varchar2
  ,p_element_name                  in     varchar2 default hr_api.g_varchar2
  ,p_indirect_only_flag            in     varchar2 default hr_api.g_varchar2
  ,p_multiple_entries_allowed_fla  in     varchar2 default hr_api.g_varchar2
  ,p_multiply_value_flag           in     varchar2 default hr_api.g_varchar2
  ,p_post_termination_rule         in     varchar2 default hr_api.g_varchar2
  ,p_process_in_run_flag           in     varchar2 default hr_api.g_varchar2
  ,p_relative_processing_priority  in     number   default hr_api.g_number
  ,p_processing_type               in     varchar2 default hr_api.g_varchar2
  ,p_standard_link_flag            in     varchar2 default hr_api.g_varchar2
  ,p_input_currency_code           in     varchar2 default hr_api.g_varchar2
  ,p_output_currency_code          in     varchar2 default hr_api.g_varchar2
  ,p_benefit_classification_name   in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_qualifying_age                in     number   default hr_api.g_number
  ,p_qualifying_length_of_service  in     number   default hr_api.g_number
  ,p_qualifying_units              in     varchar2 default hr_api.g_varchar2
  ,p_reporting_name                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_element_information_category  in     varchar2 default hr_api.g_varchar2
  ,p_element_information1          in     varchar2 default hr_api.g_varchar2
  ,p_element_information2          in     varchar2 default hr_api.g_varchar2
  ,p_element_information3          in     varchar2 default hr_api.g_varchar2
  ,p_element_information4          in     varchar2 default hr_api.g_varchar2
  ,p_element_information5          in     varchar2 default hr_api.g_varchar2
  ,p_element_information6          in     varchar2 default hr_api.g_varchar2
  ,p_element_information7          in     varchar2 default hr_api.g_varchar2
  ,p_element_information8          in     varchar2 default hr_api.g_varchar2
  ,p_element_information9          in     varchar2 default hr_api.g_varchar2
  ,p_element_information10         in     varchar2 default hr_api.g_varchar2
  ,p_element_information11         in     varchar2 default hr_api.g_varchar2
  ,p_element_information12         in     varchar2 default hr_api.g_varchar2
  ,p_element_information13         in     varchar2 default hr_api.g_varchar2
  ,p_element_information14         in     varchar2 default hr_api.g_varchar2
  ,p_element_information15         in     varchar2 default hr_api.g_varchar2
  ,p_element_information16         in     varchar2 default hr_api.g_varchar2
  ,p_element_information17         in     varchar2 default hr_api.g_varchar2
  ,p_element_information18         in     varchar2 default hr_api.g_varchar2
  ,p_element_information19         in     varchar2 default hr_api.g_varchar2
  ,p_element_information20         in     varchar2 default hr_api.g_varchar2
  ,p_third_party_pay_only_flag     in     varchar2 default hr_api.g_varchar2
  ,p_skip_formula                  in     varchar2 default hr_api.g_varchar2
  ,p_payroll_formula_id            in     number   default hr_api.g_number
  ,p_exclusion_rule_id             in     number   default hr_api.g_number
  ,p_iterative_flag                in     varchar2 default hr_api.g_varchar2
  ,p_iterative_priority            in     number   default hr_api.g_number
  ,p_iterative_formula_name        in     varchar2 default hr_api.g_varchar2
  ,p_process_mode                  in     varchar2 default hr_api.g_varchar2
  ,p_grossup_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_advance_indicator             in     varchar2 default hr_api.g_varchar2
  ,p_advance_payable               in     varchar2 default hr_api.g_varchar2
  ,p_advance_deduction             in     varchar2 default hr_api.g_varchar2
  ,p_process_advance_entry         in     varchar2 default hr_api.g_varchar2
  ,p_proration_group               in     varchar2 default hr_api.g_varchar2
  ,p_proration_formula             in     varchar2 default hr_api.g_varchar2
  ,p_recalc_event_group            in     varchar2 default hr_api.g_varchar2
  ,p_once_each_period_flag         in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_effective_date      date;
  l_ovn                 number;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_shadow_element';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_shadow_element;
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Check mandatory arguments.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_element_type_id',
     p_argument_value => p_element_type_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_object_version_number',
     p_argument_value => p_object_version_number);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  l_ovn := p_object_version_number;
  pay_set_upd.upd
  (p_effective_date                => l_effective_date
  ,p_element_type_id               => p_element_type_id
  ,p_classification_name           => p_classification_name
  ,p_additional_entry_allowed_fla  => p_additional_entry_allowed_fla
  ,p_adjustment_only_flag          => p_adjustment_only_flag
  ,p_closed_for_entry_flag         => p_closed_for_entry_flag
  ,p_element_name                  => p_element_name
  ,p_indirect_only_flag            => p_indirect_only_flag
  ,p_multiple_entries_allowed_fla  => p_multiple_entries_allowed_fla
  ,p_multiply_value_flag           => p_multiply_value_flag
  ,p_post_termination_rule         => p_post_termination_rule
  ,p_process_in_run_flag           => p_process_in_run_flag
  ,p_relative_processing_priority  => p_relative_processing_priority
  ,p_processing_type               => p_processing_type
  ,p_standard_link_flag            => p_standard_link_flag
  ,p_input_currency_code           => p_input_currency_code
  ,p_output_currency_code          => p_output_currency_code
  ,p_benefit_classification_name   => p_benefit_classification_name
  ,p_description                   => p_description
  ,p_qualifying_age                => p_qualifying_age
  ,p_qualifying_length_of_service  => p_qualifying_length_of_service
  ,p_qualifying_units              => p_qualifying_units
  ,p_reporting_name                => p_reporting_name
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_element_information_category  => p_element_information_category
  ,p_element_information1          => p_element_information1
  ,p_element_information2          => p_element_information2
  ,p_element_information3          => p_element_information3
  ,p_element_information4          => p_element_information4
  ,p_element_information5          => p_element_information5
  ,p_element_information6          => p_element_information6
  ,p_element_information7          => p_element_information7
  ,p_element_information8          => p_element_information8
  ,p_element_information9          => p_element_information9
  ,p_element_information10         => p_element_information10
  ,p_element_information11         => p_element_information11
  ,p_element_information12         => p_element_information12
  ,p_element_information13         => p_element_information13
  ,p_element_information14         => p_element_information14
  ,p_element_information15         => p_element_information15
  ,p_element_information16         => p_element_information16
  ,p_element_information17         => p_element_information17
  ,p_element_information18         => p_element_information18
  ,p_element_information19         => p_element_information19
  ,p_element_information20         => p_element_information20
  ,p_third_party_pay_only_flag     => p_third_party_pay_only_flag
  ,p_skip_formula                  => p_skip_formula
  ,p_payroll_formula_id            => p_payroll_formula_id
  ,p_exclusion_rule_id             => p_exclusion_rule_id
  ,p_iterative_flag                => p_iterative_flag
  ,p_iterative_priority            => p_iterative_priority
  ,p_iterative_formula_name        => p_iterative_formula_name
  ,p_process_mode                  => p_process_mode
  ,p_grossup_flag                  => p_grossup_flag
  ,p_advance_indicator             => p_advance_indicator
  ,p_advance_payable               => p_advance_payable
  ,p_advance_deduction             => p_advance_deduction
  ,p_process_advance_entry         => p_process_advance_entry
  ,p_proration_group               => p_proration_group
  ,p_proration_formula             => p_proration_formula
  ,p_recalc_event_group            => p_recalc_event_group
  ,p_once_each_period_flag         => p_once_each_period_flag
  ,p_object_version_number         => l_ovn
  );
  --
  -- Call After Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_ovn;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_shadow_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_object_version_number  := l_ovn;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_shadow_element;
    p_object_version_number  := null;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_shadow_element;
--
end pay_shadow_element_api;

/
