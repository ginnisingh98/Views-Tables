--------------------------------------------------------
--  DDL for Package Body HR_ACCRUAL_PLAN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ACCRUAL_PLAN_SWI" As
/* $Header: pypapswi.pkb 120.0 2005/05/29 07:15 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_accrual_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_accrual_formula_id           in     number
  ,p_co_formula_id                in     number
  ,p_pto_input_value_id           in     number
  ,p_accrual_plan_name            in     varchar2
  ,p_accrual_units_of_measure     in     varchar2
  ,p_accrual_category             in     varchar2  default null
  ,p_accrual_start                in     varchar2  default null
  ,p_ineligible_period_length     in     number    default null
  ,p_ineligible_period_type       in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_ineligibility_formula_id     in     number    default null
  ,p_balance_dimension_id         in     number    default null
  ,p_information_category         in     varchar2  default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_information21                in     varchar2  default null
  ,p_information22                in     varchar2  default null
  ,p_information23                in     varchar2  default null
  ,p_information24                in     varchar2  default null
  ,p_information25                in     varchar2  default null
  ,p_information26                in     varchar2  default null
  ,p_information27                in     varchar2  default null
  ,p_information28                in     varchar2  default null
  ,p_information29                in     varchar2  default null
  ,p_information30                in     varchar2  default null
  ,p_accrual_plan_id                 out nocopy number
  ,p_accrual_plan_element_type_id    out nocopy number
  ,p_co_element_type_id              out nocopy number
  ,p_co_input_value_id               out nocopy number
  ,p_co_date_input_value_id          out nocopy number
  ,p_co_exp_date_input_value_id      out nocopy number
  ,p_residual_element_type_id        out nocopy number
  ,p_residual_input_value_id         out nocopy number
  ,p_residual_date_input_value_id    out nocopy number
  ,p_payroll_formula_id              out nocopy number
  ,p_defined_balance_id              out nocopy number
  ,p_balance_element_type_id         out nocopy number
  ,p_tagging_element_type_id         out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_no_link_message                 out nocopy number
  ,p_check_accrual_ff                out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_no_link_message               boolean;
  l_check_accrual_ff              boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72);
Begin
  l_proc := g_package ||'create_accrual_plan';
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_accrual_plan_swi;
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
  l_no_link_message :=
    hr_api.constant_to_boolean
      (p_constant_value => p_no_link_message);
  l_check_accrual_ff :=
    hr_api.constant_to_boolean
      (p_constant_value => p_check_accrual_ff);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_accrual_plan_api.create_accrual_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_accrual_formula_id           => p_accrual_formula_id
    ,p_co_formula_id                => p_co_formula_id
    ,p_pto_input_value_id           => p_pto_input_value_id
    ,p_accrual_plan_name            => p_accrual_plan_name
    ,p_accrual_units_of_measure     => p_accrual_units_of_measure
    ,p_accrual_category             => p_accrual_category
    ,p_accrual_start                => p_accrual_start
    ,p_ineligible_period_length     => p_ineligible_period_length
    ,p_ineligible_period_type       => p_ineligible_period_type
    ,p_description                  => p_description
    ,p_ineligibility_formula_id     => p_ineligibility_formula_id
    ,p_balance_dimension_id         => p_balance_dimension_id
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_information21                => p_information21
    ,p_information22                => p_information22
    ,p_information23                => p_information23
    ,p_information24                => p_information24
    ,p_information25                => p_information25
    ,p_information26                => p_information26
    ,p_information27                => p_information27
    ,p_information28                => p_information28
    ,p_information29                => p_information29
    ,p_information30                => p_information30
    ,p_accrual_plan_id              => p_accrual_plan_id
    ,p_accrual_plan_element_type_id => p_accrual_plan_element_type_id
    ,p_co_element_type_id           => p_co_element_type_id
    ,p_co_input_value_id            => p_co_input_value_id
    ,p_co_date_input_value_id       => p_co_date_input_value_id
    ,p_co_exp_date_input_value_id   => p_co_exp_date_input_value_id
    ,p_residual_element_type_id     => p_residual_element_type_id
    ,p_residual_input_value_id      => p_residual_input_value_id
    ,p_residual_date_input_value_id => p_residual_date_input_value_id
    ,p_payroll_formula_id           => p_payroll_formula_id
    ,p_defined_balance_id           => p_defined_balance_id
    ,p_balance_element_type_id      => p_balance_element_type_id
    ,p_tagging_element_type_id      => p_tagging_element_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_no_link_message              => l_no_link_message
    ,p_check_accrual_ff             => l_check_accrual_ff
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_no_link_message :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_no_link_message
      );
  p_check_accrual_ff :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_check_accrual_ff
      );
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
    rollback to create_accrual_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_accrual_plan_id              := null;
    p_accrual_plan_element_type_id := null;
    p_co_element_type_id           := null;
    p_co_input_value_id            := null;
    p_co_date_input_value_id       := null;
    p_co_exp_date_input_value_id   := null;
    p_residual_element_type_id     := null;
    p_residual_input_value_id      := null;
    p_residual_date_input_value_id := null;
    p_payroll_formula_id           := null;
    p_defined_balance_id           := null;
    p_balance_element_type_id      := null;
    p_tagging_element_type_id      := null;
    p_object_version_number        := null;
    p_no_link_message              := null;
    p_check_accrual_ff             := null;
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
    rollback to create_accrual_plan_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_accrual_plan_id              := null;
    p_accrual_plan_element_type_id := null;
    p_co_element_type_id           := null;
    p_co_input_value_id            := null;
    p_co_date_input_value_id       := null;
    p_co_exp_date_input_value_id   := null;
    p_residual_element_type_id     := null;
    p_residual_input_value_id      := null;
    p_residual_date_input_value_id := null;
    p_payroll_formula_id           := null;
    p_defined_balance_id           := null;
    p_balance_element_type_id      := null;
    p_tagging_element_type_id      := null;
    p_object_version_number        := null;
    p_no_link_message              := null;
    p_check_accrual_ff             := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_accrual_plan;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_accrual_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_accrual_plan_id              in     number
  ,p_pto_input_value_id           in     number    default hr_api.g_number
  ,p_accrual_category             in     varchar2  default hr_api.g_varchar2
  ,p_accrual_start                in     varchar2  default hr_api.g_varchar2
  ,p_ineligible_period_length     in     number    default hr_api.g_number
  ,p_ineligible_period_type       in     varchar2  default hr_api.g_varchar2
  ,p_accrual_formula_id           in     number    default hr_api.g_number
  ,p_co_formula_id                in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_ineligibility_formula_id     in     number    default hr_api.g_number
  ,p_balance_dimension_id         in     number    default hr_api.g_number
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_payroll_formula_id              out nocopy number
  ,p_defined_balance_id              out nocopy number
  ,p_balance_element_type_id         out nocopy number
  ,p_tagging_element_type_id         out nocopy number
  ,p_check_accrual_ff                out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_check_accrual_ff              boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72);
Begin
  l_proc := g_package ||'update_accrual_plan';
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_accrual_plan_swi;
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
  l_check_accrual_ff :=
    hr_api.constant_to_boolean
      (p_constant_value => p_check_accrual_ff);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_accrual_plan_api.update_accrual_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_accrual_plan_id
    ,p_pto_input_value_id           => p_pto_input_value_id
    ,p_accrual_category             => p_accrual_category
    ,p_accrual_start                => p_accrual_start
    ,p_ineligible_period_length     => p_ineligible_period_length
    ,p_ineligible_period_type       => p_ineligible_period_type
    ,p_accrual_formula_id           => p_accrual_formula_id
    ,p_co_formula_id                => p_co_formula_id
    ,p_description                  => p_description
    ,p_ineligibility_formula_id     => p_ineligibility_formula_id
    ,p_balance_dimension_id         => p_balance_dimension_id
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_information21                => p_information21
    ,p_information22                => p_information22
    ,p_information23                => p_information23
    ,p_information24                => p_information24
    ,p_information25                => p_information25
    ,p_information26                => p_information26
    ,p_information27                => p_information27
    ,p_information28                => p_information28
    ,p_information29                => p_information29
    ,p_information30                => p_information30
    ,p_object_version_number        => p_object_version_number
    ,p_payroll_formula_id           => p_payroll_formula_id
    ,p_defined_balance_id           => p_defined_balance_id
    ,p_balance_element_type_id      => p_balance_element_type_id
    ,p_tagging_element_type_id      => p_tagging_element_type_id
    ,p_check_accrual_ff             => l_check_accrual_ff
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_check_accrual_ff :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_check_accrual_ff
      );
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
    rollback to update_accrual_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_payroll_formula_id           := null;
    p_defined_balance_id           := null;
    p_balance_element_type_id      := null;
    p_tagging_element_type_id      := null;
    p_check_accrual_ff             := null;
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
    rollback to update_accrual_plan_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_payroll_formula_id           := null;
    p_defined_balance_id           := null;
    p_balance_element_type_id      := null;
    p_tagging_element_type_id      := null;
    p_check_accrual_ff             := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_accrual_plan;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_accrual_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_accrual_plan_id              in     number
  ,p_accrual_plan_element_type_id in     number
  ,p_co_element_type_id           in     number
  ,p_residual_element_type_id     in     number
  ,p_balance_element_type_id      in     number
  ,p_tagging_element_type_id      in     number
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
  l_proc    varchar2(72);
Begin
  l_proc := g_package ||'delete_accrual_plan';
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_accrual_plan_swi;
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
  hr_accrual_plan_api.delete_accrual_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_accrual_plan_id
    ,p_accrual_plan_element_type_id => p_accrual_plan_element_type_id
    ,p_co_element_type_id           => p_co_element_type_id
    ,p_residual_element_type_id     => p_residual_element_type_id
    ,p_balance_element_type_id      => p_balance_element_type_id
    ,p_tagging_element_type_id      => p_tagging_element_type_id
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
    rollback to delete_accrual_plan_swi;
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
    rollback to delete_accrual_plan_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_accrual_plan;
begin
  g_package := 'hr_accrual_plan_swi.';
end hr_accrual_plan_swi;

/
